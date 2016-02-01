 //
//  AppDelegate.m
//  muzzik
//
//  Created by 林清泽 on 15/3/7.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "WXApi.h"
#import "WeiboSDK.h"
#import "AppDelegate.h"
#import "appConfiguration.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import "ASIHTTPRequest.h"
#import "userInfo.h"
#import "settingSystemVC.h"
#import "UIImageView+WebCache.m"
#import "NotificationCenterViewController.h"
#import "FeedViewController.h"
#import "UserHomePage.h"
#import "TopicVC.h"
#import "DetaiMuzzikVC.h"
#import "RDVTabBarItem.h"
#import "LoginViewController.h"
#import "Utils_IM.h"
#import "IMConversationViewcontroller.h"
#import "IMShareMessage.h"
#import "IMDeviceContent.h"
#import "IMListenMessage.h"
#import "IMEnterMessage.h"
#import "IMCancelListenMessage.h"
#import "IMSynMusicMessage.h"
#import "userDetailInfo.h"
#import "IMMessageDispatcher.h"

#define size_to_change  3



@interface AppDelegate ()<UIApplicationDelegate,WeiboSDKDelegate,WXApiDelegate,RDVTabBarControllerDelegate,RCIMClientReceiveMessageDelegate,GeTuiSdkDelegate,RCConnectionStatusChangeDelegate>{
    BOOL isLaunched;
    UIViewController *itemVC;
    BOOL needsReplay;
    dispatch_queue_t _serialQueue;
    BOOL DontShowNotification;
    BOOL diffDate;
    NSTimer *timer;
    NSInteger timeCount;
    UIAlertView *starAlert;
    
    UIImageView *coverImageView;

    UIView *addView;
    UIImageView *startLogo;
}

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAudioSessionEvent:) name:AVAudioSessionInterruptionNotification object:nil];
    isLaunched = YES;
    userInfo *user = [userInfo shareClass];
    _serialQueue = dispatch_queue_create("IMserialQueue", DISPATCH_QUEUE_SERIAL);
    [WXApi registerApp:ID_WeiChat_APP];
    [WeiboSDK enableDebugMode:NO];
    [WeiboSDK registerApp:Key_WeiBo];
    [GeTuiSdk startSdkWithAppId:kAppId appKey:kAppKey appSecret:kAppSecret delegate:self];
    [MobClick startWithAppkey:UMAPPKEY reportPolicy:BATCH channelId:@"App Store"];
//    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
//    [MobClick setAppVersion:version];
    
    
    NSDictionary * dic = [MuzzikItem messageFromLocal];
    if (dic) {
       
        user.uid = [dic objectForKey:@"_id"];
        user.rootId = [dic objectForKey:@"_id"];
        user.token = [dic objectForKey:@"token"];
        user.gender = [dic objectForKey:@"gender"];
        user.avatar = [dic objectForKey:@"avatar"];
        user.name = [dic objectForKey:@"name"];
        if ([user.uid length]>0) {
            NSArray *focusUser = [MuzzikItem getArrayFromLocalForKey:[NSString stringWithFormat:@"%@_focusUser",user.uid]];
            if (focusUser.count >0) {
                user.focusArray = [focusUser mutableCopy];
            }else{
                user.focusArray = [NSMutableArray array];
            }
        }
        
        if ([user.token length]>0) {
            [self registerRongClound];
        }
    }
    if ([user.token length]==0) {
        user.loginType = Is_Not_Logined;
    }else{
        user.loginType = Is_Logined;
    }
    
    [self loadData];
    
    [self registerRemoteNotification];
    [self checkChannel];
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    user.hasTeachToFollow = [[MuzzikItem getStringForKey:@"User_first_Listen_song"] boolValue];
     [self requestForActivity];

    
    
    
    
    
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [ASIHTTPRequest clearSession];
    self.window.backgroundColor = [UIColor blackColor];
    [self.window makeKeyAndVisible];
    //[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];
    if (![[MuzzikItem getStringForKey:@"Muzzik_Create_Album"] isEqualToString:@"yes"]) {
        [self createAlbum];
    }
    [self QueryAllMusic];
    FeedViewController *feedVC = [[FeedViewController alloc] init];
    self.feedVC = [[UINavigationController alloc] initWithRootViewController:feedVC];
    
    TopicVC *topicVC = [[TopicVC alloc] init];
    self.topicVC = [[UINavigationController alloc] initWithRootViewController:topicVC];
    
    NotificationCenterViewController *notifyVC = [[NotificationCenterViewController alloc] init];
    
    
    self.notifyVC = [[UINavigationController alloc] initWithRootViewController:notifyVC];
    UserHomePage *userhomeVC = [[UserHomePage alloc] init];
    self.userhomeVC = [[UINavigationController alloc] initWithRootViewController:userhomeVC];
    itemVC = [[UIViewController alloc] init];
    RDVTabBarController *tabBarController = [[RDVTabBarController alloc] init];
    [tabBarController setViewControllers:@[self.feedVC, self.topicVC,itemVC,
                                           self.notifyVC,self.userhomeVC]];
    tabBarController.delegate = self;
    self.tabviewController = tabBarController;
    //[self.tabviewController.tabBar setBackgroundImage:[MuzzikItem createImageWithColor:[UIColor clearColor]]];
    //[self.tabviewController.tabBar setShadowImage:[MuzzikItem createImageWithColor:[UIColor clearColor]]];
    
    self.tabviewController.tabBar.translucent = YES;
    self.IMconnectionStatus = ConnectionStatus_Unconnected;
    
    RCIMClient *client = [RCIMClient sharedRCIMClient];
    [[RCIMClient sharedRCIMClient] initWithAppKey:AppKey_RongClound];
    [client setReceiveMessageDelegate:self object:nil];
    
    [self customizeTabBarForController:tabBarController];
    [self.window setRootViewController:self.tabviewController];
    [[SDImageCache sharedImageCache] cleanDisk];
    NSDate *  senddate=[NSDate date];
    
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    
    [dateformatter setDateFormat:@"YYYYMMdd"];
    
    NSString *locationString=[dateformatter stringFromDate:senddate];
    NSString *lastShowDateString = [MuzzikItem getStringForKey:@"Muzzik_lastShowDateString"];
    if ([lastShowDateString length] == 0) {
        [MuzzikItem addObjectToLocal:lastShowDateString ForKey:@"Muzzik_lastShowDateString"];
    }
    NSArray *activityArray = [MuzzikItem getArrayFromLocalForKey:@"Muzzik_activity_localData"];
    BOOL showed = NO;
    if ([activityArray count] >0) {
        for (NSDictionary *tempDic in activityArray) {
            NSString *from  = [self transformDateToString:[tempDic objectForKey:@"from"]];
            NSString *to    = [self transformDateToString:[tempDic objectForKey:@"to"]];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
            NSString *now   = [formatter stringFromDate:[NSDate date]];
            NSLog(@"%ld   %ld",(long)[now compare:from],(long)[now compare:to]);
            if ([now compare:from]>=0  && [now compare:to]<=0) {
                
                NSData *image = [MuzzikItem getDataFromLocalKey:[tempDic objectForKey:@"image"]];
                NSData *textImageEX = [MuzzikItem getDataFromLocalKey:[tempDic objectForKey:@"textImageEX"]];
                showed = YES;
                [self addCoverVCToWindowFullImage:[UIImage imageWithData: image] slogan:[UIImage imageWithData: textImageEX]];
                break;
                
            }
        }
    }
    if (!showed) {
        [self addCoverVCToWindowFullImage:nil slogan:nil];
    }
    
    
    
    
    NSLog(@"locationString:%@",locationString);
    NSDictionary *starDic = [MuzzikItem getDictionaryFromLocalForKey:@"Muzzik_Check_Comment_Five_star"];
    if (starDic == nil) {
        starDic = [NSDictionary dictionaryWithObjectsAndKeys:@"0",@"times",locationString,@"date",@"no",@"hasClicked", nil];
        [MuzzikItem addObjectToLocal:dic ForKey:@"Muzzik_Check_Comment_Five_star"];
    }
    else if(![[starDic objectForKey:@"hasClicked"] isEqualToString:@"yes"]){
        
        if (![[starDic objectForKey:@"date"] isEqualToString:locationString]) {
            NSString *tempString = [starDic objectForKey:@"times"];
            tempString = [NSString stringWithFormat:@"%d",[tempString intValue]+1];
            if ([tempString intValue]==2) {
                [MuzzikItem addObjectToLocal:[NSDictionary dictionaryWithObjectsAndKeys:@"0",@"times",locationString,@"date",@"no",@"hasClicked", nil] ForKey:@"Muzzik_Check_Comment_Five_star"];
                timeCount = 120;
                timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
                [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
            }else{
                [MuzzikItem addObjectToLocal:[NSDictionary dictionaryWithObjectsAndKeys:tempString,@"times",locationString,@"date",@"no",@"hasClicked", nil] ForKey:@"Muzzik_Check_Comment_Five_star"];
            }
        }
    }
    
    NSDictionary* message = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (message) {
       // [MuzzikItem addObjectToLocal:message ForKey:@"launch_APP"];
        NSString *payloadMsg = [message objectForKey:@"payload"];
        NSRange range = [payloadMsg rangeOfString:@"muzzik_id"];
        if ([payloadMsg length]>0 && range.location != NSNotFound) {
            DetaiMuzzikVC *detailvc = [[DetaiMuzzikVC alloc] init];
            
            detailvc.muzzik_id = [payloadMsg substringWithRange:NSMakeRange(range.length, payloadMsg.length-range.length)];
            [self.feedVC pushViewController:detailvc animated:YES];
        }
        else{
            self.tabviewController.selectedViewController = self.notifyVC;
            self.tabviewController.selectedIndex = 3;
        }

        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    }
    RCUserInfo *userInfo = [[RCUserInfo alloc] initWithUserId:user.uid name:user.name portrait:user.avatar];
    [[RCIMClient sharedRCIMClient] setCurrentUserInfo:userInfo];
    [[RCIMClient sharedRCIMClient] registerMessageType:[IMShareMessage class]];
    [[RCIMClient sharedRCIMClient] registerMessageType:[IMEnterMessage class]];
    [[RCIMClient sharedRCIMClient] registerMessageType:[IMDeviceContent class]];
    [[RCIMClient sharedRCIMClient] registerMessageType:[IMListenMessage class]];
    [[RCIMClient sharedRCIMClient] registerMessageType:[IMSynMusicMessage class]];
    [[RCIMClient sharedRCIMClient] registerMessageType:[IMCancelListenMessage class]];
    [[RCIMClient sharedRCIMClient] setRCConnectionStatusChangeDelegate:self];
    
    [[RCIMClient sharedRCIMClient] recordLaunchOptionsEvent:launchOptions];
    
    /**
     * 获取融云推送服务扩展字段1
     */
    NSDictionary *pushServiceData = [[RCIMClient sharedRCIMClient] getPushExtraFromLaunchOptions:launchOptions];
    if (pushServiceData) {
        NSLog(@"该启动事件包含来自融云的推送服务");
        for (id key in [pushServiceData allKeys]) {
            NSLog(@"%@", pushServiceData[key]);
        }
    } else {
        NSLog(@"该启动事件不包含来自融云的推送服务");
    }
    //[self configureUmengNotificationWithOptions:launchOptions];
    return YES;
}

