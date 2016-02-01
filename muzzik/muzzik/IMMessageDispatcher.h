//
//  IMMessageDispatcher.h
//  muzzik
//
//  Created by muzzik on 16/2/1.
//  Copyright © 2016年 muzziker. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IMMessageDispatcher : NSObject

+(void)processShareMessageByRCMessage:(RCMessage *) message;
+(void)processEnterMessageByRCMessage:(RCMessage *) message;
+(void)processTextMessageByRCMessage:(RCMessage *) message;
+(void)processCancelMessageByRCMessage:(RCMessage *) message;
+(void)processSynMusicMessageByRCMessage:(RCMessage *) message;
+(void)processListenToMessageByRCMessage:(RCMessage *) message;
+(void)processUnkowMessage:(RCMessage *) message;
@end
