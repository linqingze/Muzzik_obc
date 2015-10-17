//
//  messageForResetVC.m
//  muzzik
//
//  Created by muzzik on 15/4/16.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "messageForResetVC.h"
#import "AFViewShaker.h"
#import "NSString+MD5.h"
#import "LoginViewController.h"
#import "TTTAttributedLabel.h"

@interface messageForResetVC ()<UITextFieldDelegate,TTTAttributedLabelDelegate>{
    UITextField *checkcode;
    UITextField *passwordText;
    BOOL isOk;
    UIButton *visibleButton;
    TTTAttributedLabel *tipsLabel;
    NSTimer *timer;
    int timeCount;
}
@end

@implementation messageForResetVC
- (void)viewDidLoad {
    [super viewDidLoad];
    timeCount = 60;
    [self initNagationBar:@"重置密码" leftBtn:Constant_backImage rightBtn:3];
    UIImageView *checkImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"messageImage"]];
    [checkImage setFrame:CGRectMake(20, 15, 15, 15)];
    [self.view addSubview:checkImage];
    
    checkcode = [[UITextField alloc] initWithFrame:CGRectMake(45, 15 , SCREEN_WIDTH-50, 20)];
    
    [checkcode setClearButtonMode:UITextFieldViewModeAlways];
    [checkcode setPlaceholder:@"输入验证码"];
    checkcode.delegate = self;
    [checkcode setTextColor:[UIColor colorWithHexString:@"555555"]];
    [checkcode setKeyboardType:UIKeyboardTypePhonePad];
    [checkcode setFont:[UIFont systemFontOfSize:15]];
    [self.view addSubview:checkcode];
    [MuzzikItem addLineOnView:self.view heightPoint:45 toLeft:13 toRight:13 withColor:Color_underLine];
    
    UIImageView *passwordImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"passwordImage-1"]];
    [passwordImage setFrame:CGRectMake(20, 60, 12, 15)];
    [self.view addSubview:passwordImage];
    
    passwordText = [[UITextField alloc] initWithFrame:CGRectMake(45, 60, SCREEN_WIDTH-55, 20)];
    [passwordText setPlaceholder:@"密码"];
    passwordText.delegate = self;
    [passwordText setTextColor:[UIColor colorWithHexString:@"555555"]];
    [passwordText setFont:[UIFont systemFontOfSize:15]];
    [passwordText setSecureTextEntry:YES];
    [self.view addSubview:passwordText];
    
    visibleButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-30, 60, 20, 20)];
    [visibleButton setImage:[UIImage imageNamed:Image_visibleImage_login] forState:UIControlStateNormal];
    [visibleButton addTarget:self action:@selector(setVisible) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:visibleButton];
    [MuzzikItem addLineOnView:self.view heightPoint:90 toLeft:13 toRight:13 withColor:Color_underLine];
//    UIButton *nextButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-67, SCREEN_HEIGHT-133, 54, 52)];
//    [nextButton setImage:[UIImage imageNamed:@"cycledone"] forState:UIControlStateNormal];
//    [self.view addSubview: nextButton];
//    [nextButton addTarget:self action:@selector(summitAction) forControlEvents:UIControlEventTouchUpInside];
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    tipsLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(20, 100, 200, 25)];
    [self.view addSubview:tipsLabel];
    tipsLabel.delegate = self;
    
}
- (void)attributedLabel:(TTTAttributedLabel *)label
didSelectLinkWithTransitInformation:(NSDictionary *)components{
    NSLog(@"%@",components);
    ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_GetVerifiCode]]];
    [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:self.phoneNumber forKey:@"phone"] Method:PostMethod auth:NO];
    __weak ASIHTTPRequest *weakrequest = requestForm;
    [requestForm setCompletionBlock :^{
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData] options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"%@",[weakrequest responseString]);
        NSLog(@"%d",[weakrequest responseStatusCode]);
        if ([weakrequest responseStatusCode] == 200 && [[dic objectForKey:@"result"] boolValue]) {
            timeCount = 60;
            timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
        }
    }];
    [requestForm setFailedBlock:^{
        // [SVProgressHUD showErrorWithStatus:@"network error"];
    }];
    [requestForm startAsynchronous];

}

