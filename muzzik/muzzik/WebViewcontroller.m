//
//  WebViewcontroller.m
//  muzzik
//
//  Created by muzzik on 16/1/21.
//  Copyright © 2016年 muzziker. All rights reserved.
//

#import "WebViewcontroller.h"

@interface WebViewcontroller ()<UIWebViewDelegate>{
     UIActivityIndicatorView *activityIndicatorView;
    UIWebView *myWebView;
}

@end

@implementation WebViewcontroller

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNagationBar:@"网页内容" leftBtn:Constant_backImage rightBtn:0];
    // Do any additional setup after loading the view.
    myWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
    myWebView.delegate = self;
    [myWebView setBackgroundColor:[UIColor whiteColor]];
    myWebView.scalesPageToFit = YES;
    [self.view addSubview:myWebView];
    if (self.url) {
        NSURLRequest *request = [NSURLRequest requestWithURL:_url];
        [myWebView loadRequest:request];
    }
    
    activityIndicatorView = [[UIActivityIndicatorView alloc]
                             initWithFrame : CGRectMake(SCREEN_WIDTH/2-16, SCREEN_HEIGHT/2-48, 32.0f, 32.0f)] ;
    [activityIndicatorView setActivityIndicatorViewStyle: UIActivityIndicatorViewStyleGray] ;
    [self.view addSubview : activityIndicatorView] ;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    //调用接口，请求数据
    //    [[UIApplication sharedApplication] openURL:request.URL];
    return YES;
}


- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [activityIndicatorView startAnimating];
}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [activityIndicatorView stopAnimating];
}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    UILabel * alter = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
    alter.text = @"网页加载失败";
    [alter setFont:[UIFont fontWithName:Font_Next_DemiBold size:30]];
    [activityIndicatorView stopAnimating];
    alter.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:alter];
    NSLog(@"%@",error);
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
