//
//  NotifyButton.h
//  muzzik
//
//  Created by muzzik on 15/6/27.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotifyButton : UIButton
@property (nonatomic,assign) NotificationType notificationType;
@property (nonatomic,copy) NSString *notificationMessage;
@property (nonatomic,retain) RCUserInfo *targetUserinfo;
@end
