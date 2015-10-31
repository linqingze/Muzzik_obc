//
//  audioPlayerViewController.m
//  muzzik
//
//  Created by muzzik on 15/10/17.
//  Copyright © 2015年 muzziker. All rights reserved.
//

#import "audioPlayerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "UIImageView+WebCache.h"
#import "UIButton+WebCache.h"
#import "UIImage+BoxBlur.h"
#import "LineSlider.h"
#import "userDetailInfo.h"
#import "UserHomePage.h"
#import "DetaiMuzzikVC.h"
#import "MuzzikPlayer.h"
#import "MessageStepViewController.h"
#import "StyledPageControl.h"
#import "UIButton+autoCycle.h"
@interface audioPlayerViewController ()<UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate>{
    NSTimer *_progressUpdateTimer;
    UILabel *titleView;
    UIImageView *backGroundImage;
    UIImageView *backTransImage;
    
    UIButton_UserMuzzik *headerImage;
    UIImageView *headerTransImage;
    
    // 播放界面控件
    UILabel *songName;
    UILabel *artistName;
    UIButton *playButton;
    NSMutableArray *playList;
    
    UIButton *attentionButton;
    UILabel *nickLabel;
    StyledPageControl *pagecontrol;
    UIScrollView *Scroll;
    Globle *globle;
    UIButton *commentButton;
    UIButton *movedButton;
    UIButton *playModelButton;
    UIButton *nextButton;
    UIButton *closeButton;
    UIView *detailView;
    UILabel *message;
    UIView *messageView;
    UILabel *lyricTipsLabel;
    LineSlider *progress;
    UILabel *_currentPlaybackTime;
    
    //播放控制参数
    
    
    BOOL ableToSeek;
    BOOL _IsShowPlayList;
    //tableView
    UITableView *lyricTableView;
    NSMutableArray *lyricArray;
    NSMutableArray *playListArray;
    UITableView *plistTableView;
    
    
    //逻辑开关
    BOOL isViewLoaded;
    BOOL isPlayBack;
    BOOL durationAvailable;
}
@property(nonatomic,retain) UIView *playView;
@property (nonatomic,retain) UIView *playListView;
@property (nonatomic,retain)MuzzikPlayer *player;

@property(nonatomic,retain) UIView *blurView;

@end

@implementation audioPlayerViewController

-(instancetype)init{
    self = [super init];
    _player  = [MuzzikPlayer shareClass];
    globle = [Globle shareGloble];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playDidChangeNotification:) name:String_SetSongPlayNextNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(durationAvailable:) name:MPMovieDurationAvailableNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetPlayView) name:@"Muzzik_Player_PlayNewSong" object:nil];
    return self;
}
#pragma  mark -Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataSourceMuzzikUpdate:) name:String_MuzzikDataSource_update object:nil];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    _progressUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                            target:self
                                                          selector:@selector(updatePlaybackProgress)
                                                          userInfo:nil
                                                           repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_progressUpdateTimer forMode:NSRunLoopCommonModes];
    
    //设置标题
    
    
    //设置背景图片
    backGroundImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    backGroundImage.contentMode = UIViewContentModeScaleAspectFill;
    [backGroundImage setImage:[UIImage imageNamed:@"playerbgImageImage"]];
    
    backTransImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    backTransImage.contentMode = UIViewContentModeScaleAspectFill;
    [backTransImage setImage:[UIImage imageNamed:@""]];

    self.blurView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.blurView addSubview:backTransImage];
    [self.blurView addSubview:backGroundImage];
    
    titleView = [[UILabel alloc] initWithFrame:CGRectMake(80, 32, SCREEN_WIDTH-160, 20)];
    [titleView setTextColor:[UIColor whiteColor]];
    titleView.textAlignment = NSTextAlignmentCenter;
    titleView.adjustsFontSizeToFitWidth = YES;
    titleView.font = [UIFont boldSystemFontOfSize:16];
    
    UIImageView *grayImage = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [grayImage setImage:[UIImage imageNamed:@"playerbgcover"]];
    grayImage.contentMode = UIViewContentModeScaleAspectFill;
    [self.blurView addSubview:grayImage];
    [self.blurView addSubview:titleView];
    //设置左右item
    UIButton *leftBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 20, 44, 44)];
    [leftBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [leftBtn setImage:[UIImage imageNamed:@"backImage"] forState:UIControlStateNormal];
    UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-44, 20, 44, 44)];
    [rightBtn addTarget:self action:@selector(playListAction:) forControlEvents:UIControlEventTouchUpInside];
    [rightBtn setImage:[UIImage imageNamed:@"playerlistImage"] forState:(UIControlStateNormal)];
    [self.blurView addSubview:leftBtn];
    [self.blurView addSubview:rightBtn];
    
    
    [self.view addSubview:self.blurView];
    
    self.view.clipsToBounds = YES;
    self.playView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT-199)];
    
    [self settingPlayerView];
    [self.blurView addSubview:self.playView];
    [self initPlayList];
    userInfo *user = [userInfo shareClass];
    user.fixTitle = YES;
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    titleView.text = [NSString stringWithFormat:@"正在播放 %@",_player.viewTitle];
    AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appdelegate.tabviewController setTabBarHidden:YES animated:YES];
    isViewLoaded = YES;
    [self resetPlayView];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    isViewLoaded = NO;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
