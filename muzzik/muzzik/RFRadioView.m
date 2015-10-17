//
//  RFRadioView.m
//  RadioFree
//
//  Created by zhaojianguo-PC on 14-5-23.
//  Copyright (c) 2014年 xiaozi. All rights reserved.
//
#import "appConfiguration.h"
#import "RFRadioView.h"
#import "FSPlaylistItem.h"
#import "UIView+Additions.h"
//#import "Globle.h"
#import "FMLrcView.h"
#import "UIButton+WebCache.h"
#import "FSAudioStream.h"
#import <AVFoundation/AVFoundation.h>
#import "UIColor+HexColor.h"
#import "UIImageView+WebCache.h"
#import "TTTAttributedLabel.h"
#import "MessageStepViewController.h"
#import "DetaiMuzzikVC.h"
#import "userDetailInfo.h"
#import "UserHomePage.h"
#define closeInterValTime 0.5
@implementation RFRadioView
@synthesize delegate = _delegate;
@synthesize selectedPlaylistItem = _selectedPlaylistItem;

-(NSMutableArray *)lyricArray{
    if (!_lyricArray) {
        _lyricArray = [NSMutableArray array];
    }
    return _lyricArray;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
       
        [self setAlpha:0];
        //后台播放音频设置
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataSourceMuzzikUpdate:) name:String_MuzzikDataSource_update object:nil];
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        [session setCategory:AVAudioSessionCategoryPlayback error:nil];
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
        _progressUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                                target:self
                                                              selector:@selector(updatePlaybackProgress)
                                                              userInfo:nil
                                                               repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_progressUpdateTimer forMode:NSRunLoopCommonModes];
//        audioController = [[FSAudioController alloc] init];
        audioPlayer = [AudioPlayer shareClass];
        audioPlayer.delegate = self;
        self.smallView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 64)];
        self.titleView = [[UIView alloc] initWithFrame:CGRectMake(-SCREEN_WIDTH, 0, SCREEN_WIDTH, 64)];
        self.playView = [[UIView alloc] initWithFrame:CGRectMake(0, -338, SCREEN_WIDTH, 338)];
        self.playListView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH, 64, SCREEN_WIDTH, 338)];
        self.coverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        [self.coverView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeView)]];
        UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(closeView)];
        [recognizer setDirection:UISwipeGestureRecognizerDirectionUp];
        [self.coverView addGestureRecognizer:recognizer];
        [self.coverView setHidden:YES];
        [self addSubview:self.smallView];
        
        [self addSubview:self.coverView];
        [self addSubview:self.playListView];
        [self addSubview:self.playView];
        [self addSubview:self.smallView];
        [self addSubview:self.titleView];
        [self.playListView setBackgroundColor:Color_NavigationBar];
        [self.titleView setBackgroundColor:Color_NavigationBar];
        [self.smallView setBackgroundColor:Color_NavigationBar];
        [self.playView setBackgroundColor:Color_NavigationBar];
        //[self addSubview:_currentPlaybackTime];
        [self initPlayList];
        showButton = [[UIButton alloc] initWithFrame:CGRectMake(8, 21, 40, 40)];
        [showButton setImage:[UIImage imageNamed:Image_PlayercontrolImage] forState:UIControlStateNormal];
        [showButton addTarget:self action:@selector(showFullPlayer:) forControlEvents:UIControlEventTouchUpInside];
        UIImageView *coverBar = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, 63, 44)];
        [coverBar setImage:[UIImage imageNamed:Image_playerbarcoverImage]];
        [self addSubview:coverBar];
        [self addSubview: showButton];
        
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 30,SCREEN_WIDTH-80, 20)];
        _titleLabel.font = [UIFont boldSystemFontOfSize:15];
        [_titleLabel setTextColor:[UIColor whiteColor]];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.adjustsFontSizeToFitWidth = YES;
        _titleLabel.text = @"播放歌曲";
        [_titleLabel setAlpha:1];
        [self.titleView addSubview:_titleLabel];
        playListButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-42, 21, 40, 40)];
        [playListButton setImage:[UIImage imageNamed:Image_PlayerlistImage] forState:UIControlStateNormal];
        [playListButton addTarget:self action:@selector(showPlayList) forControlEvents:UIControlEventTouchUpInside];
        [self.titleView addSubview:playListButton];
        
        //[self addSubview:_titleLabel];
        smallPlayButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 42, 21, 40, 40)];
        [smallPlayButton setImage:[UIImage imageNamed:Image_PlayerplayImage] forState:UIControlStateNormal];
        [smallPlayButton addTarget:self action:@selector(playAction) forControlEvents:UIControlEventTouchUpInside];
        [self.smallView addSubview:smallPlayButton];
        [self.smallView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showFullPlayer:)]];

        headerImage = [[UIButton_UserMuzzik alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-37, 0, 75, 75)];
        headerImage.layer.cornerRadius = 38;
        headerImage.clipsToBounds = YES;
        [headerImage addTarget:self action:@selector(gotoUserDetail:) forControlEvents:UIControlEventTouchUpInside];
        [self.playView addSubview:headerImage];
        attentionButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2+12, 50, 25, 25)];
        [attentionButton setImage:[UIImage imageNamed:Image_PlayerfollowImage] forState:UIControlStateNormal];
        [attentionButton addTarget:self action:@selector(attentionAction) forControlEvents:UIControlEventTouchUpInside];
        [self.playView addSubview:attentionButton];
        nickLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 75, SCREEN_WIDTH, 30)];
        [nickLabel setTextColor:[UIColor whiteColor]];
        [nickLabel setFont:[UIFont fontWithName:Font_Next_Bold size:14]];
        nickLabel.textAlignment = NSTextAlignmentCenter;
        [self.playView addSubview:nickLabel];
        pagecontrol = [[StyledPageControl alloc] initWithFrame:CGRectMake(0, 105, SCREEN_WIDTH, 8)];
        //page control
        [pagecontrol setCoreSelectedColor:Color_Additional_5];
        [pagecontrol setCoreNormalColor:Color_Theme_3];
        [pagecontrol setDiameter:7];
        [pagecontrol setGapWidth:4];
        userInfo *user = [userInfo shareClass];
        if (!user.hideLyric) {
            [self.playView addSubview:pagecontrol];
        }
        
        //[pagecontrol setBackgroundColor:[UIColor whiteColor]];
        pagecontrol.numberOfPages = 2;
        Scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 113, SCREEN_WIDTH, 100)];
        Scroll.delegate = self;
        [Scroll setPagingEnabled:YES];
        if (!user.hideLyric) {
            [Scroll setContentSize:CGSizeMake(SCREEN_WIDTH*2, 100)];
        }else{
            [Scroll setContentSize:CGSizeMake(SCREEN_WIDTH, 100)];
        }
        
        [self.playView addSubview:Scroll];
        if (!user.hideLyric) {
            messageView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH, 0, SCREEN_WIDTH, 100)];
        }else{
            messageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 100)];
        }
        [messageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(seeDetail)]];
        message =[[UILabel alloc ] initWithFrame:CGRectMake(15, 10, SCREEN_WIDTH-30, 80)];
        message.numberOfLines = 0;
        
        [messageView addSubview:message];
        [Scroll addSubview:messageView];
        [Scroll setShowsHorizontalScrollIndicator:NO];
        lyricTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 100)];
        [lyricTableView setBackgroundColor:Color_NavigationBar];
        [lyricTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        lyricTipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 35, SCREEN_WIDTH-100, 20)];
        [lyricTipsLabel setFont:[UIFont systemFontOfSize:12]];
        [lyricTipsLabel setTextColor:[UIColor whiteColor]];
        lyricTipsLabel.textAlignment = NSTextAlignmentCenter;
        [lyricTipsLabel setAlpha:0];
        lyricTableView.delegate = self;
        lyricTableView.dataSource = self;
        if (!user.hideLyric) {
            [Scroll addSubview:lyricTableView];
            [Scroll addSubview:lyricTipsLabel];
        }

        _progress = [[UISlider alloc] initWithFrame:CGRectMake(15, 213, SCREEN_WIDTH-70, 20)];
        _progress.continuous = NO;
        [_progress setMinimumValue:0.0];
        _progress.minimumTrackTintColor = Color_Active_Button_1;
        _progress.maximumTrackTintColor = Color_Theme_2;
        [_progress setThumbImage:[UIImage imageNamed:Image_PlayerforwardImage] forState:UIControlStateNormal];
        [_progress addTarget:self action:@selector(progressChange:) forControlEvents:UIControlEventValueChanged];
        [self.playView addSubview: _progress];
        
        _currentPlaybackTime = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-55 , 215, 50, 15)];
       // [_currentPlaybackTime setBackgroundColor:[UIColor whiteColor]];
        UIFont *font = [UIFont systemFontOfSize:7];
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] init];
        NSString *itemStr = @"00:00";
        NSAttributedString *item = [MuzzikItem formatAttrItem:itemStr color:Color_Active_Button_1 font:font];
        [text appendAttributedString:item];
        NSString *itemStr1 = @"/00:00";
        NSAttributedString *item1 = [MuzzikItem formatAttrItem:itemStr1 color:Color_Additional_5 font:font];
        [text appendAttributedString:item1];
        _currentPlaybackTime.attributedText = text;
        [self.playView addSubview:_currentPlaybackTime];
        
        playButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-51, 241, 36, 36)];
        [playButton addTarget:self action:@selector(playAction) forControlEvents:UIControlEventTouchUpInside];
        [self.playView addSubview:playButton];
        movedButton =[[UIButton alloc] initWithFrame:CGRectMake(15, 241, 36, 36)];
        [movedButton addTarget:self action:@selector(moveAction) forControlEvents:UIControlEventTouchUpInside];
        [self.playView addSubview:movedButton];
        
        PsongName = [[UILabel alloc] initWithFrame:CGRectMake(77, 240, SCREEN_WIDTH -140, 18)];
        [PsongName setFont:[UIFont fontWithName:Font_Next_Bold size:15]];
        
        
        PartistName = [[UILabel alloc] initWithFrame:CGRectMake(77, 264, SCREEN_WIDTH -140, 16)];
        PartistName.adjustsFontSizeToFitWidth = YES;
        [PartistName setFont:[UIFont fontWithName:Font_Next_Bold size:12]];
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(13, 293, SCREEN_WIDTH-26, 1)];
        [lineView setBackgroundColor:Color_Theme_2];
        [self.playView addSubview:lineView];
        
        [self.playView addSubview:PsongName];
        [self.playView addSubview:PartistName];
        
