//
//  FeedViewController.m
//  muzzik
//
//  Created by muzzik on 15/6/12.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "FeedViewController.h"
#import "UIImageView+WebCache.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "NormalCell.h"
#import "TopicHeaderView.h"
#import "appConfiguration.h"
#import <MediaPlayer/MediaPlayer.h>
#import "TTTAttributedLabel.h"
#import "ChooseMusicVC.h"
#import "LoginViewController.h"
#import "UIButton+WebCache.h"
#import "showUserVC.h"
#import "NormalNoCardCell.h"
#import "DetaiMuzzikVC.h"
#import "MuzzikCard.h"
#import "MuzzikNoCardCell.h"
#import "userDetailInfo.h"
#import "TopicDetail.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import "MuzzikSongCell.h"
#import "MuzzikTopic.h"
#import "songDetailVCViewController.h"
#import "MessageStepViewController.h"
#import "RDVTabBarController.h"
#import "searchViewController.h"
#import "NotifyButton.h"


#define size_to_change  3
@interface FeedViewController ()<UITableViewDataSource,UITableViewDelegate,UICollectionViewDelegateFlowLayout,TTTAttributedLabelDelegate,CellDelegate>{
    NSArray *localMuzzikIdArray;
    NSMutableArray *suggestDayArray;
    UIView *userView;
    NSMutableArray *userArray;
    BOOL isUserTaped;
    UIImage *shareImage;
    UITableView *feedTableView;
    UITableView *trendTableView;
    UIView *addView;
    NSString *trendLastId;
    BOOL diffDate;
    NSString *feedLastId;
    
    UIImageView *activityImage;
    UIImageView *wordImage;
    
    UIImageView *startLogo;
    NSMutableDictionary *feedRefreshDic;
    NSMutableDictionary *feedReFreshPoImageDic;
    
    NSMutableDictionary *trendRefreshDic;
    NSMutableDictionary *trendReFreshPoImageDic;
    //shareView
    muzzik *shareMuzzik;
    UIView *shareViewFull;
    UIView *shareView;
    UIButton *shareToTimeLineButton;
    UIButton *shareToWeiChatButton;
    UIButton *shareToWeiboButton;
    UIButton *shareToQQButton;
    UIButton *shareToQQZoneButton;
    CGFloat maxScaleY;
    UIScrollView *mainScroll;
    UIView *switchView;
    UIButton *feedButton;
    UIButton *trendButton;
    UIView *lineBar;
    
    NSTimer *timer;
    NSInteger timeCount;
    UIImageView *coverImageView;
    NotifyButton *notifyBtn;
    UIAlertView *starAlert;
    
    NSMutableArray *muzzikArray;
    
    dispatch_queue_t _serialQueue;
    
    
}
@property(nonatomic,retain) muzzik *repostMuzzik;

@property(atomic,retain) NSMutableArray *feedMuzziks;
@property(atomic,retain) NSMutableArray *trendMuzziks;

@end

@implementation FeedViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    suggestDayArray = [NSMutableArray array];
    [self initNagationBar:@"" leftBtn:8 rightBtn:0];
    _serialQueue = dispatch_queue_create("serialQueue", DISPATCH_QUEUE_SERIAL);
    self.feedMuzziks = [NSMutableArray array];
    self.trendMuzziks = [NSMutableArray array];
    
    feedRefreshDic = [NSMutableDictionary dictionary];
    feedReFreshPoImageDic = [NSMutableDictionary dictionary];
    
    trendRefreshDic = [NSMutableDictionary dictionary];
    trendReFreshPoImageDic = [NSMutableDictionary dictionary];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteMuzzik:) name:String_Muzzik_Delete object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataSourceUserUpdate:) name:String_UserDataSource_update object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataSourceMuzzikUpdate:) name:String_MuzzikDataSource_update object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playnextMuzzikUpdate) name:String_SetSongPlayNextNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNewSendMuzzik:) name:String_SendNewMuzzikDataSource_update object:nil];
    // [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    feedTableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    [feedTableView  setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    feedTableView.dataSource = self;
    feedTableView.delegate = self;
    [feedTableView registerClass:[NormalCell class] forCellReuseIdentifier:@"NormalCell"];
    [feedTableView registerClass:[NormalNoCardCell class] forCellReuseIdentifier:@"NormalNoCardCell"];
    [feedTableView registerClass:[MuzzikCard class] forCellReuseIdentifier:@"MuzzikCard"];
    [feedTableView registerClass:[MuzzikNoCardCell class] forCellReuseIdentifier:@"MuzzikNoCardCell"];
    [feedTableView registerClass:[MuzzikSongCell class] forCellReuseIdentifier:@"MuzzikSongCell"];
    [feedTableView registerClass:[MuzzikTopic class] forCellReuseIdentifier:@"MuzzikTopic"];
    [feedTableView addHeaderWithTarget:self action:@selector(feedRefreshHeader)];
    [feedTableView addFooterWithTarget:self action:@selector(feedReshFooter)];
    
    trendTableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    [trendTableView  setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    trendTableView.dataSource = self;
    trendTableView.delegate = self;
    [trendTableView registerClass:[NormalCell class] forCellReuseIdentifier:@"NormalCell"];
    [trendTableView registerClass:[NormalNoCardCell class] forCellReuseIdentifier:@"NormalNoCardCell"];
    [trendTableView registerClass:[MuzzikCard class] forCellReuseIdentifier:@"MuzzikCard"];
    [trendTableView registerClass:[MuzzikNoCardCell class] forCellReuseIdentifier:@"MuzzikNoCardCell"];
    [trendTableView registerClass:[MuzzikSongCell class] forCellReuseIdentifier:@"MuzzikSongCell"];
    [trendTableView registerClass:[MuzzikTopic class] forCellReuseIdentifier:@"MuzzikTopic"];
    [trendTableView addHeaderWithTarget:self action:@selector(trendRefreshHeader)];
    [trendTableView addFooterWithTarget:self action:@selector(trendRefreshFooter)];
    
    
    
    mainScroll = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [mainScroll setBackgroundColor:[UIColor whiteColor]];
    [mainScroll setContentSize:CGSizeMake(SCREEN_WIDTH * 2, self.view.bounds.size.height)];
    mainScroll.pagingEnabled = YES;
    [self.view addSubview:mainScroll];
    userInfo *user = [userInfo shareClass];
    if ([user.token length]>0) {
        
        [mainScroll addSubview:feedTableView];
        [trendTableView setFrame:CGRectMake(SCREEN_WIDTH, trendTableView.frame.origin.y, trendTableView.frame.size.width, trendTableView.frame.size.height)];
        [mainScroll addSubview:trendTableView];
        [self trendReloadMuzzikSource];
        [self feedReloadMuzzikSource];
    }else{
        [mainScroll addSubview:trendTableView];
        [self trendReloadMuzzikSource];
    }
    
    
    [self SettingShareView];

    userView = [[UIView alloc] initWithFrame:CGRectMake(0, -75, SCREEN_WIDTH, 75)];
    [userView setBackgroundColor:Color_line_2];
    [userView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(seeMoreUser)]];
    switchView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 -60, 0, 120, 44)];
    feedButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, switchView.frame.size.width/2, switchView.frame.size.height-2)];
    [feedButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [feedButton setTitle:@"关注" forState:UIControlStateNormal];
    [feedButton.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [feedButton addTarget:self action:@selector(switchTableView:) forControlEvents:UIControlEventTouchDown];
    trendButton = [[UIButton alloc] initWithFrame:CGRectMake(switchView.frame.size.width/2, 0, switchView.frame.size.width/2, switchView.frame.size.height-2)];
    [trendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [trendButton setTitle:@"广场" forState:UIControlStateNormal];
    [trendButton.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [trendButton addTarget:self action:@selector(switchTableView:) forControlEvents:UIControlEventTouchDown];
    [switchView addSubview:trendButton];
    [switchView addSubview:feedButton];
    lineBar = [[UIView alloc] initWithFrame:CGRectMake(0, switchView.frame.size.height-2, switchView.frame.size.width/2, 2)];
    [lineBar setBackgroundColor:Color_Active_Button_1];
    [switchView addSubview:lineBar];
    [mainScroll addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    mainScroll.bounces = NO;
    if (self.rdv_tabBarController.tabBar.translucent) {
        UIEdgeInsets insets = UIEdgeInsetsMake(0,
                                               0,
                                               CGRectGetHeight(self.rdv_tabBarController.tabBar.frame),
                                               0);
        
        feedTableView.contentInset = insets;
        feedTableView.scrollIndicatorInsets = insets;
        
        trendTableView.contentInset = insets;
        trendTableView.scrollIndicatorInsets = insets;
    }
    NSDate *  senddate=[NSDate date];
    
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    
    [dateformatter setDateFormat:@"YYYYMMdd"];
    
    NSString *locationString=[dateformatter stringFromDate:senddate];
    NSString *lastShowDateString = [MuzzikItem getStringForKey:@"Muzzik_lastShowDateString"];
    diffDate =![lastShowDateString isEqualToString:locationString];
    NSArray *activityArray = [MuzzikItem getArrayFromLocalForKey:@"Muzzik_activity_localData"];
    BOOL showed = NO;
    if ([activityArray count] >0) {
        for (NSDictionary *tempDic in activityArray) {
            NSString *from  = [self transformDateToString:[tempDic objectForKey:@"from"]];
            NSString *to    = [self transformDateToString:[tempDic objectForKey:@"to"]];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
            NSString *now   = [formatter stringFromDate:[NSDate date]];
            NSLog(@"%ld   %ld",(long)[now compare:from],(long)[now compare:to]);
            if ([now compare:from]>=0  && [now compare:to]<=0) {
                
                NSData *image = [MuzzikItem getDataFromLocalKey:[tempDic objectForKey:@"image"]];
                NSData *textImageEX = [MuzzikItem getDataFromLocalKey:[tempDic objectForKey:@"textImageEX"]];
                showed = YES;
                [self addCoverVCToWindowFullImage:[UIImage imageWithData: image] slogan:[UIImage imageWithData: textImageEX]];
                break;
                
            }
        }
    }
    if (!showed) {
        [self addCoverVCToWindowFullImage:nil slogan:nil];
    }
    
    
    
    
    NSLog(@"locationString:%@",locationString);
    NSDictionary *dic = [MuzzikItem getDictionaryFromLocalForKey:@"Muzzik_Check_Comment_Five_star"];
    if (dic == nil) {
        dic = [NSDictionary dictionaryWithObjectsAndKeys:@"0",@"times",locationString,@"date",@"no",@"hasClicked", nil];
        [MuzzikItem addObjectToLocal:dic ForKey:@"Muzzik_Check_Comment_Five_star"];
    }else if(![[dic objectForKey:@"hasClicked"] isEqualToString:@"yes"]){
        
        if (![[dic objectForKey:@"date"] isEqualToString:locationString]) {
            NSString *tempString = [dic objectForKey:@"times"];
            tempString = [NSString stringWithFormat:@"%d",[tempString intValue]+1];
            if ([tempString intValue]==2) {
                [MuzzikItem addObjectToLocal:[NSDictionary dictionaryWithObjectsAndKeys:@"0",@"times",locationString,@"date",@"no",@"hasClicked", nil] ForKey:@"Muzzik_Check_Comment_Five_star"];
                timeCount = 120;
                timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
                [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
            }else{
                [MuzzikItem addObjectToLocal:[NSDictionary dictionaryWithObjectsAndKeys:tempString,@"times",locationString,@"date",@"no",@"hasClicked", nil] ForKey:@"Muzzik_Check_Comment_Five_star"];
            }
        }
    }
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:NO animated:YES];
    userInfo *user = [userInfo shareClass];
    if ([user.token length] >0) {
        [self initNagationBar:switchView leftBtn:8 rightBtn:0];
        [trendTableView setFrame:CGRectMake(SCREEN_WIDTH, trendTableView.frame.origin.y, trendTableView.frame.size.width, trendTableView.frame.size.height)];
        [mainScroll addSubview:feedTableView];
        [mainScroll setContentSize:CGSizeMake(SCREEN_WIDTH*2, self.view.bounds.size.height)];
        [self.navigationController.navigationBar addSubview:self.navigationItem.titleView];
    }else{
        [trendTableView setFrame:CGRectMake(0, trendTableView.frame.origin.y, trendTableView.frame.size.width, trendTableView.frame.size.height)];
        [feedTableView removeFromSuperview];
        
        [mainScroll setContentSize:CGSizeMake(SCREEN_WIDTH, self.view.bounds.size.height)];
        [switchView removeFromSuperview];
        [self initNagationBar:[UIImage imageNamed:@"MuzzikImage"] leftBtn:8 rightBtn:0];
    }
    if (user.isSwitchUser) {
        user.isSwitchUser = NO;
        [self trendReloadMuzzikSource];
        [self feedReloadMuzzikSource];
    }
    [shareViewFull setAlpha:0];
    [shareView setFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_WIDTH*maxScaleY)];
    [shareViewFull removeFromSuperview];
    //    UIImageView *headImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"followtitleImage"]];
    //    [headImage setFrame:CGRectMake((self.parentRoot.titleShowView.frame.size.width-headImage.frame.size.width)/2, 5, headImage.frame.size.width, headImage.frame.size.height)];
    
    // MytableView add
    //[MytableView reloadData];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [switchView removeFromSuperview];
    //[self.rdv_tabBarController setTabBarHidden:YES animated:YES];
}
-(NSString *)transformDateToString:(NSString *) time{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    NSDate *localDate = [dateFormatter dateFromString:time];
    NSDate *Tdate = [NSDate date];
    NSTimeZone *zone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    NSInteger Tinterval = [zone secondsFromGMTForDate: Tdate];
    
    NSDate *aimDate = [localDate  dateByAddingTimeInterval: Tinterval];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    return [formatter stringFromDate:aimDate];

}
-(void)updateTime{
    if (timeCount>0) {
        NSLog(@"%d",timeCount);
        timeCount-- ;
    }else{
         starAlert= [[UIAlertView alloc] initWithTitle:@"跪求五星好评" message:@"" delegate:self cancelButtonTitle:@"残忍拒绝" otherButtonTitles:nil];
        // optional - add more buttons:
        [starAlert addButtonWithTitle:@"走你!"];
        [starAlert show];
        [timer invalidate];
        timer = nil;
        
    }
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    [lineBar setFrame:CGRectMake(mainScroll.contentOffset.x*(lineBar.frame.size.width/SCREEN_WIDTH), lineBar.frame.origin.y, lineBar.frame.size.width, lineBar.frame.size.height)];
}
-(void)dealloc{
    [mainScroll removeObserver:self forKeyPath:@"contentOffset"];
}
-(void)switchTableView:(UIButton *)sender{
    if (sender == feedButton ) {
        [mainScroll scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
        
    }else{
        [mainScroll scrollRectToVisible:CGRectMake(SCREEN_WIDTH, 0, SCREEN_WIDTH, 1) animated:YES];
    }
}
-(void)tapAction:(UITapGestureRecognizer *)tap{
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    searchViewController *search = [[searchViewController alloc ] init];
    [self.navigationController pushViewController:search animated:YES];
}

- (void)addCoverVCToWindowFullImage:(UIImage *)fullImage slogan:(UIImage*)sloganImage{
    userInfo *user = [userInfo shareClass];
    user.launched = YES;
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    addView = [[UIView alloc] initWithFrame:self.navigationController.view.bounds];
    coverImageView = [[UIImageView alloc] initWithFrame:self.navigationController.view.bounds];
    UIImageView *startSlogan;
    
    if (fullImage && sloganImage) {
        [coverImageView setImage:fullImage];
        startSlogan =[[UIImageView alloc] initWithImage:sloganImage];
    }else{
        [coverImageView setImage:[UIImage imageNamed:@"startImage"]];
        startSlogan =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Startslogan"]];
    }
    
    coverImageView.contentMode = UIViewContentModeScaleAspectFill;
    CGFloat sizeScale = startSlogan.image.size.width/(SCREEN_WIDTH*0.9);
    if (sizeScale >= 1) {
        [startSlogan setFrame:CGRectMake(SCREEN_WIDTH*3/80, 64, startSlogan.image.size.width/sizeScale, startSlogan.image.size.height/sizeScale)];
    }else{
        [startSlogan setFrame:CGRectMake(SCREEN_WIDTH*3/80, 64, startSlogan.image.size.width, startSlogan.image.size.height)];
    }
    
    
    [startSlogan setAlpha:0];
    startSlogan.contentMode = UIViewContentModeScaleAspectFit;
    [UIView animateWithDuration:2 animations:^{
        [startSlogan setAlpha:1];
    }];
    if (fullImage) {
        startLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"landingpageshareImage"]];
        
    }else{
        startLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"muzzikSlogan"]];
        
    }
    [startLogo setFrame:CGRectMake(SCREEN_WIDTH-18-startLogo.frame.size.width, SCREEN_HEIGHT-startLogo.frame.size.height-18, startLogo.frame.size.width, startLogo.frame.size.height)];
    UIButton *tapButton = [[UIButton alloc] initWithFrame:startLogo.frame];
    [tapButton addTarget:self action:@selector(activityShareAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    NSLog(@"width:%f",[ UIScreen mainScreen ].bounds.size.width);
    [coverImageView addSubview:startLogo];
    [coverImageView addSubview:startSlogan];
    [addView addSubview:coverImageView];
    [addView addSubview:tapButton];
    [app.window addSubview:addView];
    
    if (fullImage) {
        [UIView animateWithDuration:1 animations:^{
            [startLogo setFrame:CGRectMake(startLogo.frame.origin.x-size_to_change, startLogo.frame.origin.y-size_to_change, startLogo.frame.size.width+2*size_to_change, startLogo.frame.size.height+2*size_to_change)];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:1 animations:^{
                [startLogo setFrame:CGRectMake(startLogo.frame.origin.x+size_to_change, startLogo.frame.origin.y+size_to_change, startLogo.frame.size.width-2*size_to_change, startLogo.frame.size.height-2*size_to_change)];
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:1 animations:^{
                    [startLogo setFrame:CGRectMake(startLogo.frame.origin.x-size_to_change, startLogo.frame.origin.y-size_to_change, startLogo.frame.size.width+2*size_to_change, startLogo.frame.size.height+2*size_to_change)];
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:1 animations:^{
                        [startLogo setFrame:CGRectMake(startLogo.frame.origin.x+size_to_change, startLogo.frame.origin.y+size_to_change, startLogo.frame.size.width-2*size_to_change, startLogo.frame.size.height-2*size_to_change)];
                    } completion:^(BOOL finished) {
                        [UIView animateWithDuration:1 animations:^{
                            [startLogo setFrame:CGRectMake(startLogo.frame.origin.x-size_to_change, startLogo.frame.origin.y-size_to_change, startLogo.frame.size.width+2*size_to_change, startLogo.frame.size.height+2*size_to_change)];
                        } completion:^(BOOL finished) {
                            [UIView animateWithDuration:1 animations:^{
                                [startLogo setFrame:CGRectMake(startLogo.frame.origin.x+size_to_change, startLogo.frame.origin.y+size_to_change, startLogo.frame.size.width-2*size_to_change, startLogo.frame.size.height-2*size_to_change)];
                            } completion:^(BOOL finished) {
                                [UIView animateWithDuration:1 animations:^{
                                    [startLogo setAlpha:0];
                                } completion:^(BOOL finished) {
                                    [UIView animateWithDuration:0.3 animations:^{
                                        [startLogo setHidden:YES];
                                        [startSlogan setHidden:YES];
                                        [coverImageView setAlpha:0];
                                        [coverImageView setFrame:CGRectMake(-coverImageView.frame.size.width, -coverImageView.frame.size.height, coverImageView.frame.size.width*3, coverImageView.frame.size.height*3)];
                                    } completion:^(BOOL finished) {
                                        [coverImageView removeFromSuperview];
                                        [addView removeFromSuperview];
                                        [self checkTeachPo];
                                    }];
                                }];
                            }];
                        }];
                    }];
                }];
            }];
        }];
    }else{
        
        [UIView animateWithDuration:5 animations:^{
            [startLogo setFrame:CGRectMake(startLogo.frame.origin.x-1, startLogo.frame.origin.y, startLogo.frame.size.width, startLogo.frame.size.height)];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.5 animations:^{
                [startLogo setHidden:YES];
                [startSlogan setHidden:YES];
                [coverImageView setAlpha:0];
                [coverImageView setFrame:CGRectMake(-coverImageView.frame.size.width, -coverImageView.frame.size.height, coverImageView.frame.size.width*3, coverImageView.frame.size.height*3)];
            } completion:^(BOOL finished) {
                [coverImageView removeFromSuperview];
                [addView removeFromSuperview];
                [self checkTeachPo];
            }];
            
        }];

    }
    
}
-(void)checkTeachPo{
    if (diffDate) {
        NSString *dateCountString = [MuzzikItem getStringForKey:@"Muzzik_times_userPoDate"];
        if (!dateCountString||[dateCountString integerValue] == 0) {
            notifyBtn = [[NotifyButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-65, SCREEN_HEIGHT-158, 130, 34)];
            [notifyBtn setImage:[UIImage imageNamed:@"guide"] forState:UIControlStateNormal];
            [self.view addSubview:notifyBtn];
            [UIView beginAnimations:@"upAndDown" context:NULL];
            [UIView setAnimationDuration:1];
            
            [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
            [UIView setAnimationDelegate:self];
            [UIView setAnimationRepeatAutoreverses:YES];
            [UIView setAnimationRepeatCount:3];
            [notifyBtn setFrame:CGRectMake(SCREEN_WIDTH/2-65, SCREEN_HEIGHT-170, 130, 34)];
            [UIView commitAnimations];
            
            [MuzzikItem addObjectToLocal:@"6" ForKey:@"Muzzik_times_userPoDate"];
        }else{
            [MuzzikItem addObjectToLocal:[NSString stringWithFormat:@"%d",[dateCountString integerValue]-1] ForKey:@"Muzzik_times_userPoDate"];
        }
    }
    
}
-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    [UIView animateWithDuration:1 animations:^{
        [notifyBtn setAlpha:0];
    } completion:^(BOOL finished) {
        [notifyBtn setHidden:YES];
        [notifyBtn removeFromSuperview];
    }];
    
}
-(void)activityShareAction:(UIButton *)sender{
    
    userInfo *user = [userInfo shareClass];
    [startLogo setImage:[UIImage imageNamed:@"landingpageQRcode"]];
    [startLogo setFrame:CGRectMake(SCREEN_WIDTH-116, SCREEN_HEIGHT-116, 98, 98)];
    UIImage *myImage = [MuzzikItem convertViewToImage:addView];
    if (user.WeChatInstalled) {
        AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [app sendImageContent:myImage];
    }else{
        WBMessageObject *message = [WBMessageObject message];
        
        message.text =[NSString stringWithFormat:@"一起来用Muzzik吧"];
        
        WBImageObject *image = [WBImageObject object];
        image.imageData = UIImageJPEGRepresentation(myImage, 1.0);
        message.imageObject = image;
        AppDelegate *myDelegate =(AppDelegate*)[[UIApplication sharedApplication] delegate];
        
        WBAuthorizeRequest *authRequest = [WBAuthorizeRequest request];
        authRequest.redirectURI = URL_WeiBo_redirectURI;
        authRequest.scope = @"all";
        
        WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message authInfo:authRequest access_token:myDelegate.wbtoken];
        
        //    request.shouldOpenWeiboAppInstallPageIfNotInstalled = NO;
        [WeiboSDK sendRequest:request];
    }
    [addView removeFromSuperview];
}
- (void)feedRefreshHeader
{

    // [self updateSomeThing];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/muzzik/feeds",BaseURL]]];
    [request addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:Limit_Constant forKey:Parameter_Limit] Method:GetMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = request;
    dispatch_async(_serialQueue, ^{
        [request setCompletionBlock :^{
            // NSLog(@"%@",[weakrequest responseString]);
            NSData *data = [weakrequest responseData];
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            if (dic) {
                [self.feedMuzziks removeAllObjects];
                muzzik *muzzikToy = [muzzik new];
                NSArray *array = [muzzikToy makeMuzziksByMuzzikArray:[dic objectForKey:@"muzziks"]];
                for (muzzik *tempmuzzik in array) {
                    BOOL isContained = NO;
                    for (muzzik *arrayMuzzik in self.feedMuzziks) {
                        if ([arrayMuzzik.muzzik_id isEqualToString:tempmuzzik.muzzik_id]) {
                            isContained = YES;
                            break;
                        }
                        
                    }
                    if (!isContained) {
                        [self.feedMuzziks addObject:tempmuzzik];
                    }
                    isContained = NO;
                }
                
                ASIHTTPRequest *requestCard = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/muzzik/card",BaseURL]]];
                [requestCard addBodyDataSourceWithJsonByDic:nil Method:GetMethod auth:YES];
                __weak ASIHTTPRequest *weakrequestCard = requestCard;
                [requestCard setCompletionBlock :^{
                    NSMutableArray *suggestCardArray = [[MuzzikItem getArrayFromLocalForKey:@"Muzzik_suggest_Day_ClickArray"] mutableCopy];
                    if (!suggestCardArray) {
                        suggestCardArray = [NSMutableArray array];
                    }
                    NSData *data = [weakrequestCard responseData];
                    NSDictionary *cardDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                    NSArray *requestArray ;
                    if (cardDic && [[cardDic allKeys] containsObject:@"muzziks"]) {
                        requestArray = [cardDic objectForKey:@"muzziks"];
                        for (NSDictionary *tempDic in requestArray) {
                            
                            if (![suggestCardArray containsObject:[tempDic objectForKey:@"_id"]]) {
                                for (muzzik *checkMuzzik in self.feedMuzziks) {
                                    if ([[tempDic objectForKey:@"_id"] isEqualToString:checkMuzzik.muzzik_id]) {
                                        if (self.feedMuzziks.count >1) {
                                            
                                            [self.feedMuzziks removeObject:checkMuzzik];
                                        }
                                        break;
                                    }
                                    
                                }
                                muzzik *insertMuzzik = [[muzzik new] makeMuzziksByMuzzikArray:[NSMutableArray arrayWithObjects:tempDic, nil]][0];
                                if (insertMuzzik) {
                                    [self.feedMuzziks insertObject:insertMuzzik atIndex:1];
                                }
                                
                                break;
                            }
                            
                            
                        }
                        [MuzzikItem SetUserInfoWithMuzziks:self.feedMuzziks title:Constant_userInfo_follow description:[NSString stringWithFormat:@"关注列表"]];
                        
                        feedLastId = [dic objectForKey:@"tail"];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [feedTableView reloadData];
                            [feedTableView headerEndRefreshing];
                        });
                        
                    }
                    
                }];
                [requestCard setFailedBlock:^{
                    
                    [feedTableView headerEndRefreshing];
                }];
                [requestCard startAsynchronous];
            }
        }];
        [request setFailedBlock:^{
            [feedTableView headerEndRefreshing];
            NSLog(@"%@,%@",[weakrequest error],[weakrequest responseString]);
        }];
        [request startAsynchronous];
    });
    
    
}

