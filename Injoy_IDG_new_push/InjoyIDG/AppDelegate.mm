

//
//  AppDelegate.m
//  SDMarketingManagement
//
//  Created by slovelys on 15/4/23.
//  Copyright (c) 2015年 slovelys. All rights reserved.
//

#import "AppDelegate+IM.h"
#import "AppDelegate.h"
#import "CXVersionsAlertView.h"
#import "RDVTabBarItem.h"
#import "SDChatManager.h"
#import "SDDataBaseHelper.h"
#import "SDIMMyselfViewController.h"
#import "SDLoginViewController.h"
#import "SDRootNavigationController.h"
#import "PlayerManager.h"
#import "CXCompanyCircleViewController.h"
#import "CXMineViewController.h"
#import "AFNetworking.h"
#import "HttpTool.h"
#import "SDCompanyUserModel.h"
#import "SDDataBaseHelper.h"
#import "SDSocketCacheManager.h"
#import "UIImage+EMGIF.h"
#import "UIImageView+EMWebCache.h"
#import <BaiduMapAPI_Map/BMKMapView.h> //只引入所需的单个头文件
#import "CXWorkHomeViewController.h"
#import "CXNewIDGWorkRootViewController.h"
#import "SDIMPersonInfomationViewController.h"
#import "SDIMConversationViewController.h"
#import "SDIMVoiceConferenceViewController.h"
#import "SDPermissionsDetectionUtils.h"
#import <AVFoundation/AVFoundation.h>
#import "CXIMHelper.h"
#import "SDIMContactsViewController.h"
// UMeng
#import "UMSocial.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialQQHandler.h"
#import "UMSocialSinaSSOHandler.h"
#import "WXApi.h"
#import "SDWebSocketManager.h"
#import "CXAllPeoplleWorkCircleViewController.h"
#import "CXYunJingWorkCircleAllViewController.h"
#import "SDIMChangePasswordViewController.h"
#import "UIView+CXCategory.h"
#import "CXDepartmentUtil.h"
#import "CXGroupMember.h"
#import "SDIMVoiceAndVideoCallViewController.h"
#import "CXYMAddressBookViewController.h"
#import "IDGContactsViewController.h"

#define kIsFirstEnterIntoApplication @"isFirstEnterIntoApplication"

@interface AppDelegate () <UIScrollViewDelegate, CXIMChatDelegate, WXApiDelegate> {
    BMKMapManager *_mapManager;
    SDLoginViewController *_loginController;
    NSDictionary *_launchDict;
}

@property(nonatomic, weak) UIPageControl *pageControl;
@property(nonatomic, weak) UIScrollView *scrollView;
@property(nonatomic, strong) NSTimer *myTimer;
@property(nonatomic, weak) UIButton *nextTapButton;
//保证整个应用周期，只能有一个标签栏控制器
@property(nonatomic, strong) RDVTabBarController *shareTabBar;
//新版下载链接网址
@property(nonatomic, strong) NSString *versionUrlLink;
@property(nonatomic, assign) BOOL canLoginFlag;
//上一次播放来新消息提示音的时间
@property(nonatomic, strong) NSDate *lastPlaySoundDate;
//第一次进入界面
@property(nonatomic, assign) BOOL isFristEnter;
@property(nonatomic, assign) NSInteger totalTime;

@end

@implementation AppDelegate

static RDVTabBarController *tabBar;

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [application cancelAllLocalNotifications];
    
   
    self.totalTime = 0;
    self.isFristEnter = YES;
    // 设置友盟
    [self setupUMengOptions];

    //如果未保存权限设置则需要保存权限设置
    if (VAL_HAD_SAVE_PERMISSION_SETTINGS == nil) {
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setBool:YES forKey:ENABLE_GET_NEW_MESSAGE_NOTIFICATION];
        [ud setBool:YES forKey:ENABLE_MAKE_SOUND];
        [ud setBool:YES forKey:ENABLE_SHOCK];
        [ud setBool:YES forKey:ENABLE_LOUD_SPEAKER];
        [ud setBool:YES forKey:ENABLE_GET_LOCATION];
        [ud setValue:@"已经保存权限设置" forKey:HAD_SAVE_PERMISSION_SETTINGS];
        [ud synchronize];
    }

    _canLoginFlag = YES;

    [SDCommonDefine sharedInstance];

    _launchDict = launchOptions;
    [[CXIMService sharedInstance].chatManager addDelegate:self];

    //设置状态栏状态
 [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];     [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    //    清除缓存的图片
    [[[EMSDWebImageManager sharedManager] imageCache] clearMemory];
    [[[EMSDWebImageManager sharedManager] imageCache] clearDisk];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginStateChange:)
                                                 name:KNOTIFICATION_LOGINCHANGE
                                               object:nil];
    
    // 红点通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivePushNotification:) name:kReceivePushNotificationKey object:nil];
    

    [self.window makeKeyAndVisible];

    tabBar = [[RDVTabBarController alloc] init];
    self.shareTabBar = tabBar;

    [self enterIntoMainInterface];
    
    return YES;
}

/**
 *  设置友盟
 */
- (void)setupUMengOptions {
    // 友盟
    [UMSocialData setAppKey:@"57d0d4f7e0f55a657b003248"];
    // 微信
    [UMSocialWechatHandler setWXAppId:@"wx8142d1cbe9e0e02f" appSecret:@"373264dc6daa6c1d6b23c688b513f1cb" url:@"http://www.umeng.com/social"];
    // QQ
//    [UMSocialQQHandler setQQWithAppId:@"1105920726" appKey:@"rlA3ktnJNQ9JH5HW" url:@"http://www.umeng.com/social"];

    // 新浪微博
    [UMSocialSinaSSOHandler openNewSinaSSOWithAppKey:@"1140947213" secret:@"a9eb9540e90e0c12e2ac3c64f2b58abe" RedirectURL:@"http://sns.whalecloud.com/sina2/callback"];

#ifdef DEBUG
    [UMSocialData openLog:YES];
#endif
}

- (RDVTabBarController *)getRDVTabBarController {
    return tabBar;
}

+ (RDVTabBarController *)get_RDVTabBarController {
    return tabBar;
}

- (void)setupViewControllers {
    tabBar = self.shareTabBar;

    CXNewIDGWorkRootViewController *workHomeViewController = [[CXNewIDGWorkRootViewController alloc] init];
    // 聊聊
    SDIMConversationViewController *conversation = [[SDIMConversationViewController alloc] init];
    //通讯录
    IDGContactsViewController *contacts = [[IDGContactsViewController alloc] init];
    // 我
    SDIMPersonInfomationViewController *mineVC = [[SDIMPersonInfomationViewController alloc] init];
    mineVC.canPopViewController = NO;
    SDCompanyUserModel *userModel = [CXIMHelper getUserByIMAccount:VAL_HXACCOUNT];
    mineVC.imAccount = userModel.imAccount;

    SDRootNavigationController *nav = [[SDRootNavigationController alloc] initWithRootViewController:tabBar];

    [tabBar setViewControllers:@[workHomeViewController, conversation, contacts, mineVC]];
    self.viewController = nav;
    NSArray *tabBarItemImagesNormal = @[@"tab_work_off", @"tab1_chat_off", @"tab3_oa_off", @"tab5_my_off"];
    NSArray *tabBarItemImagesSelected = @[@"tab_work", @"tab1_chat_on", @"tab3_oa_on", @"tab5_my_on"];
    NSArray *tabBatItemTitles = @[@"工作台", @"I-Chat", @"通讯录", @"我"];
    [self customizeTabBarForController:tabBar normalImages:tabBarItemImagesNormal selectedImages:tabBarItemImagesSelected titles:tabBatItemTitles];
}


