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
#import <RongIMKit/RongIMKit.h>
#import "UMessage_Sdk_1.2.2/UMessage.h"
@interface AppDelegate (){
    BOOL isLaunched;
    UIViewController *itemVC;
    BOOL needsReplay;
}

@end

@implementation AppDelegate
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
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAudioSessionEvent:) name:AVAudioSessionInterruptionNotification object:nil];
    isLaunched = YES;
    userInfo *user = [userInfo shareClass];
    [WXApi registerApp:ID_WeiChat_APP];
    [WeiboSDK enableDebugMode:NO];
    [WeiboSDK registerApp:Key_WeiBo];
    [self startSdkWith:kAppId appKey:kAppKey appSecret:kAppSecret];
    [MobClick startWithAppkey:UMAPPKEY reportPolicy:BATCH channelId:@"App Store"];
//    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
//    [MobClick setAppVersion:version];
    NSDictionary * dic = [MuzzikItem messageFromLocal];
    if (dic) {
       
        user.uid = [dic objectForKey:@"_id"];
        user.token = [dic objectForKey:@"token"];
        user.gender = [dic objectForKey:@"gender"];
        user.avatar = [dic objectForKey:@"avatar"];
        user.name = [dic objectForKey:@"name"];
        
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
    //    [self.tabviewController.tabBar setShadowImage:[MuzzikItem createImageWithColor:[UIColor clearColor]]];
    
    self.tabviewController.tabBar.translucent = YES;
    
    [self customizeTabBarForController:tabBarController];
    [self.window setRootViewController:self.tabviewController];
    [[SDImageCache sharedImageCache] cleanDisk];
    
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

        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    }
    [self registerRongClound];
    [self configureUmengNotificationWithOptions:launchOptions];
    return YES;
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
-(void)GexinSdkDidReceivePayload:(NSString *)payloadId fromApplication:(NSString *)appId{
    _payloadId =payloadId;
    NSData *data = [_gexinPusher retrivePayloadById:payloadId];
    NSString *payloadMsg = nil;
//    if (data) {
//        UINavigationController *nac = (UINavigationController *)self.window.rootViewController;
//        for (UIViewController *vc in nac.viewControllers) {
//            if ([vc isKindOfClass:[RootViewController class]]){
//                RootViewController *root = (RootViewController *)vc;
//                [root getMessage];
//                
//            }
//    }
//        payloadMsg = [[NSString alloc] initWithBytes:data.bytes
//                                              length:data.length
//                                            encoding:NSUTF8StringEncoding];
//    NSLog(@"payload:%@",[payloadMsg stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
//    }
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [self stopSdk];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [Globle shareGloble].isApplicationEnterBackground = YES;
    if([Globle shareGloble].isPlaying){
        [[NSNotificationCenter defaultCenter] postNotificationName:String_SetSongInformationNotification object:nil userInfo:nil];
    }
    
}

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
        UINavigationController *nac = (UINavigationController *)self.tabviewController.selectedViewController;
        if (glob.isApplicationEnterBackground && [[userInfoDic allKeys] containsObject:@"payload"] && [[userInfoDic objectForKey:@"payload"] length] > 0 && [[userInfoDic objectForKey:@"payload"] rangeOfString:@"muzzik_id"].location!= NSNotFound) {
            DetaiMuzzikVC *detailvc = [[DetaiMuzzikVC alloc] init];
            NSRange range = [[userInfoDic objectForKey:@"payload"] rangeOfString:@"muzzik_id"];
            detailvc.muzzik_id = [[userInfoDic objectForKey:@"payload"] substringWithRange:NSMakeRange(range.length, [[userInfoDic objectForKey:@"payload"] length]-range.length)];
            [nac pushViewController:detailvc animated:NO];
        }else if (nac != _notifyVC) {
            RDVTabBarItem *item = [[[self.tabviewController tabBar] items] objectAtIndex:3];
            UIImage *selectedimage = [UIImage imageNamed:@"tabbarNotification_Selected"];
            UIImage *unselectedimage = [UIImage imageNamed:@"tabbarGetNotifucation"];
            [item setFinishedSelectedImage:selectedimage withFinishedUnselectedImage:unselectedimage];
            if ([nac.viewControllers count]>1) {
                if ([[userInfoDic allKeys] containsObject:@"aps"] && [[[userInfoDic objectForKey:@"aps"] allKeys] containsObject:@"alert"] && [[userInfoDic objectForKey:@"aps"] objectForKey:@"alert"] && [[[[userInfoDic objectForKey:@"aps"] objectForKey:@"alert"] allKeys] containsObject:@"body"]) {
                    RDVTabBarItem *item = [[[self.tabviewController tabBar] items] objectAtIndex:3];
                    UIImage *selectedimage = [UIImage imageNamed:@"tabbarNotification_Selected"];
                    UIImage *unselectedimage = [UIImage imageNamed:@"tabbarGetNotifucation"];
                    [item setFinishedSelectedImage:selectedimage withFinishedUnselectedImage:unselectedimage];
                    NSDictionary *aps = [userInfoDic objectForKey:@"aps"];
                    
                    NSString *record = [NSString stringWithFormat:@"[APN]%@, %@", [NSDate date], aps];
                    NSLog(@"%@       didReceiveRemoteNotification",record);
                    NSString *Message = [[aps objectForKey:@"alert" ] objectForKey:@"body"];
                    NSArray *array = [Message componentsSeparatedByString:@" "];
                    if ([array count]>1 ) {
                        NSString *alter = [array objectAtIndex:1];
                        if ([alter isEqualToString:@"评论了你"]) {
                            [MuzzikItem showNewNotifyByText:Message];
                        }else if([alter isEqualToString:@"提到了你"]){
                            [MuzzikItem showNewNotifyByText:Message];
                        }
                    }
                }
            }
        }else{
            if ([nac.viewControllers count] == 1) {
                NotificationCenterViewController *notifyVC = (NotificationCenterViewController *)[nac.viewControllers lastObject];
                [notifyVC checkNewNotification];
                [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
            }else{
                if ([[userInfoDic allKeys] containsObject:@"aps"] && [[[userInfoDic objectForKey:@"aps"] allKeys] containsObject:@"alert"] && [[userInfoDic objectForKey:@"aps"] objectForKey:@"alert"] && [[[[userInfoDic objectForKey:@"aps"] objectForKey:@"alert"] allKeys] containsObject:@"body"]) {
                    NSDictionary *aps = [userInfoDic objectForKey:@"aps"];
                    
                    NSString *record = [NSString stringWithFormat:@"[APN]%@, %@", [NSDate date], aps];
                    NSLog(@"%@       didReceiveRemoteNotification",record);
                    NSString *Message = [[aps objectForKey:@"alert" ] objectForKey:@"body"];
                    NSArray *array = [Message componentsSeparatedByString:@" "];
                    if ([array count]>1 ) {
                        NSString *alter = [array objectAtIndex:1];
                        if ([alter isEqualToString:@"评论了你"]) {
                            [MuzzikItem showNewNotifyByText:Message];
                        }else if([alter isEqualToString:@"提到了你"]){
                            [MuzzikItem showNewNotifyByText:Message];
                        }
                        
                        //
                        //            if ([alter isEqualToString:@"评论了你"]) {
                        //                [MuzzikItem showNewNotifyByText:Message];
                        //            }else if([alter isEqualToString:@"提到了你"]){
                        //                [MuzzikItem showNewNotifyByText:Message];
                        //            }else if([alter isEqualToString:@"喜欢了你的"]){
                        //                [MuzzikItem showNewNotifyByText:Message];
                        //            }else if([alter isEqualToString:@"转发了你的"]){
                        //                [MuzzikItem showNewNotifyByText:Message];
                        //            }else if([alter isEqualToString:@"参与了你发起的话题"]){
                        //                [MuzzikItem showNewNotifyByText:Message];
                        //            }else {
                        //                //处理关注，微博好友等
                        //                [MuzzikItem showNewNotifyByText:Message];
                        //            }
                    }
                }
            }
        }
        // [4-EXT]:处理APN
        

    }
           isLaunched = YES;
    completionHandler(UIBackgroundFetchResultNewData);

}
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    [UMessage registerDeviceToken:deviceToken];
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    _deviceToken = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
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
    if (_gexinPusher) {
        [_gexinPusher registerDeviceToken:_deviceToken];
    }
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    
    // 处理推送消息
    
   // [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [UMessage didReceiveRemoteNotification:userInfo];
    // [4-EXT]:处理APN
    NSString *payloadMsg = [userInfo objectForKey:@"payload"];
    NSString *record = [NSString stringWithFormat:@"[APN]%@, %@", [NSDate date], payloadMsg];
    NSLog(@"receive:%@",record);
    
}
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
    NSLog(@"Regist fail%@",error);
    if (_gexinPusher) {
        [_gexinPusher registerDeviceToken:@""];
    }
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
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
    
    [self startSdkWith:kAppId appKey:kAppKey appSecret:kAppSecret];
    [Globle shareGloble].isApplicationEnterBackground = NO;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    NSLog(@"end");
    [ASIHTTPRequest clearSession];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma  -mark 个推Delegate