#pragma mark -initView
-(void) initPlayList{
    plistTableView = [[UITableView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH, SCREEN_HEIGHT/2-130, SCREEN_WIDTH, 220)];
    plistTableView.delegate = self;
    plistTableView.dataSource = self;
    [self.blurView addSubview:plistTableView];
    [plistTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [plistTableView setBackgroundColor:[UIColor clearColor]];
}
-(void)settingPlayerView{
    
    headerImage = [[UIButton_UserMuzzik alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-37, 10, 75, 75)];
    headerImage.layer.cornerRadius = 38;
    headerImage.clipsToBounds = YES;
    [headerImage addTarget:self action:@selector(gotoUserDetail:) forControlEvents:UIControlEventTouchUpInside];
    
    headerTransImage = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-37, 10, 75, 75)];
    headerTransImage.layer.cornerRadius = 38;
    headerTransImage.clipsToBounds = YES;
    
    [self.playView addSubview:headerTransImage];
    [self.playView addSubview:headerImage];
    attentionButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2+12, 60, 25, 25)];
    [attentionButton setImage:[UIImage imageNamed:Image_PlayerfollowImage] forState:UIControlStateNormal];
    [attentionButton addTarget:self action:@selector(attentionAction) forControlEvents:UIControlEventTouchUpInside];
    [self.playView addSubview:attentionButton];
    nickLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 90, SCREEN_WIDTH, 30)];
    [nickLabel setTextColor:[UIColor whiteColor]];
    [nickLabel setFont:[UIFont fontWithName:Font_Next_Bold size:14]];
    nickLabel.textAlignment = NSTextAlignmentCenter;
    [self.playView addSubview:nickLabel];
    pagecontrol = [[StyledPageControl alloc] initWithFrame:CGRectMake(0, 125, SCREEN_WIDTH, 8)];
    //page control
    [pagecontrol setCoreSelectedColor:[UIColor whiteColor]];
    [pagecontrol setCoreNormalColor:[UIColor colorWithWhite:1 alpha:0.4]];
    [pagecontrol setDiameter:7];
    [pagecontrol setGapWidth:4];
    userInfo *user = [userInfo shareClass];
    if (!user.hideLyric) {
        [self.playView addSubview:pagecontrol];
    }
    
    //[pagecontrol setBackgroundColor:[UIColor whiteColor]];
    pagecontrol.numberOfPages = 2;
    Scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 138, SCREEN_WIDTH, SCREEN_HEIGHT-352)];
    Scroll.delegate = self;
    [Scroll setPagingEnabled:YES];
    if (!user.hideLyric) {
        [Scroll setContentSize:CGSizeMake(SCREEN_WIDTH*2, SCREEN_HEIGHT-352)];
    }else{
        [Scroll setContentSize:CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT-352)];
    }
    
    [self.playView addSubview:Scroll];
    if (!user.hideLyric) {
        messageView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH, 0, SCREEN_WIDTH, SCREEN_HEIGHT-352)];
    }else{
        messageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-352)];
    }
    [messageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(seeDetail)]];
    message =[[UILabel alloc ] initWithFrame:CGRectMake(15, 0, SCREEN_WIDTH-30, SCREEN_HEIGHT-352)];
    message.numberOfLines = 0;
    
    [messageView addSubview:message];
    [Scroll addSubview:messageView];
    [Scroll setShowsHorizontalScrollIndicator:NO];
    lyricTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-352)];
    [lyricTableView setBackgroundColor:[UIColor clearColor]];
    [lyricTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    lyricTipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, SCREEN_WIDTH-30, SCREEN_HEIGHT-352)];
    lyricTipsLabel.numberOfLines = 0;
    [lyricTipsLabel setFont:[UIFont systemFontOfSize:16]];
    [lyricTipsLabel setTextColor:[UIColor whiteColor]];
    lyricTipsLabel.textAlignment = NSTextAlignmentCenter;
    [lyricTipsLabel setAlpha:0];
    lyricTableView.delegate = self;
    lyricTableView.dataSource = self;
    
    if (!user.hideLyric) {
        [Scroll addSubview:lyricTableView];
        [Scroll addSubview:lyricTipsLabel];
    }
    
    progress = [[LineSlider alloc] initWithFrame:CGRectMake(15, SCREEN_HEIGHT-131, SCREEN_WIDTH-70, 20)];//213
    progress.continuous = NO;
    [progress setMinimumValue:0.0];
    progress.minimumTrackTintColor = Color_Active_Button_1;
    progress.maximumTrackTintColor = [UIColor colorWithWhite:1 alpha:0.4];
    [progress setThumbImage:[UIImage imageNamed:Image_PlayerforwardImage] forState:UIControlStateNormal];
    
    [progress addTarget:self action:@selector(progressChange:) forControlEvents:UIControlEventValueChanged];
    [self.blurView addSubview: progress];
    
    _currentPlaybackTime = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-57 , SCREEN_HEIGHT-138, 50, 15)];
    // [_currentPlaybackTime setBackgroundColor:[UIColor whiteColor]];
    _currentPlaybackTime.font = [UIFont systemFontOfSize:7];
    _currentPlaybackTime.text = @"00:00/00:00";
    [_currentPlaybackTime setTextColor:[UIColor whiteColor]];
    [self.blurView addSubview:_currentPlaybackTime];
    
    playButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-51, SCREEN_HEIGHT-107, 36, 36)];
    [playButton addTarget:self action:@selector(playAction) forControlEvents:UIControlEventTouchUpInside];
    [self.blurView addSubview:playButton];
    movedButton =[[UIButton alloc] initWithFrame:CGRectMake(15, SCREEN_HEIGHT-107, 36, 36)];
    [movedButton addTarget:self action:@selector(moveAction) forControlEvents:UIControlEventTouchUpInside];
    [self.blurView addSubview:movedButton];
    
    songName = [[UILabel alloc] initWithFrame:CGRectMake(77, SCREEN_HEIGHT-110, SCREEN_WIDTH -140, 18)];
    [songName setFont:[UIFont fontWithName:Font_Next_Bold size:15]];
    
    
    artistName = [[UILabel alloc] initWithFrame:CGRectMake(77, SCREEN_HEIGHT-83, SCREEN_WIDTH -140, 16)];
    artistName.adjustsFontSizeToFitWidth = YES;
    [artistName setFont:[UIFont fontWithName:Font_Next_Bold size:12]];
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(13, SCREEN_HEIGHT-50, SCREEN_WIDTH-26, 1)];
    [lineView setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.1]];
    [self.blurView addSubview:lineView];
    
    [self.blurView addSubview:songName];
    [self.blurView addSubview:artistName];
    
    //        UISlider *slider = [[UISlider alloc ] initWithFrame:CGRectMake(10, 20, 300, 20)];
    //        [slider addTarget:self action:@selector(updateValue:) forControlEvents:UIControlEventValueChanged];
    //        [self addSubview:slider];
