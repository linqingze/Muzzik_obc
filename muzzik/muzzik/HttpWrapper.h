//
//  HttpWrapper.h
//  muzzik
//
//  Created by muzzik on 16/1/27.
//  Copyright © 2016年 muzziker. All rights reserved.
//

#import <Foundation/Foundation.h>
#define CustomErrorDomain @"com.muzzik.error"
typedef enum {
    XDefultFailed = -1000,
    XRegisterFailed,
    XConnectFailed,
    XJsonDataError,
    XTokenUnAuth
}CustomErrorFailed;



typedef void (^QueryMuzziksCompletionBlock)(NSDictionary * responseDic, NSError *error);


@interface HttpWrapper : NSObject
/**
 *  muzzik数据流请求接口。
 *
 *  @param lastId     最后一条muziik的索引Id，传入nil则默认取最新的
 *  @param completion 网络请求后返回的数据block
 */
+(void)getSuqareListByLastid:(NSString *)lastId completion:(QueryMuzziksCompletionBlock) completion;

+(void)getFeedListByLastid:(NSString *)lastId completion:(QueryMuzziksCompletionBlock) completion;


@end
