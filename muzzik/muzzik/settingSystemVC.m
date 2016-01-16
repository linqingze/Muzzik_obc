//
//  settingSystemVC.m
//  muzzik
//
//  Created by muzzik on 15/5/11.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "settingSystemVC.h"
#import "DraftBoxVC.h"
#import "SettingCell.h"
#import "TeachViewController.h"
#import "FeedBackVC.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import "UIImageView+WebCache.h"
#import "UMessage_Sdk_1.2.2/UMessage.h"
@interface settingSystemVC ()<UITableViewDataSource,UITableViewDelegate>{
    UITableView *settingTable;
    UIView *shareViewFull;
    UIView *shareView;
    UIButton *shareToTimeLineButton;
    UIButton *shareToWeiChatButton;
    UIButton *shareToWeiboButton;
    UIButton *shareToQQButton;
    UIButton *shareToQQZoneButton;
    CGFloat maxScaleY;
    UIAlertView *cleanAlert;
}

@end

@implementation settingSystemVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNagationBar:@"设置" leftBtn:Constant_backImage rightBtn:0];
    [self SettingShareView];
    settingTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
    settingTable.dataSource = self;
    settingTable.delegate = self;
    [settingTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:settingTable];
    [settingTable registerClass:[SettingCell class] forCellReuseIdentifier:@"SettingCell"];
    // Do any additional setup after loading the view from its nib.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [settingTable reloadData];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    SettingCell *Scell = [tableView dequeueReusableCellWithIdentifier:@"SettingCell" forIndexPath:indexPath];
    if (indexPath.row == 0) {
        
        Scell.label.text = @"摇一摇切歌";
        Scell.cellKeeper = self;
        [Scell.shakeSwitch setHidden:NO];
        [Scell.dataNum setHidden:YES];
        NSString * shakeSwitch = [MuzzikItem getStringForKey:@"User_shakeActionSwitch"];
        if (![shakeSwitch isEqualToString:@"close"]) {
            _isClosed = NO;
            [Scell.shakeSwitch setOn:YES ];
        }else{
            _isClosed = YES;
            [Scell.shakeSwitch setOn:NO];
        }
    }else if (indexPath.row == 1) {
        Scell.label.text = @"草稿箱";
        [Scell.shakeSwitch setHidden:YES];
        [Scell.dataNum setHidden:YES];
    }
    else if (indexPath.row == 2) {
        Scell.label.text = @"邀请好友一起来Muzzik";
        [Scell.shakeSwitch setHidden:YES];
        [Scell.dataNum setHidden:YES];
    }
    else if (indexPath.row == 3) {
        Scell.label.text = @"赏Muzzik 好评";
        [Scell.shakeSwitch setHidden:YES];
        [Scell.dataNum setHidden:YES];
        
    }else if (indexPath.row == 4) {
        Scell.label.text = @"意见反馈";
        [Scell.shakeSwitch setHidden:YES];
        [Scell.dataNum setHidden:YES];
    }else if (indexPath.row == 5) {
        Scell.label.text = @"关于Muzzik";
        [Scell.shakeSwitch setHidden:YES];
        [Scell.dataNum setHidden:YES];
    }else if (indexPath.row == 6) {
        [Scell.shakeSwitch setHidden:YES];
         [Scell.dataNum setHidden:NO];
        float totalSize = [[SDImageCache sharedImageCache] getSize]/(1024.0*1024);

        Scell.label.text = @"清除图片缓存数据";
        Scell.dataNum.text = [NSString stringWithFormat:@"%.2f M",totalSize];
    }
    else if(indexPath.row == 7){
        userInfo *user = [userInfo shareClass];
        if ([user.token length]>0) {
            Scell.label.text = @"退出账号";
        }else{
            Scell.label.text = @"登录账号";
        }
        [Scell.shakeSwitch setHidden:YES];
        [Scell.dataNum setHidden:YES];
    }
    return Scell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == 0) {

    }else if (indexPath.row == 1) {
        userInfo *user = [userInfo shareClass];
        if ([user.token length] >0) {
            DraftBoxVC *draftvc = [[DraftBoxVC alloc] init];
            [self.navigationController pushViewController:draftvc animated:YES];
        }else{
            [userInfo checkLoginWithVC:self];
        }
        
    }
    else if (indexPath.row == 2) {
        [self addShareView];
    }else if (indexPath.row == 3) {
        NSString *str = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@?mt=8",APP_ID ];
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]]; 

        
    }else if (indexPath.row == 4) {
        FeedBackVC *feedback = [[FeedBackVC alloc] init];
        [self.navigationController pushViewController:feedback animated:YES];
    }else if (indexPath.row == 5) {
        TeachViewController *teach = [[TeachViewController alloc] initWithNibName:@"TeachViewController" bundle:nil];
        teach.showType = @"about";
        [self.navigationController pushViewController:teach animated:YES];
    }else if (indexPath.row == 6){
        
        cleanAlert = [[UIAlertView alloc] initWithTitle:@"确认清除图片缓存" message:@"" delegate:self cancelButtonTitle:@"放弃" otherButtonTitles:nil];
        // optional - add more buttons:
        [cleanAlert addButtonWithTitle:@"确定"];
        [cleanAlert show];

        
    }
    else if (indexPath.row == 7){
        userInfo *user = [userInfo shareClass];
        if ([user.token length]>0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"确认退出登录" message:@"" delegate:self cancelButtonTitle:@"放弃" otherButtonTitles:nil];
            // optional - add more buttons:
            [alert addButtonWithTitle:@"确定"];
            [alert show];
        }else{
            [userInfo checkLoginWithVC:self];
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 8;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (alertView == cleanAlert) {
        if (buttonIndex == 1) {
            [[SDImageCache sharedImageCache] clearDisk];
            [settingTable reloadData];
        }
    }
    else if (buttonIndex == 1) {
        // do stuff
        userInfo *user = [userInfo shareClass];
        ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@api/notify/tokens/%@?type=APN",BaseURL,user.deviceToken]]];
        [request addBodyDataSourceWithJsonByDic:nil Method:DeleteMethod auth:YES];
        __weak ASIHTTPRequest *weakreq = request;
        [request setCompletionBlock :^{
            NSLog(@"%@",[weakreq responseString]);
            ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Logout]]];
            [requestForm addBodyDataSourceWithJsonByDic:nil Method:GetMethod auth:YES];
            __weak ASIHTTPRequest *weakrequest = requestForm;
            [requestForm setCompletionBlock :^{
                NSLog(@"%@",[weakrequest responseString]);
                NSLog(@"%d",[weakrequest responseStatusCode]);
                if ([weakrequest responseStatusCode] == 200) {
                    userInfo *user = [userInfo shareClass];
                    [UMessage removeAlias:user.uid type:kUMessageAliasTypeSina response:^(id responseObject, NSError *error) {
                        NSLog(@"%@",responseObject);
                    }];
                    user.token = @"";
                    user.uid = @"";
                    user.avatar = @"";
                    user.name = @"";
                    user.gender = @"";
                    user.isSwitchUser = YES;
                    [MuzzikItem removeMessageFromLocal:@"LoginAcess"];
                    
                    [settingTable reloadData];
                    [userInfo checkLoginWithVC:self];
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
            
        }];
        [request setFailedBlock:^{
            NSLog(@"%@",[weakreq error]);
        }];
        [request startAsynchronous];
        
       
        
    }else{
        
    }

    
}
-(void)reloadTable{
    [settingTable reloadData];
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
    [UIView animateWithDuration:0.5 animations:^{
        [shareViewFull setAlpha:0];
        [shareView setFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_WIDTH*maxScaleY)];
    } completion:^(BOOL finished) {
        [shareViewFull removeFromSuperview];
        
    }];
}
-(void) addShareView{
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
    
    message.text =[NSString stringWithFormat:@"一起来用Muzzik吧 %@",URL_Muzzik_download];
    
    WBImageObject *image = [WBImageObject object];
    image.imageData = UIImageJPEGRepresentation([UIImage imageNamed:@"startImage"], 1.0);
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
}
-(void) shareQQ{
    TencentOAuth *tencentOAuth = [[TencentOAuth alloc] initWithAppId:ID_QQ_APP
                                                         andDelegate:nil];
    NSString *url = URL_Muzzik_download;
    UIImage *image = [UIImage imageNamed:@"logo"];
    QQApiNewsObject* img = [QQApiNewsObject objectWithURL:[NSURL URLWithString:url] title:@"一起来用Muzzik吧" description:@"听最喜欢的歌，遇见最好的Ta" previewImageData:UIImagePNGRepresentation(image)];
    SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:img];
    
    
    //将被容分享到qzone
    QQApiSendResultCode sent = [QQApiInterface sendReq:req];
    [self handleSendResult:sent];
    
    
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
    NSString *url = URL_Muzzik_download;
    UIImage *image = [UIImage imageNamed:@"logo"];
    QQApiNewsObject* img = [QQApiNewsObject objectWithURL:[NSURL URLWithString:url] title:@"一起来用Muzzik吧" description:@"听最喜欢的歌，遇见最好的Ta" previewImageData:UIImagePNGRepresentation(image)];
    SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:img];
    
    
    //将被容分享到qzone
    QQApiSendResultCode sent = [QQApiInterface SendReqToQZone:req];
    [self handleSendResult:sent];

    
}
-(void) shareTimeLine{
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [app weCahtsendMusicContentByscen:1];


}

-(void) shareWeChat{
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [app weCahtsendMusicContentByscen:0];

}

-(void)dealloc{
    userInfo *user = [userInfo shareClass];
    
    if ([user.token length] == 0 ) {
        AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [app.tabviewController setSelectedViewController:app.feedVC];
        [app.tabviewController setSelectedIndex:0];
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