- (void)registerRemoteNotification
{
    
#ifdef __IPHONE_8_0
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        
        UIUserNotificationSettings *uns = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound) categories:nil];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        [[UIApplication sharedApplication] registerUserNotificationSettings:uns];
    } else {
        UIRemoteNotificationType apn_type = (UIRemoteNotificationType)(UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeBadge);
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:apn_type];
    }
#else
    UIRemoteNotificationType apn_type = (UIRemoteNotificationType)(UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeBadge);
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:apn_type];
#endif
}

-(void)requestForActivity{
    ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/common/splash?platform=ios",BaseURL]]];
    [requestForm addBodyDataSourceWithJsonByDic:nil Method:GetMethod auth:NO];
    __weak ASIHTTPRequest *weakrequest = requestForm;
    [requestForm setCompletionBlock :^{
        if ([weakrequest responseStatusCode] == 200) {
            NSDictionary *Webdic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData] options:NSJSONReadingMutableContainers error:nil];
            NSArray *activityArray = [MuzzikItem getArrayFromLocalForKey:@"Muzzik_activity_localData"];
            
            if ([[Webdic objectForKey:@"splashes"] count] >0) {
                BOOL difActivity = NO;
                if ([[Webdic objectForKey:@"splashes"] count] == [activityArray count]) {
                    
                    for (NSInteger i = 0; i<[[Webdic objectForKey:@"splashes"] count]; i++) {
                        if ([[activityArray[i] objectForKey:@"image"] isEqualToString:[[[Webdic objectForKey:@"splashes"] objectAtIndex:i]objectForKey:@"image"]] && [[activityArray[i] objectForKey:@"textImageEX"] isEqualToString:[[[Webdic objectForKey:@"splashes"] objectAtIndex:i]objectForKey:@"textImageEX"]] && [[activityArray[i] objectForKey:@"from"] isEqualToString:[[[Webdic objectForKey:@"splashes"] objectAtIndex:i]objectForKey:@"from"]] && [[activityArray[i] objectForKey:@"to"] isEqualToString:[[[Webdic objectForKey:@"splashes"] objectAtIndex:i]objectForKey:@"to"]]) {
                            
                        }else{
                            difActivity = YES;
                            [MuzzikItem addObjectToLocal:nil ForKey:[activityArray[i] objectForKey:@"image"]];
                            [MuzzikItem addObjectToLocal:nil ForKey:[activityArray[i] objectForKey:@"textImageEX"]];
                            ASIHTTPRequest *requestImage = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL_image,[[[Webdic objectForKey:@"splashes"] objectAtIndex:i] objectForKey:@"image"]]]];
                            __weak ASIHTTPRequest *weakrequestImage = requestImage;
                            [requestImage setCompletionBlock:^{
                                NSData *imageData = [weakrequestImage responseData];
                                [MuzzikItem addObjectToLocal:imageData ForKey:[[[Webdic objectForKey:@"splashes"] objectAtIndex:i] objectForKey:@"image"]];
                            }];
                            [requestImage setFailedBlock:^{
                                NSLog(@"%@",[weakrequestImage error]);
                            }];
                            [requestImage startSynchronous];
                            ASIHTTPRequest *requesttextImageEX = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL_image,[[[Webdic objectForKey:@"splashes"] objectAtIndex:i] objectForKey:@"textImageEX"]]]];
                            __weak ASIHTTPRequest *weakrequesttextImageEX = requesttextImageEX;
                            [requesttextImageEX setCompletionBlock:^{
                                NSData *imageData = [weakrequesttextImageEX responseData];
                                [MuzzikItem addObjectToLocal:imageData ForKey:[[[Webdic objectForKey:@"splashes"] objectAtIndex:i] objectForKey:@"textImageEX"]];
                            }];
                            [requesttextImageEX setFailedBlock:^{
                                NSLog(@"%@",[weakrequesttextImageEX error]);
                            }];
                            [requesttextImageEX startSynchronous];
                        }
                    }
                    if (difActivity) {
                        [MuzzikItem addObjectToLocal:[Webdic objectForKey:@"splashes"] ForKey:@"Muzzik_activity_localData"];
                    }
                }else{
                    [MuzzikItem addObjectToLocal:[Webdic objectForKey:@"splashes"] ForKey:@"Muzzik_activity_localData"];
                    for (NSDictionary *tempDic in activityArray) {
                        [MuzzikItem addObjectToLocal:nil ForKey:[tempDic objectForKey:@"image"]];
                        [MuzzikItem addObjectToLocal:nil ForKey:[tempDic objectForKey:@"textImageEX"]];
                    }
                    [MuzzikItem addObjectToLocal:[Webdic objectForKey:@"splashes"] ForKey:@"Muzzik_activity_localData"];
                    for (NSDictionary *tempDic in [Webdic objectForKey:@"splashes"]) {
                        ASIHTTPRequest *requestImage = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL_image,[tempDic objectForKey:@"image"]]]];
                        __weak ASIHTTPRequest *weakrequestImage = requestImage;
                        [requestImage setCompletionBlock:^{
                            NSData *imageData = [weakrequestImage responseData];
                            [MuzzikItem addObjectToLocal:imageData ForKey:[tempDic objectForKey:@"image"]];
                        }];
                        [requestImage setFailedBlock:^{
                            NSLog(@"%@",[weakrequestImage error]);
                        }];
                        [requestImage startSynchronous];
                        ASIHTTPRequest *requesttextImageEX = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL_image,[tempDic objectForKey:@"textImageEX"]]]];
                        __weak ASIHTTPRequest *weakrequesttextImageEX = requesttextImageEX;
                        [requesttextImageEX setCompletionBlock:^{
                            NSData *imageData = [weakrequesttextImageEX responseData];
                            [MuzzikItem addObjectToLocal:imageData ForKey:[tempDic objectForKey:@"textImageEX"]];
                        }];
                        [requesttextImageEX setFailedBlock:^{
                            NSLog(@"%@",[weakrequesttextImageEX error]);
                        }];
                        [requesttextImageEX startSynchronous];
                    }
                }
               
            }else{
                [MuzzikItem addObjectToLocal:[Webdic objectForKey:@"splashes"] ForKey:@"Muzzik_activity_localData"];
                for (NSDictionary *tempDic in activityArray) {
                    [MuzzikItem addObjectToLocal:nil ForKey:[tempDic objectForKey:@"image"]];
                    [MuzzikItem addObjectToLocal:nil ForKey:[tempDic objectForKey:@"textImageEX"]];
                }
            }
            
            
        }
        else{
            //[SVProgressHUD showErrorWithStatus:[dic objectForKey:@"message"]];
        }
    }];
    [requestForm setFailedBlock:^{
        NSLog(@"%@",[weakrequest error]);
    }];
    [requestForm startSynchronous];
}
- (void)customizeTabBarForController:(RDVTabBarController *)tabBarController {
    UIImage *finishedImage = [MuzzikItem createImageWithColor:Color_Active_Button_1];
    UIImage *unfinishedImage = [MuzzikItem createImageWithColor:[UIColor clearColor]];
    NSArray *tabBarItemImages = @[@"tabbarMuzzik", @"tabbarHot", @"third",@"tabbarNotification",@"tabbarUserCenter"];
    
    NSInteger index = 0;
    for (RDVTabBarItem *item in [[tabBarController tabBar] items]) {
        if (index!=2) {
             [item setBackgroundSelectedImage:finishedImage withUnselectedImage:unfinishedImage];
        }
        UIImage *selectedimage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_Selected",
                                                      [tabBarItemImages objectAtIndex:index]]];
        UIImage *unselectedimage = [UIImage imageNamed:[tabBarItemImages objectAtIndex:index]];
        [item setFinishedSelectedImage:selectedimage withFinishedUnselectedImage:unselectedimage];
        
        index++;
    }
    
}
-(NSString *)transformDateToString:(NSString *) time{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    NSDate *localDate = [dateFormatter dateFromString:time];
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];//或GMT
    //设置转换后的目标日期时区
    NSTimeZone* destinationTimeZone = [NSTimeZone localTimeZone];
    //得到源日期与世界标准时间的偏移量
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:localDate];
    //目标日期与本地时区的偏移量
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:localDate];
    //得到时间偏移量的差值
    NSTimeInterval Tinterval = sourceGMTOffset- destinationGMTOffset;
    //转为现在时间
    NSDate* destinationDateNow = [[NSDate alloc] initWithTimeInterval:Tinterval sinceDate:localDate];
    
    //    NSString* timeStr = @"2011-01-26 17:40:50";
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"MM-dd HH:mm"];
    return [formatter stringFromDate:destinationDateNow];
    
}

#pragma -mark 个推后台推送，消息处理
//-(void)GexinSdkDidReceivePayload:(NSString *)payloadId fromApplication:(NSString *)appId{
//    _payloadId =payloadId;
//    NSData *data = [_gexinPusher retrivePayloadById:payloadId];
//    NSString *payloadMsg = nil;
////    if (data) {
////        UINavigationController *nac = (UINavigationController *)self.window.rootViewController;
////        for (UIViewController *vc in nac.viewControllers) {
////            if ([vc isKindOfClass:[RootViewController class]]){
////                RootViewController *root = (RootViewController *)vc;
////                [root getMessage];
////                
////            }
////    }
////        payloadMsg = [[NSString alloc] initWithBytes:data.bytes
////                                              length:data.length
////                                            encoding:NSUTF8StringEncoding];
////    NSLog(@"payload:%@",[payloadMsg stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
////    }
//}



- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void) motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event

