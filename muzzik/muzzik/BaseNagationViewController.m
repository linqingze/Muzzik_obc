//
//  BaseNagationViewController.m
//  FHSegmentedViewControllerDemo
//
//  Created by iOS Fangli on 15/1/19.
//  Copyright (c) 2015年 Johnny iDay. All rights reserved.
//

#import "BaseNagationViewController.h"
#import "audioPlayerViewController.h"
@interface BaseNagationViewController ()<UIScrollViewDelegate>{
    NSInteger rightNumber;
    BOOL isContained;
}

@end


@implementation BaseNagationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    // Do any additional setup after loading the view from its nib.
}
- (void)initNagationBar:(id)title leftBtn:(NSInteger)leftImage rightBtn:(NSInteger)rightImge
{
    rightNumber = rightImge;
    if ([title isKindOfClass:[NSString class]]) {
        UILabel *headlabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 0, SCREEN_WIDTH-240, 30)];
        [headlabel setTextColor:[UIColor whiteColor]];
        headlabel.textAlignment = NSTextAlignmentCenter;
        [headlabel setText:title];
        headlabel.font = [UIFont boldSystemFontOfSize:17];
        [self.navigationItem setTitleView:headlabel];
        self.headerView = headlabel;
        _HtitleName = title;
    }else if ([title isKindOfClass:[UIImage class]]) {
        UIImage *logoImage = (UIImage *)title;
        UIImageView *imageView = [[UIImageView alloc]
                                  initWithFrame:CGRectMake((SCREEN_WIDTH-logoImage.size.width)/2, 10, logoImage.size.width, logoImage.size.height)];
        [imageView setImage:logoImage];
        [imageView setContentMode:UIViewContentModeCenter];
        [imageView setClipsToBounds:YES];
        self.navigationItem.titleView = imageView;
        self.headerView = self.navigationItem.titleView;
    }else if ([title isKindOfClass:[UIView class]]){
        if (self.headerView != title) {
            self.navigationItem.titleView = title;
            self.headerView = self.navigationItem.titleView;
        }
        

    }
    else{
        if ([title isKindOfClass:[UISegmentedControl class]]) {
            UISegmentedControl *segment = (UISegmentedControl *)title;
            self.navigationItem.titleView = segment;
            self.headerView = segment;
        }
    }
    UIButton *leftBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    leftBtn.frame = CGRectMake(0, 0, 44, 44);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0,-20,0,10)];

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
    
//    UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
//    longGesture.minimumPressDuration = 1.0f;
//    [leftBtn addGestureRecognizer:longGesture];
    
    UIButton *rightBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    rightBtn.frame = CGRectMake(0, 0, 44, 44);
    //[rightBtn setImageEdgeInsets:UIEdgeInsetsMake(2,30,2,0)];
//    if (<#condition#>) {
//        <#statements#>
//    }
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
    [self updateAnimation];
    [self.navigationController.navigationBar setBackgroundColor:Color_NavigationBar];
    [self.navigationController.navigationBar setBarTintColor:Color_NavigationBar];
    [self.navigationController.navigationBar setTranslucent:NO];
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
-(void)updateAnimation{
    if (rightNumber == 0) {
        Globle *glob = [Globle shareGloble];
        userInfo *user = [userInfo shareClass];
        if (!user.playNowImageView && !glob.isPause && glob.isPlaying) {
            user.playNowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navigationbarplayerImage"]];
            CABasicAnimation *monkeyAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
            monkeyAnimation.toValue = [NSNumber numberWithFloat:2.0 *M_PI];
            monkeyAnimation.duration = 1.5f;
            monkeyAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
            monkeyAnimation.cumulative = NO;
            monkeyAnimation.removedOnCompletion = NO; //No Remove
            [user.playNowImageView setFrame:CGRectMake(16, user.playNowImageView.frame.origin.y, user.playNowImageView.frame.size.width, user.playNowImageView.frame.size.height)];
            monkeyAnimation.repeatCount = FLT_MAX;
            [user.playNowImageView.layer addAnimation:monkeyAnimation forKey:@"AnimatedKey"];
            user.playNowImageView.layer.speed = 0.4;
            user.playNowImageView.layer.beginTime = 0.0;
            [self.rightBtn addSubview:user.playNowImageView];
        }
        if (user.playNowImageView) {
            if (!glob.isPause && glob.isPlaying) {
                [self.rightBtn addSubview:user.playNowImageView];
                user.playNowImageView.layer.speed = 0.4;
//                CFTimeInterval pausedTime = [user.playNowImageView.layer timeOffset];
//                CFTimeInterval timeSincePause = [user.playNowImageView.layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
//                user.playNowImageView.layer.beginTime = timeSincePause;
                
            }else if (glob.isPause){
                [self.rightBtn addSubview:user.playNowImageView];
                user.playNowImageView.layer.speed = 0.0;
            }
        }
        
    }
 
}
- (void)rightBtnAction:(UIButton *)sender
{
    if(rightNumber == 0 && [Globle shareGloble].isPlaying){
        for (UIViewController *vc in self.navigationController.viewControllers) {
            if ([vc isKindOfClass:[audioPlayerViewController class]]) {
                isContained = YES;
                break;
            }
        }
     [self.navigationController pushViewController:[[audioPlayerViewController alloc]init] animated:YES];
        
        
    }
}
- (void)tapAction:(UITapGestureRecognizer *)tap
{
    if (isContained) {
        NSMutableArray *array = [self.navigationController.viewControllers mutableCopy];
        for (UIViewController *vc in self.navigationController.viewControllers) {
            if ([vc isKindOfClass:[audioPlayerViewController class]]) {
                [array removeObjectAtIndex:[self.navigationController.viewControllers indexOfObject:vc]];
            }
        }
        [array removeLastObject];
        [self.navigationController setViewControllers:array animated:YES];
    }else{
        if ([[self.navigationController childViewControllers] count]>1) {
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [self dismissViewControllerAnimated:YES completion:NULL];
        }
    }
    
    
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
            btnImage = [UIImage imageNamed:@"done"];
            break;
        case 4:
            btnImage = [UIImage imageNamed:@"searchImage_white"];
            break;
        case 5:
            btnImage = [NSString stringWithFormat:@"下一步"];
            break;
        case 6:
            btnImage = [UIImage imageNamed:@"submit"];
            break;
        case 7:
            btnImage = [UIImage imageNamed:@"自拍"];
            break;
        case 8:
            btnImage = [UIImage imageNamed:@"searchImage"];
            [self.leftBtn setImageEdgeInsets:UIEdgeInsetsMake(2,0,2,0)];
            break;
        case 9:
            btnImage = [NSString stringWithFormat:@"注册"];
            break;
        case 10:
            btnImage = [UIImage imageNamed:@"conversationImage"];
            [self.rightBtn setFrame:CGRectMake(0, 0, 100, 44)];
            break;
        case 11:
            btnImage = [UIImage imageNamed:@"detailmoreImage"];
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

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self viewDidScroll:scrollView];
}
-(void)viewDidScroll:(UIScrollView *)scrollView{
   
}
@end