- (void)feedReshFooter
{
    
    // [self updateSomeThing];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/muzzik/feeds",BaseURL]]];
    [request addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:feedLastId,Parameter_from,Limit_Constant,Parameter_Limit, nil] Method:GetMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = request;
    [request setCompletionBlock :^{
        // NSLog(@"%@",[weakrequest responseString]);
        NSData *data = [weakrequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (dic) {
            muzzik *muzzikToy = [muzzik new];
            NSArray *array = [muzzikToy makeMuzziksByMuzzikArray:[dic objectForKey:@"muzziks"]];
            for (muzzik *tempmuzzik in array) {
                BOOL isContained = NO;
                for (muzzik *arrayMuzzik in self.feedMuzziks) {
                    if ([arrayMuzzik.muzzik_id isEqualToString:tempmuzzik.muzzik_id]) {
                        isContained = YES;
                        break;
                    }
                    
                }
                if (!isContained) {
                    [self.feedMuzziks addObject:tempmuzzik];
                }
                isContained = NO;
            }
            [MuzzikItem SetUserInfoWithMuzziks:self.feedMuzziks title:Constant_userInfo_follow description:[NSString stringWithFormat:@"关注列表"]];
            feedLastId = [dic objectForKey:@"tail"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [feedTableView reloadData];
                [feedTableView footerEndRefreshing];
                if ([[dic objectForKey:@"muzziks"] count]<1 ) {
                    [feedTableView removeFooter];
                }
            });
            
        }
    }];
    [request setFailedBlock:^{
        [feedTableView footerEndRefreshing];
        NSLog(@"%@,%@",[weakrequest error],[weakrequest responseString]);
    }];
    [request startAsynchronous];
    
}


- (void)trendRefreshHeader
{
    // [self updateSomeThing];
    ASIHTTPRequest *request;
    userInfo *user = [userInfo shareClass];
    if ([user.token length]>0) {
        request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :@"http://117.121.26.174:8000/api/muzzik/trending"]];
    }else{
        request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :@"http://117.121.26.174:8000/api/muzzik/introduce"]];
    }
    dispatch_async(_serialQueue, ^{
        [request addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:Limit_Constant forKey:Parameter_Limit] Method:GetMethod auth:YES];
        __weak ASIHTTPRequest *weakrequest = request;
        [request setCompletionBlock :^{
            NSLog(@"%@",[weakrequest responseString]);
            NSData *data = [weakrequest responseData];
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            if (dic) {
                [self.trendMuzziks removeAllObjects];
                muzzik *muzzikToy = [muzzik new];
                NSArray *array = [muzzikToy makeMuzziksNeedsSetUserByMuzzikArray:[dic objectForKey:@"muzziks"]];
                for (muzzik *tempmuzzik in array) {
                    BOOL isContained = NO;
                    for (muzzik *arrayMuzzik in self.trendMuzziks) {
                        if ([arrayMuzzik.muzzik_id isEqualToString:tempmuzzik.muzzik_id]) {
                            isContained = YES;
                            break;
                        }
                        
                    }
                    if (!isContained) {
                        [self.trendMuzziks addObject:tempmuzzik];
                    }
                    isContained = NO;
                }
                if ([user.token length] >0 ) {
                    [self getLocalPopMuzzikidFresh:YES];
                }
                
            }
        }];
        [request setFailedBlock:^{
            [trendTableView headerEndRefreshing];
            NSLog(@"%@,%@",[weakrequest error],[weakrequest responseString]);
        }];
        [request startAsynchronous];
    });
    
    
}

