//
//  NotificationVC.m
//  muzzik
//
//  Created by muzzik on 15/5/4.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "NotificationVC.h"
#import "NotifyObject.h"
#import "NotifyFollowCell.h"
#import "NotifyMuzzikCell.h"
#import "UIButton+WebCache.h"
#import "userDetailInfo.h"
#import "DetaiMuzzikVC.h"
#import "UIImageView+WebCache.h"
#import "searchViewController.h"
@interface NotificationVC ()<UITableViewDataSource,UITableViewDelegate,CellDelegate>{
    UITableView *notifyTabelView;
    NSMutableArray *notifyArray;
    NSMutableDictionary *RefreshDic;
    NSString *errorStatus;
    NSData *redisData;
    NSString *requestDtring;
    NSDictionary *requestDic;
    NSString *lastId;
    UIView *footView;
    UIView *footTapView;
    UILabel *footLabel;
    UIActivityIndicatorView *indicator;
}

@end

@implementation NotificationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    RefreshDic = [NSMutableDictionary dictionary];
    [[MuzzikObject shareClass].notifyBUtton setHidden:YES];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteMuzzik:) name:String_Muzzik_Delete object:nil];
    [self initNagationBar:self.title leftBtn:Constant_backImage rightBtn:0];
    notifyTabelView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
    notifyTabelView.delegate = self;
    notifyTabelView.dataSource = self;
    [self.view addSubview:notifyTabelView];
    [self followScrollView:notifyTabelView];
    notifyTabelView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [notifyTabelView registerClass:[NotifyFollowCell class] forCellReuseIdentifier:@"NotifyFollowCell"];
    [notifyTabelView registerClass:[NotifyMuzzikCell class] forCellReuseIdentifier:@"NotifyMuzzikCell"];
    footView  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 60)];
    footTapView = [[UIView alloc] initWithFrame:CGRectMake(23, 10, SCREEN_WIDTH-46, 30)];
    footTapView.backgroundColor = Color_line_2;
    footTapView.layer.cornerRadius = 5;
    footTapView.clipsToBounds = YES;
    footTapView.layer.borderColor = Color_line_1.CGColor;
    [footTapView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(getHistoryNotification)]];
    footTapView.layer.borderWidth = 1.0f;
    indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(footTapView.frame.size.width/2-52, 8, 14, 14)];
    [indicator setColor:Color_Additional_5];
    footLabel = [[UILabel alloc] initWithFrame:CGRectMake(footTapView.frame.size.width/2-40, 5, 80, 20)];
    [footLabel setText:@"查看更多"];
    [footLabel setFont:[UIFont systemFontOfSize:13]];
    footLabel.textAlignment = NSTextAlignmentCenter;
    [footLabel setTextColor:Color_Additional_5];
    [footTapView addSubview:footLabel];
    [footView addSubview:footTapView];
    
    [self loadDataMessage];
}
-(void)tapAction:(UITapGestureRecognizer *)tap{
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    searchViewController *search = [[searchViewController alloc ] init];
    [self.navigationController pushViewController:search animated:YES];
}
-(void)startLoading{
    footTapView.userInteractionEnabled = NO;
    [footLabel setText:@"正在加载..."];
    [footTapView addSubview:indicator];
    [indicator startAnimating];
}