//    closeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-45, (int)(SCREEN_WIDTH/4), 45)];
//    [closeButton setImage:[UIImage imageNamed:Image_PlayercloseImage] forState:UIControlStateNormal];
//    [closeButton addTarget:self action:@selector(closePlayView) forControlEvents:UIControlEventTouchUpInside];
//    [self.playView addSubview:closeButton];
    
    commentButton = [[UIButton alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-50, (int)(SCREEN_WIDTH/3), 50)];
    [commentButton setImage:[UIImage imageNamed:@"playerrepostImage"] forState:UIControlStateNormal];
    [commentButton addTarget:self action:@selector(commentAction) forControlEvents:UIControlEventTouchUpInside];
    [self.blurView addSubview:commentButton];
    
    playModelButton = [[UIButton alloc] initWithFrame:CGRectMake((int)(SCREEN_WIDTH/3), SCREEN_HEIGHT-50,(int)(SCREEN_WIDTH/3), 50)];
    [playModelButton setImage:[UIImage imageNamed:@"playerloopImage"] forState:UIControlStateNormal];
    [playModelButton addTarget:self action:@selector(modelAction) forControlEvents:UIControlEventTouchUpInside];
    [self.blurView addSubview:playModelButton];
    
    nextButton = [[UIButton alloc] initWithFrame:CGRectMake((int)(SCREEN_WIDTH*2/3), SCREEN_HEIGHT-50, (int)(SCREEN_WIDTH/3), 50)];
    [nextButton setImage:[UIImage imageNamed:@"playernextImage"] forState:UIControlStateNormal];
    [nextButton addTarget:self action:@selector(nextAction) forControlEvents:UIControlEventTouchUpInside];
    [self.blurView addSubview:nextButton];
}
-(void)resetPlayView{
    if ([_player.playingMuzzik.image length] >0) {
        [backTransImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",BaseURL_image,_player.playingMuzzik.image,Image_Size_Big]] placeholderImage:[UIImage imageNamed:Image_placeholdImage] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
            UIImage *tempImage =[image blurredImageWithRadius:20 iterations:3 tintColor:[UIColor blackColor]];
            [backTransImage setImage:tempImage];
            [UIView animateWithDuration:2 animations:^{
                [backGroundImage setAlpha:0];
            } completion:^(BOOL finished) {
                [backGroundImage setImage:backTransImage.image];
                [backGroundImage setAlpha:1];
            }];
        }];
    }else{
        [backGroundImage setImage:[UIImage imageNamed:@"playerbgImageImage"]];
        [backTransImage setImage:backGroundImage.image];
        [UIView animateWithDuration:2 animations:^{
            [backGroundImage setAlpha:0];
        } completion:^(BOOL finished) {
            [backGroundImage setImage:backTransImage.image];
            [backGroundImage setAlpha:1];
        }];
    }
    
    
    if (_player.playingMuzzik.MuzzikUser) {
        [attentionButton setHidden:NO];
        nickLabel.text = _player.playingMuzzik.MuzzikUser.name;
        
        headerImage.user = _player.playingMuzzik.MuzzikUser;
        [headerTransImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",BaseURL_image,_player.playingMuzzik.MuzzikUser.avatar,Image_Size_Small]] placeholderImage:[UIImage imageNamed:Image_user_placeHolder] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            attentionButton.userInteractionEnabled = NO;
            [UIView animateWithDuration:2 animations:^{
                [headerImage setAlpha:0];
            } completion:^(BOOL finished) {
                [headerImage setImage:image forState:UIControlStateNormal];
                [headerImage setAlpha:1];
                [attentionButton setUserInteractionEnabled:YES];
            }];
        }];
    }
    else{
        
        [attentionButton setHidden:YES];
        [headerImage setUserInteractionEnabled:NO];
        nickLabel.text = @"Muzzik";
        [headerImage setBackgroundImage:[UIImage imageNamed:@"logo"] forState:UIControlStateNormal];
    }
    if (![userInfo shareClass].hideLyric) {
        [lyricArray removeAllObjects];
        [lyricTableView reloadData];
        if ([[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] == kReachableViaWiFi) {
            ASIHTTPRequest *requestForm1 = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Music_Lyric_get]]];
            [requestForm1 addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:[[NSString stringWithFormat:@"%@",_player.playingMuzzik.music.name] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:@"q"] Method:GetMethod auth:NO];
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
                        lyricAddress = [[[dic1 objectForKey:@"music"] objectAtIndex:0] objectForKey:@"lyric"];
                        for (NSDictionary *dic in [dic1 objectForKey:@"music"]) {
                            if ([[dic objectForKey:@"artist"] isEqualToString:_player.playingMuzzik.music.artist] && [[dic objectForKey:@"name"] isEqualToString:_player.playingMuzzik.music.name]) {
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
                                    if ([lyricArray count] == 0) {
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
                [requestForm1 addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:[[NSString stringWithFormat:@"%@",_player.playingMuzzik.music.name] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:@"q"] Method:GetMethod auth:NO];
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
                            lyricAddress = [[[dic1 objectForKey:@"music"] objectAtIndex:0] objectForKey:@"lyric"];
                            for (NSDictionary *dic in [dic1 objectForKey:@"music"]) {
                                if ([[dic objectForKey:@"artist"] isEqualToString:_player.playingMuzzik.music.artist] && [[dic objectForKey:@"name"] isEqualToString:_player.playingMuzzik.music.name]) {
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
                                        if ([lyricArray count] == 0) {
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
    
    
    
    if ([[userInfo shareClass].uid length]>0 &&[_player.playingMuzzik.MuzzikUser.user_id isEqualToString:[userInfo shareClass].uid]) {
        [attentionButton setHidden:YES];
    }else if(_player.playingMuzzik.MuzzikUser.user_id){
        ASIHTTPRequest *requestUser = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/user/%@",BaseURL,_player.playingMuzzik.MuzzikUser.user_id]]];
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
    //
    if ([_player.playingMuzzik.message length]>0) {
//        NSDictionary *attributes;
//        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
//        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
//        paragraphStyle.alignment = NSTextAlignmentCenter;
//        
//        paragraphStyle.lineSpacing = 7;
//        attributes = @{NSFontAttributeName:[UIFont fontWithName:Font_Next_Regular size:16], NSParagraphStyleAttributeName:paragraphStyle,NSForegroundColorAttributeName:[UIColor whiteColor]};
//        NSAttributedString * attr= [[NSAttributedString alloc] initWithString:_player.playingMuzzik.message attributes:attributes];
//        message.attributedText = attr;
        message.text = _player.playingMuzzik.message;
        message.textAlignment = NSTextAlignmentCenter;
        [message setTextColor:[UIColor whiteColor]];
        [message setFont:[UIFont fontWithName:Font_Next_Regular size:16]];
//        [message setFrame:CGRectMake(message.frame.origin.x, message.frame.origin.y, SCREEN_WIDTH-30, SCREEN_HEIGHT-322)];
//        [message sizeToFit];
//        message.textAlignment = NSTextAlignmentCenter;
    }


    UIColor *color;
    if ([_player.playingMuzzik.color intValue] == 2) {
        color = Color_Action_Button_2;
        if (_player.playingMuzzik.ismoved) {
            [movedButton setImage:[UIImage imageNamed:Image_PlayeryellowlikedImage] forState:UIControlStateNormal];
        }else{
            [movedButton setImage:[UIImage imageNamed:Image_PlayeryellowlikeImage] forState:UIControlStateNormal];
        }
    }else if ([_player.playingMuzzik.color intValue] == 3){
        color = Color_Action_Button_3;
        if (_player.playingMuzzik.ismoved) {
            [movedButton setImage:[UIImage imageNamed:Image_PlayerbluelikedImage] forState:UIControlStateNormal];
        }else{
            [movedButton setImage:[UIImage imageNamed:Image_PlayerbluelikeImage] forState:UIControlStateNormal];
        }
    }else{
        color = Color_Action_Button_1;
        if (_player.playingMuzzik.ismoved) {
            [movedButton setImage:[UIImage imageNamed:Image_PlayerredlikedImage] forState:UIControlStateNormal];
        }else{
            [movedButton setImage:[UIImage imageNamed:Image_PlayerredlikeImage] forState:UIControlStateNormal];
        }
    }
    artistName.text = _player.playingMuzzik.music.artist;

    songName.text = _player.playingMuzzik.music.name;

    [artistName setTextColor:color];

    [songName setTextColor:color];
    Globle *glob = [Globle shareGloble];
    if (!glob.isPause && glob.isPlaying) {
        if ([_player.playingMuzzik.color intValue] == 2) {
            [playButton setImage:[UIImage imageNamed:Image_PlayeryellowcirclestopImage] forState:UIControlStateNormal];
        }else if ([_player.playingMuzzik.color intValue] == 3) {
            [playButton setImage:[UIImage imageNamed:Image_PlayerbluecirclestopImage] forState:UIControlStateNormal];
        }else{
            [playButton setImage:[UIImage imageNamed:Image_PlayerredcirclestopImage] forState:UIControlStateNormal];
        }
        
    }else{
        if ([_player.playingMuzzik.color intValue] == 2) {
            [playButton setImage:[UIImage imageNamed:Image_PlayeryellowcircleplayImage] forState:UIControlStateNormal];
        }else if ([_player.playingMuzzik.color intValue] == 3) {
            [playButton setImage:[UIImage imageNamed:Image_PlayerbluecircleplayImage] forState:UIControlStateNormal];
        }else{
            [playButton setImage:[UIImage imageNamed:Image_PlayerredcircleplayImage] forState:UIControlStateNormal];
        }
    }
}
#pragma mark -Action
-(void)playAction{
    [self.player playnow];
    
}
-(void)moveAction{
    userInfo *user = [userInfo shareClass];
    if ([user.token length]>0) {
        _player.playingMuzzik.ismoved = !_player.playingMuzzik.ismoved;
        if (_player.playingMuzzik.ismoved) {
            _player.playingMuzzik.moveds = [NSString stringWithFormat:@"%d",[_player.playingMuzzik.moveds intValue]+1 ];
        }else{
            _player.playingMuzzik.moveds = [NSString stringWithFormat:@"%d",[_player.playingMuzzik.moveds intValue]-1 ];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:String_MuzzikDataSource_update object:_player.playingMuzzik];
        ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/muzzik/%@/moved",BaseURL,_player.playingMuzzik.muzzik_id]]];
        [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:_player.playingMuzzik.ismoved] forKey:@"ismoved"] Method:PostMethod auth:YES];
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
        [userInfo checkLoginWithVC:self];
    }
}
-(void)nextAction{
    [self.player playNext];
}
-(void)commentAction{
    userInfo *user = [userInfo shareClass];
    if ([user.token length]>0) {
        MuzzikObject *mobject = [MuzzikObject shareClass];
        userInfo *user = [userInfo shareClass];
        user.poController = self;
        
        mobject.music = _player.playingMuzzik.music;
        [MuzzikItem getLyricByMusic:_player.playingMuzzik.music];
        MessageStepViewController *messagebv = [[MessageStepViewController alloc] init];
        [self.navigationController pushViewController:messagebv animated:YES];
    }else{
        [userInfo checkLoginWithVC:self];
    }
}
-(void)modelAction{
    if (_player.isPlayBack) {
        _player.isPlayBack = !_player.isPlayBack;
        [playModelButton setImage:[UIImage imageNamed:Image_PlayerloopImage] forState:UIControlStateNormal];
    }else{
        _player.isPlayBack = !_player.isPlayBack;
        [playModelButton setImage:[UIImage imageNamed:Image_PlayerloopclickImage] forState:UIControlStateNormal];
    }
    
}


-(void) attentionAction{
    if ([[userInfo shareClass].token length]>0) {
        _player.playingMuzzik.MuzzikUser.isFollow = YES;
        [attentionButton setHidden:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:String_UserDataSource_update object:_player.playingMuzzik.MuzzikUser];
        ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_User_Follow]]];
        [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:_player.playingMuzzik.MuzzikUser.user_id forKey:@"_id"] Method:PostMethod auth:YES];
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
        [userInfo checkLoginWithVC:self];
    }
    
}

