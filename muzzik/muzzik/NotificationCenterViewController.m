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
#import <RongIMLib/RongIMLib.h>
#import "IMFriendListViewController.h"
#import <CoreData/CoreData.h>
#import "Conversation.h"
#import "Message.h"
#import "UserCore.h"
@interface NotificationCenterViewController ()<UITableViewDataSource,UITableViewDelegate,RCIMClientReceiveMessageDelegate>{
    UITableView *notifyTabelView;
    NSMutableArray *notifyArray;
    NSInteger page;
    NSMutableDictionary *notifyDic;
    NSMutableArray *conversationList;
    dispatch_queue_t _serialQueue;
}

@end

@implementation NotificationCenterViewController
#pragma mark view_lifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    _serialQueue = dispatch_queue_create("IMserialQueue", DISPATCH_QUEUE_SERIAL);
    
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
        
        
    }
    RCIMClient *client = [RCIMClient sharedRCIMClient];
    [client setReceiveMessageDelegate:self object:nil];
    [self getSeverConversation];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:NO animated:YES];
    [self checkNewNotification];
    
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
    IMFriendListViewController *showuser = [[IMFriendListViewController alloc] init];
    [self.navigationController pushViewController:showuser animated:YES];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)getCoreConversationByCon:(RCConversation *)conversation{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Conversation" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    // Specify how the fetched objects should be sorted
    NSLog(@"%@",conversation.targetId);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"targetId == %@", conversation.targetId];
    [fetchRequest setPredicate:predicate];
//    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sendTime"
//                                                                   ascending:YES];
//    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        NSLog(@"无法打开");
    }else{
        if ([fetchedObjects count] >0) {
            Conversation *ll =fetchedObjects[0];
            NSLog(@"%@  %@",ll.targetId,ll.description);
           // return fetchedObjects[0];
        }else{
            Conversation *con = [[Conversation alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];
            con.targetId = conversation.targetId;
            
            
        }
    }
    
}
-(void)getSeverConversation{
    conversationList = [NSMutableArray array];
    NSArray *conversationArray = [[RCIMClient sharedRCIMClient]
                                 getConversationList:@[@(ConversationType_PRIVATE),
                                                       @(ConversationType_DISCUSSION),
                                                       @(ConversationType_GROUP),
                                                       @(ConversationType_SYSTEM),
                                                       @(ConversationType_APPSERVICE),
                                                       @(ConversationType_PUBLICSERVICE)]];
    if ([conversationArray count] > 0) {
        [self getConversationListByLocalArray:conversationArray];
    }
//    for (RCConversation *conversation in conversationArray) {
//        [conversationList addObject:[self getCoreConversationByCon:conversation]];
//        NSLog(@"会话类型：%lu，目标会话ID：%@", (unsigned long)conversation.conversationType, conversation.targetId);
//    }
    
//    NSArray *conversationArray = [[RCIMClient sharedRCIMClient] getConversationList:@[@(ConversationType_PRIVATE)]];
//    for (RCConversation *dic in conversationArray) {
//        NSLog(@"%@",dic);
//    }
}

-(void)getConversationListByLocalArray:(NSArray *) conArray{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Conversation" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    for (RCConversation *conversation in conArray) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"targetId == %@", conversation.targetId];
        [fetchRequest setPredicate:predicate];
        //    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sendTime"
        //                                                                   ascending:YES];
        //    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
        
        NSError *error = nil;
        NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (fetchedObjects == nil) {
            NSLog(@"无法打开");
        }else{
            dispatch_async(_serialQueue, ^{
                if ([fetchedObjects count] >0) {
                    [conversationList addObject:fetchedObjects[0]];
                }else{
                    Conversation *con = [[Conversation alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];
                    con.targetId = conversation.targetId;
                    con.sendTime = conversation.sentTime;
                    NSEntityDescription *Messageentity = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:self.managedObjectContext];
                    Message *coreMessage = [[Message alloc] initWithEntity:Messageentity insertIntoManagedObjectContext:self.managedObjectContext];
                    coreMessage.messageId = (int32_t)conversation.lastestMessageId;
                    if ([conversation.lastestMessage isMemberOfClass:[RCTextMessage class]]) {
                        RCTextMessage *testMessage = (RCTextMessage *)conversation.lastestMessage;
                        coreMessage.messageContent = testMessage.content;
                    }
                    coreMessage.sendTime = conversation.sentTime;
                    [con addMessagesObject:coreMessage];
                    con.lastMessage = coreMessage;
                    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                    NSEntityDescription *userEntity = [NSEntityDescription entityForName:@"UserCore" inManagedObjectContext:self.managedObjectContext];
                    [fetchRequest setEntity:userEntity];
                    // Specify criteria for filtering which objects to fetch
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user_id == %@", conversation.targetId];
                    [fetchRequest setPredicate:predicate];
                    // Specify how the fetched objects should be sorted
                    
                    
                    NSError *error = nil;
                    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
                    if (fetchedObjects == nil) {
                        NSLog(@"error:%@",error.userInfo);
                    }else{
                        if ([fetchedObjects count] == 0) {
                            [self addUserToConversation:con];
                        }else{
                            con.targetUser = fetchedObjects[0];
                        }
                    }
                    
                }
            });
            
        }
        

        dispatch_async(_serialQueue, ^{});
    }
}
- (void)onReceived:(RCMessage *)message
              left:(int)nLeft
            object:(id)object {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Conversation" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"targetId == %@", message.targetId];
    [fetchRequest setPredicate:predicate];
    // Specify how the fetched objects should be sorted

    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        NSLog(@"error:%@",error.userInfo);
    }else{
        if ([fetchedObjects count] == 0) {
            Conversation *con = [[Conversation alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];
            con.targetId = message.targetId;
            
            [self addMeaage:message ToConversation:con];
        }else{
            Conversation *con = fetchedObjects[0];
            [self addMeaage:message ToConversation:con];
        }
        
    }
    if ([message.content isMemberOfClass:[RCTextMessage class]]) {
        RCTextMessage *testMessage = (RCTextMessage *)message.content;
        
        NSLog(@"消息内容：%@", testMessage.content);
    }
    
    NSLog(@"还剩余的未接收的消息数：%d", nLeft);
}