- (void)startSdkWith:(NSString *)appID appKey:(NSString *)appKey appSecret:(NSString *)appSecret
{
    if (!_gexinPusher) {
        _sdkStatus = SdkStatusStoped;
        
        self.appID = appID;
        self.appKey = appKey;
        self.appSecret = appSecret;
        
        _clientId = nil;
        
        NSError *err = nil;
        _gexinPusher = [GexinSdk createSdkWithAppId:_appID
                                             appKey:_appKey
                                          appSecret:_appSecret
                                         appVersion:@"0.0.0"
                                           delegate:self
                                              error:&err];
        if (!_gexinPusher) {
            NSLog(@"%@",err);
        } else {
            _sdkStatus = SdkStatusStarting;
        }
        
    }
}

- (void)stopSdk
{
    if (_gexinPusher) {
        [_gexinPusher destroy];
        _gexinPusher = nil;
        
        _sdkStatus = SdkStatusStoped;
        
        _clientId = nil;
        
    }
}
- (BOOL)checkSdkInstance
{
    if (!_gexinPusher) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"错误" message:@"SDK未启动" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alertView show];
        return NO;
    }
    return YES;
}

- (void)setDeviceToken:(NSString *)aToken
{
    if (![self checkSdkInstance]) {
        return;
    }
    
    [_gexinPusher registerDeviceToken:aToken];
}

