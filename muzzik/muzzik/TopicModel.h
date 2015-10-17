//
//  TopicModel.h
//  muzzik
//
//  Created by muzzik on 15/4/27.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TopicModel : NSObject
@property(nonatomic,copy) NSString *tid;
@property(nonatomic,retain) MuzzikUser *lastPoster;
@property(nonatomic,copy) NSString *updateTime;
@property(nonatomic,copy) NSString *name;
@property(nonatomic,copy) NSString *lastRank;
@property(nonatomic,copy) NSString *rank;
@property(nonatomic,copy) NSString *amount;
@property(nonatomic,copy) NSString *color;
-(NSMutableArray*)makeTopicssByMuzzikArray:(NSMutableArray *)array;
@end
