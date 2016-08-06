//
//  IMConversationViewcontroller.h
//  muzzik
//
//  Created by muzzik on 15/12/30.
//  Copyright © 2015年 muzziker. All rights reserved.
//

#import <RongIMKit/RongIMKit.h>
#import "Conversation.h"
#import "ListenTogetherView.h"
@interface IMConversationViewcontroller : AMScrollingNavbarViewController
@property(nonatomic,retain) Conversation *con;
@property(nonatomic,retain) NSMutableArray *messageArray;
@property(nonatomic,retain) ListenTogetherView *listenView;
-(void) inserCellWithMessage:(Message *) coreMessage;
-(void) showUserImageWithimageKey:(NSString *)imageKey holdImage:(UIImage *) holdImage orginalRect:(CGRect) rect;
-(void) connectionChanged:(RCConnectionStatus)status;
-(void) resetCellByMessage:(Message *) changedMessage;
-(void) receiveInserCellWithMessage:(Message *)coreMessage;
-(void) userDetail:(NSString *)user_id;
-(void) removeListenMessage;
-(void) updateSynMusicMessage:(NSDictionary *) musicDic;
@end
