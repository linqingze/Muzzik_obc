//
//  user.h
//  muzzik
//
//  Created by muzzik on 15/4/11.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MuzzikUser : NSObject
@property (nonatomic,copy) NSString *user_id;
@property (nonatomic,copy) NSString *avatar;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *gender;
@property (nonatomic,copy) NSString *descrip;
@property (nonatomic,assign) BOOL isFans;
@property (nonatomic,assign) BOOL isFollow;
-(NSMutableArray*)makeMuzziksByUserArray:(NSMutableArray *)array;
@end
