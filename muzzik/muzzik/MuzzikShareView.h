//
//  MuzzikShareView.h
//  muzzik
//
//  Created by mac on 16/1/17.
//  Copyright © 2016年 muzziker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RDVTabBarController.h"
@interface MuzzikShareView : UIView
@property(nonatomic,weak) muzzik *shareMuzzik;
@property(nonatomic,weak) UIImage *shareImage;
@property(nonatomic,weak) RDVTabBarController *tabbarController;
@property(nonatomic,weak) UIView *cell;
@property (nonatomic,weak) UIViewController *ownerVC;
-(void) showShareView;
-(instancetype)initMyShare;
@end