- (void)customizeTabBarForController:(RDVTabBarController *)tabBarController normalImages:(NSArray *)tabBarItemImagesNormal
                      selectedImages:(NSArray *)tabBarItemImagesSelected
                              titles:(NSArray *)tabBatItemTitles {
    NSInteger index = 0;
    for (RDVTabBarItem *item in [[tabBarController tabBar] items]) {
        [item setBackgroundSelectedImage:nil withUnselectedImage:nil];
        UIImage *selectedimage = [UIImage imageNamed:[NSString stringWithFormat:@"%@",
                                                                                [tabBarItemImagesSelected objectAtIndex:index]]];
        UIImage *unselectedimage = [UIImage imageNamed:[NSString stringWithFormat:@"%@",
                                                                                  [tabBarItemImagesNormal objectAtIndex:index]]];
        [item setFinishedSelectedImage:selectedimage withFinishedUnselectedImage:unselectedimage];

        item.title = [tabBatItemTitles objectAtIndex:index];

        index++;
    }
}

- (void)enterIntoMainInterface {
    //检查版本更新
    [[NSUserDefaults standardUserDefaults] setObject:@1 forKey:kIsFirstEnterIntoApplication];
    [[NSUserDefaults standardUserDefaults] synchronize];

    //销毁定时器
    [self.myTimer invalidate];
    self.myTimer = nil;
    _connectionState = eEMConnectionConnected;

    [self imApplication:[UIApplication sharedApplication] didFinishLaunchingWithOptions:nil];

    /// 添加对BMKMapManager的初始化，并填入您申请的授权Key
    _mapManager = [[BMKMapManager alloc] init];
    BOOL ret = [_mapManager start:@"5H1KzNlLRpK5otqppPfH1ewPaAkzTImV" generalDelegate:nil];// 超享 idg上架使用
    if (!ret) {
        NSLog(@"百度地图管理器初始化失败/BMKMapManager start failed");
    }

    [self loginStateChange:nil];
    #ifdef DEBUG
    [self downloadBBData];
    #else
    [self downloadBBData];
    #endif
}

#pragma mark - private
//登陆状态改变
- (void)loginStateChange:(NSNotification *)notification {
    NSUserDefaults *localLoginDefaults = [NSUserDefaults standardUserDefaults];
    NSString *account = [localLoginDefaults valueForKey:@"account"];
    NSString *pwd = [localLoginDefaults valueForKey:@"pwd"];
    //如果保存了登录账号和密码并且notification为nil
    if(notification == nil && account && pwd){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setupViewControllers];
            [self setRootIMNavigationViewController];
            [self loginUser];
            return;
        });
    }else{
        //获取公司帐号
        NSString *companyAccount = [localLoginDefaults stringForKey:@"companyAccount"];
        
        self.compantID = companyAccount;
        BOOL loginSuccess = [notification.object boolValue];
        
        if (loginSuccess) { //登陆成功加载主窗口控制器
            if(VAL_IS_Update_Pwd){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self setupViewControllers];
                    [self setRootIMNavigationViewController];
                    [_loginController hideHud];
                });
            }else{
                SDIMChangePasswordViewController * changePasswordViewController = [[SDIMChangePasswordViewController alloc] init];
                self.window.rootViewController = changePasswordViewController;
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"首次登录需要修改您的密码！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
            }
        }
        else {
            //登陆失败加载登陆页面控制器
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            // 记住密码
            BOOL isOn = [defaults boolForKey:@"remember"];
            NSString *userName;
            NSString *pwd;
            NSString *account;
            NSString *companyAccount;
            if (isOn) {
                userName = [localLoginDefaults stringForKey:@"userName"];
                pwd = [localLoginDefaults stringForKey:@"pwd"];
                companyAccount = [localLoginDefaults stringForKey:@"companyAccount"];
                // 手机号码
                account = [localLoginDefaults stringForKey:@"account"];
            } else {
                userName = [localLoginDefaults stringForKey:@"userName"];
                pwd = [localLoginDefaults stringForKey:@"pwd"];
                account = @"";
            }
            _loginController = _loginController ?: [[SDLoginViewController alloc] init];
            _loginController.subLoginView.myAccount.text = account;
            _loginController.subLoginView.password.text = pwd;
            
            self.window.rootViewController = _loginController;
        }
    }
}

