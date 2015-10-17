//
//  CommentTableVC.h
//  muzzik
//
//  Created by muzzik on 15/5/7.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserMuzzikVC.h"
#import "AMScrollingNavbarViewController.h"
@interface CommentTableVC :AMScrollingNavbarViewController
@property (nonatomic,copy)NSString *uid;
@property(nonatomic,weak) UserMuzzikVC *keeper;
- (void)viewDidCurrentView;
@end
