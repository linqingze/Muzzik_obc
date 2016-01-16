//
//  IMConversationViewcontroller.m
//  muzzik
//
//  Created by muzzik on 15/12/30.
//  Copyright © 2015年 muzziker. All rights reserved.
//

#import "IMConversationViewcontroller.h"
#import "ownerTableViewCell.h"
#import "HPGrowingTextView.h"
@interface IMConversationViewcontroller ()<UITableViewDataSource,UITableViewDelegate,HPGrowingTextViewDelegate>{
    UITableView *IMTableView;
    UIView *IMTalkView;
    NSInteger messageCount;
    UIView *commentView;
    HPGrowingTextView *comnentTextView;
    CGRect tableOriginRect;
    CGRect commentViewRect;
    
    UITapGestureRecognizer *tapOnview;
}

@end

@implementation IMConversationViewcontroller

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    messageCount = 20>_con.messages.count ? _con.messages.count:20;
    tapOnview = [[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)];
    
    [self settingTableView];
    [self settingTalkView];
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playnextMuzzikUpdate) name:String_SetSongPlayNextNotification object:nil];
    if ([[userInfo shareClass].account.myConversation containsObject:_con]) {
        NSLog(@"contain");
    }
    [super viewWillAppear:animated];
    if (messageCount > 0) {
        [IMTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:messageCount-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
   
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}
-(void) settingTableView{
    IMTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-124)];
    IMTableView.backgroundColor = [UIColor whiteColor];
    IMTableView.delegate = self;
    IMTableView.dataSource = self;
    IMTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [IMTableView registerClass:[ownerTableViewCell class] forCellReuseIdentifier:@"ownerTableViewCell"];
    [self.view addSubview:IMTableView];
    tableOriginRect = IMTableView.frame;
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
    NSLog(@"%d",_con.messages.count);
    if (messageCount >= _con.messages.count) {
        message = _con.messages[indexPath.row];
    }else{
        message = _con.messages[indexPath.row+_con.messages.count-messageCount];
    }
    
//    NSLog(@"%@",message.cellHeight);
    if ([message.cellHeight integerValue] == 0) {
        CGFloat height = 0;
        if ([message.needsToShowTime boolValue]) {
            height += 40;
        }else{
            height+=16;
        }
        if ([message.messageType isEqualToString:Type_IM_TextMessage]) {
            UILabel *_messageLabel = [[UILabel alloc] init];
            _messageLabel.numberOfLines = 0;
            [_messageLabel setFont:[UIFont fontWithName:Font_Next_Regular size:15]];
            [_messageLabel setFrame:CGRectMake(0, 0, SCREEN_WIDTH-126, 1000)];
            _messageLabel.text = message.messageContent;
            [_messageLabel sizeToFit];
            message.cellHeight = [NSNumber numberWithDouble:height+ _messageLabel.frame.size.height+22];
        }else if ([message.messageType isEqualToString:Type_IM_ShareMuzzik]){
            message.cellHeight = [NSNumber numberWithDouble:height+78];
        }
        
        
    }
    return [message.cellHeight doubleValue];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     ownerTableViewCell*  cell = [tableView dequeueReusableCellWithIdentifier:@"ownerTableViewCell" forIndexPath:indexPath];
    Message *message;
    cell.imvc = self;
    if (messageCount >= _con.messages.count) {
        message = _con.messages[indexPath.row];
    }else{
        message = _con.messages[indexPath.row+_con.messages.count-messageCount];
    }
    [cell configureCellWithMessage:message];
    return cell;
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
        __block Message *newMessgae = [app getNewMessage];
        newMessgae.messageType = Type_IM_TextMessage;
        newMessgae.sendTime = [NSDate date];
        newMessgae.messageContent = growingTextView.text;
        newMessgae.abstractString = growingTextView.text;;
        newMessgae.messageUser = [userInfo shareClass].account.ownerUser;
        newMessgae.isOwner = [NSNumber numberWithBool:YES];
        NSLog(@"%@",_con.sendTime);

        if ([app checkLimitedTime:newMessgae.sendTime oldDate:_con.sendTime]) {
            newMessgae.needsToShowTime = [NSNumber numberWithBool:YES];
        }else{
            newMessgae.needsToShowTime = [NSNumber numberWithBool:NO];
        }
        _con.sendTime = [NSDate date];
        [_con addMessagesObject:newMessgae];
        _con.abstractString = growingTextView.text;
        if (![[userInfo shareClass].account.myConversation containsObject:_con]) {
            [[userInfo shareClass].account insertObject:_con inMyConversationAtIndex:0];
        }else{
            NSLog(@"contain");
        }
        messageCount++;
        dispatch_async(dispatch_get_main_queue(), ^{
            [IMTableView reloadData];
            [IMTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:messageCount-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            growingTextView.text = @"";
        });
        
        [[RCIMClient sharedRCIMClient] sendMessage:ConversationType_PRIVATE
                                          targetId:_con.targetId
                                           content:rctext
                                       pushContent:nil
                                          pushData:nil
                                           success:^(long messageId) {
                                               newMessgae.sendStatue = @"ok";
                                               [app.managedObjectContext save:nil];
                                           } error:^(RCErrorCode nErrorCode, long messageId) {
                                               newMessgae.sendStatue = @"error";
                                               NSLog(@"发送失败。消息ID：%@， 错误码：%d", messageId, nErrorCode);
                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                   [IMTableView reloadData];
                                               });
                                               
                                           }];
    }
    return YES;
}

-(void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView{
    
}


#pragma mark - 监听键盘高度改变事件

- (void)keyboardWillShow:(NSNotification *)notification
{
    [self.view addGestureRecognizer:tapOnview];
    
    
    NSDictionary *userInfo = [notification userInfo];
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    CGRect keyboardRect = [aValue CGRectValue];
    if (messageCount > 0  && IMTableView.contentSize.height> SCREEN_HEIGHT-keyboardRect.size.height) {
        [IMTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:messageCount-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    //
    CGRect newTableFrame = tableOriginRect;
    newTableFrame.size.height += -keyboardRect.size.height;
    IMTableView.contentOffset = CGPointMake(0, IMTableView.contentOffset.y+keyboardRect.size.height);
    
    
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
}

- (void)keyboardWillHide:(NSNotification *)notification
{
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

-(void)inserCellWithMessage:(Message *)coreMessage{
    NSLog(@"%@",_con);
    messageCount++;
    _con.unReadMessage = [NSNumber numberWithInt:0];
    [IMTableView reloadData];
    [IMTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:messageCount-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    if (![[userInfo shareClass].account.myConversation containsObject:_con]) {
        [[userInfo shareClass].account insertObject:_con inMyConversationAtIndex:0];
    }else{
         NSLog(@"contain");
    }
    
//    [IMTableView beginUpdates];
//    [IMTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:messageCount-1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
//    [IMTableView endUpdates];
}

-(void)playnextMuzzikUpdate{
    [IMTableView reloadData];
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