//登录
- (void)loginUser {
    [[SDCommonDefine sharedInstance] systemUse];
    NSString *url = [NSString stringWithFormat:@"%@login", urlPrefix];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSUserDefaults *loginDefaults = [NSUserDefaults standardUserDefaults];
    NSString *account = [loginDefaults valueForKey:@"account"];
    NSString *pwd = [loginDefaults valueForKey:@"pwd"];
    [params setValue:account forKey:@"account"];
    [params setValue:[NSString md5:[NSString md5:pwd]] forKey:@"password"];
    params[@"appOs"] = @"ios";
    __weak typeof(self) weakSelf = self;
    [HttpTool postWithPath:url
                    params:params
                   success:^(id JSON) {
                       NSDictionary *dict = JSON;
                       NSDictionary *dataDict = dict[@"data"];
                       //统计报表isShare为1，统计报表有分享，为0则没有分享
                       NSNumber *isShare = dict[@"data"][@"isShare"];
                       NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                       [defaults setObject:isShare forKey:kShareForERPStatisticsType];
                       [defaults synchronize];
                       // 静态数据{staticList}
                       [defaults setValue:[dict valueForKeyPath:@"data.staticList"] forKey:KStaticData];
                       NSNumber *status = [dict objectForKey:@"status"];
                       if (status.intValue == 200) {
                           // 公司id
                           NSString *companyId = [NSString stringWithFormat:@"%@",[dataDict valueForKey:@"companyId"]];
                           if ([companyId length] > 0) {
                               [[NSUserDefaults standardUserDefaults] setValue:companyId forKey:COMPANYID];
                           }
                           // 公司名称
                           NSString *companyName = [dataDict valueForKey:@"companyName"];
                           if ([companyName length] > 0) {
                               [[NSUserDefaults standardUserDefaults] setValue:companyName forKey:KCompanyName];
                           }
                           
                           // 定制启动页
                           NSString *s_logo = [dataDict valueForKey:@"iosLogo4"];
                           if ([s_logo length] > 0) {
                               [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%@^%@",s_logo,VAL_companyId] forKey:KCompanyLogo];
                           } else {
                               [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:KCompanyLogo];
                           }
                           
                           // 是否开启指纹登陆
                           NSString *s_fingerprintLogin = [NSString stringWithFormat:@"%@",[dataDict valueForKey:@"s_fingerprintLogin"]];
                           if ([s_fingerprintLogin length] > 0) {
                               [[NSUserDefaults standardUserDefaults] setValue:s_fingerprintLogin forKey:KFingerprintLogin];
                           }
                           
                           
                           // 部门名称
                           NSString *dpName = [dataDict valueForKey:@"dpName"];
                           if ([dpName length] > 0) {
                               [[NSUserDefaults standardUserDefaults] setValue:dpName forKey:KDpName];
                           }
                           // 用户名称
                           NSString *userName = [dataDict valueForKey:@"userName"];
                           if ([userName length] > 0) {
                               [[NSUserDefaults standardUserDefaults] setValue:userName forKey:kUserName];
                           }
                           // 账号
                           NSString *account = [dataDict valueForKey:@"account"];
                           if ([account length] > 0) {
                               [[NSUserDefaults standardUserDefaults] setValue:account forKey:kAccount];
                           }
                           // 职务
                           NSString *job = [dataDict valueForKey:@"job"];
                           if (![job isKindOfClass:[NSNull class]] && [job length] > 0) {
                               [[NSUserDefaults standardUserDefaults] setValue:job forKey:KJob];
                           }
                           // 下载链接或者官网链接
                           NSString *iosdownload = [dataDict valueForKey:@"ios_download"];
                           if ([iosdownload length] > 0) {
                               [[NSUserDefaults standardUserDefaults] setValue:iosdownload forKey:IOS_DOWNLOAD];
                           }
                           // 用户ID
                           NSNumber *userID = [dataDict valueForKey:@"eid"];// 用户ID
                           if ([userID.stringValue length] > 0) {
                               [[NSUserDefaults standardUserDefaults] setValue:userID forKey:KUserID];
                           }
                           
                           // 是否是超级用户
                           NSNumber *isSuper = [dataDict objectForKey:@"isSuper"];
                           [[NSUserDefaults standardUserDefaults] setInteger:isSuper.integerValue forKey:KIsSuper];
                           
                           // 超级用户状态
                           NSNumber *superStatus = [dataDict objectForKey:@"superStatus"];
                           [[NSUserDefaults standardUserDefaults] setInteger:superStatus.integerValue forKey:KSuperStatus];
                           
                           // 用户类型 1=公司管理员，2=普通用户
                           NSNumber *userType = [dataDict objectForKey:@"userType"];
                           [[NSUserDefaults standardUserDefaults] setObject:userType forKey:KUserType];
                           
                           // dpId
                           NSNumber *dpId = [dataDict valueForKey:KDpId];
                           if (dpId) {
                               [[NSUserDefaults standardUserDefaults] setValue:dpId forKey:KDpId];
                           }
                           // 用户身份层次
                           NSString *userLevel = [NSString stringWithFormat:@"%@", [dataDict valueForKey:@"level"]];
                           if ([userLevel length] > 0) {
                               [[NSUserDefaults standardUserDefaults] setValue:userLevel forKey:KUserlevel];
                           }
                           // 公司level
                           NSString *companyLevel = [NSString stringWithFormat:@"%@", [dataDict valueForKey:@"companyLevel"]];
                           if ([companyLevel length] > 0) {
                               [[NSUserDefaults standardUserDefaults] setValue:companyLevel forKey:KCompanylevel];
                           }
                           // 头像路径
                           NSString *icon = [dataDict objectForKey:@"icon"];
                           if ([icon isKindOfClass:NSNull.class]) {
                               icon = nil;
                           }
                           [[NSUserDefaults standardUserDefaults] setValue:icon forKey:kIcon];
                           // im帐号
                           NSString *hUser = [dataDict objectForKey:@"imAccount"];
                           if ([hUser length] > 0) {
                               // 将IM用户名保存在本地
                               [[NSUserDefaults standardUserDefaults] setValue:hUser forKey:HXACCOUNT];
                           }
                           // im帐号是否启用：1:启用，0:停用
                           NSString *imStatus = [NSString stringWithFormat:@"%@", [dataDict objectForKey:@"imStatus"]];
                           if ([imStatus length] > 0) {
                               // 将IM用户名保存在本地
                               [[NSUserDefaults standardUserDefaults] setValue:imStatus forKey:KImStatus];
                           }
                           
                           // 权限菜单
                           NSArray *menulist = [[dataDict objectForKey:@"menuList"] mutableCopy];
                           if ([menulist count] > 0) {
                               // 将IM用户名保存在本地
                               [[NSUserDefaults standardUserDefaults] setValue:menulist forKey:KMenuList];
                           }
                           
                           BOOL isZhuanShuDingZhi = ([[dataDict objectForKey:@"level"] integerValue] == 2)?YES:NO;
                           NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                           [ud setBool:isZhuanShuDingZhi forKey:ISZHUAN_SHU_DING_ZHI];
                           
                           BOOL isShowAnnualMeeting = ([[dataDict objectForKey:@"showAnnualMeeting"] integerValue] == 1)?YES:NO;
                           [ud setBool:isShowAnnualMeeting forKey:ISSHOW_ANNUALMEETING];
                           
                           BOOL isUpdatePwd = ([[dataDict objectForKey:IS_Update_Pwd] integerValue] == 1)?YES:NO;
                           [ud setBool:isUpdatePwd forKey:IS_Update_Pwd];
                           
                           BOOL isAnnualTem = ([[dataDict objectForKey:IS_AnnualTem] integerValue] == 1)?YES:NO;
                           [ud setBool:isAnnualTem forKey:IS_AnnualTem];
                           
                           BOOL isOpenGetLocation = ([[dataDict objectForKey:@"s_location"] integerValue] == 1)?YES:NO;
                           [ud setBool:isOpenGetLocation forKey:OPEN_GET_LOCATION];
                           
                           // 是否开启已阅未阅
                           BOOL isOpenReadFlag = ([[dataDict objectForKey:@"s_read"] integerValue] == 1) ? YES : NO;
                           [ud setBool:isOpenReadFlag forKey:OPEN_READ_FLAG];
                           
                           //如果未保存权限设置则需要保存权限设置
                           if (VAL_HAD_SAVE_RedViewShow == nil) {
                               NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                               [ud setValue:[NSString stringWithFormat:@"已经保存%@红点开关", VAL_HXACCOUNT] forKey:HAD_SAVE_RedViewShow];
                               [ud setBool:NO forKey:SHOW_ADD_FRIENDS];
                               [ud setBool:NO forKey:HAVE_UNREAD_WORKCIRCLE_MESSAGE];
                               [ud synchronize];
                           }
                           
                           // token
                           [[NSUserDefaults standardUserDefaults] setValue:[dataDict valueForKey:@"token"] forKey:key_token];
                           
                           NSString *updateTime = [dataDict objectForKey:@"updateTime"];
                           if ([updateTime length] > 0) {
                               // 将环信用户名保存在本地
                               [[NSUserDefaults standardUserDefaults] setValue:updateTime forKey:kUpdateTime];
                           }
                           
                           NSString *yaoUrl = [dataDict objectForKey:YAOURL];
                           yaoUrl = [yaoUrl stringByReplacingOccurrencesOfString:@"{userId}" withString:[NSString stringWithFormat:@"%zd", [VAL_USERID integerValue]]];
                           [[NSUserDefaults standardUserDefaults] setValue:yaoUrl forKey:YAOURL];
                           
                           //是否已经加入推广群
                           NSString *applyGroup = [dataDict objectForKey:@"applyGroup"];
                           if (applyGroup && [applyGroup isEqualToString:@"1"]) {
                               [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IMUserHasdJoinExtensionGroupKey];
                           } else {
                               [[NSUserDefaults standardUserDefaults] setBool:NO forKey:IMUserHasdJoinExtensionGroupKey];
                           }
                           [[NSUserDefaults standardUserDefaults] synchronize];
                           
                           [[CXDepartmentUtil sharedInstance] getDepartmentDataFromServer];
                           [weakSelf imLoginWithUsername:hUser password:pwd];
                       } else {
                           UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:JSON[@"msg"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                           [alert show];
                       }
                   }
                   failure:^(NSError *error) {
                       UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"连接服务器失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                       [alert show];
                   }];
}

#pragma mark IM登陆
- (void)imLoginWithUsername:(NSString *)username password:(NSString *)password {
    //#ifdef DEBUG
    //    // 屏蔽im登录
    //    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@YES];
    //    [SDDataBaseHelper shareDB];
    //    return;
    //
    //#endif

    [SDWebSocketManager shareWebSocketManager]; // 初始化SDWebSocketManager添加代理
    [[CXIMService sharedInstance] loginWithAccount:username password:password completion:^(NSError *error) {
        if (!error) {            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSArray *groups = [[CXIMService sharedInstance].groupManager loadGroupsFromDB];
                [[CXLoaclDataManager sharedInstance] saveLocalGroupDataWithGroups:groups];
                [self downloadTXL];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [CXPushHelper updateDeviceToken];
                    [SDDataBaseHelper shareDB];
                    [[NSNotificationCenter defaultCenter] postNotificationName:UserLoginSuccessNotification object:nil];
                    ((AppDelegate *)[UIApplication sharedApplication].delegate).locateTimer.fireDate = [NSDate distantPast];
                });
            });
            
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:KNetworkFailRemind delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            NSLog(@"cxim login error:%@", error.localizedDescription);
        }
    }];
}

