//
//  CXAllPeoplleWorkCircleViewController.h
//  InjoyERP
//
//  Created by wtz on 16/11/22.
//  Copyright © 2016年 Injoy. All rights reserved.
//

#import "SDRootViewController.h"
#import "CXAllPeoplleWorkCircleModel.h"

@interface CXAllPeoplleWorkCircleViewController : SDRootViewController

// 底部操作栏
@property (nonatomic,strong) UIView *toolView;
// 文本输入
@property (nonatomic,strong) UITextView *textView;

@property (nonatomic, strong) CXAllPeoplleWorkCircleModel * commentModel;

-(void)collapseAll;

@end
