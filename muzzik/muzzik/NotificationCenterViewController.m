//
//  NotificationCenterViewController.m
//  muzzik
//
//  Created by muzzik on 15/9/7.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//
//  @[@(ConversationType_PRIVATE),
//    @(ConversationType_DISCUSSION),
//    @(ConversationType_GROUP),
//    @(ConversationType_SYSTEM),
//    @(ConversationType_APPSERVICE),
//    @(ConversationType_PUBLICSERVICE)]
#import "NotificationCenterViewController.h"
#import "NotifyObject.h"
#import "NotificationCategoryCell.h"
#import "NotificationVC.h"
#import "RDVTabBarController.h"
#import "searchViewController.h"

#import "IMFriendListViewController.h"
#import <CoreData/CoreData.h>
#import "Conversation.h"
#import "Message.h"
#import "UserCore.h"
#import "Utils_IM.h"
#import "IMConversationViewcontroller.h"
@interface NotificationCenterViewController ()<UITableViewDataSource,UITableViewDelegate>{
    UITableView *notifyTabelView;
    NSMutableArray *notifyArray;
    NSInteger page;
    NSMutableDictionary *notifyDic;
    UIButton *replyButton;
    UIButton *moveButon;
    UIButton *mentionButton;
    UIButton *followButton;
    UIButton *repostButton;
    UIButton *topicButton;
    UIView *headerView;
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
    [self settingHeadView];
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
        
        
    }
    
    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:NO animated:YES];
    [self checkNewNotification];
    //[self getSeverConversation];
   // [self getLocalConversation];
    
    
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
-(void) settingHeadView{
    headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 136)];
    
    replyButton = [[UIButton alloc] initWithFrame:CGRectMake(16, 16, (SCREEN_WIDTH - 44) / 3, 57)];
    replyButton.layer.cornerRadius = 5;
    replyButton.layer.masksToBounds = YES;
    [replyButton setBackgroundColor:Color_line_2];
    [replyButton setImage:[UIImage imageNamed:@"greynoti_reply"] forState:UIControlStateNormal];
    [replyButton addTarget:self action:@selector(seeReplyAction:) forControlEvents:UIControlEventTouchUpInside];
    
    moveButon = [[UIButton alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 44) / 3+22, 16, (SCREEN_WIDTH - 44) / 3, 57)];
    moveButon.layer.cornerRadius = 5;
    moveButon.layer.masksToBounds = YES;
    [moveButon setBackgroundColor:Color_line_2];
    [moveButon setImage:[UIImage imageNamed:@"greynoti_like"] forState:UIControlStateNormal];
    [moveButon addTarget:self action:@selector(seeMoveAction:) forControlEvents:UIControlEventTouchUpInside];
    
    mentionButton = [[UIButton alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 44)*2 / 3+28, 16, (SCREEN_WIDTH - 44) / 3, 57)];
    mentionButton.layer.cornerRadius = 5;
    mentionButton.layer.masksToBounds = YES;
    [mentionButton setBackgroundColor:Color_line_2];
    [mentionButton setImage:[UIImage imageNamed:@"noti_at"] forState:UIControlStateNormal];
    [mentionButton addTarget:self action:@selector(seeMentionAction:) forControlEvents:UIControlEventTouchUpInside];
    
    followButton = [[UIButton alloc] initWithFrame:CGRectMake(16, 79, (SCREEN_WIDTH - 44) / 3, 57)];
    followButton.layer.cornerRadius = 5;
    followButton.layer.masksToBounds = YES;
    [followButton setBackgroundColor:Color_line_2];
    [followButton setImage:[UIImage imageNamed:@"greynoti_follow"] forState:UIControlStateNormal];
    [followButton addTarget:self action:@selector(seefollowAction:) forControlEvents:UIControlEventTouchUpInside];
    
    repostButton = [[UIButton alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 44) / 3 +22, 79, (SCREEN_WIDTH - 44) / 3, 57)];
    repostButton.layer.cornerRadius = 5;
    repostButton.layer.masksToBounds = YES;
    [repostButton setBackgroundColor:Color_line_2];
    [repostButton setImage:[UIImage imageNamed:@"greynoti_retweet"] forState:UIControlStateNormal];
    [repostButton addTarget:self action:@selector(seeRepostAction:) forControlEvents:UIControlEventTouchUpInside];
    
    topicButton = [[UIButton alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 44)*2 / 3 +28, 79, (SCREEN_WIDTH - 44) / 3, 57)];
    topicButton.layer.cornerRadius = 5;
    topicButton.layer.masksToBounds = YES;
    [topicButton setBackgroundColor:Color_line_2];
    [topicButton setImage:[UIImage imageNamed:@"greynoti_topic"] forState:UIControlStateNormal];
    [topicButton addTarget:self action:@selector(seeTopicAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [headerView addSubview:replyButton];
    [headerView addSubview:mentionButton];
    [headerView addSubview:moveButon];
    [headerView addSubview:followButton];
    [headerView addSubview:repostButton];
    [headerView addSubview: topicButton];
    [notifyTabelView setTableHeaderView:headerView];
    
    
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
    return [userInfo shareClass].account.myConversation.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NotificationCategoryCell*  cell = [tableView dequeueReusableCellWithIdentifier:@"NotificationCategoryCell" forIndexPath:indexPath];
    
    userInfo *user = [userInfo shareClass];
    
    Conversation *con = [user.account.myConversation objectAtIndex:indexPath.row];
    [cell.titleImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL_image,con.targetUser.avatar]]];
    NSLog(@"%@",con.unReadMessage);
    cell.nameLabel.text = con.targetUser.name;
    cell.messageLabel.text = con.abstractString;
    cell.badgeImage.badgeNum = [con.unReadMessage integerValue];
    cell.timeLabel.text = [Utils_IM getStringFromIMDate:con.sendTime];
