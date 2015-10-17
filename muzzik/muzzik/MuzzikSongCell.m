//
//  MuzzikSongCell.m
//  muzzik
//
//  Created by muzzik on 15/7/29.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "MuzzikSongCell.h"

@implementation MuzzikSongCell
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
    _cardView = [[UIView alloc] initWithFrame:CGRectMake(8, 23, SCREEN_WIDTH-16, 80)];
    [_cardView setBackgroundColor:Color_line_2];
    _cardView.layer.cornerRadius = 3;
    _cardView.clipsToBounds = YES;
    [self addSubview:_cardView];
    _MusicCardLogo = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 28)];
    [_MusicCardLogo setImage:[UIImage imageNamed:@"hotmusicImage"]];
    [_cardView addSubview:_MusicCardLogo];
    _cardTitle = [[UILabel alloc] initWithFrame:CGRectMake(30, 4, SCREEN_WIDTH-100, 20)];
    [_cardTitle setFont:[UIFont boldSystemFontOfSize:11]];
    [_cardTitle setTextColor:Color_Text_1];
    [_cardView addSubview:_cardTitle];
    
    _musicName = [[UILabel alloc] initWithFrame:CGRectMake(30, 31, SCREEN_WIDTH-110, 18)];
    [_musicName setFont:[UIFont boldSystemFontOfSize:14]];
    [_musicName setTextColor:Color_Text_2];
    [_cardView addSubview:_musicName];
    
    _musicArtist = [[UILabel alloc] initWithFrame:CGRectMake(30, 53, SCREEN_WIDTH-110, 18)];
    [_musicArtist setFont:[UIFont boldSystemFontOfSize:12]];
    [_musicArtist setTextColor:Color_Text_2];
    [_cardView addSubview:_musicArtist];
    
    _NewMuzzikButton = [[UIButton alloc] initWithFrame:CGRectMake(_cardView.frame.size.width-72, 31, 36, 36)];
    [_NewMuzzikButton setImage:[UIImage imageNamed:Image_songlistpostweetImage] forState:UIControlStateNormal];
    [_NewMuzzikButton addTarget:self action:@selector(newMuzzik) forControlEvents:UIControlEventTouchUpInside];
    [_cardView addSubview:_NewMuzzikButton];
    
    _playButton = [[UIButton alloc] initWithFrame:CGRectMake(_cardView.frame.size.width-36, 31, 36, 36)];
    [_playButton setImage:[UIImage imageNamed:Image_playgreyImage] forState:UIControlStateNormal];
    [_playButton addTarget:self action:@selector(playMusic) forControlEvents:UIControlEventTouchUpInside];
    [_cardView addSubview:_playButton];
    
}
-(void)newMuzzik{
    MuzzikObject *mobject = [MuzzikObject shareClass];
    mobject.music = self.songModel.music;
   // [MuzzikItem getLyricByMusic:self.songModel.music];
    [self.delegate newMuzzik:self.songModel];
}
-(void)playMusic{
    [self.delegate playSongWithSongModel:self.songModel];
}
@end
