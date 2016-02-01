//
//  ListenCell.m
//  muzzik
//
//  Created by muzzik on 16/1/31.
//  Copyright © 2016年 muzziker. All rights reserved.
//

#import "ListenCell.h"

@implementation ListenCell

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
    _headImage = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [_headImage setImage:[UIImage imageNamed:@"frame"] forState:UIControlStateNormal];
    [_headImage addTarget:self action:@selector(showUserInfo) forControlEvents:UIControlEventTouchUpInside];
    _timeLabel = [[UILabel alloc] init];
    [_timeLabel setFont:[UIFont fontWithName:Font_Next_Regular size:10]];
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    [_timeLabel setTextColor:Color_Additional_5];
    [_timeLabel setBackgroundColor:[UIColor whiteColor]];
    _timelineImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"timedivideline"]];
    [_timelineImage setFrame:CGRectMake(SCREEN_WIDTH/2-140, 16, 280, 8)];
    _timelineImage.contentMode = UIViewContentModeScaleAspectFit;
    
    _songName = [[UILabel alloc]  initWithFrame:CGRectMake(10, 40, SCREEN_WIDTH - 156, 17)];
    [_songName setFont:[UIFont fontWithName:Font_Next_medium size:15]];
    [_songName setTextColor:Color_Text_1];
    
    _artistNamel = [[UILabel alloc] initWithFrame:CGRectMake(10, 55, SCREEN_WIDTH - 240, 15)];
    [_artistNamel setFont:[UIFont fontWithName:Font_Next_medium size:12]];
    _artistNamel.textColor = Color_Text_2;

    _messageView = [[UIView alloc] init];
    _messageView.layer.cornerRadius = 5;
    _messageView.layer.masksToBounds = YES;
    _messageView.layer.borderWidth = 1;
    [_messageView addSubview:_songName];
    [_messageView addSubview:_artistNamel];
    UILabel *listenTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 100, 24)];
    listenTextLabel.text = @"Hi,我正在听";
    [listenTextLabel setFont:[UIFont systemFontOfSize:15]];
    [_messageView addSubview:listenTextLabel];
    UIButton *listenButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-133, 10, 50, 24)];
    [listenButton setTitle:@"一起听" forState:UIControlStateNormal];
    [listenButton setBackgroundColor:Color_Additional_4];
    listenButton.layer.cornerRadius = 5;
    listenButton.layer.masksToBounds = YES;
    [listenButton addTarget:self action:@selector(listenTogether) forControlEvents:UIControlEventTouchUpInside];
    [_messageView addSubview:listenButton];

}
-(void  ) configureCellWithMessage:(Message *) message{
    self.cellMessage = message;
    if (message.messageData) {
        _playMuzzik = [[muzzik new] makeMuzziksByMuzzikArray:[NSMutableArray arrayWithArray:@[[NSJSONSerialization JSONObjectWithData:message.messageData options:NSJSONReadingMutableContainers error:nil]]]][0];
        _artistNamel.text = _playMuzzik.music.name;
        _songName.text = _playMuzzik.music.artist;
    }
}
-(void)listenTogether{
    
    if (_playMuzzik) {
        [MuzzikPlayer shareClass].listType = TempList;
        [MuzzikPlayer shareClass].MusicArray =  [NSMutableArray arrayWithArray:@[_playMuzzik]];
        [MuzzikItem SetUserInfoWithMuzziks: [NSMutableArray arrayWithArray:@[_playMuzzik]] title:Constant_userInfo_temp description:[NSString stringWithFormat:@"单曲<%@>",_playMuzzik.music.name]];
        [[MuzzikPlayer shareClass] playSongWithSongModel:_playMuzzik Title:[NSString stringWithFormat:@"单曲<%@>",_playMuzzik.music.name]];
    }
    [self.imvc removeCell:self];
}

@end