//    if (indexPath.row == 0) {
//        
//        
//    }
//    else if (indexPath.row == 1) {
//        [cell.titleImage setImage:[UIImage imageNamed:@"noti_at"]];
//        cell.decriptionLabel.text = @"他们提到了你";
//        cell.badgeImage.isNew = user.notificationNumMetionNew;
//        cell.badgeImage.badgeNum = user.notificationNumMetion;
//        
//    }
//    else if (indexPath.row == 2) {
//        [cell.titleImage setImage:[UIImage imageNamed:@"noti_follow"]];
//        cell.decriptionLabel.text = @"他们关注了你";
//        cell.badgeImage.isNew = user.notificationNumFollowNew;
//        cell.badgeImage.badgeNum = user.notificationNumFollow;
//        
//    }
//    else if (indexPath.row == 3) {
//        [cell.titleImage setImage:[UIImage imageNamed:@"noti_like"]];
//        cell.decriptionLabel.text = @"他们喜欢了你的Muzzik";
//        cell.badgeImage.isNew = user.notificationNumMovedNew;
//        cell.badgeImage.badgeNum = user.notificationNumMoved;
//        
//    }
//    else if (indexPath.row == 4) {
//        [cell.titleImage setImage:[UIImage imageNamed:@"noti_retweet"]];
//        cell.decriptionLabel.text = @"他们转发了你的Muzzik";
//        cell.badgeImage.isNew = user.notificationNumRepostNew;
//        cell.badgeImage.badgeNum = user.notificationNumRepost;
//        
//    }
//    else {
//        [cell.titleImage setImage:[UIImage imageNamed:@"noti_topic"]];
//        cell.decriptionLabel.text = @"他们参与了你的话题";
//         cell.badgeImage.isNew = user.notificationNumParticipationTopicNew;
//        cell.badgeImage.badgeNum = user.notificationNumParticipationTopic;
//       
//    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    userInfo *user = [userInfo shareClass];
    IMConversationViewcontroller *imVC = [[IMConversationViewcontroller alloc] init];
    imVC.con = [user.account.myConversation objectAtIndex:indexPath.row];
    imVC.con.unReadMessage = [NSNumber numberWithInt:0];
    imVC.title = imVC.con.targetUser.name;
    AppDelegate *app = (AppDelegate *) [UIApplication sharedApplication].delegate;
    [app.managedObjectContext save:nil];
    [self.navigationController pushViewController:imVC animated:YES];
