//
//  IM_share_Message.h
//  muzzik
//
//  Created by muzzik on 16/1/14.
//  Copyright © 2016年 muzziker. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>

@interface IMShareMessage : RCMessageContent
@property(nonatomic,retain) NSData *jsonData;

@end