//        UISlider *slider = [[UISlider alloc ] initWithFrame:CGRectMake(10, 20, 300, 20)];
//        [slider addTarget:self action:@selector(updateValue:) forControlEvents:UIControlEventValueChanged];
//        [self addSubview:slider];
        closeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 293, (int)(SCREEN_WIDTH/4), 45)];
        [closeButton setImage:[UIImage imageNamed:Image_PlayercloseImage] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(closePlayView) forControlEvents:UIControlEventTouchUpInside];
        [self.playView addSubview:closeButton];
        
        commentButton = [[UIButton alloc] initWithFrame:CGRectMake((int)(SCREEN_WIDTH/4), 293, (int)(SCREEN_WIDTH/4), 45)];
        [commentButton setImage:[UIImage imageNamed:Image_PlayerreplyImage] forState:UIControlStateNormal];
        [commentButton addTarget:self action:@selector(commentAction) forControlEvents:UIControlEventTouchUpInside];
        [self.playView addSubview:commentButton];
        
        playModelButton = [[UIButton alloc] initWithFrame:CGRectMake((int)(SCREEN_WIDTH/2), 293,(int)(SCREEN_WIDTH/4), 45)];
        [playModelButton setImage:[UIImage imageNamed:Image_PlayerloopImage] forState:UIControlStateNormal];
        [playModelButton addTarget:self action:@selector(modelAction) forControlEvents:UIControlEventTouchUpInside];
        [self.playView addSubview:playModelButton];
        
        nextButton = [[UIButton alloc] initWithFrame:CGRectMake((int)(SCREEN_WIDTH*3/4), 293, (int)(SCREEN_WIDTH/4), 45)];
        [nextButton setImage:[UIImage imageNamed:Image_PlayernextsongImage] forState:UIControlStateNormal];
        [nextButton addTarget:self action:@selector(nextAction) forControlEvents:UIControlEventTouchUpInside];
        [self.playView addSubview:nextButton];
        
       
        songName = [[UILabel alloc] init];
        artistName = [[UILabel alloc] init];
         [songName setFrame:CGRectMake(77, 25, SCREEN_WIDTH -140, 15)];
        [songName setTextColor:[UIColor whiteColor]];
        [songName setFont:[UIFont fontWithName:Font_Next_Bold size:14]];
        [self.smallView addSubview:songName];
        artistName.frame=CGRectMake(77, 42, SCREEN_WIDTH -140, 15);
        artistName.adjustsFontSizeToFitWidth = YES;
        [artistName setFont:[UIFont fontWithName:Font_Next_Bold size:12]];
        [artistName setTextColor:[UIColor whiteColor]];
        [self.smallView addSubview:artistName];
       
    }
    return self;
}

