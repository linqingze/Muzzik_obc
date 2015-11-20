//
//  ShareResultViewController.m
//  muzzik
//
//  Created by muzzik on 15/11/10.
//  Copyright © 2015年 muzziker. All rights reserved.
//

#import "ShareResultViewController.h"
#import "ASIFormDataRequest.h"
#import <TencentOpenAPI/TencentOAuth.h>
#define View_Padding_Width 16
#define View_Inter_Width  16
@interface ShareResultViewController (){
    UIView *baseLine;
    UIView *musicPlayView;
    UILabel *musicName;
    UILabel *musicArtist;
    UIImageView *likeButton;
    UIImageView *playButton;
    UILabel *message;
    
    UIView *shareChannelView;
    UIButton *weiboShare;
    UIButton *weChatshare;
    UIButton *QQZoneShare;
    
    BOOL isShareToWeiChat;
    BOOL isShareToWeiBo;
    BOOL isShareToQQ;
    
    BOOL isSending;
    UIScrollView *mainScroll;
    muzzik *newmuzzik;
}

@end

@implementation ShareResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNagationBar:@"发布并分享" leftBtn:Constant_backImage rightBtn:5];
    mainScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
    [self.view addSubview: mainScroll];
    
    musicPlayView = [[UIView alloc] initWithFrame:CGRectMake(View_Padding_Width, View_Padding_Width, SCREEN_WIDTH-2*View_Padding_Width, 100)];
    musicPlayView.layer.borderColor = Color_line_1.CGColor;
    musicPlayView.layer.borderWidth = 1;
    MuzzikObject *mobject = [MuzzikObject shareClass];
    musicPlayView.layer.cornerRadius = 3;
    musicPlayView.layer.masksToBounds = YES;
    message = [[UILabel alloc] initWithFrame:CGRectMake(View_Inter_Width, View_Inter_Width, musicPlayView.frame.size.width-2*View_Inter_Width, 30)];
    [message setFont:[UIFont systemFontOfSize:Font_Size_Muzzik_Message]];
    message.numberOfLines = 0;
    [message setTextColor:Color_Text_2];
    if ([mobject.message length]>0) {
       [message setText:mobject.message];
    }else{
        [message setText:@"I Love This Muzzik!"];
    }
    [message sizeToFit];
    
    [musicPlayView addSubview:message];
    
    baseLine = [[UIView alloc] initWithFrame:CGRectMake(View_Inter_Width, CGRectGetMaxY(message.frame)+11, musicPlayView.frame.size.width-View_Inter_Width*2, 1)];
    
    [baseLine setBackgroundColor:Color_Active_Button_1];
    
    [musicPlayView addSubview:baseLine];
    
    likeButton = [[UIImageView alloc] initWithFrame:CGRectMake(View_Inter_Width, CGRectGetMaxY(baseLine.frame)+10, 36, 36)];
    [likeButton setImage:[UIImage imageNamed:@"shareorangelikeImage"]];
    [musicPlayView addSubview:likeButton];
    playButton = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(baseLine.frame)-36, CGRectGetMaxY(baseLine.frame)+10, 36, 36)];
    [playButton setImage:[UIImage imageNamed:@"shareorangeplayImage"]];
    [musicPlayView addSubview:playButton];
    
    musicName = [[UILabel alloc] initWithFrame:CGRectMake(View_Inter_Width+55, CGRectGetMaxY(baseLine.frame)+8, SCREEN_WIDTH-150, 20)];
    [musicName setFont:[UIFont fontWithName:Font_Next_Bold size:15]];
    [musicName setTextColor:[UIColor colorWithHexString:@"f26d7d"]];
    musicName.text = mobject.music.name;
    [musicPlayView addSubview:musicName];
    musicArtist = [[UILabel alloc] initWithFrame:CGRectMake(View_Inter_Width+55, CGRectGetMaxY(baseLine.frame)+29, SCREEN_WIDTH-150, 25)];
    [musicArtist setFont:[UIFont fontWithName:Font_Next_Bold size:12]];
    [musicArtist setTextColor:[UIColor colorWithHexString:@"f26d7d"]];
    musicArtist.text = mobject.music.artist;
    [musicPlayView addSubview:musicArtist];
    if (self.poImage) {
        UIImageView *picture = [[UIImageView alloc] initWithFrame:CGRectMake(View_Inter_Width, CGRectGetMaxY(baseLine.frame)+55, baseLine.frame.size.width,  baseLine.frame.size.width)];
        picture.layer.cornerRadius = 3;
        picture.clipsToBounds = YES;
        [picture setImage:self.poImage];
        [musicPlayView addSubview:picture];
        [musicPlayView setFrame:CGRectMake(View_Padding_Width, View_Padding_Width, SCREEN_WIDTH-2*View_Padding_Width, CGRectGetMaxY(baseLine.frame)+55+baseLine.frame.size.width+View_Inter_Width)];
    }else{
        [musicPlayView setFrame:CGRectMake(View_Padding_Width, View_Padding_Width, SCREEN_WIDTH-2*View_Padding_Width, CGRectGetMaxY(likeButton.frame)+View_Inter_Width)];
    }
    [mainScroll addSubview:musicPlayView];
    
    shareChannelView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(musicPlayView.frame)+10, SCREEN_WIDTH, 90)];
    UILabel *notify = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, SCREEN_WIDTH-32, 30)];
    [notify setFont:[UIFont systemFontOfSize:14]];
    [notify setTextColor:Color_Text_2];
    [notify setText:@"让小伙伴们也来听听"];
    [shareChannelView addSubview:notify];
    UIView *underLine = [[UIView alloc] initWithFrame:CGRectMake(View_Padding_Width, 30, SCREEN_WIDTH-View_Padding_Width *2, 1)];
    [underLine setBackgroundColor:Color_line_1];
    [shareChannelView addSubview:notify];
    [shareChannelView addSubview:underLine];
    
    userInfo *user = [userInfo shareClass];
    if (user.WeChatInstalled && user.QQInstalled) {
        isShareToWeiChat = YES;
        weiboShare = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-45, 30, 90, 60)];
        weChatshare = [[UIButton alloc] initWithFrame:CGRectMake(16, 30, 90, 60)];
        QQZoneShare = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-106, 30, 90, 60)];
        
        [weiboShare setImage:[UIImage imageNamed:@"shareunselectedweibo"] forState:UIControlStateNormal];
        [weChatshare setImage:[UIImage imageNamed:@"sharefriendcircle"] forState:UIControlStateNormal];
        [QQZoneShare setImage:[UIImage imageNamed:@"shareunselectedqzone"] forState:UIControlStateNormal];
        
        [QQZoneShare addTarget:self action:@selector(setChannelShare:) forControlEvents:UIControlEventTouchUpInside];
        [weChatshare addTarget:self action:@selector(setChannelShare:) forControlEvents:UIControlEventTouchUpInside];
        [weiboShare addTarget:self action:@selector(setChannelShare:) forControlEvents:UIControlEventTouchUpInside];
        
        [shareChannelView addSubview:QQZoneShare];
        [shareChannelView addSubview:weiboShare];
        [shareChannelView addSubview:weChatshare];
        
    }
    else if(user.WeChatInstalled || user.QQInstalled){
        if (user.WeChatInstalled) {
            isShareToWeiChat = YES;
            weiboShare = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-45, 30, 90, 60)];
            weChatshare = [[UIButton alloc] initWithFrame:CGRectMake(16, 30, 90, 60)];
            
            [weiboShare setImage:[UIImage imageNamed:@"shareunselectedweibo"] forState:UIControlStateNormal];
            [weChatshare setImage:[UIImage imageNamed:@"sharefriendcircle"] forState:UIControlStateNormal];
            
            [weChatshare addTarget:self action:@selector(setChannelShare:) forControlEvents:UIControlEventTouchUpInside];
            [weiboShare addTarget:self action:@selector(setChannelShare:) forControlEvents:UIControlEventTouchUpInside];
            
            [shareChannelView addSubview:weiboShare];
            [shareChannelView addSubview:weChatshare];
            
        }else{
            isShareToWeiBo = YES;
            weiboShare = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-45, 30, 90, 60)];
            QQZoneShare = [[UIButton alloc] initWithFrame:CGRectMake(16, 30, 90, 60)];
            
            [weiboShare setImage:[UIImage imageNamed:@"shareweibo"] forState:UIControlStateNormal];
            [QQZoneShare setImage:[UIImage imageNamed:@"shareunselectedqzone"] forState:UIControlStateNormal];
            
            [QQZoneShare addTarget:self action:@selector(setChannelShare:) forControlEvents:UIControlEventTouchUpInside];
            [weiboShare addTarget:self action:@selector(setChannelShare:) forControlEvents:UIControlEventTouchUpInside];
            [shareChannelView addSubview:QQZoneShare];
            [shareChannelView addSubview:weiboShare];
            
        }
    }
    else{
        isShareToWeiBo = YES;
        weiboShare = [[UIButton alloc] initWithFrame:CGRectMake(16, 30, 90, 60)];
        [weiboShare setImage:[UIImage imageNamed:@"shareweibo"] forState:UIControlStateNormal];
        [weiboShare addTarget:self action:@selector(setChannelShare:) forControlEvents:UIControlEventTouchUpInside];
        [shareChannelView addSubview:weiboShare];
        
    }
    if (self.poImage) {
        
        [shareChannelView setFrame:CGRectMake(0, SCREEN_HEIGHT-154, SCREEN_WIDTH, 90)];
        [self.view addSubview:shareChannelView];
        [mainScroll setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-164)];
        [mainScroll setContentSize:CGSizeMake(SCREEN_WIDTH, CGRectGetMaxY(musicPlayView.frame)+10)];
    }else{
        [shareChannelView setFrame:CGRectMake(0, CGRectGetMaxY(musicPlayView.frame)+10, SCREEN_WIDTH, 90)];
        [mainScroll addSubview:shareChannelView];
        [mainScroll setContentSize:CGSizeMake(SCREEN_WIDTH, CGRectGetMaxY(musicPlayView.frame)+100)];
        
    }
    // Do any additional setup after loading the view.
}



