//
//  NotificationCenterViewController.m
//  muzzik
//
//  Created by muzzik on 15/9/7.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "NotificationCenterViewController.h"
#import "NotifyObject.h"
#import "NotificationCategoryCell.h"
#import "NotificationVC.h"
#import "RDVTabBarController.h"
#import "searchViewController.h"
#import <RongIMLib/RongIMLib.h>
#import "showUsersVC.h"

@interface NotificationCenterViewController ()<UITableViewDataSource,UITableViewDelegate>{
    UITableView *notifyTabelView;
    NSMutableArray *notifyArray;
    NSInteger page;
    NSMutableDictionary *notifyDic;
}

@end

@implementation NotificationCenterViewController
#pragma mark view_lifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    page = 1;
    self.hidesBottomBarWhenPushed=YES;
    notifyArray = [NSMutableArray array];
    [[MuzzikObject shareClass].notifyBUtton setHidden:YES];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
     [self initNagationBar:@"消息" leftBtn:8 rightBtn:13];
    notifyTabelView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
    notifyTabelView.delegate = self;
    notifyTabelView.dataSource = self;
     [notifyTabelView registerClass:[NotificationCategoryCell class] forCellReuseIdentifier:@"NotificationCategoryCell"];
    [self.view addSubview:notifyTabelView];
    [self followScrollView:notifyTabelView];
    notifyTabelView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self loadLocalMessage];
    [self checkNewNotification];
    if (self.rdv_tabBarController.tabBar.translucent) {
        UIEdgeInsets insets = UIEdgeInsetsMake(0,
                                               0,
                                               CGRectGetHeight(self.rdv_tabBarController.tabBar.frame),
                                               0);
        
        notifyTabelView.contentInset = insets;
        notifyTabelView.scrollIndicatorInsets = insets;
        RCIMClient *client = [RCIMClient sharedRCIMClient];
        NSArray *conversationList = [client
                                     getConversationList:@[@(ConversationType_PRIVATE),
                                                           @(ConversationType_DISCUSSION),
                                                           @(ConversationType_GROUP),
                                                           @(ConversationType_SYSTEM),
                                                           @(ConversationType_APPSERVICE),
                                                           @(ConversationType_PUBLICSERVICE)]];
        NSLog(@"%@",conversationList);
    }
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteMuzzik:) name:String_Muzzik_Delete object:nil];
    
    // Do any additional setup after loading the view.
    //120480220855
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:NO animated:YES];
    [self checkNewNotification];
    [notifyTabelView reloadData];
}
-(void)dealloc{
    userInfo *user = [userInfo shareClass];
    user.notificationNumMovedNew = NO;
    user.notificationNumParticipationTopicNew = NO;
    user.notificationNumReplyNew = NO;
    user.notificationNumRepostNew = NO;
    user.notificationNumFollowNew = NO;
    user.notificationNumMetionNew = NO;
}
-(void)checkNewNotification{
    userInfo *user = [userInfo shareClass];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_New_notify_Now]]];
    [request addBodyDataSourceWithJsonByDic:nil Method:GetMethod auth:YES];
    __weak ASIHTTPRequest *weakrequest = request;
    [request setCompletionBlock :^{
        NSData *data = [weakrequest responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (dic && [[dic allKeys] containsObject:@"result"] && [[dic objectForKey:@"result"] integerValue]>0) {
            
            user.notificationNumTotal = [[dic objectForKey:@"result"] integerValue];
            [self loadDataMessageFull:NO];
        }
    }];
    [request setFailedBlock:^{
        NSLog(@"%@",[weakrequest error]);
        [self networkErrorShow];
    }];
    [request startAsynchronous];
}
-(void)reloadDataSource{
    [super reloadDataSource];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self checkNewNotification];
    });
    
    
}
-(void)tapAction:(UITapGestureRecognizer *)tap{
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    searchViewController *search = [[searchViewController alloc ] init];
    [self.navigationController pushViewController:search animated:YES];
}
#pragma mark tableView_DelegateMethod

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 6;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NotificationCategoryCell*  cell = [tableView dequeueReusableCellWithIdentifier:@"NotificationCategoryCell" forIndexPath:indexPath];
    userInfo *user = [userInfo shareClass];
    if (indexPath.row == 0) {
        [cell.titleImage setImage:[UIImage imageNamed:@"noti_reply"]];
        cell.decriptionLabel.text = @"他们回复了你的Muzzik";
        cell.badgeImage.isNew = user.notificationNumReplyNew;
        cell.badgeImage.badgeNum = user.notificationNumReply;
        
    }
    else if (indexPath.row == 1) {
        [cell.titleImage setImage:[UIImage imageNamed:@"noti_at"]];
        cell.decriptionLabel.text = @"他们提到了你";
        cell.badgeImage.isNew = user.notificationNumMetionNew;
        cell.badgeImage.badgeNum = user.notificationNumMetion;
        
    }
    else if (indexPath.row == 2) {
        [cell.titleImage setImage:[UIImage imageNamed:@"noti_follow"]];
        cell.decriptionLabel.text = @"他们关注了你";
        cell.badgeImage.isNew = user.notificationNumFollowNew;
        cell.badgeImage.badgeNum = user.notificationNumFollow;
        
    }
    else if (indexPath.row == 3) {
        [cell.titleImage setImage:[UIImage imageNamed:@"noti_like"]];
        cell.decriptionLabel.text = @"他们喜欢了你的Muzzik";
        cell.badgeImage.isNew = user.notificationNumMovedNew;
        cell.badgeImage.badgeNum = user.notificationNumMoved;
        
    }
    else if (indexPath.row == 4) {
        [cell.titleImage setImage:[UIImage imageNamed:@"noti_retweet"]];
        cell.decriptionLabel.text = @"他们转发了你的Muzzik";
        cell.badgeImage.isNew = user.notificationNumRepostNew;
        cell.badgeImage.badgeNum = user.notificationNumRepost;
        
    }
    else {
        [cell.titleImage setImage:[UIImage imageNamed:@"noti_topic"]];
        cell.decriptionLabel.text = @"他们参与了你的话题";
         cell.badgeImage.isNew = user.notificationNumParticipationTopicNew;
        cell.badgeImage.badgeNum = user.notificationNumParticipationTopic;
       
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NotificationVC *notifyvc = [[NotificationVC alloc] init];
    userInfo *user = [userInfo shareClass];
    if (indexPath.row == 0) {
        notifyvc.title = @"他们回复了你的Muzzik";
        notifyvc.notifyType = Notification_comment;
        notifyvc.numOfNewNotification = user.notificationNumReply;
        user.notificationNumReplyNew = NO;
    }else if (indexPath.row == 1) {
        notifyvc.title = @"他们提到了你";
        notifyvc.notifyType = Notification_at;
        notifyvc.numOfNewNotification = user.notificationNumMetion;
        user.notificationNumMetionNew = NO;
    }else if (indexPath.row == 2) {
        notifyvc.title = @"他们关注了你";
        notifyvc.notifyType = Notification_follow;
        notifyvc.numOfNewNotification = user.notificationNumFollow;
        user.notificationNumFollowNew = NO;
    }else if (indexPath.row == 3) {
        notifyvc.title = @"他们喜欢了你的Muzzik";
        notifyvc.notifyType = Notification_moved;
        notifyvc.numOfNewNotification = user.notificationNumMoved;
        user.notificationNumMovedNew = NO;
    }else if (indexPath.row == 4) {
        notifyvc.title = @"他们转发了你的Muzzik";
        notifyvc.notifyType = Notification_repost;
        notifyvc.numOfNewNotification = user.notificationNumRepost;
        user.notificationNumRepostNew = NO;
    }else if (indexPath.row == 5) {
        notifyvc.title = @"他们参与了你的话题";
        notifyvc.notifyType = Notification_participation;
        notifyvc.numOfNewNotification = user.notificationNumParticipationTopic;
        user.notificationNumParticipationTopicNew = NO;
    }
    [self.navigationController pushViewController:notifyvc animated:YES];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];    
}
/**
 *  读取本地持久化数据，设置每个通知类型的个数;
 */
