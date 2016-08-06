//
//  MuzzikShareView.m
//  muzzik
//
//  Created by mac on 16/1/17.
//  Copyright © 2016年 muzziker. All rights reserved.
//

#import "MuzzikShareView.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import <RongIMKit/RongIMKit.h>
#import "IMShareMessage.h"
#import "IMFriendListViewController.h"
@interface MuzzikShareView (){
    UIView *shareView;
    UIButton *shareToTimeLineButton;
    UIButton *shareToWeiChatButton;
    UIButton *shareToWeiboButton;
    UIButton *shareToQQButton;
    UIButton *shareToQQZoneButton;
    CGFloat maxScaleY;
}
@end
@implementation MuzzikShareView
-(instancetype)initMyShare{
    self = [super init];
    if (self) {
        CGFloat screenWidth = SCREEN_WIDTH;
        
        CGFloat scaleX = 0.1;
        CGFloat scaleY = 0.08;
        userInfo *user = [userInfo shareClass];
        if (user.WeChatInstalled || user.QQInstalled) {
            maxScaleY = 0.7;
        }else{
            maxScaleY = 0.4;
        }
        self.frame =  CGRectMake(0, 0, screenWidth, SCREEN_HEIGHT);
        [self setAlpha:0];
        [self setBackgroundColor:[UIColor colorWithRed:0.125 green:0.121 blue:0.164 alpha:0.8]];
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeShareView)]];
        shareView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, screenWidth, screenWidth*maxScaleY)];
        [shareView setBackgroundColor:[UIColor colorWithRed:0.125 green:0.121 blue:0.164 alpha:0.85]];
        if (user.WeChatInstalled) {
            UIButton *wechatButton = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth*0.1, screenWidth*0.08, screenWidth*0.18, screenWidth*0.18)];
            [wechatButton setImage:[UIImage imageNamed:Image_wechatImage] forState:UIControlStateNormal];
            [wechatButton setBackgroundImage:[UIImage imageNamed:Image_sharebgImage] forState:UIControlStateNormal];
            [wechatButton setBackgroundImage:[UIImage imageNamed:Image_shareclickbgImage] forState:UIControlStateHighlighted];
            [wechatButton setImage:[UIImage imageNamed:Image_wechatImage] forState:UIControlStateHighlighted];
            wechatButton.tag = 2001;
            [wechatButton addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
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
            timeLineButton.tag = 2002;
            [timeLineButton addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
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
        weiboButton.tag = 2003;
        [weiboButton addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
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
            [QQButton addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
            QQButton.tag = 2004;
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
            qqZoneButton.tag = 2005;
            [qqZoneButton addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
            [shareView addSubview:qqZoneButton];
            
            UILabel *QQZoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth*(scaleX+0.31), screenWidth*(scaleY+0.18), screenWidth*0.18, 20)];
            QQZoneLabel.text = @"QQ空间";
            QQZoneLabel.textAlignment = NSTextAlignmentCenter;
            [QQZoneLabel setFont:[UIFont systemFontOfSize:12]];
            QQZoneLabel.textColor = Color_line_2;
            [shareView addSubview:QQZoneLabel];
            
        }
        if (user.QQInstalled && user.WeChatInstalled) {
            scaleY = 0.39;
            scaleX = 0.72;
            
        }else if (!user.QQInstalled && !user.WeChatInstalled){
            scaleY = 0.08;
            scaleX = 0.41;
        }else{
            scaleY = 0.39;
            scaleX = 0.1;
        }
        
        UIButton *muzzikButton = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth*scaleX, screenWidth*scaleY, screenWidth*0.18, screenWidth*0.18)];
        [muzzikButton setImage:[UIImage imageNamed:@"sharetomuzziker"] forState:UIControlStateNormal];
        [muzzikButton setBackgroundImage:[UIImage imageNamed:Image_sharebgImage] forState:UIControlStateNormal];
        [muzzikButton setBackgroundImage:[UIImage imageNamed:Image_shareclickbgImage] forState:UIControlStateHighlighted];
        [muzzikButton setImage:[UIImage imageNamed:@"sharetomuzziker"] forState:UIControlStateHighlighted];
        [muzzikButton addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
        [shareView addSubview:muzzikButton];
        muzzikButton.tag = 2006;
        UILabel *muzzikLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth*scaleX, screenWidth*(scaleY+0.18), screenWidth*0.18, 20)];
        muzzikLabel.text = @"Muzzik";
        muzzikLabel.textAlignment = NSTextAlignmentCenter;
        [muzzikLabel setFont:[UIFont systemFontOfSize:12]];
        muzzikLabel.textColor = Color_line_2;
        [shareView addSubview:muzzikLabel];
        [self addSubview:shareView];
    }
    return self;
}

