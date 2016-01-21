//
//  IMConversationViewcontroller.m
//  muzzik
//
//  Created by muzzik on 15/12/30.
//  Copyright © 2015年 muzziker. All rights reserved.
//

#import "IMConversationViewcontroller.h"
#import "IMTextCell.h"
#import "IMshareCell.h"
#import "HPGrowingTextView.h"
#import "UIImageView+WebCache.h"
#import "YYTextView.h"
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
}

@end

@implementation IMConversationViewcontroller

- (void)viewDidLoad {
    [super viewDidLoad];
    userHeadImage = [[UIView alloc] init];
    [userHeadImage setBackgroundColor:[UIColor blackColor]];
    statueLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
    statueLabel.textAlignment = NSTextAlignmentCenter;

    cellUserheadImage = [[UIImageView alloc] init];
    cellUserheadImage.contentMode = UIViewContentModeScaleAspectFit;
    [userHeadImage addSubview:cellUserheadImage];
    [userHeadImage addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedWithImage)]];
    [self initNagationBar:self.title leftBtn:Constant_backImage rightBtn:0];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
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
    if (messageCount > 0 ) {
        messageCount = messageCount>_con.messages.count ? _con.messages.count :messageCount;
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
    [IMTableView registerClass:[IMTextCell class] forCellReuseIdentifier:@"IMTextCell"];
    [IMTableView registerClass:[IMshareCell class] forCellReuseIdentifier:@"IMshareCell"];
    [self.view addSubview:IMTableView];
    tableOriginRect = IMTableView.frame;
    if (_con.messages.count>15) {
        [IMTableView addHeaderWithTarget:self action:@selector(refreshHeader)];
        [IMTableView setHeaderRefreshingText:@"稍等..."];
        [IMTableView setHeaderPullToRefreshText:@"下拉查看历史"];
        [IMTableView setHeaderReleaseToRefreshText:@"松开查看"];
        [IMTableView hideTimeLabel];
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
-(void)refreshHeader{
    messageCount +=15;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (messageCount > _con.messages.count) {
            [IMTableView setHeaderHidden:YES];
            [IMTableView headerEndRefreshing];
            [IMTableView removeHeader];
            messageCount = _con.messages.count;
        }else{
           [IMTableView headerEndRefreshing];
        }
        [IMTableView reloadData];
        [IMTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:messageCount-15 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    });
}

-(void)connectionChanged:(RCConnectionStatus)status{
    [statueLabel setAlpha:1];
    if (status == ConnectionStatus_Connected) {
        statueLabel.text = @"成功连接至服务器";
        [statueLabel setBackgroundColor:[UIColor greenColor]];
    }
    [self.view addSubview:statueLabel];
    [UIView animateWithDuration:2 animations:^{
        [statueLabel setAlpha:0];
    } completion:^(BOOL finished) {
        [statueLabel removeFromSuperview];
    }];
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
            height += 40;
        }else{
            height+=16;
        }
        if ([message.messageType isEqualToString:Type_IM_TextMessage]) {
            YYTextView *_messageLabel = [[YYTextView alloc] init];
            [_messageLabel setFont:[UIFont fontWithName:Font_Next_Regular size:15]];
            [_messageLabel setFrame:CGRectMake(0, 0, SCREEN_WIDTH-126, 1000)];
            _messageLabel.text = message.messageContent;
            [_messageLabel sizeToFit];
            message.cellHeight = [NSNumber numberWithDouble:height+ _messageLabel.frame.size.height+17];
        }else if ([message.messageType isEqualToString:Type_IM_ShareMuzzik]){
            message.cellHeight = [NSNumber numberWithDouble:height+78];
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
    if ([message.messageType isEqualToString:Type_IM_TextMessage]) {
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
        NSLog(@"%@",_con.targetUser.name);
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
    if (messageCount > 0  && IMTableView.contentSize.height> SCREEN_HEIGHT-keyboardRect.size.height) {
         IMTableView.contentOffset = CGPointMake(0, IMTableView.contentOffset.y+keyboardRect.size.height);
    }
   
    
    
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
-(BOOL)prefersStatusBarHidden{
    return hideStatus;
}

-(void)resetCellByMessage:(Message *)changedMessage{
    if ([_con.messages containsObject:changedMessage]) {
        NSInteger index = [_con.messages indexOfObject:changedMessage];
        if (messageCount >= _con.messages.count) {
            [IMTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }else{
            [IMTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index-_con.messages.count+messageCount inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }

    }
    
    for (Message *newmessage in _con.messages) {
        if (newmessage  == changedMessage) {
            NSLog(@"-------------yes---------------");
        }
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
