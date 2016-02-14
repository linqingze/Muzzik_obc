//
//  IMConversationViewcontroller.m
//  muzzik
//
//  Created by muzzik on 15/12/30.
//  Copyright © 2015年 muzziker. All rights reserved.
//

#import "IMConversationViewcontroller.h"
#import "IMTextCell.h"
#import "IMTextOwnerCell.h"
#import "IMshareCell.h"
#import "HPGrowingTextView.h"
#import "UIImageView+WebCache.h"
#import "YYTextView.h"
#import "userDetailInfo.h"
#import "IMEnterMessage.h"
#import "Utils_IM.h"
#import "ListenCell.h"
@interface IMConversationViewcontroller ()<UITableViewDataSource,UITableViewDelegate,HPGrowingTextViewDelegate>{
    UITableView *IMTableView;
    UIView *IMTalkView;
    NSInteger messageCount;
    UIView *commentView;
    HPGrowingTextView *comnentTextView;
    CGRect tableOriginRect;
    CGRect commentViewRect;
    
    UITapGestureRecognizer *tapOnview;
    UIView *userHeadImage;
    UIImageView *cellUserheadImage;
    BOOL hideStatus;
    UILabel *statueLabel;
    UIView *headerView;
    UIActivityIndicatorView *activityView;
    BOOL loadingMore;
    BOOL keyBoadShow;
    UIView *messageCountView;
    UILabel *messageLeftLabel;
    NSInteger newMessgaeCount;
    Message *listenMessage;

}

@end

@implementation IMConversationViewcontroller

