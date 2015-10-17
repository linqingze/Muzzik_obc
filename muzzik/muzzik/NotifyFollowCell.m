//
//  NotifyFollowCell.m
//  muzzik
//
//  Created by muzzik on 15/5/18.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "NotifyFollowCell.h"

@implementation NotifyFollowCell

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
    //[self addSubview:self.preImage];
    _headImage = [[UIImageView alloc] initWithFrame:CGRectMake(23, 16, 40, 40)];
    _headImage.layer.cornerRadius = 20;
    _headImage.clipsToBounds = YES;
    [self addSubview:_headImage];
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(73, 16, SCREEN_WIDTH-100, 20)];
    [self addSubview:_nameLabel];
    _message = [[UILabel alloc] initWithFrame:CGRectMake(73, 41, SCREEN_WIDTH-100, 15)];
    [_message setTextColor:Color_Text_2];
    [_message setFont:[UIFont fontWithName:Font_Next_DemiBold size:14]];
    [self addSubview: _message];
    _lineView = [[UIView alloc] initWithFrame:CGRectMake(23, 71, SCREEN_WIDTH-46, 1)];
    [_lineView setBackgroundColor:Color_line_1];
    [self addSubview:_lineView];
}
-(void)goToUser{
    [self.delegate userDetail:self.user_id];
}
@end
