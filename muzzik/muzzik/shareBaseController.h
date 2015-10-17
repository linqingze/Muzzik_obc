//
//  shareBaseController.h
//  muzzik
//
//  Created by muzzik on 15/4/27.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MuzzikObject.h"
@interface shareBaseController : UIViewController

@property (nonatomic,retain)NSMutableArray *btnImage;
@property (nonatomic,retain)NSMutableDictionary *shareDic;
@property (nonatomic,copy) NSString *HtitleName;
- (void)tapAction:(UITapGestureRecognizer *)tap; //返回按钮点击响应方法
//- (void)longPressAction:(UILongPressGestureRecognizer *)longPressGesture; //返回按钮长按手势响应方法

- (void)rightBtnAction:(UIButton *)sender;  //导航栏右按钮响应事件

- (void)setLeftBtnHide:(BOOL)isHide;
- (void)setRightBtnHide:(BOOL)isHide;

- (void)initNagationBar:(id)title leftBtn:(NSInteger)leftImage rightBtn:(NSInteger)rightImge;  //初始化导航栏
@end