-(void)updateTime{
    if (timeCount>0) {
        UIFont *font = [UIFont boldSystemFontOfSize:12];
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] init];
        NSString *itemStr = @"没有收到？重新获取验证码 ";
        NSAttributedString *item = [MuzzikItem formatAttrItem:itemStr color:[UIColor colorWithHexString:@"a8acbb"] font:font];
        [text appendAttributedString:item];
        NSString *itemStr1 = [NSString stringWithFormat:@"%d",timeCount];
        NSAttributedString *item1 = [MuzzikItem formatAttrItem:itemStr1 color:Color_Active_Button_1 font:font];
        [text appendAttributedString:item1];
        tipsLabel.attributedText = text;
        timeCount-- ;
    }else{
        [timer invalidate];
        timer = nil;
        [tipsLabel setFont:[UIFont boldSystemFontOfSize:12]];
        [tipsLabel setTextColor:[UIColor colorWithHexString:@"a8acbb"]];
        tipsLabel.attributedText = nil;
        tipsLabel.text = @"没有收到？重新获取验证码 ";
        [tipsLabel addLinkToTransitInformation:[NSDictionary dictionaryWithObject:@"value" forKey:@"key"] withRange:[tipsLabel.text rangeOfString:@"重新获取验证码"]];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return  YES;
}

-(void) setVisible{
    if (passwordText.secureTextEntry) {
        [visibleButton setImage:[UIImage imageNamed:Image_invisibleImage_login] forState:UIControlStateNormal];
        [passwordText setSecureTextEntry:NO];
    }
    else{
        [visibleButton setImage:[UIImage imageNamed:Image_visibleImage_login] forState:UIControlStateNormal];
        [passwordText setSecureTextEntry:YES];
    }
    
}
-(void) rightBtnAction:(UIButton *)sender{
    if ([checkcode.text length] == 0){
        [MuzzikItem showTipsAtView:self.view xPoint:20 yPoint:100 text:@"请输入正确的验证码"];
        [[[AFViewShaker alloc] initWithView:checkcode] shake];
    }else if([passwordText.text length]<6|| [passwordText.text length]>16){
        [MuzzikItem showTipsAtView:self.view xPoint:20 yPoint:100 text:@"密码必须是由6至16位数字字母组成的"];
        [[[AFViewShaker alloc] initWithView:checkcode] shake];
    }
    else{
         NSString *passwordInMD5 = [[NSString stringWithFormat:@"%@Muzzik%@",self.phoneNumber,passwordText.text] md5Encrypt];
        ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_Reset_Pwd]]];
        [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObjectsAndKeys:self.phoneNumber,@"phone",passwordInMD5,@"hashedPassword",checkcode.text,@"code", nil] Method:PostMethod auth:NO];
        __weak ASIHTTPRequest *weakrequest = requestForm;
        [requestForm setCompletionBlock :^{
            NSLog(@"%@",[weakrequest responseString]);
            NSLog(@"%d",[weakrequest responseStatusCode]);
             NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData] options:NSJSONReadingMutableContainers error:nil];
            if (dic && [[dic allKeys] containsObject:@"error"]) {
                if ([[dic objectForKey:@"error"] isEqualToString:@"verify faild"]) {
                    [MuzzikItem showTipsAtView:self.view xPoint:20 yPoint:100 text:@"请输入正确的验证码"];
                    [[[AFViewShaker alloc] initWithView:checkcode] shake];
                }
            }else if([weakrequest responseStatusCode] == 200 && [[dic allKeys] containsObject:@"token"]) {
                userInfo *user = [userInfo shareClass];
                user.token = [dic objectForKey:@"token"];
                [MuzzikItem showNotifyOnView:self.navigationController.view text:@"密码修改成功"];
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        }];
        [requestForm setFailedBlock:^{
            // [SVProgressHUD showErrorWithStatus:@"network error"];
        }];
        [requestForm startAsynchronous];
    }

}




@end