{
    NSString * shakeSwitch = [MuzzikItem getStringForKey:@"User_shakeActionSwitch"];
    if (![shakeSwitch isEqualToString:@"close"]) {
        MuzzikPlayer *player = [MuzzikPlayer shareClass];
        //摇动结束
        if (event.subtype == UIEventSubtypeMotionShake && [player.MusicArray count]>0) {
            [player playNext];
        }
    }
    
    
}
//响应远程音乐播放控制消息
- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent {
    
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        MuzzikPlayer * player = [MuzzikPlayer shareClass];
        NSLog(@"");
        switch (receivedEvent.subtype) {
                
            case UIEventSubtypeRemoteControlPause:
                [player playnow];
                NSLog(@"RemoteControlEvents: pause");
                break;
            case UIEventSubtypeRemoteControlTogglePlayPause:
                [player playnow];
                NSLog(@"RemoteControlEvents: pause");
                break;
            case UIEventSubtypeRemoteControlPlay:
                [player playnow];
                NSLog(@"RemoteControlEvents: play");
                [[NSNotificationCenter defaultCenter] postNotificationName:String_SetSongInformationNotification object:nil userInfo:nil];
                break;
            case UIEventSubtypeRemoteControlNextTrack:
                [player playNext];
                NSLog(@"RemoteControlEvents: playModeNext");
                break;
            case UIEventSubtypeRemoteControlPreviousTrack:
                [player playPre];
                NSLog(@"RemoteControlEvents: playPrev");
                break;
            default:
                break;
        }
    }
}
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
#if __QQAPI_ENABLE__
    [QQApiInterface handleOpenURL:url delegate:(id)[QQAPIDemoEntry class]];
#endif
    if ([WeiboSDK handleOpenURL:url delegate:self]) {
        return [WeiboSDK handleOpenURL:url delegate:self];
    }else if([TencentOAuth HandleOpenURL:url]){
         return [TencentOAuth HandleOpenURL:url];
    }
    else if( [WXApi handleOpenURL:url delegate:self])
    {
        return  [WXApi handleOpenURL:url delegate:self];
    }
    return [WeiboSDK handleOpenURL:url delegate:self];
}
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    if ([WeiboSDK handleOpenURL:url delegate:self]) {
        return [WeiboSDK handleOpenURL:url delegate:self];
    }else if([TencentOAuth HandleOpenURL:url]){
        return [TencentOAuth HandleOpenURL:url];
    }
    else if( [WXApi handleOpenURL:url delegate:self])
    {
        return  [WXApi handleOpenURL:url delegate:self];
    }

    return [WeiboSDK handleOpenURL:url delegate:self];
}




-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfoDic fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    userInfo *user = [userInfo shareClass];
    NSArray *a = [userInfoDic allKeys];
    NSLog(@"%@",a);
    if ([[userInfoDic allKeys] containsObject:@"rc"]) {
        self.tabviewController.selectedViewController = self.notifyVC;
        self.tabviewController.selectedIndex = 3;
        [self.notifyVC popToRootViewControllerAnimated:YES];
        RDVTabBarItem *item = [[[self.tabviewController tabBar] items] objectAtIndex:3];
        UIImage *selectedimage = [UIImage imageNamed:@"tabbarNotification_Selected"];
        UIImage *unselectedimage = [UIImage imageNamed:@"tabbarNotification"];
        [item setFinishedSelectedImage:selectedimage withFinishedUnselectedImage:unselectedimage];
    }else{
        if (user.launched) {
            Globle *glob = [Globle shareGloble];
            if (!glob.isApplicationEnterBackground && isLaunched) {
                
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                
                //
                //        if ([self checkMute]) {
                //            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                //        }else{
                //            AudioServicesPlaySystemSound(1301);
                //        }
                
                
                
            }
            if (DontShowNotification) {
                RDVTabBarItem *item = [[[self.tabviewController tabBar] items] objectAtIndex:3];
                UIImage *selectedimage = [UIImage imageNamed:@"tabbarNotification_Selected"];
                UIImage *unselectedimage = [UIImage imageNamed:@"tabbarNotification"];
                [item setFinishedSelectedImage:selectedimage withFinishedUnselectedImage:unselectedimage];
                UINavigationController *pushNac  = (UINavigationController *)self.tabviewController.selectedViewController;
                
                if ([pushNac.viewControllers.lastObject isKindOfClass:[NotificationCenterViewController class]]) {
                    NotificationCenterViewController *notifyVC = (NotificationCenterViewController *)pushNac.viewControllers.lastObject;
                    [notifyVC checkNewNotification];
                    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
                }else{
                    self.tabviewController.selectedViewController = self.notifyVC;
                    self.tabviewController.selectedIndex = 3;
                    [self.notifyVC popToRootViewControllerAnimated:YES];
                }
            }else{
                UINavigationController *nac = (UINavigationController *)self.tabviewController.selectedViewController;
                if (glob.isApplicationEnterBackground && [[userInfoDic allKeys] containsObject:@"payload"] && [[userInfoDic objectForKey:@"payload"] length] > 0 && [[userInfoDic objectForKey:@"payload"] rangeOfString:@"muzzik_id"].location!= NSNotFound) {
                    
                    DetaiMuzzikVC *detailvc = [[DetaiMuzzikVC alloc] init];
                    NSRange range = [[userInfoDic objectForKey:@"payload"] rangeOfString:@"muzzik_id"];
                    detailvc.muzzik_id = [[userInfoDic objectForKey:@"payload"] substringWithRange:NSMakeRange(range.length, [[userInfoDic objectForKey:@"payload"] length]-range.length)];
                    [nac pushViewController:detailvc animated:NO];
                }
                else if (nac != _notifyVC) {
                    RDVTabBarItem *item = [[[self.tabviewController tabBar] items] objectAtIndex:3];
                    UIImage *selectedimage = [UIImage imageNamed:@"tabbarNotification_Selected"];
                    UIImage *unselectedimage = [UIImage imageNamed:@"tabbarGetNotifucation"];
                    [item setFinishedSelectedImage:selectedimage withFinishedUnselectedImage:unselectedimage];
                    if ([[userInfoDic allKeys] containsObject:@"aps"] && [[[userInfoDic objectForKey:@"aps"] allKeys] containsObject:@"alert"] && [[userInfoDic objectForKey:@"aps"] objectForKey:@"alert"] && [[[[userInfoDic objectForKey:@"aps"] objectForKey:@"alert"] allKeys] containsObject:@"body"]) {
                        RDVTabBarItem *item = [[[self.tabviewController tabBar] items] objectAtIndex:3];
                        [item setFinishedSelectedImage:selectedimage withFinishedUnselectedImage:unselectedimage];
                        NSDictionary *aps = [userInfoDic objectForKey:@"aps"];
                        
                        NSString *record = [NSString stringWithFormat:@"[APN]%@, %@", [NSDate date], aps];
                        NSLog(@"%@       didReceiveRemoteNotification",record);
                        NSString *Message = [[aps objectForKey:@"alert" ] objectForKey:@"body"];
                        NSArray *array = [Message componentsSeparatedByString:@" "];
                        if ([array count]>1 ) {
                            NSString *alter = [array objectAtIndex:1];
                            if ([alter isEqualToString:@"评论了你"]) {
                                user.notificationType = NotificationType_reply;
                                user.notificationMessage = Message;
                            }else if([alter isEqualToString:@"提到了你"]){
                                user.notificationType = NotificationType_at;
                                user.notificationMessage = Message;
                            }
                            if ([user.notificationMessage length] >0) {
                                if ([nac.viewControllers.lastObject isKindOfClass:[FeedViewController class]] || [nac.viewControllers.lastObject isKindOfClass:[DetaiMuzzikVC class]] || [nac.viewControllers.lastObject isKindOfClass:[userDetailInfo class]]  || [nac.viewControllers.lastObject isKindOfClass:[UserHomePage class]]||[nac.viewControllers.lastObject isKindOfClass:[TopicVC class]]  ){
                                    [MuzzikItem showNewNotifyByText:user.notificationMessage ];
                                }
                            }
                            
                        }
                    }
                }
                else{
                    
                    if ([nac.viewControllers.lastObject isKindOfClass:[NotificationCenterViewController class]]) {
                        NotificationCenterViewController *notifyVC = (NotificationCenterViewController *)[nac.viewControllers lastObject];
                        [notifyVC checkNewNotification];
                        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
                    }
                }
            }
            
            // [4-EXT]:处理APN
            
            
        }
        isLaunched = YES;
    }
    
    completionHandler(UIBackgroundFetchResultNewData);

}
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    _deviceToken = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    [[RCIMClient sharedRCIMClient] setDeviceToken:_deviceToken];
    [GeTuiSdk registerDeviceToken:_deviceToken];
    NSLog(@"deviceToken:%@", _deviceToken);
    userInfo *user = [userInfo shareClass];
    user.deviceToken =_deviceToken;
    if ([user.token length]>0) {
        ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Set_Notify]]];
        [request addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:user.deviceToken,@"deviceToken",@"APN",@"type", nil] Method:PostMethod auth:YES];
        __weak ASIHTTPRequest *weakreq = request;
        [request setCompletionBlock :^{
            NSLog(@"%@",[weakreq responseString]);
            NSLog(@"%d",[weakreq responseStatusCode]);
            if ([weakreq responseStatusCode] == 200) {
                
                NSLog(@"register ok");
            }
            else{
                //[SVProgressHUD showErrorWithStatus:[dic objectForKey:@"message"]];
            }
        }];
        [request setFailedBlock:^{
            NSLog(@"%@",[weakreq error]);
        }];
        [request startAsynchronous];
    }
    // [3]:向个推服务器注册deviceToken

}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    
    // 处理推送消息
    
   // [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    // [4-EXT]:处理APN
    NSString *payloadMsg = [userInfo objectForKey:@"payload"];
    NSString *record = [NSString stringWithFormat:@"[APN]%@, %@", [NSDate date], payloadMsg];
    NSLog(@"receive:%@",record);
    
    [[RCIMClient sharedRCIMClient] recordRemoteNotificationEvent:userInfo];
    /**
     * 获取融云推送服务扩展字段2
     */
    NSDictionary *pushServiceData = [[RCIMClient sharedRCIMClient] getPushExtraFromRemoteNotification:userInfo];
    if (pushServiceData) {
        NSLog(@"该远程推送包含来自融云的推送服务");
        for (id key in [pushServiceData allKeys]) {
            NSLog(@"key = %@, value = %@", key, pushServiceData[key]);
        }
    } else {
        NSLog(@"该远程推送不包含来自融云的推送服务");
    }
    
    
}
-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
     [GeTuiSdk resume];
    completionHandler(UIBackgroundFetchResultNewData);
}
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
    NSLog(@"Regist fail%@",error);
    
}
- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [Globle shareGloble].isApplicationEnterBackground = YES;
    if([Globle shareGloble].isPlaying){
        [[NSNotificationCenter defaultCenter] postNotificationName:String_SetSongInformationNotification object:nil userInfo:nil];
    }
    [[RCIMClient sharedRCIMClient] disconnect];
    DontShowNotification = YES;
}
- (void)applicationWillEnterForeground:(UIApplication *)application {
    [self saveContext];
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}
- (void)applicationWillResignActive:(UIApplication *)application {
     [[RCIMClient sharedRCIMClient] disconnect];
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    DontShowNotification = NO;
    userInfo *user = [userInfo shareClass];
    if ([user.rongCloundToken length ]>0) {
        [[RCIMClient sharedRCIMClient] connectWithToken:user.rongCloundToken success:NULL error:NULL tokenIncorrect:NULL];
    }
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_New_notify_Now]]];
    [request addBodyDataSourceWithJsonByDic:nil Method:GetMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = request;
    [request setCompletionBlock :^{
        NSData *data = [weakrequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (dic && [[dic allKeys] containsObject:@"result"] && [[dic objectForKey:@"result"] integerValue]>0) {
            if (self.tabviewController.selectedViewController == self.notifyVC) {
                if ([self.notifyVC.viewControllers.lastObject isKindOfClass:[NotificationCenterViewController class]]) {
                    NotificationCenterViewController* notificationvc = (NotificationCenterViewController*)self.notifyVC.viewControllers.lastObject;
                    [notificationvc checkNewNotification];
                }
            }else{
                RDVTabBarItem *item = [[[self.tabviewController tabBar] items] objectAtIndex:3];
                UIImage *selectedimage = [UIImage imageNamed:@"tabbarNotification_Selected"];
                UIImage *unselectedimage = [UIImage imageNamed:@"tabbarGetNotifucation"];
                [item setFinishedSelectedImage:selectedimage withFinishedUnselectedImage:unselectedimage];
            }
            
        }
    }];
    [request startAsynchronous];
    

    [Globle shareGloble].isApplicationEnterBackground = NO;
}
- (void)application:(UIApplication *)application
didReceiveLocalNotification:(UILocalNotification *)notification {
    /**
     * 统计推送打开率3
     */
    [[RCIMClient sharedRCIMClient] recordLocalNotificationEvent:notification];
    
    //震动
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    AudioServicesPlaySystemSound(1007);
}

- (void)applicationWillTerminate:(UIApplication *)application {
    NSLog(@"end");
    [self saveContext];
    [ASIHTTPRequest clearSession];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
#pragma -mark GeTui
- (void)GeTuiSdkDidRegisterClient:(NSString *)clientId {
    // [4-EXT-1]: 个推SDK已注册，返回clientId
    NSLog(@"\n>>>[GeTuiSdk RegisterClient]:%@\n\n", clientId);
}

/** SDK遇到错误回调 */
- (void)GeTuiSdkDidOccurError:(NSError *)error {
    // [EXT]:个推错误报告，集成步骤发生的任何错误都在这里通知，如果集成后，无法正常收到消息，查看这里的通知。
    NSLog(@"\n>>>[GexinSdk error]:%@\n\n", [error localizedDescription]);
}
- (void)GeTuiSdkDidReceivePayload:(NSString *)payloadId andTaskId:(NSString *)taskId andMessageId:(NSString *)aMsgId andOffLine:(BOOL)offLine fromApplication:(NSString *)appId {
    
    // [4]: 收到个推消息
    NSData *payload = [GeTuiSdk retrivePayloadById:payloadId];
    NSString *payloadMsg = nil;
    if (payload) {
        payloadMsg = [[NSString alloc] initWithBytes:payload.bytes length:payload.length encoding:NSUTF8StringEncoding];
    }
    
    NSString *msg = [NSString stringWithFormat:@" payloadId=%@,taskId=%@,messageId:%@,payloadMsg:%@%@",payloadId,taskId,aMsgId,payloadMsg,offLine ? @"<离线消息>" : @""];
    NSLog(@"\n>>>[GexinSdk ReceivePayload]:%@\n\n", msg);
    
    /**
     *汇报个推自定义事件
     *actionId：用户自定义的actionid，int类型，取值90001-90999。
     *taskId：下发任务的任务ID。
     *msgId： 下发任务的消息ID。
     *返回值：BOOL，YES表示该命令已经提交，NO表示该命令未提交成功。注：该结果不代表服务器收到该条命令
     **/
    [GeTuiSdk sendFeedbackMessage:90001 taskId:taskId msgId:aMsgId];
}

#pragma -mark weibo
- (void)didReceiveWeiboRequest:(WBBaseRequest *)request
{
    
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    if ([response isKindOfClass:WBSendMessageToWeiboResponse.class])
    {
        if ((int)response.statusCode == 0) {
            [MuzzikItem showNotifyOnView:self.window.rootViewController.view text:@"分享成功"];
        }
        else if ((int)response.statusCode == -1) {
            [MuzzikItem showNotifyOnView:self.window.rootViewController.view text:@"取消分享"];
        }else if ((int)response.statusCode == -2) {
            [MuzzikItem showNotifyOnView:self.window.rootViewController.view text:@"分享失败"];
        }
        
        WBSendMessageToWeiboResponse* sendMessageToWeiboResponse = (WBSendMessageToWeiboResponse*)response;
        NSString* accessToken = [sendMessageToWeiboResponse.authResponse accessToken];
        if (accessToken)
        {
            self.wbtoken = accessToken;
        }
        NSString* userID = [sendMessageToWeiboResponse.authResponse userID];
        if (userID) {
            self.wbCurrentUserID = userID;
        }
    }
    else if ([response isKindOfClass:WBAuthorizeResponse.class])
    {
        userInfo *user = [userInfo shareClass];
        self.wbtoken = [(WBAuthorizeResponse *)response accessToken];
        self.wbCurrentUserID = [(WBAuthorizeResponse *)response userID];
        UINavigationController *nac = (UINavigationController *)self.tabviewController.selectedViewController;
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        [manager GET:[NSString stringWithFormat:@"%@%@",URL_WeiBo_AUTH,[(WBAuthorizeResponse *)response accessToken]] parameters:nil progress:NULL success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if(responseObject){
                if ([[responseObject allKeys] containsObject:@"token"]) {
                    user.token = [responseObject objectForKey:@"token"];
                }
                user.isSwitchUser = YES;
                if ([[responseObject allKeys] containsObject:@"avatar"]) {
                    user.avatar = [responseObject objectForKey:@"avatar"];
                }
                if ([[responseObject allKeys] containsObject:@"gender"]) {
                    user.gender = [responseObject objectForKey:@"gender"];
                }
                if ([[responseObject allKeys] containsObject:@"_id"]) {
                    user.uid = [responseObject objectForKey:@"_id"];
                }
                if ([[responseObject allKeys] containsObject:@"blocked"]) {
                    user.blocked = [[responseObject objectForKey:@"blocked"] boolValue];
                }
                if ([[responseObject allKeys] containsObject:@"name"]) {
                    user.name = [responseObject objectForKey:@"name"];
                }
                 [self registerRongClound];
                [MuzzikItem addMessageToLocal:[NSDictionary dictionaryWithObjectsAndKeys:user.token,@"token",user.avatar,@"avatar",user.name,@"name",user.uid,@"_id",user.gender,@"gender",nil]];
                if ([nac.viewControllers.lastObject isKindOfClass:[LoginViewController class]]) {
                    [nac popViewControllerAnimated:YES];
                }
                for (UIViewController *vc in nac.viewControllers) {
                    if ([vc isKindOfClass:[settingSystemVC class]]) {
                        settingSystemVC *settingvc = (settingSystemVC*)vc;
                        [settingvc reloadTable];
                        break;
                    }
                }
                
                [manager POST:URL_Set_Notify parameters:[NSDictionary dictionaryWithObjectsAndKeys:user.deviceToken,@"deviceToken",@"APN",@"type", nil] progress:NULL success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    NSLog(@"%@",responseObject);
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    NSLog(@"%@",error);
                }];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             NSLog(@"%@",error);
        }];
    }
}

- (void)removeNetWorkChangeNot
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}