- (void)trendRefreshFooter
{
    // [self updateSomeThing];
    ASIHTTPRequest *request;
    userInfo *user = [userInfo shareClass];
    if ([user.token length]>0) {
        request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :@"http://117.121.26.174:8000/api/muzzik/trending"]];
    }else{
        request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :@"http://117.121.26.174:8000/api/muzzik/introduce"]];
    }
    [request addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:trendLastId,Parameter_from,Limit_Constant,Parameter_Limit, nil] Method:GetMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = request;
    [request setCompletionBlock :^{
        // NSLog(@"%@",[weakrequest responseString]);
        NSData *data = [weakrequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (dic) {
            muzzik *muzzikToy = [muzzik new];
            NSArray *array = [muzzikToy makeMuzziksNeedsSetUserByMuzzikArray:[dic objectForKey:@"muzziks"]];
            for (muzzik *tempmuzzik in array) {
                BOOL isContained = NO;
                for (muzzik *arrayMuzzik in self.trendMuzziks) {
                    if ([arrayMuzzik.muzzik_id isEqualToString:tempmuzzik.muzzik_id]) {
                        isContained = YES;
                        break;
                    }
                    
                }
                if (!isContained) {
                    [self.trendMuzziks addObject:tempmuzzik];
                }
                isContained = NO;
            }
            [MuzzikItem SetUserInfoWithMuzziks:self.trendMuzziks title:Constant_userInfo_square description:nil];
            trendLastId = [dic objectForKey:@"tail"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [trendTableView reloadData];
                [trendTableView footerEndRefreshing];
                if ([[dic objectForKey:@"muzziks"] count]<[Limit_Constant integerValue] ) {
                    [trendTableView removeFooter];
                }
            });
            
        }
    }];
    [request setFailedBlock:^{
        [trendTableView footerEndRefreshing];
        NSLog(@"%@,%@",[weakrequest error],[weakrequest responseString]);
    }];
    [request startAsynchronous];
    
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    userInfo *user = [userInfo shareClass];
    if ([user.token length]>0) {
        if (tableView == feedTableView) {
            return self.feedMuzziks.count;
        }else{
            return self.trendMuzziks.count;
        }
    }else{
        return self.trendMuzziks.count;
    }
    
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    muzzik *tempMuzzik;
    userInfo *user = [userInfo shareClass];
    if ([user.token length]>0) {
        if (tableView == feedTableView) {
            tempMuzzik = [self.feedMuzziks objectAtIndex:indexPath.row];
        }else{
            tempMuzzik = [self.trendMuzziks objectAtIndex:indexPath.row];
        }
    }else{
        tempMuzzik = [self.trendMuzziks objectAtIndex:indexPath.row];
    }
    
    if ([tempMuzzik.type isEqualToString:@"normal"] ||[tempMuzzik.type isEqualToString:@"repost"]) {
        
        TTTAttributedLabel *label = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(75, 0, SCREEN_WIDTH-110, 500)];
        [label setFont:[UIFont systemFontOfSize:Font_Size_Muzzik_Message]];
        [label setText:tempMuzzik.message];
        CGFloat textHeight = [MuzzikItem heightForLabel:label WithText:label.text];
        if (textHeight>limitHeight) {
            if (![tempMuzzik.image isKindOfClass:[NSNull class]] && [tempMuzzik.image length]>0) {
                return (int)(260+limitHeight+SCREEN_WIDTH*3/4)+8;
            }else{
                return 248+limitHeight;
            }
            
        }else{
            if (![tempMuzzik.image isKindOfClass:[NSNull class]] && [tempMuzzik.image length]>0) {
                return (int)(260+textHeight+SCREEN_WIDTH*3/4)-2;
            }else{
                return 248+(int)textHeight;
            }
        }
    }else if([tempMuzzik.type isEqualToString:@"muzzikCard"]){
        TTTAttributedLabel *label = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(75, 0, SCREEN_WIDTH-96, 500)];
        [label setText:tempMuzzik.message];
        [label setFont:[UIFont systemFontOfSize:Font_Size_Muzzik_Message]];
        CGFloat textHeight = [MuzzikItem heightForLabel:label WithText:label.text];
        if (textHeight>limitHeight) {
            if (![tempMuzzik.image isKindOfClass:[NSNull class]] && [tempMuzzik.image length]>0) {
                return SCREEN_WIDTH+limitHeight+80;
            }else{
                return limitHeight+190;
            }
        }
        else{
            if (![tempMuzzik.image isKindOfClass:[NSNull class]] && [tempMuzzik.image length]>0) {
                return (int)(SCREEN_WIDTH+textHeight+80);
            }else{
                return textHeight+190;
            }
            
        }
    }
    else if([tempMuzzik.type isEqualToString:@"musicCard"]){
        return 108;
    }else if([tempMuzzik.type isEqualToString:@"topicCard"]){
        return 101;
    }else{
        return 0;
    }
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    muzzik *tempMuzzik;
    userInfo *user = [userInfo shareClass];
    if ([user.token length]>0) {
        if (tableView == feedTableView) {
            tempMuzzik = [self.feedMuzziks objectAtIndex:indexPath.row];
        }else{
            tempMuzzik = [self.trendMuzziks objectAtIndex:indexPath.row];
        }
    }else{
        tempMuzzik = [self.trendMuzziks objectAtIndex:indexPath.row];
    }
    
    if ([tempMuzzik isKindOfClass:[muzzik class]]) {
        if ([tempMuzzik.type isEqualToString:@"muzzikCard"]) {
            NSMutableArray *suggestDic = [[MuzzikItem getArrayFromLocalForKey:@"Muzzik_suggest_Day_ClickArray"] mutableCopy];
            if (!suggestDic) {
                suggestDic = [NSMutableArray array];
            }
            BOOL isTaped = NO;
            for (NSString *dicKey in suggestDic) {
                if ([dicKey isEqualToString:tempMuzzik.muzzik_id]) {
                    isTaped = YES;
                    break;
                }
            }
            if (!isTaped) {
                [suggestDic addObject:tempMuzzik.muzzik_id];
                if ([suggestDic count]>300) {
                    [MuzzikItem addObjectToLocal:[suggestDic subarrayWithRange:NSMakeRange(150, suggestDic.count-150)] ForKey:@"Muzzik_suggest_Day_ClickArray"];
                }else{
                    [MuzzikItem addObjectToLocal:[suggestDic copy] ForKey:@"Muzzik_suggest_Day_ClickArray"];
                }
            }
            DetaiMuzzikVC *detail = [[DetaiMuzzikVC alloc] init];
            detail.muzzik_id = tempMuzzik.muzzik_id;
            [self.navigationController pushViewController:detail animated:YES];
        }
        else if([tempMuzzik.type isEqualToString:@"musicCard"]){
            NSMutableArray *suggestDic = [[MuzzikItem getArrayFromLocalForKey:@"Muzzik_suggest_Day_ClickArray"] mutableCopy];
            if (!suggestDic) {
                suggestDic = [NSMutableArray array];
            }
            BOOL isTaped = NO;
            for (NSString *dicKey in suggestDic) {
                if ([dicKey isEqualToString:tempMuzzik.muzzik_id]) {
                    isTaped = YES;
                    break;
                }
            }
            if (!isTaped) {
                [suggestDic addObject:tempMuzzik.muzzik_id];
                if ([suggestDic count]>300) {
                    [MuzzikItem addObjectToLocal:[suggestDic subarrayWithRange:NSMakeRange(150, suggestDic.count-150)] ForKey:@"Muzzik_suggest_Day_ClickArray"];
                }else{
                    [MuzzikItem addObjectToLocal:[suggestDic copy] ForKey:@"Muzzik_suggest_Day_ClickArray"];
                }
            }

            songDetailVCViewController *songDetail = [[songDetailVCViewController alloc] init];
            songDetail.detailMuzzik = tempMuzzik;
            [self.navigationController pushViewController:songDetail animated:YES];
        }
        else if([tempMuzzik.type isEqualToString:@"topicCard"]){
            NSMutableArray *suggestDic = [[MuzzikItem getArrayFromLocalForKey:@"Muzzik_suggest_Day_ClickArray"] mutableCopy];
            if (!suggestDic) {
                suggestDic = [NSMutableArray array];
            }
            BOOL isTaped = NO;
            for (NSString *dicKey in suggestDic) {
                if ([dicKey isEqualToString:tempMuzzik.muzzik_id]) {
                    isTaped = YES;
                    break;
                }
            }
            if (!isTaped) {
                [suggestDic addObject:tempMuzzik.muzzik_id];
                if ([suggestDic count]>300) {
                    [MuzzikItem addObjectToLocal:[suggestDic subarrayWithRange:NSMakeRange(150, suggestDic.count-150)] ForKey:@"Muzzik_suggest_Day_ClickArray"];
                }else{
                    [MuzzikItem addObjectToLocal:[suggestDic copy] ForKey:@"Muzzik_suggest_Day_ClickArray"];
                }
            }

            TopicDetail *topic = [[TopicDetail alloc] init];
            topic.topic_id = [tempMuzzik.topics[0] objectForKey:@"_id"];
            [self.navigationController pushViewController:topic animated:YES];
        }
        else{
            DetaiMuzzikVC *detail = [[DetaiMuzzikVC alloc] init];
            detail.muzzik_id = tempMuzzik.muzzik_id;
            [self.navigationController pushViewController:detail animated:YES];
        }
        
        
    }
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Globle *glob = [Globle shareGloble];
    muzzik *tempMuzzik;
    userInfo *user = [userInfo shareClass];
    if ([user.token length]>0) {
        if (tableView == feedTableView) {
            tempMuzzik = [self.feedMuzziks objectAtIndex:indexPath.row];
        }else{
            tempMuzzik = [self.trendMuzziks objectAtIndex:indexPath.row];
        }
    }else{
        tempMuzzik = [self.trendMuzziks objectAtIndex:indexPath.row];
    }
    if ([tempMuzzik.type isEqualToString:@"repost"] || [tempMuzzik.type isEqualToString:@"normal"] || [tempMuzzik.type isEqualToString:@"muzzikCard"])
    {
        if (![tempMuzzik.image isKindOfClass:[NSNull class]] && [tempMuzzik.image length] == 0) {
            if ([tempMuzzik.type isEqualToString:@"repost"] ){
                NormalCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NormalCell" forIndexPath:indexPath];
                cell.songModel = tempMuzzik;
                cell.indexpath = indexPath;
                if ([tempMuzzik.muzzik_id isEqualToString:[MuzzikPlayer shareClass].playingMuzzik.muzzik_id] &&!glob.isPause && glob.isPlaying) {
                    cell.isPlaying = YES;
                }else{
                    cell.isPlaying = NO;
                }
                cell.userName.text = tempMuzzik.MuzzikUser.name;
                
                
                [cell.userImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",BaseURL_image,tempMuzzik.MuzzikUser.avatar,Image_Size_Small]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:Image_user_placeHolder] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    if (tableView == trendTableView) {
                        if (![[trendRefreshDic allKeys] containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]) {
                            [cell.userImage setAlpha:0];
                            [trendRefreshDic setObject:indexPath forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
                            [UIView animateWithDuration:0.5 animations:^{
                                [cell.userImage setAlpha:1];
                            }];
                        }
                    }else{
                        if (![[feedRefreshDic allKeys] containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]) {
                            [cell.userImage setAlpha:0];
                            [feedRefreshDic setObject:indexPath forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
                            [UIView animateWithDuration:0.5 animations:^{
                                [cell.userImage setAlpha:1];
                            }];
                        }
                    }
                    
                    
                }];

                if (tableView == trendTableView) {
                    cell.userImage.frame = CGRectMake(16, 20, 50, 50);
                    cell.repostImage.frame = CGRectMake(66, 21, 8, 8);
                    cell.repostUserName.frame = CGRectMake(80, 20, 150, 10);
                    
                    [cell.attentionButton setFrame:CGRectMake(SCREEN_WIDTH-61, 39, 45, 23)];
                    [cell.userName setFrame:CGRectMake(80, 41, SCREEN_WIDTH-160, 20)];
                    if ([[user.followDic allKeys] containsObject:tempMuzzik.MuzzikUser.user_id]) {
                        if (([[user.followDic objectForKey:tempMuzzik.MuzzikUser.user_id] integerValue] ^ 2) <2 || [user.uid isEqualToString:tempMuzzik.MuzzikUser.user_id]) {
                            cell.isFollow = YES;
                        }else{
                            cell.isFollow = NO;
                        }
                    }else{
                        cell.isFollow = NO;
                        
                    }
                    [cell.timeImage setHidden:YES];
                    [cell.timeStamp setHidden:YES];
                }else{
                    cell.userImage.frame = CGRectMake(16, 16, 50, 50);
                    cell.repostImage.frame = CGRectMake(66, 17, 8, 8);
                    cell.repostUserName.frame = CGRectMake(80, 16, 150, 10);
                    
                    [cell.attentionButton setFrame:CGRectMake(SCREEN_WIDTH-61, 26, 45, 23)];
                    [cell.userName setFrame:CGRectMake(80, 27, SCREEN_WIDTH-160, 20)];
                    cell.timeStamp.text = [MuzzikItem transtromTime:tempMuzzik.date];
                    [cell.timeStamp sizeToFit];
                    [cell.timeImage setFrame:CGRectMake(CGRectGetMaxX(cell.timeStamp.frame)+3, cell.timeImage.frame.origin.y, cell.timeImage.frame.size.width, cell.timeImage.frame.size.height)];
                    [cell.timeImage setHidden:NO];
                    [cell.timeStamp setHidden:NO];
                }
                cell.userName.text = tempMuzzik.MuzzikUser.name;
                if (tempMuzzik.isprivate ) {
                    [cell.privateImage setHidden:NO];
                    [cell.userName sizeToFit];
                    [cell.privateImage setFrame:CGRectMake(cell.userName.frame.origin.x+cell.userName.frame.size.width+2, cell.userName.frame.origin.y, 20, 20)];
                }else{
                    [cell.privateImage setHidden:YES];
                    [cell.userName setFrame:CGRectMake(80, cell.userName.frame.origin.y, SCREEN_WIDTH-160, 20)];
                }
                cell.userName.text = tempMuzzik.MuzzikUser.name;
                [cell.repostImage setHidden:NO];
                cell.repostUserName.text = tempMuzzik.reposter.name;
                cell.muzzikMessage.text = tempMuzzik.message;
                [cell.muzzikMessage addClickMessagewithTopics:tempMuzzik.topics];
                [cell.muzzikMessage addClickMessageForAt];
                cell.isMoved = tempMuzzik.ismoved;
                cell.isReposted = tempMuzzik.isReposted;
                cell.index = indexPath.row;
                cell.muzzikMessage.delegate = self;
                
                CGFloat textHeight = [MuzzikItem heightForLabel:cell.muzzikMessage WithText:cell.muzzikMessage.text];
                if (textHeight>limitHeight) {
                    [cell.muzzikMessage setFrame:CGRectMake((int)floor(cell.muzzikMessage.frame.origin.x), (int)floor(cell.muzzikMessage.frame.origin.y), cell.muzzikMessage.frame.size.width, limitHeight)];
                }else{
                    [cell.muzzikMessage setFrame:CGRectMake((int)floor(cell.muzzikMessage.frame.origin.x), (int)floor(cell.muzzikMessage.frame.origin.y), cell.muzzikMessage.frame.size.width, textHeight)];
                }
                [cell.musicPlayView setFrame:CGRectMake(0, (int)floor(cell.muzzikMessage.frame.origin.y+8+cell.muzzikMessage.bounds.size.height), SCREEN_WIDTH, cell.musicPlayView.frame.size.height)];
                cell.musicArtist.text =tempMuzzik.music.artist;
                cell.musicName.text = tempMuzzik.music.name;
                
                
                [cell colorViewWithColorString:[NSString stringWithFormat:@"%@",tempMuzzik.color]];
                cell.muzzik_id = tempMuzzik.muzzik_id;
                cell.delegate=self;
                if ([tempMuzzik.moveds integerValue]>0) {
                    [cell.moves setTitle:[NSString stringWithFormat:@"喜欢数%@",tempMuzzik.moveds] forState:UIControlStateNormal];
                }else{
                    [cell.moves setTitle:@"喜欢数" forState:UIControlStateNormal];
                }
                if ([tempMuzzik.reposts integerValue]>0) {
                    [cell.reposts setTitle:[NSString stringWithFormat:@"转发数%@",tempMuzzik.reposts] forState:UIControlStateNormal];
                }
                else{
                    [cell.reposts setTitle:@"转发数" forState:UIControlStateNormal];
                }
                if ([tempMuzzik.comments integerValue]>0) {
                    [cell.comments setTitle:[NSString stringWithFormat:@"评论数%@",tempMuzzik.comments ] forState:UIControlStateNormal];
                }
                else{
                    [cell.comments setTitle:@"评论数" forState:UIControlStateNormal];
                }
                if ([tempMuzzik.shares integerValue]>0) {
                    [cell.shares setTitle:[NSString stringWithFormat:@"分享数%@",tempMuzzik.shares] forState:UIControlStateNormal];
                }
                else{
                    [cell.shares setTitle:@"分享数" forState:UIControlStateNormal];
                }
                return  cell;
            }
            else if([tempMuzzik.type isEqualToString:@"normal"]){
                NormalCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NormalCell" forIndexPath:indexPath];
                cell.songModel = tempMuzzik;
                cell.indexpath = indexPath;
                if ([tempMuzzik.muzzik_id isEqualToString:[MuzzikPlayer shareClass].playingMuzzik.muzzik_id] &&!glob.isPause && glob.isPlaying) {
                    cell.isPlaying = YES;
                }else{
                    cell.isPlaying = NO;
                }
                [cell.userImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",BaseURL_image,tempMuzzik.MuzzikUser.avatar,Image_Size_Small]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:Image_user_placeHolder] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    if (tableView == trendTableView) {
                        if (![[trendRefreshDic allKeys] containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]) {
                            [cell.userImage setAlpha:0];
                            [trendRefreshDic setObject:indexPath forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
                            [UIView animateWithDuration:0.5 animations:^{
                                [cell.userImage setAlpha:1];
                            }];
                        }
                    }else{
                        if (![[feedRefreshDic allKeys] containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]) {
                            [cell.userImage setAlpha:0];
                            [feedRefreshDic setObject:indexPath forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
                            [UIView animateWithDuration:0.5 animations:^{
                                [cell.userImage setAlpha:1];
                            }];
                        }
                    }
                    
                    
                }];
                
                if (tableView == trendTableView) {
                    cell.userImage.frame = CGRectMake(16, 20, 50, 50);
                    cell.repostImage.frame = CGRectMake(66, 21, 8, 8);
                    cell.repostUserName.frame = CGRectMake(80, 20, 150, 10);
                    
                    [cell.attentionButton setFrame:CGRectMake(SCREEN_WIDTH-61, 39, 45, 23)];
                    [cell.userName setFrame:CGRectMake(80, 41, SCREEN_WIDTH-160, 20)];
                    if ([[user.followDic allKeys] containsObject:tempMuzzik.MuzzikUser.user_id]) {
                        if (([[user.followDic objectForKey:tempMuzzik.MuzzikUser.user_id] integerValue] ^ 2) <2 || [user.uid isEqualToString:tempMuzzik.MuzzikUser.user_id]) {
                            cell.isFollow = YES;
                        }else{
                            cell.isFollow = NO;
                        }
                    }else{
                        cell.isFollow = NO;
                        
                    }
                    [cell.timeImage setHidden:YES];
                    [cell.timeStamp setHidden:YES];
                }else{
                    cell.userImage.frame = CGRectMake(16, 16, 50, 50);
                    cell.repostImage.frame = CGRectMake(66, 17, 8, 8);
                    cell.repostUserName.frame = CGRectMake(80, 16, 150, 10);
                    
                    [cell.attentionButton setFrame:CGRectMake(SCREEN_WIDTH-61, 26, 45, 23)];
                    [cell.userName setFrame:CGRectMake(80, 27, SCREEN_WIDTH-160, 20)];
                    cell.timeStamp.text = [MuzzikItem transtromTime:tempMuzzik.date];
                    [cell.timeStamp sizeToFit];
                    [cell.timeImage setFrame:CGRectMake(CGRectGetMaxX(cell.timeStamp.frame)+3, cell.timeImage.frame.origin.y, cell.timeImage.frame.size.width, cell.timeImage.frame.size.height)];
                    [cell.timeImage setHidden:NO];
                    [cell.timeStamp setHidden:NO];
                }
                cell.userName.text = tempMuzzik.MuzzikUser.name;
                if (tempMuzzik.isprivate ) {
                    [cell.privateImage setHidden:NO];
                    [cell.userName sizeToFit];
                    [cell.privateImage setFrame:CGRectMake(cell.userName.frame.origin.x+cell.userName.frame.size.width+2, cell.userName.frame.origin.y, 20, 20)];
                }else{
                    [cell.privateImage setHidden:YES];
                    [cell.userName setFrame:CGRectMake(80, cell.userName.frame.origin.y, SCREEN_WIDTH-160, 20)];
                }
                cell.repostUserName.text = @"";
                [cell.repostImage setHidden:YES];
                cell.muzzikMessage.text = tempMuzzik.message;
                [cell.muzzikMessage addClickMessagewithTopics:tempMuzzik.topics];
                [cell.muzzikMessage addClickMessageForAt];
                cell.isMoved = tempMuzzik.ismoved;
                cell.isReposted = tempMuzzik.isReposted;
                cell.index = indexPath.row;
                cell.muzzikMessage.delegate = self;
                CGFloat textHeight = [MuzzikItem heightForLabel:cell.muzzikMessage WithText:cell.muzzikMessage.text];
                if (textHeight>limitHeight) {
                    [cell.muzzikMessage setFrame:CGRectMake((int)floor(cell.muzzikMessage.frame.origin.x), (int)floor(cell.muzzikMessage.frame.origin.y), cell.muzzikMessage.frame.size.width, limitHeight)];
                }else{
                    [cell.muzzikMessage setFrame:CGRectMake((int)floor(cell.muzzikMessage.frame.origin.x), (int)floor(cell.muzzikMessage.frame.origin.y), cell.muzzikMessage.frame.size.width, textHeight)];
                }
                [cell.musicPlayView setFrame:CGRectMake(0,(int) floor(cell.muzzikMessage.frame.origin.y+8+cell.muzzikMessage.bounds.size.height), SCREEN_WIDTH, cell.musicPlayView.frame.size.height)];
                cell.musicArtist.text =tempMuzzik.music.artist;
                cell.musicName.text = tempMuzzik.music.name;
                
                [cell colorViewWithColorString:[NSString stringWithFormat:@"%@",tempMuzzik.color]];
                cell.muzzik_id = tempMuzzik.muzzik_id;
                cell.delegate=self;
                if ([tempMuzzik.moveds integerValue]>0) {
                    [cell.moves setTitle:[NSString stringWithFormat:@"喜欢数%@",tempMuzzik.moveds] forState:UIControlStateNormal];
                }else{
                    [cell.moves setTitle:@"喜欢数" forState:UIControlStateNormal];
                }
                if ([tempMuzzik.reposts integerValue]>0) {
                    [cell.reposts setTitle:[NSString stringWithFormat:@"转发数%@",tempMuzzik.reposts] forState:UIControlStateNormal];
                }
                else{
                    [cell.reposts setTitle:@"转发数" forState:UIControlStateNormal];
                }
                if ([tempMuzzik.comments integerValue]>0) {
                    [cell.comments setTitle:[NSString stringWithFormat:@"评论数%@",tempMuzzik.comments ] forState:UIControlStateNormal];
                }
                else{
                    [cell.comments setTitle:@"评论数" forState:UIControlStateNormal];
                }
                if ([tempMuzzik.shares integerValue]>0) {
                    [cell.shares setTitle:[NSString stringWithFormat:@"分享数%@",tempMuzzik.shares] forState:UIControlStateNormal];
                }
                else{
                    [cell.shares setTitle:@"分享数" forState:UIControlStateNormal];
                }
                return  cell;
            }
            else{
                MuzzikNoCardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MuzzikNoCardCell" forIndexPath:indexPath];
                cell.songModel = tempMuzzik;
                if ([tempMuzzik.muzzik_id isEqualToString:[MuzzikPlayer shareClass].playingMuzzik.muzzik_id] &&!glob.isPause && glob.isPlaying) {
                    cell.isPlaying = YES;
                }else{
                    cell.isPlaying = NO;
                }
                cell.delegate = self;
                cell.cardTitle.text = tempMuzzik.title;
                cell.userName.text = tempMuzzik.MuzzikUser.name;
                cell.timeStamp.text = [MuzzikItem transtromTime:tempMuzzik.date];
                [cell.userImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",BaseURL_image,tempMuzzik.MuzzikUser.avatar,Image_Size_Small]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:Image_user_placeHolder] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    if (tableView == trendTableView) {
                        if (![[trendRefreshDic allKeys] containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]) {
                            [cell.userImage setAlpha:0];
                            [trendRefreshDic setObject:indexPath forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
                            [UIView animateWithDuration:0.5 animations:^{
                                [cell.userImage setAlpha:1];
                            }];
                        }
                    }else{
                        if (![[feedRefreshDic allKeys] containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]) {
                            [cell.userImage setAlpha:0];
                            [feedRefreshDic setObject:indexPath forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
                            [UIView animateWithDuration:0.5 animations:^{
                                [cell.userImage setAlpha:1];
                            }];
                        }
                    }
                    
                    
                }];
                cell.muzzikMessage.delegate = self;
                [cell colorViewWithColorString:[NSString stringWithFormat:@"%@",tempMuzzik.color]];
                cell.index = indexPath.row;
                cell.isMoved = tempMuzzik.ismoved;
                cell.muzzikMessage.text = tempMuzzik.message;
                [cell.muzzikMessage addClickMessagewithTopics:tempMuzzik.topics];
                [cell.muzzikMessage addClickMessageForAt];
                CGFloat textHeight = [MuzzikItem heightForLabel:cell.muzzikMessage WithText:cell.muzzikMessage.text];
                if (textHeight>limitHeight) {
                    [cell.muzzikMessage setFrame:CGRectMake((int)floor(cell.muzzikMessage.frame.origin.x), (int)floor(cell.muzzikMessage.frame.origin.y), cell.muzzikMessage.frame.size.width, limitHeight)];
                }else{
                    [cell.muzzikMessage setFrame:CGRectMake((int)floor(cell.muzzikMessage.frame.origin.x), (int)floor(cell.muzzikMessage.frame.origin.y), cell.muzzikMessage.frame.size.width, textHeight)];
                }
                [cell.musicPlayView setFrame:CGRectMake(0, (int)floor(cell.muzzikMessage.frame.origin.y+cell.muzzikMessage.frame.size.height+12),cell.musicPlayView.frame.size.width, (int)floor(cell.musicPlayView.frame.size.height))];
                [cell.cardView setFrame:CGRectMake(16, 20, SCREEN_WIDTH-32, (int)floor(cell.muzzikMessage.frame.origin.y+cell.muzzikMessage.frame.size.height+80))];
                cell.musicArtist.text =tempMuzzik.music.artist;
                cell.musicName.text = tempMuzzik.music.name;
                return cell;
                
            }
        }
        else{
            if ([tempMuzzik.type isEqualToString:@"repost"] ){
                NormalNoCardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NormalNoCardCell" forIndexPath:indexPath];
                cell.songModel = tempMuzzik;
                cell.indexpath = indexPath;
                if ([tempMuzzik.muzzik_id isEqualToString:[MuzzikPlayer shareClass].playingMuzzik.muzzik_id] &&!glob.isPause && glob.isPlaying) {
                    cell.isPlaying = YES;
                }else{
                    cell.isPlaying = NO;
                }
                if (tableView == trendTableView) {
                    cell.userImage.frame = CGRectMake(16, 20, 50, 50);
                    cell.repostImage.frame = CGRectMake(66, 21, 8, 8);
                    cell.repostUserName.frame = CGRectMake(80, 20, 150, 10);
                    
                    [cell.attentionButton setFrame:CGRectMake(SCREEN_WIDTH-61, 39, 45, 23)];
                    [cell.userName setFrame:CGRectMake(80, 41, SCREEN_WIDTH-160, 20)];
                    if ([[user.followDic allKeys] containsObject:tempMuzzik.MuzzikUser.user_id]) {
                        if (([[user.followDic objectForKey:tempMuzzik.MuzzikUser.user_id] integerValue] ^ 2) <2 || [user.uid isEqualToString:tempMuzzik.MuzzikUser.user_id]) {
                            cell.isFollow = YES;
                        }else{
                            cell.isFollow = NO;
                        }
                    }else{
                        cell.isFollow = NO;
                        
                    }
                    [cell.timeImage setHidden:YES];
                    [cell.timeStamp setHidden:YES];
                }else{
                    cell.userImage.frame = CGRectMake(16, 16, 50, 50);
                    cell.repostImage.frame = CGRectMake(66, 17, 8, 8);
                    cell.repostUserName.frame = CGRectMake(80, 16, 150, 10);
                    
                    [cell.attentionButton setFrame:CGRectMake(SCREEN_WIDTH-61, 26, 45, 23)];
                    [cell.userName setFrame:CGRectMake(80, 27, SCREEN_WIDTH-160, 20)];
                    cell.timeStamp.text = [MuzzikItem transtromTime:tempMuzzik.date];
                    [cell.timeStamp sizeToFit];
                    [cell.timeImage setFrame:CGRectMake(CGRectGetMaxX(cell.timeStamp.frame)+3, cell.timeImage.frame.origin.y, cell.timeImage.frame.size.width, cell.timeImage.frame.size.height)];
                    [cell.timeImage setHidden:NO];
                    [cell.timeStamp setHidden:NO];
                }
                cell.userName.text = tempMuzzik.MuzzikUser.name;
                if (tempMuzzik.isprivate ) {
                    [cell.privateImage setHidden:NO];
                    [cell.userName sizeToFit];
                    [cell.privateImage setFrame:CGRectMake(cell.userName.frame.origin.x+cell.userName.frame.size.width+2, cell.userName.frame.origin.y, 20, 20)];
                }else{
                    [cell.privateImage setHidden:YES];
                    [cell.userName setFrame:CGRectMake(80, cell.userName.frame.origin.y, SCREEN_WIDTH-160, 20)];
                }
                [cell.userImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",BaseURL_image,tempMuzzik.MuzzikUser.avatar,Image_Size_Small]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:Image_user_placeHolder] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    if (tableView == trendTableView) {
                        if (![[trendRefreshDic allKeys] containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]) {
                            [cell.userImage setAlpha:0];
                            [trendRefreshDic setObject:indexPath forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
                            [UIView animateWithDuration:0.5 animations:^{
                                [cell.userImage setAlpha:1];
                            }];
                        }
                    }else{
                        if (![[feedRefreshDic allKeys] containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]) {
                            [cell.userImage setAlpha:0];
                            [feedRefreshDic setObject:indexPath forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
                            [UIView animateWithDuration:0.5 animations:^{
                                [cell.userImage setAlpha:1];
                            }];
                        }
                    }
                    
                    
                }];
                
                [cell.poImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",BaseURL_image,tempMuzzik.image,Image_Size_Big]] placeholderImage:[UIImage imageNamed:Image_placeholdImage] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    if (tableView == trendTableView) {
                        if (![[trendReFreshPoImageDic allKeys] containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]) {
                            [cell.poImage setAlpha:0];
                            [trendReFreshPoImageDic setObject:indexPath forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
                            [UIView animateWithDuration:0.5 animations:^{
                                [cell.poImage setAlpha:1];
                            }];
                        }
                    }else{
                        if (![[feedReFreshPoImageDic allKeys] containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]) {
                            [cell.poImage setAlpha:0];
                            [feedReFreshPoImageDic setObject:indexPath forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
                            [UIView animateWithDuration:0.5 animations:^{
                                [cell.poImage setAlpha:1];
                            }];
                        }
                    }
                    
                    
                }];
                [cell.repostImage setHidden:NO];
                cell.repostUserName.text = tempMuzzik.reposter.name;
                cell.muzzikMessage.text = tempMuzzik.message;
                [cell.muzzikMessage addClickMessagewithTopics:tempMuzzik.topics];
                [cell.muzzikMessage addClickMessageForAt];
                cell.isMoved = tempMuzzik.ismoved;
                cell.isReposted = tempMuzzik.isReposted;
                cell.index = indexPath.row;
                cell.muzzikMessage.delegate = self;
                CGFloat textHeight = [MuzzikItem heightForLabel:cell.muzzikMessage WithText:cell.muzzikMessage.text];
                if (textHeight>limitHeight) {
                    [cell.muzzikMessage setFrame:CGRectMake((int)floor(cell.muzzikMessage.frame.origin.x), (int)floor(cell.muzzikMessage.frame.origin.y), cell.muzzikMessage.frame.size.width, limitHeight)];
                }else{
                    [cell.muzzikMessage setFrame:CGRectMake((int)floor(cell.muzzikMessage.frame.origin.x), (int)floor(cell.muzzikMessage.frame.origin.y), cell.muzzikMessage.frame.size.width, textHeight)];
                }
                [cell.musicPlayView setFrame:CGRectMake(0,(int)floor( cell.muzzikMessage.frame.origin.y+8+cell.muzzikMessage.bounds.size.height), SCREEN_WIDTH, (int)cell.musicPlayView.frame.size.height)];
                cell.musicArtist.text =tempMuzzik.music.artist;
                cell.musicName.text = tempMuzzik.music.name;

                
                [cell colorViewWithColorString:[NSString stringWithFormat:@"%@",tempMuzzik.color]];
                cell.muzzik_id = tempMuzzik.muzzik_id;
                cell.delegate=self;
                if ([tempMuzzik.moveds integerValue]>0) {
                    [cell.moves setTitle:[NSString stringWithFormat:@"喜欢数%@",tempMuzzik.moveds] forState:UIControlStateNormal];
                }else{
                    [cell.moves setTitle:@"喜欢数" forState:UIControlStateNormal];
                }
                if ([tempMuzzik.reposts integerValue]>0) {
                    [cell.reposts setTitle:[NSString stringWithFormat:@"转发数%@",tempMuzzik.reposts] forState:UIControlStateNormal];
                }
                else{
                    [cell.reposts setTitle:@"转发数" forState:UIControlStateNormal];
                }
                if ([tempMuzzik.comments integerValue]>0) {
                    [cell.comments setTitle:[NSString stringWithFormat:@"评论数%@",tempMuzzik.comments ] forState:UIControlStateNormal];
                }
                else{
                    [cell.comments setTitle:@"评论数" forState:UIControlStateNormal];
                }
                if ([tempMuzzik.shares integerValue]>0) {
                    [cell.shares setTitle:[NSString stringWithFormat:@"分享数%@",tempMuzzik.shares] forState:UIControlStateNormal];
                }
                else{
                    [cell.shares setTitle:@"分享数" forState:UIControlStateNormal];
                }
                return  cell;
            }
            else if([tempMuzzik.type isEqualToString:@"normal"]){
                NormalNoCardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NormalNoCardCell" forIndexPath:indexPath];
                cell.songModel = tempMuzzik;
                cell.indexpath = indexPath;
                if ([tempMuzzik.muzzik_id isEqualToString:[MuzzikPlayer shareClass].playingMuzzik.muzzik_id] &&!glob.isPause && glob.isPlaying) {
                    cell.isPlaying = YES;
                }else{
                    cell.isPlaying = NO;
                }
                if (tableView == trendTableView) {
                    cell.userImage.frame = CGRectMake(16, 20, 50, 50);
                    cell.repostImage.frame = CGRectMake(66, 21, 8, 8);
                    cell.repostUserName.frame = CGRectMake(80, 20, 150, 10);
                    
                    [cell.attentionButton setFrame:CGRectMake(SCREEN_WIDTH-61, 39, 45, 23)];
                    [cell.userName setFrame:CGRectMake(80, 41, SCREEN_WIDTH-160, 20)];
                    if ([[user.followDic allKeys] containsObject:tempMuzzik.MuzzikUser.user_id]) {
                        if (([[user.followDic objectForKey:tempMuzzik.MuzzikUser.user_id] integerValue] ^ 2) <2 || [user.uid isEqualToString:tempMuzzik.MuzzikUser.user_id]) {
                            cell.isFollow = YES;
                        }else{
                            cell.isFollow = NO;
                        }
                    }else{
                        cell.isFollow = NO;
                        
                    }
                    [cell.timeImage setHidden:YES];
                    [cell.timeStamp setHidden:YES];
                }else{
                    cell.userImage.frame = CGRectMake(16, 16, 50, 50);
                    cell.repostImage.frame = CGRectMake(66, 17, 8, 8);
                    cell.repostUserName.frame = CGRectMake(80, 16, 150, 10);
                    
                    [cell.attentionButton setFrame:CGRectMake(SCREEN_WIDTH-61, 26, 45, 23)];
                    [cell.userName setFrame:CGRectMake(80, 27, SCREEN_WIDTH-160, 20)];
                    cell.timeStamp.text = [MuzzikItem transtromTime:tempMuzzik.date];
                    [cell.timeStamp sizeToFit];
                    [cell.timeImage setFrame:CGRectMake(CGRectGetMaxX(cell.timeStamp.frame)+3, cell.timeImage.frame.origin.y, cell.timeImage.frame.size.width, cell.timeImage.frame.size.height)];
                    [cell.timeImage setHidden:NO];
                    [cell.timeStamp setHidden:NO];
                }
                cell.userName.text = tempMuzzik.MuzzikUser.name;
                if (tempMuzzik.isprivate ) {
                    [cell.privateImage setHidden:NO];
                    [cell.userName sizeToFit];
                    [cell.privateImage setFrame:CGRectMake(cell.userName.frame.origin.x+cell.userName.frame.size.width+2, cell.userName.frame.origin.y, 20, 20)];
                }else{
                    [cell.privateImage setHidden:YES];
                    [cell.userName setFrame:CGRectMake(80, cell.userName.frame.origin.y, SCREEN_WIDTH-160, 20)];
                }
                [cell.userImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",BaseURL_image,tempMuzzik.MuzzikUser.avatar,Image_Size_Small]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:Image_user_placeHolder] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    if (tableView == trendTableView) {
                        if (![[trendRefreshDic allKeys] containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]) {
                            [cell.userImage setAlpha:0];
                            [trendRefreshDic setObject:indexPath forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
                            [UIView animateWithDuration:0.5 animations:^{
                                [cell.userImage setAlpha:1];
                            }];
                        }
                    }else{
                        if (![[feedRefreshDic allKeys] containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]) {
                            [cell.userImage setAlpha:0];
                            [feedRefreshDic setObject:indexPath forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
                            [UIView animateWithDuration:0.5 animations:^{
                                [cell.userImage setAlpha:1];
                            }];
                        }
                    }
                    
                    
                }];
                
                [cell.poImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",BaseURL_image,tempMuzzik.image,Image_Size_Big]] placeholderImage:[UIImage imageNamed:Image_placeholdImage] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    if (tableView == trendTableView) {
                        if (![[trendReFreshPoImageDic allKeys] containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]) {
                            [cell.poImage setAlpha:0];
                            [trendReFreshPoImageDic setObject:indexPath forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
                            [UIView animateWithDuration:0.5 animations:^{
                                [cell.poImage setAlpha:1];
                            }];
                        }
                    }else{
                        if (![[feedReFreshPoImageDic allKeys] containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]) {
                            [cell.poImage setAlpha:0];
                            [feedReFreshPoImageDic setObject:indexPath forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
                            [UIView animateWithDuration:0.5 animations:^{
                                [cell.poImage setAlpha:1];
                            }];
                        }
                    }
                    
                    
                }];
                
               
                cell.repostUserName.text = @"";
                [cell.repostImage setHidden:YES];
                cell.muzzikMessage.text = tempMuzzik.message;
                [cell.muzzikMessage addClickMessagewithTopics:tempMuzzik.topics];
                [cell.muzzikMessage addClickMessageForAt];
                cell.isMoved = tempMuzzik.ismoved;
                cell.isReposted = tempMuzzik.isReposted;
                cell.index = indexPath.row;
                cell.muzzikMessage.delegate = self;
                CGFloat textHeight = [MuzzikItem heightForLabel:cell.muzzikMessage WithText:cell.muzzikMessage.text];
                if (textHeight>limitHeight) {
                    [cell.muzzikMessage setFrame:CGRectMake((int)floor(cell.muzzikMessage.frame.origin.x), (int)floor(cell.muzzikMessage.frame.origin.y), cell.muzzikMessage.frame.size.width, limitHeight)];
                }else{
                    [cell.muzzikMessage setFrame:CGRectMake((int)floor(cell.muzzikMessage.frame.origin.x), (int)floor(cell.muzzikMessage.frame.origin.y), cell.muzzikMessage.frame.size.width, textHeight)];
                }
                [cell.musicPlayView setFrame:CGRectMake(0, (int)floor(cell.muzzikMessage.frame.origin.y+8+cell.muzzikMessage.bounds.size.height), SCREEN_WIDTH, floor(cell.musicPlayView.frame.size.height))];
                cell.musicArtist.text =tempMuzzik.music.artist;
                cell.musicName.text = tempMuzzik.music.name;
                
                [cell colorViewWithColorString:[NSString stringWithFormat:@"%@",tempMuzzik.color]];
                cell.muzzik_id = tempMuzzik.muzzik_id;
                cell.delegate=self;
                if ([tempMuzzik.moveds integerValue]>0) {
                    [cell.moves setTitle:[NSString stringWithFormat:@"喜欢数%@",tempMuzzik.moveds] forState:UIControlStateNormal];
                }else{
                    [cell.moves setTitle:@"喜欢数" forState:UIControlStateNormal];
                }
                if ([tempMuzzik.reposts integerValue]>0) {
                    [cell.reposts setTitle:[NSString stringWithFormat:@"转发数%@",tempMuzzik.reposts] forState:UIControlStateNormal];
                }
                else{
                    [cell.reposts setTitle:@"转发数" forState:UIControlStateNormal];
                }
                if ([tempMuzzik.comments integerValue]>0) {
                    [cell.comments setTitle:[NSString stringWithFormat:@"评论数%@",tempMuzzik.comments ] forState:UIControlStateNormal];
                }
                else{
                    [cell.comments setTitle:@"评论数" forState:UIControlStateNormal];
                }
                if ([tempMuzzik.shares integerValue]>0) {
                    [cell.shares setTitle:[NSString stringWithFormat:@"分享数%@",tempMuzzik.shares] forState:UIControlStateNormal];
                }
                else{
                    [cell.shares setTitle:@"分享数" forState:UIControlStateNormal];
                }
                return  cell;
            }
            else {
                MuzzikCard *cell = [tableView dequeueReusableCellWithIdentifier:@"MuzzikCard" forIndexPath:indexPath];
                cell.songModel = tempMuzzik;
                if ([tempMuzzik.muzzik_id isEqualToString:[MuzzikPlayer shareClass].playingMuzzik.muzzik_id] &&!glob.isPause && glob.isPlaying) {
                    cell.isPlaying = YES;
                }else{
                    cell.isPlaying = NO;
                }
                cell.delegate = self;
                cell.cardTitle.text = tempMuzzik.title;
                cell.userName.text = tempMuzzik.MuzzikUser.name;
                cell.timeStamp.text = [MuzzikItem transtromTime:tempMuzzik.date];
                
                [cell.userImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",BaseURL_image,tempMuzzik.MuzzikUser.avatar,Image_Size_Small]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:Image_user_placeHolder] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    if (tableView == trendTableView) {
                        if (![[trendRefreshDic allKeys] containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]) {
                            [cell.userImage setAlpha:0];
                            [trendRefreshDic setObject:indexPath forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
                            [UIView animateWithDuration:0.5 animations:^{
                                [cell.userImage setAlpha:1];
                            }];
                        }
                    }else{
                        if (![[feedRefreshDic allKeys] containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]) {
                            [cell.userImage setAlpha:0];
                            [feedRefreshDic setObject:indexPath forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
                            [UIView animateWithDuration:0.5 animations:^{
                                [cell.userImage setAlpha:1];
                            }];
                        }
                    }
                    
                    
                }];
                
                [cell.muzzikCardImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",BaseURL_image,tempMuzzik.image,Image_Size_Big]] placeholderImage:[UIImage imageNamed:Image_placeholdImage] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    if (tableView == trendTableView) {
                        if (![[trendReFreshPoImageDic allKeys] containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]) {
                            [cell.muzzikCardImage setAlpha:0];
                            [trendReFreshPoImageDic setObject:indexPath forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
                            [UIView animateWithDuration:0.5 animations:^{
                                [cell.muzzikCardImage setAlpha:1];
                            }];
                        }
                    }else{
                        if (![[feedReFreshPoImageDic allKeys] containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]) {
                            [cell.muzzikCardImage setAlpha:0];
                            [feedReFreshPoImageDic setObject:indexPath forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
                            [UIView animateWithDuration:0.5 animations:^{
                                [cell.muzzikCardImage setAlpha:1];
                            }];
                        }
                    }
                    
                    
                }];
               
                cell.index = indexPath.row;
                cell.isMoved = tempMuzzik.ismoved;
                 [cell colorViewWithColorString:[NSString stringWithFormat:@"%@",tempMuzzik.color]];
                cell.muzzikMessage.text = tempMuzzik.message;
                [cell.muzzikMessage addClickMessagewithTopics:tempMuzzik.topics];
                [cell.muzzikMessage addClickMessageForAt];
                
                
                cell.muzzikMessage.delegate = self;
                cell.RepostID = tempMuzzik.repostID;
                CGFloat textHeight = [MuzzikItem heightForLabel:cell.muzzikMessage WithText:cell.muzzikMessage.text];
                if (textHeight>limitHeight) {
                    [cell.muzzikMessage setFrame:CGRectMake((int)floor(cell.muzzikMessage.frame.origin.x), (int)floor(cell.muzzikMessage.frame.origin.y), cell.muzzikMessage.frame.size.width, limitHeight)];
                }else{
                    [cell.muzzikMessage setFrame:CGRectMake((int)floor(cell.muzzikMessage.frame.origin.x), (int)floor(cell.muzzikMessage.frame.origin.y), cell.muzzikMessage.frame.size.width, textHeight)];
                }
                [cell.musicPlayView setFrame:CGRectMake(0, (int)(cell.muzzikMessage.frame.origin.y+cell.muzzikMessage.frame.size.height+12), SCREEN_WIDTH-16, cell.musicPlayView.frame.size.height)];
                [cell.cardView setFrame:CGRectMake(16, 20, SCREEN_WIDTH-32,(int) (cell.muzzikMessage.frame.origin.y+cell.muzzikMessage.frame.size.height+80))];
                cell.musicArtist.text =tempMuzzik.music.artist;
                cell.musicName.text = tempMuzzik.music.name;
                return cell;
            }
            
        }

    }
    else if ([tempMuzzik.type isEqualToString:@"musicCard"] ){
        MuzzikSongCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MuzzikSongCell" forIndexPath:indexPath];
        cell.cardTitle.text = tempMuzzik.title;
        cell.musicArtist.text = tempMuzzik.music.artist;
        cell.musicName.text = tempMuzzik.music.name;
        cell.songModel = tempMuzzik;
        cell.delegate = self;
        if ([tempMuzzik.muzzik_id isEqualToString:[MuzzikPlayer shareClass].playingMuzzik.muzzik_id] &&!glob.isPause && glob.isPlaying) {
            [cell.playButton setImage:[UIImage imageNamed:Image_stoporangeImage] forState:UIControlStateNormal];
        }else{
             [cell.playButton setImage:[UIImage imageNamed:Image_playgreyImage] forState:UIControlStateNormal];
        }
        return cell;
    }
    else if([tempMuzzik.type isEqualToString:@"topicCard"]){
        MuzzikTopic *cell = [tableView dequeueReusableCellWithIdentifier:@"MuzzikTopic" forIndexPath:indexPath];
        cell.cardTitle.text = tempMuzzik.title;
        cell.TopicLabel.text = [NSString stringWithFormat:@"#%@#",[tempMuzzik.topics[0] objectForKey:@"name"]];
        cell.songModel = tempMuzzik;
        cell.delegate = self;
        return cell;
    }
    else {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        return cell;
    }
    
    
}
-(void)newMuzzik:(muzzik *)localMzzik{
    userInfo *user = [userInfo shareClass];
    if ([user.token length]>0) {
        //new po
        user.poController = self;
        MessageStepViewController *msgVC = [[MessageStepViewController alloc] init];
        msgVC.isNewSelected = YES;
        [self.navigationController pushViewController:msgVC animated:YES];
        
    }
    else{
        LoginViewController *loginVC = [[LoginViewController alloc] init];
        [self.navigationController pushViewController:loginVC animated:YES];
    }
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
}
- (void)attributedLabel:(TTTAttributedLabel *)label
didSelectLinkWithTransitInformation:(NSDictionary *)components{
    NSLog(@"%@",components);
    if ([[components allKeys] containsObject:@"topic_id"]) {
        TopicDetail *topicDetail = [[TopicDetail alloc] init];
        topicDetail.topic_id = [components objectForKey:@"topic_id"];
        [self.navigationController pushViewController:topicDetail animated:YES];
        [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    }else if([[components allKeys] containsObject:@"at_name"]){
        
        userInfo *user = [userInfo shareClass];
        if ([[components objectForKey:@"at_name"] isEqualToString:user.name]) {
//            UserHomePage *home = [[UserHomePage alloc] init];
//            [self.navigationController pushViewController:home animated:YES];
//            [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
        }else{
            userDetailInfo *uInfo = [[userDetailInfo alloc] init];
            uInfo.uid = [[components objectForKey:@"at_name"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [self.navigationController pushViewController:uInfo animated:YES];
            [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
        }
    }
}
-(void)deleteMuzzik:(NSNotification *)notify{
    muzzik *localMzzik = notify.object;
    for (muzzik *tempMuzzik in self.feedMuzziks) {
        if ([tempMuzzik.muzzik_id isEqualToString:localMzzik.muzzik_id]) {
            [self.feedMuzziks removeObject:tempMuzzik];
            [feedTableView reloadData];
            break;
        }
    }
    for (muzzik *tempMuzzik in self.trendMuzziks) {
        if ([tempMuzzik.muzzik_id isEqualToString:localMzzik.muzzik_id]) {
            [self.trendMuzziks removeObject:tempMuzzik];
            [trendTableView reloadData];
            break;
        }
    }
    
    
}

-(void)moveMuzzik:(muzzik *)tempMuzzik{
    
    userInfo *user = [userInfo shareClass];
    if ([user.token length]>0) {
        tempMuzzik.ismoved = !tempMuzzik.ismoved;
        if (tempMuzzik.ismoved) {
            tempMuzzik.moveds = [NSString stringWithFormat:@"%d",[tempMuzzik.moveds intValue]+1 ];
        }else{
            tempMuzzik.moveds = [NSString stringWithFormat:@"%d",[tempMuzzik.moveds intValue]-1 ];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:String_MuzzikDataSource_update object:tempMuzzik];
        ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/muzzik/%@/moved",BaseURL,tempMuzzik.muzzik_id]]];
        [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:tempMuzzik.ismoved] forKey:@"ismoved"] Method:PostMethod auth:YES];
        __weak ASIHTTPRequest *weakrequest = requestForm;
        [requestForm setCompletionBlock :^{
            NSLog(@"%@",[weakrequest responseString]);
            if ([weakrequest responseStatusCode] == 200) {
                NSLog(@"%@",[weakrequest responseString]);
                // NSData *data = [weakrequest responseData];
              
                
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
        [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
        LoginViewController *loginVC = [[LoginViewController alloc] init];
        [self.navigationController pushViewController:loginVC animated:YES];
        
    }
    
    
}
-(void)repostActionWithMuzzik:(muzzik *)tempMuzzik{
    userInfo *user = [userInfo shareClass];
    if ([user.token length]>0) {
        self.repostMuzzik = tempMuzzik;
        if (!tempMuzzik.isReposted) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"确定转发这条Muzzik吗?" message:@"" delegate:self cancelButtonTitle:@"放弃" otherButtonTitles:nil];
            // optional - add more buttons:
            [alert addButtonWithTitle:@"确定"];
            [alert show];
            
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"确定取消转发这条Muzzik吗?" message:@"" delegate:self cancelButtonTitle:@"放弃" otherButtonTitles:nil];
            // optional - add more buttons:
            [alert addButtonWithTitle:@"确定"];
            [alert show];
        }
    }else{
        [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
        [userInfo checkLoginWithVC:self];
    }
   
    
    
}
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView == starAlert) {
        if (buttonIndex == 1) {
            NSDictionary *dic = [MuzzikItem getDictionaryFromLocalForKey:@"Muzzik_Check_Comment_Five_star"];
            [MuzzikItem addObjectToLocal:[NSDictionary dictionaryWithObjectsAndKeys:[dic objectForKey:@"times"],@"times",[dic objectForKey:@"date"],@"date",@"yes",@"hasClicked", nil] ForKey:@"Muzzik_Check_Comment_Five_star"];
            NSString *str = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@?mt=8",APP_ID ];
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
        }                                     
    }
    else if (buttonIndex == 1) {
        // do stuff
        if (!self.repostMuzzik.isReposted) {
            
            self.repostMuzzik.isReposted = YES;
            self.repostMuzzik.reposts = [NSString stringWithFormat:@"%d",[self.repostMuzzik.reposts intValue]+1];
            [[NSNotificationCenter defaultCenter] postNotificationName:String_MuzzikDataSource_update object:self.repostMuzzik];
            ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/muzzik",BaseURL]]];
            NSDictionary *dictionary = [NSDictionary dictionaryWithObject:self.repostMuzzik.muzzik_id forKey:@"repost"];
            [requestForm addBodyDataSourceWithJsonByDic:dictionary Method:PutMethod auth:YES];
            __weak ASIHTTPRequest *weakrequest = requestForm;
            [requestForm setCompletionBlock :^{
                NSLog(@"%@",[weakrequest requestHeaders]);
                NSLog(@"%@",[weakrequest responseString]);
                NSLog(@"%d",[weakrequest responseStatusCode]);
                if ([weakrequest responseStatusCode] == 200) {
                    [MuzzikItem showNotifyOnView:self.view text:@"转发成功"];
                }
                
                else if([weakrequest responseStatusCode] == 401){
                    //[SVProgressHUD showErrorWithStatus:[dic objectForKey:@"message"]];
                }else if ([weakrequest responseStatusCode] == 400){
                }
            }];
            [requestForm setFailedBlock:^{
                NSLog(@"%@",[weakrequest error]);
            }];
            [requestForm startAsynchronous];
        }else{
            
            
            self.repostMuzzik.isReposted = NO;
            self.repostMuzzik.reposts = [NSString stringWithFormat:@"%d",[self.repostMuzzik.reposts integerValue]-1];
            [[NSNotificationCenter defaultCenter] postNotificationName:String_MuzzikDataSource_update object:self.repostMuzzik];
            
            ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/muzzik/%@/repost",BaseURL,self.repostMuzzik.muzzik_id]]];
            [requestForm addBodyDataSourceWithJsonByDic:nil Method:DeleteMethod auth:YES];
            __weak ASIHTTPRequest *weakrequest = requestForm;
            [requestForm setCompletionBlock :^{
                NSLog(@"%@",[weakrequest requestHeaders]);
                NSLog(@"%@",[weakrequest responseString]);
                NSLog(@"%d",[weakrequest responseStatusCode]);
                if ([weakrequest responseStatusCode] == 200) {
                    [MuzzikItem showNotifyOnView:self.view text:@"取消转发"];
                }
                
                else if([weakrequest responseStatusCode] == 401){
                    //[SVProgressHUD showErrorWithStatus:[dic objectForKey:@"message"]];
                }else if ([weakrequest responseStatusCode] == 400){
                    
                }
            }];
            [requestForm setFailedBlock:^{
                NSLog(@"%@",[weakrequest error]);
            }];
            [requestForm startAsynchronous];
        }
        
        
    }else{
        
    }
    
}

-(void)feedReloadMuzzikSource{
    userInfo *user = [userInfo shareClass];
    if ([user.uid length]>0) {
        dispatch_async(_serialQueue, ^{
            if ([MuzzikItem getDataFromLocalKey: [NSString stringWithFormat:@"User_Feed%@",user.uid]]) {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[MuzzikItem getDataFromLocalKey: [NSString stringWithFormat:@"User_Feed%@",user.uid]] options:NSJSONReadingMutableContainers error:nil];
                
                if (dic) {
                    muzzik *muzzikToy = [muzzik new];
                    NSArray *array = [muzzikToy makeMuzziksByMuzzikArray:[dic objectForKey:@"muzziks"]];
                    for (muzzik *tempmuzzik in array) {
                        BOOL isContained = NO;
                        for (muzzik *arrayMuzzik in self.feedMuzziks) {
                            if ([arrayMuzzik.muzzik_id isEqualToString:tempmuzzik.muzzik_id]) {
                                isContained = YES;
                                break;
                            }
                            
                        }
                        if (!isContained) {
                            [self.feedMuzziks addObject:tempmuzzik];
                        }
                        isContained = NO;
                    }
                    feedLastId = [dic objectForKey:@"tail"];
                    [feedTableView reloadData];
                    
                }
            }
        });
        
    }
    dispatch_async(_serialQueue, ^{
        NSDictionary *requestDic = [NSDictionary dictionaryWithObject:@"20" forKey:Parameter_Limit];
        
        ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/muzzik/feeds",BaseURL]]];
        
        [request addBodyDataSourceWithJsonByDic:requestDic Method:GetMethod auth:YES];
        __weak ASIHTTPRequest *weakrequest = request;
        [request setCompletionBlock :^{
            //    NSLog(@"%@",weakrequest.originalURL);
            [self.feedMuzziks removeAllObjects];
            NSLog(@"%@",[weakrequest responseString]);
            NSData *data = [weakrequest responseData];
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            if (dic) {
                [MuzzikItem addObjectToLocal:data ForKey:[NSString stringWithFormat:@"User_Feed%@",user.uid]];
                
                muzzik *muzzikToy = [muzzik new];
                NSArray *array = [muzzikToy makeMuzziksByMuzzikArray:[dic objectForKey:@"muzziks"]];
                for (muzzik *tempmuzzik in array) {
                    BOOL isContained = NO;
                    for (muzzik *arrayMuzzik in self.feedMuzziks) {
                        if ([arrayMuzzik.muzzik_id isEqualToString:tempmuzzik.muzzik_id]) {
                            isContained = YES;
                            break;
                        }
                        
                    }
                    if (!isContained) {
                        [self.feedMuzziks addObject:tempmuzzik];
                    }
                    isContained = NO;
                }
                [MuzzikItem SetUserInfoWithMuzziks:self.feedMuzziks title:Constant_userInfo_follow description:[NSString stringWithFormat:@"关注列表"]];
                ASIHTTPRequest *requestCard = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/muzzik/card",BaseURL]]];
                [requestCard addBodyDataSourceWithJsonByDic:nil Method:GetMethod auth:YES];
                __weak ASIHTTPRequest *weakrequestCard = requestCard;
                [requestCard setCompletionBlock :^{
                    NSMutableArray *suggestCardArray = [[MuzzikItem getArrayFromLocalForKey:@"Muzzik_suggest_Day_ClickArray"] mutableCopy];
                    if (!suggestCardArray) {
                        suggestCardArray = [NSMutableArray array];
                    }
                    NSData *data = [weakrequestCard responseData];
                    NSDictionary *cardDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                    NSArray *requestArray ;
                    if (cardDic && [[cardDic allKeys] containsObject:@"muzziks"]) {
                        requestArray = [cardDic objectForKey:@"muzziks"];
                        for (NSDictionary *tempDic in requestArray) {
                            
                            if (![suggestCardArray containsObject:[tempDic objectForKey:@"_id"]]) {
                                for (muzzik *checkMuzzik in self.feedMuzziks) {
                                    if ([[tempDic objectForKey:@"_id"] isEqualToString:checkMuzzik.muzzik_id]) {
                                        if (self.feedMuzziks.count >1) {
                                            
                                            [self.feedMuzziks removeObject:checkMuzzik];
                                        }
                                        break;
                                    }
                                    
                                }
                                [self.feedMuzziks insertObject:[[muzzik new] makeMuzziksByMuzzikArray:[NSMutableArray arrayWithObjects:tempDic, nil]][0] atIndex:1];
                                break;
                            }
                            
                            
                        }
                        [self requestForVip];
                        [MuzzikItem SetUserInfoWithMuzziks:self.feedMuzziks title:Constant_userInfo_follow description:[NSString stringWithFormat:@"关注列表"]];
                        
                        feedLastId = [dic objectForKey:@"tail"];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [feedTableView reloadData];
                            [feedTableView headerEndRefreshing];
                        });
                        
                    }
                    
                }];
                [requestCard setFailedBlock:^{
                    
                    [feedTableView headerEndRefreshing];
                }];
                [requestCard startAsynchronous];
                
                
            }
        }];
        [request setFailedBlock:^{
            
            if (![[weakrequest responseString] length]>0) {
                [self networkErrorShow];
            }
        }];
        [request startAsynchronous];
    });
    
}
-(void) requestForVip{
    NSString *vipUserId = [MuzzikItem getStringForKey:@"Muzzik_Vip_User_Daily"];
    if (vipUserId == nil) {
        ASIHTTPRequest *requestVip = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"http://117.121.26.174:8000/api/activity/top"]]];
        
        [requestVip addBodyDataSourceWithJsonByDic:nil Method:GetMethod auth:NO];
        __weak ASIHTTPRequest *weakrequestVip = requestVip;
        [requestVip setCompletionBlock :^{
            NSData *data = [weakrequestVip responseData];
            NSDictionary *VipDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            if (VipDic && [[VipDic allKeys] containsObject:@"_id"] && [[VipDic objectForKey:@"_id"] length] > 0) {
                NSString *VipMuzzikId = [MuzzikItem getStringForKey:@"Muzzik_Daily_Vip_MuzzikId"];
                if ([VipMuzzikId length] == 0) {
                    [self requestMuzzikWithId:[VipDic objectForKey:@"_id"]];
                }else{
                    if (![VipMuzzikId isEqualToString:[VipDic objectForKey:@"_id"]]) {
                         [self requestMuzzikWithId:[VipDic objectForKey:@"_id"]];
                    }
                }
                
                
               
            }
        }];
        [requestVip setFailedBlock:^{
            NSLog(@"%@",[weakrequestVip error]);
        }];
        [requestVip startAsynchronous];
    }
}
-(void)requestMuzzikWithId:(NSString *)muzzikId{
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/muzzik/%@",BaseURL,muzzikId]]];
    
    [request addBodyDataSourceWithJsonByDic:nil Method:GetMethod auth:NO];
    __weak ASIHTTPRequest *weakrequestVip = request;
    [request setCompletionBlock :^{
        NSData *data = [weakrequestVip responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (dic) {
            muzzik *tempMuzzik = [[[muzzik new] makeMuzziksByMuzzikArray:[NSMutableArray arrayWithObject:dic]] lastObject];
            if (self.feedMuzziks && tempMuzzik) {
                for (muzzik *arrayMuzzik in self.feedMuzziks) {
                    if ([arrayMuzzik.muzzik_id isEqualToString:tempMuzzik.muzzik_id]) {
                        [self.feedMuzziks removeObject:arrayMuzzik];
                        break;
                    }
                }
                
                [self.feedMuzziks insertObject:tempMuzzik atIndex:0];
                [MuzzikItem addObjectToLocal:muzzikId ForKey:@"Muzzik_Daily_Vip_MuzzikId"];
                [feedTableView reloadData];
                
            }
        }
        
    }];
    [request setFailedBlock:^{
        NSLog(@"%@",[weakrequestVip error]);
    }];
    [request startAsynchronous];
}
-(void)trendReloadMuzzikSource{
    userInfo *user = [userInfo shareClass];
    
    if ([user.token length]>0) {
        dispatch_async(_serialQueue, ^{
            if ([MuzzikItem getDataFromLocalKey: Constant_Data_Square] ) {
                NSData *data = [MuzzikItem getDataFromLocalKey: Constant_Data_Square];
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                if (dic) {
                    trendLastId = [dic objectForKey:@"tail"];
                    [self.trendMuzziks removeAllObjects];
                    muzzik *muzzikToy = [muzzik new];
                    NSArray *array = [muzzikToy makeMuzziksNeedsSetUserByMuzzikArray:[dic objectForKey:@"muzziks"]];
                    for (muzzik *tempmuzzik in array) {
                        BOOL isContained = NO;
                        for (muzzik *arrayMuzzik in self.trendMuzziks) {
                            if ([arrayMuzzik.muzzik_id isEqualToString:tempmuzzik.muzzik_id]) {
                                isContained = YES;
                                break;
                            }
                            
                        }
                        if (!isContained) {
                            [self.trendMuzziks addObject:tempmuzzik];
                        }
                        isContained = NO;
                    }
                    [trendTableView reloadData];
                }
            }
        });
        
        dispatch_async(_serialQueue, ^{
            ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :@"http://117.121.26.174:8000/api/muzzik/trending"]];
            [request addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:@"20" forKey:Parameter_Limit] Method:GetMethod auth:YES];
            __weak ASIHTTPRequest *weakrequest = request;
            [request setCompletionBlock :^{
                //    NSLog(@"%@",weakrequest.originalURL);
                [self.trendMuzziks removeAllObjects];
                NSData *data = [weakrequest responseData];
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                if (dic) {
                    
                    muzzik *muzzikToy = [muzzik new];
                    NSArray *array = [muzzikToy makeMuzziksNeedsSetUserByMuzzikArray:[dic objectForKey:@"muzziks"]];
                    
                    for (muzzik *tempmuzzik in array) {
                        BOOL isContained = NO;
                        for (muzzik *arrayMuzzik in self.trendMuzziks) {
                            if ([arrayMuzzik.muzzik_id isEqualToString:tempmuzzik.muzzik_id]) {
                                isContained = YES;
                                break;
                            }
                            
                        }
                        if (!isContained) {
                            [self.trendMuzziks addObject:tempmuzzik];
                        }
                        isContained = NO;
                    }
                    
                    [self getLocalPopMuzzikidFresh:NO];
                    
                }
            }];
            [request setFailedBlock:^{
                NSLog(@"%@,%@",[weakrequest error],[weakrequest responseString]);
                if (![[weakrequest responseString] length]>0) {
                    [self networkErrorShow];
                }
                
            }];
            [request startAsynchronous];
        });
        
    }else{
        dispatch_async(_serialQueue, ^{
            if ([MuzzikItem getDataFromLocalKey: @"Constant_Data_Square_NotLogin"] ) {
                NSData *data = [MuzzikItem getDataFromLocalKey: @"Constant_Data_Square_NotLogin"];
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                if (dic) {
                    trendLastId = [dic objectForKey:@"tail"];
                    muzzik *muzzikToy = [muzzik new];
                    NSArray *array = [muzzikToy makeMuzziksNeedsSetUserByMuzzikArray:[dic objectForKey:@"muzziks"]];
                    for (muzzik *tempmuzzik in array) {
                        BOOL isContained = NO;
                        for (muzzik *arrayMuzzik in self.trendMuzziks) {
                            if ([arrayMuzzik.muzzik_id isEqualToString:tempmuzzik.muzzik_id]) {
                                isContained = YES;
                                break;
                            }
                            
                        }
                        if (!isContained) {
                            [self.trendMuzziks addObject:tempmuzzik];
                        }
                        isContained = NO;
                    }
                }
            }
        });
        
        
        dispatch_async(_serialQueue, ^{
            ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :@"http://117.121.26.174:8000/api/muzzik/introduce"]];
            [request addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:@"20" forKey:Parameter_Limit] Method:GetMethod auth:YES];
            __weak ASIHTTPRequest *weakrequest = request;
            [request setCompletionBlock :^{
                //    NSLog(@"%@",weakrequest.originalURL);
                [self.trendMuzziks removeAllObjects];
                NSData *data = [weakrequest responseData];
                if (data) {
                    [MuzzikItem addObjectToLocal:data ForKey:@"Constant_Data_Square_NotLogin"];
                }
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                if (dic) {
                    
                    muzzik *muzzikToy = [muzzik new];
                    NSArray *array = [muzzikToy makeMuzziksNeedsSetUserByMuzzikArray:[dic objectForKey:@"muzziks"]];
                    for (muzzik *tempmuzzik in array) {
                        BOOL isContained = NO;
                        for (muzzik *arrayMuzzik in self.trendMuzziks) {
                            if ([arrayMuzzik.muzzik_id isEqualToString:tempmuzzik.muzzik_id]) {
                                isContained = YES;
                                break;
                            }
                            
                        }
                        if (!isContained) {
                            [self.trendMuzziks addObject:tempmuzzik];
                        }
                        isContained = NO;
                    }
                    ASIHTTPRequest *requestCard = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/muzzik/card",BaseURL]]];
                    [requestCard addBodyDataSourceWithJsonByDic:nil Method:GetMethod auth:YES];
                    __weak ASIHTTPRequest *weakrequestCard = requestCard;
                    [requestCard setCompletionBlock :^{
                        NSMutableArray *suggestCardArray = [[MuzzikItem getArrayFromLocalForKey:@"Muzzik_suggest_Day_ClickArray"] mutableCopy];
                        if (!suggestCardArray) {
                            suggestCardArray = [NSMutableArray array];
                        }
                        NSData *data = [weakrequestCard responseData];
                        NSDictionary *cardDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                        NSArray *requestArray ;
                        if (cardDic && [[cardDic allKeys] containsObject:@"muzziks"]) {
                            requestArray = [cardDic objectForKey:@"muzziks"];
                            for (NSDictionary *tempDic in requestArray) {
                                
                                if (![suggestCardArray containsObject:[tempDic objectForKey:@"_id"]]) {
                                    for (muzzik *checkMuzzik in self.trendMuzziks) {
                                        if ([[tempDic objectForKey:@"_id"] isEqualToString:checkMuzzik.muzzik_id]) {
                                            if (self.trendMuzziks.count >1) {
                                                
                                                [self.trendMuzziks removeObject:checkMuzzik];
                                            }
                                            break;
                                        }
                                        
                                    }
                                    if (self.trendMuzziks && [[muzzik new] makeMuzziksByMuzzikArray:[NSMutableArray arrayWithObjects:tempDic, nil]][0] && tempDic) {
                                        [self.trendMuzziks insertObject:[[muzzik new] makeMuzziksNeedsSetUserByMuzzikArray:[NSMutableArray arrayWithObjects:tempDic, nil]][0] atIndex:1];
                                    }
                                    
                                    break;
                                }
                                
                                
                            }
                            [MuzzikItem SetUserInfoWithMuzziks:self.trendMuzziks title:Constant_userInfo_square description:nil];
                            
                            trendLastId = [dic objectForKey:@"tail"];
                            [trendTableView reloadData];
                            [trendTableView headerEndRefreshing];
                            
                        }
                        
                    }];
                    [requestCard setFailedBlock:^{
                        [trendTableView reloadData];
                        
                    }];
                    [requestCard startAsynchronous];
                    
                    
                }
            }];
            [request setFailedBlock:^{
                NSLog(@"%@,%@",[weakrequest error],[weakrequest responseString]);
                if (![[weakrequest responseString] length]>0) {
                    [self networkErrorShow];
                }
                
            }];
            [request startAsynchronous];
        });
        
    }
    
    
}
-(void) upperRefreshRequestForCard{
    if ([self.trendMuzziks count]>0 && [muzzikArray count]>0) {
        NSArray *tempArray = [[muzzik new] makeMuzziksNeedsSetUserByMuzzikArray:muzzikArray];
        for (muzzik *tempMuzzik in tempArray) {
            [self.trendMuzziks insertObject:tempMuzzik atIndex:0];
        }
    }
    ASIHTTPRequest *requestCard = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/muzzik/card",BaseURL]]];
    [requestCard addBodyDataSourceWithJsonByDic:nil Method:GetMethod auth:YES];
    __weak ASIHTTPRequest *weakrequestCard = requestCard;
    [requestCard setCompletionBlock :^{
        NSMutableArray *suggestCardArray = [[MuzzikItem getArrayFromLocalForKey:@"Muzzik_suggest_Day_ClickArray"] mutableCopy];
        if (!suggestCardArray) {
            suggestCardArray = [NSMutableArray array];
        }
        NSData *data = [weakrequestCard responseData];
        NSDictionary *cardDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        NSArray *requestArray ;
        if (cardDic && [[cardDic allKeys] containsObject:@"muzziks"]) {
            requestArray = [cardDic objectForKey:@"muzziks"];
            for (NSDictionary *tempDic in requestArray) {
                
                if (![suggestCardArray containsObject:[tempDic objectForKey:@"_id"]]) {
                    for (muzzik *checkMuzzik in self.trendMuzziks) {
                        if ([[tempDic objectForKey:@"_id"] isEqualToString:checkMuzzik.muzzik_id]) {
                            if (self.trendMuzziks.count >1) {
                                
                                [self.trendMuzziks removeObject:checkMuzzik];
                            }
                            break;
                        }
                        
                    }
                    muzzik *insertMuzzik = [[muzzik new] makeMuzziksByMuzzikArray:[NSMutableArray arrayWithObjects:tempDic, nil]][0];
                    if (insertMuzzik) {
                        [self.trendMuzziks insertObject:[[muzzik new] makeMuzziksByMuzzikArray:[NSMutableArray arrayWithObjects:tempDic, nil]][0] atIndex:1];
                    }
                    
                    break;
                }
                
                
            }
            [MuzzikItem SetUserInfoWithMuzziks:self.trendMuzziks title:Constant_userInfo_square description:nil];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [trendTableView reloadData];
                [trendTableView headerEndRefreshing];
            });
            
        }
        
    }];
    [requestCard setFailedBlock:^{
        
        [trendTableView headerEndRefreshing];
    }];
    [requestCard startAsynchronous];
}
-(void) requestForCard{
    if ([self.trendMuzziks count]>0 && [muzzikArray count]>0) {
        NSArray *tempArray = [[muzzik new] makeMuzziksNeedsSetUserByMuzzikArray:muzzikArray];
        for (muzzik *tempMuzzik in tempArray) {
            [self.trendMuzziks insertObject:tempMuzzik atIndex:0];
        }
    }
    ASIHTTPRequest *requestCard = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/muzzik/card",BaseURL]]];
    [requestCard addBodyDataSourceWithJsonByDic:nil Method:GetMethod auth:YES];
    __weak ASIHTTPRequest *weakrequestCard = requestCard;
    [requestCard setCompletionBlock :^{
        NSMutableArray *suggestCardArray = [[MuzzikItem getArrayFromLocalForKey:@"Muzzik_suggest_Day_ClickArray"] mutableCopy];
        if (!suggestCardArray) {
            suggestCardArray = [NSMutableArray array];
        }
        NSData *data = [weakrequestCard responseData];
        NSDictionary *cardDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        NSArray *requestArray ;
        if (cardDic && [[cardDic allKeys] containsObject:@"muzziks"]) {
            requestArray = [cardDic objectForKey:@"muzziks"];
            for (NSDictionary *tempDic in requestArray) {
                
                if (![suggestCardArray containsObject:[tempDic objectForKey:@"_id"]]) {
                    for (muzzik *checkMuzzik in self.trendMuzziks) {
                        if ([[tempDic objectForKey:@"_id"] isEqualToString:checkMuzzik.muzzik_id]) {
                            if (self.trendMuzziks.count >1) {
                                
                                [self.trendMuzziks removeObject:checkMuzzik];
                            }
                            break;
                        }
                        
                    }
                    if (self.trendMuzziks && [[muzzik new] makeMuzziksByMuzzikArray:[NSMutableArray arrayWithObjects:tempDic, nil]][0] && tempDic) {
                        [self.trendMuzziks insertObject:[[muzzik new] makeMuzziksNeedsSetUserByMuzzikArray:[NSMutableArray arrayWithObjects:tempDic, nil]][0] atIndex:1];
                    }
                    break;
                }
                
                
            }
            [MuzzikItem SetUserInfoWithMuzziks:self.trendMuzziks title:Constant_userInfo_square description:nil];
            [trendTableView reloadData];
            
            //                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //
            //                        });
            
        }
        
    }];
    [requestCard setFailedBlock:^{
        [trendTableView reloadData];
    }];
    [requestCard startAsynchronous];
}
-(void)reloadDataSource{
    [super reloadDataSource];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        userInfo *user = [userInfo shareClass];
        if ([user.token length]>0) {
            if (mainScroll.contentOffset.x >200) {
                [self trendReloadMuzzikSource];
            }else{
                [self feedReloadMuzzikSource];
            }
        }else{
            [self trendReloadMuzzikSource];
        }
    });
    
    
}
-(void)playnextMuzzikUpdate{
    [feedTableView reloadData];
    [trendTableView reloadData];
    if (self.isViewLoaded &&self.view.window) {
        [self updateAnimation];
    }
}
-(void)playSongWithSongModel:(muzzik *)songModel{
    MuzzikRequestCenter *center = [MuzzikRequestCenter shareClass];
    
    userInfo *user = [userInfo shareClass];
    if ([user.token length]>0) {
        if (mainScroll.contentOffset.x>200) {
            center.subUrlString = @"http://117.121.26.174:8000/api/muzzik/trending";
            center.requestDic = [NSDictionary dictionaryWithObjectsAndKeys:trendLastId,Parameter_from,Limit_Constant,Parameter_Limit, nil];
            center.isPage = NO;
            center.singleMusic = NO;
            center.MuzzikType = Type_Muzzik_Muzzik;
            center.lastId = trendLastId;
            [MuzzikPlayer shareClass].MusicArray = [self.trendMuzziks mutableCopy];
            [MuzzikItem SetUserInfoWithMuzziks:self.trendMuzziks title:Constant_userInfo_square description:[NSString stringWithFormat:@"广场列表"]];
            [[MuzzikPlayer shareClass] playSongWithSongModel:songModel Title:@"广场列表"];
            [MuzzikPlayer shareClass].listType = SquareList;
        }else{
            center.subUrlString = @"http://117.121.26.174/api/muzzik/feeds";
            center.requestDic = [NSDictionary dictionaryWithObjectsAndKeys:feedLastId,Parameter_from,Limit_Constant,Parameter_Limit, nil];
            center.isPage = NO;
            center.singleMusic = NO;
            center.MuzzikType = Type_Muzzik_Muzzik;
            center.lastId = feedLastId;
            
            [MuzzikPlayer shareClass].MusicArray = [self.feedMuzziks mutableCopy];
            [MuzzikItem SetUserInfoWithMuzziks:self.feedMuzziks title:Constant_userInfo_follow description:[NSString stringWithFormat:@"关注列表"]];
            [[MuzzikPlayer shareClass] playSongWithSongModel:songModel Title:@"关注列表"];
            [MuzzikPlayer shareClass].listType = feedList;
        }
    }else{
        center.subUrlString = @"http://117.121.26.174:8000/api/muzzik/introduce";
        center.requestDic = [NSDictionary dictionaryWithObjectsAndKeys:trendLastId,Parameter_from,Limit_Constant,Parameter_Limit, nil];
        center.isPage = NO;
        center.singleMusic = NO;
        center.MuzzikType = Type_Muzzik_Muzzik;
        center.lastId = trendLastId;
        [MuzzikPlayer shareClass].MusicArray = [self.trendMuzziks mutableCopy];
        [MuzzikItem SetUserInfoWithMuzziks:self.trendMuzziks title:Constant_userInfo_square description:[NSString stringWithFormat:@"广场列表"]];
        [[MuzzikPlayer shareClass] playSongWithSongModel:songModel Title:@"广场列表"];
        [MuzzikPlayer shareClass].listType = SquareList;
    }
    if (self.isViewLoaded &&self.view.window) {
        [self updateAnimation];
    }
    //[self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    
}