-(void) addUserToConversation:(Conversation *)con{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    __weak NotificationCenterViewController *weakSelf = self;
    [manager GET:[NSString stringWithFormat:@"api/user/%@",con.targetId] parameters:nil progress:NULL success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@",responseObject);
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"UserCore" inManagedObjectContext:weakSelf.managedObjectContext];
        UserCore *coreUser = [[UserCore alloc] initWithEntity:entity insertIntoManagedObjectContext:weakSelf.managedObjectContext];
        coreUser.user_id = con.targetId;
        if ([[responseObject allKeys] containsObject:@"name"] && [[responseObject objectForKey:@"name"] length] >0) {
            coreUser.name = [responseObject objectForKey:@"name"];
        }
        if ([[responseObject allKeys] containsObject:@"avatar"] && [[responseObject objectForKey:@"avatar"] length] >0) {
            coreUser.avatar = [responseObject objectForKey:@"avatar"];
        }
        
        if ([[responseObject allKeys] containsObject:@"school"] && [[responseObject objectForKey:@"school"] length] >0) {
            coreUser.school = [responseObject objectForKey:@"school"];
        }
        
        if ([[responseObject allKeys] containsObject:@"company"] && [[responseObject objectForKey:@"company"] length] >0) {
            coreUser.company = [responseObject objectForKey:@"company"];
        }
        
        if ([[responseObject allKeys] containsObject:@"topicsTotal"] && [[responseObject objectForKey:@"topicsTotal"] length] >0) {
            coreUser.topicsTotal = (int32_t)[[responseObject objectForKey:@"topicsTotal"] integerValue];
        }
        
        if ([[responseObject allKeys] containsObject:@"musicsTotal"] && [[responseObject objectForKey:@"musicsTotal"] length] >0) {
            coreUser.musicsTotal = (int32_t)[[responseObject objectForKey:@"musicsTotal"] integerValue];
        }
        if ([[responseObject allKeys] containsObject:@"muzzikTotal"] && [[responseObject objectForKey:@"muzzikTotal"] length] >0) {
            coreUser.muzzikTotal = (int32_t)[[responseObject objectForKey:@"muzzikTotal"] integerValue];
        }
        if ([[responseObject allKeys] containsObject:@"followsCount"] && [[responseObject objectForKey:@"followsCount"] length] >0) {
            coreUser.followsCount = (int32_t)[[responseObject objectForKey:@"followsCount"] integerValue];
        }
        if ([[responseObject allKeys] containsObject:@"fansCount"] && [[responseObject objectForKey:@"fansCount"] length] >0) {
            coreUser.fansCount = (int32_t)[[responseObject objectForKey:@"fansCount"] integerValue];
        }
        
        if ([[responseObject allKeys] containsObject:@"gender"] && [[responseObject objectForKey:@"gender"] length] >0) {
            coreUser.gender = [responseObject objectForKey:@"gender"];
        }
        
        if ([[responseObject allKeys] containsObject:@"astro"] && [[responseObject objectForKey:@"astro"] length] >0) {
            coreUser.astro = [responseObject objectForKey:@"astro"];
        }
        
        if ([[responseObject allKeys] containsObject:@"description"] && [[responseObject objectForKey:@"description"] length] >0) {
            coreUser.descrip = [responseObject objectForKey:@"description"];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
    }];
    
}
-(void) addMeaage:(RCMessage *) message ToConversation:(Conversation *)con{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:self.managedObjectContext];
    Message *coreMessage = [[Message alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];
    coreMessage.messageId = (int32_t)message.messageId;
    if ([message.content isMemberOfClass:[RCTextMessage class]]) {
        RCTextMessage *testMessage = (RCTextMessage *)message.content;
        coreMessage.messageContent = testMessage.content;
    }
    con.sendTime = message.sentTime;
    coreMessage.sendTime = message.sentTime;
    [con addMessagesObject:coreMessage];
    con.lastMessage = coreMessage;
    if ([con.targetUser count] == 0) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"UserCore" inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        // Specify criteria for filtering which objects to fetch
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user_id == %@", message.targetId];
        [fetchRequest setPredicate:predicate];
        // Specify how the fetched objects should be sorted
        
        
        NSError *error = nil;
        NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (fetchedObjects == nil) {
            NSLog(@"error:%@",error.userInfo);
        }else{
            if ([fetchedObjects count] == 0) {
                [self addUserToConversation:con];
            }else{
                con.targetUser = fetchedObjects[0];
            }
        }
        
        
    }else{
        [self.managedObjectContext save:nil];
    }
    
    
    
    
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