#pragma mark - 播放器控制
-(void) showFullPlayer:(UIButton *) sender{
    if (_IsShowDetail) {
        [self.coverView setHidden:YES];
        CABasicAnimation *animation2 = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        animation2.duration = 0.825; // 持续时间
        animation2.removedOnCompletion = YES;
        animation2.autoreverses = NO;
        animation2.fillMode = kCAFillModeForwards;
        animation2.repeatCount = 1; // 重复次数
        animation2.fromValue = [NSNumber numberWithFloat:M_PI_4]; // 起始角度
        animation2.toValue = [NSNumber numberWithFloat:0.0]; // 终止角度
        [showButton.layer addAnimation:animation2 forKey:@"rotate-layer"];
        showButton.transform = CGAffineTransformMakeRotation(0);
        [showButton.layer addAnimation:animation2 forKey:@"move-rotate-layer"];
        
        _IsShowDetail = NO;
        if (_IsShowPlayList) {
            _IsShowPlayList = NO;
            [UIView animateWithDuration:0.825 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.titleView setFrame:CGRectMake(-SCREEN_WIDTH, 0, SCREEN_WIDTH, 64)];
                
            } completion:^(BOOL finished) {
                [smallPlayButton setHidden:NO];
                [songName setHidden:NO];
                [artistName setHidden:NO];
                [self setFrame:CGRectMake(0, 0, SCREEN_WIDTH, 64)];
                [self.playView setFrame:CGRectMake(0, -366, SCREEN_WIDTH, 338)];
                [self.playListView setFrame:CGRectMake(SCREEN_WIDTH, 64, SCREEN_WIDTH, 338)];
            }];
            [UIView animateWithDuration:0.6 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.playListView setFrame:CGRectMake(0, -366, SCREEN_WIDTH, 338)];
            } completion:nil];
        }else{
            [UIView animateWithDuration:0.825 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.titleView setFrame:CGRectMake(-SCREEN_WIDTH, 0, SCREEN_WIDTH, 64)];
                
            } completion:^(BOOL finished) {
                [smallPlayButton setHidden:NO];
                [songName setHidden:NO];
                [artistName setHidden:NO];
                [self setFrame:CGRectMake(0, 0, SCREEN_WIDTH, 64)];
            }];
            [UIView animateWithDuration:0.6 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.playView setFrame:CGRectMake(0, -366, SCREEN_WIDTH, 338)];
            } completion:nil];
        }
        
        
    }else{
        [self.coverView setHidden:NO];
        CABasicAnimation *animation2 = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        animation2.duration = 0.85; // 持续时间
        animation2.removedOnCompletion = YES;
        animation2.autoreverses = NO;
        animation2.fillMode = kCAFillModeForwards;
        animation2.repeatCount = 1; // 重复次数
        animation2.fromValue = [NSNumber numberWithFloat:0.0]; // 起始角度
        animation2.toValue = [NSNumber numberWithFloat:M_PI_4]; // 终止角度
        [showButton.layer addAnimation:animation2 forKey:@"rotate-layer"];
        showButton.transform = CGAffineTransformMakeRotation(M_PI_4);
        [showButton.layer addAnimation:animation2 forKey:@"move-rotate-layer"];
        
        _IsShowDetail = YES;
        [smallPlayButton setHidden:YES];
        [songName setHidden:YES];
        [artistName setHidden:YES];
        
        if (!_playMuzzik.isCheckFollow) {             //下载过，不再下载歌词
            _playMuzzik.isCheckFollow = YES;
            if (_playMuzzik.MuzzikUser) {
                [attentionButton setHidden:NO];
                nickLabel.text = _playMuzzik.MuzzikUser.name;
                NSLog(@"%@",[NSString stringWithFormat:@"%@%@?imageView2/1/w/100/h/100",BaseURL_image,_playMuzzik.MuzzikUser.avatar]);
                [headerImage setUserInteractionEnabled:YES];
                headerImage.user = _playMuzzik.MuzzikUser;
                [headerImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",BaseURL_image,_playMuzzik.MuzzikUser.avatar,Image_Size_Small]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:Image_user_placeHolder] options:SDWebImageRetryFailed ];
                
            }else{
                [attentionButton setHidden:YES];
                
                userInfo *user = [userInfo shareClass];
                if ([user.token length]>0) {
                    [headerImage setUserInteractionEnabled:YES];
                    MuzzikUser *muser = [MuzzikUser new];
                    muser.user_id = user.uid;
                    headerImage.user = muser;
                    [headerImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",BaseURL_image,user.avatar,Image_Size_Small]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:Image_user_placeHolder] options:SDWebImageRetryFailed ];
                    nickLabel.text = user.name;
                }else{
                    [attentionButton setHidden:YES];
                    [headerImage setUserInteractionEnabled:NO];
                    nickLabel.text = @"Muzzik";
                    [headerImage setBackgroundImage:[UIImage imageNamed:@"logo"] forState:UIControlStateNormal];
                }
            }
            if ([[userInfo shareClass].uid length]>0 &&[_playMuzzik.MuzzikUser.user_id isEqualToString:[userInfo shareClass].uid]) {
                [attentionButton setHidden:YES];
            }else if(_playMuzzik.MuzzikUser.user_id){
                ASIHTTPRequest *requestUser = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/user/%@",BaseURL,_playMuzzik.MuzzikUser.user_id]]];
                [requestUser addBodyDataSourceWithJsonByDic:nil Method:GetMethod auth:YES];
                __weak ASIHTTPRequest *weakrequestUser = requestUser;
                [requestUser setCompletionBlock :^{
                    NSLog(@"%@",[weakrequestUser responseString]);
                    NSLog(@"%d",[weakrequestUser responseStatusCode]);
                    if ([weakrequestUser responseStatusCode] == 200) {
                        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequestUser responseData]  options:NSJSONReadingMutableContainers error:nil];
                        if (![[dic objectForKey:@"isFollow"] boolValue]) {
                            [attentionButton setHidden:NO];
                        }else{
                            [attentionButton setHidden:YES];
                        }
                    }
                }];
                [requestUser setFailedBlock:^{
                    NSLog(@"%@",[weakrequestUser error]);
                }];
                [requestUser startAsynchronous];
            }
            if (![userInfo shareClass].hideLyric) {
                [self.lyricArray removeAllObjects];
                [lyricTableView reloadData];
                if ([[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] == kReachableViaWiFi) {
                    ASIHTTPRequest *requestForm1 = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Music_Lyric_get]]];
                    [requestForm1 addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:[[NSString stringWithFormat:@"%@",_playMuzzik.music.name] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:@"q"] Method:GetMethod auth:NO];
                    [requestForm1 setUseCookiePersistence:NO];
                    __weak ASIHTTPRequest *weakrequest1 = requestForm1;
                    [requestForm1 setCompletionBlock :^{
                        //  NSLog(@"%@",[weakrequest1 responseString]);
                        // NSLog(@"URL:%@     status:%d",[weakrequest1 originalURL],[weakrequest1 responseStatusCode]);
                        if ([weakrequest1 responseStatusCode] == 200) {
                            NSData *data = [weakrequest1 responseData];
                            NSDictionary *dic1 = [NSJSONSerialization JSONObjectWithData:data  options:NSJSONReadingMutableContainers error:nil];
                            NSString *lyricAddress ;
                            if ([[dic1 objectForKey:@"music"] count]>0) {
                                for (NSDictionary *dic in [dic1 objectForKey:@"music"]) {
                                    if ([[dic objectForKey:@"artist"] isEqualToString:_playMuzzik.music.artist] && [[dic objectForKey:@"name"] isEqualToString:_playMuzzik.music.name]) {
                                        lyricAddress = [dic objectForKey:@"lyric"];
                                        break;
                                    }
                                }
                                if ([lyricAddress length]>0) {
                                    ASIHTTPRequest *lyricRequest1 = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[lyricAddress stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
                                    __weak ASIHTTPRequest *lrcRequest1 = lyricRequest1;
                                    [lyricRequest1 setCompletionBlock:^{
                                        NSString *lyric =  [[NSString alloc] initWithData:[lrcRequest1 responseData]   encoding:NSUTF8StringEncoding];
                                        [UIView animateWithDuration:0.2 animations:^{
                                            [lyricTipsLabel setAlpha:0];
                                        }completion:^(BOOL finished) {
                                            [self parseLrcLine:lyric];
                                            if ([self.lyricArray count] == 0) {
                                                [lyricTipsLabel setText:@"暂无歌词"];
                                                [UIView animateWithDuration:0.3 animations:^{
                                                    [lyricTipsLabel setAlpha:1];
                                                }];
                                            }
                                        }];
                                        
                                        // NSLog(@"%@",self.lyricArray);
                                        //  NSLog(@"%@",[lrcRequest1 responseString]);
                                        //  NSLog(@"URL:%@     status:%d",[lrcRequest1 originalURL],[lrcRequest1 responseStatusCode]);
                                    }];
                                    [lyricRequest1 setFailedBlock:^{
                                        [UIView animateWithDuration:0.3 animations:^{
                                            [UIView animateWithDuration:0.3 animations:^{
                                                [lyricTipsLabel setAlpha:0];
                                            }];
                                        } completion:^(BOOL finished) {
                                            [lyricTipsLabel setText:@"暂无歌词"];
                                            [UIView animateWithDuration:0.3 animations:^{
                                                [lyricTipsLabel setAlpha:1];
                                            }];
                                        }];
                                        
                                        NSLog(@"%@",lrcRequest1.error);
                                    }];
                                    [lyricRequest1 startAsynchronous];
                                }
                                else{
                                    [UIView animateWithDuration:0.3 animations:^{
                                        [UIView animateWithDuration:0.3 animations:^{
                                            [lyricTipsLabel setAlpha:0];
                                        }];
                                    } completion:^(BOOL finished) {
                                        [lyricTipsLabel setText:@"暂无歌词"];
                                        [UIView animateWithDuration:0.3 animations:^{
                                            [lyricTipsLabel setAlpha:0.5];
                                        }];
                                    }];
                                }
                            }else{
                                [UIView animateWithDuration:0.3 animations:^{
                                    [UIView animateWithDuration:0.3 animations:^{
                                        [lyricTipsLabel setAlpha:0];
                                    }];
                                } completion:^(BOOL finished) {
                                    [lyricTipsLabel setText:@"暂无歌词"];
                                    [UIView animateWithDuration:0.3 animations:^{
                                        [lyricTipsLabel setAlpha:0.5];
                                    }];
                                }];
                            }
                            
                        }
                        else{
                            [UIView animateWithDuration:0.3 animations:^{
                                [UIView animateWithDuration:0.3 animations:^{
                                    [lyricTipsLabel setAlpha:0];
                                }];
                            } completion:^(BOOL finished) {
                                [lyricTipsLabel setText:@"暂无歌词"];
                                [UIView animateWithDuration:0.3 animations:^{
                                    [lyricTipsLabel setAlpha:1];
                                }];
                            }];
                            //[SVProgressHUD showErrorWithStatus:[dic objectForKey:@"message"]];
                        }
                    }];
                    [requestForm1 setFailedBlock:^{
                        NSLog(@"URL:%@     status:%d",[weakrequest1 originalURL],[weakrequest1 responseStatusCode]);
                        NSLog(@"  kkk%@",[weakrequest1 error]);
                        [UIView animateWithDuration:0.3 animations:^{
                            [UIView animateWithDuration:0.3 animations:^{
                                [lyricTipsLabel setAlpha:0];
                            }];
                        } completion:^(BOOL finished) {
                            [lyricTipsLabel setText:@"暂无歌词"];
                            [UIView animateWithDuration:0.3 animations:^{
                                [lyricTipsLabel setAlpha:1];
                            }];
                        }];
                    }];
                    [requestForm1 startAsynchronous];
                }
                else{
                    [lyricTipsLabel setText:@"请求歌词"];
                    [UIView animateWithDuration:0.5 animations:^{
                        [lyricTipsLabel setAlpha:0.5];
                    }completion:^(BOOL finished) {
                        ASIHTTPRequest *requestForm1 = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Music_Lyric_get]]];
                        [requestForm1 addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:[[NSString stringWithFormat:@"%@",_playMuzzik.music.name] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:@"q"] Method:GetMethod auth:NO];
                        [requestForm1 setUseCookiePersistence:NO];
                        __weak ASIHTTPRequest *weakrequest1 = requestForm1;
                        [requestForm1 setCompletionBlock :^{
                            //  NSLog(@"%@",[weakrequest1 responseString]);
                            // NSLog(@"URL:%@     status:%d",[weakrequest1 originalURL],[weakrequest1 responseStatusCode]);
                            if ([weakrequest1 responseStatusCode] == 200) {
                                NSData *data = [weakrequest1 responseData];
                                NSDictionary *dic1 = [NSJSONSerialization JSONObjectWithData:data  options:NSJSONReadingMutableContainers error:nil];
                                NSString *lyricAddress;
                                if ([[dic1 objectForKey:@"music"] count]>0) {
                                    for (NSDictionary *dic in [dic1 objectForKey:@"music"]) {
                                        if ([[dic objectForKey:@"artist"] isEqualToString:_playMuzzik.music.artist] && [[dic objectForKey:@"name"] isEqualToString:_playMuzzik.music.name]) {
                                            lyricAddress = [dic objectForKey:@"lyric"];
                                            break;
                                        }
                                    }
                                    if ([lyricAddress length]>0) {
                                        ASIHTTPRequest *lyricRequest1 = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[lyricAddress stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
                                        __weak ASIHTTPRequest *lrcRequest1 = lyricRequest1;
                                        [lyricRequest1 setCompletionBlock:^{
                                            NSString *lyric =  [[NSString alloc] initWithData:[lrcRequest1 responseData]   encoding:NSUTF8StringEncoding];
                                            [UIView animateWithDuration:0.2 animations:^{
                                                [lyricTipsLabel setAlpha:0];
                                            }completion:^(BOOL finished) {
                                                [self parseLrcLine:lyric];
                                                if ([self.lyricArray count] == 0) {
                                                    [lyricTipsLabel setText:@"暂无歌词"];
                                                    [UIView animateWithDuration:0.3 animations:^{
                                                        [lyricTipsLabel setAlpha:1];
                                                    }];
                                                }
                                            }];
                                            
                                            // NSLog(@"%@",self.lyricArray);
                                            //  NSLog(@"%@",[lrcRequest1 responseString]);
                                            //  NSLog(@"URL:%@     status:%d",[lrcRequest1 originalURL],[lrcRequest1 responseStatusCode]);
                                        }];
                                        [lyricRequest1 setFailedBlock:^{
                                            [UIView animateWithDuration:0.3 animations:^{
                                                [UIView animateWithDuration:0.3 animations:^{
                                                    [lyricTipsLabel setAlpha:0];
                                                }];
                                            } completion:^(BOOL finished) {
                                                [lyricTipsLabel setText:@"暂无歌词"];
                                                [UIView animateWithDuration:0.3 animations:^{
                                                    [lyricTipsLabel setAlpha:1];
                                                }];
                                            }];
                                            
                                            NSLog(@"%@",lrcRequest1.error);
                                        }];
                                        [lyricRequest1 startAsynchronous];
                                    }
                                    else{
                                        [UIView animateWithDuration:0.3 animations:^{
                                            [UIView animateWithDuration:0.3 animations:^{
                                                [lyricTipsLabel setAlpha:0];
                                            }];
                                        } completion:^(BOOL finished) {
                                            [lyricTipsLabel setText:@"暂无歌词"];
                                            [UIView animateWithDuration:0.3 animations:^{
                                                [lyricTipsLabel setAlpha:0.5];
                                            }];
                                        }];
                                    }
                                }else{
                                    [UIView animateWithDuration:0.3 animations:^{
                                        [UIView animateWithDuration:0.3 animations:^{
                                            [lyricTipsLabel setAlpha:0];
                                        }];
                                    } completion:^(BOOL finished) {
                                        [lyricTipsLabel setText:@"暂无歌词"];
                                        [UIView animateWithDuration:0.3 animations:^{
                                            [lyricTipsLabel setAlpha:0.5];
                                        }];
                                    }];
                                }
                                
                            }
                            else{
                                [UIView animateWithDuration:0.3 animations:^{
                                    [UIView animateWithDuration:0.3 animations:^{
                                        [lyricTipsLabel setAlpha:0];
                                    }];
                                } completion:^(BOOL finished) {
                                    [lyricTipsLabel setText:@"暂无歌词"];
                                    [UIView animateWithDuration:0.3 animations:^{
                                        [lyricTipsLabel setAlpha:1];
                                    }];
                                }];
                                //[SVProgressHUD showErrorWithStatus:[dic objectForKey:@"message"]];
                            }
                        }];
                        [requestForm1 setFailedBlock:^{
                            NSLog(@"URL:%@     status:%d",[weakrequest1 originalURL],[weakrequest1 responseStatusCode]);
                            NSLog(@"  kkk%@",[weakrequest1 error]);
                            [UIView animateWithDuration:0.3 animations:^{
                                [UIView animateWithDuration:0.3 animations:^{
                                    [lyricTipsLabel setAlpha:0];
                                }];
                            } completion:^(BOOL finished) {
                                [lyricTipsLabel setText:@"暂无歌词"];
                                [UIView animateWithDuration:0.3 animations:^{
                                    [lyricTipsLabel setAlpha:1];
                                }];
                            }];
                        }];
                        [requestForm1 startAsynchronous];
                    }];
                }
            }
            else{
                [lyricTipsLabel setAlpha:1];
                [lyricTipsLabel setText:@"暂无歌词"];
            }
            
        }
        

        [self setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        [UIView animateWithDuration:0.85 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.titleView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, 64)];
            
        } completion:^(BOOL finished) {
            
        }];
        [UIView animateWithDuration:0.75 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.playView setFrame:CGRectMake(0, 64, SCREEN_WIDTH, 338)];
        } completion:nil];
    }
}
#pragma mark - 播放列表展示
-(void)showPlayList{
    if (_IsShowPlayList) {
        _IsShowPlayList = NO;
        [UIView animateWithDuration:0.60 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.playListView setFrame:CGRectMake(SCREEN_WIDTH, 64, SCREEN_WIDTH, 338)];
            [self.playView setFrame:CGRectMake(0, 64, SCREEN_WIDTH, 338)];
        }completion:nil];
    }else{
        _IsShowPlayList = YES;
        musicPlayer *player = [musicPlayer shareClass];
        userInfo *user = [userInfo shareClass];
        playListArray = [NSMutableArray array];

        if (![player.listType isEqualToString:SquareList]) {
            [playListArray addObject:[user.playList objectForKey:Constant_userInfo_square]];
        }
        
        if (![player.listType isEqualToString:suggestList]) {
            if (!user.checkSuggest) {
                ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/muzzik/suggest",BaseURL]]];
                [request addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:@"10",Parameter_Limit,[NSNumber numberWithBool:YES],@"image", nil] Method:GetMethod auth:NO];
                __weak ASIHTTPRequest *weakrequest = request;
                [request setCompletionBlock :^{
                    //    NSLog(@"%@",weakrequest.originalURL);
                    NSLog(@"%@",[weakrequest responseString]);
                    NSData *data = [weakrequest responseData];
                    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                    if (dic&&[[dic objectForKey:@"muzziks"]count]>0) {
                        [MuzzikItem SetUserInfoWithMuzziks:[[muzzik new] makeMuzziksByMuzzikArray:[dic objectForKey:@"muzziks"]] title:Constant_userInfo_suggest description:[NSString stringWithFormat:@"推荐列表"]];
                        [playListArray addObject:[user.playList objectForKey:Constant_userInfo_suggest]];
                        [self checkReloadPlayListTable];
                    }
                }];
                [request setFailedBlock:^{
                    NSLog(@"%@,%@",[weakrequest error],[weakrequest responseString]);
                }];
                [request startAsynchronous];
            }else{
                if ([[[user.playList objectForKey:Constant_userInfo_suggest] objectForKey:@"muzziks"] count]>0) {
                    [playListArray addObject:[user.playList objectForKey:Constant_userInfo_suggest]];
                }
                
            }
            
        }
        if ([user.token length]>0) {
            if (![player.listType isEqualToString:ownList]) {
                if (!user.checkOwn) {
                    ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/user/%@/muzziks",BaseURL,user.uid]]];
                    [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:30],Parameter_Limit ,nil] Method:GetMethod auth:YES];
                    __weak ASIHTTPRequest *weakrequest = requestForm;
                    [requestForm setCompletionBlock :^{
                        if ([weakrequest responseStatusCode] == 200) {
                            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData] options:NSJSONReadingMutableContainers error:nil];
                            muzzik *tempMuzzik = [muzzik new];
                            if ([[dic objectForKey:@"muzziks"] count]>0) {
                                [MuzzikItem SetUserInfoWithMuzziks:[tempMuzzik makeMuzziksByMuzzikArray:[dic objectForKey:@"muzziks"]] title:Constant_userInfo_own description:[NSString stringWithFormat:@"我的Muzzik"]];
                                [playListArray addObject:[user.playList objectForKey:Constant_userInfo_own]];
                                [self checkReloadPlayListTable];
                            }
                            
                        }
                    }];
                    [requestForm setFailedBlock:^{
                        NSLog(@"%@",[weakrequest error]);
                    }];
                    [requestForm startAsynchronous];
                }else{
                    if ([[[user.playList objectForKey:Constant_userInfo_own] objectForKey:@"muzziks"] count]>0) {
                        [playListArray addObject:[user.playList objectForKey:Constant_userInfo_own]];
                    }
                    
                }
                
            }
            
            
            if (![player.listType isEqualToString:feedList]) {
                if (user.checkFollow) {
                    if ([[[user.playList objectForKey:Constant_userInfo_follow] objectForKey:@"muzziks"] count]>0) {
                        [playListArray addObject:[user.playList objectForKey:Constant_userInfo_follow]];
                    }
                }else{
                    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/muzzik/feeds",BaseURL]]];
                    [request addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:30] forKey:Parameter_Limit] Method:GetMethod auth:YES];
                    __weak ASIHTTPRequest *weakrequest = request;
                    [request setCompletionBlock :^{
                        // NSLog(@"%@",[weakrequest responseString]);
                        NSData *data = [weakrequest responseData];
                        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                        if (dic && [[dic objectForKey:@"muzziks"] count]>0 ) {
                            muzzik *muzzikToy = [muzzik new];
                            [MuzzikItem SetUserInfoWithMuzziks:[muzzikToy makeMuzziksByMuzzikArray:[dic objectForKey:@"muzziks"]] title:Constant_userInfo_follow description:[NSString stringWithFormat:@"关注列表"]];
                            [playListArray addObject:[user.playList objectForKey:Constant_userInfo_follow]];
                            [self checkReloadPlayListTable];
                            
                        }
                    }];
                    [request setFailedBlock:^{
                        NSLog(@"%@,%@",[weakrequest error],[weakrequest responseString]);
                    }];
                    [request startAsynchronous];
                }
                
            }
            if (![player.listType isEqualToString:MovedList]) {
                if (user.checkMove) {
                    if ([[[user.playList objectForKey:Constant_userInfo_move] objectForKey:@"muzziks"] count]>0) {
                        [playListArray addObject:[user.playList objectForKey:Constant_userInfo_move]];
                    }
                }else{
                    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/user/movedMuzzik",BaseURL]]];
                    [request addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:30] forKey:Parameter_Limit] Method:GetMethod auth:YES];
                    __weak ASIHTTPRequest *weakrequest = request;
                    [request setCompletionBlock :^{
                        // NSLog(@"%@",[weakrequest responseString]);
                        NSData *data = [weakrequest responseData];
                        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                        if (dic && [[dic objectForKey:@"muzziks"] count]>0 ) {
                            muzzik *muzzikToy = [muzzik new];

                            [MuzzikItem SetUserInfoWithMuzziks:[muzzikToy makeMuzziksByMuzzikArray:[dic objectForKey:@"muzziks"]] title:Constant_userInfo_move description:[NSString stringWithFormat:@"喜欢列表"]];
                            [playListArray addObject:[user.playList objectForKey:Constant_userInfo_move]];
                            [self checkReloadPlayListTable];
                        }
                    }];
                    [request setFailedBlock:^{
                        NSLog(@"%@,%@",[weakrequest error],[weakrequest responseString]);
                    }];
                    [request startAsynchronous];
                }
                
            }
        }
        if (![player.listType isEqualToString:TempList] && user.checkTemp ) {
            [playListArray addObject:[user.playList objectForKey:Constant_userInfo_temp]];
        }
        [self checkReloadPlayListTable];
        [UIView animateWithDuration:0.60 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.playListView setFrame:CGRectMake(0, 64, SCREEN_WIDTH, 338)];
            [self.playView setFrame:CGRectMake(-SCREEN_WIDTH, 64, SCREEN_WIDTH, 338)];
        }completion:nil];
    }
}

