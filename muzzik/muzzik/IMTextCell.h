//
//  ownerTableViewCell.h
//  muzzik
//
//  Created by muzzik on 16/1/6.
//  Copyright © 2016年 muzziker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Message.h"
#import "IMConversationViewcontroller.h"
#import "YYTextView.h"
@interface IMTextCell : UITableViewCell
@property (nonatomic,retain) UIButton *headImage;
@property (nonatomic,retain) UIImageView *timelineImage;
@property (nonatomic,retain) UILabel *timeLabel;
@property (nonatomic,retain) YYTextView *messageLabel;
@property (nonatomic,retain) UIView *messageView;
@property (nonatomic,retain) Message *cellMessage;
@property (nonatomic,weak) IMConversationViewcontroller *imvc;
@property (nonatomic,retain) UIActivityIndicatorView *activityView;
@property (nonatomic,retain) UIButton *resendButton;

-(void) configureCellWithMessage:(Message *) message;
@end
