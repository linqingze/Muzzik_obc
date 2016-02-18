//
//  ListenTogetherView.m
//  muzzik
//
//  Created by muzzik on 16/2/16.
//  Copyright © 2016年 muzziker. All rights reserved.
//

#import "ListenTogetherView.h"
#import "UIImageView+WebCache.h"

@interface ListenTogetherView()
@property(nonatomic,retain) UIImageView *backgroundImage;
@property(nonatomic,retain) UIImageView *leftImage;
@property(nonatomic,retain) UIImageView *rightImage;
@property(nonatomic,retain) UIView *nacView;
@property(nonatomic,retain) UILabel *listenLabel;
@property(nonatomic,retain) UILabel *songNameLabel;
@property(nonatomic,retain) UILabel *artistLabel;
@property(nonatomic,retain) UIButton *listenButton;
@property(nonatomic,retain) muzzik *playMuzzik;

@end
@implementation ListenTogetherView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void)setStatus:(NSInteger)status{
    _status = status;
    if (status == Status_NoMusic) {
        [self setHidden:YES];
    }else if (status == Status_Music){
        [self setHidden:NO];
        [self.backgroundImage setImage:[UIImage imageNamed:@"listen"]];
        
        
        [_rightImage removeFromSuperview];
        [_leftImage setFrame:CGRectMake(12, 20, 13, 13)];
        [self addSubview:_leftImage];
        for (UIView *view in self.subviews) {
            NSLog(@"%@",view);
        }
    }else if (status == Status_together){
        [self setHidden:NO];
        
        [self.backgroundImage setImage:[UIImage imageNamed:@"listentogether"]];
        [_leftImage setFrame:CGRectMake(7, 20, 13, 13)];
        [_rightImage setFrame:CGRectMake(24, 18, 13, 13)];
        [self addSubview:_leftImage];
        [self addSubview:_rightImage];
        for (UIView *view in self.subviews) {
            NSLog(@"%@",view);
        }
    }
}
-(UIImageView *)backgroundImage{
    if (!_backgroundImage) {
        
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)]];
        _backgroundImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        [self addSubview:_backgroundImage];
    }
    return _backgroundImage;
}
-(UIImageView *)leftImage{
    if (!_leftImage) {
        _leftImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 13, 13)];
        _leftImage.layer.cornerRadius = 6.5;
        _leftImage.layer.masksToBounds = YES;
        _leftImage.contentMode = UIViewContentModeScaleAspectFit;
        
    }
    return _leftImage;
}
-(UIView *)nacView{
    if (!_nacView) {
        _nacView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, SCREEN_WIDTH, 0)];
        UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(viewBack)];
        
        [recognizer setDirection:(UISwipeGestureRecognizerDirectionUp)];
        
        [_nacView addGestureRecognizer:recognizer];
        _nacView.clipsToBounds = YES;
        _listenLabel = [[UILabel alloc] initWithFrame:CGRectMake(13, -80, SCREEN_WIDTH -150, 44)];
        [_listenLabel setFont:[UIFont boldSystemFontOfSize:17]];
        [_listenLabel setTextColor:[UIColor whiteColor]];
        
        _songNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(13, -36, SCREEN_WIDTH -150, 15)];
        [_songNameLabel setFont:[UIFont fontWithName:Font_Next_medium size:12]];
        [_songNameLabel setTextColor:Color_Additional_5];
        
        _artistLabel = [[UILabel alloc] initWithFrame:CGRectMake(13, -20, SCREEN_WIDTH-150, 15)];
        [_artistLabel setFont:[UIFont fontWithName:Font_Next_medium size:10]];
        [_artistLabel setTextColor:Color_Additional_5];
        
        _listenButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-61, -80, 48, 44)];
        [_listenButton addTarget:self action:@selector(listenAction) forControlEvents:UIControlEventTouchUpInside];
        [_nacView setBackgroundColor:Color_NavigationBar];
        [_nacView addSubview:_listenLabel];
        [_nacView addSubview:_songNameLabel];
        [_nacView addSubview:_artistLabel];
        [_nacView addSubview:_listenButton];
    }
    return _nacView;
}
-(UIImageView *)rightImage{
    if (!_rightImage) {
        _rightImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 13, 13)];
        _rightImage.layer.cornerRadius = 6.5;
        _rightImage.layer.masksToBounds = YES;
        _rightImage.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _rightImage;
}
-(void)setLeftAvatarString:(NSString *)leftAvatarString{
    _leftAvatarString = leftAvatarString;
    [self.leftImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",BaseURL_image,leftAvatarString,Image_Size_Small]]];
    
}
-(void)setRightAvatarString:(NSString *)rightAvatarString{
    _rightAvatarString = rightAvatarString;
    [self.rightImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",BaseURL_image,rightAvatarString,Image_Size_Small]]];
}
-(void)setListenMessage:(Message *)listenMessage{
    _listenMessage = listenMessage;
    if (_listenMessage.messageData) {
        _playMuzzik = [[muzzik new] makeMuzziksByMusicArray:[NSMutableArray arrayWithArray:@[[NSJSONSerialization JSONObjectWithData:_listenMessage.messageData options:NSJSONReadingMutableContainers error:nil]]]][0];
    }
}
-(void) tap{
    AppDelegate *appdelegate = [UIApplication sharedApplication].delegate;
    UINavigationController *nac = (UINavigationController *)appdelegate.tabviewController.selectedViewController;
    [nac.view addSubview:self.nacView];
    if (self.status == Status_Music) {
        [_listenButton setImage:[UIImage imageNamed:@"listentogetherbutton"] forState:UIControlStateNormal];
        _listenLabel.text = [NSString stringWithFormat:@"%@正在听",_listenMessage.messageUser.name];
        _artistLabel.text = _playMuzzik.music.artist;
        _songNameLabel.text = _playMuzzik.music.name;
    }else if (self.status == Status_together){
        [_listenButton setImage:[UIImage imageNamed:@"canclelistentogether"] forState:UIControlStateNormal];
        userInfo *user = [userInfo shareClass];
        if ([user.listenToUid isEqualToString:_listenMessage.messageUser.user_id]) {
            _listenLabel.text = @"正在和Ta一起听";
        }else if([user.listenUser containsObject:_listenMessage.messageUser]){
            _listenLabel.text = @"Ta正在和你一起听";
        }
        _artistLabel.text = _playMuzzik.music.artist;
        _songNameLabel.text = _playMuzzik.music.name;
    }
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [_nacView setFrame:CGRectMake(0, 20, SCREEN_WIDTH, 80)];
        _listenLabel.frame = CGRectMake(13, 0, SCREEN_WIDTH -150, 44);
        _songNameLabel.frame = CGRectMake(13, 44, SCREEN_WIDTH -150, 15);
        _artistLabel.frame = CGRectMake(13, 60, SCREEN_WIDTH-150, 15);
        _listenButton.frame = CGRectMake(SCREEN_WIDTH-61, 0, 48, 44);
    } completion:^(BOOL finished) {
        [self performSelector:@selector(viewBack) withObject:nil afterDelay:4];
    }];
    
}
-(void)viewBack{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(viewBack) object:nil];
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [_nacView setFrame:CGRectMake(0, 20, SCREEN_WIDTH, 0)];
        _listenLabel.frame = CGRectMake(13, -80, SCREEN_WIDTH -150, 44);
        _songNameLabel.frame = CGRectMake(13, -36, SCREEN_WIDTH -150, 15);
        _artistLabel.frame = CGRectMake(13, -20, SCREEN_WIDTH-150, 15);
        _listenButton.frame = CGRectMake(SCREEN_WIDTH-61, -80, 48, 44);
    } completion:^(BOOL finished) {
        [_nacView removeFromSuperview];
    }];
}
-(void)listenAction{
    if (self.status == Status_Music) {
        [_listenButton setImage:[UIImage imageNamed:@"canclelistentogether"] forState:UIControlStateNormal];
    }else if (self.status == Status_together){
        [_listenButton setImage:[UIImage imageNamed:@"listentogetherbutton"] forState:UIControlStateNormal];
    }
    [self.delegate listenActionInStatue:self.status];
}
@end
