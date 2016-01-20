//
//  AppDelegate.h
//  muzzik
//
//  Created by 林清泽 on 15/3/7.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WXApi.h"
#import "GeTuiSdk.h"
#import "WeiboSDK.h"
#import "Reachability.h"
#import "RDVTabBarController.h"
#import <CoreData/CoreData.h>
#import "Account.h"
#import "Message.h"
#import "Conversation.h"
#import "UserCore.h"
#import <RongIMLib/RongIMLib.h>

@interface AppDelegate : UIResponder {
     NSString *_deviceToken;
}
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) RDVTabBarController *tabviewController;
@property (strong, nonatomic) UINavigationController *feedVC;
@property (strong, nonatomic) UINavigationController *notifyVC;
@property (strong, nonatomic) UINavigationController *userhomeVC;
@property (strong, nonatomic) UINavigationController *topicVC;
@property (strong, nonatomic) UIWindow *window;
@property (copy, nonatomic) NSString *wbtoken;
@property (copy, nonatomic) NSString *wbCurrentUserID;
@property (copy, nonatomic) NSString *appKey;
@property (copy, nonatomic) NSString *appSecret;
@property (copy, nonatomic) NSString *appID;
@property (copy, nonatomic) NSString *clientId;
@property (assign, nonatomic) SdkStatus sdkStatus;

@property (assign, nonatomic) int lastPayloadIndex;
@property (retain, nonatomic) NSString *payloadId;


//-(void) downLoadLyricByMusic:(music *)music;
- (void) sendImageContent:(UIImage *)image;
-(void) sendMusicContentByMuzzik:(muzzik*)localMuzzik scen:(int)scene image:(UIImage *)image;
- (void)sendAuthRequestByVC:(UIViewController *)vc;
-(void)weCahtsendMusicContentByscen:(int)scene;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
-(Account *) getAccountByUserName:(NSString *)name userId:(NSString *) uid userToken:(NSString *)token Avatar:(NSString *) avatar;
-(Message *) getNewMessage;
-(UserCore *) getNewUser;
-(Conversation *) getNewConversation;
-(BOOL) checkLimitedTime:(NSDate *)new oldDate:(NSDate *)old;
-(Conversation *)getConversationByUserInfo:(RCUserInfo *)userinfo;
-(void)sendIMMessage:(RCMessageContent *)contentMessage targetCon:(Conversation *)targetCon pushContent:(NSString *)pushContent;
-(UserCore *)getNewUserWithuserinfo:(RCUserInfo *)userinfo;
@end

