//
//  HttpWrapper.m
//  muzzik
//
//  Created by muzzik on 16/1/27.
//  Copyright © 2016年 muzziker. All rights reserved.
//

#import "HttpWrapper.h"
#import "AFNetworking.h"
@implementation HttpWrapper


+(void)getFeedListByLastid:(NSString *)lastId completion:(QueryMuzziksCompletionBlock)completion{
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:BaseURL]];
    NSDictionary *reqDic;
    if (lastId) {
        reqDic = [NSDictionary dictionaryWithObjectsAndKeys:lastId,Parameter_from,Limit_Constant,Parameter_Limit, nil];
    }else{
        reqDic = [NSDictionary dictionaryWithObjectsAndKeys:Limit_Constant,Parameter_Limit, nil];
    }
    [manager GET:@"api/muzzik/feeds" parameters:reqDic progress:NULL success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if(![responseObject isKindOfClass:[NSDictionary class]] || !responseObject){
            completion(nil,[NSError errorWithDomain:CustomErrorDomain code:XJsonDataError userInfo:[NSDictionary dictionaryWithObject:@"json Data format error"                                                                      forKey:NSLocalizedDescriptionKey]]);
        }else if([responseObject isKindOfClass:[NSDictionary class]]){
            completion(responseObject,nil);
        }else{
            NSLog(@"data error :%@",responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil,[NSError errorWithDomain:CustomErrorDomain code:XConnectFailed userInfo:[NSDictionary dictionaryWithObject:@"connect failed"                                                                      forKey:NSLocalizedDescriptionKey]]);
    }];
}
@end