- (void)viewDidLoad {
    [super viewDidLoad];
    userHeadImage = [[UIView alloc] init];
    [userHeadImage setBackgroundColor:[UIColor blackColor]];
    statueLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
    statueLabel.textAlignment = NSTextAlignmentCenter;
    statueLabel.font = [UIFont  systemFontOfSize:15];
    [statueLabel setTextColor:[UIColor whiteColor]];
    cellUserheadImage = [[UIImageView alloc] init];
    cellUserheadImage.contentMode = UIViewContentModeScaleAspectFit;
    [userHeadImage addSubview:cellUserheadImage];
    [userHeadImage addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedWithImage)]];
    [self initNagationBar:self.title leftBtn:Constant_backImage rightBtn:100];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    tapOnview = [[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)];
    
    [self settingTableView];
    [self settingTalkView];
    [self settingMessageButton];
    IMEnterMessage *enter = [[IMEnterMessage alloc] init];
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"watch", nil];
    enter.jsonStr = [Utils_IM DataTOjsonString:dic];
    enter.extra = [Utils_IM DataTOjsonString:[NSDictionary dictionaryWithObjectsAndKeys:_con.targetUser.name,@"name",_con.targetUser.avatar,@"avatar",_con.targetUser.user_id,@"_id", nil]];
    [[RCIMClient sharedRCIMClient] sendMessage:ConversationType_PRIVATE targetId:self.con.targetId content:enter pushContent:nil success:nil error:nil];
    // Do any additional setup after loading the view.
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    userInfo *user = [userInfo shareClass];
    IMEnterMessage *enter = [[IMEnterMessage alloc] init];
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"watch",[user.listenToUid isEqualToString:_con.targetId], nil];
    enter.jsonStr = [Utils_IM DataTOjsonString:dic];
    enter.extra = [Utils_IM DataTOjsonString:[NSDictionary dictionaryWithObjectsAndKeys:_con.targetUser.name,@"name",_con.targetUser.avatar,@"avatar",_con.targetUser.user_id,@"_id", nil]];
    [[RCIMClient sharedRCIMClient] sendMessage:ConversationType_PRIVATE targetId:self.con.targetId content:enter pushContent:nil success:nil error:nil];
    
}
-(void)viewWillAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playnextMuzzikUpdate) name:String_SetSongPlayNextNotification object:nil];
    if ([[userInfo shareClass].account.myConversation containsObject:_con]) {
        NSLog(@"contain");
    }
    [super viewWillAppear:animated];
    if (messageCount > 0 && !keyBoadShow) {
        messageCount = messageCount>_con.messages.count ? _con.messages.count :messageCount;
        [IMTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:messageCount-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
     AppDelegate *app = (AppDelegate *) [UIApplication sharedApplication].delegate;
    NSLog(@"%d",app.IMconnectionStatus);
    if (app.IMconnectionStatus == ConnectionStatus_NETWORK_UNAVAILABLE || app.IMconnectionStatus == ConnectionStatus_Unconnected) {
         [self connectionChanged:app.IMconnectionStatus];
    }
   
   
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if ([_con.messages count] == 0) {
        [[userInfo shareClass].account removeMyConversationObject:_con];
    }
}
-(void) settingTableView{
    IMTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-124)];
    IMTableView.backgroundColor = [UIColor whiteColor];
    IMTableView.delegate = self;
    IMTableView.dataSource = self;
    IMTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [IMTableView registerClass:[IMTextCell class] forCellReuseIdentifier:@"IMTextCell"];
    [IMTableView registerClass:[IMshareCell class] forCellReuseIdentifier:@"IMshareCell"];
    [IMTableView registerClass:[IMTextOwnerCell class] forCellReuseIdentifier:@"IMTextOwnerCell"];
    [self.view addSubview:IMTableView];
    tableOriginRect = IMTableView.frame;
    if (_con.messages.count>15) {
        headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
        [headerView setBackgroundColor:[UIColor whiteColor]];
        activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [activityView setFrame:CGRectMake(SCREEN_WIDTH/2-15, 0, 30, 30)];
        [headerView addSubview:activityView];
        messageCount = 15;
    }else{
        messageCount = _con.messages.count;
    }
    messageCount = 15>_con.messages.count ? _con.messages.count:15;
    
}
-(void) settingTalkView{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    commentView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-124, SCREEN_WIDTH, 60)];
    [commentView setBackgroundColor:Color_line_2];
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
    [line setBackgroundColor:Color_line_1];
    [commentView addSubview:line];
    [self.view addSubview:commentView];
    comnentTextView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(13, 10, SCREEN_WIDTH-26, 40)];
    comnentTextView.tintColor = Color_Active_Button_1;
    comnentTextView.layer.borderWidth =1;
    comnentTextView.layer.borderColor = Color_line_1.CGColor;
    comnentTextView.layer.cornerRadius = 3;
    comnentTextView.clipsToBounds = YES;
    comnentTextView.delegate = self;
    comnentTextView.maxHeight = 80;
    comnentTextView.font = [UIFont systemFontOfSize:15];
    comnentTextView.textColor = Color_Text_2;
    [comnentTextView setReturnKeyType:UIReturnKeySend];
    comnentTextView.animateHeightChange = NO;
    
    comnentTextView.placeholderColor = Color_Text_4;
    [commentView addSubview:comnentTextView];
    commentViewRect = commentView.frame;
}

-(void)settingMessageButton{
    messageCountView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 50, SCREEN_HEIGHT-165, 33, 33)];
    UIImageView *backImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 33, 33)];
    [backImage setImage:[UIImage imageNamed:@"bubble"]];
    backImage.contentMode = UIViewContentModeScaleToFill;
    messageLeftLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, 7, 27, 20)];
    [messageLeftLabel setTextColor:[UIColor whiteColor]];
    [messageLeftLabel setFont:[UIFont fontWithName:Font_Next_medium size:10]];
    messageLeftLabel.textAlignment = NSTextAlignmentCenter;
    [messageCountView addSubview:backImage];
    [messageCountView addSubview:messageLeftLabel];
    [messageCountView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(seeMessage)]];
    newMessgaeCount = 0;
    
}

