//
//  MuzzikHTTPSessionManager.m
//  muzzik
//
//  Created by muzzik on 15/12/19.
//  Copyright © 2015年 muzziker. All rights reserved.
//

#import "MuzzikHTTPSessionManager.h"

@implementation MuzzikHTTPSessionManager
+ (instancetype)sharedManager{
    static MuzzikHTTPSessionManager *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *baseURL = [NSURL URLWithString:Muzzik_BaseURL];
        
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        [config setHTTPAdditionalHeaders:@{ @"User-Agent" : @"TuneStore iOS 1.0"}];
        //设置我们的缓存大小 其中内存缓存大小设置10M  磁盘缓存5M
        [config setTimeoutIntervalForRequest:4.0];
        NSURLCache *cache = [[NSURLCache alloc] initWithMemoryCapacity:10 * 1024 * 1024
                                                          diskCapacity:50 * 1024 * 1024
                                                              diskPath:nil];
        
        [config setURLCache:cache];
        
        _sharedClient = [[MuzzikHTTPSessionManager alloc] initWithBaseURL:baseURL
                                         sessionConfiguration:config];
        _sharedClient.responseSerializer = [AFJSONResponseSerializer serializer];
    });
    
    return _sharedClient;
}


@end