-(void)loadLocalMessage{
    notifyDic = [[MuzzikItem getDictionaryFromLocalForKey:Notification_Number_Dictionary] mutableCopy];
    if (!notifyDic) {
        notifyDic = [NSMutableDictionary dictionary];
        [notifyDic setObject:[NSNumber numberWithInteger:0] forKey:@"comment"];
        [notifyDic setObject:[NSNumber numberWithInteger:0] forKey:@"repost"];
        [notifyDic setObject:[NSNumber numberWithInteger:0] forKey:@"at"];
        [notifyDic setObject:[NSNumber numberWithInteger:0] forKey:@"follow"];
        [notifyDic setObject:[NSNumber numberWithInteger:0] forKey:@"moved"];
        [notifyDic setObject:[NSNumber numberWithInteger:0] forKey:@"participate_topic"];
    }
    userInfo *user = [userInfo shareClass];
    user.notificationNumReply = [notifyDic[@"comment"] integerValue];
    user.notificationNumRepost = [notifyDic[@"repost"] integerValue];
    user.notificationNumMetion = [notifyDic[@"at"] integerValue];
    user.notificationNumFollow = [notifyDic[@"follow"] integerValue];
    user.notificationNumMoved = [notifyDic[@"moved"] integerValue];
    user.notificationNumParticipationTopic = [notifyDic[@"participate_topic"] integerValue];
    [notifyTabelView reloadData];
}


