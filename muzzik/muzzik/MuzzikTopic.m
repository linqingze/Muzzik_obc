//
//  MuzzikTopic.m
//  muzzik
//
//  Created by muzzik on 15/7/29.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "MuzzikTopic.h"

@implementation MuzzikTopic

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
    _cardView = [[UIView alloc] initWithFrame:CGRectMake(8, 23, SCREEN_WIDTH-16, 73)];
    [_cardView setBackgroundColor:Color_line_2];
    _cardView.layer.cornerRadius = 3;
    _cardView.clipsToBounds = YES;
    [self addSubview:_cardView];
    _MusicCardLogo = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 28)];
    [_MusicCardLogo setImage:[UIImage imageNamed:@"topicImage"]];
    [_cardView addSubview:_MusicCardLogo];
    _cardTitle = [[UILabel alloc] initWithFrame:CGRectMake(30, 3, SCREEN_WIDTH-100, 20)];
    [_cardTitle setFont:[UIFont boldSystemFontOfSize:11]];
    [_cardTitle setTextColor:Color_Text_1];
    [_cardView addSubview:_cardTitle];
    
    _TopicLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 25, SCREEN_WIDTH-110, 40)];
    [_TopicLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [_TopicLabel setTextColor:Color_Additional_4];
    [_cardView addSubview:_TopicLabel];
    
    _addtopicButton = [[UIButton alloc] initWithFrame:CGRectMake(_cardView.frame.size.width-65, 27, 50, 36)];
    [_addtopicButton setImage:[UIImage imageNamed:@"addtopicImage"] forState:UIControlStateNormal];
    [_addtopicButton addTarget:self action:@selector(newMuzzik) forControlEvents:UIControlEventTouchUpInside];
    [_cardView addSubview:_addtopicButton];
    
}
-(void)newMuzzik{
    MuzzikObject *mobject = [MuzzikObject shareClass];
    mobject.tempmessage = self.TopicLabel.text;
    [self.delegate newMuzzik:self.songModel];
}
@end
