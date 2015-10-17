//
//  shareBaseController.m
//  muzzik
//
//  Created by muzzik on 15/4/27.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "shareBaseController.h"
#import "appConfiguration.h"

@interface shareBaseController ()
@property(nonatomic, retain)UIButton *leftBtn;
@property(nonatomic, retain)UIButton *rightBtn;
@end

@implementation shareBaseController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)initNagationBar:(id)title leftBtn:(NSInteger)leftImage rightBtn:(NSInteger)rightImge
{
    if ([title isKindOfClass:[NSString class]]) {
        UILabel *headlabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 0, SCREEN_WIDTH-240, 30)];
        [headlabel setTextColor:[UIColor whiteColor]];
        headlabel.textAlignment = NSTextAlignmentCenter;
        [headlabel setText:title];
        
        _HtitleName = title;
        
        headlabel.font = [UIFont boldSystemFontOfSize:15];
        [self.navigationItem setTitleView:headlabel];
        
        
    }else if ([title isKindOfClass:[UIImage class]]) {
        UIImage *logoImage = (UIImage *)title;
        UIImageView *imageView = [[UIImageView alloc]
                                  initWithFrame:CGRectMake((SCREEN_WIDTH-logoImage.size.width)/2, 10, logoImage.size.width, logoImage.size.height)];
        [imageView setImage:logoImage];
        [imageView setContentMode:UIViewContentModeCenter];
        [imageView setClipsToBounds:YES];
        self.navigationItem.titleView = imageView;
    }else if ([title isKindOfClass:[UIView class]]){
        self.navigationItem.titleView = title;
    }
    else{
        if ([title isKindOfClass:[UISegmentedControl class]]) {
            UISegmentedControl *segment = (UISegmentedControl *)title;
            self.navigationItem.titleView = segment;
        }
    }
    UIButton *leftBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    leftBtn.frame = CGRectMake(0, 0, 44, 44);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(2,0,2,30)];
    
    if ([[self btnImage:leftImage] isKindOfClass:[UIImage class]]) {
        UIImage *image = (UIImage *)[self btnImage:leftImage];
        [leftBtn setImage:image forState:(UIControlStateNormal)];
        
    }else if ([[self btnImage:leftImage] isKindOfClass:[NSString class]]) {
        NSString *title = (NSString *)[self btnImage:leftImage];
        [leftBtn setTitle:title  forState:(UIControlStateNormal)];
    }
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    [self.view setBackgroundColor:[UIColor whiteColor]];
    //    [self.navigationController.navigationBar addSubview:leftBtn];
    self.leftBtn = leftBtn;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [leftBtn addGestureRecognizer:tap];
//    
//    UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
//    longGesture.minimumPressDuration = 1.0f;
//    [leftBtn addGestureRecognizer:longGesture];
    
    UIButton *rightBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    rightBtn.frame = CGRectMake(0, 0, 44, 44);
    //[rightBtn setImageEdgeInsets:UIEdgeInsetsMake(2,20,2,0)];
    
    if ([[self btnImage:rightImge] isKindOfClass:[UIImage class]]) {
        UIImage *image = (UIImage *)[self btnImage:rightImge];
        //[rightBtn setImageEdgeInsets:UIEdgeInsetsMake(2,25,2,0)];
        [rightBtn setImage:image forState:(UIControlStateNormal)];
        
    }else if ([[self btnImage:rightImge] isKindOfClass:[NSString class]]) {
        NSString *title = (NSString *)[self btnImage:rightImge];
        [rightBtn setTitle:title forState:(UIControlStateNormal)];
        //rightBtn.titleLabel.font = [UIFont fontWithName:font_YuanTiRegular size:14];
        [rightBtn setTitleColor:Color_scarlet forState:(UIControlStateNormal)];
        [rightBtn setTitleEdgeInsets:UIEdgeInsetsMake(2,0,2,0)];
    }
    [rightBtn addTarget:self action:@selector(rightBtnAction:) forControlEvents:(UIControlEventTouchUpInside)];
    self.navigationItem.rightBarButtonItem = rightItem;
    self.rightBtn = rightBtn;
    [self.navigationController.navigationBar setBackgroundColor:Color_NavigationBar];
    [self.navigationController.navigationBar setBarTintColor:Color_NavigationBar];
    [self.navigationController.navigationBar setTranslucent:NO];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:self.HtitleName];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:self.HtitleName];
    
}

- (void)tapAction:(UITapGestureRecognizer *)tap
{
    if ([[self.navigationController childViewControllers] count]>1) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
    
    NSLog(@"我貌似点击了吧??");
}

- (void)longPressAction:(UILongPressGestureRecognizer *)longPressGesture
{
    if (longPressGesture.state == UIGestureRecognizerStateEnded){
        if ([[self.navigationController childViewControllers] count]>2) {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }else{
            [self dismissViewControllerAnimated:YES completion:NULL];
        }
    }
    
}


- (void)rightBtnAction:(UIButton *)sender
{
    NSLog(@"rrrrrrr");
}


- (void)setLeftBtnHide:(BOOL)isHide
{
    if (isHide) {
        self.leftBtn.hidden = YES;
    }else{
        self.leftBtn.hidden = NO;
    }
}



- (void)setRightBtnHide:(BOOL)isHide
{
    if (isHide) {
        self.rightBtn.hidden = YES;
    }else{
        self.rightBtn.hidden = NO;
    }
}



- (id)btnImage:(NSInteger)selectNum
{
    id btnImage;
    switch (selectNum) {
        case 0:
            btnImage = nil;
            break;
        case 1:
            btnImage = [UIImage imageNamed:@"backImage"];
            break;
        case 2:
            btnImage = [UIImage imageNamed:Image_Next];
            break;
        case 3:
            btnImage = [UIImage imageNamed:@"确定"];
            break;
        case 4:
            btnImage = [UIImage imageNamed:@"searchImage_white"];
            break;
        case 5:
            btnImage = [UIImage imageNamed:Image_done];
            break;
        case 6:
            btnImage = [NSString stringWithFormat:@"提交"];
            break;
        case 7:
            btnImage = [UIImage imageNamed:@"自拍"];
            break;
        case 8:
            btnImage = [UIImage imageNamed:@"分享"];
            break;
        case 9:
            btnImage = [NSString stringWithFormat:@"注册"];
            break;
        case 10:
            btnImage = [NSString stringWithFormat:@"管理"];
            break;
        case 11:
            btnImage = [UIImage imageNamed:@"添加"];
            break;
        case 12:
            btnImage = [NSString stringWithFormat:@"保存"];
            break;
        default:
            btnImage = nil;
            break;
    }
    return btnImage;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
