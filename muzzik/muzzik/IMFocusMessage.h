//
//  IMFocusMessage.h
//  muzzik
//
//  Created by muzzik on 16/2/18.
//  Copyright © 2016年 muzziker. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>

@interface IMFocusMessage : RCMessageContent<RCMessagePersistentCompatible,RCMessageContentView>
@property(nonatomic,retain) NSString *jsonStr;
@property(nonatomic,retain) NSString *extra;

@end