#pragma -mark weichat

//- (void)sendAuthRequest
//{
//    SendAuthReq* req = [[[SendAuthReq alloc] init] autorelease];
//    req.scope = @"snsapi_message,snsapi_userinfo,snsapi_friend,snsapi_contact"; // @"post_timeline,sns"
//    req.state = @"xxx";
//    req.openID = @"0c806938e2413ce73eef92cc3";
//    
//    [WXApi sendAuthReq:req viewController:self.viewController delegate:self];
//}
- (void)sendAuthRequestByVC:(UIViewController *)vc
{
    SendAuthReq* req = [[SendAuthReq alloc] init];
    req.scope = @"snsapi_userinfo"; // @"post_timeline,sns"
    req.state = @"123";
    
    [WXApi sendAuthReq:req viewController:vc delegate:self];
    req = nil;
}

-(void) onResp:(BaseResp*)resp
{
    if([resp isKindOfClass:[SendMessageToWXResp class]])
    {
        if (resp.errCode == 0) {
            [MuzzikItem showNotifyOnViewUpon:self.window.rootViewController.view text:@"分享成功"];
        }
        else if (resp.errCode == -1) {
            [MuzzikItem showNotifyOnViewUpon:self.window.rootViewController.view text:@"分享失败"];
        }else if (resp.errCode == -2) {
            [MuzzikItem showNotifyOnViewUpon:self.window.rootViewController.view text:@"取消分享"];
        }
    }
    else if([resp isKindOfClass:[SendAuthResp class]])
    {
        SendAuthResp *temp = (SendAuthResp*)resp;
        userInfo *user = [userInfo shareClass];
        UINavigationController *nac = (UINavigationController *)self.tabviewController.selectedViewController;
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        [manager GET:URL_WeiChat_AUTH parameters:[NSDictionary dictionaryWithObjectsAndKeys:@"json",@"result",temp.code,@"code", nil] progress:NULL success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if(responseObject){
                
                user.isSwitchUser = YES;
                if ([[responseObject allKeys] containsObject:@"avatar"]) {
                    user.avatar = [responseObject objectForKey:@"avatar"];
                }
                if ([[responseObject allKeys] containsObject:@"gender"]) {
                    user.gender = [responseObject objectForKey:@"gender"];
                }
                if ([[responseObject allKeys] containsObject:@"_id"]) {
                    user.uid = [responseObject objectForKey:@"_id"];
                }
                if ([[responseObject allKeys] containsObject:@"blocked"]) {
                    user.blocked = [[responseObject objectForKey:@"blocked"] boolValue];
                }
                if ([[responseObject allKeys] containsObject:@"name"]) {
                    user.name = [responseObject objectForKey:@"name"];
                }
                if ([[responseObject allKeys] containsObject:@"token"]) {
                    user.token = [responseObject objectForKey:@"token"];

                }
                 [self registerRongClound];
                [MuzzikItem addMessageToLocal:[NSDictionary dictionaryWithObjectsAndKeys:user.token,@"token",user.avatar,@"avatar",user.name,@"name",user.uid,@"_id",user.gender,@"gender",nil]];
                if ([nac.viewControllers.lastObject isKindOfClass:[LoginViewController class]]) {
                    [nac popViewControllerAnimated:YES];
                }
                for (UIViewController *vc in nac.viewControllers) {
                    if ([vc isKindOfClass:[settingSystemVC class]]) {
                        settingSystemVC *settingvc = (settingSystemVC*)vc;
                        [settingvc reloadTable];
                        break;
                    }
                }
                
                [manager POST:URL_Set_Notify parameters:[NSDictionary dictionaryWithObjectsAndKeys:user.deviceToken,@"deviceToken",@"APN",@"type", nil] progress:NULL success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    NSLog(@"%@",responseObject);
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    NSLog(@"%@",error);
                }];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"%@",error);
        }];
        
    }
    else if ([resp isKindOfClass:[AddCardToWXCardPackageResp class]])
    {
        AddCardToWXCardPackageResp* temp = (AddCardToWXCardPackageResp*)resp;
        NSMutableString* cardStr = [[NSMutableString alloc] init];
        for (WXCardItem* cardItem in temp.cardAry) {
            [cardStr appendString:[NSString stringWithFormat:@"cardid:%@ cardext:%@ cardstate:%u\n",cardItem.cardId,cardItem.extMsg,(unsigned int)cardItem.cardState]];
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"add card resp" message:cardStr delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void) sendImageContent:(UIImage *)image
{
    WXMediaMessage *message = [WXMediaMessage message];
    [message setThumbImage:nil];
    
    WXImageObject *ext = [WXImageObject object];
    ext.imageData = UIImageJPEGRepresentation(image, 1);
    message.mediaObject = ext;
    message.mediaTagName = @"Muzzik";
    message.messageExt = @"share Image";
    message.messageAction = @"<action>dotalist</action>";
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = WXSceneTimeline;
    
    [WXApi sendReq:req];
}
-(void)weCahtsendMusicContentByscen:(int)scene{
    WXWebpageObject *wobject = [WXWebpageObject object];
    wobject.webpageUrl = URL_Muzzik_download;
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = @"一起来用Muzzik 吧";
    message.description = @"听最喜欢的歌，遇见最好的Ta";
    
    [message setThumbImage:[UIImage imageNamed:@"logo"]];
    message.mediaObject = wobject;
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = scene;
    
    [WXApi sendReq:req];
}
-(void) sendMusicContentByMuzzik:(muzzik*)localMuzzik scen:(int)scene image:(UIImage *)image
{
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = localMuzzik.music.name;
    message.description = localMuzzik.music.artist;

    [message setThumbImage:image];
    WXMusicObject *ext = [WXMusicObject object];
    ext.musicUrl = @"http://a.app.qq.com/o/simple.jsp?pkgname=com.blueorbit.Muzzik";
    ext.musicDataUrl = [NSString stringWithFormat:@"%@%@",BaseURL_audio,localMuzzik.music.key];
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = scene;
    
    [WXApi sendReq:req];
}

//#pragma -mark 辅助方法
//-(void) downLoadLyricByMusic:(music *)music{
//    
//}
-(void)onAudioSessionEvent:(NSNotification *)notify{
    NSLog(@"%@",notify.userInfo);
    Globle *glob = [Globle shareGloble];
    if ([[notify.userInfo allKeys] containsObject:@"AVAudioSessionInterruptionOptionKey"] && [[notify.userInfo allKeys] containsObject:@"AVAudioSessionInterruptionTypeKey"]) {
        if ([[notify.userInfo objectForKey:@"AVAudioSessionInterruptionOptionKey"] integerValue] == 1 && [[notify.userInfo objectForKey:@"AVAudioSessionInterruptionTypeKey"] integerValue] == 0) {
            if (needsReplay) {
                [[MuzzikPlayer shareClass].player resume];
                needsReplay = NO;
            }
            
        }
    }else if([[notify.userInfo allKeys] containsObject:@"AVAudioSessionInterruptionTypeKey"]){
        if ([[notify.userInfo objectForKey:@"AVAudioSessionInterruptionTypeKey"] integerValue] == 1) {
            if (glob.isPlaying && !glob.isPause) {
                needsReplay = YES;
                [[MuzzikPlayer shareClass].player pause];
            }
            
        }
    }
}

-(void) checkChannel{
    userInfo *user = [userInfo shareClass];
    user.WeChatInstalled = [WXApi isWXAppInstalled];
    user.QQInstalled = [QQApiInterface isQQInstalled];
}
#pragma -mark 启动图
-(void)updateTime{
    if (timeCount>0) {
        NSLog(@"%d",timeCount);
        timeCount-- ;
    }else{
        starAlert= [[UIAlertView alloc] initWithTitle:@"跪求五星好评" message:@"" delegate:self cancelButtonTitle:@"残忍拒绝" otherButtonTitles:nil];
        // optional - add more buttons:
        [starAlert addButtonWithTitle:@"走你!"];
        [starAlert show];
        [timer invalidate];
        timer = nil;
        
    }
}
- (void)addCoverVCToWindowFullImage:(UIImage *)fullImage slogan:(UIImage*)sloganImage{
    userInfo *user = [userInfo shareClass];
    user.launched = YES;
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    addView = [[UIView alloc] initWithFrame:self.window.bounds];
    coverImageView = [[UIImageView alloc] initWithFrame:self.window.bounds];
    UIImageView *startSlogan;
    
    if (fullImage && sloganImage) {
        [coverImageView setImage:fullImage];
        startSlogan =[[UIImageView alloc] initWithImage:sloganImage];
    }else{
        [coverImageView setImage:[UIImage imageNamed:@"startImage"]];
        startSlogan =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Startslogan"]];
    }
    
    coverImageView.contentMode = UIViewContentModeScaleAspectFill;
    CGFloat sizeScale = startSlogan.image.size.width/(SCREEN_WIDTH*0.9);
    if (sizeScale >= 1) {
        [startSlogan setFrame:CGRectMake(SCREEN_WIDTH*3/80, 64, startSlogan.image.size.width/sizeScale, startSlogan.image.size.height/sizeScale)];
    }else{
        [startSlogan setFrame:CGRectMake(SCREEN_WIDTH*3/80, 64, startSlogan.image.size.width, startSlogan.image.size.height)];
    }
    
    
    [startSlogan setAlpha:0];
    startSlogan.contentMode = UIViewContentModeScaleAspectFit;
    [UIView animateWithDuration:2 animations:^{
        [startSlogan setAlpha:1];
    }];
    if (fullImage) {
        startLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"landingpageshareImage"]];
        
    }else{
        startLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"muzzikSlogan"]];
        
    }
    [startLogo setFrame:CGRectMake(SCREEN_WIDTH-18-startLogo.frame.size.width, SCREEN_HEIGHT-startLogo.frame.size.height-18, startLogo.frame.size.width, startLogo.frame.size.height)];
    UIButton *tapButton = [[UIButton alloc] initWithFrame:startLogo.frame];
    [tapButton addTarget:self action:@selector(activityShareAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    NSLog(@"width:%f",[ UIScreen mainScreen ].bounds.size.width);
    [coverImageView addSubview:startLogo];
    [coverImageView addSubview:startSlogan];
    [addView addSubview:coverImageView];
    [addView addSubview:tapButton];
    [app.window addSubview:addView];
    
    if (fullImage) {
        [UIView animateWithDuration:1 animations:^{
            [startLogo setFrame:CGRectMake(startLogo.frame.origin.x-size_to_change, startLogo.frame.origin.y-size_to_change, startLogo.frame.size.width+2*size_to_change, startLogo.frame.size.height+2*size_to_change)];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:1 animations:^{
                [startLogo setFrame:CGRectMake(startLogo.frame.origin.x+size_to_change, startLogo.frame.origin.y+size_to_change, startLogo.frame.size.width-2*size_to_change, startLogo.frame.size.height-2*size_to_change)];
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:1 animations:^{
                    [startLogo setFrame:CGRectMake(startLogo.frame.origin.x-size_to_change, startLogo.frame.origin.y-size_to_change, startLogo.frame.size.width+2*size_to_change, startLogo.frame.size.height+2*size_to_change)];
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:1 animations:^{
                        [startLogo setFrame:CGRectMake(startLogo.frame.origin.x+size_to_change, startLogo.frame.origin.y+size_to_change, startLogo.frame.size.width-2*size_to_change, startLogo.frame.size.height-2*size_to_change)];
                    } completion:^(BOOL finished) {
                        [UIView animateWithDuration:1 animations:^{
                            [startLogo setFrame:CGRectMake(startLogo.frame.origin.x-size_to_change, startLogo.frame.origin.y-size_to_change, startLogo.frame.size.width+2*size_to_change, startLogo.frame.size.height+2*size_to_change)];
                        } completion:^(BOOL finished) {
                            [UIView animateWithDuration:1 animations:^{
                                [startLogo setFrame:CGRectMake(startLogo.frame.origin.x+size_to_change, startLogo.frame.origin.y+size_to_change, startLogo.frame.size.width-2*size_to_change, startLogo.frame.size.height-2*size_to_change)];
                            } completion:^(BOOL finished) {
                                [UIView animateWithDuration:1 animations:^{
                                    [startLogo setAlpha:0];
                                } completion:^(BOOL finished) {
                                    [UIView animateWithDuration:0.3 animations:^{
                                        [startLogo setHidden:YES];
                                        [startSlogan setHidden:YES];
                                        [coverImageView setAlpha:0];
                                        [coverImageView setFrame:CGRectMake(-coverImageView.frame.size.width, -coverImageView.frame.size.height, coverImageView.frame.size.width*3, coverImageView.frame.size.height*3)];
                                    } completion:^(BOOL finished) {
                                        [coverImageView removeFromSuperview];
                                        [addView removeFromSuperview];
                                        
                                    }];
                                }];
                            }];
                        }];
                    }];
                }];
            }];
        }];
    }else{
        
        [UIView animateWithDuration:5 animations:^{
            [startLogo setFrame:CGRectMake(startLogo.frame.origin.x-1, startLogo.frame.origin.y, startLogo.frame.size.width, startLogo.frame.size.height)];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.5 animations:^{
                [startLogo setHidden:YES];
                [startSlogan setHidden:YES];
                [coverImageView setAlpha:0];
                [coverImageView setFrame:CGRectMake(-coverImageView.frame.size.width, -coverImageView.frame.size.height, coverImageView.frame.size.width*3, coverImageView.frame.size.height*3)];
            } completion:^(BOOL finished) {
                [coverImageView removeFromSuperview];
                [addView removeFromSuperview];
                
            }];
            
        }];
        
    }
    
}
-(void)activityShareAction:(UIButton *)sender{
    
    userInfo *user = [userInfo shareClass];
    [startLogo setImage:[UIImage imageNamed:@"landingpageQRcode"]];
    [startLogo setFrame:CGRectMake(SCREEN_WIDTH-116, SCREEN_HEIGHT-116, 98, 98)];
    UIImage *myImage = [MuzzikItem convertViewToImage:addView];
    if (user.WeChatInstalled) {
        [self sendImageContent:myImage];
    }else{
        WBMessageObject *message = [WBMessageObject message];
        
        message.text =[NSString stringWithFormat:@"一起来用Muzzik吧"];
        
        WBImageObject *image = [WBImageObject object];
        image.imageData = UIImageJPEGRepresentation(myImage, 1.0);
        message.imageObject = image;
        
        WBAuthorizeRequest *authRequest = [WBAuthorizeRequest request];
        authRequest.redirectURI = URL_WeiBo_redirectURI;
        authRequest.scope = @"all";
        
        WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message authInfo:authRequest access_token:self.wbtoken];
        
        //    request.shouldOpenWeiboAppInstallPageIfNotInstalled = NO;
        [WeiboSDK sendRequest:request];
    }
    [addView removeFromSuperview];
}
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView == starAlert) {
        if (buttonIndex == 1) {
            NSDictionary *dic = [MuzzikItem getDictionaryFromLocalForKey:@"Muzzik_Check_Comment_Five_star"];
            [MuzzikItem addObjectToLocal:[NSDictionary dictionaryWithObjectsAndKeys:[dic objectForKey:@"times"],@"times",[dic objectForKey:@"date"],@"date",@"yes",@"hasClicked", nil] ForKey:@"Muzzik_Check_Comment_Five_star"];
            NSString *str = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@?mt=8",APP_ID ];
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
        }
    }
}