//    NotificationVC *notifyvc = [[NotificationVC alloc] init];
//    userInfo *user = [userInfo shareClass];
//    if (indexPath.row == 0) {
//        notifyvc.title = @"他们回复了你的Muzzik";
//        notifyvc.notifyType = Notification_comment;
//        notifyvc.numOfNewNotification = user.notificationNumReply;
//        user.notificationNumReplyNew = NO;
//    }else if (indexPath.row == 1) {
//        notifyvc.title = @"他们提到了你";
//        notifyvc.notifyType = Notification_at;
//        notifyvc.numOfNewNotification = user.notificationNumMetion;
//        user.notificationNumMetionNew = NO;
//    }else if (indexPath.row == 2) {
//        notifyvc.title = @"他们关注了你";
//        notifyvc.notifyType = Notification_follow;
//        notifyvc.numOfNewNotification = user.notificationNumFollow;
//        user.notificationNumFollowNew = NO;
//    }else if (indexPath.row == 3) {
//        notifyvc.title = @"他们喜欢了你的Muzzik";
//        notifyvc.notifyType = Notification_moved;
//        notifyvc.numOfNewNotification = user.notificationNumMoved;
//        user.notificationNumMovedNew = NO;
//    }else if (indexPath.row == 4) {
//        notifyvc.title = @"他们转发了你的Muzzik";
//        notifyvc.notifyType = Notification_repost;
//        notifyvc.numOfNewNotification = user.notificationNumRepost;
//        user.notificationNumRepostNew = NO;
//    }else if (indexPath.row == 5) {
//        notifyvc.title = @"他们参与了你的话题";
//        notifyvc.notifyType = Notification_participation;
//        notifyvc.numOfNewNotification = user.notificationNumParticipationTopic;
//        user.notificationNumParticipationTopicNew = NO;
//    }
//    [self.navigationController pushViewController:notifyvc animated:YES];
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
    IMFriendListViewController *showuser = [[IMFriendListViewController alloc] init];
    [self.navigationController pushViewController:showuser animated:YES];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)newMessageArrive{
    dispatch_async(dispatch_get_main_queue(), ^{
        [notifyTabelView reloadData];
    });
    
}
//-(void)getSeverConversation{
//        NSArray *conversationArray = [[RCIMClient sharedRCIMClient]
//                                      getConversationList:@[@(ConversationType_PRIVATE),
//                                                            @(ConversationType_DISCUSSION),
//                                                            @(ConversationType_GROUP),
//                                                            @(ConversationType_SYSTEM),
//                                                            @(ConversationType_APPSERVICE),
//                                                            @(ConversationType_PUBLICSERVICE)]];
//        [self getConversationListByLocalArray:conversationArray];
//
////    for (RCConversation *conversation in conversationArray) {
////        [conversationList addObject:[self getCoreConversationByCon:conversation]];
////        NSLog(@"会话类型：%lu，目标会话ID：%@", (unsigned long)conversation.conversationType, conversation.targetId);
////    }
//    
////    NSArray *conversationArray = [[RCIMClient sharedRCIMClient] getConversationList:@[@(ConversationType_PRIVATE)]];
////    for (RCConversation *dic in conversationArray) {
////        NSLog(@"%@",dic);
////    }
//}
//
//-(void)getConversationListByLocalArray:(NSArray *) conArray{
//    userInfo *user = [userInfo shareClass];
//    NSEnumerator *enume = [conArray reverseObjectEnumerator];
//    RCConversation *conversation;
//    while (conversation = [enume nextObject]) {
//        BOOL contained = NO;
//        for (Conversation *con in [user.account.myConversation array]) {
//            if ([con.targetId isEqualToString:conversation.targetId]) {
//                if ([con.lastMessage.messageId longValue]  != conversation.lastestMessageId) {
//                    Message *coreMessage = [[CoreStack sharedInstance] getNewMessage];
//                    coreMessage.messageId = [NSNumber numberWithLong:conversation.lastestMessageId];
//                    if ([conversation.lastestMessage isMemberOfClass:[RCTextMessage class]]) {
//                        RCTextMessage *testMessage = (RCTextMessage *)conversation.lastestMessage;
//                        coreMessage.messageContent = testMessage.content;
//                    }
//                    con.accountForConversation = user.account;
//                    coreMessage.sendTime = [NSDate dateWithTimeIntervalSince1970:conversation.sentTime/1000];
//                    
//                    if ([self checkLimitedTime:coreMessage.sendTime oldDate:con.sendTime]) {
//                        coreMessage.needsToShowTime = [NSNumber numberWithBool:YES];
//                    }else{
//                        coreMessage.needsToShowTime = [NSNumber numberWithBool:NO];
//                    }
//                    
//                    coreMessage.messages = con;
//                    if ([conversation.senderUserId isEqualToString:user.uid]) {
//                        coreMessage.isOwner = [NSNumber numberWithBool:YES];
//                    }else{
//                        coreMessage.isOwner = [NSNumber numberWithBool:NO];
//                    }
//                    
//                    if (![con.targetId isEqualToString:user.account.myConversation.lastObject.targetId]) {
//                        [user.account removeMyConversationObject:con];
//                        [user.account insertObject:con inMyConversationAtIndex:0];
//                    }
//                    
//                    //添加未读消息到本地，并清空服务器未读消息
//                    
//                    [self pickNewMessagesFromLocal:conversation toCoreConversation:con andLastMessage:coreMessage];
//                    [[[CoreStack sharedInstance] managedObjectContext] save:nil];
//                }
//                contained = YES;
//                break;
//            }
//        }
//        if (!contained) {
//            Conversation *con = [[CoreStack sharedInstance] getNewConversation];
//            con.targetId = conversation.targetId;
//            con.sendTime = [NSDate dateWithTimeIntervalSince1970:conversation.sentTime/1000];
//            Message *coreMessage = [[CoreStack sharedInstance] getNewMessage];
//            coreMessage.messageId = [NSNumber numberWithLong:conversation.lastestMessageId];
//            if ([conversation.lastestMessage isMemberOfClass:[RCTextMessage class]]) {
//                RCTextMessage *testMessage = (RCTextMessage *)conversation.lastestMessage;
//                coreMessage.messageContent = testMessage.content;
//            }
//            con.accountForConversation = user.account;
//            coreMessage.sendTime = [NSDate dateWithTimeIntervalSince1970:conversation.sentTime/1000];
//            coreMessage.needsToShowTime = [NSNumber numberWithBool:YES];
//            coreMessage.messages = con;
//            if ([conversation.senderUserId isEqualToString:user.uid]) {
//                coreMessage.isOwner = [NSNumber numberWithBool:YES];
//            }else{
//                coreMessage.isOwner = [NSNumber numberWithBool:NO];
//            }
//            [self pickNewMessagesFromLocal:conversation toCoreConversation:con andLastMessage:coreMessage];
//            BOOL containedUser = NO;
//            for (UserCore *coreUser in user.account.myUser) {
//                if ([coreUser.user_id isEqualToString:con.targetId]) {
//                    con.targetUser = coreUser;
//                    [user.account addMyConversationObject:con];
//                    [[[CoreStack sharedInstance] managedObjectContext] save:nil];
//                    containedUser = YES;
//                    break;
//                }
//            }
//            if (!containedUser) {
//                dispatch_async(_serialQueue, ^{
//                    UserCore *newUser = [[CoreStack sharedInstance] getNewUser];
//                    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//                    [manager GET:[NSString stringWithFormat:@"api/user/%@",con.targetId] parameters:nil progress:NULL success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//                        NSLog(@"%@",responseObject);
//                        newUser.user_id = con.targetId;
//                        if ([[responseObject allKeys] containsObject:@"name"] && [[responseObject objectForKey:@"name"] length] >0) {
//                            newUser.name = [responseObject objectForKey:@"name"];
//                        }
//                        if ([[responseObject allKeys] containsObject:@"avatar"] && [[responseObject objectForKey:@"avatar"] length] >0) {
//                            newUser.avatar = [responseObject objectForKey:@"avatar"];
//                        }
//                        
//                        if ([[responseObject allKeys] containsObject:@"school"] && [[responseObject objectForKey:@"school"] length] >0) {
//                            newUser.school = [responseObject objectForKey:@"school"];
//                        }
//                        
//                        if ([[responseObject allKeys] containsObject:@"company"] && [[responseObject objectForKey:@"company"] length] >0) {
//                            newUser.company = [responseObject objectForKey:@"company"];
//                        }
//                        
//                        if ([[responseObject allKeys] containsObject:@"topicsTotal"]) {
//                            newUser.topicsTotal = [responseObject objectForKey:@"topicsTotal"];
//                        }
//                        
//                        if ([[responseObject allKeys] containsObject:@"musicsTotal"]) {
//                            newUser.musicsTotal = [responseObject objectForKey:@"musicsTotal"];
//                        }
//                        if ([[responseObject allKeys] containsObject:@"muzzikTotal"]) {
//                            newUser.muzzikTotal = [responseObject objectForKey:@"muzzikTotal"];
//                        }
//                        if ([[responseObject allKeys] containsObject:@"followsCount"]) {
//                            newUser.followsCount = [responseObject objectForKey:@"followsCount"];
//                        }
//                        if ([[responseObject allKeys] containsObject:@"fansCount"]) {
//                            newUser.fansCount = [responseObject objectForKey:@"fansCount"];
//                        }
//                        
//                        if ([[responseObject allKeys] containsObject:@"gender"] && [[responseObject objectForKey:@"gender"] length] >0) {
//                            newUser.gender = [responseObject objectForKey:@"gender"];
//                        }
//                        
//                        if ([[responseObject allKeys] containsObject:@"astro"] && [[responseObject objectForKey:@"astro"] length] >0) {
//                            newUser.astro = [responseObject objectForKey:@"astro"];
//                        }
//                        
//                        if ([[responseObject allKeys] containsObject:@"description"] && [[responseObject objectForKey:@"description"] length] >0) {
//                            newUser.descrip = [responseObject objectForKey:@"description"];
//                        }
//                        con.targetUser = newUser;
//                        [user.account addMyConversationObject:con];
//                        [[[CoreStack sharedInstance] managedObjectContext] save:nil];
//                    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//                        NSLog(@"%@",error);
//                    }];
//                });
//            }
//                }
//    
//        
//    }
//    dispatch_async(_serialQueue, ^{
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [notifyTabelView reloadData];
//        });
//    });
//}





