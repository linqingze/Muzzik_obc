//
//  NotificationCategoryCell.h
//  muzzik
//
//  Created by muzzik on 15/9/8.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "badgeImageView.h"
@interface NotificationCategoryCell : UITableViewCell
@property (nonatomic,retain) UIImageView *titleImage;
@property (nonatomic,retain) UILabel *decriptionLabel;
@property (nonatomic,retain) badgeImageView *badgeImage;
@end
