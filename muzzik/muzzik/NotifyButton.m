//
//  NotifyButton.m
//  muzzik
//
//  Created by muzzik on 15/6/27.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "NotifyButton.h"
#import "NotificationCenterViewController.h"
#import "IMConversationViewcontroller.h"
#import "NotificationVC.h"
#import "RDVTabBarItem.h"
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
    [self removeFromSuperview];
    if ([self.targetUserinfo.userId length]>0 || [self.notificationMessage length]>0) {
        AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
        RDVTabBarItem *item = [[[app.tabviewController tabBar] items] objectAtIndex:3];
        UIImage *selectedimage = [UIImage imageNamed:@"tabbarNotification_Selected"];
        UIImage *unselectedimage = [UIImage imageNamed:@"tabbarNotification"];
        [item setFinishedSelectedImage:selectedimage withFinishedUnselectedImage:unselectedimage];
        
        UINavigationController *nac = (UINavigationController *)app.tabviewController.selectedViewController;
        userInfo *user = [userInfo shareClass];
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        
        if (self.notificationType == NotificationType_IM) {
            if ([self.targetUserinfo.userId length]>0) {
                BOOL isContained = NO;
                IMConversationViewcontroller *imVC = [[IMConversationViewcontroller alloc] init];
                imVC.con = [app getConversationByUserInfo:self.targetUserinfo];
                imVC.con.unReadMessage = [NSNumber numberWithInt:0];
                imVC.title = imVC.con.targetUser.name;
                [app.managedObjectContext save:nil];
                
                for (UIViewController *vc in nac.viewControllers) {
                    if ([vc isKindOfClass:[IMConversationViewcontroller class]]) {
                        isContained = YES;
                        break;
                    }
                }
                [app.tabviewController setTabBarHidden:YES animated:YES];
                if (isContained) {
                    NSMutableArray *array = [nac.viewControllers mutableCopy];
                    for (UIViewController *vc in nac.viewControllers) {
                        if ([vc isKindOfClass:[IMConversationViewcontroller class]]) {
                            [array removeObjectAtIndex:[nac.viewControllers indexOfObject:vc]];
                        }
                    }
                    [array addObject:imVC];
                    [nac setViewControllers:array animated:YES];
                }else{
                    [nac pushViewController:imVC animated:YES];
                }
                
            }
        }else{
            [app.tabviewController setSelectedViewController:app.notifyVC];
            app.tabviewController.selectedIndex = 3;
            [app.notifyVC popToRootViewControllerAnimated:YES];
        }
        
        
        
        
        
//        else if (self.notificationType == NotificationType_reply) {
//            
//            NotificationVC *notifyvc = [[NotificationVC alloc] init];
//            notifyvc.title = @"他们回复了你的Muzzik";
//            notifyvc.notifyType = Notification_comment;
//            notifyvc.numOfNewNotification = user.notificationNumReply;
//            user.notificationNumReplyNew = NO;
//            [nac pushViewController:notifyvc animated:YES];
//            [app.tabviewController setTabBarHidden:YES animated:YES];
//            
//            
//        }else if (self.notificationType == NotificationType_moved) {
//            NotificationVC *notifyvc = [[NotificationVC alloc] init];
//            notifyvc.title = @"他们喜欢了你的Muzzik";
//            notifyvc.notifyType = Notification_moved;
//            notifyvc.numOfNewNotification = user.notificationNumMoved;
//            user.notificationNumMovedNew = NO;
//            [nac pushViewController:notifyvc animated:YES];
//            [app.tabviewController setTabBarHidden:YES animated:YES];
//        }else if (self.notificationType == NotificationType_at) {
//            
//            NotificationVC *notifyvc = [[NotificationVC alloc] init];
//            notifyvc.title = @"他们提到了你";
//            notifyvc.notifyType = Notification_at;
//            notifyvc.numOfNewNotification = user.notificationNumMetion;
//            user.notificationNumMetionNew = NO;
//            [nac pushViewController:notifyvc animated:YES];
//            [app.tabviewController setTabBarHidden:YES animated:YES];
//        }else if (self.notificationType == NotificationType_follow) {
//            
//            
//            
//            NotificationVC *notifyvc = [[NotificationVC alloc] init];
//            notifyvc.title = @"他们关注了你";
//            notifyvc.notifyType = Notification_follow;
//            notifyvc.numOfNewNotification = user.notificationNumFollow;
//            user.notificationNumFollowNew = NO;
//            [nac pushViewController:notifyvc animated:YES];
//            [app.tabviewController setTabBarHidden:YES animated:YES];
//            
//        }else if (self.notificationType == NotificationType_repost) {
//            
//            
//            NotificationVC *notifyvc = [[NotificationVC alloc] init];
//            notifyvc.title = @"他们转发了你的Muzzik";
//            notifyvc.notifyType = Notification_repost;
//            notifyvc.numOfNewNotification = user.notificationNumRepost;
//            user.notificationNumRepostNew = NO;
//            [nac pushViewController:notifyvc animated:YES];
//            [app.tabviewController setTabBarHidden:YES animated:YES];
//        }else if (self.notificationType == NotificationType_topic) {
//            
//            NotificationVC *notifyvc = [[NotificationVC alloc] init];
//            notifyvc.title = @"他们参与了你的话题";
//            notifyvc.notifyType = Notification_participation;
//            notifyvc.numOfNewNotification = user.notificationNumParticipationTopic;
//            user.notificationNumParticipationTopicNew = NO;
//            [nac pushViewController:notifyvc animated:YES];
//            [app.tabviewController setTabBarHidden:YES animated:YES];
//        }

    }
}
@end
