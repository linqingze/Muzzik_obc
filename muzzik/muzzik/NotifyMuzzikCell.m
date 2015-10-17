//
//  NotifyMuzzikCell.m
//  muzzik
//
//  Created by muzzik on 15/5/18.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "NotifyMuzzikCell.h"

@implementation NotifyMuzzikCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
        
    }
    return self;
}
-(void)setup{
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    self.preImage = [[UIImageView alloc] initWithFrame:CGRectMake(8, 31, 10, 10)];
    //类型标志图标
    //[self addSubview:self.preImage];
    _headImage = [[UIButton alloc] initWithFrame:CGRectMake(23, 16, 40, 40)];
    _headImage.layer.cornerRadius = 20;
    _headImage.clipsToBounds = YES;
    [_headImage addTarget:self action:@selector(goToUser) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_headImage];
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(73, 16, SCREEN_WIDTH-100, 20)];
    [self addSubview:_nameLabel];
    _message = [[UILabel alloc] initWithFrame:CGRectMake(73, 41, SCREEN_WIDTH-100, 15)];
    [_message setTextColor:Color_Text_2];
    [_message setFont:[UIFont fontWithName:Font_Next_DemiBold size:14]];
    [self addSubview: _message];
    _messageView = [[UIView alloc] initWithFrame:CGRectMake(73, 66, SCREEN_WIDTH-106, 61)];
    _messageView.layer.cornerRadius =3;
    _messageView.clipsToBounds = YES;
    [_messageView setBackgroundColor:Color_line_2];
    [self addSubview: _messageView];
    _commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, _messageView.frame.size.width-10, 20)];
    [_commentLabel setTextColor:Color_Text_2];
    [_commentLabel setFont:[UIFont fontWithName:Font_Next_medium size:12]];
    [_messageView addSubview: _commentLabel];
    
    _songname = [[UILabel alloc] initWithFrame:CGRectMake(5, 21, _messageView.frame.size.width, 15)];
    [_songname setTextColor:Color_Action_Button_1];
    [_songname setFont:[UIFont boldSystemFontOfSize:12]];
    [_messageView addSubview: _songname];
    
    _artist = [[UILabel alloc] initWithFrame:CGRectMake(5, 40, _messageView.frame.size.width, 15)];
    [_artist setTextColor:Color_Action_Button_1];
    [_artist setFont:[UIFont boldSystemFontOfSize:10]];
    [_messageView addSubview: _artist];
    
    _lineView = [[UIView alloc] initWithFrame:CGRectMake(23, 151, SCREEN_WIDTH-46, 1)];
    [_lineView setBackgroundColor:Color_line_1];
    [self addSubview:_lineView];
}
-(void)goToUser{
    [self.delegate userDetail:self.user_id];
}
@end