-(void)checkReloadPlayListTable{
    userInfo *user = [userInfo shareClass];
    if ([user.token length]>0) {
        if (user.checkFollow&& user.checkMove && user.checkOwn && user.checkSquare && user.checkSuggest) {
            [plistTableView reloadData];
        }
    }else{
        if (user.checkSquare && user.checkSuggest) {
            [plistTableView reloadData];
        }
    }
    
    
}
-(void)playButtonEvent
{
    Globle *glob = [Globle shareGloble];
    if (glob.isPlaying) {
        glob.isPlaying = NO;
    }else{
        glob.isPlaying = YES;
    }
    if (audioPlayer.state == AudioPlayerStatePaused){
        [audioPlayer resume];
        [self startTimer];
        backImageView.layer.speed = 0.2;
        CFTimeInterval pausedTime = [backImageView.layer timeOffset];
        CFTimeInterval timeSincePause = [backImageView.layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
        backImageView.layer.beginTime = timeSincePause;
        
    }
    else{
        [audioPlayer pause];
        [_progressUpdateTimer invalidate];
        CFTimeInterval pausedTime = [backImageView.layer convertTime:CACurrentMediaTime() fromLayer:nil];
        backImageView.layer.speed = 0.0;
        backImageView.layer.timeOffset = pausedTime;

    }
    [playButton setImage:glob.isPlaying?[UIImage imageNamed:@"stopImage"]:[UIImage imageNamed:@"playImage"] forState:UIControlStateNormal];

}
//-(void)playBackButtonEvent
//{
//    isPlayBack+=1;
//    NSString * name = nil;
//    NSString * title = nil;
//    switch (isPlayBack) {
//        case 0:
//            name = @"order.png";
//            title = @"顺序播放";
//            break;
//        case 1:
//            name = @"random.png";
//            title = @"随机播放";
//            break;
//        case 2:
//            name = @"lock.png";
//            title = @"单曲播放";
//            isPlayBack=-1;
//            break;
//        default:
//            break;
//    }
//    [_playbackButton setImage:[UIImage imageNamed:name] forState:UIControlStateNormal];
//
//}

-(void)preButtonEvent:(UIButton *)btn
{
    [self stopEverything];
    [_delegate radioView:self preSwitchMusic:btn];
}

-(void)nextButtonEvent:(UIButton *)btn
{
    [self stopEverything];
    [_delegate radioView:self nextSwitchMusic:btn];
}
-(void)playListButtonEvent:(UIButton *)btn
{
    [_delegate radioView:self playListButton:btn];
}

-(void)startTimer
{
    [_progressUpdateTimer fire];
}
-(void)startMusic
{
    
    NSLog(@"%@",self.playMuzzik.music.name);
    [audioPlayer play:self.musicUrl];
}

-(NSAttributedString*)TimeformatFromSeconds:(int)seconds total:(int)total
{
    int totalm = seconds/(60);
    int totalConstant = total/(60);
    
    int th = totalConstant/(60);
    int h = totalm/(60);
    
    int tm = totalConstant%(60);
    int m = totalm%(60);
    
    int ts = total%(60);
    int s = seconds%(60);
    UIFont *font = [UIFont systemFontOfSize:7];
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] init];
    NSString *itemStr;
    
    NSString *itemStr1;
    
    
    if (h==0) {
        itemStr = [NSString stringWithFormat:@"%02d:%02d", m, s];
    }
    else{
        itemStr = [NSString stringWithFormat:@"%02d:%02d:%02d", h, m, s];
    }
    NSAttributedString *item = [MuzzikItem formatAttrItem:itemStr color:Color_Active_Button_1 font:font];
    [text appendAttributedString:item];
    
    if (th==0) {
        itemStr1 = [NSString stringWithFormat:@"/%02d:%02d", tm, ts];
    }
    else{
        itemStr1 = [NSString stringWithFormat:@"/%02d:%02d:%02d", th, tm, ts];
    }
    if ([self.lyricArray count]>0) {
        for (NSDictionary *dic in self.lyricArray) {
            if ([[[dic allKeys] objectAtIndex:0] isEqualToString:itemStr]) {
                [self performSelector:@selector(scrolllyric:) withObject:dic afterDelay:1.5];
                
                break;
            }
        }
    }

    NSAttributedString *item1 = [MuzzikItem formatAttrItem:itemStr1 color:Color_Additional_5 font:font];
    [text appendAttributedString:item1];
    return  text;
    
}
-(void)scrolllyric:(NSDictionary *)dic{
    if ([self.lyricArray containsObject:dic]) {
        [lyricTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.lyricArray indexOfObject:dic] inSection:0]  atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
    
}
-(void)stopEverything
{
    self.playNext = NO;
    [audioPlayer stop];
}
-(void)setPlayMuzzik:(muzzik *)playMuzzik{
    
    isError = NO;
   // NSLog(@"%@",[NSString stringWithFormat:@"%@/%@",playMuzzik.music.name,playMuzzik.music.artist]);
    if (!([playMuzzik.muzzik_id isEqualToString:_playMuzzik.muzzik_id]||([playMuzzik.muzzik_id length] == 0 &&[playMuzzik.music.music_id isEqualToString:_playMuzzik.music.music_id]))||([[musicPlayer shareClass].MusicArray count] ==1 && ![playMuzzik.muzzik_id isEqualToString:_playMuzzik.muzzik_id])) {
        [Globle shareGloble].isPause = NO;
        muzzik *lastMuzzik = [[musicPlayer shareClass].MusicArray lastObject];
        if ([lastMuzzik.muzzik_id isEqualToString:playMuzzik.muzzik_id] ||([lastMuzzik.muzzik_id length] == 0 && [lastMuzzik.music.music_id isEqualToString:playMuzzik.music.music_id])) {
            MuzzikRequestCenter *center = [MuzzikRequestCenter shareClass];
            [center requestToAddMoreMuzziks:[musicPlayer shareClass].MusicArray];
        }
        _playMuzzik.isCheckFollow = NO;
        _playMuzzik = playMuzzik;
        if (_IsShowDetail) {
            _playMuzzik.isCheckFollow = YES;
            if (_playMuzzik.MuzzikUser) {
                [attentionButton setHidden:NO];
                nickLabel.text = _playMuzzik.MuzzikUser.name;
                NSLog(@"%@",[NSString stringWithFormat:@"%@%@?imageView2/1/w/100/h/100",BaseURL_image,_playMuzzik.MuzzikUser.avatar]);
                [headerImage setUserInteractionEnabled:YES];
                headerImage.user = _playMuzzik.MuzzikUser;
                [headerImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",BaseURL_image,_playMuzzik.MuzzikUser.avatar,Image_Size_Small]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:Image_user_placeHolder] options:SDWebImageRetryFailed ];
            }else{
                [attentionButton setHidden:YES];
                [headerImage setUserInteractionEnabled:NO];
                userInfo *user = [userInfo shareClass];
                if ([user.token length]>0) {
                    [headerImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",BaseURL_image,user.avatar,Image_Size_Small]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:Image_user_placeHolder] options:SDWebImageRetryFailed ];
                    nickLabel.text = user.name;
                }else{
                    [attentionButton setHidden:YES];
                    [headerImage setUserInteractionEnabled:NO];
                    nickLabel.text = @"Muzzik";
                    [headerImage setBackgroundImage:[UIImage imageNamed:@"logo"] forState:UIControlStateNormal];
                }
            }
            if (![userInfo shareClass].hideLyric) {
                [self.lyricArray removeAllObjects];
                [lyricTableView reloadData];
                if ([[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] == kReachableViaWiFi) {
                    ASIHTTPRequest *requestForm1 = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Music_Lyric_get]]];
                    [requestForm1 addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:[[NSString stringWithFormat:@"%@",_playMuzzik.music.name] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:@"q"] Method:GetMethod auth:NO];
                    [requestForm1 setUseCookiePersistence:NO];
                    __weak ASIHTTPRequest *weakrequest1 = requestForm1;
                    [requestForm1 setCompletionBlock :^{
                        //  NSLog(@"%@",[weakrequest1 responseString]);
                        // NSLog(@"URL:%@     status:%d",[weakrequest1 originalURL],[weakrequest1 responseStatusCode]);
                        if ([weakrequest1 responseStatusCode] == 200) {
                            NSData *data = [weakrequest1 responseData];
                            NSDictionary *dic1 = [NSJSONSerialization JSONObjectWithData:data  options:NSJSONReadingMutableContainers error:nil];
                            NSString *lyricAddress ;
                            if ([[dic1 objectForKey:@"music"] count]>0) {
                                for (NSDictionary *dic in [dic1 objectForKey:@"music"]) {
                                    if ([[dic objectForKey:@"artist"] isEqualToString:_playMuzzik.music.artist] && [[dic objectForKey:@"name"] isEqualToString:_playMuzzik.music.name]) {
                                        lyricAddress = [dic objectForKey:@"lyric"];
                                        break;
                                    }
                                }
                                if ([lyricAddress length]>0) {
                                    ASIHTTPRequest *lyricRequest1 = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[lyricAddress stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
                                    __weak ASIHTTPRequest *lrcRequest1 = lyricRequest1;
                                    [lyricRequest1 setCompletionBlock:^{
                                        NSString *lyric =  [[NSString alloc] initWithData:[lrcRequest1 responseData]   encoding:NSUTF8StringEncoding];
                                        [UIView animateWithDuration:0.2 animations:^{
                                            [lyricTipsLabel setAlpha:0];
                                        }completion:^(BOOL finished) {
                                            [self parseLrcLine:lyric];
                                            if ([self.lyricArray count] == 0) {
                                                [lyricTipsLabel setText:@"暂无歌词"];
                                                [UIView animateWithDuration:0.3 animations:^{
                                                    [lyricTipsLabel setAlpha:1];
                                                }];
                                            }
                                        }];
                                        
                                        // NSLog(@"%@",self.lyricArray);
                                        //  NSLog(@"%@",[lrcRequest1 responseString]);
                                        //  NSLog(@"URL:%@     status:%d",[lrcRequest1 originalURL],[lrcRequest1 responseStatusCode]);
                                    }];
                                    [lyricRequest1 setFailedBlock:^{
                                        [UIView animateWithDuration:0.3 animations:^{
                                            [UIView animateWithDuration:0.3 animations:^{
                                                [lyricTipsLabel setAlpha:0];
                                            }];
                                        } completion:^(BOOL finished) {
                                            [lyricTipsLabel setText:@"暂无歌词"];
                                            [UIView animateWithDuration:0.3 animations:^{
                                                [lyricTipsLabel setAlpha:1];
                                            }];
                                        }];
                                        
                                        NSLog(@"%@",lrcRequest1.error);
                                    }];
                                    [lyricRequest1 startAsynchronous];
                                }
                                else{
                                    [UIView animateWithDuration:0.3 animations:^{
                                        [UIView animateWithDuration:0.3 animations:^{
                                            [lyricTipsLabel setAlpha:0];
                                        }];
                                    } completion:^(BOOL finished) {
                                        [lyricTipsLabel setText:@"暂无歌词"];
                                        [UIView animateWithDuration:0.3 animations:^{
                                            [lyricTipsLabel setAlpha:0.5];
                                        }];
                                    }];
                                }
                                
                            }else{
                                [UIView animateWithDuration:0.3 animations:^{
                                    [UIView animateWithDuration:0.3 animations:^{
                                        [lyricTipsLabel setAlpha:0];
                                    }];
                                } completion:^(BOOL finished) {
                                    [lyricTipsLabel setText:@"暂无歌词"];
                                    [UIView animateWithDuration:0.3 animations:^{
                                        [lyricTipsLabel setAlpha:0.5];
                                    }];
                                }];
                            }
                            
                        }
                        else{
                            [UIView animateWithDuration:0.3 animations:^{
                                [UIView animateWithDuration:0.3 animations:^{
                                    [lyricTipsLabel setAlpha:0];
                                }];
                            } completion:^(BOOL finished) {
                                [lyricTipsLabel setText:@"暂无歌词"];
                                [UIView animateWithDuration:0.3 animations:^{
                                    [lyricTipsLabel setAlpha:1];
                                }];
                            }];
                            //[SVProgressHUD showErrorWithStatus:[dic objectForKey:@"message"]];
                        }
                    }];
                    [requestForm1 setFailedBlock:^{
                        NSLog(@"URL:%@     status:%d",[weakrequest1 originalURL],[weakrequest1 responseStatusCode]);
                        NSLog(@"  kkk%@",[weakrequest1 error]);
                        [UIView animateWithDuration:0.3 animations:^{
                            [UIView animateWithDuration:0.3 animations:^{
                                [lyricTipsLabel setAlpha:0];
                            }];
                        } completion:^(BOOL finished) {
                            [lyricTipsLabel setText:@"暂无歌词"];
                            [UIView animateWithDuration:0.3 animations:^{
                                [lyricTipsLabel setAlpha:1];
                            }];
                        }];
                    }];
                    [requestForm1 startAsynchronous];
                }
                else{
                    [lyricTipsLabel setText:@"请求歌词"];
                    [UIView animateWithDuration:0.5 animations:^{
                        [lyricTipsLabel setAlpha:0.5];
                    }completion:^(BOOL finished) {
                        ASIHTTPRequest *requestForm1 = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Music_Lyric_get]]];
                        [requestForm1 addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:[[NSString stringWithFormat:@"%@",_playMuzzik.music.name] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:@"q"] Method:GetMethod auth:NO];
                        [requestForm1 setUseCookiePersistence:NO];
                        __weak ASIHTTPRequest *weakrequest1 = requestForm1;
                        [requestForm1 setCompletionBlock :^{
                            //  NSLog(@"%@",[weakrequest1 responseString]);
                            // NSLog(@"URL:%@     status:%d",[weakrequest1 originalURL],[weakrequest1 responseStatusCode]);
                            if ([weakrequest1 responseStatusCode] == 200) {
                                NSData *data = [weakrequest1 responseData];
                                NSDictionary *dic1 = [NSJSONSerialization JSONObjectWithData:data  options:NSJSONReadingMutableContainers error:nil];
                                NSString *lyricAddress ;
                                if ([[dic1 objectForKey:@"music"] count]>0) {
                                    for (NSDictionary *dic in [dic1 objectForKey:@"music"]) {
                                        if ([[dic objectForKey:@"artist"] isEqualToString:_playMuzzik.music.artist] && [[dic objectForKey:@"name"] isEqualToString:_playMuzzik.music.name]) {
                                            lyricAddress = [dic objectForKey:@"lyric"];
                                            break;
                                        }
                                    }
                                    if ([lyricAddress length]>0) {
                                        ASIHTTPRequest *lyricRequest1 = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[lyricAddress stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
                                        __weak ASIHTTPRequest *lrcRequest1 = lyricRequest1;
                                        [lyricRequest1 setCompletionBlock:^{
                                            NSString *lyric =  [[NSString alloc] initWithData:[lrcRequest1 responseData]   encoding:NSUTF8StringEncoding];
                                            [UIView animateWithDuration:0.2 animations:^{
                                                [lyricTipsLabel setAlpha:0];
                                            }completion:^(BOOL finished) {
                                                [self parseLrcLine:lyric];
                                                if ([self.lyricArray count] == 0) {
                                                    [lyricTipsLabel setText:@"暂无歌词"];
                                                    [UIView animateWithDuration:0.3 animations:^{
                                                        [lyricTipsLabel setAlpha:1];
                                                    }];
                                                }
                                            }];
                                            
                                            // NSLog(@"%@",self.lyricArray);
                                            //  NSLog(@"%@",[lrcRequest1 responseString]);
                                            //  NSLog(@"URL:%@     status:%d",[lrcRequest1 originalURL],[lrcRequest1 responseStatusCode]);
                                        }];
                                        [lyricRequest1 setFailedBlock:^{
                                            [UIView animateWithDuration:0.3 animations:^{
                                                [UIView animateWithDuration:0.3 animations:^{
                                                    [lyricTipsLabel setAlpha:0];
                                                }];
                                            } completion:^(BOOL finished) {
                                                [lyricTipsLabel setText:@"暂无歌词"];
                                                [UIView animateWithDuration:0.3 animations:^{
                                                    [lyricTipsLabel setAlpha:1];
                                                }];
                                            }];
                                            
                                            NSLog(@"%@",lrcRequest1.error);
                                        }];
                                        [lyricRequest1 startAsynchronous];
                                    }
                                    else{
                                        [UIView animateWithDuration:0.3 animations:^{
                                            [UIView animateWithDuration:0.3 animations:^{
                                                [lyricTipsLabel setAlpha:0];
                                            }];
                                        } completion:^(BOOL finished) {
                                            [lyricTipsLabel setText:@"暂无歌词"];
                                            [UIView animateWithDuration:0.3 animations:^{
                                                [lyricTipsLabel setAlpha:0.5];
                                            }];
                                        }];
                                    }
                                }else{
                                    [UIView animateWithDuration:0.3 animations:^{
                                        [UIView animateWithDuration:0.3 animations:^{
                                            [lyricTipsLabel setAlpha:0];
                                        }];
                                    } completion:^(BOOL finished) {
                                        [lyricTipsLabel setText:@"暂无歌词"];
                                        [UIView animateWithDuration:0.3 animations:^{
                                            [lyricTipsLabel setAlpha:0.5];
                                        }];
                                    }];
                                }
                                
                            }
                            else{
                                [UIView animateWithDuration:0.3 animations:^{
                                    [UIView animateWithDuration:0.3 animations:^{
                                        [lyricTipsLabel setAlpha:0];
                                    }];
                                } completion:^(BOOL finished) {
                                    [lyricTipsLabel setText:@"暂无歌词"];
                                    [UIView animateWithDuration:0.3 animations:^{
                                        [lyricTipsLabel setAlpha:1];
                                    }];
                                }];
                                //[SVProgressHUD showErrorWithStatus:[dic objectForKey:@"message"]];
                            }
                        }];
                        [requestForm1 setFailedBlock:^{
                            NSLog(@"URL:%@     status:%d",[weakrequest1 originalURL],[weakrequest1 responseStatusCode]);
                            NSLog(@"  kkk%@",[weakrequest1 error]);
                            [UIView animateWithDuration:0.3 animations:^{
                                [UIView animateWithDuration:0.3 animations:^{
                                    [lyricTipsLabel setAlpha:0];
                                }];
                            } completion:^(BOOL finished) {
                                [lyricTipsLabel setText:@"暂无歌词"];
                                [UIView animateWithDuration:0.3 animations:^{
                                    [lyricTipsLabel setAlpha:1];
                                }];
                            }];
                        }];
                        [requestForm1 startAsynchronous];
                    }];
                }
            }
            else{
                [lyricTipsLabel setAlpha:1];
                [lyricTipsLabel setText:@"暂无歌词"];
            }
            
            
            
            if ([[userInfo shareClass].uid length]>0 &&[playMuzzik.MuzzikUser.user_id isEqualToString:[userInfo shareClass].uid]) {
                [attentionButton setHidden:YES];
            }else if(playMuzzik.MuzzikUser.user_id){
                ASIHTTPRequest *requestUser = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/user/%@",BaseURL,playMuzzik.MuzzikUser.user_id]]];
                [requestUser addBodyDataSourceWithJsonByDic:nil Method:GetMethod auth:YES];
                __weak ASIHTTPRequest *weakrequestUser = requestUser;
                [requestUser setCompletionBlock :^{
                    NSLog(@"%@",[weakrequestUser responseString]);
                    NSLog(@"%d",[weakrequestUser responseStatusCode]);
                    if ([weakrequestUser responseStatusCode] == 200) {
                        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequestUser responseData]  options:NSJSONReadingMutableContainers error:nil];
                        if (![[dic objectForKey:@"isFollow"] boolValue]) {
                            [attentionButton setHidden:NO];
                        }else{
                            [attentionButton setHidden:YES];
                        }
                    }
                }];
                [requestUser setFailedBlock:^{
                    NSLog(@"%@",[weakrequestUser error]);
                }];
                [requestUser startAsynchronous];
            }
            //检测用户是否已关注
            
            
        }
        if ([playMuzzik.message length]>0) {
            NSDictionary *attributes;
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
            paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
            paragraphStyle.alignment = NSTextAlignmentCenter;
            paragraphStyle.lineSpacing = 7;
            attributes = @{NSFontAttributeName:[UIFont fontWithName:Font_Next_Regular size:16], NSParagraphStyleAttributeName:paragraphStyle,NSForegroundColorAttributeName:[UIColor whiteColor]};
            NSAttributedString * attr= [[NSAttributedString alloc] initWithString:playMuzzik.message attributes:attributes];
            message.attributedText = attr;
        }
        
        
        UIColor *color;
        if ([playMuzzik.color intValue] == 2) {
            color = Color_Action_Button_2;
            if (playMuzzik.ismoved) {
                [movedButton setImage:[UIImage imageNamed:Image_PlayeryellowlikedImage] forState:UIControlStateNormal];
            }else{
                [movedButton setImage:[UIImage imageNamed:Image_PlayeryellowlikeImage] forState:UIControlStateNormal];
            }
        }else if ([playMuzzik.color intValue] == 3){
            color = Color_Action_Button_3;
            if (playMuzzik.ismoved) {
                [movedButton setImage:[UIImage imageNamed:Image_PlayerbluelikedImage] forState:UIControlStateNormal];
            }else{
                [movedButton setImage:[UIImage imageNamed:Image_PlayerbluelikeImage] forState:UIControlStateNormal];
            }
        }else{
            color = Color_Action_Button_1;
            if (playMuzzik.ismoved) {
                [movedButton setImage:[UIImage imageNamed:Image_PlayerredlikedImage] forState:UIControlStateNormal];
            }else{
                [movedButton setImage:[UIImage imageNamed:Image_PlayerredlikeImage] forState:UIControlStateNormal];
            }
        }
        artistName.text = playMuzzik.music.artist;
        PartistName.text = playMuzzik.music.artist;
        songName.text = playMuzzik.music.name;
        PsongName.text = playMuzzik.music.name;
        [artistName setTextColor:color];
        [PartistName setTextColor:color];
        [songName setTextColor:color];
        [PsongName setTextColor:color];
       
        
        [self stopEverything];
        [self startMusic];
        [self startTimer];
    }else{
        musicPlayer *player = [musicPlayer shareClass];
        [player play];
    }

}
-(void) parseLrcLine:(NSString *)sourceLineText
{
   
    
    [self.lyricArray removeAllObjects];
    if (!sourceLineText || sourceLineText.length <= 0)
        return ;
    NSArray *array = [sourceLineText componentsSeparatedByString:@"\n"];
    for (int i = 0; i < array.count; i++) {
        NSString *tempStr = [array objectAtIndex:i];
        NSArray *lineArray = [tempStr componentsSeparatedByString:@"]"];
        for (int j = 0; j < [lineArray count]-1; j ++) {
            
            if ([lineArray[j] length] > 8) {
                NSString *str1 = [tempStr substringWithRange:NSMakeRange(3, 1)];
                NSString *str2 = [tempStr substringWithRange:NSMakeRange(6, 1)];
                if ([str1 isEqualToString:@":"] && [str2 isEqualToString:@"."]) {
                    NSString *lrcStr = [lineArray lastObject];
                    if ([lrcStr rangeOfString:@"xiami"].location !=NSNotFound || [lrcStr rangeOfString:@"Xiami"].location !=NSNotFound || [lrcStr rangeOfString:@"虾米"].location !=NSNotFound) {
                        continue;
                    }

                    NSString *timeStr = [[lineArray objectAtIndex:j] substringWithRange:NSMakeRange(1, 8)];//分割区间求歌词时间
                    //把时间 和 歌词 加入词典
                    NSDictionary *dic = [NSDictionary dictionaryWithObject:lrcStr forKey:[timeStr substringToIndex:5]];
                    [self.lyricArray addObject:dic];
                }
            }
        }
    }
    if ([self.lyricArray count] == 0) {
        for (int i = 0; i < array.count; i++) {
            NSString *tempStr = [array objectAtIndex:i];
            NSArray *lineArray = [tempStr componentsSeparatedByString:@"]"];
            for (int j = 0; j < [lineArray count]-1; j ++) {
                
                if ([lineArray[j] length] > 5) {
                    NSString *str1 = [tempStr substringWithRange:NSMakeRange(3, 1)];
                    NSString *str2 = [tempStr substringWithRange:NSMakeRange(5, 1)];
                    if ([str1 isEqualToString:@":"] && [@"0123456789" rangeOfString:str2].location != NSNotFound ) {
                        NSString *lrcStr = [lineArray lastObject];
                        if ([lrcStr rangeOfString:@"xiami"].location !=NSNotFound || [lrcStr rangeOfString:@"Xiami"].location !=NSNotFound || [lrcStr rangeOfString:@"虾米"].location !=NSNotFound) {
                            continue;
                        }
                        
                        NSString *timeStr = [[lineArray objectAtIndex:j] substringWithRange:NSMakeRange(1, 5)];//分割区间求歌词时间
                        //把时间 和 歌词 加入词典
                        NSDictionary *dic = [NSDictionary dictionaryWithObject:lrcStr forKey:[timeStr substringToIndex:5]];
                        [self.lyricArray addObject:dic];
                    }
                }
            }
        }
    }
    self.lyricArray = [NSMutableArray arrayWithArray:[self.lyricArray sortedArrayUsingComparator: ^(id obj1, id obj2) {
        NSDictionary *dic1 = (NSDictionary *)obj1;
        NSDictionary *dic2 = (NSDictionary *)obj2;
       // [[dic1 allKeys] objectAtIndex:0]
        if ([[[dic1 allKeys] objectAtIndex:0] compare:[[dic2 allKeys] objectAtIndex:0] options:NSCaseInsensitiveSearch]==NSOrderedAscending) {
            return NSOrderedAscending;//递减
        }
        if ([[[dic1 allKeys] objectAtIndex:0] compare:[[dic2 allKeys] objectAtIndex:0] options:NSCaseInsensitiveSearch]==NSOrderedDescending){
            return NSOrderedDescending;
        }
        return NSOrderedSame;
    }]];
    NSArray *larray = [NSArray arrayWithArray:self.lyricArray];
    for (long i = larray.count-1; i>0; i--) {
        NSDictionary *dic = larray[i];
       // NSLog(@"%d",[[[dic allValues][0] stringByTrimmingCharactersInSet:[NSCharacterSet symbolCharacterSet]] length]);
        if ([[[dic allValues][0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0 ) {
            [self.lyricArray removeObjectAtIndex:[larray indexOfObject:dic]];
        }
    }
//    if ([self.lyricArray count] == 0) {
//        NSArray *tarray = [NSMutableArray arrayWithArray:[sourceLineText componentsSeparatedByString:@"\n"]];
//        for (long i = tarray.count-1; i>=0; i--) {
//            NSString *string = tarray[i];
//            string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//            if ([string length] != 0 ) {
//                [self.lyricArray insertObject:[NSDictionary dictionaryWithObject:string forKey:@"s"] atIndex:0];
//            }
//        }
//    }
//    NSLog(@"%@",self.lyricArray);
    [lyricTableView reloadData];
}

-(void) seek
{
    if (!audioPlayer)
    {
        return;
    }
    NSLog(@"Slider Changed: %f", _progress.value);
    [audioPlayer seekToTime:_progress.value];
}

-(void) updateControls
{
    Globle *glob = [Globle shareGloble];
    if (audioPlayer.state == AudioPlayerStateStopped) {
        
        if (self.playNext) {
            [_delegate radioView:self musicStop:isPlayBack];
        }
        self.playNext = NO;
    }else if (audioPlayer.state == AudioPlayerStateReady){
        
    }else if (audioPlayer.state == AudioPlayerStateRunning){
        
    }else if (audioPlayer.state == AudioPlayerStatePlaying){
        [[NSNotificationCenter defaultCenter] postNotificationName:String_SetSongPlayNextNotification object:nil];
        glob.isPlaying = YES;
        self.playNext = YES;
    }else if (audioPlayer.state == AudioPlayerStateError){
        if (!isError) {
            isError = YES;
            [nextButton setEnabled:YES];
            [ MuzzikItem showNotifyOnView:nil text:@"歌曲文件读取失败"];
            if (![Reachability reachabilityWithHostName:@"www.muzziker.com"].currentReachabilityStatus == NotReachable) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [_delegate radioView:self musicStop:isPlayBack];
                });
                glob.isPlaying = YES;
            }
        }
        
        
    }
    
    [smallPlayButton setImage:glob.isPlaying&&!glob.isPause?[UIImage imageNamed:Image_PlayerstopImage]:[UIImage imageNamed:Image_PlayerplayImage] forState:UIControlStateNormal];
    if (!glob.isPause && glob.isPlaying) {
        if ([_playMuzzik.color intValue] == 2) {
            [playButton setImage:[UIImage imageNamed:Image_PlayeryellowcirclestopImage] forState:UIControlStateNormal];
        }else if ([_playMuzzik.color intValue] == 3) {
            [playButton setImage:[UIImage imageNamed:Image_PlayerbluecirclestopImage] forState:UIControlStateNormal];
        }else{
            [playButton setImage:[UIImage imageNamed:Image_PlayerredcirclestopImage] forState:UIControlStateNormal];
        }
        
    }else{
        if ([_playMuzzik.color intValue] == 2) {
            [playButton setImage:[UIImage imageNamed:Image_PlayeryellowcircleplayImage] forState:UIControlStateNormal];
        }else if ([_playMuzzik.color intValue] == 3) {
            [playButton setImage:[UIImage imageNamed:Image_PlayerbluecircleplayImage] forState:UIControlStateNormal];
        }else{
            [playButton setImage:[UIImage imageNamed:Image_PlayerredcircleplayImage] forState:UIControlStateNormal];
        }
    }
    
}
-(void) updatePlaybackProgress
{
    if (!audioPlayer || audioPlayer.duration == 0){
        _progress.value = 0;
        return;
    }
    NSLog(@"progress:%f",audioPlayer.progress);
    _progress.minimumValue = 0;
    _progress.maximumValue = audioPlayer.duration;
    if (audioPlayer.progress<3.0) {
        [nextButton setEnabled:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:String_SetSongInformationNotification object:nil userInfo:nil];
    }
    [_progress setValue:audioPlayer.progress animated:YES];
    _currentPlaybackTime.attributedText =[self TimeformatFromSeconds:audioPlayer.progress total:audioPlayer.duration];
  
}
-(void) updateValue:(UISlider *)sender{
    NSLog(@"%f",sender.value);
}
-(void) audioPlayer:(AudioPlayer*)audioPlayer stateChanged:(AudioPlayerState)state
{
    [self updateControls];
}