-(void) getUnreadMessage{
    newMessgaeCount ++;
    if (newMessgaeCount<=99) {
        messageLeftLabel.text = [NSString stringWithFormat:@"%ld",newMessgaeCount];
    }else{
        messageLeftLabel.text = @"99+";
    }
    
    [self.view addSubview:messageCountView];
    
}
-(void)refreshHeader{
    messageCount +=15;
    __block NSUInteger moreNum = 15;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        loadingMore = NO;
       
        [activityView stopAnimating];
        if (messageCount > _con.messages.count) {
            
            moreNum = 15 - messageCount + _con.messages.count;
            messageCount = _con.messages.count;
            [IMTableView reloadData];
            [IMTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:moreNum inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }else{
           
            [IMTableView reloadData];
            [IMTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:moreNum inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }
        
    });
}

-(void)connectionChanged:(RCConnectionStatus)status{
    
    if (status == ConnectionStatus_Connected) {
        [statueLabel setAlpha:0.9];
        statueLabel.text = @"连接服务器成功";
        [statueLabel setBackgroundColor:Color_Additional_2];
        
        [UIView animateWithDuration:3 animations:^{
            [statueLabel setAlpha:0.9];
        } completion:^(BOOL finished) {
            [statueLabel removeFromSuperview];
        }];
        
        
    }else if(status == ConnectionStatus_Connecting ){
        [statueLabel setAlpha:0.9];
        statueLabel.text = @"正在连接...";
        [statueLabel setBackgroundColor:Color_Action_Button_2];
        
    }else if(status == ConnectionStatus_Unconnected || status == ConnectionStatus_NETWORK_UNAVAILABLE){
        [statueLabel setAlpha:0.9];
        statueLabel.text = @"连接不上服务器";
        [statueLabel setBackgroundColor:Color_Active_Button_1];
    }
    [self.view addSubview:statueLabel];
    
}

#pragma mark tableView_DelegateMethod

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _con.messages.count >messageCount ? messageCount : _con.messages.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    Message *message;
    if (messageCount >= _con.messages.count) {
        message = _con.messages[indexPath.row];
    }else{
        message = _con.messages[indexPath.row+_con.messages.count-messageCount];
    }
    
//    NSLog(@"%@",message.cellHeight);
    if ([message.cellHeight integerValue] == 0) {
        CGFloat height = 0;
        if ([message.needsToShowTime boolValue]) {
            height += 56;
        }else{
            height+=16;
        }
        AppDelegate *app = (AppDelegate *) [UIApplication sharedApplication].delegate;

        if ([message.messageType isEqualToString:Type_IM_TextMessage]) {
            YYTextView *_messageLabel = [[YYTextView alloc] init];
            _messageLabel.textContainerInset = UIEdgeInsetsMake(9, 10, 9, 10);
            NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:message.messageContent];
            text.yy_font = [UIFont fontWithName:Font_Next_Regular size:15];
            text.yy_color = [UIColor blackColor];
            _messageLabel.attributedText = text;
            CGSize labelsize = [_messageLabel sizeThatFits:CGSizeMake(SCREEN_WIDTH-136, 2000)];

            message.cellHeight = [NSNumber numberWithDouble:height+ labelsize.height+10];
            [app.managedObjectContext save:nil];
        }else if ([message.messageType isEqualToString:Type_IM_ShareMuzzik]){
            message.cellHeight = [NSNumber numberWithDouble:height+88];
            [app.managedObjectContext save:nil];
        }
        
        
    }
    return [message.cellHeight doubleValue];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Message *message;
    if (messageCount >= _con.messages.count) {
        message = _con.messages[indexPath.row];
    }else{
        message = _con.messages[indexPath.row+_con.messages.count-messageCount];
    }
    if ([message.messageType isEqualToString:Type_IM_TextMessage] &&  [message.isOwner boolValue]) {
        IMTextOwnerCell*  cell = [tableView dequeueReusableCellWithIdentifier:@"IMTextOwnerCell" forIndexPath:indexPath];
        cell.imvc = self;
        if (messageCount >= _con.messages.count) {
            message = _con.messages[indexPath.row];
        }else{
            message = _con.messages[indexPath.row+_con.messages.count-messageCount];
        }
        [cell configureCellWithMessage:message];
        return cell;
        
    }else if ([message.messageType isEqualToString:Type_IM_TextMessage] &&  ![message.isOwner boolValue]) {
        IMTextCell*  cell = [tableView dequeueReusableCellWithIdentifier:@"IMTextCell" forIndexPath:indexPath];
        cell.imvc = self;
        if (messageCount >= _con.messages.count) {
            message = _con.messages[indexPath.row];
        }else{
            message = _con.messages[indexPath.row+_con.messages.count-messageCount];
        }
        [cell configureCellWithMessage:message];
        return cell;
        
    }
    else if ([message.messageType isEqualToString:Type_IM_ShareMuzzik]){
        IMshareCell*  cell = [tableView dequeueReusableCellWithIdentifier:@"IMshareCell" forIndexPath:indexPath];
        cell.imvc = self;
        if (messageCount >= _con.messages.count) {
            message = _con.messages[indexPath.row];
        }else{
            message = _con.messages[indexPath.row+_con.messages.count-messageCount];
        }
        [cell configureCellWithMessage:message];
        return cell;
    }
    return nil;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - HOGrowingDelegate
