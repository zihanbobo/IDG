//
//  CXIDGCapitalExpressDetailViewController.m
//  InjoyIDG
//
//  Created by wtz on 2017/12/22.
//  Copyright © 2017年 Injoy. All rights reserved.
//

#import "CXIDGCapitalExpressDetailViewController.h"
#import "HttpTool.h"
#import "Masonry.h"
#import "CXShareView.h"

@interface CXIDGCapitalExpressDetailViewController ()<UIWebViewDelegate>

@property(weak, nonatomic) SDRootTopView *rootTopView;
@property(weak, nonatomic) UIWebView *webView;

@end

@implementation CXIDGCapitalExpressDetailViewController

- (void)setUpSubviews {
    UIWebView *webView = [[UIWebView alloc] init];
    webView.delegate = self;
    webView.scalesPageToFit = YES;
    self.webView = webView;
    [self.view addSubview:webView];
    [webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-kTabbarSafeBottomMargin);
        make.top.equalTo(self.rootTopView.mas_bottom);
    }];
}

- (void)setUpNavBar {
    SDRootTopView *rootTopView = [self getRootTopView];
    self.rootTopView = rootTopView;
    //和安卓一致
    [rootTopView setNavTitle:self.model.title ? : @"快报详情"];
    [rootTopView setUpLeftBarItemImage:[UIImage imageNamed:@"back.png"]
                             addTarget:self.navigationController
                                action:@selector(popViewControllerAnimated:)];
//    [rootTopView setUpRightBarItemImage:[UIImage imageNamed:@"rightShareImage.png"]
//                             addTarget:self
//                                action:@selector(shareBtnClick)];
}

- (void)shareBtnClick{
    NSLog(@"%@",self.model);
    CXShareView* shareView = [CXShareView view];
    shareView.shareTitle = self.model.title;
    shareView.shareContent = self.model.digest;
    shareView.shareUrl = self.model.url;
    [shareView show];
}

#pragma mark - view life

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpNavBar];
    [self setUpSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSURL *url = [NSURL URLWithString:self.model.url];
    NSURLRequest *request = [NSURLRequest
                             requestWithURL:url
                             cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                             timeoutInterval:10.f];
    [_webView loadRequest:request];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSString *meta = [NSString stringWithFormat:@"document.getElementsByName(\"viewport\")[0].content = \"width=%f, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no\"", webView.frame.size.width];
    [webView stringByEvaluatingJavaScriptFromString:meta];
}

@end
