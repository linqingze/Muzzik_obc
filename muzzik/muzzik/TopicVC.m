//
//  TopicVC.m
//  muzzik
//
//  Created by muzzik on 15/4/3.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "TopicVC.h"
#import "topicLabel.h"
#import "TopicDetail.h"
#import "UIImageView+WebCache.h"
#import "TapImageView.h"
#import "TTTAttributedLabel.h"
#import "UIButton+WebCache.h"
#import "userDetailInfo.h"
#import "SuggestMuzzikVC.h"
#import "ActivityUserVC.h"
#import "TopRankVC.h"
#import "UIButton_UserMuzzik.h"
#import "RDVTabBarController.h"

#define width_For_Cell 60.0
@interface TopicVC ()<UIScrollViewDelegate,TapLabelDelegate>{
    
    UIScrollView *mainScroll;
    NSArray *topicArray;
    NSArray *userArray;
    muzzik *trendMuzzik;
    muzzik *suggestMuzzik;
    NSMutableArray *suggestArray;
    muzzik *localMuzzik;
    
    //topic
    UIView *topicView;
    UILabel *hotLabel;
    UIImageView *topicNext;
    
    //user
    UIView *userView;
    UILabel *userLabel;
    UIImageView *userNext;
    
    //muzzik
    UIButton *headButton;
    UIImageView *muzzikImage;
    UIView *MainMuzzikView ;
    UIView *muzzikView;
    UILabel *muzzikLabel;
    UIImageView *muzzikNext;
    UILabel *musicName;
    UIButton *playButton;
    UIButton *likeButton;
    UIProgressView *progress;
    NSMutableArray *userImageArray;
    TTTAttributedLabel *label;
    UILabel *userNameLabel;
    UILabel *timeStamp;
    UIImageView *timeImage;
    UIView *musicPlayView;
    BOOL loadedSquare;
    BOOL loadedTopic;
    BOOL loadedUser;
    BOOL loadedMuzzik;

}
@end

@implementation TopicVC