-(void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height{
    CGFloat delta = height-growingTextView.frame.size.height;
    tableOriginRect = CGRectMake(tableOriginRect.origin.x, tableOriginRect.origin.y, tableOriginRect.size.width, tableOriginRect.size.height-delta);
    commentViewRect = CGRectMake(commentViewRect.origin.x, commentViewRect.origin.y-delta, SCREEN_WIDTH, commentViewRect.size.height+delta);
    [commentView setFrame:CGRectMake(commentView.frame.origin.x, commentView.frame.origin.y-delta, SCREEN_WIDTH, commentView.frame.size.height+delta)];
    [IMTableView setFrame:CGRectMake(IMTableView.frame.origin.x, IMTableView.frame.origin.y, IMTableView.frame.size.width, IMTableView.frame.size.height-delta)];
    [UIView animateWithDuration:0.2 animations:^{
        IMTableView.contentOffset = CGPointMake(IMTableView.contentOffset.x, IMTableView.contentOffset.y+delta);
    }];
    
}
-(BOOL)growingTextViewShouldReturn:(HPGrowingTextView *)growingTextView{
    if ([growingTextView.text length]>0) {
        
           RCTextMessage *rctext = [[RCTextMessage alloc] init];
        [rctext setSenderUserInfo:[RCIMClient sharedRCIMClient].currentUserInfo];
        rctext.content = growingTextView.text;
        
        AppDelegate *app = (AppDelegate *) [UIApplication sharedApplication].delegate;
        [app sendIMMessage:rctext targetCon:_con pushContent:[NSString stringWithFormat:@"%@: %@",[userInfo shareClass].name,growingTextView.text]];
        growingTextView.text = @"";
    }
    return YES;
}

-(void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView{
}


#pragma mark - 监听键盘高度改变事件

- (void)keyboardWillShow:(NSNotification *)notification
{
    keyBoadShow = YES;
    [self.view addGestureRecognizer:tapOnview];
    
    
    NSDictionary *userInfo = [notification userInfo];
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    CGRect keyboardRect = [aValue CGRectValue];
    
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    //
    CGRect newTableFrame = tableOriginRect;
    newTableFrame.size.height += -keyboardRect.size.height;
    
    
    
    CGRect newInputFieldFrame = commentViewRect;
    newInputFieldFrame.origin.y += -keyboardRect.size.height;
    
    
    // 键盘的动画时间，设定与其完全保持一致
    NSNumber *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    if ([animationDurationValue doubleValue]  < 0.05) {
        //不用动画
        IMTableView.frame = newTableFrame;
        commentView.frame = newInputFieldFrame;
        return;
    }
    
    
    NSNumber *num = [NSNumber new];
    [animationDurationValue getValue:(__bridge void *)(num)];
    
    
    // 键盘的动画是变速的，设定与其完全保持一致
    NSNumber *animationCurveObject = [userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // 开始及执行动画
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[animationDurationValue doubleValue]];
    [UIView setAnimationCurve:(UIViewAnimationCurve)animationCurveObject];
    
    IMTableView.frame = newTableFrame;
    commentView.frame = newInputFieldFrame;
    [UIView commitAnimations];
    if (messageCount > 0  && IMTableView.contentSize.height> SCREEN_HEIGHT-keyboardRect.size.height-124) {
        [IMTableView scrollRectToVisible:CGRectMake(0, IMTableView.contentSize.height-1, 1, 1) animated:YES];
//        
//        [IMTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:messageCount-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    keyBoadShow = NO;
    [self.view removeGestureRecognizer:tapOnview];
    NSDictionary* userInfo = [notification userInfo];
    
    // 键盘的动画时间，设定与其完全保持一致
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    // 键盘的动画是变速的，设定与其完全保持一致
    NSValue *animationCurveObject =[userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey];
    NSUInteger animationCurve;
    [animationCurveObject getValue:&animationCurve];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:(UIViewAnimationCurve)animationCurve];
    
    commentView.frame = commentViewRect;
    IMTableView.frame = tableOriginRect;
    [UIView commitAnimations];
}



-(void)playnextMuzzikUpdate{
    [IMTableView reloadData];
}

-(void) showUserImageWithimageKey:(NSString *)imageKey holdImage:(UIImage *) holdImage orginalRect:(CGRect) rect{
    [userHeadImage setFrame:CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1)];
    [cellUserheadImage setFrame:CGRectMake(0, 0, 1, 1)];
    [cellUserheadImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",BaseURL_image,imageKey,Image_Size_Big]] placeholderImage:holdImage completed:NULL];
    [self.navigationController.view addSubview:userHeadImage];
    hideStatus = YES;
    [self setNeedsStatusBarAppearanceUpdate];
    [UIView animateWithDuration:0.3 animations:^{
        [userHeadImage setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        [cellUserheadImage setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    }];
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

-(void)tappedWithImage{
    hideStatus = NO;
    [self setNeedsStatusBarAppearanceUpdate];
    [UIView animateWithDuration:0.3 animations:^{
        [userHeadImage setFrame:CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1)];
        [cellUserheadImage setFrame:CGRectMake(0, 0, 1, 1)];
    } completion:^(BOOL finished) {
        [userHeadImage removeFromSuperview];
    }];
}

-(void)resetCellByMessage:(Message *)changedMessage{
    for (Message *newmessage in _con.messages) {
        if (newmessage  == changedMessage) {
            NSLog(@"-------------yes---------------");
        }
    }
    if ([_con.messages containsObject:changedMessage]) {
        NSInteger index = [_con.messages indexOfObject:changedMessage];
        NSIndexPath *indexpath;
        if (messageCount >= _con.messages.count) {
            indexpath =[NSIndexPath indexPathForRow:index inSection:0];
        }else{
            indexpath = [NSIndexPath indexPathForRow:index-_con.messages.count+messageCount inSection:0];

        }
        UITableViewCell *cell = [IMTableView cellForRowAtIndexPath:indexpath];
        if ([cell respondsToSelector:@selector(updateStatus:)]) {
            [cell performSelectorOnMainThread:@selector(updateStatus:) withObject:changedMessage.sendStatue waitUntilDone:YES];
        }
        
    }
    
    
    
}

-(void)inserCellWithMessage:(Message *)coreMessage{
    messageCount++;
    _con.unReadMessage = [NSNumber numberWithInt:0];
    if (![[userInfo shareClass].account.myConversation containsObject:_con]) {
        [[userInfo shareClass].account insertObject:_con inMyConversationAtIndex:0];
        AppDelegate *app = (AppDelegate *) [UIApplication sharedApplication].delegate;
        [app.managedObjectContext save:nil];
        
        
    }if ([_con.messages containsObject:coreMessage]) {
        NSInteger index = [_con.messages indexOfObject:coreMessage];
        
        if (messageCount >= _con.messages.count) {
            [IMTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            [IMTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            
        }else{
            [IMTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index-_con.messages.count+messageCount inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            [IMTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index-_con.messages.count+messageCount inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            
        }
    }
    
}


-(void)receiveInserCellWithMessage:(Message *)coreMessage{
    messageCount++;
    _con.unReadMessage = [NSNumber numberWithInt:0];
    if (![[userInfo shareClass].account.myConversation containsObject:_con]) {
        [[userInfo shareClass].account insertObject:_con inMyConversationAtIndex:0];
        AppDelegate *app = (AppDelegate *) [UIApplication sharedApplication].delegate;
        [app.managedObjectContext save:nil];
        
        
    }
    NSLog(@"contentSize:%f    contentOffset:%f",IMTableView.contentSize.height, IMTableView.contentOffset.y);
    
    if ([_con.messages containsObject:coreMessage]) {
        NSInteger index = [_con.messages indexOfObject:coreMessage];
        
        
        if (messageCount >= _con.messages.count) {
            if (IMTableView.contentSize.height - IMTableView.contentOffset.y <= SCREEN_HEIGHT-124) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [IMTableView beginUpdates];
                    [IMTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                    [IMTableView endUpdates];
                });
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [IMTableView scrollRectToVisible:CGRectMake(0, IMTableView.contentSize.height-1, 1, 1) animated:YES];
                    
                    NSLog(@"%f",IMTableView.contentSize.height);
                });
            }else{
                [IMTableView beginUpdates];
                [IMTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                [IMTableView endUpdates];
                [self getUnreadMessage];
            }
            
            
            
        }else{
            if (IMTableView.contentSize.height - IMTableView.contentOffset.y <= SCREEN_HEIGHT-124) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [IMTableView beginUpdates];
                    [IMTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index-_con.messages.count+messageCount inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                    [IMTableView endUpdates];
                });
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    
                    [IMTableView scrollRectToVisible:CGRectMake(0, IMTableView.contentSize.height-1, 1, 1) animated:YES];
                    
                    NSLog(@"%f",IMTableView.contentSize.height);
                });
         
            }else{
                [IMTableView beginUpdates];
                [IMTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index-_con.messages.count+messageCount inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                [IMTableView endUpdates];
                [self getUnreadMessage];
            }
        }

    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSLog(@"%f",scrollView.contentOffset.y);
    if (scrollView.contentOffset.y < -10) {
        if (_con.messages.count>messageCount && !loadingMore) {
            loadingMore = YES;
            [IMTableView setTableHeaderView:headerView];
            [activityView startAnimating];
            [self refreshHeader];
        }
        
        NSLog(@"刷新啦");
    }
    if (IMTableView.contentSize.height - IMTableView.contentOffset.y <= SCREEN_HEIGHT-124 && newMessgaeCount>0) {
        [messageCountView removeFromSuperview];
        newMessgaeCount = 0;
    }
    NSLog(@"%f",IMTableView.contentSize.height - IMTableView.contentOffset.y);
    
   
}
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (keyBoadShow) {
        [comnentTextView resignFirstResponder];
    }
}
-(void)seeMessage{
    [messageCountView removeFromSuperview];
    newMessgaeCount = 0;
    [IMTableView scrollRectToVisible:CGRectMake(0, IMTableView.contentSize.height-1, 1, 1) animated:YES];
}
-(void)removeCell:(UITableViewCell *)cell{
    
}

-(void)updateSynMusicMessage:(NSDictionary *)musicDic{
    if (listenMessage) {
        listenMessage.messageData = [NSJSONSerialization dataWithJSONObject:musicDic options:kNilOptions error:nil];
        NSInteger index = [_con.messages indexOfObject:listenMessage];
        if (messageCount >= _con.messages.count) {
            ListenCell *cell = [IMTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
            [cell updateMusicMessage];
        }
        else{
            ListenCell *cell = [IMTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index-_con.messages.count+messageCount inSection:0]];
            [cell updateMusicMessage];
        }
      
    }else{
        AppDelegate *app = (AppDelegate *) [UIApplication sharedApplication].delegate;
        listenMessage = [app getNewMessage];
        
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
