//
//  IMConversationViewcontroller.h
//  muzzik
//
//  Created by muzzik on 15/12/30.
//  Copyright © 2015年 muzziker. All rights reserved.
//

#import <RongIMKit/RongIMKit.h>
#import "Conversation.h"
@interface IMConversationViewcontroller : AMScrollingNavbarViewController
@property(nonatomic,retain) Conversation *con;

-(void) inserCellWithMessage:(Message *) coreMessage;
@end
