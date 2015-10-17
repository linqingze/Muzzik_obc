//
//  showUserVC.h
//  muzzik
//
//  Created by muzzik on 15/5/2.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//


@interface showUserVC : AMScrollingNavbarViewController
@property (nonatomic,copy) NSString *showType;
@property (nonatomic,copy) NSString *muzzik_id;
@property (nonatomic,retain) NSMutableArray *userArray;
@end