- (WBMessageObject *)messageToShare
{
    WBMessageObject *message = [WBMessageObject message];
    
    message.text =[NSString stringWithFormat:@"一起来用Muzzik吧 %@%@",URL_Muzzik_SharePage,_shareMuzzik.muzzik_id];
    
    WBImageObject *image = [WBImageObject object];
   image.imageData = UIImageJPEGRepresentation([MuzzikItem convertViewToImage:self.cell], 1.0);
    message.imageObject = image;
    return message;
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

-(void)closeShareView{
//    if (self.tabbarController) {
//        [self.tabbarController setTabBarHidden:NO animated:YES];
//    }
    [UIView animateWithDuration:0.5 animations:^{
        [self setAlpha:0];
        [shareView setFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_WIDTH*maxScaleY)];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        
    }];
}

-(void) showShareView{
    AppDelegate *myDelegate =(AppDelegate*)[[UIApplication sharedApplication] delegate];
    [myDelegate.window addSubview:self];
    [UIView animateWithDuration:0.3 animations:^{
        [self setAlpha:1];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 animations:^{
            [shareView setFrame:CGRectMake(0, SCREEN_HEIGHT-SCREEN_WIDTH*maxScaleY, SCREEN_WIDTH, SCREEN_WIDTH*maxScaleY)];
        } ];
    }];
}