-(void)loadData{
    userInfo *user = [userInfo shareClass];

    ASIHTTPRequest *requestsquare = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Muzzik_Trending]]];
    [requestsquare addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:@"20" forKey:Parameter_Limit] Method:GetMethod auth:YES];
    __weak ASIHTTPRequest *weakrequestsquare = requestsquare;
    [requestsquare setCompletionBlock :^{
        //    NSLog(@"%@",weakrequest.originalURL);
        NSData *data = [weakrequestsquare responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (dic  && [[dic objectForKey:@"muzziks"] count]>0 ) {
            NSMutableArray *squareMuzziks = [NSMutableArray array];
            muzzik *muzzikToy = [muzzik new];
            NSArray *array = [muzzikToy makeMuzziksByMuzzikArray:[dic objectForKey:@"muzziks"]];
            for (muzzik *tempmuzzik in array) {
                BOOL isContained = NO;
                for (muzzik *arrayMuzzik in squareMuzziks) {
                    if ([arrayMuzzik.muzzik_id isEqualToString:tempmuzzik.muzzik_id]) {
                        isContained = YES;
                        break;
                    }
                    
                }
                if (!isContained) {
                    [squareMuzziks addObject:tempmuzzik];
                }
                isContained = NO;
            }
            [MuzzikItem SetUserInfoWithMuzziks:squareMuzziks title:Constant_userInfo_square description:nil];
            [MuzzikItem addObjectToLocal:data ForKey:Constant_Data_Square];
            
        }
    }];
    [requestsquare setFailedBlock:^{
        NSLog(@"%@,%@",[weakrequestsquare error],[weakrequestsquare responseString]);
    }];
    [requestsquare startAsynchronous];
    
    
    
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/muzzik/suggest",BaseURL]]];
    [request addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:@"10",Parameter_Limit,[NSNumber numberWithBool:YES],@"image", nil] Method:GetMethod auth:NO];
    __weak ASIHTTPRequest *weakrequest = request;
    [request setCompletionBlock :^{
        //    NSLog(@"%@",weakrequest.originalURL);
        NSData *data = [weakrequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (dic&&[[dic objectForKey:@"muzziks"]count]>0) {
            if ([[dic allKeys] containsObject:@"data"] && [[[dic objectForKey:@"data"] allKeys] containsObject:@"title"] && [[[dic objectForKey:@"data"] objectForKey:@"title"] length] >0) {
                user.suggestTitle = [[dic objectForKey:@"data"] objectForKey:@"title"];
            }
            [MuzzikItem SetUserInfoWithMuzziks:[[muzzik new] makeMuzziksByMuzzikArray:[dic objectForKey:@"muzziks"]] title:Constant_userInfo_suggest description:[NSString stringWithFormat:@"推荐列表"]];
            [MuzzikItem addObjectToLocal:data ForKey:Constant_Data_Suggest];
            
        }
    }];
    [request setFailedBlock:^{
        NSLog(@"%@,%@",[weakrequest error],[weakrequest responseString]);
    }];
    [request startAsynchronous];
    
    if ([user.token length]>0) {
        ASIHTTPRequest *requestOwn = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/user/%@/muzziks",BaseURL,user.uid]]];
        [requestOwn addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:20],Parameter_Limit ,nil] Method:GetMethod auth:YES];
        __weak ASIHTTPRequest *weakrequestOwn = requestOwn;
        [requestOwn setCompletionBlock :^{
            if ([weakrequestOwn responseStatusCode] == 200) {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequestOwn responseData] options:NSJSONReadingMutableContainers error:nil];
                if (dic  && [[dic objectForKey:@"muzziks"] count]>0 ) {
                    NSMutableArray *ownerMuzziks = [NSMutableArray array];
                    muzzik *muzzikToy = [muzzik new];
                    NSArray *array = [muzzikToy makeMuzziksByMuzzikArray:[dic objectForKey:@"muzziks"]];
                    for (muzzik *tempmuzzik in array) {
                        BOOL isContained = NO;
                        for (muzzik *arrayMuzzik in ownerMuzziks) {
                            if ([arrayMuzzik.muzzik_id isEqualToString:tempmuzzik.muzzik_id]) {
                                isContained = YES;
                                break;
                            }
                            
                        }
                        if (!isContained) {
                            [ownerMuzziks addObject:tempmuzzik];
                        }
                        isContained = NO;
                    }
                    [MuzzikItem SetUserInfoWithMuzziks:ownerMuzziks title:Constant_userInfo_own description:[NSString stringWithFormat:@"我的Muzzik"]];
                     [MuzzikItem addObjectToLocal:[weakrequestOwn responseData] ForKey:[NSString stringWithFormat:@"Persistence_own_data%@",user.token]];
                }
            }
            }];
            [requestOwn setFailedBlock:^{
                NSLog(@"%@",[weakrequestOwn error]);
            }];
            [requestOwn startAsynchronous];
        
        ASIHTTPRequest *requestfollow = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/muzzik/feeds",BaseURL]]];
        [requestfollow addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:30] forKey:Parameter_Limit] Method:GetMethod auth:YES];
        __weak ASIHTTPRequest *weakrequestfollow = requestfollow;
        [requestfollow setCompletionBlock :^{
            // NSLog(@"%@",[weakrequest responseString]);
            NSData *data = [weakrequestfollow responseData];
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            
            if (dic  && [[dic objectForKey:@"muzziks"] count]>0 ) {
                NSMutableArray *feedMuzziks = [NSMutableArray array];
                muzzik *muzzikToy = [muzzik new];
                NSArray *array = [muzzikToy makeMuzziksByMuzzikArray:[dic objectForKey:@"muzziks"]];
                for (muzzik *tempmuzzik in array) {
                    BOOL isContained = NO;
                    for (muzzik *arrayMuzzik in feedMuzziks) {
                        if ([arrayMuzzik.muzzik_id isEqualToString:tempmuzzik.muzzik_id]) {
                            isContained = YES;
                            break;
                        }
                        
                    }
                    if (!isContained) {
                        [feedMuzziks addObject:tempmuzzik];
                    }
                    isContained = NO;
                }
                 [MuzzikItem SetUserInfoWithMuzziks:feedMuzziks title:Constant_userInfo_follow description:[NSString stringWithFormat:@"关注列表"]];
                [MuzzikItem addObjectToLocal:data ForKey:[NSString stringWithFormat:@"User_Feed%@",user.uid]];
            }
        }];
        [requestfollow setFailedBlock:^{
            NSLog(@"%@,%@",[weakrequestfollow error],[weakrequestfollow responseString]);
        }];
        [requestfollow startAsynchronous];
        
        ASIHTTPRequest *requestmove = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/user/movedMuzzik",BaseURL]]];
        [requestmove addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:20] forKey:Parameter_Limit] Method:GetMethod auth:YES];
        __weak ASIHTTPRequest *weakrequestmove = requestmove;
        [requestmove setCompletionBlock :^{
            // NSLog(@"%@",[weakrequest responseString]);
            NSData *data = [weakrequestmove responseData];
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
//            if ([[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] == kReachableViaWiFi) {
//                NSArray *musicArray = [MuzzikItem getArrayFromLocalForKey:Muzzik_local_Music_Moved_Array];
//            }
            
            
            if (dic  && [[dic objectForKey:@"muzziks"] count]>0 ) {
                NSMutableArray *movedMuzziks = [NSMutableArray array];
                muzzik *muzzikToy = [muzzik new];
                NSArray *array = [muzzikToy makeMuzziksByMuzzikArray:[dic objectForKey:@"muzziks"]];
                for (muzzik *tempmuzzik in array) {
                    BOOL isContained = NO;
                    for (muzzik *arrayMuzzik in movedMuzziks) {
                        if ([arrayMuzzik.muzzik_id isEqualToString:tempmuzzik.muzzik_id]) {
                            isContained = YES;
                            break;
                        }
                        
                    }
                    if (!isContained) {
                        [movedMuzziks addObject:tempmuzzik];
                    }
                    isContained = NO;
                }
                [MuzzikItem SetUserInfoWithMuzziks:movedMuzziks title:Constant_userInfo_move description:[NSString stringWithFormat:@"喜欢列表"]];
                [MuzzikItem addObjectToLocal:data ForKey:[NSString stringWithFormat:@"Persistence_moved_data%@",user.token]];
            }
        }];
        [requestmove setFailedBlock:^{
            NSLog(@"%@,%@",[weakrequestmove error],[weakrequestmove responseString]);
        }];
        [requestmove startAsynchronous];
    }
    ASIHTTPRequest *requestHead = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL_image,user.avatar]]];
    [requestHead addBodyDataSourceWithJsonByDic:nil Method:GetMethod auth:NO];
    __weak ASIHTTPRequest *weakrequestHead = requestHead;
    [requestHead setCompletionBlock :^{
        if ([weakrequestHead responseStatusCode] == 200) {
            user.userHeadThumb = [UIImage imageWithData:[weakrequestHead responseData]];
        }
        else{
            //[SVProgressHUD showErrorWithStatus:[dic objectForKey:@"message"]];
        }
    }];
    [requestHead setFailedBlock:^{
        NSLog(@"%@",[weakrequest error]);
    }];
    [requestHead startAsynchronous];

    
    
}
#pragma mark - 创建相册
-(void) createAlbum{
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    NSMutableArray *groups=[[NSMutableArray alloc]init];
    ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group, BOOL *stop)
    {
        if (group)
        {
            [groups addObject:group];
        }
        
        else
        {
            BOOL haveHDRGroup = NO;
            
            for (ALAssetsGroup *gp in groups)
            {
                NSString *name =[gp valueForProperty:ALAssetsGroupPropertyName];
                
                if ([name isEqualToString:@"Muzzik相册"])
                {
                    haveHDRGroup = YES;
                }
            }
            
            if (!haveHDRGroup)
            {
                //do add a group named "XXXX"
                [assetsLibrary addAssetsGroupAlbumWithName:@"Muzzik相册"
                                               resultBlock:^(ALAssetsGroup *group1)
                 {
                     if (group1) {
                         [groups addObject:group1];
                         NSLog(@"%@",[MuzzikItem getStringForKey:@"Muzzik_Create_Album"]);
                         [MuzzikItem addObjectToLocal:@"yes" ForKey:@"Muzzik_Create_Album"];
                     }
                     
                     
                 }
                                              failureBlock:nil];
                haveHDRGroup = YES;
            }
        }
        
    };
    //创建相簿
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:listGroupBlock failureBlock:nil];
}