- (void)downloadTXL{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *url = [NSString stringWithFormat:@"%@/sysuser/new/list", urlPrefix];
        
        [HttpTool getWithPath:url params:nil success:^(id JSON) {
            NSNumber *status = JSON[@"status"];
            if ([status intValue] == 200) {
                [[CXLoaclDataManager sharedInstance].depKJArray removeAllObjects];
                [[CXLoaclDataManager sharedInstance].allKJDicContactsArray removeAllObjects];
                [[CXLoaclDataManager sharedInstance].allKJDepDataArray removeAllObjects];
                [[CXLoaclDataManager sharedInstance].depArray removeAllObjects];
                [[CXLoaclDataManager sharedInstance].allDicContactsArray removeAllObjects];
                [[CXLoaclDataManager sharedInstance].allDepDataArray removeAllObjects];
                NSArray * contactsArray = JSON[@"data"][@"contacts"];
                for(NSDictionary * depDataDic in contactsArray){
                    [[CXLoaclDataManager sharedInstance].depKJArray addObject:depDataDic.allKeys[0]];
                    NSArray * depDataArray = depDataDic.allValues[0];
                    //用来保存每一组的userModelArray
                    NSMutableArray * depUsersArray = @[].mutableCopy;
                    for(NSDictionary * contactDic in depDataArray){
                        NSMutableDictionary * mutableDic = contactDic.mutableCopy;
                        if([mutableDic[@"icon"] isKindOfClass:[NSNull class]]){
                            mutableDic[@"icon"] = @"";
                        }
                        [[CXLoaclDataManager sharedInstance].allKJDicContactsArray addObject:mutableDic];
                        
                        SDCompanyUserModel *userModel = [SDCompanyUserModel yy_modelWithDictionary:contactDic];
                        userModel.userId = @([contactDic[@"userId"] integerValue]);
                        [depUsersArray addObject:userModel];
                    }
                    NSMutableDictionary * userDic = [NSMutableDictionary dictionary];
                    [userDic setValue:depUsersArray forKey:depDataDic.allKeys[0]];
                    [[CXLoaclDataManager sharedInstance].allKJDepDataArray addObject:userDic];
                }
                
                NSArray * allContactsArray = JSON[@"data"][@"allContacts"];
                for(NSDictionary * depDataDic in allContactsArray){
                    [[CXLoaclDataManager sharedInstance].depArray addObject:depDataDic.allKeys[0]];
                    NSArray * depDataArray = depDataDic.allValues[0];
                    //用来保存每一组的userModelArray
                    NSMutableArray * depUsersArray = @[].mutableCopy;
                    for(NSDictionary * contactDic in depDataArray){
                        NSMutableDictionary * mutableDic = contactDic.mutableCopy;
                        if([mutableDic[@"icon"] isKindOfClass:[NSNull class]]){
                            mutableDic[@"icon"] = @"";
                        }
                        [[CXLoaclDataManager sharedInstance].allDicContactsArray addObject:mutableDic];
                
                        SDCompanyUserModel *userModel = [SDCompanyUserModel yy_modelWithDictionary:contactDic];
                        userModel.userId = @([contactDic[@"userId"] integerValue]);
                        [depUsersArray addObject:userModel];
                    }
                    NSMutableDictionary * userDic = [NSMutableDictionary dictionary];
                    [userDic setValue:depUsersArray forKey:depDataDic.allKeys[0]];
                    [[CXLoaclDataManager sharedInstance].allDepDataArray addObject:userDic];
                }
                [[CXLoaclDataManager sharedInstance] saveLocalFriendsDataWithFriends:[CXLoaclDataManager sharedInstance].allKJDicContactsArray];
                
                [[CXLoaclDataManager sharedInstance] saveSearchLocalFriendsDataWithFriends:[CXLoaclDataManager sharedInstance].allDicContactsArray];
            }else{
                
            }
        } failure:^(NSError *error) {
            
        }];
    });
}

- (void)setRootIMNavigationViewController {
    AppDelegate *appDelegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
    SDRootNavigationController *nav = [[SDRootNavigationController alloc] initWithRootViewController:[appDelegate getRDVTabBarController]];
    [appDelegate getRDVTabBarController].selectedIndex = 0;
    appDelegate->_storedViewController = appDelegate.window.rootViewController;
    self.window.rootViewController = nav;
}

#pragma mark-- 获取 userid

+ (NSString *)getUserID {
    return [NSString stringWithFormat:@"%@", VAL_USERID];
}

///类方法获取用户名
+ (NSString *)getUserName:(NSInteger)userID {
    return [[SDDataBaseHelper shareDB] getUserName:userID];
}

+ (NSString *)getUserHXAccount {
    return VAL_HXACCOUNT;
}

+ (NSString *)getJobRole {
    return [[SDDataBaseHelper shareDB] getUserJobRole:[VAL_USERID integerValue]];
}

#pragma mark-- 获取 companyID

+ (NSString *)getCompanyID {
    return VAL_companyId;
}

+ (NSString *)getCompanyAccount {
    return VAL_companyAccount;
}

+ (NSString *)getUserDeptId {
    return [[SDDataBaseHelper shareDB] getUserDeptID2:[[AppDelegate getUserID] integerValue]];
}

+ (NSString *)getUserDeptName {
    return [[SDDataBaseHelper shareDB] getUserDept:[[AppDelegate getUserID] integerValue]];
}

+ (NSString *)getUserDeptNameByUserId:(NSInteger)userId {
    return [[SDDataBaseHelper shareDB] getUserDept:userId];
}

+ (NSString *)getUserDeptName:(NSInteger)dpid {
    return [[SDDataBaseHelper shareDB] getUserDeptName:dpid];
}

+ (NSString *)getUserType {
    return [[SDDataBaseHelper shareDB] getUserTypeByUserID:[AppDelegate getUserID]];
}

- (void)localNotificationForSocketPush {
    //移除之前的本地消息通知
    for (UILocalNotification *localNotification in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
        NSDictionary *notificaionUserInfo = localNotification.userInfo;
        if ([notificaionUserInfo[@"socketNoticeKey"] isEqualToString:@"socketType"]) {
            [[UIApplication sharedApplication] cancelLocalNotification:localNotification];
        }
    }
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {

    [self reloadRedCount];
    
    __block UIBackgroundTaskIdentifier taskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:taskIdentifier];
        taskIdentifier = UIBackgroundTaskInvalid;
    }];
    
    [CXPushHelper sendBadgeToServer];
}

#pragma mark-- 程序即将进入前台要执行的代码

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [self localNotificationForSocketPush];
    if([CXIMService sharedInstance].socketManager.state == CXIMSocketState_OPEN){
        //更新待办(请假审批,销假审批,报销审批,出差审批)
        dispatch_async(dispatch_get_global_queue(0, 0), ^{//处理
            [self getCostService];
            [self getTraveService];
            [self getHolidayService];
            [self getResumptionService];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kReceivePushNotificationKey object:nil];
            });
            
        });
    }
    
}

