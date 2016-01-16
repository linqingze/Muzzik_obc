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
    NSDictionary *dict = @{@"jsonstr": self.jsonData};
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
        self.jsonData = [dict[@"jsonstr"] dataUsingEncoding:NSUTF8StringEncoding];
    } else {
        self.rawJSONData = data;
    }
}
@end
