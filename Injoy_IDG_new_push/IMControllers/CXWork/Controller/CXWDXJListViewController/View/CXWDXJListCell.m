//
//  CXWDXJListCell.m
//  InjoyIDG
//
//  Created by wtz on 2018/4/13.
//  Copyright © 2018年 Injoy. All rights reserved.
//

#import "CXWDXJListCell.h"
#import "Masonry.h"
#import "CXWDXJListModel.h"

@interface CXWDXJListCell()

@property(strong, nonatomic) UILabel *approvalUserNameLabel;
@property(strong, nonatomic) UILabel *nameLabel;
/// 休假类型
@property(strong, nonatomic) UILabel *kindLabel;
/// 申请时间
@property(strong, nonatomic) UILabel *sqTimeLabel;
/// 开始时间
@property(strong, nonatomic) UILabel *startTimeLabel;
/// 结束时间
@property(strong, nonatomic) UILabel *endTimeLabel;
/// 休假时长
@property(strong, nonatomic) UILabel *timeLabel;

@property(strong, nonatomic) UILabel *reasonLabel;///<审批意见

@end

@implementation CXWDXJListCell


#pragma mark -- setter && getter
- (void)setModel:(CXWDXJListModel *)model{
    
    _model = model;
    
    NSString *userName = [[CXLoaclDataManager sharedInstance] getUserFromLocalFriendsContactsDicWithAccount:model.userName].name;

        self.nameLabel.text = [NSString stringWithFormat:@"%@的销假", userName];

    
    if ([model.signed_objc integerValue] == 1) {//批审中
        self.approvalUserNameLabel.text = @"批审中";
        self.approvalUserNameLabel.textColor = kColorWithRGB(212.f, 115.f, 80.f);
        self.reasonLabel.text = @"";
    } else if([model.signed_objc integerValue] == 2){//批审通过
        self.approvalUserNameLabel.text = @"批审通过";
        self.approvalUserNameLabel.textColor = kColorWithRGB(56.f, 125.f, 19.f);
        self.reasonLabel.text = @"";
    }else if([model.signed_objc integerValue] == 3){//批审驳回
        self.approvalUserNameLabel.text = @"批审驳回";
        self.approvalUserNameLabel.textColor = kColorWithRGB(189.f, 83.f, 85.f);
//        self.reasonLabel.text = [NSString stringWithFormat:@"审批意见： "];
        self.reasonLabel.text = @"";
    }
    self.kindLabel.text = [NSString stringWithFormat:@"销假类型：%@", model.leaveType];
    self.sqTimeLabel.text = [NSString stringWithFormat:@"申请时间：%@", model.operateDate];
    self.startTimeLabel.text = [NSString stringWithFormat:@"开始时间：%@", model.resumptionBegin];
    self.endTimeLabel.text = [NSString stringWithFormat:@"结束时间：%@", model.resumptionEnd];
    self.timeLabel.text = [NSString stringWithFormat:@"销假时长：%.1f天 ",[model.resumptionDays doubleValue]];
//    self.reasonLabel.text = [NSString stringWithFormat:@"审批意见： "];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self =[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupSubview];
    }
    return self;
}
- (void)setupSubview{
    CGFloat margin = 10.0;
    self.nameLabel = [self createLabelWithTextColor:[UIColor blackColor]];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(margin);
    }];
    self.approvalUserNameLabel = [self createLabelWithTextColor:[UIColor blackColor]];
    self.approvalUserNameLabel.textAlignment = NSTextAlignmentRight;
    [self.approvalUserNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(margin);
        make.right.mas_equalTo(-margin);
    }];
    self.kindLabel = [self createLabelWithTextColor:kColorWithRGB(158.f, 158.f, 158.f)];
    [self.kindLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.nameLabel.mas_left);
        make.top.mas_equalTo(self.nameLabel.mas_bottom).mas_offset(margin);
    }];
    self.sqTimeLabel = [self createLabelWithTextColor:kColorWithRGB(158.f, 158.f, 158.f)];
    [self.sqTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.kindLabel.mas_left);
        make.top.mas_equalTo(self.kindLabel.mas_bottom).mas_offset(margin);
    }];
    self.startTimeLabel = [self createLabelWithTextColor:kColorWithRGB(158.f, 158.f, 158.f)];
    [self.startTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.sqTimeLabel.mas_left);
        make.top.mas_equalTo(self.sqTimeLabel.mas_bottom).mas_offset(margin);
    }];
    self.endTimeLabel = [self createLabelWithTextColor:kColorWithRGB(158.f, 158.f, 158.f)];
    [self.endTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.startTimeLabel.mas_left);
        make.top.mas_equalTo(self.startTimeLabel.mas_bottom).mas_offset(margin);
    }];
    self.timeLabel = [self createLabelWithTextColor:kColorWithRGB(158.f, 158.f, 158.f)];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.endTimeLabel.mas_left);
        make.top.mas_equalTo(self.endTimeLabel.mas_bottom).mas_offset(margin);
    }];
    self.reasonLabel = [self createLabelWithTextColor:kColorWithRGB(158.f, 158.f, 158.f)];
    [self.reasonLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.timeLabel.mas_left);
        make.top.mas_equalTo(self.timeLabel.mas_bottom).mas_offset(margin);//间隔统一???
        make.bottom.mas_equalTo(-margin);
    }];
}