-(void)gotoUserDetail:(UIButton_UserMuzzik *) sender{
    userInfo *user = [userInfo shareClass];
    if ([sender.user.user_id isEqualToString:user.uid]) {
        UserHomePage *home = [[UserHomePage alloc] init];
        home.isPush = YES;
        [self.navigationController pushViewController:home animated:YES];
    }else{
        userDetailInfo *detailuser = [[userDetailInfo alloc] init];
        detailuser.uid = sender.user.user_id;
        [self.navigationController pushViewController:detailuser animated:YES];
    }
    
}
-(void)seeDetail{
    if ([_player.playingMuzzik.muzzik_id length]>0) {
        AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
        UINavigationController *nac = (UINavigationController *)app.tabviewController.selectedViewController;
        UIViewController *vc  = [nac.viewControllers lastObject];
        if ([vc isKindOfClass:[ DetaiMuzzikVC class]]) {
            DetaiMuzzikVC *detail = (DetaiMuzzikVC *)vc;
            if (![detail.muzzik_id isEqualToString:_player.playingMuzzik.muzzik_id]) {
                DetaiMuzzikVC *godetail = [[DetaiMuzzikVC alloc] init];
                godetail.muzzik_id = _player.playingMuzzik.muzzik_id;
                
                [nac pushViewController:godetail animated:YES];
            }
        }else{
            DetaiMuzzikVC *godetail = [[DetaiMuzzikVC alloc] init];
            godetail.muzzik_id = _player.playingMuzzik.muzzik_id;
            
            [nac pushViewController:godetail animated:YES];
        }
        
    }
}
-(void)progressChange:(UISlider *) progressSlider{
    [_player.player seekToTime:progressSlider.value];
}
-(void)backAction:(UIButton *)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)playListAction:(UIButton *)sender{
    if (_IsShowPlayList) {
        _IsShowPlayList = NO;
        [UIView animateWithDuration:0.30 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [plistTableView setFrame:CGRectMake(SCREEN_WIDTH, SCREEN_HEIGHT/2-130, SCREEN_WIDTH, 220)];
            [self.playView setFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT-199)];
        }completion:nil];
    }else{
        _IsShowPlayList = YES;
        userInfo *user = [userInfo shareClass];
        playListArray = [NSMutableArray array];
        
        if (![_player.listType isEqualToString:SquareList]) {
            [playListArray addObject:[user.playList objectForKey:Constant_userInfo_square]];
        }
        if (![_player.listType isEqualToString:feedList]) {
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
        if ([user.token length]>0) {
            if (![_player.listType isEqualToString:ownList]) {
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
            
            
            
            if (![_player.listType isEqualToString:MovedList]) {
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
        if (![_player.listType isEqualToString:suggestList]) {
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
        
        if (![_player.listType isEqualToString:TempList] && user.checkTemp ) {
            [playListArray addObject:[user.playList objectForKey:Constant_userInfo_temp]];
        }
        [self checkReloadPlayListTable];
        
        [UIView animateWithDuration:0.30 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [plistTableView setFrame:CGRectMake(0, SCREEN_HEIGHT/2-130, SCREEN_WIDTH, 220)];
            [self.playView setFrame:CGRectMake(-SCREEN_WIDTH, 64, SCREEN_WIDTH, SCREEN_HEIGHT-199)];
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

- (void)playDidChangeNotification:(NSNotification *)notification {
    
    if (_player.player.state == STKAudioPlayerStateStopped) {
        globle.isPlaying = NO;
        NSLog(@"停止");
        [playButton stopAnimation];
        if ([_player.playingMuzzik.color intValue] == 2) {
            [playButton setImage:[UIImage imageNamed:Image_PlayeryellowcircleplayImage] forState:UIControlStateNormal];
        }else if ([_player.playingMuzzik.color intValue] == 3) {
            [playButton setImage:[UIImage imageNamed:Image_PlayerbluecircleplayImage] forState:UIControlStateNormal];
        }else{
            [playButton setImage:[UIImage imageNamed:Image_PlayerredcircleplayImage] forState:UIControlStateNormal];
        }
    } else if(_player.player.state == STKAudioPlayerStatePlaying) {
        NSLog(@"播放");
        [playButton stopAnimation];
        if ([_player.playingMuzzik.color intValue] == 2) {
            [playButton setImage:[UIImage imageNamed:Image_PlayeryellowcirclestopImage] forState:UIControlStateNormal];
        }else if ([_player.playingMuzzik.color intValue] == 3) {
            [playButton setImage:[UIImage imageNamed:Image_PlayerbluecirclestopImage] forState:UIControlStateNormal];
        }else{
            [playButton setImage:[UIImage imageNamed:Image_PlayerredcirclestopImage] forState:UIControlStateNormal];
        }
    } else if(_player.player.state == STKAudioPlayerStatePaused) {
        NSLog(@"暂停");
        [playButton stopAnimation];
        if ([_player.playingMuzzik.color intValue] == 2) {
            [playButton setImage:[UIImage imageNamed:Image_PlayeryellowcircleplayImage] forState:UIControlStateNormal];
        }else if ([_player.playingMuzzik.color intValue] == 3) {
            [playButton setImage:[UIImage imageNamed:Image_PlayerbluecircleplayImage] forState:UIControlStateNormal];
        }else{
            [playButton setImage:[UIImage imageNamed:Image_PlayerredcircleplayImage] forState:UIControlStateNormal];
        }
    }
    else if (_player.player.state == STKAudioPlayerStateBuffering){
        [playButton startAnimation];
    }
}

#pragma mark private_method

-(void) updatePlaybackProgress
{
    progress.minimumValue = 0;
    progress.maximumValue = _player.player.duration;
    if (_player.player.progress<3.0) {
        [nextButton setEnabled:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:String_SetSongInformationNotification object:nil userInfo:nil];
    }
    [progress setValue:_player.player.progress animated:YES];
    _currentPlaybackTime.text =[self TimeformatFromSeconds:_player.player.progress total:_player.player.duration];
    
}
-(NSString*)TimeformatFromSeconds:(int)seconds total:(int)total
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
        itemStr1 = [NSString stringWithFormat:@"%@/%02d:%02d",itemStr, tm, ts];
    }
    else{
        itemStr1 = [NSString stringWithFormat:@"%@/%02d:%02d:%02d",itemStr, th, tm, ts];
    }
    if ([lyricArray count]>0) {
        for (NSDictionary *dic in lyricArray) {
            if ([[[dic allKeys] objectAtIndex:0] isEqualToString:itemStr]) {
                [self performSelector:@selector(scrolllyric:) withObject:dic afterDelay:0.5];
                
                break;
            }
        }
    }
    if (_player.player.duration > 0 ) {
        return  itemStr1;
    }else{
        return @"00:00/00:00";
    }
    
    
}
-(void)scrolllyric:(NSDictionary *)dic{
    if ([lyricArray containsObject:dic]) {
        [lyricTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[lyricArray indexOfObject:dic] inSection:0]  atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
    
}
-(void) parseLrcLine:(NSString *)sourceLineText
{
    
    
    [lyricArray removeAllObjects];
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
                    [lyricArray addObject:dic];
                }
            }
        }
    }
    if ([lyricArray count] == 0) {
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
                        [lyricArray addObject:dic];
                    }
                }
            }
        }
    }
    lyricArray = [NSMutableArray arrayWithArray:[lyricArray sortedArrayUsingComparator: ^(id obj1, id obj2) {
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
    NSArray *larray = [NSArray arrayWithArray:lyricArray];
    for (long i = larray.count-1; i>0; i--) {
        NSDictionary *dic = larray[i];
        // NSLog(@"%d",[[[dic allValues][0] stringByTrimmingCharactersInSet:[NSCharacterSet symbolCharacterSet]] length]);
        if ([[[dic allValues][0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0 ) {
            [lyricArray removeObjectAtIndex:[larray indexOfObject:dic]];
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
- (void) durationAvailable:(NSNotification*)notification
{
    ableToSeek = YES;
    progress.userInteractionEnabled = YES;

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark -TableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == lyricTableView) {
        return lyricArray.count;
    }else{
        return playListArray.count;
    }
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    [cell setBackgroundColor:[UIColor clearColor]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    if (tableView == lyricTableView) {
        cell.textLabel.text =[[lyricArray[indexPath.row] allObjects][0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
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
        [cell.textLabel setTextColor:[UIColor whiteColor]];
        return cell;
    }
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == lyricTableView) {
        UILabel *tempLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 10, SCREEN_WIDTH-50, 80)];
        tempLabel.font = [UIFont fontWithName:Font_Next_Regular size:16];
        tempLabel.text = [[lyricArray[indexPath.row] allObjects][0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
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
        MuzzikPlayer *player = [MuzzikPlayer shareClass];
        NSMutableArray *muzziks = [dic objectForKey:UserInfo_muzziks];
        player.MusicArray = muzziks;
        player.listType = [dic objectForKey:@"type"];
        [player playSongWithSongModel:muzziks[0] Title:[dic objectForKey:UserInfo_description]];
        titleView.text = [NSString stringWithFormat:@"正在播放 %@",_player.viewTitle];
        if ([self respondsToSelector:@selector(playListAction:)]) {
            [self performSelector:@selector(playListAction:) withObject:nil afterDelay:0.5];
        }
        
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)sView
{
    int index = fabs(sView.contentOffset.x) / sView.frame.size.width;
    //NSLog(@"%d",index);
    [pagecontrol setCurrentPage:index];
}
-(void)dataSourceMuzzikUpdate:(NSNotification *)notify{
    muzzik *tempMuzzik = (muzzik *)notify.object;
    if ([_player.playingMuzzik.muzzik_id isEqualToString:tempMuzzik.muzzik_id]) {
        _player.playingMuzzik.ismoved = tempMuzzik.ismoved;
        _player.playingMuzzik.isReposted = tempMuzzik.isReposted;
        _player.playingMuzzik.moveds = tempMuzzik.moveds;
        _player.playingMuzzik.reposts = tempMuzzik.reposts;
        _player.playingMuzzik.shares = tempMuzzik.shares;
        _player.playingMuzzik.comments = tempMuzzik.comments;
        UIColor *color;
        if ([_player.playingMuzzik.color intValue] == 2) {
            color = Color_Action_Button_1;
            if (_player.playingMuzzik.ismoved) {
                [movedButton setImage:[UIImage imageNamed:Image_PlayeryellowlikedImage] forState:UIControlStateNormal];
            }else{
                [movedButton setImage:[UIImage imageNamed:Image_PlayeryellowlikeImage] forState:UIControlStateNormal];
            }
        }else if ([_player.playingMuzzik.color intValue] == 3){
            color = Color_Action_Button_2;
            if (_player.playingMuzzik.ismoved) {
                [movedButton setImage:[UIImage imageNamed:Image_PlayerbluelikedImage] forState:UIControlStateNormal];
            }else{
                [movedButton setImage:[UIImage imageNamed:Image_PlayerbluelikeImage] forState:UIControlStateNormal];
            }
        }else{
            color = Color_Action_Button_3;
            if (_player.playingMuzzik.ismoved) {
                [movedButton setImage:[UIImage imageNamed:Image_PlayerredlikedImage] forState:UIControlStateNormal];
            }else{
                [movedButton setImage:[UIImage imageNamed:Image_PlayerredlikeImage] forState:UIControlStateNormal];
            }
        }
    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
