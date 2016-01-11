//
//  NotificationCategoryCell.h
//  muzzik
//
//  Created by muzzik on 15/9/8.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "badgeImageView.h"
#import "UIImageView+WebCache.h"
@interface NotificationCategoryCell : UITableViewCell
@property (nonatomic,retain) UIImageView *titleImage;
@property (nonatomic,retain) UILabel *nameLabel;
@property (nonatomic,retain) UILabel *messageLabel;
@property (nonatomic,retain) badgeImageView *badgeImage;
@property (nonatomic,retain) UILabel *timeLabel;
@end