//-(void) pickNewMessagesFromLocal:(RCConversation *)rccon toCoreConversation:(Conversation *)con andLastMessage:(Message *) coreMessage{
//    NSArray *newMessages = [[RCIMClient sharedRCIMClient] getLatestMessages:ConversationType_PRIVATE targetId:rccon.targetId count:rccon.unreadMessageCount];
//    if (newMessages) {
//        if ([[RCIMClient sharedRCIMClient] clearMessagesUnreadStatus:ConversationType_PRIVATE targetId:rccon.targetId]) {
//            con.unReadMessage = [NSNumber numberWithInt:rccon.unreadMessageCount + [con.unReadMessage intValue]];
//            NSEnumerator *messageEnumerator = [newMessages reverseObjectEnumerator];
//            RCMessage *newLocalMessage;
//            while (newLocalMessage = [messageEnumerator nextObject]) {
//                Message *tempMessage = [[CoreStack sharedInstance] getNewMessage];
//                tempMessage.messageId = [NSNumber numberWithLong:newLocalMessage.messageId];
//                if ([newLocalMessage.content isMemberOfClass:[RCTextMessage class]]) {
//                    RCTextMessage *testMessage = (RCTextMessage *)newLocalMessage;
//                    tempMessage.messageContent = testMessage.content;
//                }
//                tempMessage.sendTime = [NSDate dateWithTimeIntervalSince1970:newLocalMessage.sentTime/1000];
//                if ([self checkLimitedTime:tempMessage.sendTime oldDate:con.messages.lastObject.sendTime]) {
//                    tempMessage.needsToShowTime = [NSNumber numberWithBool:YES];
//                }else{
//                    tempMessage.needsToShowTime = [NSNumber numberWithBool:NO];
//                }
//                
//                tempMessage.messages = con;
//                if ([rccon.senderUserId isEqualToString:[userInfo shareClass].uid]) {
//                    tempMessage.isOwner = [NSNumber numberWithBool:YES];
//                }else{
//                    tempMessage.isOwner = [NSNumber numberWithBool:NO];
//                }
//                [con addMessagesObject:tempMessage];
//            }
//            
//        }
//        
//        con.lastMessage = coreMessage;
//    }
//}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
