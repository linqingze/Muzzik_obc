//
//  DraftsCell.m
//  muzzik
//
//  Created by muzzik on 15/6/7.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "DraftsCell.h"

@implementation DraftsCell

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
    _timeImage = [[UIImageView alloc] initWithFrame:CGRectMake(20, 10, 9, 9)];
    [_timeImage setImage:[UIImage imageNamed:Image_timeImage]];
    [self addSubview:_timeImage];
    
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 10, 100, 10)];
    [_timeLabel setTextColor:Color_Additional_5];
    [_timeLabel setFont:[UIFont fontWithName:Font_Next_medium size:9]];
    [self addSubview:_timeLabel];
    
    _message = [[UILabel alloc] initWithFrame:CGRectMake(20, 35, SCREEN_WIDTH-40, 20)];
    [_message setFont:[UIFont systemFontOfSize:Font_Size_Muzzik_Message]];
    [_message setTextColor:Color_Text_2];
    [self addSubview:_message];
    _songview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 60)];
    [self addSubview:_songview];
    _songImage = [[UIImageView alloc] initWithFrame:CGRectMake(13,11, 15, 15)];
    [_songImage setImage:[UIImage imageNamed:@"draftmusicImage"]];
    [_songview addSubview:_songImage];
    
//    UIView *separateLine = [[UIView alloc] initWithFrame:CGRectMake(60, 10, 1, 40)];
//    [separateLine setBackgroundColor:Color_line_1];
//    [_songview addSubview:separateLine];
    
    _songName = [[UILabel alloc] initWithFrame:CGRectMake(20, 11, SCREEN_WIDTH-26, 20)];
    _songName.textColor = Color_Text_2;
    _songName.font = [UIFont fontWithName:Font_Next_Bold size:15];
    [_songview addSubview:_songName];
    
    _Artist = [[UILabel alloc] initWithFrame:CGRectMake(20, 33, SCREEN_WIDTH-26, 20)];
    _Artist.textColor = Color_Text_3;
    _Artist.font = [UIFont fontWithName:Font_Next_Bold size:12];
    [_songview addSubview:_Artist];

    [MuzzikItem addLineOnView:_songview heightPoint:59 toLeft:20 toRight:20 withColor:Color_line_1];

}

@end