-(void)endLoading{
    footTapView.userInteractionEnabled = YES;
    [indicator stopAnimating];
    [footLabel setText:@"查看更多"];
    [indicator removeFromSuperview];
}
-(void)getHistoryNotification{
    [self startLoading];
    userInfo *user = [userInfo shareClass];
    
    if (self.notifyType == Notification_comment) {
        
        requestDic = [NSDictionary dictionaryWithObjectsAndKeys:lastId,Parameter_from,@"comment",@"type",user.token,@"token", nil];
    }else if (self.notifyType == Notification_at) {
        
        requestDic = [NSDictionary dictionaryWithObjectsAndKeys:lastId,Parameter_from,@"at",@"type",user.token,@"token", nil];
    }else if (self.notifyType == Notification_moved) {
        
        requestDic = [NSDictionary dictionaryWithObjectsAndKeys:lastId,Parameter_from,@"moved",@"type",user.token,@"token", nil];
    }else if (self.notifyType == Notification_follow) {
        
        requestDic = [NSDictionary dictionaryWithObjectsAndKeys:lastId,Parameter_from,@"follow",@"type",user.token,@"token", nil];
    }else if (self.notifyType == Notification_repost) {
        
        requestDic = [NSDictionary dictionaryWithObjectsAndKeys:lastId,Parameter_from,@"repost",@"type",user.token,@"token", nil];
    }else if (self.notifyType == Notification_participation) {
        requestDic = [NSDictionary dictionaryWithObjectsAndKeys:lastId,Parameter_from,@"participate_topic",@"type",user.token,@"token", nil];
    }
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"http://117.121.26.174:8000/api/notify"]]];
    [request addBodyDataSourceWithJsonByDic:requestDic Method:GetMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = request;
    [request setCompletionBlock :^{
        //    NSLog(@"%@",weakrequest.originalURL);
        NSLog(@"%@",[weakrequest responseString]);
        NSData *data = [weakrequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (dic) {
           
            [notifyArray addObjectsFromArray:[[NotifyObject new] makeMuzziksByNotifyArray:[dic objectForKey:@"notifies"]]];
            NotifyObject *notifyobj = [notifyArray lastObject];
            lastId = notifyobj.notify_id;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self endLoading];
                [notifyTabelView reloadData];
                
                if ([[dic objectForKey:@"notifies"] count] == 0 ) {
                    [notifyTabelView removeFooter];
                }else{
                    [notifyTabelView addFooterWithTarget:self action:@selector(refreshFooter)];
                }
                [notifyTabelView setTableFooterView:nil];
            });
        }
    }];
    [request setFailedBlock:^{
        if (![[weakrequest responseString] length]>0) {
             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                 [self endLoading];
             });

        }
        NSLog(@"%@,%@",[weakrequest error],[weakrequest responseString]);
        
        
        
    }];
    [request startAsynchronous];
}
-(void)loadDataMessage{
     userInfo *user = [userInfo shareClass];
    if (self.numOfNewNotification == 0) {
        if ([user.token length]>0) {
            if (self.notifyType == Notification_comment) {
                redisData = [MuzzikItem getDataFromLocalKey:[NSString stringWithFormat:@"user_Notify_comment%@",user.uid]];
                requestDic = [NSDictionary dictionaryWithObjectsAndKeys:Limit_Constant,Parameter_Limit,@"comment",@"type",user.token,@"token", nil];
            }else if (self.notifyType == Notification_at) {
                redisData = [MuzzikItem getDataFromLocalKey:[NSString stringWithFormat:@"user_Notify_at%@",user.uid]];
                 requestDic = [NSDictionary dictionaryWithObjectsAndKeys:Limit_Constant,Parameter_Limit,@"at",@"type",user.token,@"token", nil];
            }else if (self.notifyType == Notification_moved) {
                redisData = [MuzzikItem getDataFromLocalKey:[NSString stringWithFormat:@"user_Notify_moved%@",user.uid]];
                 requestDic = [NSDictionary dictionaryWithObjectsAndKeys:Limit_Constant,Parameter_Limit,@"moved",@"type",user.token,@"token", nil];
            }else if (self.notifyType == Notification_follow) {
                redisData = [MuzzikItem getDataFromLocalKey:[NSString stringWithFormat:@"user_Notify_follow%@",user.uid]];
                requestDic = [NSDictionary dictionaryWithObjectsAndKeys:Limit_Constant,Parameter_Limit,@"follow",@"type",user.token,@"token", nil];
            }else if (self.notifyType == Notification_repost) {
                redisData = [MuzzikItem getDataFromLocalKey:[NSString stringWithFormat:@"user_Notify_repost%@",user.uid]];
                requestDic = [NSDictionary dictionaryWithObjectsAndKeys:Limit_Constant,Parameter_Limit,@"repost",@"type",user.token,@"token", nil];
            }else if (self.notifyType == Notification_participation) {
                redisData = [MuzzikItem getDataFromLocalKey:[NSString stringWithFormat:@"user_Notify_participation%@",user.uid]];
                requestDic = [NSDictionary dictionaryWithObjectsAndKeys:Limit_Constant,Parameter_Limit,@"participate_topic",@"type",user.token,@"token", nil];
            }
            if (redisData) {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:redisData options:NSJSONReadingMutableContainers error:nil];
                if (dic) {
                    notifyArray = [[NotifyObject new] makeMuzziksByNotifyArray:[dic objectForKey:@"notifies"]];
                    NotifyObject *notifyobj = [notifyArray lastObject];
                    lastId = notifyobj.notify_id;
                    [notifyTabelView addFooterWithTarget:self action:@selector(refreshFooter)];
                    [notifyTabelView reloadData];
                    
                }
            }else{
                ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"http://117.121.26.174:8000/api/notify"]]];
                [request addBodyDataSourceWithJsonByDic:requestDic Method:GetMethod auth:YES];
                __weak ASIHTTPRequest *weakrequest = request;
                [request setCompletionBlock :^{
                    //    NSLog(@"%@",weakrequest.originalURL);
                    NSLog(@"%@",[weakrequest responseString]);
                    NSData *data = [weakrequest responseData];
                    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                    if (dic) {
                        if (self.notifyType == Notification_comment) {
                            [MuzzikItem addObjectToLocal:data ForKey:[NSString stringWithFormat:@"user_Notify_comment%@",user.uid]];
                            
                        }else if (self.notifyType == Notification_at) {
                            [MuzzikItem addObjectToLocal:data ForKey:[NSString stringWithFormat:@"user_Notify_at%@",user.uid]];
                        }else if (self.notifyType == Notification_moved) {
                            [MuzzikItem addObjectToLocal:data ForKey:[NSString stringWithFormat:@"user_Notify_moved%@",user.uid]];
                        }else if (self.notifyType == Notification_follow) {
                            [MuzzikItem addObjectToLocal:data ForKey:[NSString stringWithFormat:@"user_Notify_follow%@",user.uid]];
                        }else if (self.notifyType == Notification_repost) {
                            [MuzzikItem addObjectToLocal:data ForKey:[NSString stringWithFormat:@"user_Notify_repost%@",user.uid]];
                        }else if (self.notifyType == Notification_participation) {
                            [MuzzikItem addObjectToLocal:data ForKey:[NSString stringWithFormat:@"user_Notify_participation%@",user.uid]];
                        }
                        notifyArray = [[NotifyObject new] makeMuzziksByNotifyArray:[dic objectForKey:@"notifies"]];
                        NotifyObject *notifyobj = [notifyArray lastObject];
                        lastId = notifyobj.notify_id;
                        
                        [notifyTabelView reloadData];
                        
                        if (notifyArray.count > 0) {
                            [notifyTabelView addFooterWithTarget:self action:@selector(refreshFooter)];
                        }
                    }
                }];
                [request setFailedBlock:^{
                    if (![[weakrequest responseString] length]>0) {
                        errorStatus = @"history";
                        [self networkErrorShow];
                    }
                    NSLog(@"%@,%@",[weakrequest error],[weakrequest responseString]);
                    
                    
                    
                }];
                [request startAsynchronous];
            }
        }
    }else{
        NSDictionary *requestNumDic;
        if (self.notifyType == Notification_comment) {
            requestNumDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%ld",self.numOfNewNotification],Parameter_Limit,@"comment",@"type",user.token,@"token", nil];
            [MuzzikItem addObjectToLocal:nil ForKey:[NSString stringWithFormat:@"user_Notify_comment%@",user.uid]];

        }else if (self.notifyType == Notification_at) {
            requestNumDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%ld",self.numOfNewNotification],Parameter_Limit,@"at",@"type",user.token,@"token", nil];
            [MuzzikItem addObjectToLocal:nil ForKey:[NSString stringWithFormat:@"user_Notify_at%@",user.uid]];
        }else if (self.notifyType == Notification_moved) {
            [MuzzikItem addObjectToLocal:nil ForKey:[NSString stringWithFormat:@"user_Notify_moved%@",user.uid]];
            requestNumDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%ld",self.numOfNewNotification],Parameter_Limit,@"moved",@"type",user.token,@"token", nil];
        }else if (self.notifyType == Notification_follow) {
            [MuzzikItem addObjectToLocal:nil ForKey:[NSString stringWithFormat:@"user_Notify_follow%@",user.uid]];
            requestNumDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%ld",self.numOfNewNotification],Parameter_Limit,@"follow",@"type",user.token,@"token", nil];
        }else if (self.notifyType == Notification_repost) {
            [MuzzikItem addObjectToLocal:nil ForKey:[NSString stringWithFormat:@"user_Notify_repost%@",user.uid]];
            requestNumDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%ld",self.numOfNewNotification],Parameter_Limit,@"repost",@"type",user.token,@"token", nil];
        }else if (self.notifyType == Notification_participation) {
            [MuzzikItem addObjectToLocal:nil ForKey:[NSString stringWithFormat:@"user_Notify_participation%@",user.uid]];
            requestNumDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%ld",self.numOfNewNotification],Parameter_Limit,@"participate_topic",@"type",user.token,@"token", nil];
        }
        ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"http://117.121.26.174:8000/api/notify"]]];
        [request addBodyDataSourceWithJsonByDic:requestNumDic Method:GetMethod auth:YES];
        __weak ASIHTTPRequest *weakrequest = request;
        [request setCompletionBlock :^{
            //    NSLog(@"%@",weakrequest.originalURL);
            NSLog(@"%@",[weakrequest responseString]);
            NSData *data = [weakrequest responseData];
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            if (dic) {
                //  [MuzzikItem addObjectToLocal:data ForKey:Constant_Data_notify];
                notifyArray = [[NotifyObject new] makeMuzziksByNotifyArray:[dic objectForKey:@"notifies"]];
                NotifyObject *notifyobj = [notifyArray lastObject];
                lastId = notifyobj.notify_id;
                [notifyTabelView reloadData];
                if (self.notifyType == Notification_comment) {
                    user.notificationNumReply = 0;
                }else if (self.notifyType == Notification_at) {
                    user.notificationNumMetion = 0;
                }else if (self.notifyType == Notification_moved) {
                    user.notificationNumMoved = 0;
                }else if (self.notifyType == Notification_follow) {
                    user.notificationNumFollow = 0;
                }else if (self.notifyType == Notification_repost) {
                    user.notificationNumRepost = 0;
                }else if (self.notifyType == Notification_participation) {
                    user.notificationNumParticipationTopic = 0;
                }
                NSMutableDictionary *notifyDic = [NSMutableDictionary dictionary];
                [notifyDic setObject:[NSNumber numberWithInteger:user.notificationNumReply] forKey:@"comment"];
                [notifyDic setObject:[NSNumber numberWithInteger:user.notificationNumRepost] forKey:@"repost"];
                [notifyDic setObject:[NSNumber numberWithInteger:user.notificationNumMetion] forKey:@"at"];
                [notifyDic setObject:[NSNumber numberWithInteger:user.notificationNumFollow] forKey:@"follow"];
                [notifyDic setObject:[NSNumber numberWithInteger:user.notificationNumMoved] forKey:@"moved"];
                [notifyDic setObject:[NSNumber numberWithInteger:user.notificationNumParticipationTopic] forKey:@"participate_topic"];
                [MuzzikItem addObjectToLocal:[notifyDic copy] ForKey:Notification_Number_Dictionary];
                
                [notifyTabelView setTableFooterView:footView];
            }
        }];
        [request setFailedBlock:^{
            if (![[weakrequest responseString] length]>0) {
                errorStatus = @"new";
                [self networkErrorShow];
            }
            NSLog(@"%@,%@",[weakrequest error],[weakrequest responseString]);
            
            
            
        }];
        [request startAsynchronous];
    }
   
}
-(void)reloadDataSource{
    [super reloadDataSource];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self loadDataMessage];
    });
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [notifyTabelView reloadData];
    [self.rdv_tabBarController setTabBarHidden:NO animated:YES];
    // MytableView add
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];

}

