//
//  AMScrollingNavbarViewController.h
//  AMScrollingNavbar
//
//  Created by Andrea on 08/11/13.
//  Copyright (c) 2013 Andrea Mazzini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseNagationViewController.h"

@interface AMScrollingNavbarViewController : BaseNagationViewController

@property (strong, nonatomic) UIPanGestureRecognizer *panGesture;
/**-----------------------------------------------------------------------------
 * @name AMScrollingNavbarViewController
 * -----------------------------------------------------------------------------
 */

/** Scrolling init method
 *
 * Enables the scrolling on a generic UIView.
 *
 * @param scrollableView The UIView where the scrolling is performed.
 */
- (void)followScrollView:(UIScrollView *)scrollableView;
-(void)networkErrorShow;
-(void)reloadDataSource;
//- (void)tapAction:(UITapGestureRecognizer *)tap; //返回按钮点击响应方法
//- (void)longPressAction:(UILongPressGestureRecognizer *)longPressGesture; //返回按钮长按手势响应方法
//- (void)setBackBtnHide:(BOOL)isHide;  //隐藏导航栏返回按钮

@end
