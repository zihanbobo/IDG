//
// Created by ^ on 2017/11/27.
// Copyright (c) 2017 Injoy. All rights reserved.
//

#import "CXInvestmentViewController.h"
#import "Masonry.h"
#import "UIButton+LXMImagePosition.h"
#import "CXProjectListViewController.h"

@interface CXInvestmentViewController ()
        <
        UICollectionViewDelegate,
        UICollectionViewDataSource
        >
@property(weak, nonatomic) SDRootTopView *rootTopView;
@property(strong, nonatomic) UICollectionView *collectionView;
@property(copy, nonatomic) NSMutableArray *dataSourceArr;
@property(copy, readonly, nonatomic) NSArray *imageArr;
@end

@implementation CXInvestmentViewController

static NSString *const cellId_1 = @"cellId";
static NSString *const headerId = @"headerId";

#pragma mark - get & set

- (NSArray *)imageArr {
    return @[@"pm_tzxm", @"pm_bgxm", @"pm_growth", @"pm_thxmgz", @"pm_tmt"];
}

- (NSMutableArray *)dataSourceArr {
    if (nil == _dataSourceArr) {
        _dataSourceArr = [[NSMutableArray alloc] initWithObjects:
                @"投资项目",
                @"并购项目",
                @"Growth潜在项目",
                @"投后项目跟踪",
                @"融资信息",
                        nil];
    }
    return _dataSourceArr;
}

- (UICollectionView *)collectionView {
    if (nil == _collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
        layout.itemSize = CGSizeMake(Screen_Width / 3.5f, 80.f);
        layout.sectionInset = UIEdgeInsetsMake(10.f, 10.f, 0.f, 0.f);
        layout.headerReferenceSize = CGSizeMake(GET_WIDTH(self.view), [UIImage imageNamed:@"hrBgImage"].size.height);

        _collectionView = [[UICollectionView alloc] initWithFrame:(CGRect) {0.f, navHigh, Screen_Width, Screen_Height - navHigh} collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerId];
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:cellId_1];
    }
    return _collectionView;
}

#pragma mark - UI

- (void)setUpNavBar {
    SDRootTopView *rootTopView = [self getRootTopView];
    self.rootTopView = rootTopView;
    [rootTopView setNavTitle:@"项目管理"];
    [rootTopView setUpLeftBarItemImage:[UIImage imageNamed:@"back.png"]
                             addTarget:self.navigationController
                                action:@selector(popViewControllerAnimated:)];
}

- (void)setUpCollectionView {
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-kTabbarSafeBottomMargin);
        make.top.equalTo(self.rootTopView.mas_bottom);
    }];
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *title = self.dataSourceArr[indexPath.row];
    NSLog(@"-->>:%@", title);

    if ([@"投资项目" isEqualToString:title]) {
        CXProjectListViewController *vc = [[CXProjectListViewController alloc] init];
        vc.title = title;
        [self.navigationController pushViewController:vc animated:YES];
        if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
            self.navigationController.interactivePopGestureRecognizer.delegate = nil;
        }
    }
    if ([@"并购项目" isEqualToString:title]) {

    }
    if ([@"Growth潜在项目" isEqualToString:title]) {

    }
    if ([@"投后项目跟踪" isEqualToString:title]) {

    }
    if ([@"融资信息" isEqualToString:title]) {

    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.dataSourceArr count];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        // 头部视图
        UICollectionReusableView *headerView = [collectionView
                dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                   withReuseIdentifier:headerId
                                          forIndexPath:indexPath];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pmBgimage"]];
        [headerView addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(headerView);
        }];
        return headerView;
    }
    return nil;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId_1 forIndexPath:indexPath];

    UIButton *cellButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cellButton.frame = cell.bounds;
    [cellButton setTitle:self.dataSourceArr[indexPath.row] forState:UIControlStateNormal];
    [cellButton setImage:[UIImage imageNamed:self.imageArr[indexPath.row]] forState:UIControlStateNormal];
    [cellButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cellButton.titleLabel setFont:[UIFont systemFontOfSize:13]];
    cellButton.userInteractionEnabled = NO;
    [cellButton setImagePosition:LXMImagePositionTop spacing:5];

    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    [cell.contentView addSubview:cellButton];

    return cell;
}

#pragma mark - view life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpNavBar];

    [self setUpCollectionView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
