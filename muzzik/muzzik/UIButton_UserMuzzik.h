//
//  UIButton_UserMuzzik.h
//  muzzik
//
//  Created by muzzik on 15/5/25.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton_UserMuzzik : UIButton
@property (nonatomic, retain) MuzzikUser *user;
@property (nonatomic, copy) NSString *followType;
@end
