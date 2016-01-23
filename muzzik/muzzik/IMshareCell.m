//
//  IMshareCell.m
//  muzzik
//
//  Created by muzzik on 16/1/21.
//  Copyright © 2016年 muzziker. All rights reserved.
//

#import "IMshareCell.h"
#import "Utils_IM.h"
#import "UIButton+WebCache.h"
#import "DetaiMuzzikVC.h"
#import "IMShareMessage.h"
@implementation IMshareCell

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
    [_headImage setImage:[UIImage imageNamed:@"frame"] forState:UIControlStateNormal];
    [_headImage addTarget:self action:@selector(seeUserImage) forControlEvents:UIControlEventTouchUpInside];
    _timeLabel = [[UILabel alloc] init];
    [_timeLabel setFont:[UIFont fontWithName:Font_Next_Regular size:10]];
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    [_timeLabel setTextColor:Color_Additional_5];
    [_timeLabel setBackgroundColor:[UIColor whiteColor]];
    _timelineImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"timedivideline"]];
    [_timelineImage setFrame:CGRectMake(SCREEN_WIDTH/2-140, 16, 280, 8)];
    _timelineImage.contentMode = UIViewContentModeScaleAspectFit;
    
    _muzzikUserHeader = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 60, 60)];
    [_muzzikUserHeader addTarget:self action:@selector(playMyzzik) forControlEvents:UIControlEventTouchUpInside];
    
    _artistNamel = [[UILabel alloc] initWithFrame:CGRectMake(80, 10, SCREEN_WIDTH - 216, 17)];
    [_artistNamel setFont:[UIFont fontWithName:Font_Next_medium size:15]];
    
    _artistNamel.textColor = Color_Text_1;
    _songName = [[UILabel alloc]  initWithFrame:CGRectMake(80, 30, SCREEN_WIDTH - 216, 15)];
    [_songName setFont:[UIFont fontWithName:Font_Next_medium size:12]];
    [_songName setTextColor:Color_Text_2];
    
    
    _messageView = [[UIView alloc] init];
    _messageView.layer.cornerRadius = 5;
    _messageView.layer.masksToBounds = YES;
    [_messageView addSubview:_muzzikUserHeader];
    [_messageView addSubview:_songName];
    [_messageView addSubview:_artistNamel];
    
    _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _resendButton = [[UIButton alloc] init];
    [_resendButton setImage:[UIImage imageNamed:@"resend"] forState:UIControlStateNormal];
    [_resendButton addTarget:self action:@selector(rensendMessage) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_activityView];
    [self addSubview:_resendButton];
    
    
    [self addSubview:_messageView];
    [self addSubview:_headImage];
    [self addSubview:_timelineImage];
    [self addSubview:_timeLabel];
    
    _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnView:)];
    _longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [_messageView addGestureRecognizer:_tap];
    [_messageView addGestureRecognizer:_longPress];
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
        [_messageView setBackgroundColor:[UIColor whiteColor]];
        [_headImage setFrame:CGRectMake(SCREEN_WIDTH-53, height, 40, 40)];
        [_messageView setFrame:CGRectMake(73, height, SCREEN_WIDTH-136, 80)];
        
        
    }else{
        [_messageView setBackgroundColor:[UIColor whiteColor]];
        [_headImage setFrame:CGRectMake(13, height, 40, 40)];
        [_messageView setFrame:CGRectMake(63, height, SCREEN_WIDTH-136, 80)];
    }
    if ([message.sendStatue isEqualToString:Statue_OK]) {
        [_resendButton setHidden:YES];
        [_activityView stopAnimating];
        [_activityView setHidden:YES];
    }else if ([message.sendStatue isEqualToString:Statue_Sending]&& ![Utils_IM checkLimitedTime:[NSDate date] oldDate:message.sendTime]){
        [_resendButton setHidden:YES];
        [_activityView setHidden:NO];
        if ([message.isOwner boolValue]) {
            [_activityView setFrame:CGRectMake(_messageView.frame.origin.x-25, _messageView.frame.origin.y, 20, _messageView.frame.size.height)];
            [_activityView startAnimating];
        }else{
            [_activityView setFrame:CGRectMake(_messageView.frame.origin.x+_messageView.frame.size.width+5, _messageView.frame.origin.y, 20, _messageView.frame.size.height)];
            [_activityView startAnimating];
        }
        
    }else{
        [_resendButton setHidden:NO];
        [_activityView stopAnimating];
        [_activityView setHidden:YES];
        if ([message.isOwner boolValue]) {
            [_resendButton setFrame:CGRectMake(_messageView.frame.origin.x-50, _messageView.frame.origin.y, 40, 40)];
            [_activityView setFrame:CGRectMake(_messageView.frame.origin.x-25, _messageView.frame.origin.y, 20, _messageView.frame.size.height)];
        }else{
            [_resendButton setFrame:CGRectMake(_messageView.frame.origin.x+_messageView.frame.size.width+5, _messageView.frame.origin.y, 40, 40)];
        }
    }
    
    
    
    [_headImage sd_setBackgroundImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",BaseURL_image,message.messageUser.avatar,Image_Size_Small]] forState:UIControlStateNormal];
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
    [self.imvc.view resignFirstResponder];
    CGRect rect = [self convertRect:self.headImage.frame toView:self.imvc.view];
    
    [self.imvc showUserImageWithimageKey:self.cellMessage.messageUser.avatar holdImage:[self.headImage imageForState:UIControlStateNormal] orginalRect:rect];
}

-(void)rensendMessage{
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [_resendButton setHidden:YES];
    [_activityView setHidden:NO];
    [_activityView startAnimating];
    IMShareMessage *imshare = [[IMShareMessage alloc] init];
    imshare.jsonStr = [[NSString alloc] initWithData:self.cellMessage.messageData encoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:self.imvc.con.targetUser.name,@"name",self.imvc.con.targetUser.avatar,@"avatar",self.imvc.con.targetUser.user_id,@"_id", nil];
    imshare.extra = [self DataTOjsonString:dic];
    
    [[RCIMClient sharedRCIMClient] sendMessage:ConversationType_PRIVATE targetId:self.imvc.con.targetId content:imshare pushContent:[NSString stringWithFormat:@"%@: 分享了一条Muzzik",self.imvc.con.targetUser.name] success:^(long messageId) {
        self.cellMessage.sendStatue = Statue_OK;
        [app.managedObjectContext save:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_resendButton setHidden:YES];
            [_activityView stopAnimating];
            [_activityView setHidden:YES];
        });
        
    } error:^(RCErrorCode nErrorCode, long messageId) {
        self.cellMessage.sendStatue = Statue_Failed;
        [app.managedObjectContext save:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_resendButton setHidden:NO];
            [_activityView stopAnimating];
            [_activityView setHidden:YES];
        });
        
    }];
    
}

-(NSString*)DataTOjsonString:(id)object
{
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}
@end