#pragma 获取出差数量
-(void)getTraveService{
    NSString *path = [NSString stringWithFormat:@"%@sysuser/approveNum/trave",urlPrefix];
    [HttpTool getWithPath:path params:nil success:^(id JSON) {
        NSInteger status = [JSON[@"status"] integerValue];
        if (status == 200) {
            dispatch_async(dispatch_get_main_queue(), ^{//更新待办
                NSInteger data = [JSON[@"data"] integerValue];
                [[NSUserDefaults standardUserDefaults] setInteger:data forKey:CX_trave];
                [[NSUserDefaults standardUserDefaults] synchronize];
            });
           
        }
        
    } failure:^(NSError *error) {
        
    }];
}
#pragma 获取请假数量
-(void)getHolidayService{
    NSString *path = [NSString stringWithFormat:@"%@sysuser/approveNum/holiday",urlPrefix];
    [HttpTool getWithPath:path params:nil success:^(id JSON) {
        NSInteger status = [JSON[@"status"] integerValue];
        if (status == 200) {
            dispatch_async(dispatch_get_main_queue(), ^{//更新待办
                NSInteger data = [JSON[@"data"] integerValue];
                [[NSUserDefaults standardUserDefaults] setInteger:data forKey:CX_holiday];
                [[NSUserDefaults standardUserDefaults] synchronize];
            });
           
        }
    } failure:^(NSError *error) {
        
    }];
}
#pragma 获取销假数量
-(void)getResumptionService{
    NSString *path = [NSString stringWithFormat:@"%@sysuser/approveNum/resumption",urlPrefix];
    [HttpTool getWithPath:path params:nil success:^(id JSON) {
        NSInteger status = [JSON[@"status"] integerValue];
        if (status == 200) {
            dispatch_async(dispatch_get_main_queue(), ^{//更新待办
                NSInteger data = [JSON[@"data"] integerValue];
                [[NSUserDefaults standardUserDefaults] setInteger:data forKey:CX_resumption];
                [[NSUserDefaults standardUserDefaults] synchronize];
            });
            
        }
    } failure:^(NSError *error) {
        
    }];
}
#pragma 获取报销数量
-(void)getCostService{
    NSString *path = [NSString stringWithFormat:@"%@sysuser/approveNum/cost",urlPrefix];
    [HttpTool getWithPath:path params:nil success:^(id JSON) {
        NSInteger status = [JSON[@"status"] integerValue];
        if (status == 200) {
            dispatch_async(dispatch_get_main_queue(), ^{//更新待办
                NSInteger data = [JSON[@"data"] integerValue];
                [[NSUserDefaults standardUserDefaults] setInteger:data forKey:CX_cost];
                [[NSUserDefaults standardUserDefaults] synchronize];
            });
           
        }
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark-- 手势验证成功，进入主界面

- (void)success {
    //切换到主界面
    [self.window setRootViewController:self.viewController];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSLog(@"applicationWillTerminate");
    [CXPushHelper sendBadgeToServer];
    [NSThread sleepForTimeInterval:3];
}

#pragma mark 下载新版介绍的数据

- (void)downloadBBData {
    __weak typeof(self) weakSelf = self;
    NSString *urlString = [NSString stringWithFormat:@"%@sysversion/ios/1", urlPrefix];

    [HttpTool getWithPath:urlString
                   params:nil
                  success:^(id JSON) {
                      weakSelf.scrollView.scrollEnabled = YES;

                      // app版本
                      NSString *version = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
                      NSDictionary *jsonDict = JSON;
                      if ([jsonDict[@"status"] integerValue] == 200) {
                          // 新版本号 和 当前forgetStatus
                          NSString *newVersionName = [NSString stringWithFormat:@"%@", jsonDict[@"data"][@"versionName"]];
                          NSString *newForgetStatus = [NSString stringWithFormat:@"%@", jsonDict[@"data"][@"forgetStatus"]];
                          NSString * urlLink = [NSString stringWithFormat:@"%@", jsonDict[@"data"][@"urlLink"]];
                          // 苹果审核入口
                          // [苹果审核所需条件：app版本等于最新版本，且按钮状态为隐藏]
                          if ([newVersionName isEqualToString:version] && [newForgetStatus isEqualToString:@"2"]) {
                              // 保存新的 forgetstatus
                              NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                              [ud setValue:@"2" forKey:kForgetStatusKey];
                              [ud synchronize];
                          }
                              // 用户使用入口
                          else {
                              // 显示注册和忘记密码按钮
                              NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                              [ud setValue:@"1" forKey:kForgetStatusKey];
                              [ud synchronize];
                              _loginController.registerForgetButtonHidden = NO;

                              // [用户更新所需条件：app版本不等于最新版本]
                              if ([newVersionName doubleValue] > [version doubleValue] && [newForgetStatus isEqualToString:@"1"]) {
                                  _canLoginFlag = NO;
                                  weakSelf.versionUrlLink = jsonDict[@"data"][@"urlLink"];
                                  if ([weakSelf.versionUrlLink isEqual:[NSNull class]] || [weakSelf.versionUrlLink isEqualToString:@""] || weakSelf.versionUrlLink == nil) {
                                      weakSelf.versionUrlLink = urlLink;
                                  }
                                  //提醒客户前往appstore下载
                                  NSString *descri = jsonDict[@"data"][@"description"];
                                  NSString *description = [NSString stringWithFormat:@"%@", descri];
                                  CXVersionsAlertView *alertView = [[CXVersionsAlertView alloc] init];
                                  alertView.title = @"发现新版本";
                                  alertView.content = description;
                                  alertView.ignoreButtonTapped = ^(CXVersionsAlertView *alertView) {
                                      [alertView dismiss];
                                  };
                                  alertView.updateButtonTapped = ^(CXVersionsAlertView *alertView) {
                                      [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlLink]];
                                  };
                                  [alertView show];
                              }else {
                                  [[NSNotificationCenter defaultCenter] postNotificationName:@"autoLoginSoftware" object:nil];
                              }
                          }
                      }
                  }
                  failure:^(NSError *error) {
                      //NSLog(@"%@", error.description);
                      weakSelf.scrollView.scrollEnabled = YES;
                  }];
}

#pragma mark - 跳转

+ (void)jumpToIMModule {
    AppDelegate *appDelegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
    SDRootNavigationController *nav = [[SDRootNavigationController alloc] initWithRootViewController:[appDelegate getRDVTabBarController]];
    [appDelegate getRDVTabBarController].selectedIndex = 0;
    appDelegate->_storedViewController = appDelegate.window.rootViewController;

    [UIView transitionWithView:[appDelegate window] duration:0.4 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                BOOL oldState = [UIView areAnimationsEnabled];
                [UIView setAnimationsEnabled:NO];
                [[appDelegate window] setRootViewController:nav];
                [UIView setAnimationsEnabled:oldState];
            }
                    completion:nil];
    //停止播放声音
    PlayerManager *playManager = [PlayerManager sharedManager];
    [playManager stopPlaying];
    //恢复声音播放
    [[NSNotificationCenter defaultCenter] postNotificationName:@"voiceResumePlay" object:nil];
}


+ (void)jumpBackFromIMModule {
    AppDelegate *appDelegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
    if (!appDelegate->_storedViewController) {
    }
    [UIView transitionWithView:[appDelegate window] duration:0.4 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                BOOL oldState = [UIView areAnimationsEnabled];
                [UIView setAnimationsEnabled:NO];
                [[appDelegate window] setRootViewController:appDelegate->_storedViewController];
                [UIView setAnimationsEnabled:oldState];
            }
                    completion:nil];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 200 && buttonIndex == 0) {
        //前往appstore，下载新版本
        NSURL *versionUrl = [NSURL URLWithString:self.versionUrlLink];
        NSLog(@"updateAppUrl:%@", versionUrl);
        if ([[UIApplication sharedApplication] canOpenURL:versionUrl]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.versionUrlLink]];
        }
    }
}