- (UILabel *)createLabelWithTextColor:(UIColor *)textColor{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.font = kFontTimeSizeForForm;
    label.textColor = textColor ;
    [self.contentView addSubview:label];
    return label;
}


/*
#pragma mark - life cycle

- (UILabel *)reasonLabel{
    if (_reasonLabel == nil) {
        _reasonLabel = [[UILabel alloc] init];
        _reasonLabel.font = kFontTimeSizeForForm;
        _reasonLabel.textColor =  kColorWithRGB(158.f, 158.f, 158.f);;
    }
    return _reasonLabel;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        UIColor *bgColor = kColorWithRGB(158.f, 158.f, 158.f);
        
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = kFontSizeForDetail;
        [self.contentView addSubview:_nameLabel];
        
        _approvalUserNameLabel = [[UILabel alloc] init];
        _approvalUserNameLabel.font = kFontTimeSizeForForm;
        [self.contentView addSubview:_approvalUserNameLabel];
        
        _kindLabel = [[UILabel alloc] init];
        _kindLabel.textColor = bgColor;
        _kindLabel.font = kFontTimeSizeForForm;
        [self.contentView addSubview:_kindLabel];
        
        _sqTimeLabel = [[UILabel alloc] init];
        _sqTimeLabel.font = kFontTimeSizeForForm;
        _sqTimeLabel.textColor = bgColor;
        [self.contentView addSubview:_sqTimeLabel];
        
        _startTimeLabel = [[UILabel alloc] init];
        _startTimeLabel.font = kFontTimeSizeForForm;
        _startTimeLabel.textColor = bgColor;
        [self.contentView addSubview:_startTimeLabel];
        
        _endTimeLabel = [[UILabel alloc] init];
        _endTimeLabel.textColor = bgColor;
        _endTimeLabel.font = kFontTimeSizeForForm;
        [self.contentView addSubview:_endTimeLabel];
        
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = kFontTimeSizeForForm;
        _timeLabel.textColor = bgColor;
        [self.contentView addSubview:_timeLabel];

//        [self setViewAtuoLayoutWithModel:nil];
    }
    return self;
}

- (void)setViewAtuoLayoutWithModel:(CXWDXJListModel *)model {
    CGFloat margin = 10.f;
    
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(margin);
        make.top.equalTo(self.contentView.mas_top).offset(margin);
    }];
    
    [_approvalUserNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(-margin);
        make.centerY.equalTo(_nameLabel.mas_centerY);
    }];
    
    [_kindLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_nameLabel.mas_left);
        make.top.equalTo(_nameLabel.mas_bottom).offset(margin);
    }];
    
    [_sqTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_kindLabel.mas_left);
        make.top.equalTo(_kindLabel.mas_bottom).offset(margin);
    }];
    
    [_startTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_sqTimeLabel.mas_left);
        make.top.equalTo(_sqTimeLabel.mas_bottom).offset(margin);
    }];
    
    [_endTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_startTimeLabel.mas_left);
        make.top.equalTo(_startTimeLabel.mas_bottom).offset(margin);
    }];
    
     if ([model.signed_objc integerValue] == 3) {//驳回
         [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
             make.left.equalTo(_endTimeLabel.mas_left);
             make.top.equalTo(_endTimeLabel.mas_bottom).offset(margin);
             make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-margin - 20).priorityHigh();
         }];
         
         [self.contentView addSubview:self.reasonLabel];
         [_reasonLabel mas_makeConstraints:^(MASConstraintMaker *make) {
             make.left.equalTo(self.timeLabel.mas_left);
             make.top.equalTo(self.timeLabel.mas_bottom).mas_offset(margin);
             make.bottom.mas_equalTo(-margin);
         }];
     }else{
         [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
             make.left.equalTo(_endTimeLabel.mas_left);
             make.top.equalTo(_endTimeLabel.mas_bottom).offset(margin);
             make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-margin).priorityHigh();
         }];
     }
    
  
}
- (void)setModel:(CXWDXJListModel *)model{
    _model = model;
   
    
}
- (void)setAction:(id)vacationApplicationModel {
    CXWDXJListModel *model = vacationApplicationModel;
    [self setViewAtuoLayoutWithModel:vacationApplicationModel];
    
    _nameLabel.text = [NSString stringWithFormat:@"%@的销假", [[CXLoaclDataManager sharedInstance] getUserFromLocalFriendsContactsDicWithAccount:model.userName].name];
    _kindLabel.text = [NSString stringWithFormat:@"销假类型：%@", model.leaveType];
    _sqTimeLabel.text = [NSString stringWithFormat:@"申请时间：%@", model.operateDate];
    _startTimeLabel.text = [NSString stringWithFormat:@"开始时间：%@", model.resumptionBegin];
    _endTimeLabel.text = [NSString stringWithFormat:@"结束时间：%@", model.resumptionEnd];
    _timeLabel.text = [NSString stringWithFormat:@"销假时长：%.1f天 \n  审批意见:%@", [model.resumptionDays doubleValue],model.reason];
//    _reasonLabel.text = [NSString stringWithFormat:@"审批意见:  %@",model.reason ? : @""];
    // 橙色
    UIColor *color_1 = kColorWithRGB(212.f, 115.f, 80.f);
    // 红色
    UIColor *color_2 = kColorWithRGB(189.f, 83.f, 85.f);
    // 绿色
    UIColor *color_3 = kColorWithRGB(56.f, 125.f, 19.f);
    
    if ([model.signed_objc integerValue] == 1) {
        // 审批中
        _approvalUserNameLabel.textColor = color_1;
        _approvalUserNameLabel.text = @"批审中";
        _reasonLabel.text = nil;
    }else
    if ([model.signed_objc integerValue] == 2) {
        // 审批通过
        _approvalUserNameLabel.textColor = color_3;
        _approvalUserNameLabel.text = @"批审通过";
        _reasonLabel.text = nil;
    }else
    
    if ([model.signed_objc integerValue] == 3) {
        // 审批驳回
        _approvalUserNameLabel.textColor = color_2;
        _approvalUserNameLabel.text = @"批审驳回";
        _reasonLabel.text = [NSString stringWithFormat:@"审批意见:  %@",model.reason ? : @""];
    }

}

//- (void)setApprovalAction:(id)vacationApplicationModel {
//    CXVacationApplicationModel *model = vacationApplicationModel;
//    
//    _nameLabel.text = [NSString stringWithFormat:@"%@的请假", model.name];
//    _kindLabel.text = [NSString stringWithFormat:@"请假类型：%@", model.holidayType];
//    _startTimeLabel.text = [NSString stringWithFormat:@"开始时间：%@", model.leaveStart];
//    _endTimeLabel.text = [NSString stringWithFormat:@"结束时间：%@", model.leaveEnd];
//    _timeLabel.text = [NSString stringWithFormat:@"请假时长：%.1f天", model.leaveDay];
//    
//    // 橙色
//    UIColor *color_1 = kColorWithRGB(212.f, 115.f, 80.f);
//    // 红色
//    UIColor *color_2 = kColorWithRGB(189.f, 83.f, 85.f);
//    // 绿色
//    UIColor *color_3 = kColorWithRGB(56.f, 125.f, 19.f);
//    
//    if (model.isApprove == 0) {
//        // 未审批
//        _approvalUserNameLabel.textColor = color_1;
//        _approvalUserNameLabel.text = @"未批审";
//    }
//    if (model.isApprove == 1) {
//        // 审批同意
//        _approvalUserNameLabel.textColor = color_3;
//        _approvalUserNameLabel.text = @"同意";
//    }
//    
//    if (model.isApprove == 2) {
//        // 审批不同意
//        _approvalUserNameLabel.textColor = color_2;
//        _approvalUserNameLabel.text = @"不同意";
//    }
//}
*/

@end