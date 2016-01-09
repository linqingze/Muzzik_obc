//
//  NotificationCenterViewController.h
//  muzzik
//
//  Created by muzzik on 15/9/7.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "AMScrollingNavbarViewController.h"

@interface NotificationCenterViewController : AMScrollingNavbarViewController
@property ( strong, nonatomic) NSManagedObjectContext *managedObjectContext;
-(void)checkNewNotification;
@end
