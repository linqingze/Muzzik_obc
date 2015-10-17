//
//  BaseNagationViewController.h
//  FHSegmentedViewControllerDemo
//
//  Created by iOS Fangli on 15/1/19.
//  Copyright (c) 2015年 Johnny iDay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseNagationViewController : UIViewController
@property (nonatomic,retain)NSMutableArray *btnImage;
@property (nonatomic,assign) CGFloat lastY;
@property(nonatomic, retain)UIButton *leftBtn;
@property (nonatomic,retain)UIView *headerView;
@property(nonatomic, retain)UIButton *rightBtn;
@property (nonatomic,copy) NSString *HtitleName;
@property (nonatomic,assign) BOOL isMusicButton;
@property(nonatomic,retain) UIImageView *backImageView;
- (void)tapAction:(UITapGestureRecognizer *)tap; //返回按钮点击响应方法
//- (void)longPressAction:(UILongPressGestureRecognizer *)longPressGesture; //返回按钮长按手势响应方法

- (void)rightBtnAction:(UIButton *)sender;  //导航栏右按钮响应事件

- (void)setLeftBtnHide:(BOOL)isHide;
- (void)setRightBtnHide:(BOOL)isHide;

- (void)initNagationBar:(id)title leftBtn:(NSInteger)leftImage rightBtn:(NSInteger)rightImge;  //初始化导航栏
-(void) viewDidScroll:(UIScrollView *)scrollView;
-(void)updateAnimation;
@end