-(void) audioPlayer:(AudioPlayer*)audioPlayer didEncounterError:(AudioPlayerErrorCode)errorCode
{
    [self updateControls];
}

-(void) audioPlayer:(AudioPlayer*)audioPlayer didStartPlayingQueueItemId:(NSObject*)queueItemId
{
    [self updateControls];
}

-(void) audioPlayer:(AudioPlayer*)Player didFinishBufferingSourceWithQueueItemId:(NSObject*)queueItemId
{
    [self updateControls];
   // [MuzzikItem saveMusicData:[Player getFinishedData] MusicKey:self.playMuzzik.music.key];
    
   // NSLog(@"%@",[Player getFinishedData]);
}

-(void) audioPlayer:(AudioPlayer*)audioPlayer didFinishPlayingQueueItemId:(NSObject*)queueItemId withReason:(AudioPlayerStopReason)stopReason andProgress:(double)progress andDuration:(double)duration
{
    [self updateControls];
}
#pragma -mark  picker委托方法
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == lyricTableView) {
        return self.lyricArray.count;
    }else{
        return playListArray.count;
    }
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
     UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
     cell.textLabel.textAlignment = NSTextAlignmentCenter;
     [cell setBackgroundColor:Color_NavigationBar];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    if (tableView == lyricTableView) {
        cell.textLabel.text =[[_lyricArray[indexPath.row] allObjects][0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        cell.textLabel.numberOfLines = 0;
        
        [cell.textLabel setFont:[UIFont fontWithName:Font_Next_Regular size:16]];
        [cell.textLabel setTextColor:[UIColor whiteColor]];
        
        UILabel *tempLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 10, SCREEN_WIDTH-50, 80)];
        tempLabel.font = [UIFont fontWithName:Font_Next_Regular size:16];
        tempLabel.text = cell.textLabel.text;
        tempLabel.numberOfLines = 0;
        [tempLabel sizeToFit];
        [cell.textLabel setFrame:CGRectMake((SCREEN_WIDTH-tempLabel.frame.size.width)/2, cell.textLabel.frame.origin.y, tempLabel.frame.size.width, tempLabel.frame.size.height)];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        
        return cell;
    }else{
        cell.textLabel.text =[playListArray[indexPath.row] objectForKey:UserInfo_description];;
        [cell.textLabel setFont:[UIFont fontWithName:Font_Next_medium size:16]];
        [cell.textLabel setTextColor:Color_Theme_5];
        return cell;
    }
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == lyricTableView) {
        UILabel *tempLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 10, SCREEN_WIDTH-50, 80)];
        tempLabel.font = [UIFont fontWithName:Font_Next_Regular size:16];
        tempLabel.text = [[_lyricArray[indexPath.row] allObjects][0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        tempLabel.numberOfLines = 0;
        [tempLabel sizeToFit];
        
        return tempLabel.frame.size.height+10;
    }else{
        return 50;
    }
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == plistTableView) {
        NSDictionary *dic = [playListArray objectAtIndex:indexPath.row];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [cell.textLabel setTextColor:[UIColor whiteColor]];
        musicPlayer *player = [musicPlayer shareClass];
        NSMutableArray *muzziks = [dic objectForKey:UserInfo_muzziks];
        player.MusicArray = muzziks;
        player.listType = [dic objectForKey:@"type"];
        [player playSongWithSongModel:muzziks[0] Title:[dic objectForKey:UserInfo_description]];
        
        [self performSelector:@selector(showPlayList) withObject:nil afterDelay:0.5];
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)sView
{
    int index = fabs(sView.contentOffset.x) / sView.frame.size.width;
    //NSLog(@"%d",index);
    [pagecontrol setCurrentPage:index];
}

