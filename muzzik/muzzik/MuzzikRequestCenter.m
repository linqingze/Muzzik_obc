//
//  MuzzikRequestCenter.m
//  muzzik
//
//  Created by muzzik on 15/8/11.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "MuzzikRequestCenter.h"

@implementation MuzzikRequestCenter
+(MuzzikRequestCenter *) shareClass{
    static MuzzikRequestCenter *myclass=nil;
    if(!myclass){
        myclass = [[super allocWithZone:NULL] init];
    }
    return myclass;
}

+(id)allocWithZone:(NSZone *)zone{
    return [self shareClass];
}
-(void)requestToAddMoreMuzziks:(NSMutableArray *)orginalArray{
    if (!self.singleMusic) {
        if (self.isPage) {
            
            ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :self.subUrlString]];
            [requestForm addBodyDataSourceWithJsonByDic:self.requestDic Method:GetMethod auth:YES];
            __weak ASIHTTPRequest *weakrequest = requestForm;
            [requestForm setCompletionBlock :^{
                NSLog(@"%@",[weakrequest responseString]);
                NSLog(@"%d",[weakrequest responseStatusCode]);
                
                if ([weakrequest responseStatusCode] == 200) {
                    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData]  options:NSJSONReadingMutableContainers error:nil];
                    if (self.MuzzikType == Type_Muzzik_Muzzik) {
                        muzzik *muzzikToy = [muzzik new];
                        NSMutableArray *songarray = [muzzikToy makeMuzziksByMuzzikArray:[dic objectForKey:@"muzziks"]];
                        for (muzzik *localMuzzik in songarray) {
                            BOOL isContained = NO;
                            for (muzzik *originMuzzik in orginalArray) {
                                if ([originMuzzik.muzzik_id isEqualToString:localMuzzik.muzzik_id]) {
                                    isContained = YES;
                                    break;
                                }
                            }
                            if (!isContained) {
                                [orginalArray addObject:localMuzzik];
                            }
                        }
                    }else if(self.MuzzikType == Type_Muzzik_Music){
                        [orginalArray addObjectsFromArray:[[muzzik new] makeMuzziksByMusicArray:[dic objectForKey:@"music"]]];
                    }
                    self.page++ ;
                    NSMutableDictionary *muatDic = [self.requestDic mutableCopy];
                    [muatDic setObject:[NSNumber numberWithInteger:self.page] forKey:Parameter_page];
                    self.requestDic = [muatDic copy];
                    
                }
                else{
                    //[SVProgressHUD showErrorWithStatus:[dic objectForKey:@"message"]];
                }
            }];
            [requestForm setFailedBlock:^{
                NSLog(@"%@",[weakrequest error]);
                
            }];
            [requestForm startAsynchronous];
        }else{
            if ([self.lastId length]>0) {
                ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,self.subUrlString]]];
                [requestForm addBodyDataSourceWithJsonByDic:self.requestDic Method:GetMethod auth:YES];
                __weak ASIHTTPRequest *weakrequest = requestForm;
                [requestForm setCompletionBlock :^{
                    NSLog(@"%@",[weakrequest responseString]);
                    NSLog(@"%d",[weakrequest responseStatusCode]);
                    
                    if ([weakrequest responseStatusCode] == 200) {
                        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData]  options:NSJSONReadingMutableContainers error:nil];
                        if (self.MuzzikType == Type_Muzzik_Muzzik) {
                            muzzik *muzzikToy = [muzzik new];
                            NSMutableArray *songarray = [muzzikToy makeMuzziksByMuzzikArray:[dic objectForKey:@"muzziks"]];
                            for (muzzik *localMuzzik in songarray) {
                                BOOL isContained = NO;
                                for (muzzik *originMuzzik in orginalArray) {
                                    if ([originMuzzik.music.name isEqualToString:localMuzzik.music.name] && [originMuzzik.music.artist isEqualToString:localMuzzik.music.artist]) {
                                        isContained = YES;
                                        break;
                                    }
                                }
                                if (!isContained) {
                                    [orginalArray addObject:localMuzzik];
                                }
                            }
                        }else if(self.MuzzikType == Type_Muzzik_Music){
                            [orginalArray addObjectsFromArray:[[muzzik new] makeMuzziksByMusicArray:[dic objectForKey:@"music"]]];
                        }
                        self.lastId = [dic objectForKey:@"tail"];
                        if ([self.lastId length]>0) {
                            NSMutableDictionary *muatDic = [self.requestDic mutableCopy];
                            [muatDic setObject:self.lastId forKey:Parameter_from];
                            self.requestDic = [muatDic copy];
                        }
                        
                        
                    }
                    else{
                        //[SVProgressHUD showErrorWithStatus:[dic objectForKey:@"message"]];
                    }
                }];
                [requestForm setFailedBlock:^{
                    NSLog(@"%@",[weakrequest error]);
                    
                }];
                [requestForm startAsynchronous];
            }
           
        }
    }
    
}
-(void)clearObject{
    self.isPage = NO;
    self.page = 0;
    self.subUrlString = @"";
    self.singleMusic = NO;
}
@end