- (BOOL)setTags:(NSArray *)aTags error:(NSError **)error
{
    if (![self checkSdkInstance]) {
        return NO;
    }
    
    return [_gexinPusher setTags:aTags];
}
- (void)GexinSdkDidRegisterClient:(NSString *)clientId{
     _sdkStatus = SdkStatusStarted;
    _clientId = clientId;


}
- (NSString *)sendMessage:(NSData *)body error:(NSError **)error {
    if (![self checkSdkInstance]) {
        return nil;
    }
    
    return [_gexinPusher sendMessage:body error:error];
}

- (void)bindAlias:(NSString *)aAlias {
    if (![self checkSdkInstance]) {
        return;
    }
    
    return [_gexinPusher bindAlias:aAlias];
}

- (void)unbindAlias:(NSString *)aAlias {
    if (![self checkSdkInstance]) {
        return;
    }
    
    return [_gexinPusher unbindAlias:aAlias];
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
        ASIHTTPRequest *requestsquare = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@%@",BaseURL,URL_WeiBo_AUTH,[(WBAuthorizeResponse *)response accessToken]]]];
        [requestsquare addBodyDataSourceWithJsonByDic:nil Method:GetMethod auth:YES];
        __weak ASIHTTPRequest *weakrequestsquare = requestsquare;
        [requestsquare setCompletionBlock :^{
            //    NSLog(@"%@",weakrequest.originalURL);
            NSData *data = [weakrequestsquare responseData];
            NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            
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
            [MuzzikItem addMessageToLocal:[NSDictionary dictionaryWithObjectsAndKeys:user.token,@"token",user.avatar,@"avatar",user.name,@"name",user.uid,@"_id",user.gender,@"gender",nil]];
            if ([nac.viewControllers.lastObject isKindOfClass:[LoginViewController class]]) {
                [nac popViewControllerAnimated:YES];
            }
            ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Set_Notify]]];
            [request addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:user.deviceToken,@"deviceToken",@"APN",@"type", nil] Method:PostMethod auth:YES];
            __weak ASIHTTPRequest *weakrequest = request;
            [request setCompletionBlock :^{
                NSLog(@"JSON: %@", [weakrequest responseString]);
            }];
             [request setFailedBlock:^{
                 
             }];
            [request startAsynchronous];
            
            for (UIViewController *vc in nac.viewControllers) {
                if ([vc isKindOfClass:[settingSystemVC class]]) {
                    settingSystemVC *settingvc = (settingSystemVC*)vc;
                    [settingvc reloadTable];
                    break;
                }
            }
            
            
            
            
        }];
        [requestsquare setFailedBlock:^{
            NSLog(@"%@,%@",[weakrequestsquare error],[weakrequestsquare responseString]);
        }];
        [requestsquare startAsynchronous];
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
        ASIHTTPRequest *requestsquare = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_WeiChat_AUTH]]];
        [requestsquare addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:@"json",@"result",temp.code,@"code", nil] Method:GetMethod auth:YES];
        __weak ASIHTTPRequest *weakrequestsquare = requestsquare;
        [requestsquare setCompletionBlock :^{
            NSData *data = [weakrequestsquare responseData];
            NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];

            user.isSwitchUser = YES;
            if ([[responseObject allKeys] containsObject:@"token"]) {
                user.token = [responseObject objectForKey:@"token"];
            }
            if ([[responseObject allKeys] containsObject:@"avatar"]) {
                user.avatar = [responseObject objectForKey:@"avatar"];
            }
            if ([[responseObject allKeys] containsObject:@"gender"]) {
                user.gender = [responseObject objectForKey:@"gender"];
            }
            if ([[responseObject allKeys] containsObject:@"_id"]) {
                user.uid = [responseObject objectForKey:@"_id"];
                [UMessage addAlias:user.uid type:@"Muzzik" response:^(id responseObject, NSError *error) {
                    NSLog(@"object:%@,error:%@",responseObject,error);
                }];
            }
            if ([[responseObject allKeys] containsObject:@"blocked"]) {
                user.blocked = [[responseObject objectForKey:@"blocked"] boolValue];
            }
            if ([[responseObject allKeys] containsObject:@"name"]) {
                user.name = [responseObject objectForKey:@"name"];
            }
            [MuzzikItem addMessageToLocal:[NSDictionary dictionaryWithObjectsAndKeys:user.token,@"token",user.avatar,@"avatar",user.name,@"name",user.uid,@"_id",user.gender,@"gender",nil]];
            if ([user.token length]>0) {
                ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Set_Notify]]];
                [request addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:user.deviceToken,@"deviceToken",@"APN",@"type", nil] Method:PostMethod auth:YES];
                __weak ASIHTTPRequest *weakrequest = request;
                [request setCompletionBlock :^{
                    NSLog(@"JSON: %@", [weakrequest responseString]);
                }];
                [request setFailedBlock:^{
                    
                }];
                [request startAsynchronous];
                UINavigationController *nac = (UINavigationController *)self.tabviewController.selectedViewController;
                for (UIViewController *vc in nac.viewControllers) {
                    if ([vc isKindOfClass:[settingSystemVC class]]) {
                        settingSystemVC *settingvc = (settingSystemVC*)vc;
                        [settingvc reloadTable];
                        break;
                    }
                }
                [nac popViewControllerAnimated:YES];
            }
        }];
        [requestsquare setFailedBlock:^{
            NSLog(@"%@",[weakrequestsquare error]);
        }];
        [requestsquare startAsynchronous];
        
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
    [[RCIM sharedRCIM] initWithAppKey:AppKey_RongClound];
    ASIHTTPRequest *rongRequest = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL,URL_RongClound_Token]]];
    [rongRequest addBodyDataSourceWithJsonByDic:nil Method:GetMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = rongRequest;
    [rongRequest setCompletionBlock :^{
        if ([weakrequest responseStatusCode] == 200) {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData] options:NSJSONReadingMutableContainers error:nil];
            NSLog(@"%@",dic);
            
            [[RCIM sharedRCIM] connectWithToken:[dic objectForKey:@"token"] success:^(NSString *userId) {
                NSLog(@"登陆成功。当前登录的用户ID：%@", userId);
            } error:^(RCConnectErrorCode status) {
                NSLog(@"登陆的错误码为:%d", status);
            } tokenIncorrect:^{
                //token过期或者不正确。
                //如果设置了token有效期并且token过期，请重新请求您的服务器获取新的token
                //如果没有设置token有效期却提示token错误，请检查您客户端和服务器的appkey是否匹配，还有检查您获取token的流程。
                NSLog(@"token错误");
            }];
        }
    }];
    [rongRequest setFailedBlock:^{
        NSLog(@"%@",[weakrequest error]);
    }];
    [rongRequest startAsynchronous];
}
#pragma mark configure Method