/**
 *  读取新收到的通知消息，并处理分类;
 */
-(void)loadDataMessageFull:(BOOL) isNotifyFull{
    userInfo *user = [userInfo shareClass];
    if ([user.token length]>0 && user.notificationNumTotal > 0) {
        NSDictionary *requestDic = [NSDictionary dictionaryWithObjectsAndKeys:Limit_Constant,Parameter_Limit,[NSNumber numberWithBool:YES],@"full", nil];
        ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Notify]]];
        [request addBodyDataSourceWithJsonByDic:requestDic Method:GetMethod auth:YES];
        __weak ASIHTTPRequest *weakrequest = request;
        [request setCompletionBlock :^{
            //    NSLog(@"%@",weakrequest.originalURL);
            NSLog(@"%@",[weakrequest responseString]);
            NSData *data = [weakrequest responseData];
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            if (dic) {
                page ++;
                if (!isNotifyFull) {
                    notifyArray = [[NotifyObject new] makeMuzziksByNotifyArray:[dic objectForKey:@"notifies"]];
                }else{
                    [notifyArray addObjectsFromArray:[[NotifyObject new] makeMuzziksByNotifyArray:[dic objectForKey:@"notifies"]]];
                }
                
                
                if (user.notificationNumTotal>[notifyArray count]) {
                    [self loadDataMessageFull:YES];
                }
                else{
                    for (NSInteger i = 0; i<user.notificationNumTotal; i++) {
                        NotifyObject *tempMuzzik = notifyArray[i];
                        if ([tempMuzzik.type isEqualToString:@"comment"]) {
                            user.notificationNumReply ++;
                            user.notificationNumReplyNew = YES;
                        }
                        else if ([tempMuzzik.type isEqualToString:@"at"]) {
                            user.notificationNumMetion ++;
                            user.notificationNumMetionNew = YES;
                        }
                        else if ([tempMuzzik.type isEqualToString:@"moved"]) {
                            user.notificationNumMoved ++;
                            user.notificationNumMovedNew = YES;
                        }
                        else if ([tempMuzzik.type isEqualToString:@"repost"]) {
                            user.notificationNumRepost ++;
                            user.notificationNumRepostNew = YES;
                        }
                        else if ([tempMuzzik.type isEqualToString:@"participate_topic"]) {
                            user.notificationNumParticipationTopic ++;
                            user.notificationNumParticipationTopicNew = YES;
                        }
                        else {
                            user.notificationNumFollow ++;
                            user.notificationNumFollowNew = YES;
                        }
                    }
                    [notifyDic setObject:[NSNumber numberWithInteger:user.notificationNumReply] forKey:@"comment"];
                    [notifyDic setObject:[NSNumber numberWithInteger:user.notificationNumRepost] forKey:@"repost"];
                    [notifyDic setObject:[NSNumber numberWithInteger:user.notificationNumMetion] forKey:@"at"];
                    [notifyDic setObject:[NSNumber numberWithInteger:user.notificationNumFollow] forKey:@"follow"];
                    [notifyDic setObject:[NSNumber numberWithInteger:user.notificationNumMoved] forKey:@"moved"];
                    [notifyDic setObject:[NSNumber numberWithInteger:user.notificationNumParticipationTopic] forKey:@"participate_topic"];
                    [MuzzikItem addObjectToLocal:[notifyDic copy] ForKey:Notification_Number_Dictionary];
                    if (user.notificationNumTotal > 0) {
                        [notifyTabelView reloadData];
                        user.notificationNumTotal = 0;
                    }
                    
                    
                }
            }
        }];
        [request setFailedBlock:^{
            if (![[weakrequest responseString] length]>0) {
                [self networkErrorShow];
            }
            NSLog(@"%@,%@",[weakrequest error],[weakrequest responseString]);
            
            
            
        }];
        [request startAsynchronous];

    }
}
-(void)rightBtnAction:(UIButton *)sender{
//    IMListViewController *rcc = [[IMListViewController alloc] init];
//    [self.navigationController pushViewController:rcc animated:YES];
    showUsersVC *showuser = [[showUsersVC alloc] init];
    showuser.showType = @"follows";
    [self.navigationController pushViewController:showuser animated:YES];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];

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

@end
