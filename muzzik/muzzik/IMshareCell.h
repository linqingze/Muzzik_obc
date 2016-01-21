//
//  IMshareCell.h
//  muzzik
//
//  Created by muzzik on 16/1/21.
//  Copyright © 2016年 muzziker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Message.h"
#import "IMConversationViewcontroller.h"

@interface IMshareCell : UITableViewCell
@property (nonatomic,retain) UIButton *headImage;
@property (nonatomic,retain) UIImageView *timelineImage;
@property (nonatomic,retain) UILabel *timeLabel;
@property (nonatomic,retain) UIView *messageView;

@property (nonatomic,retain) Message *cellMessage;
@property (nonatomic,retain) UIButton *muzzikUserHeader;
@property (nonatomic,retain) UILabel *artistNamel;
@property (nonatomic,retain) UILabel *songName;
@property (nonatomic,retain) UITapGestureRecognizer *tap;
@property (nonatomic,retain) UILongPressGestureRecognizer *longPress;
@property (nonatomic,retain) muzzik *playMuzzik;
@property (nonatomic,weak) IMConversationViewcontroller *imvc;

@property (nonatomic,retain) UIActivityIndicatorView *activityView;
@property (nonatomic,retain) UIButton *resendButton;


-(void) configureCellWithMessage:(Message *) message;
@end
