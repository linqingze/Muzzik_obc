//
//  CommentMuzzikCell.m
//  muzzik
//
//  Created by muzzik on 15/5/9.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "CommentMuzzikCell.h"

@implementation CommentMuzzikCell

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
    _lineview = [[UIView alloc] initWithFrame:CGRectMake(16, 1, SCREEN_WIDTH-32, 1)];
    [_lineview setBackgroundColor:Color_line_1];
    [self addSubview:_lineview];
    
    _privateImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [_privateImage setImage:[UIImage imageNamed:Image_detailinvisibleImage]];
    [_privateImage setHidden:YES];
    [self addSubview:_privateImage];
    _userImage = [[UIButton alloc] initWithFrame:CGRectMake(16, 20, 50, 50)];
    [_userImage addTarget:self action:@selector(goToUser) forControlEvents:UIControlEventTouchUpInside];
    _userImage.layer.cornerRadius = 25;
    _userImage.layer.masksToBounds = YES;
    //    _userImage.layer.borderColor = [UIColor whiteColor].CGColor;
    //    _userImage.layer.borderWidth = 2.0f;
    [self addSubview:_userImage];
    _userName = [[UILabel alloc] initWithFrame:CGRectMake(76, 25,100, 20)];
    [_userName setTextColor:Color_Text_1];
    [_userName setFont:[UIFont fontWithName:Font_Next_medium size:Font_size_userName]];
    [self addSubview:_userName];
    _message = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(76, 56, SCREEN_WIDTH-140, 30)];
    [_message setFont:[UIFont systemFontOfSize:Font_Size_Muzzik_Message]];
    [_message setTextColor:Color_Text_2];
    [self addSubview:_message];
    
    _playButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-56, 40, 40, 40)];
    [_playButton addTarget:self action:@selector(playMuzzik) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_playButton];
    _songName = [[UILabel alloc] initWithFrame:CGRectMake(79, 12, SCREEN_WIDTH-150, 20)];
    [self addSubview:_songName];
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-76, 4, 45, 20)];
    _timeLabel.textAlignment = NSTextAlignmentRight;
    _timeImage = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-25, 9, 9, 9)];
    [_timeImage setImage:[UIImage imageNamed:Image_timeImage]];
    [self addSubview:_timeImage];
    [_timeLabel setFont:[UIFont systemFontOfSize:9]];
    [_timeLabel setTextColor:Color_Additional_5];
    [self addSubview:_timeLabel];
    self.longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(informAction:)];
    [self addGestureRecognizer:self.longPress];
}
-(void) playMuzzik{
     [self.delegate playSongWithSongModel:self.MuzzikModel];
}
-(void) goToUser{
    [self.delegate userDetail:self.MuzzikModel.MuzzikUser.user_id];
}
-(void)informAction:(UILongPressGestureRecognizer *)longPressGesture{
    if (longPressGesture.state == UIGestureRecognizerStateBegan){
        userInfo *user = [userInfo shareClass];
        if (![user.uid isEqualToString:self.MuzzikModel.MuzzikUser.user_id]) {
            
            UIActionSheet *alertSheet;
            if ([user.token length]>0 ) {
                alertSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"举报", nil];
            }else{
                alertSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"请先登录，再举报Ta", nil];
            }
            
            [alertSheet showInView:self.window];
        }
        
    }
    
    
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{

    if(buttonIndex==actionSheet.cancelButtonIndex){
        return;
    }else{
        UIViewController *vc =  (UIViewController *)self.delegate;
        userInfo *user = [userInfo shareClass];
        if ([user.token length]>0) {
            repostVC *informvc = [[repostVC alloc] init];
            informvc.informString = [NSString stringWithFormat:@"muzzik id:%@",self.MuzzikModel.muzzik_id];
            [vc.navigationController pushViewController:informvc animated:YES];
        }else{
            [userInfo checkLoginWithVC:vc];
        }
    }
    
}
@end