#pragma -mark progress change

-(void)seeDetail{
    if ([self.playMuzzik.muzzik_id length]>0) {
        [self closeView];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UINavigationController *nac = (UINavigationController *)self.window.rootViewController;
            UIViewController *vc  = [nac.viewControllers lastObject];
            if ([vc isKindOfClass:[ DetaiMuzzikVC class]]) {
                DetaiMuzzikVC *detail = (DetaiMuzzikVC *)vc;
                if (![detail.muzzik_id isEqualToString:self.playMuzzik.muzzik_id]) {
                    DetaiMuzzikVC *godetail = [[DetaiMuzzikVC alloc] init];
                    godetail.muzzik_id = self.playMuzzik.muzzik_id;
                    
                    [nac pushViewController:godetail animated:YES];
                }
            }else{
                DetaiMuzzikVC *godetail = [[DetaiMuzzikVC alloc] init];
                godetail.muzzik_id = self.playMuzzik.muzzik_id;
                
                [nac pushViewController:godetail animated:YES];
            }
        });
       
    }
}
-(void)progressChange:(UISlider *) progressSlider{
    [audioPlayer seekToTime:progressSlider.value];
}

-(void)playAction{
    musicPlayer *player = [musicPlayer shareClass];
    [player play];
    [[NSNotificationCenter defaultCenter] postNotificationName:String_SetSongPlayNextNotification object:nil];
    
}


