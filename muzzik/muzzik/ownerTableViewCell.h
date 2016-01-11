//
//  ownerTableViewCell.h
//  muzzik
//
//  Created by muzzik on 16/1/6.
//  Copyright © 2016年 muzziker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Message.h"
@interface ownerTableViewCell : UITableViewCell
@property (nonatomic,retain) UIButton *headImage;
@property (nonatomic,retain) UIImageView *timelineImage;
@property (nonatomic,retain) UILabel *timeLabel;
@property (nonatomic,retain) UILabel *messageLabel;
-(CGFloat) configureCellWithMessage:(Message *) message;
@end