-(void)setChannelShare:(id)sender{
    if (sender == weChatshare) {
        if (isShareToWeiChat) {
            isShareToWeiChat = NO;
            [weChatshare setImage:[UIImage imageNamed:@"shareunselectedfriendcircle"] forState:UIControlStateNormal];
        }else{
            isShareToQQ = NO;
            isShareToWeiBo = NO;
            isShareToWeiChat = YES;
            [QQZoneShare setImage:[UIImage imageNamed:@"shareunselectedqzone"] forState:UIControlStateNormal];
            [weiboShare setImage:[UIImage imageNamed:@"shareunselectedweibo"] forState:UIControlStateNormal];
            [weChatshare setImage:[UIImage imageNamed:@"sharefriendcircle"] forState:UIControlStateNormal];
        }
    }
    else if (sender == weiboShare) {
        if (isShareToWeiBo) {
            isShareToWeiBo = NO;
            [weiboShare setImage:[UIImage imageNamed:@"shareunselectedweibo"] forState:UIControlStateNormal];
        }else{
            isShareToQQ = NO;
            isShareToWeiBo = YES;
            isShareToWeiChat = NO;
            [QQZoneShare setImage:[UIImage imageNamed:@"shareunselectedqzone"] forState:UIControlStateNormal];
            [weiboShare setImage:[UIImage imageNamed:@"shareweibo"] forState:UIControlStateNormal];
            [weChatshare setImage:[UIImage imageNamed:@"shareunselectedfriendcircle"] forState:UIControlStateNormal];
        }
    }
    else if (sender == QQZoneShare) {
        if (isShareToQQ) {
            isShareToQQ = NO;
            [QQZoneShare setImage:[UIImage imageNamed:@"shareunselectedqzone"] forState:UIControlStateNormal];
        }else{
            isShareToQQ = YES;
            isShareToWeiBo = NO;
            isShareToWeiChat = NO;
            [QQZoneShare setImage:[UIImage imageNamed:@"shareqzone"] forState:UIControlStateNormal];
            [weiboShare setImage:[UIImage imageNamed:@"shareunselectedweibo"] forState:UIControlStateNormal];
            [weChatshare setImage:[UIImage imageNamed:@"shareunselectedfriendcircle"] forState:UIControlStateNormal];
        }
    }
}


