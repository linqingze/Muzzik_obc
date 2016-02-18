//
//  EnterCell.m
//  muzzik
//
//  Created by muzzik on 16/2/15.
//  Copyright © 2016年 muzziker. All rights reserved.
//

#import "EnterCell.h"
#import "Utils_IM.h"
@implementation EnterCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
        
    }
    return self;
}

-(void)setup{
    _timeLabel = [[UILabel alloc] init];
    [_timeLabel setFont:[UIFont fontWithName:Font_Next_Regular size:10]];
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    [_timeLabel setTextColor:Color_Additional_5];
    [_timeLabel setBackgroundColor:[UIColor whiteColor]];
    _timelineImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"timedivideline"]];
    [_timelineImage setFrame:CGRectMake(SCREEN_WIDTH/2-140, 16, 280, 8)];
    _timelineImage.contentMode = UIViewContentModeScaleAspectFit;
    
    _messageLabel = [[UILabel alloc] init];
    [_messageLabel setTextColor:Color_Additional_5];
    _messageLabel.font = [UIFont fontWithName:Font_Next_Regular size:10];
    [_messageLabel setBackgroundColor:Color_line_2];
    _messageLabel.layer.cornerRadius = 5;
    _messageLabel.layer.masksToBounds = YES;
    _messageLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_timelineImage];
    [self addSubview:_timeLabel];
    [self addSubview:_messageLabel];

}

-(void)configureCellWithMessage:(Message *)message{
    self.cellMessage = message;
    CGFloat height = 0;
    if ([message.needsToShowTime boolValue]) {
        [_timelineImage setHidden:NO];
        [_timeLabel setHidden:NO];
        [_timeLabel setBounds:CGRectMake(0, 0, 120, 15)];
        _timeLabel.text = [Utils_IM getStringFromIMDate:message.sendTime];
        CGSize size = [_timeLabel sizeThatFits:CGSizeMake(120, 15)];
        [_timeLabel setFrame:CGRectMake(SCREEN_WIDTH/2 -size.width/2-5, 16,size.width+10, 8)];
        height += 48;
    }else{
        [_timeLabel setHidden:YES];
        [_timelineImage setHidden:YES];
        height+=8;
    }
    [_messageLabel setText:message.messageContent];
    CGSize size = [_messageLabel sizeThatFits:CGSizeMake(SCREEN_WIDTH-60, 15)];
    [_messageLabel setFrame:CGRectMake(SCREEN_WIDTH/2-size.width/2-5, height, size.width+10, size.height+10)];
    
}
@end
