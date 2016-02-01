//
//  IMEnterMessage.m
//  muzzik
//
//  Created by muzzik on 16/1/31.
//  Copyright © 2016年 muzziker. All rights reserved.
//

#import "IMEnterMessage.h"

@implementation IMEnterMessage
+ (NSString *)getObjectName {
    return @"Muzzik:enter";
}


- (NSData *)encode{
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    if (self.jsonStr) {
        [dataDict setObject:self.jsonStr forKey:@"jsonstr"];
    }
    if (self.senderUserInfo) {
        NSMutableDictionary *__dic = [[NSMutableDictionary alloc] init];
        if (self.senderUserInfo.name) {
            [__dic setObject:self.senderUserInfo.name forKeyedSubscript:@"name"];
        }
        if (self.senderUserInfo.portraitUri) {
            [__dic setObject:self.senderUserInfo.portraitUri forKeyedSubscript:@"portrait"];
        }
        if (self.senderUserInfo.userId) {
            [__dic setObject:self.senderUserInfo.userId forKeyedSubscript:@"id"];
        }
        [dataDict setObject:__dic forKey:@"user"];
    }
    if (self.extra) {
        [dataDict setObject:self.extra forKey:@"extra"];
    }
    
    NSError *__error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dataDict options:kNilOptions error:&__error];
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
        
        self.extra = [dict objectForKey:@"extra"];
        
        NSDictionary *userinfoDic = [dict objectForKey:@"user"];
        [self decodeUserInfo:userinfoDic];
    } else {
        self.rawJSONData = data;
    }
}
+ (RCMessagePersistent)persistentFlag{
    return MessagePersistent_ISCOUNTED | MessagePersistent_ISPERSISTED;
}

@end