-(void)rightBtnAction:(UIButton *)sender{
    MuzzikObject *mobject = [MuzzikObject shareClass];
    userInfo *user = [userInfo shareClass];
    if (self.poImage) {
        ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString : [NSString stringWithFormat:@"%@%@",BaseURL,URL_Upload_Image]]];
        
        [requestForm addBodyDataSourceWithJsonByDic:nil Method:GetMethod auth:YES];
        __weak ASIHTTPRequest *weakrequest = requestForm;
        [requestForm setCompletionBlock :^{
            NSLog(@"%@    %@",[weakrequest originalURL],[weakrequest requestHeaders]);
            NSLog(@"%@",[weakrequest responseHeaders]);
            NSLog(@"%@",[weakrequest responseString]);
            NSLog(@"%d",[weakrequest responseStatusCode]);
            if ([weakrequest responseStatusCode] == 200) {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData] options:NSJSONReadingMutableContainers error:nil];
                
                ASIFormDataRequest *interRequest = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:[dic objectForKey:@"url"]]];
                [ASIFormDataRequest clearSession];
                [interRequest setPostFormat:ASIMultipartFormDataPostFormat];
                [interRequest setPostValue:[[dic objectForKey:@"data"] objectForKey:@"token"] forKey:@"token"];
                NSData *imageData = UIImageJPEGRepresentation(self.poImage, 1);
                [interRequest addData:imageData forKey:@"file"];
                __weak ASIFormDataRequest *form = interRequest;
                [interRequest buildRequestHeaders];
                NSLog(@"header:%@",interRequest.requestHeaders);
                [interRequest setCompletionBlock:^{
                    NSDictionary *keydic = [NSJSONSerialization JSONObjectWithData:[form responseData] options:NSJSONReadingMutableContainers error:nil];
                    mobject.imageKey = [keydic objectForKey:@"key"];
                    ASIHTTPRequest *shareRequest = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL,URL_Muzzik_new]]];
                    NSMutableDictionary *requestDic = [NSMutableDictionary dictionary];
                    if (mobject.isPrivate) {
                        [requestDic setObject:[NSNumber numberWithBool:YES] forKey:Parameter_private];
                    }
                    if ([mobject.imageKey length]>0) {
                        [requestDic setObject:mobject.imageKey forKey:Parameter_image_key];
                    }
                    if ([mobject.message length]>0) {
                        [requestDic setObject:mobject.message forKey:Parameter_message];
                    }else{
                        [requestDic setObject:@"I Love This Muzzik!" forKey:Parameter_message];
                    }
                    NSDictionary *musicDic = [NSDictionary dictionaryWithObjectsAndKeys:mobject.music.key,@"key",mobject.music.name,@"name",mobject.music.artist,@"artist", nil];
                    [requestDic setObject:musicDic forKey:@"music"];
                    [shareRequest addBodyDataSourceWithJsonByDic:requestDic Method:PutMethod auth:YES];
                    __weak ASIHTTPRequest *weakShare = shareRequest;
                    [shareRequest setCompletionBlock:^{
                        NSLog(@"data:%@",[weakShare responseString]);
                        if ([weakShare responseStatusCode] == 200) {
                            isSending = NO;
                           
                            NSDictionary *muzzikDic = [NSJSONSerialization JSONObjectWithData:[weakShare responseData] options:NSJSONReadingMutableContainers error:nil];
                            [self setPoMuzzikMessage:muzzikDic];
                            if (isShareToWeiChat) {
                                AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
                                [app sendMusicContentByMuzzik:newmuzzik scen:1 image:user.userHeadThumb];
                            }
                            else if (isShareToQQ) {
                                TencentOAuth *tencentOAuth = [[TencentOAuth alloc] initWithAppId:ID_QQ_APP
                                                                                     andDelegate:nil];
                                NSString *url = [NSString stringWithFormat:@"%@%@",URL_Muzzik_SharePage,newmuzzik.muzzik_id];
                                //分享图预览图URL地址
                                NSString *previewImageUrl = @"http://muzzik-image.qiniudn.com/FieqckeQDGWACSpDA3P0aDzmGcB6";
                                //音乐播放的网络流媒体地址
                                QQApiAudioObject *audioObj =[QQApiAudioObject objectWithURL:[NSURL URLWithString:url]
                                                                                      title:newmuzzik.music.name description:newmuzzik.music.artist previewImageURL:[NSURL URLWithString:previewImageUrl]];
                                //设置播放流媒体地址
                                audioObj.flashURL=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL_audio,newmuzzik.music.key]];
                                SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:audioObj];
                                //将内容分享到qq
                                
                                QQApiSendResultCode sent = [QQApiInterface sendReq:req];
                                [self handleSendResult:sent];
                            }
                            else if(isShareToWeiBo){
                                AppDelegate *myDelegate =(AppDelegate*)[[UIApplication sharedApplication] delegate];
                                
                                WBAuthorizeRequest *authRequest = [WBAuthorizeRequest request];
                                authRequest.redirectURI = URL_WeiBo_redirectURI;
                                authRequest.scope = @"all";
                                
                                WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:[self messageToShare] authInfo:authRequest access_token:myDelegate.wbtoken];
                                
                                //    request.shouldOpenWeiboAppInstallPageIfNotInstalled = NO;
                                [WeiboSDK sendRequest:request];
                            }
                            [mobject clearObject];
                            [self.navigationController popToViewController:user.poController animated:YES];
                            user.poController = nil;
                        }
                    }];
                    [shareRequest setFailedBlock:^{
                        isSending = NO;
                        [MuzzikItem showNotifyOnView:self.view text:@"muzzik发送失败，请确认网络状态再次重试"];
                    }];
                    [shareRequest startAsynchronous];
                }];
                [interRequest setFailedBlock:^{
                    isSending = NO;
                    [MuzzikItem showNotifyOnView:self.view text:@"图片上传请求失败，请确认网络状态再次重试"];
                }];
                [interRequest startAsynchronous];
            }
        }];
        [requestForm setFailedBlock:^{
            isSending = NO;
            [MuzzikItem showNotifyOnView:self.view text:@"图片上传地址请求失败，请确认网络状态再次重试"];
        }];
        [requestForm startAsynchronous];
    }
    else{
        ASIHTTPRequest *shareRequest = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL,URL_Muzzik_new]]];
        NSMutableDictionary *requestDic = [NSMutableDictionary dictionary];
        if (mobject.isPrivate) {
            [requestDic setObject:[NSNumber numberWithBool:YES] forKey:Parameter_private];
        }
        if ([mobject.message length]>0) {
            [requestDic setObject:mobject.message forKey:Parameter_message];
        }else{
            [requestDic setObject:@"I Love This Muzzik!" forKey:Parameter_message];
        }
        NSDictionary *musicDic = [NSDictionary dictionaryWithObjectsAndKeys:mobject.music.key,@"key",mobject.music.name,@"name",mobject.music.artist,@"artist", nil];
        [requestDic setObject:musicDic forKey:@"music"];
        [shareRequest addBodyDataSourceWithJsonByDic:requestDic Method:PutMethod auth:YES];
        __weak ASIHTTPRequest *weakShare = shareRequest;
        [shareRequest setCompletionBlock:^{
            NSLog(@"data:%@",[weakShare responseString]);
            if ([weakShare responseStatusCode] == 200) {
                isSending = NO;
                
                NSDictionary *muzzikDic = [NSJSONSerialization JSONObjectWithData:[weakShare responseData] options:NSJSONReadingMutableContainers error:nil];
                [self setPoMuzzikMessage:muzzikDic];
                if (isShareToWeiChat) {
                    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
                    [app sendMusicContentByMuzzik:newmuzzik scen:1 image:user.userHeadThumb];
                }
                else if (isShareToQQ) {
                    TencentOAuth *tencentOAuth = [[TencentOAuth alloc] initWithAppId:ID_QQ_APP
                                                                         andDelegate:nil];
                    NSString *url = [NSString stringWithFormat:@"%@%@",URL_Muzzik_SharePage,newmuzzik.muzzik_id];
                    //分享图预览图URL地址
                    NSString *previewImageUrl = @"http://muzzik-image.qiniudn.com/FieqckeQDGWACSpDA3P0aDzmGcB6";
                    //音乐播放的网络流媒体地址
                    QQApiAudioObject *audioObj =[QQApiAudioObject objectWithURL:[NSURL URLWithString:url]
                                                                          title:newmuzzik.music.name description:newmuzzik.music.artist previewImageURL:[NSURL URLWithString:previewImageUrl]];
                    //设置播放流媒体地址
                    audioObj.flashURL=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL_audio,newmuzzik.music.key]];
                    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:audioObj];
                    //将内容分享到qq
                    
                    QQApiSendResultCode sent = [QQApiInterface sendReq:req];
                    [self handleSendResult:sent];
                }
                else if(isShareToWeiBo){
                    AppDelegate *myDelegate =(AppDelegate*)[[UIApplication sharedApplication] delegate];
                    
                    WBAuthorizeRequest *authRequest = [WBAuthorizeRequest request];
                    authRequest.redirectURI = URL_WeiBo_redirectURI;
                    authRequest.scope = @"all";
                    
                    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:[self messageToShare] authInfo:authRequest access_token:myDelegate.wbtoken];
                    
                    //    request.shouldOpenWeiboAppInstallPageIfNotInstalled = NO;
                    [WeiboSDK sendRequest:request];
                }
                
                [mobject clearObject];
                [self.navigationController popToViewController:user.poController animated:YES];
                user.poController = nil;
            }
        }];
        [shareRequest setFailedBlock:^{
            isSending = NO;
            [MuzzikItem showNotifyOnView:self.view text:@"muzzik发送失败，请确认网络状态再次重试"];
        }];
        [shareRequest startAsynchronous];
    }
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
-(void)setPoMuzzikMessage:(NSDictionary *)dic{
    userInfo *user = [userInfo shareClass];
    MuzzikObject *mobject = [MuzzikObject shareClass];
    newmuzzik = [muzzik new];
    newmuzzik.muzzik_id = [dic objectForKey:@"_id"];
    newmuzzik.ismoved = NO;
    newmuzzik.date = [dic objectForKey:@"date"];
    newmuzzik.message = [dic objectForKey:@"message"];
    if ([mobject.imageKey length]>0 ) {
        newmuzzik.image = mobject.imageKey;
    }
    
    newmuzzik.topics = [dic objectForKey:@"topics"];
    newmuzzik.users = [dic objectForKey:@"users"];
    newmuzzik.type = [dic objectForKey:@"type"];
    newmuzzik.onlytext = [[dic objectForKey:@"onlyText"] boolValue];
    newmuzzik.isReposted = NO;
    newmuzzik.reposts = [dic objectForKey:@"reposts"];
    newmuzzik.shares = [dic objectForKey:@"shares"];
    newmuzzik.comments = [dic objectForKey:@"comments"];
    newmuzzik.color = [dic objectForKey:@"color"];
    newmuzzik.moveds = [dic objectForKey:@"moveds"];
    newmuzzik.isprivate = [[dic objectForKey:@"private"] boolValue];
    newmuzzik.plays = [dic objectForKey:@"plays"];
    newmuzzik.repostID = [dic objectForKey:@"repostID"];
    newmuzzik.title = [dic objectForKey:@"title"];
    newmuzzik.repostDate = [dic objectForKey:@"repostDate"];
    newmuzzik.reposter = [MuzzikUser new];
    newmuzzik.reposter.name = [[dic objectForKey:@"repostUser"] objectForKey:@"name"];
    newmuzzik.reposter.user_id = [[dic objectForKey:@"repostUser"] objectForKey:@"_id"];
    newmuzzik.reposter.avatar = [[dic objectForKey:@"repostUser"] objectForKey:@"avatar"];
    newmuzzik.reposter.gender = [[dic objectForKey:@"repostUser"] objectForKey:@"gender"];
    
    newmuzzik.MuzzikUser = [MuzzikUser new];
    newmuzzik.MuzzikUser.avatar = user.avatar;
    newmuzzik.MuzzikUser.user_id = user.uid;
    newmuzzik.MuzzikUser.gender = user.gender;
    newmuzzik.MuzzikUser.name = user.name;
    newmuzzik.MuzzikUser.isFollow = NO;
    newmuzzik.MuzzikUser.isFans = NO;
    newmuzzik.music = [music new];
    newmuzzik.music.music_id = mobject.music.music_id;
    newmuzzik.music.artist = mobject.music.artist;
    newmuzzik.music.key = mobject.music.key;
    newmuzzik.music.name = mobject.music.name;
    [[NSNotificationCenter defaultCenter] postNotificationName:String_SendNewMuzzikDataSource_update object:newmuzzik];
}
- (WBMessageObject *)messageToShare
{
    WBMessageObject *Wmessage = [WBMessageObject message];
    
    Wmessage.text =[NSString stringWithFormat:@"一起来用Muzzik吧 %@%@",URL_Muzzik_SharePage,newmuzzik.muzzik_id];
    
    WBImageObject *image = [WBImageObject object];
    if (self.poImage) {
        image.imageData = UIImageJPEGRepresentation(self.poImage, 1.0);
        Wmessage.imageObject = image;
    }
    
    
    return Wmessage;
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
