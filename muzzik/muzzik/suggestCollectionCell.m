//
//  suggestCollectionCell.m
//  muzzik
//
//  Created by muzzik on 15/5/17.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "suggestCollectionCell.h"

@implementation suggestCollectionCell
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-84)];
        [self.scroll setContentSize:CGSizeMake(SCREEN_WIDTH, SCREEN_WIDTH*2)];
        [self addSubview:self.scroll];
        
        [self.scroll addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickOnCell)]];
        self.muzzikImage = [[UIImageView alloc] initWithFrame:CGRectMake(23, 0, SCREEN_WIDTH-46, SCREEN_WIDTH-46)];
        self.muzzikImage.layer.cornerRadius = 3;
        self.muzzikImage.clipsToBounds = YES;
        [self.scroll addSubview:self.muzzikImage];
        self.playButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-75, 20, 36, 36)];
        self.playButton.layer.cornerRadius = 3;
        self.playButton.clipsToBounds = YES;
        [self.playButton addTarget:self action:@selector(playAction) forControlEvents:UIControlEventTouchUpInside];
        
       // [self.playButton setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.4]];
        [self.scroll addSubview:self.playButton];
        _headImage = [[UIButton alloc] initWithFrame:CGRectMake(23, SCREEN_WIDTH-74, 56, 56)];
        _headImage.layer.cornerRadius = 28;
        _headImage.layer.borderColor = [UIColor whiteColor].CGColor;
        _headImage.layer.borderWidth =2;
        _headImage.clipsToBounds = YES;
        [_headImage addTarget:self action:@selector(goToUser) forControlEvents:UIControlEventTouchUpInside];
        [self.scroll addSubview:_headImage];
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(84, SCREEN_WIDTH-40, SCREEN_WIDTH-140, 17)];
        [_nameLabel setFont:[UIFont boldSystemFontOfSize:Font_size_userName]];
        [_nameLabel setTextColor:Color_Text_1];
        [self.scroll addSubview:_nameLabel];
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-130, SCREEN_WIDTH-35, 94, 9)];
        [_timeLabel setTextColor:Color_Additional_5];
        [_timeLabel setFont:[UIFont fontWithName:Font_Next_medium size:9]];
        _timeLabel.textAlignment = NSTextAlignmentRight;
        [self.scroll addSubview:_timeLabel];
        _timeImage = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-32, SCREEN_WIDTH-35, 9, 9)];
        [_timeImage setImage:[UIImage imageNamed:Image_timeImage]];
        [self.scroll addSubview:_timeImage];
        
        _message = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(23, SCREEN_WIDTH-8, SCREEN_WIDTH-46, 400)];
        [_message setFont:[UIFont systemFontOfSize:Font_Size_Muzzik_Message]];
        [_message setTextColor:Color_Text_2];
        [self.scroll addSubview:_message];
        
        _ActionView  = [[UIView alloc] initWithFrame:CGRectMake(20, SCREEN_HEIGHT-139, SCREEN_WIDTH-40, 55)];
        [_ActionView setBackgroundColor:[UIColor whiteColor]];
        _downLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-50, 1)];
        [_downLine setBackgroundColor:Color_line_1];
        [_ActionView addSubview:_downLine];
        int widthCell = (int)(_ActionView.frame.size.width/4);
        _moveButton = [[UIButton alloc] initWithFrame:CGRectMake(0,0, widthCell, 55)];
        [_moveButton setImage:[UIImage imageNamed:Image_retweetImage] forState:UIControlStateNormal];
        [_moveButton addTarget:self action:@selector(moveAction) forControlEvents:UIControlEventTouchUpInside];
        [_ActionView addSubview:_moveButton];
        
        _repostButton = [[UIButton alloc] initWithFrame:CGRectMake(widthCell,0, widthCell, 55)];
        [_repostButton setImage:[UIImage imageNamed:Image_retweetImage] forState:UIControlStateNormal];
        [_repostButton addTarget:self action:@selector(repostAction) forControlEvents:UIControlEventTouchUpInside];
        [_ActionView addSubview:_repostButton];
        //[_repostButton setBackgroundColor:Color_Additional_4];
        _shareButton = [[UIButton alloc] initWithFrame:CGRectMake(widthCell*2,0, widthCell, 55)];
        [_shareButton setImage:[UIImage imageNamed:Image_shareImage] forState:UIControlStateNormal];
        [_shareButton addTarget:self action:@selector(shareAction) forControlEvents:UIControlEventTouchUpInside];
        [_ActionView addSubview:_shareButton];
        
        _commentButton = [[UIButton alloc] initWithFrame:CGRectMake(widthCell*3,0,widthCell, 55)];
        [_commentButton setImage:[UIImage imageNamed:Image_replyImage] forState:UIControlStateNormal];
        [_commentButton addTarget:self action:@selector(commentAction) forControlEvents:UIControlEventTouchUpInside];
        [_ActionView addSubview:_commentButton];
        [self addSubview:_ActionView];
    }
    return self;
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
    [self.delegate shareActionWithMuzzik:self.songModel image:[self.headImage imageForState:UIControlStateNormal] ];
}
-(void)commentAction{
    [self.delegate commentAtMuzzik:self.songModel];
}

-(void)goToUser{
    [self.delegate userDetail:self.songModel.MuzzikUser.user_id];
}
-(void)clickOnCell{
    NSLog(@"click");
    [self.delegate clickOnCell:self.songModel];
}
-(void)playAction{
    [self.delegate playSongWithSongModel:self.songModel];
}
@end
