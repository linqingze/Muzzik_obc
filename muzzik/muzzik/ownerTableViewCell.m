//
//  ownerTableViewCell.m
//  muzzik
//
//  Created by muzzik on 16/1/6.
//  Copyright © 2016年 muzziker. All rights reserved.
//

#import "ownerTableViewCell.h"
#import "Utils_IM.h"
#import "UIButton+WebCache.h"
#import "DetaiMuzzikVC.h"
@implementation ownerTableViewCell
#define Message_size 15

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
    _headImage.layer.cornerRadius = 20;
    _headImage.layer.masksToBounds = YES;
    [_headImage addTarget:self action:@selector(seeUserImage) forControlEvents:UIControlEventTouchUpInside];
    _timeLabel = [[UILabel alloc] init];
    [_timeLabel setFont:[UIFont fontWithName:Font_Next_Regular size:10]];
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    [_timeLabel setTextColor:Color_Text_3];
    [_timeLabel setBackgroundColor:[UIColor whiteColor]];
    _timelineImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"timedivideline"]];
    [_timelineImage setFrame:CGRectMake(SCREEN_WIDTH/2-140, 16, 280, 8)];
    _timelineImage.contentMode = UIViewContentModeScaleAspectFit;
    _messageLabel = [[UILabel alloc] init];
    _messageLabel.numberOfLines = 0;
    [_messageLabel setFont:[UIFont fontWithName:Font_Next_Regular size:Message_size]];
    
    _muzzikUserHeader = [[UIButton alloc] initWithFrame:CGRectMake(5, 5, 60, 60)];
    [_muzzikUserHeader addTarget:self action:@selector(playMyzzik) forControlEvents:UIControlEventTouchUpInside];
    
    _artistNamel = [[UILabel alloc] initWithFrame:CGRectMake(70, 5, SCREEN_WIDTH - 206, 15)];
    [_artistNamel setFont:[UIFont fontWithName:Font_Next_Regular size:15]];
    
    _artistNamel.textColor = Color_Text_1;
    _songName = [[UILabel alloc]  initWithFrame:CGRectMake(70, 25, SCREEN_WIDTH - 206, 15)];
    [_songName setFont:[UIFont fontWithName:Font_Next_Regular size:12]];
    [_songName setTextColor:Color_Text_2];
    
    
    _messageView = [[UIView alloc] init];
    _messageView.layer.cornerRadius = 5;
    _messageView.layer.masksToBounds = YES;
    [_messageView addSubview:_muzzikUserHeader];
    [_messageView addSubview:_messageLabel];
    [_messageView addSubview:_songName];
    [_messageView addSubview:_artistNamel];
    [self addSubview:_messageView];
    [self addSubview:_headImage];
    [self addSubview:_timelineImage];
    [self addSubview:_timeLabel];

    _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnView:)];
    _longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
}
-(CGFloat) configureCellWithMessage:(Message *) message{
    self.cellMessage = message;
    CGFloat height = 0;
    if ([message.needsToShowTime boolValue]) {
        [_timelineImage setHidden:NO];
        [_timeLabel setHidden:NO];
        [_timeLabel setBounds:CGRectMake(0, 0, 120, 15)];
        _timeLabel.text = [Utils_IM getStringFromIMDate:message.sendTime];
        [_timeLabel sizeToFit];
        [_timeLabel setFrame:CGRectMake(SCREEN_WIDTH/2 - _timeLabel.frame.size.width/2-5, 16, _timeLabel.frame.size.width+10, 8)];
        height += 40;
    }else{
        [_timeLabel setHidden:YES];
        [_timelineImage setHidden:YES];
        height+=8;
    }
    
    if ([message.messageType isEqualToString:Type_IM_TextMessage]) {
        [_messageView removeGestureRecognizer:_tap];
        [_messageView removeGestureRecognizer:_longPress];
        [_muzzikUserHeader setHidden:YES];
        [_artistNamel setHidden:YES];
        [_songName setHidden:YES];
        [_messageLabel setHidden:NO];
        _messageView.layer.borderWidth = 0;
        [_messageLabel setFrame:CGRectMake(0, 0, SCREEN_WIDTH-151, 1000)];
        _messageLabel.text = message.messageContent;
        [_messageLabel sizeToFit];
        
        if ([message.isOwner boolValue]) {
            
            [_headImage setFrame:CGRectMake(SCREEN_WIDTH-53, height, 40, 40)];
            
            [_messageLabel setFrame:CGRectMake(10, 10, _messageLabel.frame.size.width, _messageLabel.frame.size.height)];
            
            [_messageView setBackgroundColor:Color_Active_Button_2];
            [_messageView setFrame:CGRectMake(SCREEN_WIDTH-83-_messageLabel.frame.size.width, height, _messageLabel.frame.size.width+20,  _messageLabel.frame.size.height+22)];
            
        }else{
            [_headImage setFrame:CGRectMake(13, height, 40, 40)];
            
            
            [_messageLabel setFrame:CGRectMake(10, 10, _messageLabel.frame.size.width, _messageLabel.frame.size.height)];
            [_messageView setBackgroundColor:Color_line_1];
            [_messageView setFrame:CGRectMake(63, height, _messageLabel.frame.size.width+20,  _messageLabel.frame.size.height+22)];
           
        }
        _messageLabel.textAlignment = NSTextAlignmentLeft;
    }else if ([message.messageType isEqualToString:Type_IM_ShareMuzzik]){
        [_messageView addGestureRecognizer:_tap];
        [_messageView addGestureRecognizer:_longPress];
        [_muzzikUserHeader setHidden:NO];
        [_artistNamel setHidden:NO];
        [_songName setHidden:NO];
        [_messageLabel setHidden:YES];
        [_messageView setBackgroundColor:[UIColor whiteColor]];
        _messageView.layer.borderWidth = 1;
        _messageView.layer.borderColor = Color_Active_Button_2.CGColor;
        if (message.messageData) {
            _playMuzzik = [[muzzik new] makeMuzziksByMuzzikArray:[NSMutableArray arrayWithArray:@[[NSJSONSerialization JSONObjectWithData:message.messageData options:NSJSONReadingMutableContainers error:nil]]]][0];
            
            [_muzzikUserHeader sd_setBackgroundImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",BaseURL_image,_playMuzzik.MuzzikUser.avatar,Image_Size_Small]] forState:UIControlStateNormal];
            if ([_playMuzzik.muzzik_id isEqualToString:[MuzzikPlayer shareClass].playingMuzzik.muzzik_id] &&![Globle shareGloble].isPause && [Globle shareGloble].isPlaying) {
                [_muzzikUserHeader setImage:[UIImage imageNamed:@"IMmuzzikstop"] forState:UIControlStateNormal];
            }else{
                [_muzzikUserHeader setImage:[UIImage imageNamed:@"IMmuzzikplay"] forState:UIControlStateNormal];
            }
            _songName.text = _playMuzzik.music.name;
            _artistNamel.text = _playMuzzik.music.artist;
        }
        
        
        
        
        if ([message.isOwner boolValue]) {
            [_headImage setFrame:CGRectMake(SCREEN_WIDTH-53, height, 40, 40)];
            [_messageView setFrame:CGRectMake(73, height, SCREEN_WIDTH-136, 70)];

            
        }else{
            [_headImage setFrame:CGRectMake(13, height, 40, 40)];
            [_messageView setFrame:CGRectMake(63, height, SCREEN_WIDTH-136, 70)];
        }
        
    }else{
        
    }
    NSLog(@"name:%@   avatar:%@,",message.messageUser.name,message.messageUser.avatar);
    [_headImage sd_setBackgroundImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL_image,message.messageUser.avatar]] forState:UIControlStateNormal];
    return height+_messageLabel.frame.size.height;
}
-(void)playMyzzik{

    if (_playMuzzik) {
        [MuzzikPlayer shareClass].listType = TempList;
        [MuzzikPlayer shareClass].MusicArray =  [NSMutableArray arrayWithArray:@[_playMuzzik]];
        [MuzzikItem SetUserInfoWithMuzziks: [NSMutableArray arrayWithArray:@[_playMuzzik]] title:Constant_userInfo_temp description:[NSString stringWithFormat:@"单曲<%@>",_playMuzzik.music.name]];
        [[MuzzikPlayer shareClass] playSongWithSongModel:_playMuzzik Title:[NSString stringWithFormat:@"单曲<%@>",_playMuzzik.music.name]];
    }
}

