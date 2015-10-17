//
//  MuzzikNoCardCell.m
//  muzzik
//
//  Created by muzzik on 15/5/2.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "MuzzikNoCardCell.h"

@implementation MuzzikNoCardCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
        
    }
    return self;
}

-(void)setup{
    CGFloat ScreenWidth = SCREEN_WIDTH;
    [self setBackgroundColor:[UIColor whiteColor]];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    self.muzzikCardLogo = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 28)];
    [self.muzzikCardLogo setImage:[UIImage imageNamed:Image_nopictweetImage]];
    self.cardTitle = [[UILabel alloc] initWithFrame:CGRectMake(32, 0, ScreenWidth-80, 28)];
    [self.cardTitle setFont:[UIFont boldSystemFontOfSize:10]];
    [self.cardTitle setTextColor:Color_Text_1];
    
    self.userImage = [[UIButton alloc] initWithFrame:CGRectMake( 32, 28, 50, 50)];
    self.userImage.layer.cornerRadius = 25;
    self.userImage.clipsToBounds = YES;
    [_userImage addTarget:self action:@selector(goToUser) forControlEvents:UIControlEventTouchUpInside];
    self.userName = [[UILabel alloc] initWithFrame:CGRectMake(90, 43, ScreenWidth-180, 20)];
    [self.userName setFont:[UIFont boldSystemFontOfSize:16]];
    [self.userName setTextColor:Color_Text_1];
    
    _timeStamp = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth-145, 43, 60, 10)];
    [_timeStamp setFont:[UIFont systemFontOfSize:8.0]];
    _timeStamp.textAlignment = NSTextAlignmentRight;
    [_timeStamp setTextColor:Color_Additional_5];
    
    _timeImage = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth-76, 43, 9, 9)];
    [_timeImage setImage:[UIImage imageNamed:Image_timeImage]];
    _muzzikMessage = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(32, CGRectGetMaxY(_userImage.frame)+10, ScreenWidth-96, 200)];
    [_muzzikMessage setTextColor:Color_Text_2];
    [_muzzikMessage setFont:[UIFont systemFontOfSize:Font_Size_Muzzik_Message]];
    _musicPlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0 , ScreenWidth-16, 70)];
    [self.contentView addSubview:_musicPlayView];
    _progress = [[UIProgressView alloc] initWithFrame:CGRectMake(32, 0, ScreenWidth-96, 2)];
    [_progress setProgress:1];
    [_musicPlayView addSubview:_progress];
    _musicName = [[UILabel alloc] initWithFrame:CGRectMake(80, 10, ScreenWidth-192, 25)];
    [_musicName setFont:[UIFont fontWithName:Font_Next_Bold size:15]];
    [_musicPlayView addSubview:_musicName];
    _musicArtist = [[UILabel alloc] initWithFrame:CGRectMake(80, 35, ScreenWidth-192, 25)];
    [_musicArtist setFont:[UIFont fontWithName:Font_Next_Bold size:12]];
    [_musicPlayView addSubview:_musicArtist];
    _likeButton = [[UIButton alloc] initWithFrame:CGRectMake(32,17 , 36, 36)];
    [_likeButton addTarget:self action:@selector(moveAction) forControlEvents:UIControlEventTouchUpInside];
    
    [_musicPlayView addSubview:_likeButton];
    
    _playButton = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth-102, 17, 36, 36)];
    
    [_playButton addTarget:self action:@selector(playMusicAction:) forControlEvents:UIControlEventTouchUpInside];
    [_musicPlayView addSubview:_playButton];
    _cardView = [[UIView alloc] initWithFrame:CGRectMake(16, 8, SCREEN_WIDTH-16, 200)];
    [_cardView setBackgroundColor:Color_line_2];
    _cardView.layer.cornerRadius = 2;
    _cardView.clipsToBounds = YES;
    
    [_cardView addSubview:_muzzikCardLogo];
    [_cardView addSubview:_cardTitle];
    [_cardView addSubview:_userImage];
    [_cardView addSubview:_userName];
    [_cardView addSubview:_timeImage];
    [_cardView addSubview:_timeStamp];
    [_cardView addSubview:_muzzikMessage];
    [_cardView addSubview:_musicPlayView];
    [self addSubview:_cardView];
    
    
}
-(void)playMusicAction:(id) sender{
    NSLog(@"play");
    [self.delegate playSongWithSongModel:self.songModel];
}
-(void) colorViewWithColorString:(NSString *) colorString{
    UIColor *color;
    if ([colorString isEqualToString:@"2"]) {
        color = [UIColor colorWithHexString:@"fea42c"];
        if (self.isMoved) {
            [self.likeButton setImage:[UIImage imageNamed:@"yellowlikedImage"] forState:UIControlStateNormal];
        }else{
            [self.likeButton setImage:[UIImage imageNamed:@"yellowlikeImage"] forState:UIControlStateNormal];
        }
        if (self.isPlaying) {
            [self.playButton setImage:[UIImage imageNamed:@"yellowstopImage"] forState:UIControlStateNormal];
        }else{
            [self.playButton setImage:[UIImage imageNamed:@"yellowplayImage"] forState:UIControlStateNormal];
        }
    }
    else if([colorString isEqualToString:@"3"]){
        //bluelikeImage
        color = [UIColor colorWithHexString:@"04a0bf"];
        if (self.isMoved) {
            [self.likeButton setImage:[UIImage imageNamed:@"bluelikedImage"] forState:UIControlStateNormal];
        }else{
            [self.likeButton setImage:[UIImage imageNamed:@"bluelikeImage"] forState:UIControlStateNormal];
        }
        if (self.isPlaying) {
            [self.playButton setImage:[UIImage imageNamed:@"bluestopImage"] forState:UIControlStateNormal];
        }else{
            [self.playButton setImage:[UIImage imageNamed:@"blueplayImage"] forState:UIControlStateNormal];
        }
    }
    else{
        color = [UIColor colorWithHexString:@"f26d7d"];
        if (self.isMoved) {
            [self.likeButton setImage:[UIImage imageNamed:@"redlikedImage"] forState:UIControlStateNormal];
        }else{
            [self.likeButton setImage:[UIImage imageNamed:@"redlikeImage"] forState:UIControlStateNormal];
        }
        if (self.isPlaying) {
            [self.playButton setImage:[UIImage imageNamed:@"redstopImage"] forState:UIControlStateNormal];
        }else{
            [self.playButton setImage:[UIImage imageNamed:@"redplayImage"] forState:UIControlStateNormal];
        }
    }
    [_progress setTintColor:color];
    [_musicArtist setTextColor:color];
    [_musicName setTextColor:color];
}
-(void)moveAction{
    NSLog(@"move");
    [self.delegate moveMuzzik:self.songModel];
}
-(void)goToUser{
    [self.delegate userDetail:self.songModel.MuzzikUser.user_id];
}

@end
