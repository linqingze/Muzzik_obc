//
//  IMEnterMessage.h
//  muzzik
//
//  Created by muzzik on 16/1/31.
//  Copyright © 2016年 muzziker. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>

@interface IMEnterMessage : RCMessageContent<RCMessagePersistentCompatible,RCMessageContentView>
@property(nonatomic,retain) NSString *jsonStr;
@property(nonatomic,retain) NSString *extra;

@end
