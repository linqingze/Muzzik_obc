//
//  Utils_IM.m
//  muzzik
//
//  Created by muzzik on 16/1/9.
//  Copyright © 2016年 muzziker. All rights reserved.
//

#import "Utils_IM.h"

@implementation Utils_IM

+(NSString *) getStringFromIMDate:(NSDate*)date{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];

    NSDate *now = [NSDate date];

    [formatter setDateFormat:@"HH:mm"];
    NSTimeInterval interval = fabs([date timeIntervalSinceNow]);
    NSString *nowString = [formatter stringFromDate:now];
    NSString *timeString = [formatter stringFromDate:date];
    
    BOOL result = [nowString compare:timeString] == NSOrderedAscending;
    
    if (interval<24*60*60 && !result) {
        return timeString;
    }else if((interval<24*60*60 && result) ||(interval<2*24*60*60 && !result)){ //一天之外
        return [NSString stringWithFormat:@"昨天 %@",timeString];
    }else if((interval<2*24*60*60 && result) ||(interval<3*24*60*60 && !result)){ //一天之外
        return [NSString stringWithFormat:@"前天 %@",timeString];
    }else {
        [formatter setDateFormat:@"yyyy.MM.dd  HH:mm"];
        nowString = [formatter stringFromDate:date];
        
        return nowString;
    }
    
}

+(BOOL) checkLimitedTime:(NSDate *)new oldDate:(NSDate *)old{
    NSTimeInterval newInterval = [new timeIntervalSinceReferenceDate];
    NSTimeInterval oldInterval = [old timeIntervalSinceReferenceDate];
    if (newInterval - oldInterval > 300) {
        return YES;
    }else{
        return NO;
    }
}
+(BOOL) checkoOldDate:(NSDate *)old{
    NSTimeInterval nowInterval = [[NSDate date] timeIntervalSinceReferenceDate];
    NSTimeInterval oldInterval = [old timeIntervalSinceReferenceDate];
    if (nowInterval - oldInterval < 20) {
        return YES;
    }else{
        return NO;
    }
}
+(NSString*)DataTOjsonString:(id)object
{
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}
@end
