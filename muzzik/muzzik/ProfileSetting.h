//
//  ProfileSetting.h
//  muzzik
//
//  Created by muzzik on 15/5/7.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "UserHomePage.h"
@interface ProfileSetting : AMScrollingNavbarViewController
@property (nonatomic,retain) NSMutableDictionary *profileDic;
@property (nonatomic,weak) UserHomePage *userhome;
@end
