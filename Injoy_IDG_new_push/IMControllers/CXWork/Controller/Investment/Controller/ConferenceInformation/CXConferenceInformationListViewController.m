//
// Created by ^ on 2017/12/14.
// Copyright (c) 2017 Injoy. All rights reserved.
//

#import "CXConferenceInformationListViewController.h"
#import "CXBaseRequest.h"
#import "MJRefresh.h"
#import "Masonry.h"
#import "CXConferenceInformationListCell.h"
#import "CXConferenceInformationModel.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "CXConferenceInformationDetailViewController.h"

@interface CXConferenceInformationListViewController ()
        <
        UITableViewDelegate,
        UITableViewDataSource
        >
@property(strong, nonatomic) UITableView *listTableView;
@property(strong, nonatomic) NSMutableArray *dataSourceArr;
@property(assign, nonatomic) int pageNumber;
@property(strong, nonatomic) CXConferenceInformationModel *conferenceInformationModel;
@end

@implementation CXConferenceInformationListViewController

const NSString *const m_CI_cellID = @"cellID_1_0";

#pragma mark - HTTP request

- (void)findListRequest {
    NSString *url = [NSString stringWithFormat:@"%@project/opinion/list/%d", urlPrefix, self.eid];

    [CXBaseRequest postResultWithUrl:url
                               param:nil
                             success:^(id responseObj) {
                                 CXConferenceInformationModel *model = [CXConferenceInformationModel yy_modelWithDictionary:responseObj];
                                 self.conferenceInformationModel = model;
                                 if (HTTPSUCCESSOK == model.status) {
                                     [self.dataSourceArr addObjectsFromArray:model.data];
                                 } else {
                                     MAKE_TOAST(model.msg);
                                 }
                                 [self.listTableView reloadData];
                                 [self.listTableView.header endRefreshing];
                             } failure:^(NSError *error) {
                CXAlert(KNetworkFailRemind);
            }];
}

#pragma mark - get & set

- (CXConferenceInformationModel *)conferenceInformationModel {
    if (nil == _conferenceInformationModel) {
        _conferenceInformationModel = [[CXConferenceInformationModel alloc] init];
    }
    return _conferenceInformationModel;
}

- (NSMutableArray *)dataSourceArr {
    if (nil == _dataSourceArr) {
        _dataSourceArr = [[NSMutableArray alloc] init];
    }
    return _dataSourceArr;
}

- (UITableView *)listTableView {
    if (nil == _listTableView) {
        _listTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _listTableView.tableFooterView = [[UIView alloc] init];
        _listTableView.dataSource = self;
        _listTableView.backgroundColor = kBackgroundColor;
        _listTableView.delegate = self;
        _listTableView.separatorColor = kBackgroundColor;
        _listTableView.estimatedRowHeight = 0;
        [_listTableView registerClass:[CXConferenceInformationListCell class] forCellReuseIdentifier:m_CI_cellID];
    }
    return _listTableView;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = [tableView fd_heightForCellWithIdentifier:m_CI_cellID cacheByIndexPath:indexPath configuration:^(id cell) {
        [((CXConferenceInformationListCell *) cell) setAction:self.dataSourceArr[indexPath.row]];
    }];
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CXConferenceInformationDetailViewController *vc = [[CXConferenceInformationDetailViewController alloc] init];
    CXConferenceInformationModel *model = self.dataSourceArr[indexPath.row];
    vc.opinionId = model.opinionId;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (NSInteger) [self.dataSourceArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.dataSourceArr.count) {
        CXConferenceInformationListCell *cell = [tableView dequeueReusableCellWithIdentifier:m_CI_cellID];
        if (!cell) {
            cell = [[CXConferenceInformationListCell alloc]
                    initWithStyle:UITableViewCellStyleDefault
                  reuseIdentifier:m_CI_cellID];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setAction:self.dataSourceArr[indexPath.row]];
        return cell;
    }
    return [[CXConferenceInformationListCell alloc] init];
}

#pragma mark - UI

- (void)setUpTableView {
    [self.view addSubview:self.listTableView];

    [self.listTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-kTabbarSafeBottomMargin);
    }];

    if ([self.listTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.listTableView setSeparatorInset:UIEdgeInsetsZero];
    }

    @weakify(self);
    [self.listTableView addLegendHeaderWithRefreshingBlock:^{
        @strongify(self);
        self.pageNumber = 1;
        [self.dataSourceArr removeAllObjects];
        [self findListRequest];
    }];

    self.listTableView.footer.hidden = YES;
    [self.listTableView.header beginRefreshing];
}

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setUpTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
