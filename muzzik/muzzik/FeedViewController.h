//
//  FeedViewController.h
//  muzzik
//
//  Created by muzzik on 15/6/12.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "AMScrollingNavbarViewController.h"
@class MainMuzzikViewController;
@interface FeedViewController : AMScrollingNavbarViewController
@property (nonatomic,weak) MainMuzzikViewController *keeper;
@property(nonatomic) MuzzikPlayer *musicplayer;

@end