-(void) closePlayView{
    [audioPlayer stop];
    [musicPlayer shareClass].localMuzzik = nil;
    [musicPlayer shareClass].MusicArray = nil;
    Globle *glob = [Globle shareGloble];
    _playMuzzik = nil;
    glob.isPause = NO;
    self.playNext = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:String_SetSongPlayNextNotification object:nil];
    CABasicAnimation *animation2 = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation2.duration = 0.825; // 持续时间
    animation2.removedOnCompletion = YES;
    animation2.autoreverses = NO;
    animation2.fillMode = kCAFillModeForwards;
    animation2.repeatCount = 1; // 重复次数
    animation2.fromValue = [NSNumber numberWithFloat:M_PI_4]; // 起始角度
    animation2.toValue = [NSNumber numberWithFloat:0.0]; // 终止角度
    [showButton.layer addAnimation:animation2 forKey:@"rotate-layer"];
    showButton.transform = CGAffineTransformMakeRotation(0);
    [showButton.layer addAnimation:animation2 forKey:@"move-rotate-layer"];
    
    _IsShowDetail = NO;
    if (_IsShowPlayList) {
        _IsShowPlayList = NO;
        [UIView animateWithDuration:0.825 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.titleView setFrame:CGRectMake(-SCREEN_WIDTH, 0, SCREEN_WIDTH, 64)];
            
        } completion:^(BOOL finished) {
            [smallPlayButton setHidden:NO];
            [songName setHidden:NO];
            [artistName setHidden:NO];
            [self setFrame:CGRectMake(0, 0, SCREEN_WIDTH, 64)];
            [self.playView setFrame:CGRectMake(0, -366, SCREEN_WIDTH, 338)];
            [self.playListView setFrame:CGRectMake(SCREEN_WIDTH, 64, SCREEN_WIDTH, 338)];
            [UIView animateWithDuration:Play_timeinterval delay:closeInterValTime options: UIViewAnimationOptionCurveEaseInOut animations:^{
                [self setAlpha:0];
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:Play_timeinterval animations:^{
                    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
                    UINavigationController *nac = (UINavigationController *)app.window.rootViewController;
                    if ([[[nac viewControllers] lastObject] isKindOfClass:[AMScrollingNavbarViewController class]]) {
                        AMScrollingNavbarViewController *viewcontroller = (AMScrollingNavbarViewController *)[[nac viewControllers] lastObject];
                        [viewcontroller.leftBtn setAlpha:1];
                        [viewcontroller.rightBtn setAlpha:1];
                        [viewcontroller.headerView setAlpha:1];
                    }
                }];
            }];
        }];
        [UIView animateWithDuration:0.6 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.playListView setFrame:CGRectMake(0, -366, SCREEN_WIDTH, 338)];
        } completion:nil];
    }else{
        [UIView animateWithDuration:0.825 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.titleView setFrame:CGRectMake(-SCREEN_WIDTH, 0, SCREEN_WIDTH, 64)];
            
        } completion:^(BOOL finished) {
            [smallPlayButton setHidden:NO];
            [songName setHidden:NO];
            [artistName setHidden:NO];
            [self setFrame:CGRectMake(0, 0, SCREEN_WIDTH, 64)];
            [UIView animateWithDuration:Play_timeinterval delay:closeInterValTime options: UIViewAnimationOptionCurveEaseInOut animations:^{
                [self setAlpha:0];
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:Play_timeinterval animations:^{
                     glob.isPlaying = NO;
                    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
                    UINavigationController *nac = (UINavigationController *)app.window.rootViewController;
                    if ([[[nac viewControllers] lastObject] isKindOfClass:[AMScrollingNavbarViewController class]]) {
                        AMScrollingNavbarViewController *viewcontroller = (AMScrollingNavbarViewController *)[[nac viewControllers] lastObject];
                        [viewcontroller.leftBtn setAlpha:1];
                        [viewcontroller.rightBtn setAlpha:1];
                        [viewcontroller.headerView setAlpha:1];
                    }
                }];
            }];
        }];
        [UIView animateWithDuration:0.6 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
           
            [self.playView setFrame:CGRectMake(0, -366, SCREEN_WIDTH, 338)];
        } completion:nil];
    }

}
-(void)nextAction{
    [nextButton setEnabled:NO];
    [audioPlayer stop];
}
//收起播放器
-(void)closeView{
    CABasicAnimation *animation2 = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation2.duration = 0.825; // 持续时间
    animation2.removedOnCompletion = YES;
    animation2.autoreverses = NO;
    animation2.fillMode = kCAFillModeForwards;
    animation2.repeatCount = 1; // 重复次数
    animation2.fromValue = [NSNumber numberWithFloat:M_PI_4]; // 起始角度
    animation2.toValue = [NSNumber numberWithFloat:0.0]; // 终止角度
    [showButton.layer addAnimation:animation2 forKey:@"rotate-layer"];
    showButton.transform = CGAffineTransformMakeRotation(0);
    [showButton.layer addAnimation:animation2 forKey:@"move-rotate-layer"];
    
    _IsShowDetail = NO;
    if (_IsShowPlayList) {
        _IsShowPlayList = NO;
        [UIView animateWithDuration:0.825 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.titleView setFrame:CGRectMake(-SCREEN_WIDTH, 0, SCREEN_WIDTH, 64)];
            
        } completion:^(BOOL finished) {
            [smallPlayButton setHidden:NO];
            [songName setHidden:NO];
            [artistName setHidden:NO];
            [self setFrame:CGRectMake(0, 0, SCREEN_WIDTH, 64)];
            [self.playView setFrame:CGRectMake(0, -366, SCREEN_WIDTH, 338)];
            [self.playListView setFrame:CGRectMake(SCREEN_WIDTH, 64, SCREEN_WIDTH, 338)];
        }];
        [UIView animateWithDuration:0.6 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.playListView setFrame:CGRectMake(0, -366, SCREEN_WIDTH, 338)];
        } completion:nil];
    }else{
        [UIView animateWithDuration:0.825 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.titleView setFrame:CGRectMake(-SCREEN_WIDTH, 0, SCREEN_WIDTH, 64)];
            
        } completion:^(BOOL finished) {
            [smallPlayButton setHidden:NO];
            [songName setHidden:NO];
            [artistName setHidden:NO];
            [self setFrame:CGRectMake(0, 0, SCREEN_WIDTH, 64)];
        }];
        [UIView animateWithDuration:0.6 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.playView setFrame:CGRectMake(0, -366, SCREEN_WIDTH, 338)];
        } completion:nil];
    }
}
-(void) attentionAction{
    if ([[userInfo shareClass].token length]>0) {
        _playMuzzik.MuzzikUser.isFollow = YES;
        [attentionButton setHidden:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:String_UserDataSource_update object:_playMuzzik.MuzzikUser];
        ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_User_Follow]]];
        [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:_playMuzzik.MuzzikUser.user_id forKey:@"_id"] Method:PostMethod auth:YES];
        __weak ASIHTTPRequest *weakrequest = requestForm;
        [requestForm setCompletionBlock :^{
            NSLog(@"%@",[weakrequest responseString]);
            NSLog(@"%d",[weakrequest responseStatusCode]);
            
            if ([weakrequest responseStatusCode] == 200) {
                
            }
            else{
                
                //[SVProgressHUD showErrorWithStatus:[dic objectForKey:@"message"]];
            }
        }];
        [requestForm setFailedBlock:^{
            NSLog(@"%@",[weakrequest error]);
            NSLog(@"hhhh%@  kkk%@",[weakrequest responseString],[weakrequest responseHeaders]);
        }];
        [requestForm startAsynchronous];
    }else{
        AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
        UINavigationController *nac = (UINavigationController *)app.window.rootViewController;
        [userInfo checkLoginWithVC:nac.viewControllers[0]];
    }
    
}
-(void)modelAction{
    if (isPlayBack == -1) {
        isPlayBack = 0;
        [playModelButton setImage:[UIImage imageNamed:Image_PlayerloopImage] forState:UIControlStateNormal];
    }else{
        isPlayBack = -1;
        [playModelButton setImage:[UIImage imageNamed:Image_PlayerloopclickImage] forState:UIControlStateNormal];
    }
    
}
-(void)moveAction{
    userInfo *user = [userInfo shareClass];
    if ([user.token length]>0) {
        _playMuzzik.ismoved = !_playMuzzik.ismoved;
        if (_playMuzzik.ismoved) {
            _playMuzzik.moveds = [NSString stringWithFormat:@"%d",[_playMuzzik.moveds intValue]+1 ];
        }else{
            _playMuzzik.moveds = [NSString stringWithFormat:@"%d",[_playMuzzik.moveds intValue]-1 ];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:String_MuzzikDataSource_update object:_playMuzzik];
        ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/muzzik/%@/moved",BaseURL,_playMuzzik.muzzik_id]]];
        [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:_playMuzzik.ismoved] forKey:@"ismoved"] Method:PostMethod auth:YES];
        __weak ASIHTTPRequest *weakrequest = requestForm;
        [requestForm setCompletionBlock :^{
            if ([weakrequest responseStatusCode] == 200) {
                // NSData *data = [weakrequest responseData];
                
                //                NSIndexPath *indexPath=[NSIndexPath indexPathForRow:[self.muzziks indexOfObject:tempMuzzik] inSection:0];
                //                [MytableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
                
            }
            else{
                //[SVProgressHUD showErrorWithStatus:[dic objectForKey:@"message"]];
            }
        }];
        [requestForm setFailedBlock:^{
            NSLog(@"%@",[weakrequest error]);
        }];
        [requestForm startAsynchronous];
        
        //NSLog(@"json:%@,dic:%@",tempJsonData,dic);
        
    }else{
        AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
        UINavigationController *nac = (UINavigationController *)app.window.rootViewController;
        [userInfo checkLoginWithVC:nac.viewControllers[0]];
    }
}
-(void)commentAction{
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UINavigationController *nac = (UINavigationController *)app.window.rootViewController;
    userInfo *user = [userInfo shareClass];
    if ([user.token length]>0) {
        
        [self closeView];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            MuzzikObject *mobject = [MuzzikObject shareClass];
            userInfo *user = [userInfo shareClass];
            user.poController = nac.viewControllers.lastObject;
            
            mobject.music = _playMuzzik.music;
            [MuzzikItem getLyricByMusic:_playMuzzik.music];
            MessageStepViewController *messagebv = [[MessageStepViewController alloc] init];
            [nac pushViewController:messagebv animated:YES];
        });
    }else{
        AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
        UINavigationController *nac = (UINavigationController *)app.window.rootViewController;
        [userInfo checkLoginWithVC:nac.viewControllers[0]];
    }
   
}
-(void)setTitleString:(NSString *)title{
    _titleLabel.text = title;
}
-(void)checkPlayList{
    userInfo *user = [userInfo shareClass];
    if (!user.checkMove && [user.token length]>0) {
        ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Moved_Muzziks]]];
        [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:30],Parameter_Limit ,nil] Method:GetMethod auth:YES];
        __weak ASIHTTPRequest *weakrequest = requestForm;
        [requestForm setCompletionBlock :^{
            if ([weakrequest responseStatusCode] == 200) {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData] options:NSJSONReadingMutableContainers error:nil];
                muzzik *tempMuzzik = [muzzik new];
                [MuzzikItem SetUserInfoWithMuzziks:[tempMuzzik makeMuzziksByMusicArray:[dic objectForKey:@"music"]] title:Constant_userInfo_move description:[NSString stringWithFormat:@"喜欢列表"]];
            }
            else{
                //[SVProgressHUD showErrorWithStatus:[dic objectForKey:@"message"]];
            }
        }];
        [requestForm setFailedBlock:^{
            NSLog(@"%@",[weakrequest error]);
        }];
        [requestForm startAsynchronous];
    }
    
    //检查关注列表
    if (!user.checkMove && [user.token length]>0) {
        ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Moved_Muzziks]]];
        [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:30],Parameter_Limit ,nil] Method:GetMethod auth:YES];
        __weak ASIHTTPRequest *weakrequest = requestForm;
        [requestForm setCompletionBlock :^{
            if ([weakrequest responseStatusCode] == 200) {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData] options:NSJSONReadingMutableContainers error:nil];
                muzzik *tempMuzzik = [muzzik new];
                [MuzzikItem SetUserInfoWithMuzziks:[tempMuzzik makeMuzziksByMusicArray:[dic objectForKey:@"music"]] title:Constant_userInfo_move description:[NSString stringWithFormat:@"喜欢列表"]];
            }
            else{
                //[SVProgressHUD showErrorWithStatus:[dic objectForKey:@"message"]];
            }
        }];
        [requestForm setFailedBlock:^{
            NSLog(@"%@",[weakrequest error]);
        }];
        [requestForm startAsynchronous];
    }
    
    //检查我的muzzik
    if (!user.checkMove && [user.token length]>0) {
        ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/muzzik/feeds",BaseURL]]];
        [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:30],Parameter_Limit ,nil] Method:GetMethod auth:YES];
        __weak ASIHTTPRequest *weakrequest = requestForm;
        [requestForm setCompletionBlock :^{
            if ([weakrequest responseStatusCode] == 200) {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData] options:NSJSONReadingMutableContainers error:nil];
                muzzik *tempMuzzik = [muzzik new];
                [MuzzikItem SetUserInfoWithMuzziks:[tempMuzzik makeMuzziksByMusicArray:[dic objectForKey:@"music"]] title:Constant_userInfo_move description:[NSString stringWithFormat:@"喜欢列表"]];
            }
            else{
                //[SVProgressHUD showErrorWithStatus:[dic objectForKey:@"message"]];
            }
        }];
        [requestForm setFailedBlock:^{
            NSLog(@"%@",[weakrequest error]);
        }];
        [requestForm startAsynchronous];
    }
    //检查推荐列表
    if (!user.checkMove && [user.token length]>0) {
        ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Moved_Muzziks]]];
        [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:30],Parameter_Limit ,nil] Method:GetMethod auth:YES];
        __weak ASIHTTPRequest *weakrequest = requestForm;
        [requestForm setCompletionBlock :^{
            if ([weakrequest responseStatusCode] == 200) {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData] options:NSJSONReadingMutableContainers error:nil];
                muzzik *tempMuzzik = [muzzik new];
                [MuzzikItem SetUserInfoWithMuzziks:[tempMuzzik makeMuzziksByMusicArray:[dic objectForKey:@"music"]] title:Constant_userInfo_move description:[NSString stringWithFormat:@"喜欢列表"]];
            }
            else{
                //[SVProgressHUD showErrorWithStatus:[dic objectForKey:@"message"]];
            }
        }];
        [requestForm setFailedBlock:^{
            NSLog(@"%@",[weakrequest error]);
        }];
        [requestForm startAsynchronous];
    }
}

