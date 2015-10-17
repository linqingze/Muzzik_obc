//
//  FeedBackVC.m
//  muzzik
//
//  Created by muzzik on 15/6/14.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "FeedBackVC.h"
#import "HPGrowingTextView.h"
@interface FeedBackVC ()<HPGrowingTextViewDelegate>{
    HPGrowingTextView *decripText;
    
}

@end

@implementation FeedBackVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNagationBar:@"反馈" leftBtn:Constant_backImage rightBtn:3];
    decripText = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(10, 20, SCREEN_WIDTH-20, 200)];
    decripText.layer.cornerRadius = 3;
    decripText.clipsToBounds = YES;
    decripText.delegate = self;
    decripText.layer.borderColor = Color_line_1.CGColor;
    decripText.layer.borderWidth = 1;
    decripText.backgroundColor = Color_line_2;
    [self.view addSubview:decripText];
    decripText.placeholder = @"为了Muzzik变得更好,请反馈您宝贵的意见... QQ群:257196166";
//    [decripText setFont:[UIFont fontWithName:Font_Next_DemiBold size:15]];
    [decripText setFrame:CGRectMake(10, 20, SCREEN_WIDTH-20, 200)];
    decripText.textColor = Color_Text_1;
    [decripText setPlaceholderColor:Color_Text_4];
    [decripText setFont:[UIFont systemFontOfSize:14]];
    [decripText setReturnKeyType:UIReturnKeyDone];
    // Do any additional setup after loading the view.
}

- (void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView{
    if ([growingTextView.text length]>140) {
        growingTextView.text = [growingTextView.text substringToIndex:140];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)rightBtnAction:(UIButton *)sender{
    [decripText resignFirstResponder];
    ASIHTTPRequest *feedBackRequest = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@api/admin/feedback",BaseURL]]];
    [feedBackRequest addBodyDataSourceWithJsonByDic:[NSDictionary dictionaryWithObject:decripText.text forKey:@"message"] Method:PostMethod auth:YES];
    __weak ASIHTTPRequest *WeakImageRequest = feedBackRequest;
    [feedBackRequest setCompletionBlock:^{
        if ([WeakImageRequest responseStatusCode]==200) {
            [MuzzikItem showNotifyOnView:self.navigationController.view text:@"反馈成功"];
            [self.navigationController popViewControllerAnimated:YES];
            
        }
    }];
    [feedBackRequest setFailedBlock:^{
        NSLog(@"%@",[WeakImageRequest error]);
        [userInfo checkLoginWithVC:self];
    }];
    [feedBackRequest startAsynchronous];
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
