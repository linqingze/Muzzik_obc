//
//  NormalCell.m
//  muzzik
//
//  Created by 林清泽 on 15/3/4.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "NormalCell.h"
#import "appConfiguration.h"
@implementation NormalCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
        
    }
    return self;
}
-(void)setup{
    [self setBackgroundColor:[UIColor whiteColor]];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    _userImage = [[UIButton alloc] initWithFrame:CGRectMake(16, 36, 50, 50)];
    [_userImage addTarget:self action:@selector(goToUser) forControlEvents:UIControlEventTouchUpInside];
    _userImage.layer.cornerRadius = 25;
    _userImage.layer.masksToBounds = YES;
    //    _userImage.layer.borderColor = [UIColor whiteColor].CGColor;
    //    _userImage.layer.borderWidth = 2.0f;
    [self addSubview:_userImage];
    _repostImage = [[UIImageView alloc] initWithFrame:CGRectMake(66, 39, 8, 8)];
    [self addSubview:_repostImage];
    _repostUserName = [[UILabel alloc] initWithFrame:CGRectMake(80, 38, 150, 10)];
    [_repostUserName setTextColor:Color_Additional_5];
    [_repostUserName setFont:[UIFont fontWithName:Font_Next_DemiBold size:9]];
    [self addSubview:_repostUserName];
    
    _songModel = [muzzik new];
    _timeStamp = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-130, 15, 96, 9)];
    [_timeStamp setTextColor:Color_Additional_5];
    [_timeStamp setFont:[UIFont fontWithName:Font_Next_medium size:9]];
    _timeStamp.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:_timeStamp];
    _timeImage = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-30, 15, 9, 9)];
    [_timeImage setImage:[UIImage imageNamed:Image_timeImage]];
    [self.contentView addSubview:_timeImage];
    
    _privateImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [_privateImage setImage:[UIImage imageNamed:Image_detailinvisibleImage]];
    [_privateImage setHidden:YES];
    [self addSubview:_privateImage];
    
    _userName = [[UILabel alloc] initWithFrame:CGRectMake(80, 55, SCREEN_WIDTH-120, 20)];
    //  [_userName setTextColor:Color_LightGray];
    [_userName setFont:[UIFont fontWithName:Font_Next_DemiBold size:Font_size_userName]];
    [_userName setTextColor:Color_Text_1];
    [self.contentView addSubview:_userName];
    _muzzikMessage = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake( 80, 83, SCREEN_WIDTH-110, 2000)];
    [_muzzikMessage setTextColor:Color_Text_2];
    [_muzzikMessage setFont:[UIFont systemFontOfSize:Font_Size_Muzzik_Message]];
    [self.contentView addSubview:_muzzikMessage];
    _musicPlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 75, SCREEN_WIDTH, 165)];
    [_musicPlayView setBackgroundColor:[UIColor whiteColor]];
    [self.contentView addSubview:_musicPlayView];
    _progress = [[UIProgressView alloc] initWithFrame:CGRectMake(16, 0, SCREEN_WIDTH-32, 1)];
    [_progress setProgress:1];
    [_musicPlayView addSubview:_progress];
    _musicName = [[UILabel alloc] initWithFrame:CGRectMake(80, 15, SCREEN_WIDTH-150, 20)];
    [_musicName setFont:[UIFont fontWithName:Font_Next_Bold size:15]];
    [_musicPlayView addSubview:_musicName];
    _musicArtist = [[UILabel alloc] initWithFrame:CGRectMake(80, 36, SCREEN_WIDTH-150, 25)];
    [_musicArtist setFont:[UIFont fontWithName:Font_Next_Bold size:12]];
    [_musicPlayView addSubview:_musicArtist];
    _likeButton = [[UIButton alloc] initWithFrame:CGRectMake(19, 17, 36, 36)];
    [_likeButton addTarget:self action:@selector(moveAction) forControlEvents:UIControlEventTouchUpInside];
    [_musicPlayView addSubview:_likeButton];
    
    _playButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-53, 17, 36, 36)];

    [_playButton addTarget:self action:@selector(playMusicAction:) forControlEvents:UIControlEventTouchUpInside];
    [_musicPlayView addSubview:_playButton];
    
    _upperLine = [[UIImageView alloc] initWithFrame:CGRectMake((int)SCREEN_WIDTH/8, 70, SCREEN_WIDTH*3/4, 1)];
    [_upperLine setImage:[UIImage imageNamed:Image_lineImage]];
    [_musicPlayView addSubview:_upperLine];
    
    
    
    
    _moves = [[UIButton alloc] initWithFrame:CGRectMake((int)((SCREEN_WIDTH)/8.0), _upperLine.frame.origin.y, (int)((SCREEN_WIDTH*3)/16.0), 40)];
    [_moves setTitle:@"喜欢数" forState:UIControlStateNormal];
    [_moves setTitleColor:Color_Additional_5 forState:UIControlStateNormal];
    [_moves.titleLabel setFont:[UIFont systemFontOfSize:10]];
    [_moves addTarget:self action:@selector(pushMove) forControlEvents:UIControlEventTouchUpInside];
    _moves.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_musicPlayView addSubview:_moves];
    
    _reposts = [[UIButton alloc] initWithFrame:CGRectMake((int)((SCREEN_WIDTH*5)/16.0), _upperLine.frame.origin.y, (int)((SCREEN_WIDTH*3)/16.0), 40)];
    [_reposts setTitle:@"转发数" forState:UIControlStateNormal];
    [_reposts setTitleColor:Color_Additional_5 forState:UIControlStateNormal];
    [_reposts.titleLabel setFont:[UIFont systemFontOfSize:10.0]];
    [_reposts addTarget:self action:@selector(pushRepost) forControlEvents:UIControlEventTouchUpInside];
    _reposts.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_musicPlayView addSubview:_reposts];
    
    _shares = [[UIButton alloc] initWithFrame:CGRectMake((int)(SCREEN_WIDTH/2), _upperLine.frame.origin.y, (int)((SCREEN_WIDTH*3)/16.0), 40)];
    [_shares setTitle:@"分享数" forState:UIControlStateNormal];
    [_shares setTitleColor:Color_Additional_5 forState:UIControlStateNormal];
    [_shares.titleLabel setFont:[UIFont systemFontOfSize:10.0]];
    [_shares addTarget:self action:@selector(pushShare) forControlEvents:UIControlEventTouchUpInside];
    _shares.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_musicPlayView addSubview:_shares];
    
    _comments = [[UIButton alloc] initWithFrame:CGRectMake((int)((SCREEN_WIDTH*11)/16.0), _upperLine.frame.origin.y, (int)((SCREEN_WIDTH*3)/16.0), 40)];
    [_comments setTitle:@"评论数" forState:UIControlStateNormal];
    [_comments setTitleColor:Color_Additional_5 forState:UIControlStateNormal];
    [_comments.titleLabel setFont:[UIFont systemFontOfSize:10.0]];
    [_comments addTarget:self action:@selector(pushComment) forControlEvents:UIControlEventTouchUpInside];
    _comments.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_musicPlayView addSubview:_comments];
    
    
    
    
    
    _downLine = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/8, _comments.frame.origin.y+40, SCREEN_WIDTH*3/4, 1)];
    [_downLine setImage:[UIImage imageNamed:Image_lineImage]];
    [_musicPlayView addSubview:_downLine];
    
    _repostButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/8,_downLine.frame.origin.y, SCREEN_WIDTH/4.0, 55)];
    [_repostButton setImage:[UIImage imageNamed:Image_retweetImage] forState:UIControlStateNormal];
    [_repostButton addTarget:self action:@selector(repostAction) forControlEvents:UIControlEventTouchUpInside];
    [_musicPlayView addSubview:_repostButton];
    //[_repostButton setBackgroundColor:Color_Additional_4];
    _shareButton = [[UIButton alloc] initWithFrame:CGRectMake((int)SCREEN_WIDTH*3/8,_downLine.frame.origin.y, (int)SCREEN_WIDTH/4.0, 55)];
    [_shareButton setImage:[UIImage imageNamed:Image_shareImage] forState:UIControlStateNormal];
    [_shareButton addTarget:self action:@selector(shareAction) forControlEvents:UIControlEventTouchUpInside];
    [_musicPlayView addSubview:_shareButton];
    
    _commentButton = [[UIButton alloc] initWithFrame:CGRectMake((int)SCREEN_WIDTH*5/8,_downLine.frame.origin.y, (int)SCREEN_WIDTH/4.0, 55)];
    [_commentButton setImage:[UIImage imageNamed:Image_replyImage] forState:UIControlStateNormal];
    [_commentButton addTarget:self action:@selector(commentAction) forControlEvents:UIControlEventTouchUpInside];
    [_musicPlayView addSubview:_commentButton];
    [MuzzikItem addLineOnView:_musicPlayView heightPoint:_downLine.frame.origin.y+54 toLeft:16 toRight:16 withColor:Color_line_1];
}
-(void)downloadMusicAction:(id)sender{
    NSLog(@"download");
    //[self.homeVc downMusicWithModel:self.songModel];
}
-(void)playMusicAction:(id) sender{

    NSLog(@"play");
    [self.delegate playSongWithSongModel:self.songModel];
}
-(void) colorViewWithColorString:(NSString *) colorString{
    self.colorstring = colorString;
    UIColor *color;
    if ([colorString isEqualToString:@"2"]) {
        color = [UIColor colorWithHexString:@"fea42c"];
        [self.repostImage setImage:[UIImage imageNamed:Image_yellowretweetImage]];
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
        if (self.isReposted) {
            [self.repostButton setImage:[UIImage imageNamed:Image_hottweetyellowretweetImage] forState:UIControlStateNormal];
        }else{
            [self.repostButton setImage:[UIImage imageNamed:Image_hottweetgreyretweetImage] forState:UIControlStateNormal];
        }
    }
    else if([colorString isEqualToString:@"3"]){
        //bluelikeImage
        [self.repostImage setImage:[UIImage imageNamed:Image_blueretweetImage]];
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
        if (self.isReposted) {
            [self.repostButton setImage:[UIImage imageNamed:Image_hottweetblueretweetImage] forState:UIControlStateNormal];
        }else{
            [self.repostButton setImage:[UIImage imageNamed:Image_hottweetgreyretweetImage] forState:UIControlStateNormal];
        }
    }
    else{
        color = [UIColor colorWithHexString:@"f26d7d"];
        [self.repostImage setImage:[UIImage imageNamed:Image_redretweetImage]];
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
        if (self.isReposted) {
            [self.repostButton setImage:[UIImage imageNamed:Image_hottweetredretweetImage] forState:UIControlStateNormal];
        }else{
            [self.repostButton setImage:[UIImage imageNamed:Image_hottweetgreyretweetImage] forState:UIControlStateNormal];
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
-(void)repostAction{
    [self.delegate repostActionWithMuzzik:self.songModel];
    NSLog(@"repost");
}
-(void)shareAction{
    NSLog(@"share");
    [self.delegate shareActionWithMuzzik:self.songModel image:[self.userImage imageForState:UIControlStateNormal] ];
}
-(void)commentAction{
    [self.delegate commentAtMuzzik:self.songModel];
}
-(void)pushComment{
    [self.delegate showComment:self.songModel];
}
-(void)pushMove{
    [self.delegate showMoved:self.muzzik_id];
}
-(void)pushShare{
    [self.delegate showShare:self.muzzik_id];
}
-(void)pushRepost{
    [self.delegate showRepost:self.muzzik_id];
}


-(void)goToUser{
    [self.delegate userDetail:self.songModel.MuzzikUser.user_id];
}
@end