-(void) commentAtMuzzik:(muzzik *)localMuzzik{
    muzzik *tempMuzzik = localMuzzik;
    DetaiMuzzikVC *detail = [[DetaiMuzzikVC alloc] init];
    detail.muzzik_id = tempMuzzik.muzzik_id;
    detail.showType = Constant_Comment;
     [self.navigationController pushViewController:detail animated:YES];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
}
-(void) showRepost:(NSString *)muzzik_id{
    showUserVC *showvc = [[showUserVC alloc] init];
    showvc.muzzik_id = muzzik_id;
    showvc.showType = @"repost";
    [self.navigationController pushViewController:showvc animated:YES];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
}
-(void) showShare:(NSString *)muzzik_id{
    showUserVC *showvc = [[showUserVC alloc] init];
    showvc.muzzik_id = muzzik_id;
    showvc.showType = @"share";
    [self.navigationController pushViewController:showvc animated:YES];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
}
-(void)showComment:(muzzik *)localMuzzik{
    muzzik *tempMuzzik = localMuzzik;
    DetaiMuzzikVC *detail = [[DetaiMuzzikVC alloc] init];
    detail.muzzik_id = tempMuzzik.muzzik_id;
    detail.showType = Constant_showComment;
    [self.navigationController pushViewController:detail animated:YES];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
}