#pragma mark - 收到新消息的时候震动和播放提示音

/**
 *  系统铃声播放完成后的回调
 */
void EMSystemSoundFinishedPlayingCallback(SystemSoundID sound_id, void *user_data) {
    AudioServicesDisposeSystemSoundID(sound_id);
}

// 播放接收到新消息时的声音
- (SystemSoundID)playNewMessageSound {
    // 要播放的音频文件地址
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"in" ofType:@"mp3"];
    NSURL *audioPath = [[NSURL alloc] initFileURLWithPath:bundlePath];
    // 创建系统声音，同时返回一个ID
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef) (audioPath), &soundID);
    // Register the sound completion callback.
    AudioServicesAddSystemSoundCompletion(soundID,
            NULL, // uses the main run loop
            NULL, // uses kCFRunLoopDefaultMode
            EMSystemSoundFinishedPlayingCallback, // the name of our custom callback function
            NULL // for user data, but we don't need to do that in this case, so we just pass NULL
    );

    AudioServicesPlaySystemSound(soundID);

    return soundID;
}

// 震动
- (void)playVibration {
    // Register the sound completion callback.
    AudioServicesAddSystemSoundCompletion(kSystemSoundID_Vibrate,
            NULL, // uses the main run loop
            NULL, // uses kCFRunLoopDefaultMode
            EMSystemSoundFinishedPlayingCallback, // the name of our custom callback function
            NULL // for user data, but we don't need to do that in this case, so we just pass NULL
    );

    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

//两次提示的默认间隔
static const CGFloat kDefaultPlaySoundInterval = 3.0;

- (void)playSoundAndVibration {
    NSTimeInterval timeInterval = [[NSDate date]
            timeIntervalSinceDate:self.lastPlaySoundDate];
    if (timeInterval < kDefaultPlaySoundInterval) {
        //如果距离上次响铃和震动时间太短, 则跳过响铃
        NSLog(@"skip ringing & vibration %@, %@", [NSDate date], self.lastPlaySoundDate);
        return;
    }
    //保存最后一次响铃时间
    self.lastPlaySoundDate = [NSDate date];

    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        if (VAL_ENABLE_GET_NEW_MESSAGE_NOTIFICATION) {
            //收到消息时，播放音频
            if (VAL_ENABLE_MAKE_SOUND) {
                [self playNewMessageSound];
            }
            //收到消息时，震动
            if (VAL_ENABLE_SHOCK) {
                [self playVibration];
            }
        }
    }
}

- (void)reloadRedCount {
    NSArray *conversations = [[CXIMService sharedInstance].chatManager loadConversations];
    // 未读总数
    NSInteger unreadMessagesToatl = 0;
    for (CXIMConversation *conversation in conversations) {
        unreadMessagesToatl += conversation.unreadNumber;
    }
    UIView * view = [[UIView alloc] init];
    NSInteger count = [view countNumBadge:IM_PUSH_DM,IM_PUSH_GT,IM_PUSH_GSXW,IM_PUSH_PUSH_HOLIDAY,IM_PUSH_PROGRESS,IM_PUSH_XIAO,IM_PUSH_QJ,IM_PUSH_ZBKB,IM_PUSH_CLSP,IM_PUSH_NEWSLETTER,nil];//新增报销审批
   
    NSInteger num = [CXPushHelper getMyApprove];
    if (num != 0) {
        count += num;
    }
    
    NSInteger sysUnreadCount = 0;

  
    sysUnreadCount = [self countNumBadge:IM_SystemMessage,nil];//新版的系统消息推送,显示具体的数量,不再显示0或者1

    
    [UIApplication sharedApplication].applicationIconBadgeNumber = count + unreadMessagesToatl + sysUnreadCount;
    [[NSUserDefaults standardUserDefaults] synchronize];
    //[UIApplication sharedApplication].applicationIconBadgeNumber = unreadMessagesToatl;
}


#pragma mark - CXIMServiceDelegate

- (void)CXIMService:(CXIMService *)service didReceiveChatMessage:(CXIMMessage *)message {
    //收到新消息的时候震动和播放提示音
    if (VAL_ImStatus) {
        [self playSoundAndVibration];
        [self reloadRedCount];
        [[NSNotificationCenter defaultCenter] postNotificationName:receiveReloadHomeViewRedViewNotification object:self];
    }
    [self reloadUnReadMessageCount];
}

- (void)CXIMService:(CXIMService *)service didReceiveMediaCallResponse:(NSDictionary *)response {
    NSString *from = response[@"from"];
    CXIMMediaCallType type = (CXIMMediaCallType) [response[@"type"] integerValue];
    CXIMMediaCallStatus status = (CXIMMediaCallStatus) [response[@"status"] integerValue];
    BOOL canPickMedia = [SDPermissionsDetectionUtils checkMediaFree];
    BOOL canRecord = [SDPermissionsDetectionUtils checkCanRecordFree];
    if (status == CXIMMediaCallStatusRequest && type == CXIMMediaCallTypeVideo) {
        if (!canRecord && !canPickMedia) {
            NSString *messageStr = [NSString stringWithFormat:@"%@邀请您视频通话,由于此应用没有语音和视频权限,所以未能接通,您可以在“隐私设置”中开启语音和视频权限", from];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提醒" message:messageStr delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            return;
        } else if (!canRecord) {
            NSString *messageStr = [NSString stringWithFormat:@"%@邀请您视频通话,由于此应用没有语音权限,所以未能接通,您可以在“隐私设置”中开启语音权限", from];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提醒" message:messageStr delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            return;
        } else if (!canPickMedia) {
            NSString *messageStr = [NSString stringWithFormat:@"%@邀请您视频通话,由于此应用没有视频权限,所以未能接通,您可以在“隐私设置”中开启视频权限", from];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提醒" message:messageStr delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            return;
        } else {
            SDIMVoiceAndVideoCallViewController *videoCallController = [[SDIMVoiceAndVideoCallViewController alloc] initWithInitiateOrAcceptCallType:SDIMCallAcceptType];
            videoCallController.audioOrVideoType = type;
            videoCallController.chatter = from;
            CGFloat w = [response[@"screen_width"] ? response[@"screen_width"] : @"320" floatValue];
            CGFloat h = [response[@"screen_height"] ? response[@"screen_height"] : @"480" floatValue];
            NSNumber *receiveCallTime = @([response[@"time"] longLongValue]);
            videoCallController.displaySize = CGSizeMake(w, h);
            videoCallController.receiveCallTime = receiveCallTime;
            NSString *name = [[SDChatManager sharedChatManager] searchUserByHxAccount:from].realName;
            name = [CXIMHelper getRealNameByAccount:from];
            name = name && name.length ? name : from;
            videoCallController.chatterDisplayName = name;
            
            //app不处于超享加的首页
            [[self topViewController] presentViewController:videoCallController animated:YES completion:nil];
            return;
        }
    } else if (status == CXIMMediaCallStatusRequest && type == CXIMMediaCallTypeAudio) {
        if (!canRecord) {
            NSString *messageStr = [NSString stringWithFormat:@"%@邀请您语音通话,由于此应用没有语音权限,所以未能接通,您可以在“隐私设置”中开启语音权限", from];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提醒" message:messageStr delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            return;
        } else {
            SDIMVoiceAndVideoCallViewController *videoCallController = [[SDIMVoiceAndVideoCallViewController alloc] initWithInitiateOrAcceptCallType:SDIMCallAcceptType];
            videoCallController.audioOrVideoType = type;
            
            videoCallController.chatter = from;
            NSString *name = [[SDChatManager sharedChatManager] searchUserByHxAccount:from].realName;
            name = [CXIMHelper getRealNameByAccount:from];
            name = name && name.length ? name : from;
            videoCallController.chatterDisplayName = name;
            CGFloat w = [response[@"screen_width"] ? response[@"screen_width"] : @"320" floatValue];
            CGFloat h = [response[@"screen_height"] ? response[@"screen_height"] : @"480" floatValue];
            NSNumber *receiveCallTime = @([response[@"time"] longLongValue]);
            videoCallController.displaySize = CGSizeMake(w, h);
            videoCallController.receiveCallTime = receiveCallTime;
            
            //app不处于超享加的首页
            [[self topViewController] presentViewController:videoCallController animated:YES completion:nil];
            
            return;
        }
    }
    
    [self reloadUnReadMessageCount];
}

