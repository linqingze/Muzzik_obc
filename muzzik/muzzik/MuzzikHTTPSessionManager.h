//
//  MuzzikHTTPSessionManager.h
//  muzzik
//
//  Created by muzzik on 15/12/19.
//  Copyright © 2015年 muzziker. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@interface MuzzikHTTPSessionManager : AFHTTPSessionManager
+ (instancetype)sharedManager;
@end
