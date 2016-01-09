//
//  AppDelegate.h
//  muzzik
//
//  Created by 林清泽 on 15/3/7.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "WXApi.h"
#import "GexinSdk.h"
#import "WeiboSDK.h"
#import "Reachability.h"
#import "RDVTabBarController.h"
typedef enum {
    SdkStatusStoped,
    SdkStatusStarting,
    SdkStatusStarted
} SdkStatus;

@interface AppDelegate : UIResponder {
     NSString *_deviceToken;
}
@property (strong, nonatomic) RDVTabBarController *tabviewController;
@property (strong, nonatomic) UINavigationController *feedVC;
@property (strong, nonatomic) UINavigationController *notifyVC;
@property (strong, nonatomic) UINavigationController *userhomeVC;
@property (strong, nonatomic) UINavigationController *topicVC;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) GexinSdk *gexinPusher;
@property (copy, nonatomic) NSString *wbtoken;
@property (copy, nonatomic) NSString *wbCurrentUserID;
@property (copy, nonatomic) NSString *appKey;
@property (copy, nonatomic) NSString *appSecret;
@property (copy, nonatomic) NSString *appID;
@property (copy, nonatomic) NSString *clientId;
@property (assign, nonatomic) SdkStatus sdkStatus;

@property (assign, nonatomic) int lastPayloadIndex;
@property (retain, nonatomic) NSString *payloadId;


@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


- (void)startSdkWith:(NSString *)appID appKey:(NSString *)appKey appSecret:(NSString *)appSecret;
- (void)stopSdk;

- (void)setDeviceToken:(NSString *)aToken;
- (BOOL)setTags:(NSArray *)aTag error:(NSError **)error;
- (NSString *)sendMessage:(NSData *)body error:(NSError **)error;

- (void)bindAlias:(NSString *)aAlias;
- (void)unbindAlias:(NSString *)aAlias;
//-(void) downLoadLyricByMusic:(music *)music;
- (void) sendImageContent:(UIImage *)image;
-(void) sendMusicContentByMuzzik:(muzzik*)localMuzzik scen:(int)scene image:(UIImage *)image;
- (void)sendAuthRequestByVC:(UIViewController *)vc;
-(void)weCahtsendMusicContentByscen:(int)scene;
@end

