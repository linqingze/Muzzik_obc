//
//  AMScrollingNavbarViewController.m
//  AMScrollingNavbar
//
//  Created by Andrea on 08/11/13.
//  Copyright (c) 2013 Andrea Mazzini. All rights reserved.
//

#import "AMScrollingNavbarViewController.h"
#import "AppConfiguration.h"

@interface AMScrollingNavbarViewController () <UIGestureRecognizerDelegate>

@property (nonatomic, weak)	UIScrollView *scrollableView;
@property (assign, nonatomic) float lastContentOffset;
@property (assign, nonatomic) BOOL isCollapsed;
@property (assign, nonatomic) BOOL isExpanded;
@property (assign, nonatomic) BOOL isStatuBarHide;
@property (retain, nonatomic) UIButton *backBtn;
@property (nonatomic,retain) UIView *networkView;
@end

@implementation AMScrollingNavbarViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [[UIApplication sharedApplication] setApplicationSupportsShakeToEdit:YES];
    [self becomeFirstResponder];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateAnimation];
    [MobClick beginLogPageView:self.HtitleName];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:self.HtitleName];
    [self.leftBtn setAlpha:1];
    [self.rightBtn setAlpha:1];
    [self.headerView setAlpha:1];
    
}
-(void)networkErrorShow{
    if (!_networkView) {
        _networkView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
        [_networkView setBackgroundColor:Color_line_2];
        [_networkView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reloadDataSource)]];
        UILabel *networkMessage = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
        networkMessage.textAlignment = NSTextAlignmentCenter;
        UIFont *font = [UIFont boldSystemFontOfSize:12];
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] init];
        NSString *itemStr = @"网络请求失败，";
        NSAttributedString *item = [MuzzikItem formatAttrItem:itemStr color:[UIColor colorWithHexString:@"a8acbb"] font:font];
        [text appendAttributedString:item];
        NSString *itemStr1 = @"重新加载";
        NSAttributedString *item1 = [MuzzikItem formatAttrItem:itemStr1 color:Color_Additional_4 font:font];
        [text appendAttributedString:item1];
        networkMessage.attributedText = text;
        [_networkView addSubview:networkMessage];
    }
    [self.view addSubview:_networkView];
    [_networkView setAlpha:0];
    [UIView animateWithDuration:1 animations:^{
        [_networkView setAlpha:1];
    }];
    
}
- (void)followScrollView:(UIScrollView *)scrollableView
{
	self.scrollableView = scrollableView;
	self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
	[self.panGesture setMaximumNumberOfTouches:1];
	
	[self.panGesture setDelegate:self];
	[self.scrollableView addGestureRecognizer:self.panGesture];


}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
	return YES;
}

// called when a gesture recognizer attempts to transition out of UIGestureRecognizerStatePossible. returning NO causes it to transition to UIGestureRecognizerStateFailed
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}

// called when the recognition of one of gestureRecognizer or otherGestureRecognizer would be blocked by the other
// return YES to allow both to recognize simultaneously. the default implementation returns NO (by default no two gestures can be recognized simultaneously)
//
// note: returning YES is guaranteed to allow simultaneous recognition. returning NO is not guaranteed to prevent simultaneous recognition, as the other gesture's delegate may return YES


// called before touchesBegan:withEvent: is called on the gesture recognizer for a new touch. return NO to prevent the gesture recognizer from seeing this touch
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return YES;
}


- (void)handlePan:(UIPanGestureRecognizer*)gesture
{
    CGPoint translation = [gesture translationInView:[self.scrollableView superview]];
    NSLog(@"%f",translation.y);
    //标示 用户向上滑动或者向下滑动 (>0,向上滑动；<0,向下滑动)
    if ([gesture state] == UIGestureRecognizerStateBegan) {
        self.lastContentOffset = translation.y;
    }
    if ([gesture state] == UIGestureRecognizerStateEnded) {
        // Reset the nav bar if the scroll is partial
        self.lastContentOffset = 0;
    }
}

- (BOOL)canBecomeFirstResponder
{
    return YES;// default is NO
}

- (void) motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event

{
    NSString * shakeSwitch = [MuzzikItem getStringForKey:@"User_shakeActionSwitch"];
    if (![shakeSwitch isEqualToString:@"close"]) {
        MuzzikPlayer *player = [MuzzikPlayer shareClass];
        //摇动结束
        if (event.subtype == UIEventSubtypeMotionShake && [player.MusicArray count]>0) {
            [player playNext];
        }
    }
    
    
}

-(void)reloadDataSource{
    [UIView animateWithDuration:1 animations:^{
        [_networkView setAlpha:0];
    } completion:^(BOOL finished) {
        [_networkView removeFromSuperview];
    }];
    
}

@end
