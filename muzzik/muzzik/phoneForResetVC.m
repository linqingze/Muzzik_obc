//
//  phoneForResetVC.m
//  muzzik
//
//  Created by muzzik on 15/4/16.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "phoneForResetVC.h"
#import "messageForResetVC.h"
#import "AFViewShaker.h"
@implementation phoneForResetVC
-(void)viewDidLoad{
    [super viewDidLoad];
    [self initNagationBar:@"重置密码" leftBtn:Constant_backImage rightBtn:2];
    UIImageView *checkImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"phonenumImage"]];
    [checkImage setFrame:CGRectMake(20, 15, 9, 15)];
    [self.view addSubview:checkImage];
    
    phoneText = [[UITextField alloc] initWithFrame:CGRectMake(45, 0 , SCREEN_WIDTH-50, 45)];
    
    [phoneText setClearButtonMode:UITextFieldViewModeAlways];
    [phoneText setPlaceholder:@"请输入手机号码"];
    phoneText.delegate = self;
    [phoneText setTextColor:[UIColor colorWithHexString:@"555555"]];
    [phoneText setKeyboardType:UIKeyboardTypePhonePad];
    [phoneText setFont:[UIFont systemFontOfSize:15]];
    [self.view addSubview:phoneText];
    tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 50, SCREEN_WIDTH-30, 20)];
    tipsLabel.font = [UIFont boldSystemFontOfSize:12];
    [tipsLabel setTextColor:[UIColor colorWithHexString:@"f26a3d"]];
    [self.view addSubview:tipsLabel];
    [MuzzikItem addLineOnView:self.view heightPoint:45 toLeft:13 toRight:13 withColor:Color_underLine];
//    UIButton *nextButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-67, SCREEN_HEIGHT-133, 54, 52)];
//    [nextButton setImage:[UIImage imageNamed:@"cycleNext"] forState:UIControlStateNormal];
//    [self.view addSubview: nextButton];
//    [nextButton addTarget:self action:@selector(summitAction) forControlEvents:UIControlEventTouchUpInside];
    UITapGestureRecognizer *tapOnview = [[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)];
    [self.view addGestureRecognizer:tapOnview];
}

-(void)rightBtnAction:(UIButton *)sender{
    if ([phoneText.text length]>0) {
        ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_check_phone]]];
        [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:phoneText.text forKey:@"phone"] Method:PostMethod auth:NO];
        __weak ASIHTTPRequest *weakrequest = requestForm;
        [requestForm setCompletionBlock :^{
            NSLog(@"%@",[weakrequest responseString]);
            NSLog(@"%d",[weakrequest responseStatusCode]);
            //NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData] options:NSJSONReadingMutableContainers error:nil];
            if ([weakrequest responseStatusCode] == 409 ) {
                ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString :[NSString stringWithFormat:@"%@%@",BaseURL,URL_GetVerifiCode]]];
                [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:phoneText.text forKey:@"phone"] Method:PostMethod auth:NO];
                __weak ASIHTTPRequest *weakrequest = requestForm;
                [requestForm setCompletionBlock :^{
                    NSLog(@"%@",[weakrequest responseString]);
                    NSLog(@"%d",[weakrequest responseStatusCode]);
                    if ([weakrequest responseStatusCode] == 200) {
                        messageForResetVC *mVC = [[messageForResetVC alloc] init];
                        mVC.phoneNumber = phoneText.text;
                        [self.navigationController pushViewController:mVC animated:YES];
                    }
                }];
                [requestForm setFailedBlock:^{
                    // [SVProgressHUD showErrorWithStatus:@"network error"];
                }];
                [requestForm startAsynchronous];
            }else{
                [MuzzikItem showView:tipsLabel Text:@"手机号不存在"];
                
                isOk = NO;
            }
        }];
        [requestForm setFailedBlock:^{
            // [SVProgressHUD showErrorWithStatus:@"network error"];
        }];
        [requestForm startAsynchronous];
    }else{
        [[[AFViewShaker alloc] initWithView:phoneText]shake];
        [MuzzikItem showView:tipsLabel Text:@"请填写正确的手机号码"];
    }
    
}
@end
