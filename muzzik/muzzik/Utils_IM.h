//
//  Utils_IM.h
//  muzzik
//
//  Created by muzzik on 16/1/9.
//  Copyright © 2016年 muzziker. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utils_IM : NSObject
+(NSString *) getStringFromIMDate:(NSDate*)date;
+(BOOL) checkLimitedTime:(NSDate *)new oldDate:(NSDate *)old;
+(BOOL) checkoOldDate:(NSDate *)old;

+(NSString*)DataTOjsonString:(id)object;
@end