- (void)viewDidLoad {
    [super viewDidLoad];
    userImageArray = [NSMutableArray array];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self initNagationBar:@"热门" leftBtn:8 rightBtn:0];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataSourceMuzzikUpdate:) name:String_MuzzikDataSource_update object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataSourceUserUpdate:) name:String_UserDataSource_update object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playnextMuzzikUpdate) name:String_SetSongPlayNextNotification object:nil];
    mainScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
    [mainScroll setContentSize:CGSizeMake(SCREEN_WIDTH, 1200)];
    [self.view addSubview:mainScroll];
    [self followScrollView:mainScroll];

    
    
    //topic
    topicView = [[UIView alloc] initWithFrame:CGRectMake(8, 259+(NSInteger)(SCREEN_WIDTH*5/3), SCREEN_WIDTH-16, 234)];
    [topicView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapForMoreTopic)]];
    [topicView setBackgroundColor:Color_line_2];
    topicView.layer.cornerRadius =3;
    topicView.clipsToBounds = YES;
    [mainScroll addSubview:topicView];
    hotLabel = [[UILabel alloc] initWithFrame:CGRectMake(15,0 , topicView.frame.size.width-30, 40)];
    hotLabel.font = [UIFont boldSystemFontOfSize:15];
    [hotLabel setTextColor:Color_Text_2];
    hotLabel.adjustsFontSizeToFitWidth = YES;
    hotLabel.text = @"热门话题";
    
    topicNext = [[UIImageView alloc] initWithFrame:CGRectMake(topicView.frame.size.width-22, 14, 7, 12)];
    [topicNext setImage:[UIImage imageNamed:Image_recommendarrowImage]];
    [topicView addSubview:hotLabel];
    [topicView addSubview:topicNext];
    
    [self loadTopics];
    //user
    userView = [[UIView alloc] initWithFrame:CGRectMake(8, 16, SCREEN_WIDTH-16, (NSInteger)(58+SCREEN_WIDTH*2/3))];
    [userView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapForMoreUser)]];
    [userView setBackgroundColor:Color_line_2];
    userView.layer.cornerRadius =3;
    userView.clipsToBounds = YES;
    [mainScroll addSubview:userView];
    userLabel = [[UILabel alloc] initWithFrame:CGRectMake(15,0 , topicView.frame.size.width-30, 40)];
    userLabel.font = [UIFont boldSystemFontOfSize:15];
    userLabel.adjustsFontSizeToFitWidth = YES;
    [userLabel setTextColor:Color_Text_2];
    [userView addSubview:userLabel];
    userNext = [[UIImageView alloc] initWithFrame:CGRectMake(topicView.frame.size.width-22, 14, 7, 12)];
    [userNext setImage:[UIImage imageNamed:Image_recommendarrowImage]];
    [userView addSubview:userNext];
    [self loadUser];
    //Muzzik
    MainMuzzikView = [[UIView alloc] initWithFrame:CGRectMake(0, (NSInteger)(154+SCREEN_WIDTH*2/3), SCREEN_WIDTH, 145+SCREEN_WIDTH)];
    [MainMuzzikView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(SeeMoreSuggestMuzzik)]];
    [mainScroll addSubview: MainMuzzikView];
    muzzikImage = [[UIImageView alloc] initWithFrame:CGRectMake(5, 40, SCREEN_WIDTH-10, SCREEN_WIDTH-10)];
    [MainMuzzikView addSubview:muzzikImage];
    muzzikView = [[UIView alloc] initWithFrame:CGRectMake(8, 0, SCREEN_WIDTH-16, 145+SCREEN_WIDTH)];
    [muzzikView setBackgroundColor:Color_line_2];
    muzzikView.layer.cornerRadius =3;
    muzzikView.clipsToBounds = YES;
    [MainMuzzikView addSubview:muzzikView];
    muzzikLabel = [[UILabel alloc] initWithFrame:CGRectMake(15,0 , topicView.frame.size.width-30 , 40)];
    muzzikLabel.font = [UIFont boldSystemFontOfSize:15];
    muzzikLabel.adjustsFontSizeToFitWidth = YES;
    [muzzikLabel setTextColor:Color_Text_2];
    [muzzikView addSubview:muzzikLabel];
    muzzikNext = [[UIImageView alloc] initWithFrame:CGRectMake(topicView.frame.size.width-22, 14, 7, 12)];
    [muzzikNext setImage:[UIImage imageNamed:Image_recommendarrowImage]];
    [muzzikView addSubview:muzzikNext];
    [self loadMuzzik];
    [mainScroll addHeaderWithTarget:self action:@selector(refreshHeader)];
    if (self.rdv_tabBarController.tabBar.translucent) {
        UIEdgeInsets insets = UIEdgeInsetsMake(0,
                                               0,
                                               CGRectGetHeight(self.rdv_tabBarController.tabBar.frame),
                                               0);
        
        mainScroll.contentInset = insets;
        mainScroll.scrollIndicatorInsets = insets;
    }
    
}
-(void)refreshHeader{
     [self loadUser];
     [self loadMuzzik];
     [self loadTopics];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        [mainScroll headerEndRefreshing];
//        if (loadedUser && loadedTopic && loadedSquare && loadedMuzzik) {
//            [mainScroll removeHeader];
//        }
    });
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:NO animated:YES];
//    userView.frame = CGRectMake(8, 16, SCREEN_WIDTH-16, (NSInteger)(58+SCREEN_WIDTH*2/3));
//    MainMuzzikView.frame = CGRectMake(0, (NSInteger)(94+SCREEN_WIDTH*2/3), SCREEN_WIDTH-16, MainMuzzikView.frame.size.height);
//    topicView.frame = CGRectMake(8, 114+(NSInteger)(SCREEN_WIDTH*2/3+MainMuzzikView.frame.size.height), SCREEN_WIDTH-16, 234);
//    [mainScroll setContentSize:CGSizeMake(SCREEN_WIDTH, topicView.frame.origin.y+topicView.frame.size.height+20)];
    

}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark -loadData
-(void) loadTopics{
    if ([MuzzikItem getDataFromLocalKey: Constant_Data_topic]) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[MuzzikItem getDataFromLocalKey: Constant_Data_topic] options:NSJSONReadingMutableContainers error:nil];
        if (dic) {

            for (UIView *view in [topicView subviews]) {
                [view removeFromSuperview];
            }
            [topicView addSubview: hotLabel];
            
            [topicView addSubview:topicNext];
            
            loadedTopic =YES;
            CGFloat MaxX = SCREEN_WIDTH-23;
            CGFloat localX = 15;
            CGFloat localY = 42;
            topicArray = [dic objectForKey:@"topics"];
            if ([[[dic objectForKey:@"data"] allKeys] containsObject:@"title"] && [[[dic objectForKey:@"data"] objectForKey:@"title"] length]>0) {
                hotLabel.text = [[dic objectForKey:@"data"] objectForKey:@"title"];
            }
            for (int i = 0; i<topicArray.count; i++) {
                topicLabel *tempLabel = [[topicLabel alloc] init];
                tempLabel.delegate = self;
                [tempLabel setText:[topicArray[i] objectForKey:@"name"] font:[UIFont boldSystemFontOfSize:12] color:[[topicArray[i] objectForKey:@"color"] longValue]];
                tempLabel.tid = [topicArray[i] objectForKey:@"_id"];
                if (localX +tempLabel.frame.size.width+8>MaxX) {
                    localX = 15;
                    localY = localY+38;
                    if (localY<224) {
                        [tempLabel setFrame:CGRectMake(localX, localY, tempLabel.frame.size.width, tempLabel.frame.size.height)];
                        [topicView addSubview:tempLabel];
                        localX = localX+tempLabel.frame.size.width+8;
                    }else{
                        break;
                    }
                }else{
                    [tempLabel setFrame:CGRectMake(localX, localY, tempLabel.frame.size.width, tempLabel.frame.size.height)];
                    [topicView addSubview:tempLabel];
                    localX = localX+tempLabel.frame.size.width+8;
                }
            }
        }
    }
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/topic/suggest",BaseURL]]];
    [request addBodyDataSourceWithJsonByDic:nil Method:GetMethod auth:NO];
    __weak ASIHTTPRequest *weakrequest = request;
    [request setCompletionBlock :^{
        //    NSLog(@"%@",weakrequest.originalURL);
        NSLog(@"%@",[weakrequest responseString]);
        NSData *data = [weakrequest responseData];
        [MuzzikItem addObjectToLocal:data ForKey:Constant_Data_topic];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (dic) {
            loadedTopic = YES;
            for (UIView *view in [topicView subviews]) {
                [view removeFromSuperview];
            }
            [topicView addSubview: hotLabel];
            
            [topicView addSubview:topicNext];
            if ([[dic allKeys] containsObject:@"data"] && [[[dic objectForKey:@"data"] allKeys] containsObject:@"title"] && [[[dic objectForKey:@"data"] objectForKey:@"title"] length] >0) {
                hotLabel.text = [[dic objectForKey:@"data"] objectForKey:@"title"];
            }
            CGFloat MaxX = SCREEN_WIDTH-23;
            CGFloat localX = 15;
            CGFloat localY = 42;
            topicArray = [dic objectForKey:@"topics"];
            for (int i = 0; i<topicArray.count; i++) {
                topicLabel *tempLabel = [[topicLabel alloc] init];
                tempLabel.delegate = self;
                [tempLabel setText:[topicArray[i] objectForKey:@"name"] font:[UIFont boldSystemFontOfSize:12] color:[[topicArray[i] objectForKey:@"color"] longValue]];
                tempLabel.tid = [topicArray[i] objectForKey:@"_id"];
                if (localX +tempLabel.frame.size.width+8>MaxX) {
                    localX = 15;
                    localY = localY+38;
                    if (localY<224) {
                        [tempLabel setFrame:CGRectMake(localX, localY, tempLabel.frame.size.width, tempLabel.frame.size.height)];
                        [topicView addSubview:tempLabel];
                        localX = localX+tempLabel.frame.size.width+8;
                    }else{
                        break;
                    }
                }else{
                    [tempLabel setFrame:CGRectMake(localX, localY, tempLabel.frame.size.width, tempLabel.frame.size.height)];
                    [topicView addSubview:tempLabel];
                    localX = localX+tempLabel.frame.size.width+8;
                }
            }
        }
    }];
    [request setFailedBlock:^{
        NSLog(@"%@,%@",[weakrequest error],[weakrequest responseString]);
        
    }];
    [request startAsynchronous];
}