-(void) refreshFooter{
    userInfo *user = [userInfo shareClass];
    if (self.notifyType == Notification_comment) {

        requestDic = [NSDictionary dictionaryWithObjectsAndKeys:lastId,Parameter_from,@"comment",@"type",user.token,@"token", nil];
    }else if (self.notifyType == Notification_at) {

        requestDic = [NSDictionary dictionaryWithObjectsAndKeys:lastId,Parameter_from,@"at",@"type",user.token,@"token", nil];
    }else if (self.notifyType == Notification_moved) {

        requestDic = [NSDictionary dictionaryWithObjectsAndKeys:lastId,Parameter_from,@"moved",@"type",user.token,@"token", nil];
    }else if (self.notifyType == Notification_follow) {

        requestDic = [NSDictionary dictionaryWithObjectsAndKeys:lastId,Parameter_from,@"follow",@"type",user.token,@"token", nil];
    }else if (self.notifyType == Notification_repost) {

        requestDic = [NSDictionary dictionaryWithObjectsAndKeys:lastId,Parameter_from,@"repost",@"type",user.token,@"token", nil];
    }else if (self.notifyType == Notification_participation) {
        requestDic = [NSDictionary dictionaryWithObjectsAndKeys:lastId,Parameter_from,@"participate_topic",@"type",user.token,@"token", nil];
    }
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"http://117.121.26.174:8000/api/notify"]]];
    [request addBodyDataSourceWithJsonByDic:requestDic Method:GetMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = request;
    [request setCompletionBlock :^{
        //    NSLog(@"%@",weakrequest.originalURL);
        NSLog(@"%@",[weakrequest responseString]);
        NSData *data = [weakrequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (dic) {
            [notifyArray addObjectsFromArray:[[NotifyObject new] makeMuzziksByNotifyArray:[dic objectForKey:@"notifies"]]];
            NotifyObject *notifyobj = [notifyArray lastObject];
            lastId = notifyobj.notify_id;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [notifyTabelView footerEndRefreshing];
                [notifyTabelView reloadData];
                
                if ([[dic objectForKey:@"notifies"] count]<1 ) {
                    [notifyTabelView removeFooter];
                }
            });
        }
    }];
    [request setFailedBlock:^{
        if (![[weakrequest responseString] length]>0) {
            errorStatus = @"history";
            [self networkErrorShow];
        }
        NSLog(@"%@,%@",[weakrequest error],[weakrequest responseString]);
        
        
        
    }];
    [request startAsynchronous];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return notifyArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NotifyObject *tempNotify = [notifyArray objectAtIndex:indexPath.row];
    NSLog(@"%d",[tempNotify.type isEqualToString:@"friend_exists"]);
    if ([tempNotify.type isEqualToString:@"follow"] ||[tempNotify.type isEqualToString:@"friend_registered"] || [tempNotify.type isEqualToString:@"friend_exists"]) {
      NotifyFollowCell*  cell = [tableView dequeueReusableCellWithIdentifier:@"NotifyFollowCell" forIndexPath:indexPath];
        if (tempNotify.readed) {
            [cell.preImage setImage:[UIImage imageNamed:Image_notifollowclickImage]];
        }else{
            [cell.preImage setImage:[UIImage imageNamed:Image_notifollowImage]];
        }
        [cell.headImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",BaseURL_image,tempNotify.user.avatar,Image_Size_Small]] placeholderImage:[UIImage imageNamed:Image_user_placeHolder] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (![[RefreshDic allKeys] containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]) {
                [RefreshDic setObject:indexPath forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
                [cell.headImage setAlpha:0];
                [UIView animateWithDuration:0.5 animations:^{
                    [cell.headImage setAlpha:1];
                }];
            }
            
            
        }];
        cell.user_id = tempNotify.user.user_id;
        cell.nameLabel.attributedText = [self creatTextByName:tempNotify.user.name Date:tempNotify.date];
        if ([tempNotify.type isEqualToString:@"follow"]) {
            cell.message.text = @"关注了你";
        }else if ([tempNotify.type isEqualToString:@"friend_registered"]) {
            cell.message.text = @"微博好友加入了Muzzik";
        }else if ([tempNotify.type isEqualToString:@"friend_exists"]) {
            cell.message.text = @"微博好友在Muzzik里等候你好久好久了....";
        }
       return cell;
    }else{
        NotifyMuzzikCell*  cell = [tableView dequeueReusableCellWithIdentifier:@"NotifyMuzzikCell" forIndexPath:indexPath];
        if (!tempNotify.readed) {
            if ([tempNotify.type isEqualToString:@"moved"]) {
                [cell.preImage setImage:[UIImage imageNamed:Image_notilikeImage]];
            }else if([tempNotify.type isEqualToString:@"repost"]){
                [cell.preImage setImage:[UIImage imageNamed:Image_notiretweetImage]];
            }else if([tempNotify.type isEqualToString:@"comment"] || [tempNotify.type isEqualToString:@"at"]){
                [cell.preImage setImage:[UIImage imageNamed:Image_notireplyImage]];
            }else if([tempNotify.type isEqualToString:@"participate_topic"]){
                [cell.preImage setImage:[UIImage imageNamed:Image_notitopicImage]];
            }
        }else{
            if ([tempNotify.type isEqualToString:@"moved"]) {
                [cell.preImage setImage:[UIImage imageNamed:Image_notilikeclickImage]];
            }else if([tempNotify.type isEqualToString:@"repost"]){
                [cell.preImage setImage:[UIImage imageNamed:Image_notiretweetclickImage]];
            }else if([tempNotify.type isEqualToString:@"comment"] || [tempNotify.type isEqualToString:@"at"]){
                [cell.preImage setImage:[UIImage imageNamed:Image_notireplyclickImage]];
            }else if([tempNotify.type isEqualToString:@"participate_topic"]){
                [cell.preImage setImage:[UIImage imageNamed:Image_notitopicclickImage]];
            }
        }

        [cell.headImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",BaseURL_image,tempNotify.user.avatar,Image_Size_Small]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:Image_user_placeHolder] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (![[RefreshDic allKeys] containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]) {
                [RefreshDic setObject:indexPath forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
                [cell.headImage setAlpha:0];
                [UIView animateWithDuration:0.5 animations:^{
                    [cell.headImage setAlpha:1];
                }];
            }
            
            
        }];
        cell.user_id = tempNotify.user.user_id;
        cell.nameLabel.attributedText = [self creatTextByName:tempNotify.user.name Date:tempNotify.date];
        cell.delegate = self;
        if ([tempNotify.type isEqualToString:@"moved"]) {
            cell.message.text = @"喜欢了这条Muzzik";
        }else if([tempNotify.type isEqualToString:@"repost"]){
            cell.message.text = @"转发了这条Muzzik";
        }else if([tempNotify.type isEqualToString:@"comment"]){
            cell.message.text = @"回复了你的Muzzik";
        }else if([tempNotify.type isEqualToString:@"at"]){
             cell.message.text = @"提到了你";
        }else if([tempNotify.type isEqualToString:@"participate_topic"]){
            cell.message.text = @"参与了你发起的话题";
        }
        UIColor *color;
        if ([tempNotify.muzzik.color intValue]==1) {
            color = Color_Action_Button_1;
        }else if ([tempNotify.muzzik.color intValue]==2){
            color = Color_Action_Button_2;
        }else{
            color = Color_Action_Button_3;
        }
        cell.commentLabel.text = tempNotify.muzzik.message;
        cell.songname.text = tempNotify.muzzik.music.name;
        cell.artist.text = tempNotify.muzzik.music.artist;
        [cell.songname setTextColor:color];
        [cell.artist setTextColor:color];
        return cell;

    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NotifyObject *tempNotify = [notifyArray objectAtIndex:indexPath.row];
    tempNotify.readed = YES;
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Read_Notify]]];
    [request addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:tempNotify.notify_id,@"_id", nil] Method:PostMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = request;
    [request setCompletionBlock :^{
    }];
    [request setFailedBlock:^{
        NSLog(@"%@,%@",[weakrequest error],[weakrequest responseString]);
    }];
    [request startAsynchronous];
    if ([tempNotify.type isEqualToString:@"follow"] ||[tempNotify.type isEqualToString:@"friend_registered"] || [tempNotify.type isEqualToString:@"friend_exists"]) {
        userInfo *user = [userInfo shareClass];
        if ([tempNotify.user.user_id isEqualToString:user.uid]) {
            UserHomePage *home = [[UserHomePage alloc] init];
            [self.navigationController pushViewController:home animated:YES];
        }else{
            userDetailInfo *detailuser = [[userDetailInfo alloc] init];
            detailuser.uid = tempNotify.user.user_id;
            [self.navigationController pushViewController:detailuser animated:YES];
        }
    }else{
        muzzik *tempMuzzik = tempNotify.muzzik;
        DetaiMuzzikVC *detail = [[DetaiMuzzikVC alloc] init];
        detail.muzzik_id = tempMuzzik.muzzik_id;
        [self.navigationController pushViewController:detail animated:YES];
    }
   
}
-(void)deleteMuzzik:(NSNotification *)notify{
    muzzik *localMzzik = notify.object;
    for (NotifyObject *tempMuzzik in notifyArray) {
        if ([tempMuzzik.muzzik.muzzik_id isEqualToString:localMzzik.muzzik_id]) {
            [notifyArray removeObject:tempMuzzik];
            [notifyTabelView reloadData];
            break;
        }
    }
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
     NotifyObject *tempNotify = [notifyArray objectAtIndex:indexPath.row];
    if ([tempNotify.type isEqualToString:@"follow"] ||[tempNotify.type isEqualToString:@"friend_registered"] || [tempNotify.type isEqualToString:@"friend_exists"]) {
        return 72.0;
    }else{
        return 152;
    }
}
-(NSMutableAttributedString *)creatTextByName:(NSString *)name Date:(double)date{
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] init];
    NSString *itemStr = name;
    NSAttributedString *item = [MuzzikItem formatAttrItem:itemStr color:Color_Text_1  font:[UIFont fontWithName:Font_Next_DemiBold size:16]];
    [text appendAttributedString:item];
    NSString *itemStr1 = [NSString stringWithFormat:@"    %@",[MuzzikItem transtromTimeWithNum:date]];
    NSAttributedString *item1 = [MuzzikItem formatAttrItem:itemStr1 color:Color_Additional_5  font:[UIFont systemFontOfSize:9]];
    [text appendAttributedString:item1];
    return  text;
}
-(void)userDetail:(NSString *)user_id{
    userInfo *user = [userInfo shareClass];
    if ([user_id isEqualToString:user.uid]) {
        UserHomePage *home = [[UserHomePage alloc] init];
        [self.navigationController pushViewController:home animated:YES];
    }else{
        userDetailInfo *detailuser = [[userDetailInfo alloc] init];
        detailuser.uid = user_id;
        [self.navigationController pushViewController:detailuser animated:YES];
    }
}

@end