-(void) showMoved:(NSString *)muzzik_id{
    showUserVC *showvc = [[showUserVC alloc] init];
    showvc.muzzik_id = muzzik_id;
    showvc.showType = @"moved";
    [self.navigationController pushViewController:showvc animated:YES];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
}

-(void)userDetail:(NSString *)user_id{
    userInfo *user = [userInfo shareClass];
    if ([user_id isEqualToString:user.uid]) {
        UserHomePage *home = [[UserHomePage alloc] init];
        home.isPush = YES;
        [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
        [self.navigationController pushViewController:home animated:YES];
        
        
    }else{
        userDetailInfo *detailuser = [[userDetailInfo alloc] init];
        detailuser.uid = user_id;
        [self.navigationController pushViewController:detailuser animated:YES];
        [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    }
    
}
-(void)getLocalPopMuzzikidFresh:(BOOL)refresh{
    if (!localMuzzikIdArray) {
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"hot" ofType:@"muzziks"];
        NSString *muzziks = [NSString stringWithContentsOfFile:plistPath encoding:NSUTF8StringEncoding error:nil];
        localMuzzikIdArray = [muzziks componentsSeparatedByString:@"\n"];
    }
    
    muzzikArray = [NSMutableArray array];
    NSInteger myIndex = arc4random()%(localMuzzikIdArray.count-4);
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/muzzik/detail",BaseURL_GUI]]];
    [request addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:localMuzzikIdArray[myIndex] forKey:@"_id"] Method:GetMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = request;
    [request setCompletionBlock :^{
        // NSLog(@"%@",[weakrequest responseString]);
        if ([weakrequest responseStatusCode] == 200) {
            NSData *data = [weakrequest responseData];
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            if (dic) {
                [muzzikArray addObject:dic];
            }
            
        }
        if ([weakrequest responseStatusCode] == 200 || [weakrequest responseStatusCode] == 404) {
            ASIHTTPRequest *request1 = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/muzzik/detail",BaseURL_GUI]]];
            [request1 addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:localMuzzikIdArray[myIndex+1] forKey:@"_id"] Method:GetMethod auth:YES];
            __weak ASIHTTPRequest *weakrequest1 = request1;
            [request1 setCompletionBlock :^{
                // NSLog(@"%@",[weakrequest responseString]);
                if ([weakrequest1 responseStatusCode] == 200) {
                    NSData *data = [weakrequest1 responseData];
                    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                    if (dic) {
                        [muzzikArray addObject:dic];
                    }
                    
                }
                if ([weakrequest1 responseStatusCode] == 200 || [weakrequest1 responseStatusCode] == 404) {
                    ASIHTTPRequest *request2 = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/muzzik/detail",BaseURL_GUI]]];
                    [request2 addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:localMuzzikIdArray[myIndex+2] forKey:@"_id"] Method:GetMethod auth:YES];
                    __weak ASIHTTPRequest *weakrequest2 = request2;
                    [request2 setCompletionBlock :^{
                        // NSLog(@"%@",[weakrequest responseString]);
                        if ([weakrequest2 responseStatusCode] == 200) {
                            NSData *data = [weakrequest2 responseData];
                            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                            if (dic) {
                                [muzzikArray addObject:dic];
                            }
                            
                        }
                        if ([weakrequest2 responseStatusCode] == 200 || [weakrequest2 responseStatusCode] == 404) {
                            ASIHTTPRequest *request3 = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/muzzik/detail",BaseURL_GUI]]];
                            [request3 addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:localMuzzikIdArray[myIndex+3] forKey:@"_id"] Method:GetMethod auth:YES];
                            __weak ASIHTTPRequest *weakrequest3 = request3;
                            [request3 setCompletionBlock :^{
                                // NSLog(@"%@",[weakrequest responseString]);
                                if ([weakrequest3 responseStatusCode] == 200) {
                                    NSData *data = [weakrequest3 responseData];
                                    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                                    if (dic) {
                                        [muzzikArray addObject:dic];
                                        if (refresh) {
                                            [self upperRefreshRequestForCard];
                                        }else{
                                            [self requestForCard];
                                        }
                                    }
                                    
                                }
                                
                            }];
                            [request3 setFailedBlock:^{
                                NSLog(@"%@",[weakrequest3 error]);
                                if (refresh) {
                                    [self upperRefreshRequestForCard];
                                }else{
                                    [self requestForCard];
                                }
                            }];
                            [request3 startAsynchronous];
                        }
                        
                    }];
                    [request2 setFailedBlock:^{
                        NSLog(@"%@",[weakrequest2 error]);
                        if (refresh) {
                            [self upperRefreshRequestForCard];
                        }else{
                            [self requestForCard];
                        }
                    }];
                    [request2 startAsynchronous];
                }
                
            }];
            [request1 setFailedBlock:^{
                NSLog(@"%@",[weakrequest1 error]);
                if (refresh) {
                    [self upperRefreshRequestForCard];
                }else{
                    [self requestForCard];
                }
            }];
            [request1 startAsynchronous];
        }
        
    }];
    [request setFailedBlock:^{
        if (refresh) {
            [self upperRefreshRequestForCard];
        }else{
            [self requestForCard];
        }
        
        NSLog(@"%@",[weakrequest error]);
        
    }];
    [request startAsynchronous];
}
-(NSMutableArray *) searchUsers:(NSString *)message{
    NSString *checkTabel = @"<>,.~!@＠#$¥%％^&*()，。：；;:‘“～  》？《！＃＊……‘“”／/";
    NSMutableArray *array = [NSMutableArray array];
    BOOL GetAt = NO;
    //  || [[message substringWithRange:NSMakeRange(i, 1)] isEqualToString:@"＠"]
    int location = 0;
    for (int i = 0; i<message.length; i++) {
        if ([[message substringWithRange:NSMakeRange(i, 1)] isEqualToString:@"@"]|| [[message substringWithRange:NSMakeRange(i, 1)] isEqualToString:@"＠"]) {
            GetAt = YES;
            location = i;
            continue;
        }else if ([checkTabel rangeOfString:[message substringWithRange:NSMakeRange(i, 1)]].location != NSNotFound && GetAt){
            GetAt = NO;
            [array addObject:[message substringWithRange:NSMakeRange(location, i-location)]];
            
        }else if(i == message.length-1 && GetAt){
            [array addObject:[message substringWithRange:NSMakeRange(location, i-location+1)]];
        }
    }
    
    
    return array;
}



