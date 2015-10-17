//
//  NotifyButton.m
//  muzzik
//
//  Created by muzzik on 15/6/27.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "NotifyButton.h"
#import "NotificationCenterViewController.h"

@implementation NotifyButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self addTarget:self action:@selector(showNotify) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}
-(void)showNotify{
    [self setHidden:YES];
//    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
//    UINavigationController *nac = (UINavigationController *)app.window.rootViewController;
//    
//    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
//    if ([[nac.viewControllers lastObject] isKindOfClass:[NotificationCenterViewController class]]) {
//        NotificationCenterViewController *notifyVC = (NotificationCenterViewController *)[nac.viewControllers lastObject];
//        [notifyVC checkNewNotification];
//        
//    }else{
//        NotificationCenterViewController *notifyVC = [[NotificationCenterViewController alloc] init];
//        [nac pushViewController:notifyVC animated:YES];
//    }
    
}
@end