- (UIViewController *)topViewController {
    UIViewController *resultVC;
    resultVC = [self _topViewController:self.window.rootViewController];
    while (resultVC.presentedViewController) {
        resultVC = [self _topViewController:resultVC.presentedViewController];
    }
    return resultVC;
}

- (UIViewController *)_topViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self _topViewController:[(UINavigationController *)vc topViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self _topViewController:[(UITabBarController *)vc selectedViewController]];
    } else {
        return vc;
    }
    return nil;
}

-(void)CXIMService:(CXIMService *)service didSendMessageSuccess:(CXIMMessage *)message
{
    [self reloadUnReadMessageCount];
}

-(void)CXIMService:(CXIMService *)service didReceiveMediaCallMessage:(CXIMMessage *)message
{
    [self reloadUnReadMessageCount];
}

-(void)CXIMService:(CXIMService *)service didSelfExitGroupWithGroupId:(NSString *)groupId time:(NSNumber *)time
{
    [self reloadUnReadMessageCount];
}

-(void)CXIMService:(CXIMService *)service didSelfDismissGroupWithGroupId:(NSString *)groupId dismissTime:(NSNumber *)dismissTime
{
    [self reloadUnReadMessageCount];
}

- (void)CXIMService:(CXIMService *)service didAddedIntoGroup:(NSString *)groupName groupId:(NSString *)groupId inviter:(NSString *)inviter time:(NSNumber *)time
{
    [self reloadUnReadMessageCount];
}

- (void)CXIMService:(CXIMService *)service didMembers:(NSArray<NSString *> *)members removedFromGroup:(NSString *)groupName groupId:(NSString *)groupId byOwner:(NSString *)owner time:(NSNumber *)time
{
    [self reloadUnReadMessageCount];
}

- (void)CXIMService:(CXIMService *)service didRemovedFromGroup:(NSString *)groupName groupId:(NSString *)groupId time:(NSNumber *)time
{
    [self reloadUnReadMessageCount];
}

- (void)CXIMService:(CXIMService *)service didChangedGroupName:(NSString *)groupName groupId:(NSString *)groupId byOwner:(NSString *)owner time:(NSNumber *)time
{
    [self reloadUnReadMessageCount];
}

- (void)CXIMService:(CXIMService *)service didSelfInviteMembers:(NSArray<NSString *> *)members intoGroup:(NSString *)groupName groupId:(NSString *)groupId time:(NSNumber *)time
{
    [self reloadUnReadMessageCount];
}

- (void)CXIMService:(CXIMService *)service didSomeone:(NSString *)inviter inviteMembers:(NSArray<NSString *> *)members intoGroup:(NSString *)groupName groupId:(NSString *)groupId time:(NSNumber *)time
{
    [self reloadUnReadMessageCount];
}

#pragma mark - 远程通知

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    [self imApplication:application didRegisterUserNotificationSettings:notificationSettings];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [self imApplication:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [self imApplication:application didFailToRegisterForRemoteNotificationsWithError:error];
    //极光
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);

}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"收到远程通知：%@,内容是:%@", userInfo,userInfo[@"aps"][@"alert"]);
    //收不到通知公告,这里再重新补发一次
    [[NSNotificationCenter defaultCenter] postNotificationName:kReceivePushNotificationKey object:nil userInfo:nil];
}

- (void)reloadUnReadMessageCount{
    NSArray* arr = [[CXIMService sharedInstance].chatManager loadConversations];
    NSMutableArray * allConversationsArray = [[NSMutableArray alloc] initWithCapacity:0];
    for(CXIMConversation * conversation in arr){
        if(!conversation.isVoiceConference){
            [allConversationsArray addObject:conversation];
        }
    }
    NSInteger unread = 0;
    for (CXIMConversation * conversation in allConversationsArray) {
        unread += conversation.unreadNumber;
    }
    //I_ChatCount
    NSInteger I_ChatCount = [self countNumBadge:IM_PUSH_GT,IM_PUSH_ZBKB,IM_PUSH_GSXW,IM_PUSH_NEWSLETTER/*,CX_NK_Push*/,nil];//新增报销推送
    unread += I_ChatCount;
    NSInteger sysUnreadCount = 0;

    sysUnreadCount = [self countNumBadge:IM_SystemMessage,nil];//新版的系统消息推送,显示具体的数量,不再显示0或者1

    unread = unread + sysUnreadCount;
    NSString * bage = unread > 0 ? @(unread).stringValue : nil;
    RDVTabBarController *vc = [AppDelegate get_RDVTabBarController];
    [vc.tabBar.items[1] setBadgeValue:bage];
}

- (void)reLogin {
    [self.locateTimer invalidate];
    self.locateTimer = nil;
    
    [[CXIMService sharedInstance] logout];
    // 定位到企信
    RDVTabBarController *tabBarVC = [(AppDelegate *) [UIApplication sharedApplication].delegate getRDVTabBarController];
    tabBarVC.selectedIndex = 0;
    //隐藏状态栏
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    // 关闭socket
    [[SDWebSocketManager shareWebSocketManager] closeSocket];
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@NO];
}

#define kGetZBKBBadgeNumberTime 3*60

- (NSTimer *)locateTimer {
    if (_locateTimer == nil) {
        _locateTimer = [NSTimer scheduledTimerWithTimeInterval:kGetZBKBBadgeNumberTime target:self selector:@selector(addZBKBBadgeNumber) userInfo:nil repeats:YES];
        _locateTimer.fireDate = [NSDate distantFuture];
    }
    return _locateTimer;
}