-(void)shareActionWithMuzzik:(muzzik *)localMuzzik image:(UIImage *) image{
    shareMuzzik = localMuzzik;
    shareImage = image;
    [self addShareView];
}
-(void)SettingShareView{
    CGFloat screenWidth = SCREEN_WIDTH;
    
    CGFloat scaleX = 0.1;
    CGFloat scaleY = 0.08;
    userInfo *user = [userInfo shareClass];
    if (user.WeChatInstalled && user.QQInstalled) {
        maxScaleY = 0.7;
    }else{
        maxScaleY = 0.4;
    }
    shareViewFull = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, SCREEN_HEIGHT)];
    [shareViewFull setAlpha:0];
    [shareViewFull setBackgroundColor:[UIColor colorWithRed:0.125 green:0.121 blue:0.164 alpha:0.8]];
    [shareViewFull addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeShareView)]];
    shareView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, screenWidth, screenWidth*maxScaleY)];
    [shareView setBackgroundColor:[UIColor colorWithRed:0.125 green:0.121 blue:0.164 alpha:0.85]];
    if (user.WeChatInstalled) {
        UIButton *wechatButton = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth*0.1, screenWidth*0.08, screenWidth*0.18, screenWidth*0.18)];
        [wechatButton setImage:[UIImage imageNamed:Image_wechatImage] forState:UIControlStateNormal];
        [wechatButton setBackgroundImage:[UIImage imageNamed:Image_sharebgImage] forState:UIControlStateNormal];
        [wechatButton setBackgroundImage:[UIImage imageNamed:Image_shareclickbgImage] forState:UIControlStateHighlighted];
        [wechatButton setImage:[UIImage imageNamed:Image_wechatImage] forState:UIControlStateHighlighted];
        [wechatButton addTarget:self action:@selector(shareWeChat) forControlEvents:UIControlEventTouchUpInside];
        [shareView addSubview:wechatButton];
        UILabel *weiChatLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth*0.1, screenWidth*0.26, screenWidth*0.18, 20)];
        weiChatLabel.text = @"微 信";
        weiChatLabel.textAlignment = NSTextAlignmentCenter;
        [weiChatLabel setFont:[UIFont systemFontOfSize:12]];
        weiChatLabel.textColor =  Color_line_2;
        [shareView addSubview:weiChatLabel];
        UIButton *timeLineButton = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth*0.41, screenWidth*0.08, SCREEN_WIDTH*0.18, SCREEN_WIDTH*0.18)];
        [timeLineButton setImage:[UIImage imageNamed:Image_momentImage] forState:UIControlStateNormal];
        [timeLineButton setBackgroundImage:[UIImage imageNamed:Image_sharebgImage] forState:UIControlStateNormal];
        [timeLineButton setBackgroundImage:[UIImage imageNamed:Image_shareclickbgImage] forState:UIControlStateHighlighted];
        [timeLineButton setImage:[UIImage imageNamed:Image_momentImage] forState:UIControlStateHighlighted];
        [timeLineButton addTarget:self action:@selector(shareTimeLine) forControlEvents:UIControlEventTouchUpInside];
        [shareView addSubview:timeLineButton];
        
        UILabel *timeLineLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth*0.41, screenWidth*0.26, screenWidth*0.18, 20)];
        timeLineLabel.text = @"朋友圈";
        timeLineLabel.textAlignment = NSTextAlignmentCenter;
        [timeLineLabel setFont:[UIFont systemFontOfSize:12]];
        timeLineLabel.textColor =  Color_line_2;
        [shareView addSubview:timeLineLabel];
        scaleX = 0.72;
    }
    
    
    UIButton *weiboButton = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth*scaleX, screenWidth*0.08, SCREEN_WIDTH*0.18, SCREEN_WIDTH*0.18)];
    [weiboButton setImage:[UIImage imageNamed:Image_weiboImage] forState:UIControlStateNormal];
    [weiboButton setBackgroundImage:[UIImage imageNamed:Image_sharebgImage] forState:UIControlStateNormal];
    [weiboButton setBackgroundImage:[UIImage imageNamed:Image_shareclickbgImage] forState:UIControlStateHighlighted];
    [weiboButton setImage:[UIImage imageNamed:Image_weiboImage] forState:UIControlStateHighlighted];
    [weiboButton addTarget:self action:@selector(shareWeiBo) forControlEvents:UIControlEventTouchUpInside];
    [shareView addSubview:weiboButton];
    UILabel *weiBoLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth*scaleX, screenWidth*0.26, screenWidth*0.18, 20)];
    weiBoLabel.text = @"微 博";
    weiBoLabel.textAlignment = NSTextAlignmentCenter;
    [weiBoLabel setFont:[UIFont systemFontOfSize:12]];
    weiBoLabel.textColor = Color_line_2;
    [shareView addSubview:weiBoLabel];
    if (user.WeChatInstalled) {
        scaleY = 0.39;
        scaleX = 0.1;
    }else{
        scaleX = 0.41;
    }
    if (user.QQInstalled) {
        UIButton *QQButton = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth*scaleX, screenWidth*scaleY, screenWidth*0.18, screenWidth*0.18)];
        [QQButton setImage:[UIImage imageNamed:Image_qqImage] forState:UIControlStateNormal];
        [QQButton setBackgroundImage:[UIImage imageNamed:Image_sharebgImage] forState:UIControlStateNormal];
        [QQButton setBackgroundImage:[UIImage imageNamed:Image_shareclickbgImage] forState:UIControlStateHighlighted];
        [QQButton setImage:[UIImage imageNamed:Image_qqImage] forState:UIControlStateHighlighted];
        [QQButton addTarget:self action:@selector(shareQQ) forControlEvents:UIControlEventTouchUpInside];
        [shareView addSubview:QQButton];
        
        UILabel *QQLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth*scaleX, screenWidth*(scaleY+0.18), screenWidth*0.18, 20)];
        QQLabel.text = @"QQ";
        QQLabel.textAlignment = NSTextAlignmentCenter;
        [QQLabel setFont:[UIFont systemFontOfSize:12]];
        QQLabel.textColor = Color_line_2;
        [shareView addSubview:QQLabel];
        
        UIButton *qqZoneButton = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth*(scaleX+0.31), screenWidth*scaleY, screenWidth*0.18, screenWidth*0.18)];
        [qqZoneButton setImage:[UIImage imageNamed:Image_q_zoneImage] forState:UIControlStateNormal];
        [qqZoneButton setBackgroundImage:[UIImage imageNamed:Image_sharebgImage] forState:UIControlStateNormal];
        [qqZoneButton setBackgroundImage:[UIImage imageNamed:Image_shareclickbgImage] forState:UIControlStateHighlighted];
        [qqZoneButton setImage:[UIImage imageNamed:Image_q_zoneImage] forState:UIControlStateHighlighted];
        [qqZoneButton addTarget:self action:@selector(shareQQZone) forControlEvents:UIControlEventTouchUpInside];
        [shareView addSubview:qqZoneButton];
        
        UILabel *QQZoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth*(scaleX+0.31), screenWidth*(scaleY+0.18), screenWidth*0.18, 20)];
        QQZoneLabel.text = @"QQ空间";
        QQZoneLabel.textAlignment = NSTextAlignmentCenter;
        [QQZoneLabel setFont:[UIFont systemFontOfSize:12]];
        QQZoneLabel.textColor = Color_line_2;
        [shareView addSubview:QQZoneLabel];
        
    }
    
    [shareViewFull addSubview:shareView];
    
    
    
}
-(void)closeShareView{
    [self.rdv_tabBarController setTabBarHidden:NO animated:YES];
    [UIView animateWithDuration:0.5 animations:^{
        [shareViewFull setAlpha:0];
        [shareView setFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_WIDTH*maxScaleY)];
    } completion:^(BOOL finished) {
        [shareViewFull removeFromSuperview];
        
    }];
}
-(void) addShareView{
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    [self.navigationController.view addSubview:shareViewFull];
    [UIView animateWithDuration:0.3 animations:^{
        [shareViewFull setAlpha:1];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 animations:^{
            [shareView setFrame:CGRectMake(0, SCREEN_HEIGHT-SCREEN_WIDTH*maxScaleY, SCREEN_WIDTH, SCREEN_WIDTH*maxScaleY)];
        } ];
    }];
}
- (WBMessageObject *)messageToShare
{
    WBMessageObject *message = [WBMessageObject message];
    
    message.text =[NSString stringWithFormat:@"一起来用Muzzik吧 %@%@",URL_Muzzik_SharePage,shareMuzzik.muzzik_id];
    
    WBImageObject *image = [WBImageObject object];
    userInfo *user = [userInfo shareClass];
    if ([user.token length]>0) {
        if (mainScroll.contentOffset.x>200) {
            image.imageData = UIImageJPEGRepresentation([MuzzikItem convertViewToImage:[trendTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[self.trendMuzziks indexOfObject:shareMuzzik] inSection:0]]], 1.0);
        }else{
            image.imageData = UIImageJPEGRepresentation([MuzzikItem convertViewToImage:[feedTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[self.feedMuzziks indexOfObject:shareMuzzik] inSection:0]]], 1.0);
        }
    }else{
        image.imageData = UIImageJPEGRepresentation([MuzzikItem convertViewToImage:[trendTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[self.trendMuzziks indexOfObject:shareMuzzik] inSection:0]]], 1.0);
    }
    
    message.imageObject = image;
    return message;
}
-(void)shareWeiBo{
    AppDelegate *myDelegate =(AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    WBAuthorizeRequest *authRequest = [WBAuthorizeRequest request];
    authRequest.redirectURI = URL_WeiBo_redirectURI;
    authRequest.scope = @"all";
    
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:[self messageToShare] authInfo:authRequest access_token:myDelegate.wbtoken];
    
    //    request.shouldOpenWeiboAppInstallPageIfNotInstalled = NO;
    [WeiboSDK sendRequest:request];
    NSDictionary *requestDic = [NSDictionary dictionaryWithObjectsAndKeys:shareMuzzik.muzzik_id,@"_id",@"weibo",@"channel", nil];
    
    ASIHTTPRequest *requestShare = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Share_Muzzik]]];
    
    [requestShare addBodyDataSourceWithJsonByDic:requestDic Method:PostMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = requestShare;
    [requestShare setCompletionBlock :^{
        
        shareMuzzik.shares = [NSString stringWithFormat:@"%d",[shareMuzzik.shares intValue]+1];
        [[NSNotificationCenter defaultCenter] postNotificationName:String_MuzzikDataSource_update object:shareMuzzik];
    }];
    [requestShare setFailedBlock:^{
        NSLog(@"%@",[weakrequest error]);
    }];
    [requestShare startAsynchronous];
}
-(void) shareQQ{
    TencentOAuth *tencentOAuth = [[TencentOAuth alloc] initWithAppId:ID_QQ_APP
                                                         andDelegate:nil];
    NSString *url = [NSString stringWithFormat:@"%@%@",URL_Muzzik_SharePage,shareMuzzik.muzzik_id];
    //分享图预览图URL地址
    NSString *previewImageUrl = @"http://muzzik-image.qiniudn.com/FieqckeQDGWACSpDA3P0aDzmGcB6";
    //音乐播放的网络流媒体地址
    QQApiAudioObject *audioObj =[QQApiAudioObject objectWithURL:[NSURL URLWithString:url]
                                                          title:shareMuzzik.music.name description:shareMuzzik.music.artist previewImageURL:[NSURL URLWithString:previewImageUrl]];
    //设置播放流媒体地址
    audioObj.flashURL=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL_audio,shareMuzzik.music.key]];
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:audioObj];
    //将内容分享到qq
    
    QQApiSendResultCode sent = [QQApiInterface sendReq:req];
    [self handleSendResult:sent];
    //将被容分享到qzone
    //QQApiSendResultCode sent = [QQApiInterface SendReqToQZone:req];
    
    NSDictionary *requestDic = [NSDictionary dictionaryWithObjectsAndKeys:shareMuzzik.muzzik_id,@"_id",@"qq",@"channel", nil];
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Share_Muzzik]]];
    
    [request addBodyDataSourceWithJsonByDic:requestDic Method:PostMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = request;
    [request setCompletionBlock :^{

        shareMuzzik.shares = [NSString stringWithFormat:@"%d",[shareMuzzik.shares intValue]+1];
        [[NSNotificationCenter defaultCenter] postNotificationName:String_MuzzikDataSource_update object:shareMuzzik];
    }];
    [request setFailedBlock:^{
        NSLog(@"%@",[weakrequest error]);
    }];
    [request startAsynchronous];
    
    
}
- (void)handleSendResult:(QQApiSendResultCode)sendResult
{
    switch (sendResult)
    {
        case EQQAPIAPPNOTREGISTED:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"App未注册" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            
            
            break;
        }
        case EQQAPIMESSAGECONTENTINVALID:
        case EQQAPIMESSAGECONTENTNULL:
        case EQQAPIMESSAGETYPEINVALID:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"发送参数错误" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            
            
            break;
        }
        case EQQAPIQQNOTINSTALLED:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"未安装手Q" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            
            
            break;
        }
        case EQQAPIQQNOTSUPPORTAPI:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"API接口不支持" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            
            
            break;
        }
        case EQQAPISENDFAILD:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"发送失败" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            
            break;
        }
        default:
        {
            break;
        }
    }
}
-(void) shareQQZone{
    
    TencentOAuth *tencentOAuth = [[TencentOAuth alloc] initWithAppId:ID_QQ_APP
                                                         andDelegate:nil];
    //分享跳转URL
    NSString *url = [NSString stringWithFormat:@"%@%@",URL_Muzzik_SharePage,shareMuzzik.muzzik_id];
    //分享图预览图URL地址
    NSString *previewImageUrl = [NSString stringWithFormat:@"%@%@",BaseURL_image,shareMuzzik.MuzzikUser.avatar];
    //音乐播放的网络流媒体地址
    NSString *flashURL = [NSString stringWithFormat:@"%@%@",BaseURL_audio,shareMuzzik.music.key];
    QQApiAudioObject *audioObj =[QQApiAudioObject objectWithURL:[NSURL URLWithString:url]
                                                          title:@"我在Muzzik上分享了首歌" description:[NSString stringWithFormat:@"%@  %@",shareMuzzik.music.name,shareMuzzik.music.artist] previewImageURL:[NSURL URLWithString:previewImageUrl]];
    //设置播放流媒体地址
    audioObj.flashURL = [NSURL URLWithString:flashURL] ;
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:audioObj];
    //将内容分享到qq
    //QQApiSendResultCode sent = [QQApiInterface sendReq:req];
    //将被容分享到qzone
    QQApiSendResultCode sent = [QQApiInterface SendReqToQZone:req];
    
    [self handleSendResult:sent];
    
    NSDictionary *requestDic = [NSDictionary dictionaryWithObjectsAndKeys:shareMuzzik.muzzik_id,@"_id",@"qzone",@"channel", nil];
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Share_Muzzik]]];
    
    [request addBodyDataSourceWithJsonByDic:requestDic Method:PostMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = request;
    [request setCompletionBlock :^{
        
        shareMuzzik.shares = [NSString stringWithFormat:@"%d",[shareMuzzik.shares intValue]+1];
        [[NSNotificationCenter defaultCenter] postNotificationName:String_MuzzikDataSource_update object:shareMuzzik];
    }];
    [request setFailedBlock:^{
        NSLog(@"%@",[weakrequest error]);
    }];
    [request startAsynchronous];
    
}
-(void) shareTimeLine{
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [app sendMusicContentByMuzzik:shareMuzzik scen:1 image:shareImage];
    NSDictionary *requestDic = [NSDictionary dictionaryWithObjectsAndKeys:shareMuzzik.muzzik_id,@"_id",@"moment",@"channel", nil];
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Share_Muzzik]]];
    
    [request addBodyDataSourceWithJsonByDic:requestDic Method:PostMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = request;
    [request setCompletionBlock :^{
        
        shareMuzzik.shares = [NSString stringWithFormat:@"%d",[shareMuzzik.shares intValue]+1];
        [[NSNotificationCenter defaultCenter] postNotificationName:String_MuzzikDataSource_update object:shareMuzzik];
    }];
    [request setFailedBlock:^{
        NSLog(@"%@",[weakrequest error]);
    }];
    [request startAsynchronous];
}

