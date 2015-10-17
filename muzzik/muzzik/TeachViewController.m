//
//  TeachViewController.m
//  ShopUU
//
//  Created by iOS Fangli on 14/12/19.
//  Copyright (c) 2014年 IOS. All rights reserved.
//

#import "TeachViewController.h"

@interface TeachViewController ()
{
    UIActivityIndicatorView *activityIndicatorView;
}

@end

@implementation TeachViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    
    self.teachWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
//    self.teachWebView.scrollView.contentInset = UIEdgeInsetsMake(-64, 0, 0, 0);
    self.teachWebView.delegate = self;
    [self.teachWebView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.teachWebView];
    NSURL *url;
    if ([self.showType isEqualToString:@"QA"]) {
         url = [NSURL URLWithString:@"http://www.muzziker.com/qa.html"];
        [self initNagationBar:@"Q&A" leftBtn:Constant_backImage rightBtn:0];
    }else if([self.showType isEqualToString:@"about"]){
        url = [NSURL URLWithString:URL_protocol];
        [self initNagationBar:@"关于Muzzik" leftBtn:Constant_backImage rightBtn:0];
    }else{
        url = [NSURL URLWithString:URL_protocol];
        [self initNagationBar:@"Muzzik用户协议" leftBtn:Constant_backImage rightBtn:0];
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.teachWebView loadRequest:request];
    
//    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
//    doubleTap.numberOfTouchesRequired = 2;
//    [self.teachWebView addGestureRecognizer:doubleTap];
    
    activityIndicatorView = [[UIActivityIndicatorView alloc]
                             initWithFrame : CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)] ;
    [activityIndicatorView setCenter: self.view.center] ;
    [activityIndicatorView setActivityIndicatorViewStyle: UIActivityIndicatorViewStyleWhite] ;
    [self.view addSubview : activityIndicatorView] ;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//- (void)doubleTap:(UITapGestureRecognizer *)doubleTap
//{
//    int scrollPositionY = [[self.teachWebView stringByEvaluatingJavaScriptFromString:@"window.pageYOffset"] intValue];
//    int scrollPositionX = [[self.teachWebView stringByEvaluatingJavaScriptFromString:@"window.pageXOffset"] intValue];
//    
//    int displayWidth = [[self.teachWebView stringByEvaluatingJavaScriptFromString:@"window.outerWidth"] intValue];
//    CGFloat scale = self.teachWebView.frame.size.width / displayWidth;
//    
//    CGPoint pt = [doubleTap locationInView:self.teachWebView];
//    pt.x *= scale;
//    pt.y *= scale;
//    pt.x += scrollPositionX;
//    pt.y += scrollPositionY;
//    
//    NSString *js = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).tagName", pt.x, pt.y];
//    NSString * tagName = [self.teachWebView stringByEvaluatingJavaScriptFromString:js];
//    if ([tagName isEqualToString:@"img"]) {
//        NSString *imgURL = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).src", pt.x, pt.y];
//        NSString *urlToSave = [self.teachWebView stringByEvaluatingJavaScriptFromString:imgURL];
//        NSLog(@"image url=%@", urlToSave);
//    }
//}


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