- (void)addZBKBBadgeNumber{
    NSString * LastFiveIdsString = [NSString stringWithFormat:@"LastFiveIdsString_%@",VAL_HXACCOUNT];
    NSString * ids = [[NSUserDefaults standardUserDefaults] objectForKey:LastFiveIdsString];
    if(ids && [ids isKindOfClass:[NSString class]] && [ids length] > 0){
        NSString *url = [NSString stringWithFormat:@"%@wx/bulletin/new/count", urlPrefix];
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setValue:ids forKey:@"ids"];
        [HttpTool postWithPath:url params:params success:^(NSDictionary *JSON) {
            if ([JSON[@"status"] intValue] == 200) {
                VAL_PUSHES_HAVEREAD_NEW(IM_PUSH_ZBKB);
                if([JSON[@"data"] integerValue] > 0){
                    NSString * timeStamp = [NSString stringWithFormat:@"%ld",[self timeSwitchTimestamp:JSON[@"otherData"]]];
                    NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
                    [ud setObject:timeStamp forKey:@"IM_PUSH_ZBKB_Time"];
                    [ud synchronize];
                    
                    NSDictionary * textMsg = @{@"资本快报推送":@"资本快报推送"};
                    NSMutableDictionary *pushes = [VAL_PUSHES mutableCopy];
                    if (!pushes) {
                        pushes = [NSMutableDictionary dictionary];
                        VAL_PUSHES_RESET(pushes);
                    }
                    NSMutableArray *textMsgs;
                    textMsgs = [VAL_PUSHES_MSGS(IM_PUSH_ZBKB) mutableCopy];
                    if (!textMsgs) {
                        textMsgs = [NSMutableArray array];
                    }
                    for(NSInteger i = 0; i < [JSON[@"data"] integerValue]; i++){
                        [textMsgs addObject:textMsg];
                    }
                    pushes[IM_PUSH_ZBKB] = textMsgs;
                    VAL_PUSHES_RESET(pushes);
                    [[NSNotificationCenter defaultCenter] postNotificationName:kReceivePushNotificationKey object:nil userInfo:@{kPushTypeKey : IM_PUSH_ZBKB, kPushMsgKey : textMsg}];
                }
                RDVTabBarController* vc = [AppDelegate get_RDVTabBarController];
                //工作台模块显示红点
                NSInteger count = [self countNumBadge:IM_PUSH_DM,IM_PUSH_PUSH_HOLIDAY,IM_PUSH_PROGRESS,IM_PUSH_QJ,IM_PUSH_XIAO,IM_PUSH_BS,IM_PUSH_CLSP,nil];//新增报销审批
                
                NSInteger num = [CXPushHelper getMyApprove];//这里点击我的审批再返回后有变化
                if (num != 0) {
                    count += num;
                }
                
                [vc setReadOrUnRead:count andTypeNum:0];
                //I-Chat模块显示红点
                NSArray *conversations = [[CXIMService sharedInstance].chatManager loadConversations];
                // 未读总数
                NSInteger unreadMessagesToatl = 0;
                for (CXIMConversation *conversation in conversations) {
                    unreadMessagesToatl += conversation.unreadNumber;
                }
                NSInteger I_ChatCount = [self countNumBadge:IM_PUSH_GT,IM_PUSH_ZBKB,IM_PUSH_GSXW,IM_PUSH_NEWSLETTER,nil];//新增报销推送
                NSInteger sysUnreadCount = 0;

                sysUnreadCount = [self countNumBadge:IM_SystemMessage,nil];//新版的系统消息推送,显示具体的数量,不再显示0或者1

                [vc setReadOrUnRead:I_ChatCount + unreadMessagesToatl + sysUnreadCount andTypeNum:1];
            } else {
            }
        }failure:^(NSError *error) {
        }];
    }else{
        NSMutableDictionary * psh = [VAL_PUSHES mutableCopy];
        [psh removeObjectForKey:IM_PUSH_ZBKB];
        VAL_PUSHES_RESET(psh);
        RDVTabBarController* vc = [AppDelegate get_RDVTabBarController];
        //工作模块显示红点
        NSInteger count = [self countNumBadge:IM_PUSH_DM,IM_PUSH_PUSH_HOLIDAY,IM_PUSH_PROGRESS,IM_PUSH_QJ,IM_PUSH_XIAO,IM_PUSH_BS,IM_PUSH_CLSP,nil];//新增报销审批
        
        NSInteger num = [CXPushHelper getMyApprove];
        if (num != 0) {
            count += num;
        }
        
        [vc setReadOrUnRead:count andTypeNum:0];
        //I-Chat模块显示红点
        NSArray *conversations = [[CXIMService sharedInstance].chatManager loadConversations];
        // 未读总数
        NSInteger unreadMessagesToatl = 0;
        for (CXIMConversation *conversation in conversations) {
            unreadMessagesToatl += conversation.unreadNumber;
        }
        NSInteger I_ChatCount = [self countNumBadge:IM_PUSH_GT,IM_PUSH_ZBKB,IM_PUSH_GSXW,IM_PUSH_NEWSLETTER,nil];//新增报销推送
        NSInteger sysUnreadCount = 0;

        sysUnreadCount = [self countNumBadge:IM_SystemMessage,nil];//新版的系统消息推送,显示具体的数量,不再显示0或者1

        [vc setReadOrUnRead:I_ChatCount + unreadMessagesToatl + sysUnreadCount andTypeNum:1];
    }
}

#pragma mark - 将某个时间转化成 时间戳
- (NSInteger)timeSwitchTimestamp:(NSString *)formatTime{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [NSLocale localeWithLocaleIdentifier:@"zh_CN"];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    [formatter setTimeZone:timeZone];
    //------------将字符串按formatter转成nsdate
    NSDate* date = [formatter dateFromString:formatTime];
    //时间转时间戳的方法:
    NSInteger timeSp = [[NSNumber numberWithDouble:([date timeIntervalSince1970] * 1000)] integerValue];
    NSLog(@"将某个时间转化成 时间戳&&&&&&&timeSp:%ld",(long)timeSp); //时间戳的值
    return timeSp;
}

- (NSInteger)countNumBadge:(NSString *)firstType, ... {
    va_list types;
    id type;
    NSInteger msgCount = 0;
    if (firstType) {
        if ([VAL_PUSHES_MSGS(firstType) count] > 0) {
            msgCount = [VAL_PUSHES_MSGS(firstType) count];
        }
        va_start(types, firstType);
        while ((type = va_arg(types, id))) {
            if ([VAL_PUSHES_MSGS(type) count] > 0) {
                msgCount += [VAL_PUSHES_MSGS(type) count];
            }
        }
        va_end(types);
    }
    return msgCount;
}

//获取当前时间戳
- (NSString *)currentTimeStr{
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];//获取当前时间0秒后的时间
    NSTimeInterval time=[date timeIntervalSince1970]*1000;// *1000 是精确到毫秒，不乘就是精确到秒
    NSString *timeString = [NSString stringWithFormat:@"%.0f", time];
    return timeString;
}

- (void)receivePushNotification:(NSNotification *)noti {
    RDVTabBarController* vc = [AppDelegate get_RDVTabBarController];
    UIView * view = [[UIView alloc] init];
    //工作模块显示红点
    NSInteger count = [view countNumBadge:IM_PUSH_DM,IM_PUSH_PUSH_HOLIDAY,IM_PUSH_PROGRESS,IM_PUSH_QJ,IM_PUSH_XIAO,IM_PUSH_BS,IM_PUSH_CLSP,nil];//新增报销审批
    
    NSInteger num = [CXPushHelper getMyApprove];
    if (num != 0) {
        count += num;
    }
    
    [vc setReadOrUnRead:count andTypeNum:0];
 
    //I-Chat模块显示红点
    NSArray *conversations = [[CXIMService sharedInstance].chatManager loadConversations];
    // 未读总数
    NSInteger unreadMessagesToatl = 0;
    for (CXIMConversation *conversation in conversations) {
        unreadMessagesToatl += conversation.unreadNumber;
    }
    
    NSInteger I_ChatCount = [view countNumBadge:IM_PUSH_GT,IM_PUSH_ZBKB,IM_PUSH_GSXW,IM_PUSH_NEWSLETTER,nil];
    NSInteger sysUnreadCount = 0;

    sysUnreadCount = [view countNumBadge:IM_SystemMessage,nil];//新版的系统消息推送,显示具体的数量,不再显示0或者1

    [vc setReadOrUnRead:I_ChatCount + unreadMessagesToatl + sysUnreadCount  andTypeNum:1];
}


@end
