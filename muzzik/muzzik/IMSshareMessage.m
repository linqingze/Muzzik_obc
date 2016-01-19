//
//  IM_share_Message.m
//  muzzik
//
//  Created by muzzik on 16/1/14.
//  Copyright © 2016年 muzziker. All rights reserved.
//

#import "IMShareMessage.h"

@implementation IMShareMessage


+ (NSString *)getObjectName {
    return @"app:sharemuzzik";
}


- (NSData *)encode{
    NSDictionary *dict = @{@"jsonstr": self.jsonStr};
    NSError *__error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&__error];
    if (!__error) {
        return data;
    } else {
        NSDictionary *userInfo = @{@"error": __error};
        @throw [NSException exceptionWithName:@"Failed at conversing GroupInvitationNotification instance to JSON data"
                                       reason:@"please check encode method"
                                     userInfo:userInfo];
    }
}
-(void)decodeWithData:(NSData *)data {
    __autoreleasing NSError *__error = nil;
    if (!data) {
        return;
    }
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&__error];
    if (!__error && dict) {
        self.jsonStr = dict[@"jsonstr"];
    } else {
        self.rawJSONData = data;
    }
}
+ (RCMessagePersistent)persistentFlag{
    return MessagePersistent_ISCOUNTED | MessagePersistent_ISPERSISTED;
}

-(NSString *)conversationDigest{
    return @"分享了一条Muzzik";
}
@end