-(void) initPlayList{
    plistTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 50, SCREEN_WIDTH, 250)];
    plistTableView.delegate = self;
    plistTableView.dataSource = self;
    [self.playListView addSubview:plistTableView];
    [plistTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [plistTableView setBackgroundColor:Color_NavigationBar];
}

-(void)dataSourceMuzzikUpdate:(NSNotification *)notify{
    muzzik *tempMuzzik = (muzzik *)notify.object;
    if ([_playMuzzik.muzzik_id isEqualToString:tempMuzzik.muzzik_id]) {
        _playMuzzik.ismoved = tempMuzzik.ismoved;
        _playMuzzik.isReposted = tempMuzzik.isReposted;
        _playMuzzik.moveds = tempMuzzik.moveds;
        _playMuzzik.reposts = tempMuzzik.reposts;
        _playMuzzik.shares = tempMuzzik.shares;
        _playMuzzik.comments = tempMuzzik.comments;
        UIColor *color;
        if ([_playMuzzik.color intValue] == 2) {
            color = Color_Action_Button_1;
            if (_playMuzzik.ismoved) {
                [movedButton setImage:[UIImage imageNamed:Image_PlayeryellowlikedImage] forState:UIControlStateNormal];
            }else{
                [movedButton setImage:[UIImage imageNamed:Image_PlayeryellowlikeImage] forState:UIControlStateNormal];
            }
        }else if ([_playMuzzik.color intValue] == 3){
            color = Color_Action_Button_2;
            if (_playMuzzik.ismoved) {
                [movedButton setImage:[UIImage imageNamed:Image_PlayerbluelikedImage] forState:UIControlStateNormal];
            }else{
                [movedButton setImage:[UIImage imageNamed:Image_PlayerbluelikeImage] forState:UIControlStateNormal];
            }
        }else{
            color = Color_Action_Button_3;
            if (_playMuzzik.ismoved) {
                [movedButton setImage:[UIImage imageNamed:Image_PlayerredlikedImage] forState:UIControlStateNormal];
            }else{
                [movedButton setImage:[UIImage imageNamed:Image_PlayerredlikeImage] forState:UIControlStateNormal];
            }
        }
    }

}
-(void)gotoUserDetail:(UIButton_UserMuzzik *)sender{
    [self closeView];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    UINavigationController *nac = (UINavigationController *)self.window.rootViewController;
    userInfo *user = [userInfo shareClass];
    if ([sender.user.user_id isEqualToString:user.uid]) {
        UserHomePage *home = [[UserHomePage alloc] init];
        [nac pushViewController:home animated:YES];
    }else{
        userDetailInfo *detailuser = [[userDetailInfo alloc] init];
        detailuser.uid = sender.user.user_id;
        [nac pushViewController:detailuser animated:YES];
    }
    });
    
}
@end
