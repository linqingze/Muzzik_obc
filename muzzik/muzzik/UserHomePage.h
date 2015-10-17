//
//  UserHomePage.h
//  muzzik
//
//  Created by muzzik on 15/5/4.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMScrollingNavbarViewController.h"
@interface UserHomePage : AMScrollingNavbarViewController
@property (nonatomic,retain)UIImageView *headimage;
@property (nonatomic,retain) NSMutableDictionary *profileDic;
@end
