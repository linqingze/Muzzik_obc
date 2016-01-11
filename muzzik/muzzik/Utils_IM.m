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
        return @"昨天";
    }else if((interval<2*24*60*60 && result) ||(interval<3*24*60*60 && !result)){ //一天之外
        return @"2天前";
    }else if((interval<3*24*60*60 && result) ||(interval<4*24*60*60 && !result)){ //一天之外
        return @"3天前";
    }else if((interval<4*24*60*60 && result) ||(interval<5*24*60*60 && !result)){ //一天之外
        return @"4天前";
    }else if((interval<5*24*60*60 && result) ||(interval<6*24*60*60 && !result)){ //一天之外
        return @"5天前";
    }else if((interval<6*24*60*60 && result) ||(interval<7*24*60*60 && !result)){ //一天之外
        return @"6天前";
    }else {
        [formatter setDateFormat:@"yyyy.MM.dd"];
        nowString = [formatter stringFromDate:date];
        
        return nowString;
    }
    
}
@end