-(void) shareWeChat{
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [app sendMusicContentByMuzzik:shareMuzzik scen:0 image:shareImage];
    NSDictionary *requestDic = [NSDictionary dictionaryWithObjectsAndKeys:shareMuzzik.muzzik_id,@"_id",@"wechat",@"channel", nil];
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Share_Muzzik]]];
    
    [request addBodyDataSourceWithJsonByDic:requestDic Method:PostMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = request;
    [request setCompletionBlock :^{
        
        shareMuzzik.shares = [NSString stringWithFormat:@"%d",[shareMuzzik.shares intValue]+1];
        [[NSNotificationCenter defaultCenter] postNotificationName:String_MuzzikDataSource_update object:shareMuzzik];
    }];
    [request setFailedBlock:^{
        NSLog(@"%@",[weakrequest error]);
    }];
    [request startAsynchronous];
}
-(void)dataSourceMuzzikUpdate:(NSNotification *)notify{
    muzzik *tempMuzzik = (muzzik *)notify.object;
    if ([MuzzikItem checkMutableArray:self.trendMuzziks isContainMuzzik:tempMuzzik]) {
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:[self.trendMuzziks indexOfObject:tempMuzzik] inSection:0];
        [trendTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
    }
    
    if ([MuzzikItem checkMutableArray:self.feedMuzziks isContainMuzzik:tempMuzzik]) {
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:[self.feedMuzziks indexOfObject:tempMuzzik] inSection:0];
        [feedTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
    }
    
    
}
-(void)receiveNewSendMuzzik:(NSNotification *)notify{
    
    muzzik *tempMuzzik = (muzzik *)notify.object;
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/user/byMusic",BaseURL]]];
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"1",Parameter_page,[tempMuzzik.music.artist stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],@"artist",[tempMuzzik.music.name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],@"name", nil];
    [request addBodyDataSourceWithJsonByDic:dic Method:GetMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = request;
    [request setCompletionBlock :^{
        NSData *data = [weakrequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        userArray = [[MuzzikUser new] makeMuzziksByUserArray:[dic objectForKey:@"users"]];
        if ([userArray count]>0) {
            for (UIView *subview in userView.subviews) {
                [subview removeFromSuperview];
            }
            int fromX = 16;
            UILabel *tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 8, 250, 14)];
            if ([userArray count] == 1) {
                [tipsLabel setText:[NSString stringWithFormat:@"Ta也分享了这首歌： %@",tempMuzzik.music.name]];
            }else{
                [tipsLabel setText:[NSString stringWithFormat:@"他们也分享了这首歌： %@",tempMuzzik.music.name]];
            }
            
            [tipsLabel setTextColor:Color_Text_2];
            [tipsLabel setFont:[UIFont systemFontOfSize:11]];
            [userView addSubview:tipsLabel];
            UIButton *closeViewButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-31, 0, 31, 75)];
            [closeViewButton setImage:[UIImage imageNamed:@"recommandcloseImage"] forState:UIControlStateNormal];
            [closeViewButton addTarget:self action:@selector(closeUserView) forControlEvents:UIControlEventTouchUpInside];
            [userView addSubview:closeViewButton];
            BOOL GotMore = NO;
            if ((SCREEN_WIDTH-50)/50<userArray.count) {
                GotMore = YES;
                UIButton *moreButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-71, 27, 40, 40)];
                [moreButton setImage:[UIImage imageNamed:@"recommandmoreImage"] forState:UIControlStateNormal];
                [moreButton addTarget:self action:@selector(seeMoreUser) forControlEvents:UIControlEventTouchUpInside];
                [userView addSubview:moreButton];
            }
            
            for (MuzzikUser *user in userArray) {
                int temp = GotMore ? SCREEN_WIDTH-110 :SCREEN_WIDTH-71;
                if (fromX < temp) {
                    
                    UIButton_UserMuzzik *userbutton = [[UIButton_UserMuzzik alloc] initWithFrame:CGRectMake(fromX, 27, 40, 40)];
                    userbutton.user =user;
                    userbutton.layer.cornerRadius = 20;
                    userbutton.clipsToBounds = YES;
                    [userbutton addTarget:self action:@selector(seeVipUser:) forControlEvents:UIControlEventTouchUpInside];
                    [userbutton setAlpha:0];
                    
                    [userbutton sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",BaseURL_image,user.avatar,Image_Size_Small]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:Image_user_placeHolder] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                        [UIView animateWithDuration:0.5 animations:^{
                            [userbutton setAlpha:1];
                        }];
                        
                        
                    }];
                    fromX += 48;
                    [userView addSubview:userbutton];
                }else{
                    break;
                }
            }
            [self.view addSubview:userView];
            [UIView animateWithDuration:1 animations:^{
                [userView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, 75)];
                [feedTableView setFrame:CGRectMake(0, 75, SCREEN_WIDTH, SCREEN_HEIGHT-139)];
                [trendTableView setFrame:CGRectMake(SCREEN_WIDTH, 75, SCREEN_WIDTH, SCREEN_HEIGHT-139)];
            }];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (!isUserTaped) {
                    [UIView animateWithDuration:0.5 animations:^{
                        [userView setFrame:CGRectMake(0, -75, SCREEN_WIDTH, 75)];
                        [feedTableView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
                        [trendTableView setFrame:CGRectMake(SCREEN_WIDTH, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
                    } completion:^(BOOL finished) {
                        [userView removeFromSuperview];
                    }];
                }else{
                    isUserTaped = NO;
                }
                
            });
        }
    }];
    [request setFailedBlock:^{
        NSLog(@"%@",[weakrequest error]);
    }];
    [request startAsynchronous];
    
    [self.feedMuzziks insertObject:tempMuzzik atIndex:0];
    [self.trendMuzziks insertObject:tempMuzzik atIndex:0];
    [feedTableView reloadData];
    [trendTableView reloadData];
}