-(void) configureUmengNotificationWithOptions:(NSDictionary *)launchOptions {
    [UMessage startWithAppkey:AppKey_UMeng launchOptions:launchOptions];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= _IPHONE80_
    if(IOS_8_OR_LATER)
    {
        //register remoteNotification types （iOS 8.0及其以上版本）
        UIMutableUserNotificationAction *action1 = [[UIMutableUserNotificationAction alloc] init];
        action1.identifier = @"action1_identifier";
        action1.title=@"Accept";
        action1.activationMode = UIUserNotificationActivationModeForeground;//当点击的时候启动程序
        
        UIMutableUserNotificationAction *action2 = [[UIMutableUserNotificationAction alloc] init];  //第二按钮
        action2.identifier = @"action2_identifier";
        action2.title=@"Reject";
        action2.activationMode = UIUserNotificationActivationModeBackground;//当点击的时候不启动程序，在后台处理
        action2.authenticationRequired = YES;//需要解锁才能处理，如果action.activationMode = UIUserNotificationActivationModeForeground;则这个属性被忽略；
        action2.destructive = YES;
        
        UIMutableUserNotificationCategory *categorys = [[UIMutableUserNotificationCategory alloc] init];
        categorys.identifier = @"category1";//这组动作的唯一标示
        [categorys setActions:@[action1,action2] forContext:(UIUserNotificationActionContextDefault)];
        
        UIUserNotificationSettings *userSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert
                                                                                     categories:[NSSet setWithObject:categorys]];
        [UMessage registerRemoteNotificationAndUserNotificationSettings:userSettings];
        
    } else{
        //register remoteNotification types (iOS 8.0以下)
        [UMessage registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge
         |UIRemoteNotificationTypeSound
         |UIRemoteNotificationTypeAlert];
    }
#else
    
    //register remoteNotification types (iOS 8.0以下)
    [UMessage registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge
     |UIRemoteNotificationTypeSound
     |UIRemoteNotificationTypeAlert];
    
#endif
    //for log
    [UMessage setLogEnabled:YES];
}

@end