-(void) loadUser{
    if ([MuzzikItem getDataFromLocalKey: Constant_Data_User_Vip]) {
        for (UIView *view in [userView subviews]) {
            [view removeFromSuperview];
        }
        [userView addSubview: userLabel];

        [userView addSubview:userNext];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[MuzzikItem getDataFromLocalKey: Constant_Data_User_Vip] options:NSJSONReadingMutableContainers error:nil];
        if (dic) {
            if ([[dic allKeys] containsObject:@"data"] && [[[dic objectForKey:@"data"] allKeys] containsObject:@"title"] && [[[dic objectForKey:@"data"] objectForKey:@"title"] length] >0) {
                userLabel.text = [[dic objectForKey:@"data"] objectForKey:@"title"];
            }else{
                userLabel.text = @"我上榜了";
            }
            
            loadedUser = YES;
            MuzzikUser *muzzikToy = [MuzzikUser new];
            userArray = [muzzikToy makeMuzziksByUserArray:[dic objectForKey:@"users"]];
            NSMutableArray *tempArray = [NSMutableArray array];
            if ([userArray count]>6) {
                while (tempArray.count<6) {
                    MuzzikUser *user = [userArray objectAtIndex:arc4random()%userArray.count];
                    if (![tempArray containsObject:user]) {
                        [tempArray addObject:user];
                    }
                }
            }else{
                [tempArray addObjectsFromArray:userArray];
            }
            
            CGFloat localX = 15;
            CGFloat localY = 52;
            for (int i = 0; i<2; i++) {
                for (int j=0; j<3; j++) {
                    MuzzikUser * tempUser = tempArray[i*3+j];
                    UIButton_UserMuzzik *userbutton = [[UIButton_UserMuzzik alloc] initWithFrame:CGRectMake(localX, localY, SCREEN_WIDTH/3-31, SCREEN_WIDTH/3-31)];
                    userbutton.user =tempUser;
                    CGFloat x = SCREEN_WIDTH/6-15.5;
                    userbutton.layer.cornerRadius = SCREEN_WIDTH/6-15.5;
                    userbutton.clipsToBounds = YES;
                    [userbutton addTarget:self action:@selector(seeVipUser:) forControlEvents:UIControlEventTouchUpInside];
                    [userbutton setAlpha:0];
                    [userbutton sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",BaseURL_image,tempUser.avatar,Image_Size_Small]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:Image_user_placeHolder] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                        [UIView animateWithDuration:0.5 animations:^{
                            [userbutton setAlpha:1];
                        }];
                    }];
                    
                    
                    UIButton_UserMuzzik *followImage = [[UIButton_UserMuzzik alloc] initWithFrame:CGRectMake((int)(userbutton.frame.origin.x+userbutton.frame.size.width-29), (int)(userbutton.frame.size.height+userbutton.frame.origin.y-29), 29, 29)];
                    followImage.user = tempUser;
                    
                    if (tempUser.isFans && tempUser.isFollow) {
                        followImage.followType = @"1";
                        [followImage setImage:[UIImage imageNamed:Image_recommendfollowedeachother] forState:UIControlStateNormal];
                    }else if (tempUser.isFollow){
                        followImage.followType = @"1";
                        [followImage setImage:[UIImage imageNamed:Image_recommendfollowed] forState:UIControlStateNormal];
                    }else{
                        followImage.followType = @"0";
                        [followImage setImage:[UIImage imageNamed:Image_recommendfollow] forState:UIControlStateNormal];
                    }
                    [followImage addTarget:self action:@selector(follwUser:) forControlEvents:UIControlEventTouchUpInside];
                    [userImageArray addObject:followImage];
                    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake((int)localX, (int)(userbutton.frame.size.height+userbutton.frame.origin.y+5), (int)(SCREEN_WIDTH/3-31), 15)];
                    [nameLabel setFont:[UIFont systemFontOfSize:12]];
                    [nameLabel setText:tempUser.name];
                    [nameLabel setTextColor:Color_Text_2];
                    nameLabel.textAlignment = NSTextAlignmentCenter;
                    [userView addSubview:nameLabel];
                    [userView addSubview:userbutton];
                    [userView addSubview:followImage];
                    localX = SCREEN_WIDTH/3-7+localX;
                }
                localY = localY +SCREEN_WIDTH/3+1;
                localX = 15;
            }
            
        }
    }
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/user/suggest",BaseURL]]];
    [request addBodyDataSourceWithJsonByDic:nil Method:GetMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = request;
    [request setCompletionBlock :^{
        //    NSLog(@"%@",weakrequest.originalURL);
        NSLog(@"%@",[weakrequest responseString]);
        NSData *data = [weakrequest responseData];
        [MuzzikItem addObjectToLocal:data ForKey:Constant_Data_User_Vip];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (dic) {
            for (UIView *view in [userView subviews]) {
                [view removeFromSuperview];
            }
            [userView addSubview: userLabel];
            
            [userView addSubview:userNext];
            
            loadedUser = YES;
            if ([[dic allKeys] containsObject:@"data"] && [[[dic objectForKey:@"data"] allKeys] containsObject:@"title"] && [[[dic objectForKey:@"data"] objectForKey:@"title"] length] >0) {
                userLabel.text = [[dic objectForKey:@"data"] objectForKey:@"title"];
            }else{
                userLabel.text = @"我上榜了";
            }
            MuzzikUser *muzzikToy = [MuzzikUser new];
            userArray = [muzzikToy makeMuzziksByUserArray:[dic objectForKey:@"users"]];
            NSMutableArray *tempArray = [NSMutableArray array];
            if ([userArray count]>6) {
                while (tempArray.count<6) {
                    MuzzikUser *user = [userArray objectAtIndex:arc4random()%userArray.count];
                    if (![tempArray containsObject:user]) {
                        [tempArray addObject:user];
                    }
                }
            }else{
                [tempArray addObjectsFromArray:userArray];
            }
           
            CGFloat localX = 15;
            CGFloat localY = 47;
            for (int i = 0; i<2; i++) {
                for (int j=0; j<3; j++) {
                    MuzzikUser * tempUser = tempArray[i*3+j];
                    UIButton_UserMuzzik *userbutton = [[UIButton_UserMuzzik alloc] initWithFrame:CGRectMake(localX, localY, SCREEN_WIDTH/3-31, SCREEN_WIDTH/3-31)];
                    CGFloat x = SCREEN_WIDTH/6-15.5;
                    userbutton.user =tempUser;
                    userbutton.layer.cornerRadius = SCREEN_WIDTH/6-15.5;
                    userbutton.clipsToBounds = YES;
                    [userbutton addTarget:self action:@selector(seeVipUser:) forControlEvents:UIControlEventTouchUpInside];
                    [userbutton setAlpha:0];
                    [userbutton sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",BaseURL_image,tempUser.avatar,Image_Size_Small]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:Image_user_placeHolder] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                        [UIView animateWithDuration:0.5 animations:^{
                            [userbutton setAlpha:1];
                        }];
                    }];

                    
                    UIButton_UserMuzzik *followImage = [[UIButton_UserMuzzik alloc] initWithFrame:CGRectMake((int)(userbutton.frame.origin.x+userbutton.frame.size.width-29), (int)(userbutton.frame.size.height+userbutton.frame.origin.y-29), 29, 29)];
                    followImage.user = tempUser;
                    if ([[userInfo shareClass].uid length]>0 && [followImage.user.user_id isEqualToString:[userInfo shareClass].uid]) {
                        [followImage setHidden:YES];
                    }else{
                        [followImage setHidden:NO];
                    }
                    
                    if (tempUser.isFans && tempUser.isFollow) {
                        followImage.followType = @"1";
                        [followImage setImage:[UIImage imageNamed:Image_recommendfollowedeachother] forState:UIControlStateNormal];
                    }else if (tempUser.isFollow){
                        followImage.followType = @"1";
                        [followImage setImage:[UIImage imageNamed:Image_recommendfollowed] forState:UIControlStateNormal];
                    }else{
                        followImage.followType = @"0";
                        [followImage setImage:[UIImage imageNamed:Image_recommendfollow] forState:UIControlStateNormal];
                    }
                    [followImage addTarget:self action:@selector(follwUser:) forControlEvents:UIControlEventTouchUpInside];
                    [userImageArray addObject:followImage];
                    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake((int)localX, (int)(userbutton.frame.size.height+userbutton.frame.origin.y+5), (int)(SCREEN_WIDTH/3-31), 15)];
                    [nameLabel setFont:[UIFont systemFontOfSize:12]];
                    [nameLabel setText:tempUser.name];
                    [nameLabel setTextColor:Color_Text_2];
                    nameLabel.textAlignment = NSTextAlignmentCenter;
                    [userView addSubview:nameLabel];
                    [userView addSubview:userbutton];
                    [userView addSubview:followImage];
                    localX = SCREEN_WIDTH/3-7+localX;
                }
                localY = localY +SCREEN_WIDTH/3+1;
                localX = 15;
            }
            
        }
    }];
    [request setFailedBlock:^{
        NSLog(@"%@,%@",[weakrequest error],[weakrequest responseString]);
        
    }];
    [request startAsynchronous];
}
-(void) loadMuzzik{
    if ([MuzzikItem getDataFromLocalKey: Constant_Data_Suggest]) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[MuzzikItem getDataFromLocalKey: Constant_Data_Suggest] options:NSJSONReadingMutableContainers error:nil];
        if (dic&&[[dic objectForKey:@"muzziks"]count]>0) {
            suggestArray = [[muzzik new] makeMuzziksByMuzzikArray:[dic objectForKey:@"muzziks"] ] ;
            suggestMuzzik = [suggestArray firstObject];

            if ([[dic allKeys] containsObject:@"data"] && [[[dic objectForKey:@"data"] allKeys] containsObject:@"title"] && [[[dic objectForKey:@"data"] objectForKey:@"title"] length] >0) {
                muzzikLabel.text = [[dic objectForKey:@"data"] objectForKey:@"title"];
            }
            
            [self suggestViewLayout];
        }
    }
    userInfo *user = [userInfo shareClass];
    if (user.checkSuggest) {
        if ([user.suggestTitle length]>0) {
            muzzikLabel.text = user.suggestTitle;
        }
        
        suggestArray = [[user.playList objectForKey:Constant_userInfo_suggest] objectForKey:UserInfo_muzziks];
        if ([suggestArray count] >= 10) {
            suggestMuzzik = suggestArray[arc4random()%10];
        }else{
            suggestMuzzik = suggestArray[arc4random()%[suggestArray count]];
        }
        
        [suggestArray removeObject:suggestMuzzik];
        [suggestArray insertObject:suggestMuzzik atIndex:0];
        [self suggestViewLayout];
    }else{
        ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/muzzik/suggest",BaseURL]]];
        [request addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"image",[NSNumber numberWithInt:1],Parameter_Limit, nil] Method:GetMethod auth:YES];
        __weak ASIHTTPRequest *weakrequest = request;
        [request setCompletionBlock :^{
            //    NSLog(@"%@",weakrequest.originalURL);
            NSLog(@"%@",[weakrequest responseString]);
            NSData *data = [weakrequest responseData];
            [MuzzikItem addObjectToLocal:data ForKey:Constant_Data_Suggest];
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            if (dic&&[[dic objectForKey:@"muzziks"]count]>0) {
                loadedMuzzik = YES;
                if ([[dic allKeys] containsObject:@"data"] && [[[dic objectForKey:@"data"] allKeys] containsObject:@"title"] && [[[dic objectForKey:@"data"] objectForKey:@"title"] length] >0) {
                    muzzikLabel.text = [[dic objectForKey:@"data"] objectForKey:@"title"];
                }else{
                    muzzikLabel.text = @"本期推荐";
                }
                suggestArray =  [[muzzik new] makeMuzziksByMuzzikArray:[dic objectForKey:@"muzziks"] ];
                if ([suggestArray count] >= 10) {
                    suggestMuzzik = suggestArray[arc4random()%10];
                }else{
                    suggestMuzzik = suggestArray[arc4random()%[suggestArray count]];
                }
                [suggestArray removeObject:suggestMuzzik];
                [suggestArray insertObject:suggestMuzzik atIndex:0];
                [self suggestViewLayout];
            }
        }];
        [request setFailedBlock:^{
            NSLog(@"%@,%@",[weakrequest error],[weakrequest responseString]);
            if (![[weakrequest responseString] length]>0 && [MuzzikItem getDataFromLocalKey: Constant_Data_Suggest]) {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[MuzzikItem getDataFromLocalKey: Constant_Data_Suggest] options:NSJSONReadingMutableContainers error:nil];
                if (dic&&[[dic objectForKey:@"muzziks"]count]>0) {
                    suggestArray = [[muzzik new] makeMuzziksByMuzzikArray:[dic objectForKey:@"muzziks"] ] ;
                    suggestMuzzik = suggestArray[0];
                    [self suggestViewLayout];
                }
            }
            
        }];
        [request startAsynchronous];
        
    }
    
    
    
    
    
}
-(void)suggestViewLayout{
    muzzikImage.layer.cornerRadius = 3;
    muzzikImage.clipsToBounds = YES;
    [muzzikImage setAlpha:0];
    [muzzikImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",BaseURL_image,suggestMuzzik.image,Image_Size_Big]] placeholderImage:[UIImage imageNamed:Image_placeholdImage] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [UIView animateWithDuration:0.5 animations:^{
            [muzzikImage setAlpha:1];
        }];
    }];
    [MainMuzzikView addSubview:muzzikImage];
    
    [headButton removeFromSuperview];
    headButton = [[UIButton alloc] initWithFrame:CGRectMake(16, SCREEN_WIDTH+2, 56, 56)];
    headButton.layer.cornerRadius = 28;
    headButton.layer.borderColor = [UIColor whiteColor].CGColor;
    headButton.layer.borderWidth =2;
    headButton.clipsToBounds = YES;
    [headButton addTarget:self action:@selector(goToUser) forControlEvents:UIControlEventTouchUpInside];
    
    [headButton sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",BaseURL_image,suggestMuzzik.MuzzikUser.avatar,Image_Size_Small]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:Image_user_placeHolder] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [UIView animateWithDuration:0.5 animations:^{
            [headButton setAlpha:1];
        }];
    }];
    [MainMuzzikView addSubview:headButton];
    [userNameLabel removeFromSuperview];
    userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(69, SCREEN_WIDTH+38, SCREEN_WIDTH-140, 17)];
    [userNameLabel setFont:[UIFont boldSystemFontOfSize:Font_size_userName]];
    [userNameLabel setTextColor:Color_Text_1];
    userNameLabel.text = suggestMuzzik.MuzzikUser.name;
    [muzzikView addSubview:userNameLabel];
    [timeStamp removeFromSuperview];
    [timeImage removeFromSuperview];
    timeStamp = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-130, SCREEN_WIDTH+42, 92, 9)];
    [timeStamp setTextColor:Color_Additional_5];
    [timeStamp setFont:[UIFont fontWithName:Font_Next_medium size:9]];
    timeStamp.textAlignment = NSTextAlignmentRight;
    [muzzikView addSubview:timeStamp];
    timeImage = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-34, SCREEN_WIDTH+42, 9, 9)];
    [timeImage setImage:[UIImage imageNamed:Image_timeImage]];
    [muzzikView addSubview:timeImage];
    timeStamp.text = [MuzzikItem transtromTime:suggestMuzzik.date];
    
    [label removeFromSuperview];
    label = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(15, SCREEN_WIDTH+70, SCREEN_WIDTH-46, 500)];
    [label setFont:[UIFont systemFontOfSize:Font_Size_Muzzik_Message]];
    [label setTextColor:Color_Text_2];
    label.text = suggestMuzzik.message;
    CGSize msize = [label sizeThatFits:CGSizeMake(SCREEN_WIDTH-46, 2000)];
    if (msize.height>limitHeight) {
        [label setFrame:CGRectMake(15,  SCREEN_WIDTH+70, SCREEN_WIDTH-46,limitHeight)];
    }else{
        [label setFrame:CGRectMake(15,  SCREEN_WIDTH+70, SCREEN_WIDTH-46,msize.height)];
    }
    
    [muzzikView addSubview:label];
    [musicPlayView removeFromSuperview];
    musicPlayView = [[UIView alloc] initWithFrame:CGRectMake(0, (int)(SCREEN_WIDTH+83+label.frame.size.height), SCREEN_WIDTH, 60)];
    [MainMuzzikView addSubview:musicPlayView];
    progress = [[UIProgressView alloc] initWithFrame:CGRectMake(16, 0, SCREEN_WIDTH-32, 1)];
    [progress setProgress:1];
    [musicPlayView addSubview:progress];
    musicName = [[UILabel alloc] initWithFrame:CGRectMake(78, 11, SCREEN_WIDTH-150, 20)];
    [musicName setFont:[UIFont fontWithName:Font_Next_Bold size:16]];
    musicName.text = suggestMuzzik.music.name;
    [musicPlayView addSubview:musicName];
    UILabel *musicArtist = [[UILabel alloc] initWithFrame:CGRectMake(78, 32, SCREEN_WIDTH-150, 25)];
    [musicArtist setFont:[UIFont fontWithName:Font_Next_Bold size:13]];
    [musicPlayView addSubview:musicArtist];
    musicArtist.text = suggestMuzzik.music.artist;
    likeButton = [[UIButton alloc] initWithFrame:CGRectMake(23, 13, 36, 36)];
    [likeButton addTarget:self action:@selector(moveAction) forControlEvents:UIControlEventTouchUpInside];
    [musicPlayView addSubview:likeButton];
    
    playButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-61, 13, 36, 36)];
    
    [playButton addTarget:self action:@selector(playMusicAction) forControlEvents:UIControlEventTouchUpInside];
    [musicPlayView addSubview:playButton];
    UIColor *color;
    if ([suggestMuzzik.color longLongValue]==1) {
        color = Color_Action_Button_1;
        
        if (suggestMuzzik.ismoved) {
            [likeButton setImage:[UIImage imageNamed:@"redlikedImage"] forState:UIControlStateNormal];
        }else{
            [likeButton setImage:[UIImage imageNamed:@"redlikeImage"] forState:UIControlStateNormal];
        }
        [playButton setImage:[UIImage imageNamed:@"redplayImage"] forState:UIControlStateNormal];
    }
    else if([suggestMuzzik.color longLongValue]==2){
        //bluelikeImage
        color = Color_Action_Button_2;
        if (suggestMuzzik.ismoved) {
            [likeButton setImage:[UIImage imageNamed:@"yellowlikedImage"] forState:UIControlStateNormal];
        }else{
            [likeButton setImage:[UIImage imageNamed:@"yellowlikeImage"] forState:UIControlStateNormal];
        }
        [playButton setImage:[UIImage imageNamed:@"yellowplayImage"] forState:UIControlStateNormal];
    }
    
    else{
        color = Color_Action_Button_3;
        if (suggestMuzzik.ismoved) {
            [likeButton setImage:[UIImage imageNamed:@"bluelikedImage"] forState:UIControlStateNormal];
        }else{
            [likeButton setImage:[UIImage imageNamed:@"bluelikeImage"] forState:UIControlStateNormal];
        }
        [playButton setImage:[UIImage imageNamed:@"blueplayImage"] forState:UIControlStateNormal];
    }
    [progress setTintColor:color];
    [musicArtist setTextColor:color];
    [musicName setTextColor:color];
    muzzikView.frame = CGRectMake(8, 0, SCREEN_WIDTH-16, 145+SCREEN_WIDTH+label.frame.size.height);

    MainMuzzikView.frame = CGRectMake(0, (NSInteger)(348+SCREEN_WIDTH*2/3), SCREEN_WIDTH-16, (NSInteger)(145+SCREEN_WIDTH+label.frame.size.height));
    userView.frame = CGRectMake(8, 16, SCREEN_WIDTH-16, (NSInteger)(58+SCREEN_WIDTH*2/3));
    MainMuzzikView.frame = CGRectMake(0, (NSInteger)(94+SCREEN_WIDTH*2/3), SCREEN_WIDTH-16, MainMuzzikView.frame.size.height);
    topicView.frame = CGRectMake(8, 114+(NSInteger)(SCREEN_WIDTH*2/3+MainMuzzikView.frame.size.height), SCREEN_WIDTH-16, 234);
    [mainScroll setContentSize:CGSizeMake(SCREEN_WIDTH, topicView.frame.origin.y+topicView.frame.size.height+20)];

}

