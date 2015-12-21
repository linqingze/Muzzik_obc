//
//  SongListCell.m
//  muzzik
//
//  Created by muzzik on 15/5/15.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "SongListCell.h"

@implementation SongListCell

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
    self.timeImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, 33, 60)];
    [self addSubview:self.timeImage];
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, 25, 22, 10)];
    self.timeLabel.textColor = [UIColor whiteColor];
    [self.timeLabel setFont:[UIFont systemFontOfSize:7]];
    [self addSubview:self.timeLabel];
    self.songName = [[UILabel alloc] initWithFrame:CGRectMake(60, 10, SCREEN_WIDTH-150, 20)];
    [self.songName setFont:[UIFont fontWithName:Font_Next_Bold size:14]];
    [self.songName setTextColor:[UIColor colorWithHexString:@"777777"]];
    [self addSubview:self.songName];
    self.Artist = [[UILabel alloc] initWithFrame:CGRectMake(60, 32, SCREEN_WIDTH-150, 20)];
    [self.Artist setFont:[UIFont fontWithName:Font_Next_DemiBold size:12]];
    [self.Artist setTextColor:[UIColor colorWithHexString:@"999999"]];
    [self addSubview:self.Artist];
    self.playButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-48, 0, 40, 60)];
    [self.playButton setImage:[UIImage imageNamed:Image_PlayerplayImage] forState:UIControlStateNormal];
    [self.playButton addTarget:self action:@selector(playAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.playButton];
    
    self.CommentButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-88, 0, 40, 60)];
    [self.CommentButton setImage:[UIImage imageNamed:Image_replyImage] forState:UIControlStateNormal];
    [self.CommentButton addTarget:self action:@selector(CommentAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.CommentButton];
    [MuzzikItem addLineOnView:self heightPoint:59 toLeft:60 toRight:13 withColor:Color_underLine];
    
}


-(void)playAction{
    NSLog(@"play");
    [self.delegate playSongWithSongModel:self.cellMuzzik];
}
-(void)CommentAction{
    [self.delegate newMuzzik:self.cellMuzzik];
    NSLog(@"dele");
}


@end
