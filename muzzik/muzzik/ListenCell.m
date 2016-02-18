//
//  ListenCell.m
//  muzzik
//
//  Created by muzzik on 16/1/31.
//  Copyright © 2016年 muzziker. All rights reserved.
//

#import "ListenCell.h"
#import "Utils_IM.h"
#import "UIButton+WebCache.h"
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
    _listenTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 100, 24)];
    _listenTextLabel.text = @"Hi,我正在听";
    [_listenTextLabel setFont:[UIFont systemFontOfSize:13]];
    [_messageView addSubview:_listenTextLabel];
    _listenButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-210, 10, 50, 24)];
    [_listenButton setTitle:@"一起听" forState:UIControlStateNormal];
    [_listenButton.titleLabel setFont:[UIFont fontWithName:Font_Next_Regular size:12]];
    [_listenButton setBackgroundColor:Color_Additional_4];
    _listenButton.layer.cornerRadius = 3;
    _listenButton.layer.masksToBounds = YES;
    [_listenButton addTarget:self action:@selector(listenTogether) forControlEvents:UIControlEventTouchUpInside];
    [_messageView addSubview:_listenButton];
    [self addSubview:_headImage];
    [self addSubview:_messageView];

}
-(void) configureCellWithMessage:(Message *) message{
    self.cellMessage = message;
    CGFloat height = 0;
    if ([message.needsToShowTime boolValue]) {
        [_timelineImage setHidden:NO];
        [_timeLabel setHidden:NO];
        [_timeLabel setBounds:CGRectMake(0, 0, 120, 15)];
        _timeLabel.text = [Utils_IM getStringFromIMDate:message.sendTime];
        CGSize size = [_timeLabel sizeThatFits:CGSizeMake(120, 15)];
        [_timeLabel setFrame:CGRectMake(SCREEN_WIDTH/2 -size.width/2-5, 16,size.width+10, 8)];
        height += 48;
    }else{
        [_timeLabel setHidden:YES];
        [_timelineImage setHidden:YES];
        height+=8;
    }
    [_listenTextLabel setFrame:CGRectMake(10, 10, 100, 24)];
    [_listenButton setHidden:NO];
    [_headImage setFrame:CGRectMake(13, height, 40, 40)];
    [_messageView setFrame:CGRectMake(63, height, SCREEN_WIDTH-151, 80)];
    [_headImage sd_setBackgroundImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",BaseURL_image,message.messageUser.avatar,Image_Size_Small]] forState:UIControlStateNormal];
    
    if (message.messageData) {
        _playMuzzik = [[muzzik new] makeMuzziksByMusicArray:[NSMutableArray arrayWithArray:@[[NSJSONSerialization JSONObjectWithData:message.messageData options:NSJSONReadingMutableContainers error:nil]]]][0];
        _artistNamel.text = _playMuzzik.music.artist;
        _songName.text = _playMuzzik.music.name;
    }
    userInfo *user = [userInfo shareClass];
    if ([user.listenToUid isEqualToString:message.messageUser.user_id]) {
        [_listenButton setHidden:YES];
        [_listenTextLabel setFrame:CGRectMake(10, 10, 150, 24)];
        _listenTextLabel.text = @"正在和Ta一起听";
    }else if([user.listenUser containsObject:message.messageUser]){
        [_listenTextLabel setFrame:CGRectMake(10, 10, 150, 24)];
        [_listenButton setHidden:YES];
        _listenTextLabel.text = @"Ta正在和你一起听";
    }
}

-(void)showUserInfo{
    [self.imvc userDetail:self.cellMessage.messageUser.user_id];
}

-(void)listenTogether{
    self.imvc.listenView.status = Status_together;
    if (_playMuzzik) {
        [MuzzikPlayer shareClass].listType = TempList;
        [MuzzikPlayer shareClass].MusicArray =  [NSMutableArray arrayWithArray:@[_playMuzzik]];
        [MuzzikItem SetUserInfoWithMuzziks: [NSMutableArray arrayWithArray:@[_playMuzzik]] title:Constant_userInfo_temp description:[NSString stringWithFormat:@"单曲<%@>",_playMuzzik.music.name]];
        [[MuzzikPlayer shareClass] playSongWithSongModel:_playMuzzik Title:[NSString stringWithFormat:@"单曲<%@>",_playMuzzik.music.name]];
    }
    [_listenButton setHidden:YES];
    [_listenTextLabel setFrame:CGRectMake(10, 10, 150, 24)];
    _listenTextLabel.text = @"正在和Ta一起听";
    userInfo *user = [userInfo shareClass];
    user.rootId = [[NSJSONSerialization JSONObjectWithData:self.cellMessage.messageData options:NSJSONReadingMutableContainers error:nil] objectForKey:@"root"];
    user.listenToUid = self.cellMessage.messageUser.user_id;
}
-(void)updateMusicMessage{
    if (self.cellMessage.messageData) {
        _playMuzzik = [[muzzik new] makeMuzziksByMusicArray:[NSMutableArray arrayWithArray:@[[NSJSONSerialization JSONObjectWithData:self.cellMessage.messageData options:NSJSONReadingMutableContainers error:nil]]]][0];
        dispatch_async(dispatch_get_main_queue(), ^{
            _artistNamel.text = _playMuzzik.music.artist;
            _songName.text = _playMuzzik.music.name;
        });
        
    }
}
-(void)listenActionInStatue:(NSNumber *)status{
    if (status.integerValue == Status_Music) {
        self.imvc.listenView.status = Status_together;
        if (_playMuzzik) {
            [MuzzikPlayer shareClass].listType = TempList;
            [MuzzikPlayer shareClass].MusicArray =  [NSMutableArray arrayWithArray:@[_playMuzzik]];
            [MuzzikItem SetUserInfoWithMuzziks: [NSMutableArray arrayWithArray:@[_playMuzzik]] title:Constant_userInfo_temp description:[NSString stringWithFormat:@"单曲<%@>",_playMuzzik.music.name]];
            [[MuzzikPlayer shareClass] playSongWithSongModel:_playMuzzik Title:[NSString stringWithFormat:@"单曲<%@>",_playMuzzik.music.name]];
        }
        [_listenButton setHidden:YES];
        [_listenTextLabel setFrame:CGRectMake(10, 10, 150, 24)];
        _listenTextLabel.text = @"正在和Ta一起听";
        userInfo *user = [userInfo shareClass];
        user.rootId = [[NSJSONSerialization JSONObjectWithData:self.cellMessage.messageData options:NSJSONReadingMutableContainers error:nil] objectForKey:@"root"];
        user.listenToUid = self.cellMessage.messageUser.user_id;
    }else if (status.integerValue == Status_together){
        self.imvc.listenView.status = Status_Music;
        [_listenButton setHidden:NO];
        [_listenTextLabel setFrame:CGRectMake(10, 10, 100, 24)];
        _listenTextLabel.text = @"Hi,我正在听";
        userInfo *user = [userInfo shareClass];
        
        user.listenToUid =@"";
    }
}
@end
