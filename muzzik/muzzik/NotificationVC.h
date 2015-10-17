//
//  NotificationVC.h
//  muzzik
//
//  Created by muzzik on 15/5/4.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMScrollingNavbarViewController.h"
@interface NotificationVC : AMScrollingNavbarViewController
-(void)loadDataMessage;
@property (nonatomic,assign) NSInteger notifyType;
@property (nonatomic,assign) NSInteger numOfNewNotification;
@end
