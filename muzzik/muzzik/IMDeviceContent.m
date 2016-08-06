//
//  IMDeviceContent.m
//  muzzik
//
//  Created by muzzik on 16/1/25.
//  Copyright © 2016年 muzziker. All rights reserved.
//

#import "IMDeviceContent.h"

@implementation IMDeviceContent
+ (NSString *)getObjectName {
    return @"Muzzik:device";
}

//- (NSData *)encode{
//    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
//
//    NSError *__error = nil;
//    NSData *data = [NSJSONSerialization dataWithJSONObject:dataDict options:kNilOptions error:&__error];
//    if (!__error) {
//        return data;
//    } else {
//        NSDictionary *userInfo = @{@"error": __error};
//        @throw [NSException exceptionWithName:@"Failed at conversing GroupInvitationNotification instance to JSON data"
//                                       reason:@"please check encode method"
//                                     userInfo:userInfo];
//    }
//}
//-(void)decodeWithData:(NSData *)data {
//    __autoreleasing NSError *__error = nil;
//    if (!data) {
//        return;
//    }
//    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&__error];
//    if (!__error && dict) {
//
//    } else {
//        self.rawJSONData = data;
//    }
//}

@end
