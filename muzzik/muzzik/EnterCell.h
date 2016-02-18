//
//  EnterCell.h
//  muzzik
//
//  Created by muzzik on 16/2/15.
//  Copyright © 2016年 muzziker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Message.h"
@interface EnterCell : UITableViewCell
@property (nonatomic,retain) UIImageView *timelineImage;
@property (nonatomic,retain) UILabel *timeLabel;
@property (nonatomic,retain) UILabel *messageLabel;
@property (nonatomic,retain) Message *cellMessage;

-(void) configureCellWithMessage:(Message *) message;
@end
