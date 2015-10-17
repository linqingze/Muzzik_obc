//
//  setNameVc.m
//  muzzik
//
//  Created by muzzik on 15/4/15.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//
#import "AFViewShaker.h"
#import "setNameVc.h"
#import "setHeadImageVC.h"
@implementation setNameVc
-(void)viewDidLoad{
    [super viewDidLoad];
    [self initNagationBar:@"创建Muzzik昵称" leftBtn:Constant_backImage rightBtn:2];
    UIImageView *checkImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nameImage"]];
    [checkImage setFrame:CGRectMake(20, 15, 15, 15)];
    [self.view addSubview:checkImage];
    
    nameText = [[UITextField alloc] initWithFrame:CGRectMake(45, 0 , SCREEN_WIDTH-50, 45)];
    
    [nameText setClearButtonMode:UITextFieldViewModeAlways];
    [nameText setPlaceholder:@"请输入昵称"];
    nameText.delegate = self;
    [nameText setTextColor:[UIColor colorWithHexString:@"555555"]];
    [nameText setFont:[UIFont systemFontOfSize:15]];
    [self.view addSubview:nameText];
    [MuzzikItem addLineOnView:self.view heightPoint:45 toLeft:13 toRight:13 withColor:Color_underLine];
    tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 65, SCREEN_WIDTH-30, 20)];
    tipsLabel.font = [UIFont boldSystemFontOfSize:12];
    [tipsLabel setTextColor:[UIColor colorWithHexString:@"f26a3d"]];
    [self.view addSubview:tipsLabel];

//    UIButton *nextButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-67, SCREEN_HEIGHT-133, 54, 52)];
//    [nextButton setImage:[UIImage imageNamed:@"cycleNext"] forState:UIControlStateNormal];
//    [self.view addSubview: nextButton];
//    [nextButton addTarget:self action:@selector(summitAction) forControlEvents:UIControlEventTouchUpInside];
    UITapGestureRecognizer *tapOnview = [[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)];
    [self.view addGestureRecognizer:tapOnview];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return  YES;
}
-(void) rightBtnAction:(UIButton *)sender{
    [nameText resignFirstResponder];
    if ([nameText.text length] == 0) {
        setHeadImageVC *sethead = [[setHeadImageVC alloc] init];
        [self.navigationController pushViewController:sethead animated:YES];
    }
    else{
        ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString : [NSString stringWithFormat:@"%@%@",BaseURL,URL_check_phone]]];
        [request addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:nameText.text forKey:@"name"] Method:PostMethod auth:NO];
        __weak ASIHTTPRequest *weakrequest = request;
        [request setCompletionBlock :^{
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[weakrequest responseData] options:NSJSONReadingMutableContainers error:nil];
            NSLog(@"%@",[weakrequest responseString]);
            NSLog(@"%d",[weakrequest responseStatusCode]);
            if ([weakrequest responseStatusCode] == 200 && [[dic objectForKey:@"result"] boolValue]) {
                ASIHTTPRequest *requestForm = [[ASIHTTPRequest alloc] initWithURL:[ NSURL URLWithString : [NSString stringWithFormat:@"%@%@",BaseURL,URL_Update_Profile]]];
                [requestForm addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:nameText.text forKey:@"name"] Method:PostMethod auth:YES];
                __weak ASIHTTPRequest *weakreq = requestForm;
                [requestForm setCompletionBlock :^{
                    NSLog(@"%@",[weakreq responseString]);
                    NSLog(@"%d",[weakreq responseStatusCode]);
                    if ([weakreq responseStatusCode] == 200) {
                        userInfo *user = [userInfo shareClass];
                        user.name = nameText.text;
                        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:user.token,@"token",user.uid,@"_id",user.name,@"name", nil];
                        [MuzzikItem addMessageToLocal:dic];
                        
                        setHeadImageVC *sethead = [[setHeadImageVC alloc] init];
                        [self.navigationController pushViewController:sethead animated:YES];
                        //
                    }
                    else if([weakreq responseStatusCode] == 400){
                        isOk = NO;
                        [tipsLabel setText:@"用户名不可用"];
                        [[[AFViewShaker alloc] initWithView:tipsLabel] shake];
                    }
                    
                    else if([weakreq responseStatusCode] == 409){
                        isOk = NO;
                        [tipsLabel setText:@"用户名过长"];
                        [[[AFViewShaker alloc] initWithView:tipsLabel] shake];
                    }
                }];
                [requestForm setFailedBlock:^{
                    // [SVProgressHUD showErrorWithStatus:@"network error"];
                }];
                [requestForm startAsynchronous];
            }
            else if([weakrequest responseStatusCode] == 400){
                [tipsLabel setText:@"用户名不可用"];
                [[[AFViewShaker alloc] initWithView:tipsLabel] shake];
            }
            else if([weakrequest responseStatusCode] == 409){
                [tipsLabel setText:@"用户昵称已存在"];
                [[[AFViewShaker alloc] initWithView:tipsLabel] shake];
            }
        }];
        [request setFailedBlock:^{
            // [SVProgressHUD showErrorWithStatus:@"network error"];
        }];
        [request startAsynchronous];
        
        }

    }
@end
