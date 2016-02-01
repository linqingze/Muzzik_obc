//
//  userInfo.h
//  ShopUpUp
//
//  Created by kevin's mac on 14-8-1.
//  Copyright (c) 2014年 IOS. All rights reserved.
//
#import "Account.h"
#import <Foundation/Foundation.h>
#import <RongIMLib/RongIMLib.h>
typedef NS_ENUM(NSInteger, NotificationType) {
    NotificationType_reply = 1,
    NotificationType_moved,
    NotificationType_at,
    NotificationType_follow,
    NotificationType_repost,
    NotificationType_topic,
    NotificationType_IM
};
@protocol searchSource <NSObject>


@optional
// The content for any tab. Return a view controller and ViewPager will use its view to show as content
-(void)updateDataSource:(NSString *)searchText;
-(void)searchDataSource:(NSString *)searchText;

@end

@interface userInfo : NSObject
@property (nonatomic,assign) BOOL launched;
@property (nonatomic,retain) muzzik *poMuzzik;
@property (nonatomic,copy) NSString *token;
@property (nonatomic,copy) NSString *uid;
@property (nonatomic,copy) NSString *avatar;
@property (nonatomic,copy) NSString *gender;
@property (nonatomic,assign) BOOL blocked;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *deviceToken;
@property (nonatomic,copy) NSString *clientId;
@property (nonatomic,assign) BOOL WeChatInstalled;
@property (nonatomic,assign) BOOL QQInstalled;
@property (nonatomic,retain) NSMutableDictionary *playList;
@property (nonatomic,assign) BOOL checkSquare;
@property (nonatomic,assign) BOOL checkOwn;
@property (nonatomic,assign) BOOL checkFollow;
@property (nonatomic,assign) BOOL checkMove;
@property (nonatomic,assign) BOOL checkSuggest;
@property (nonatomic,assign) BOOL checkTemp;
@property (nonatomic,retain) UIImage *userHeadThumb;
@property (nonatomic,copy) NSString *suggestTitle;
@property (nonatomic,retain) id poController;
@property (nonatomic,assign) BOOL isSwitchUser;
@property (nonatomic,assign) NSInteger loginType;
@property (nonatomic,assign) BOOL hideLyric;
@property (nonatomic,assign) NSInteger notificationNumTotal;
@property (nonatomic,assign) NSInteger notificationNumReply;
@property (nonatomic,assign) BOOL notificationNumReplyNew;
@property (nonatomic,assign) NSInteger notificationNumMetion;
@property (nonatomic,assign) BOOL notificationNumMetionNew;
@property (nonatomic,assign) NSInteger notificationNumFollow;
@property (nonatomic,assign) BOOL notificationNumFollowNew;
@property (nonatomic,assign) NSInteger notificationNumMoved;
@property (nonatomic,assign) BOOL notificationNumMovedNew;
@property (nonatomic,assign) NSInteger notificationNumRepost;
@property (nonatomic,assign) BOOL notificationNumRepostNew;
@property (nonatomic,assign) NSInteger notificationNumParticipationTopic;
@property (nonatomic,assign) BOOL notificationNumParticipationTopicNew;
@property (nonatomic,retain) UIImageView *playNowImageView;
@property (nonatomic,assign) BOOL hasTeachToFollow;
@property (nonatomic,retain) NSMutableDictionary *followDic;
@property (nonatomic,retain) Account *account;
@property (nonatomic,copy) NSString *rongCloundToken;
@property (nonatomic,assign) NotificationType notificationType;
@property (nonatomic,copy) NSString *notificationMessage;
@property (nonatomic,retain) RCUserInfo *targetUserinfo;
@property (nonatomic,retain) NSMutableArray *listenUser;
@property (nonatomic,retain) NSMutableArray *focusArray;    //关心用户列表
@property (nonatomic,copy) NSString *rootId;                //一起听歌root用户 id
@property (nonatomic,copy) NSString *listenToUid;           //正在听的user用户 id
+(userInfo *) shareClass;
+(void)checkLoginWithVC:(UIViewController *)vc;
@end
