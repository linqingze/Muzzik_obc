//
//  MuzzikRequestCenter.h
//  muzzik
//
//  Created by muzzik on 15/8/11.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MuzzikRequestCenter : NSObject
@property(nonatomic,copy) NSString *subUrlString;
@property(nonatomic,assign) BOOL isPage;
@property(nonatomic,copy) NSDictionary *requestDic;
@property(nonatomic,assign) NSUInteger page;
@property(nonatomic,copy) NSString *lastId;
@property(nonatomic,assign) NSUInteger MuzzikType;
@property (nonatomic,assign) BOOL singleMusic;
@property (nonatomic,assign) BOOL IsSongList;
+(MuzzikRequestCenter *) shareClass;
-(void)requestToAddMoreMuzziks:(NSMutableArray *)orginalArray;
-(void)clearObject;
@end
