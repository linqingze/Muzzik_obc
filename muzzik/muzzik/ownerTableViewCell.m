//
//  ownerTableViewCell.m
//  muzzik
//
//  Created by muzzik on 16/1/6.
//  Copyright © 2016年 muzziker. All rights reserved.
//

#import "ownerTableViewCell.h"
#import "Utils_IM.h"
@implementation ownerTableViewCell
#define Message_size 15

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
        
    }
    return self;
}
-(void)setup{
    _headImage = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
    _headImage.layer.cornerRadius = 17.5;
    _headImage.layer.masksToBounds = YES;
    _timeLabel = [[UILabel alloc] init];
    [_timeLabel setFont:[UIFont fontWithName:Font_Next_Regular size:8]];
    [_timeLabel setTextColor:Color_Text_3];
    [_timeLabel setBackgroundColor:[UIColor whiteColor]];
    _timelineImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"timedivideline"]];
    [_timelineImage setFrame:CGRectMake(SCREEN_WIDTH/2-140, 16, 280, 8)];
    _timelineImage.contentMode = UIViewContentModeScaleAspectFill;
    _messageLabel = [[UILabel alloc] init];
    [_messageLabel setFont:[UIFont fontWithName:Font_Next_Regular size:Message_size]];
    _messageLabel.textAlignment = NSTextAlignmentCenter;
    _messageLabel.layer.cornerRadius = 5;
    _messageLabel.layer.masksToBounds = YES;
    [self addSubview:_headImage];
    [self addSubview:_timelineImage];
    [self addSubview:_timeLabel];
    [self addSubview:_messageLabel];
    
    
}
-(CGFloat) configureCellWithMessage:(Message *) message{
    CGFloat height = 0;
    if (message.needsToShowTime) {
        [_timelineImage setHidden:NO];
        [_timeLabel setHidden:NO];
        [_timeLabel setBounds:CGRectMake(0, 0, 120, 15)];
        _timeLabel.text = [Utils_IM getStringFromIMDate:message.sendTime];
        [_timeLabel sizeToFit];
        [_timeLabel setFrame:CGRectMake(SCREEN_WIDTH/2 - _timeLabel.frame.size.width/2-5, 16, _timeLabel.frame.size.width+10, 8)];
        height += 40;
    }else{
        height+=16;
    }
    
    [_messageLabel setFrame:CGRectMake(0, 0, SCREEN_WIDTH-126, 1000)];
    _messageLabel.text = message.messageContent;
    [_messageLabel sizeToFit];
    
    if (message.isOwner) {
       [_headImage setFrame:CGRectMake(13, height, 35, 35)];
        [_messageLabel setFrame:CGRectMake(58, height, _messageLabel.frame.size.width+10, _messageLabel.frame.size.height-Message_size+35)];
    }else{
        [_headImage setFrame:CGRectMake(SCREEN_WIDTH-48, height, 35, 35)];
        [_messageLabel setFrame:CGRectMake(SCREEN_WIDTH-68-_messageLabel.frame.size.width, height, _messageLabel.frame.size.width+10, _messageLabel.frame.size.height-Message_size+35)];
    }
    
    
    return height+_messageLabel.frame.size.height;
}
@end