#pragma mark -action
- (void) tappedWithObject:(topicLabel*) sender{
    TopicDetail *topic = [[TopicDetail alloc] init];
    topic.topic_id = sender.tid;
    [self.navigationController pushViewController:topic animated:YES];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
}
-(void)SeeMoreSuggestMuzzik{
    SuggestMuzzikVC *suggsetvc = [[SuggestMuzzikVC alloc]init];
    suggsetvc.viewTittle = muzzikLabel.text;
    suggsetvc.suggestArray = suggestArray;
    [self.navigationController pushViewController:suggsetvc animated:YES];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
}
-(void)goToUser{
    userInfo *user = [userInfo shareClass];
    if ([suggestMuzzik.MuzzikUser.user_id isEqualToString:user.uid]) {
//        UserHomePage *home = [[UserHomePage alloc] init];
//        [self.navigationController pushViewController:home animated:YES];
    }else{
        userDetailInfo *detailuser = [[userDetailInfo alloc] init];
        detailuser.uid = suggestMuzzik.MuzzikUser.user_id;
        [self.navigationController pushViewController:detailuser animated:YES];
        [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    }
}
-(void)moveAction{
    
    userInfo *user = [userInfo shareClass];
    if ([user.token length]>0) {
        suggestMuzzik.ismoved = !suggestMuzzik.ismoved;
        if (suggestMuzzik.ismoved) {
            suggestMuzzik.moveds = [NSString stringWithFormat:@"%d",[suggestMuzzik.moveds intValue]+1 ];
        }else{
            suggestMuzzik.moveds = [NSString stringWithFormat:@"%d",[suggestMuzzik.moveds intValue]-1 ];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:String_MuzzikDataSource_update object:suggestMuzzik];
        ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/muzzik/%@/moved",BaseURL,suggestMuzzik.muzzik_id]]];
        [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:suggestMuzzik.ismoved] forKey:@"ismoved"] Method:PostMethod auth:YES];
        __weak ASIHTTPRequest *weakrequest = requestForm;
        [requestForm setCompletionBlock :^{
            if ([weakrequest responseStatusCode] == 200) {
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
        [userInfo checkLoginWithVC:self];
        [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    }
}

-(void)playMusicAction{
    MuzzikRequestCenter *center = [MuzzikRequestCenter shareClass];
    center.singleMusic = YES;
    [musicPlayer shareClass].listType = suggestList;
    audioPlayerViewController *player = [audioPlayerViewController shareClass];
    player.MusicArray = [NSMutableArray arrayWithArray:suggestArray];
    [player playSongWithSongModel:suggestMuzzik Title:@"推荐歌曲"];
    [MuzzikItem SetUserInfoWithMuzziks:suggestArray title:Constant_userInfo_temp description:@"推荐列表"];
    [self.navigationController pushViewController:player animated:YES];
    
}
-(void) tapForMoreUser{
    ActivityUserVC *activity = [[ActivityUserVC alloc] init];
    activity.viewTittle = userLabel.text;
    [self.navigationController pushViewController:activity animated:YES];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    NSLog(@"user");
}
-(void) tapForMoreTopic{
    TopRankVC *toprank = [[TopRankVC alloc] init];
    [self.navigationController pushViewController:toprank animated:YES];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
}
-(void)playnextMuzzikUpdate{
    Globle *glob = [Globle shareGloble];
    BOOL isPlaying = [[audioPlayerViewController shareClass].playingMuzzik.muzzik_id isEqualToString:suggestMuzzik.muzzik_id]&&!glob.isPause;
    if ([suggestMuzzik.color longLongValue]==1) {
        if (isPlaying) {
            [playButton setImage:[UIImage imageNamed:@"redstopImage"] forState:UIControlStateNormal];
        }else{
            [playButton setImage:[UIImage imageNamed:@"redplayImage"] forState:UIControlStateNormal];
        }
        
    }
    else if([suggestMuzzik.color longLongValue]==2){
        if (isPlaying) {
            [playButton setImage:[UIImage imageNamed:@"yellowstopImage"] forState:UIControlStateNormal];
        }else{
            [playButton setImage:[UIImage imageNamed:@"yellowplayImage"] forState:UIControlStateNormal];
        }
        
    }
    else{
        if (isPlaying) {
            [playButton setImage:[UIImage imageNamed:@"bluestopImage"] forState:UIControlStateNormal];
        }else{
            [playButton setImage:[UIImage imageNamed:@"blueplayImage"] forState:UIControlStateNormal];
        }
        
    }
    
}

-(void)dataSourceUserUpdate:(NSNotification *)notify{
    MuzzikUser *user = notify.object;
    for (UIButton_UserMuzzik *tap in userImageArray) {
        if ([tap.user.user_id isEqualToString:user.user_id]) {
            tap.user.isFollow = user.isFollow;
            tap.user.isFans = user.isFans;
            if (user.isFans &&user.isFollow) {
                [tap setImage:[UIImage imageNamed:Image_recommendfollowedeachother] forState:UIControlStateNormal];
            }else if (user.isFollow){
                [tap setImage:[UIImage imageNamed:Image_recommendfollowed] forState:UIControlStateNormal];
            }else{
                 [tap setImage:[UIImage imageNamed:Image_recommendfollow] forState:UIControlStateNormal];
            }
            break;
        }
    }
}
-(void)dataSourceMuzzikUpdate:(NSNotification *)notify{
    muzzik *tempMuzzik = (muzzik *)notify.object;
    if ([suggestMuzzik.muzzik_id isEqualToString:tempMuzzik.muzzik_id]) {
        suggestMuzzik.ismoved = tempMuzzik.ismoved;
        suggestMuzzik.isReposted = tempMuzzik.isReposted;
        suggestMuzzik.moveds = tempMuzzik.moveds;
        suggestMuzzik.reposts = tempMuzzik.reposts;
        suggestMuzzik.shares = tempMuzzik.shares;
        suggestMuzzik.comments = tempMuzzik.comments;
        UIColor *color ;
        if ([suggestMuzzik.color longLongValue]==1) {
            color = Color_Action_Button_1;
            if (suggestMuzzik.ismoved) {
                [likeButton setImage:[UIImage imageNamed:@"redlikedImage"] forState:UIControlStateNormal];
            }else{
                [likeButton setImage:[UIImage imageNamed:@"redlikeImage"] forState:UIControlStateNormal];
            }
            
            
        }
        else if([suggestMuzzik.color longLongValue]==2){
            //bluelikeImage
            color = Color_Action_Button_2;
            if (suggestMuzzik.ismoved) {
                [likeButton setImage:[UIImage imageNamed:@"yellowlikedImage"] forState:UIControlStateNormal];
            }else{
                [likeButton setImage:[UIImage imageNamed:@"yellowlikeImage"] forState:UIControlStateNormal];
            }
        }
        
        else{
            color = Color_Action_Button_3;
            if (suggestMuzzik.ismoved) {
                [likeButton setImage:[UIImage imageNamed:@"bluelikedImage"] forState:UIControlStateNormal];
            }else{
                [likeButton setImage:[UIImage imageNamed:@"bluelikeImage"] forState:UIControlStateNormal];
            }
        }
    }
    
}

-(void) seeVipUser:(UIButton_UserMuzzik *)button{
    userInfo *user = [userInfo shareClass];
    if ([button.user.user_id isEqualToString:user.uid]) {
        UserHomePage *home = [[UserHomePage alloc] init];
        [self.navigationController pushViewController:home animated:YES];
        [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    }else{
        userDetailInfo *detailuser = [[userDetailInfo alloc] init];
        detailuser.uid = button.user.user_id;
        [self.navigationController pushViewController:detailuser animated:YES];
        [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    }
}
-(void)follwUser:(UIButton_UserMuzzik *)button{
    userInfo *user = [userInfo shareClass];
    if ([user.token length]>0) {
        
        if ([button.followType isEqualToString:@"0"]) {
            button.user.isFollow = YES;
            button.followType = @"1";
            [[NSNotificationCenter defaultCenter] postNotificationName:String_UserDataSource_update object:button.user];
            ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_User_Follow]]];
            [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:button.user.user_id forKey:@"_id"] Method:PostMethod auth:YES];
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

            }];
            [requestForm startAsynchronous];
            
        }
        else{
            button.user.isFollow = NO;
            button.followType = @"0";
            
            [[NSNotificationCenter defaultCenter] postNotificationName:String_UserDataSource_update object:button.user];
            ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_user_Unfollow]]];
            [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:button.user.user_id forKey:@"_id"] Method:PostMethod auth:YES];
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
            }];
            [requestForm startAsynchronous];
        }
    }
    
}
@end