-(void) seeVipUser:(UIButton_UserMuzzik *)button{
    isUserTaped = YES;
    userInfo *user = [userInfo shareClass];
    if ([button.user.user_id isEqualToString:user.uid]) {
//        UserHomePage *home = [[UserHomePage alloc] init];
//        [self.navigationController pushViewController:home animated:YES];
    }else{
        userDetailInfo *detailuser = [[userDetailInfo alloc] init];
        detailuser.uid = button.user.user_id;
        [self.navigationController pushViewController:detailuser animated:YES];
        [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    }
}
-(void)closeUserView{
    isUserTaped = NO;
    [UIView animateWithDuration:0.5 animations:^{
        [userView setFrame:CGRectMake(0, -75, SCREEN_WIDTH, 75)];
        [feedTableView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
        [trendTableView setFrame:CGRectMake(SCREEN_WIDTH, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
    } completion:^(BOOL finished) {
        [userView removeFromSuperview];
    }];
}
-(void)seeMoreUser{
    isUserTaped = YES;
    showUserVC *showvc = [[showUserVC alloc] init];
    showvc.showType = @"songUser";
    showvc.userArray = userArray;
    [self.navigationController pushViewController:showvc animated:YES];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];

}
-(void)scrollCell:(NSIndexPath *) indexpath{
    [trendTableView scrollToRowAtIndexPath:indexpath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

-(void)dataSourceUserUpdate:(NSNotification *)notify{
    userInfo *user = [userInfo shareClass];
    MuzzikUser *muzzikuser = notify.object;
    if (muzzikuser.isFollow) {
        if (muzzikuser.isFans) {
            [user.followDic setValue:Friend_follow_Each forKey:muzzikuser.user_id];
        }else{
            [user.followDic setValue:Friend_isFollow forKey:muzzikuser.user_id];
        }
    }else{
        if (muzzikuser.isFans) {
            [user.followDic setValue:Friend_Isfans forKey:muzzikuser.user_id];
        }else{
            [user.followDic setValue:Friend_strange forKey:muzzikuser.user_id];
        }
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [trendTableView reloadData];
    });
}
@end