-(void)shareAction:(UIButton *) sender{
    [UIView animateWithDuration:0.3 animations:^{
        [self setAlpha:0];
        [shareView setFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_WIDTH*maxScaleY)];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
        if (self.shareMuzzik && _shareImage) {
            if (sender.tag == 2001) {
                [app sendMusicContentByMuzzik:_shareMuzzik scen:0 image:_shareImage];
                NSDictionary *requestDic = [NSDictionary dictionaryWithObjectsAndKeys:_shareMuzzik.muzzik_id,@"_id",@"wechat",@"channel", nil];
                
                ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Share_Muzzik]]];
                
                [request addBodyDataSourceWithJsonByDic:requestDic Method:PostMethod auth:YES];
                __weak ASIHTTPRequest *weakrequest = request;
                [request setCompletionBlock :^{
                    
                    _shareMuzzik.shares = [NSString stringWithFormat:@"%d",[_shareMuzzik.shares intValue]+1];
                    [[NSNotificationCenter defaultCenter] postNotificationName:String_MuzzikDataSource_update object:_shareMuzzik];
                }];
                [request setFailedBlock:^{
                    NSLog(@"%@",[weakrequest error]);
                }];
                [request startAsynchronous];
                
            }else if (sender.tag == 2002) {
                
                [app sendMusicContentByMuzzik:_shareMuzzik scen:1 image:_shareImage];
                NSDictionary *requestDic = [NSDictionary dictionaryWithObjectsAndKeys:_shareMuzzik.muzzik_id,@"_id",@"moment",@"channel", nil];
                
                ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Share_Muzzik]]];
                
                [request addBodyDataSourceWithJsonByDic:requestDic Method:PostMethod auth:YES];
                __weak ASIHTTPRequest *weakrequest = request;
                [request setCompletionBlock :^{
                    
                    _shareMuzzik.shares = [NSString stringWithFormat:@"%d",[_shareMuzzik.shares intValue]+1];
                    [[NSNotificationCenter defaultCenter] postNotificationName:String_MuzzikDataSource_update object:_shareMuzzik];
                }];
                [request setFailedBlock:^{
                    NSLog(@"%@",[weakrequest error]);
                }];
                [request startAsynchronous];
            }else if (sender.tag == 2003) {
                AppDelegate *myDelegate =(AppDelegate*)[[UIApplication sharedApplication] delegate];
                
                WBAuthorizeRequest *authRequest = [WBAuthorizeRequest request];
                authRequest.redirectURI = URL_WeiBo_redirectURI;
                authRequest.scope = @"all";
                
                WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:[self messageToShare] authInfo:authRequest access_token:myDelegate.wbtoken];
                
                //    request.shouldOpenWeiboAppInstallPageIfNotInstalled = NO;
                [WeiboSDK sendRequest:request];
                NSDictionary *requestDic = [NSDictionary dictionaryWithObjectsAndKeys:_shareMuzzik.muzzik_id,@"_id",@"weibo",@"channel", nil];
                
                ASIHTTPRequest *requestShare = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Share_Muzzik]]];
                
                [requestShare addBodyDataSourceWithJsonByDic:requestDic Method:PostMethod auth:YES];
                __weak ASIHTTPRequest *weakrequest = requestShare;
                [requestShare setCompletionBlock :^{
                    
                    _shareMuzzik.shares = [NSString stringWithFormat:@"%d",[_shareMuzzik.shares intValue]+1];
                    [[NSNotificationCenter defaultCenter] postNotificationName:String_MuzzikDataSource_update object:_shareMuzzik];
                }];
                [requestShare setFailedBlock:^{
                    NSLog(@"%@",[weakrequest error]);
                }];
                [requestShare startAsynchronous];
            }else if (sender.tag == 2004) {
                TencentOAuth *tencentOAuth = [[TencentOAuth alloc] initWithAppId:ID_QQ_APP
                                                                     andDelegate:nil];
                NSString *url = [NSString stringWithFormat:@"%@%@",URL_Muzzik_SharePage,_shareMuzzik.muzzik_id];
                //分享图预览图URL地址
                NSString *previewImageUrl = @"http://muzzik-image.qiniudn.com/FieqckeQDGWACSpDA3P0aDzmGcB6";
                //音乐播放的网络流媒体地址
                QQApiAudioObject *audioObj =[QQApiAudioObject objectWithURL:[NSURL URLWithString:url]
                                                                      title:_shareMuzzik.music.name description:_shareMuzzik.music.artist previewImageURL:[NSURL URLWithString:previewImageUrl]];
                //设置播放流媒体地址
                audioObj.flashURL=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL_audio,_shareMuzzik.music.key]];
                SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:audioObj];
                //将内容分享到qq
                
                QQApiSendResultCode sent = [QQApiInterface sendReq:req];
                [self handleSendResult:sent];
                //将被容分享到qzone
                //QQApiSendResultCode sent = [QQApiInterface SendReqToQZone:req];
                
                NSDictionary *requestDic = [NSDictionary dictionaryWithObjectsAndKeys:_shareMuzzik.muzzik_id,@"_id",@"qq",@"channel", nil];
                
                ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Share_Muzzik]]];
                
                [request addBodyDataSourceWithJsonByDic:requestDic Method:PostMethod auth:YES];
                __weak ASIHTTPRequest *weakrequest = request;
                [request setCompletionBlock :^{
                    
                    _shareMuzzik.shares = [NSString stringWithFormat:@"%d",[_shareMuzzik.shares intValue]+1];
                    [[NSNotificationCenter defaultCenter] postNotificationName:String_MuzzikDataSource_update object:_shareMuzzik];
                }];
                [request setFailedBlock:^{
                    NSLog(@"%@",[weakrequest error]);
                }];
                [request startAsynchronous];
            }else if (sender.tag == 2005) {
                TencentOAuth *tencentOAuth = [[TencentOAuth alloc] initWithAppId:ID_QQ_APP
                                                                     andDelegate:nil];
                //分享跳转URL
                NSString *url = [NSString stringWithFormat:@"%@%@",URL_Muzzik_SharePage,_shareMuzzik.muzzik_id];
                //分享图预览图URL地址
                NSString *previewImageUrl = [NSString stringWithFormat:@"%@%@",BaseURL_image,_shareMuzzik.MuzzikUser.avatar];
                //音乐播放的网络流媒体地址
                NSString *flashURL = [NSString stringWithFormat:@"%@%@",BaseURL_audio,_shareMuzzik.music.key];
                QQApiAudioObject *audioObj =[QQApiAudioObject objectWithURL:[NSURL URLWithString:url]
                                                                      title:@"我在Muzzik上分享了首歌" description:[NSString stringWithFormat:@"%@  %@",_shareMuzzik.music.name,_shareMuzzik.music.artist] previewImageURL:[NSURL URLWithString:previewImageUrl]];
                //设置播放流媒体地址
                audioObj.flashURL = [NSURL URLWithString:flashURL] ;
                SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:audioObj];
                //将内容分享到qq
                //QQApiSendResultCode sent = [QQApiInterface sendReq:req];
                //将被容分享到qzone
                QQApiSendResultCode sent = [QQApiInterface SendReqToQZone:req];
                
                [self handleSendResult:sent];
                
                NSDictionary *requestDic = [NSDictionary dictionaryWithObjectsAndKeys:_shareMuzzik.muzzik_id,@"_id",@"qzone",@"channel", nil];
                
                ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Share_Muzzik]]];
                
                [request addBodyDataSourceWithJsonByDic:requestDic Method:PostMethod auth:YES];
                __weak ASIHTTPRequest *weakrequest = request;
                [request setCompletionBlock :^{
                    
                    _shareMuzzik.shares = [NSString stringWithFormat:@"%d",[_shareMuzzik.shares intValue]+1];
                    [[NSNotificationCenter defaultCenter] postNotificationName:String_MuzzikDataSource_update object:_shareMuzzik];
                }];
                [request setFailedBlock:^{
                    NSLog(@"%@",[weakrequest error]);
                }];
                [request startAsynchronous];
            }else if (sender.tag == 2006) {
                if (self.tabbarController) {
                    [self.tabbarController setTabBarHidden:YES animated:YES];
                }

                IMFriendListViewController *imvc = [[IMFriendListViewController alloc] init];
                imvc.shareMuzzik = self.shareMuzzik;
                [self.ownerVC.navigationController pushViewController:imvc animated:YES];
            }
        }

    }];
    
}
@end