//NSData *data = [NSKeyedArchiver archivedDataWithRootObject:arr1];
//
//NSArray *arr2 = [NSKeyedUnarchiver unarchiveObjectWithData:data];
- (void) QueryAllMusic
{
    NSString *versionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey];
    ASIHTTPRequest *requestVersion = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :@"http://1.myappapi.sinaapp.com/getapi/"]];
    __weak ASIHTTPRequest *weakrequestV = requestVersion;
    [requestVersion setCompletionBlock :^{
        if ([weakrequestV responseStatusCode] == 200) {
            NSData *data = [weakrequestV responseData];
            if (data) {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                if ([versionString isEqualToString:[dic objectForKey:@"version"]]) {
                    if ([[dic objectForKey:@"hide"] isEqualToString:@"1"]) {
                        userInfo *user = [userInfo shareClass];
                        user.hideLyric = YES;
                    }
                }
            }
        }
    }];
    [requestVersion setFailedBlock:^{
        userInfo *user = [userInfo shareClass];
        user.hideLyric = YES;
    }];
    [requestVersion startSynchronous];
    MPMediaQuery *everything = [MPMediaQuery albumsQuery];
    NSLog(@"Logging items from a generic query...");
    NSArray *itemsFromGenericQuery = [everything items];
    NSLog(@"count = %lu", (unsigned long)itemsFromGenericQuery.count);
    if (itemsFromGenericQuery.count > 0) {
        NSArray *array = [MuzzikItem getArrayFromLocalForKey:@"Muzzik_Local_Itunes_Muzzik"];
        if (!array) {
            array = [NSArray array];
        }
        for (MPMediaItem *song in itemsFromGenericQuery)
        {
            NSString *songTitle = [song valueForProperty: MPMediaItemPropertyTitle];
            NSString *songArtist = [song valueForProperty:MPMediaItemPropertyArtist];
            
            
            __block NSMutableArray *musicArray = [array mutableCopy];
            BOOL isContained = NO;
            if ([array count] > 0 ) {
                for (NSDictionary *dic in array) {
                    if ([[dic objectForKey:@"name"] isEqualToString:songTitle] && [[dic objectForKey:@"artist"] isEqualToString:songArtist]) {
                        isContained = YES;
                        break;
                    }
                }
            }
            if (isContained) {
                continue;
            }else{
                
                ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Music_Search]]];
                [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:Limit_Constant,Parameter_Limit,[[NSString stringWithFormat:@"%@ %@",songTitle,songArtist] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],@"q", nil] Method:GetMethod auth:NO];
                __weak ASIHTTPRequest *weakrequest = requestForm;
                [requestForm setCompletionBlock :^{
                    NSLog(@"%@",[weakrequest responseString]);
                    NSLog(@"%d",[weakrequest responseStatusCode]);
                    
                    if ([weakrequest responseStatusCode] == 200) {
                        
                        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData] options:NSJSONReadingMutableContainers error:nil];
                        
                       
                        
                        if ([[dic objectForKey:@"music"] count] >0) {
                            NSMutableArray *songarray = [dic objectForKey:@"music"];
                            for (NSDictionary *dicMusic in songarray) {
                                if ([[dicMusic objectForKey:@"name"]isEqualToString:songTitle] && [[dicMusic objectForKey:@"artist"] isEqualToString:songArtist]) {
                                    [musicArray addObject:dicMusic];
                                    [MuzzikItem addObjectToLocal:[musicArray copy] ForKey:@"Muzzik_Local_Itunes_Muzzik"];
                                    break;
                                }
                                
                            }
                        }
                    }
                }];
                [requestForm setFailedBlock:^{
                }];
                [requestForm startAsynchronous];
            }
            
            
            
            
        }
    }
    
}
- (BOOL)tabBarController:(RDVTabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    userInfo *user = [userInfo shareClass];
    if (viewController == itemVC) {
        return NO;
    }
    if ([user.token length] == 0) {
        if (viewController == self.notifyVC) {
            UINavigationController *nac = (UINavigationController *) self.tabviewController.selectedViewController;
            LoginViewController *login = [[LoginViewController alloc] init];
            [nac pushViewController:login animated:YES];
            [self.tabviewController setTabBarHidden:YES animated:YES];
            return NO;
        }else if(viewController == self.userhomeVC){
            UINavigationController *nac = (UINavigationController *) self.tabviewController.selectedViewController;
            LoginViewController *login = [[LoginViewController alloc] init];
            [nac pushViewController:login animated:YES];
            [self.tabviewController setTabBarHidden:YES animated:YES];
            return NO;
        }else{
            return YES;
        }
            
    }else{
        return YES;
    }
}