-(void)tapOnView:(UITapGestureRecognizer *) gesture{
    if (_playMuzzik) {
        DetaiMuzzikVC *detail = [[DetaiMuzzikVC alloc] init];
        detail.muzzik_id = _playMuzzik.muzzik_id;
        [_imvc.navigationController pushViewController:detail animated:YES];
    }
}
-(void)longPress:(UILongPressGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [_messageView setBackgroundColor:Color_line_1];
    }else if (gesture.state == UIGestureRecognizerStateEnded){
        NSLog(@"%d,%d",[gesture locationInView:self].x, [gesture locationInView:self].y);
        if (CGRectContainsPoint(self.bounds,[gesture locationInView:self]) ) {
            if (_playMuzzik) {
                DetaiMuzzikVC *detail = [[DetaiMuzzikVC alloc] init];
                detail.muzzik_id = _playMuzzik.muzzik_id;
                [_imvc.navigationController pushViewController:detail animated:YES];
            }
        }
        [_messageView setBackgroundColor:[UIColor whiteColor]];

    }
    
}
-(void)seeUserImage{
    CGRect rect = [self convertRect:self.headImage.frame toView:self.imvc.view];
    
    [self.imvc showUserImageWithimageKey:self.cellMessage.messageUser.avatar holdImage:[self.headImage imageForState:UIControlStateNormal] orginalRect:rect];
}
@end