/**
 * Tells the delegate that the user selected an item in the tab bar.
 */
- (void)tabBarController:(RDVTabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
    if (viewController == self.notifyVC) {
        RDVTabBarItem *item = [[[self.tabviewController tabBar] items] objectAtIndex:3];
        UIImage *selectedimage = [UIImage imageNamed:@"tabbarNotification_Selected"];
        UIImage *unselectedimage = [UIImage imageNamed:@"tabbarNotification"];
        [item setFinishedSelectedImage:selectedimage withFinishedUnselectedImage:unselectedimage];
    }
}
//-(BOOL)checkMute{
//    CFStringRef state;
//    UInt32 propertySize = sizeof(CFStringRef);
//    AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &propertySize, &state);
//    
//    if(CFStringGetLength(state) == 0) {
//        return YES;
//    }
//    else {
//        return NO;
//    }
//}

-(void) registerRongClound{

    userInfo *user = [userInfo shareClass];
    if ([user.token length]>0 && [user.name length]>0 && [user.uid length]>0 && [user.avatar length]>0) {
        if (!user.account) {
            user.account = [self getAccountByUserName:user.name userId:user.uid userToken:user.token Avatar:user.avatar];
        }
        if (user.account) {
            AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:BaseURL_LUCH]];
            [manager GET:URL_RongClound_Token parameters:nil progress:NULL success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                if( responseObject){
                    user.rongCloundToken = [responseObject objectForKey:@"token"];
                    [[RCIMClient sharedRCIMClient] connectWithToken:[responseObject objectForKey:@"token"] success:^(NSString *userId) {
                        NSLog(@"登陆成功。当前登录的用户ID：%@", userId);
                        
                    } error:^(RCConnectErrorCode status) {
                        NSLog(@"登陆的错误码为:%d", status);
                    } tokenIncorrect:^{
                        [self registerRongClound];
                        //token过期或者不正确。
                        //如果设置了token有效期并且token过期，请重新请求您的服务器获取新的token
                        //如果没有设置token有效期却提示token错误，请检查您客户端和服务器的appkey是否匹配，还有检查您获取token的流程。
                        NSLog(@"token错误");
                    }];
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                NSLog(@"%@",[error.userInfo objectForKey:@"NSLocalizedDescription"]);
                if ([[error.userInfo objectForKey:@"NSLocalizedDescription"]isEqualToString:@"Request failed: unauthorized (401)"]) {
                    user.token = @"";
                    user.uid = @"";
                    user.avatar = @"";
                    user.name = @"";
                    user.gender = @"";
                    user.isSwitchUser = YES;
                    user.account = nil;
                    [MuzzikItem removeMessageFromLocal:@"LoginAcess"];
                    
                    
                }
            }];
        }
    }
    
    
    
}
- (void)onConnectionStatusChanged:(RCConnectionStatus)status{
    self.IMconnectionStatus = status;
    if (status == ConnectionStatus_Unconnected) {
        [self registerRongClound];
    }
    UINavigationController *nac = (UINavigationController *)self.tabviewController.selectedViewController;
    if([nac.viewControllers.lastObject isKindOfClass:[IMConversationViewcontroller class]]){
        //handle message
        NSLog(@"2121");
        
        IMConversationViewcontroller* vc =(IMConversationViewcontroller *)nac.viewControllers.lastObject;
        [vc connectionChanged:status];
    }
}


#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;




- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "BlueOrbit._____" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Muzzik_coreModel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Muzzik_coreModel.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (void)onReceived:(RCMessage *)message
              left:(int)nLeft
            object:(id)object {
    if ([[RCIMClient sharedRCIMClient] clearMessagesUnreadStatus:ConversationType_PRIVATE targetId:message.targetId] ) {
        
        //添加支持的类型
        if ([message.content isMemberOfClass:[RCTextMessage class]]) {
            [IMMessageDispatcher processTextMessageByRCMessage:message];
            
        }
        else if ([message.content isMemberOfClass:[IMShareMessage class]]){
            [IMMessageDispatcher processShareMessageByRCMessage:message];
        }else if ([message.content isKindOfClass:[IMEnterMessage class]]){
            [IMMessageDispatcher processEnterMessageByRCMessage:message];
        }
        else if ([message.content isKindOfClass:[IMListenMessage class]]){
            [IMMessageDispatcher processListenToMessageByRCMessage:message];
        }
        else if ([message.content isKindOfClass:[IMCancelListenMessage class]]){
            [IMMessageDispatcher processCancelMessageByRCMessage:message];
        }
        else if ([message.content isKindOfClass:[IMSynMusicMessage class]]){
            [IMMessageDispatcher processSynMusicMessageByRCMessage:message];
        }
        else{
            [IMMessageDispatcher processUnkowMessage:message];
        }
    }
    
    
}

-(void)sendIMMessage:(RCMessageContent *)contentMessage targetCon:(Conversation *)targetCon pushContent:(NSString *)pushContent{
    userInfo *user = [userInfo shareClass];
    __block Message *coreMessage = [self getNewMessage];

    coreMessage.sendTime = [NSDate date];
    coreMessage.sendStatue = Statue_Sending;
    
//    NSLog(@"%@ %@ %@",coreMessage.messageUser.name,coreMessage.messageUser.avatar,coreMessage.messageUser.user_id);
    if ([contentMessage isKindOfClass:[RCTextMessage class]] ) {
        RCTextMessage *textMessage = (RCTextMessage *)contentMessage;
        textMessage.extra = [Utils_IM DataTOjsonString:[NSDictionary dictionaryWithObjectsAndKeys:user.name,@"name",user.avatar,@"avatar",user.uid,@"_id", nil]];
        coreMessage.messageType = Type_IM_TextMessage;
        coreMessage.messageContent = textMessage.content;
        coreMessage.abstractString = textMessage.content;
        
    }
    else if ([contentMessage isKindOfClass:[IMShareMessage class]]){
        IMShareMessage *shareMessage = (IMShareMessage *)contentMessage;
        shareMessage.extra = [Utils_IM DataTOjsonString:[NSDictionary dictionaryWithObjectsAndKeys:user.name,@"name",user.avatar,@"avatar",user.uid,@"_id", nil]];
        coreMessage.messageData =[shareMessage.jsonStr  dataUsingEncoding:NSUTF8StringEncoding];
        coreMessage.messageType = Type_IM_ShareMuzzik;;
        coreMessage.abstractString = @"[Muzzik]";
        
    }
    coreMessage.messageUser = user.account.ownerUser;
    coreMessage.isOwner = [NSNumber numberWithBool:YES];
    
//    NSLog(@"%@",targetCon.messages.count);
    [targetCon addMessagesObject:coreMessage];
     [self.managedObjectContext save:nil];
    targetCon.abstractString = coreMessage.abstractString;
    
    if (!targetCon.sendTime) {
        targetCon.sendTime =[NSDate date];
        coreMessage.needsToShowTime = [NSNumber numberWithBool:YES];
    }
    else if([self checkLimitedTime:coreMessage.sendTime oldDate:targetCon.sendTime]){
        targetCon.sendTime = coreMessage.sendTime;
        coreMessage.needsToShowTime = [NSNumber numberWithBool:YES];
    }
    else{
        targetCon.sendTime = coreMessage.sendTime;
        coreMessage.needsToShowTime = [NSNumber numberWithBool:NO];
    }
    if (![user.account.myConversation.firstObject.targetId isEqualToString:targetCon.targetId]) {
        [user.account removeMyConversationObject:targetCon];
        [user.account insertObject:targetCon inMyConversationAtIndex:0];
    }
    [self.managedObjectContext save:nil];
    UINavigationController *nac = (UINavigationController *)self.tabviewController.selectedViewController;
    if([nac.viewControllers.lastObject isKindOfClass:[IMConversationViewcontroller class]]){
        IMConversationViewcontroller* vc =(IMConversationViewcontroller *)nac.viewControllers.lastObject;
        if ([vc.con.targetId isEqualToString:targetCon.targetId]) {
            [vc inserCellWithMessage:coreMessage];
        }
    }
    
    [[RCIMClient sharedRCIMClient] sendMessage:ConversationType_PRIVATE targetId:targetCon.targetId content:contentMessage pushContent:pushContent success:^(long messageId) {
        coreMessage.messageId = [NSNumber numberWithLong:messageId];
        coreMessage.sendStatue = Statue_OK;
        [self.managedObjectContext save:nil];
        
        UINavigationController *nac = (UINavigationController *)self.tabviewController.selectedViewController;
        if([nac.viewControllers.lastObject isKindOfClass:[IMConversationViewcontroller class]]){
            
            IMConversationViewcontroller* vc =(IMConversationViewcontroller *)nac.viewControllers.lastObject;
            if ([vc.con.targetId isEqualToString:targetCon.targetId]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [vc resetCellByMessage:coreMessage];
                });
                
            }
        }
        
        
    } error:^(RCErrorCode nErrorCode, long messageId) {
        coreMessage.messageId = [NSNumber numberWithLong:messageId];
        coreMessage.sendStatue = Statue_Failed;
        UINavigationController *nac = (UINavigationController *)self.tabviewController.selectedViewController;
        if([nac.viewControllers.lastObject isKindOfClass:[IMConversationViewcontroller class]]){
            
            IMConversationViewcontroller* vc =(IMConversationViewcontroller *)nac.viewControllers.lastObject;
            if ([vc.con.targetId isEqualToString:targetCon.targetId]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [vc resetCellByMessage:coreMessage];
                });
                
            }
        }
        [self.managedObjectContext save:nil];
       
        
    }];
}







-(Account *) getAccountByUserName:(NSString *)name userId:(NSString *) uid userToken:(NSString *)token Avatar:(NSString *) avatar{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Account" inManagedObjectContext:self.managedObjectContext];
    Account *account;
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user_id == %@",uid];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        NSLog(@"无法打开");
        return nil;
    }else{
        if ([fetchedObjects count] >0) {
            return fetchedObjects[0];
        }else{
            account = [[Account alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];
            UserCore *newUser = [self getNewUser];
            newUser.user_id = uid;
            newUser.name = name;
            newUser.avatar = avatar;
            account.ownerUser = newUser;
            account.user_id = uid;
            account.token = token;
            [self.managedObjectContext save:nil];
            return account;
            
        }
    }
    return nil;
}
-(Message *) getNewMessage{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:self.managedObjectContext];
    Message *message = [[Message alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];
    return message;
}
-(UserCore *) getNewUser{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"UserCore" inManagedObjectContext:self.managedObjectContext];
    UserCore *user = [[UserCore alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];
    return user;
}


-(UserCore *)getNewUserWithuserinfo:(RCUserInfo *)userinfo{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"UserCore" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user_id == %@", userinfo.userId];
    [fetchRequest setPredicate:predicate];
    // Specify how the fetched objects should be sorted
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        NSLog(@"%@",error.userInfo);
    }else{
        if ([fetchedObjects count] == 0 ) {
            UserCore *newUser = [self getNewUser];
            newUser.name = userinfo.name;
            newUser.user_id = userinfo.userId;
            newUser.avatar = userinfo.portraitUri;
             [self.managedObjectContext save:nil];
            return newUser;
        }else{
            UserCore *newUser = fetchedObjects[0];
            if (![newUser.name isEqualToString:userinfo.name] || ![newUser.avatar isEqualToString:userinfo.portraitUri]) {
                newUser.name = userinfo.name;
                newUser.user_id = userinfo.userId;
                newUser.avatar = userinfo.portraitUri;
                [self.managedObjectContext save:nil];
            }
            return newUser;
        }
    }
    return nil;
}
-(Conversation *) getNewConversationWithTargetId:(NSString *) targetId{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"UserCore" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"targetId == %@", targetId];
    [fetchRequest setPredicate:predicate];
    // Specify how the fetched objects should be sorted
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        NSLog(@"%@",error.userInfo);
    }else{
        if ([fetchedObjects count] == 0 ) {
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"Conversation" inManagedObjectContext:self.managedObjectContext];
            Conversation *con = [[Conversation alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];
            return con;
        }else{
            return fetchedObjects[0];
        }
    }
    return nil;
    
}
-(Conversation *)getConversationByUserInfo:(RCUserInfo *)userinfo{
    userInfo *user = [userInfo shareClass];
    Conversation *newCon;
    BOOL contained = NO;
    for (NSInteger i = 0; i < user.account.myConversation.count; i++) {
        Conversation * tempCon = [user.account.myConversation objectAtIndex:i];
        if ([userinfo.userId isEqualToString:tempCon.targetId]) {
            newCon = tempCon;
            contained = YES;
            break;
        }
    }
    if(contained){
        if (![newCon.targetUser.name isEqualToString:userinfo.name] || ![newCon.targetUser.avatar isEqualToString:userinfo.portraitUri]) {
            newCon.targetUser.name = userinfo.name;
            newCon.targetUser.avatar = userinfo.portraitUri;
            [self.managedObjectContext save:nil];
        }
        
    }else{
        
        newCon = [self getNewConversationWithTargetId:userinfo.userId];
        newCon.targetId = userinfo.userId;
        
        newCon.targetUser = [self getNewUserWithuserinfo:userinfo];
        [user.account addMyConversationObject:newCon];
        
    }
    NSLog(@"%@ %@ %@",newCon.targetUser.name,newCon.targetUser.avatar,newCon.targetUser.user_id);
    return newCon;
}

-(NSDictionary *) decodeUserinfoRawdic:(NSString *)rawString{
    if (rawString) {
        NSData *dicData = [rawString dataUsingEncoding:NSUTF8StringEncoding];
        if (dicData) {
            return [NSJSONSerialization JSONObjectWithData:dicData options:NSJSONReadingMutableContainers error:nil];
        }
    }
    return nil;
}

-(BOOL) checkLimitedTime:(NSDate *)new oldDate:(NSDate *)old{
    NSTimeInterval newInterval = [new timeIntervalSinceReferenceDate];
    NSTimeInterval oldInterval = [old timeIntervalSinceReferenceDate];
    if (newInterval - oldInterval > 300) {
        return YES;
    }else{
        return NO;
    }
}
@end
