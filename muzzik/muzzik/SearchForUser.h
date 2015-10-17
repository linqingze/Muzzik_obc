//
//  SearchForUser.h
//  muzzik
//
//  Created by muzzik on 15/5/4.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "searchViewController.h"
#import "AMScrollingNavbarViewController.h"
@interface SearchForUser : AMScrollingNavbarViewController<UITableViewDelegate,UITableViewDataSource,searchSource>
@property (nonatomic,weak) searchViewController *keeper;
-(void) attention:(NSInteger) index;
- (void)viewDidCurrentView;
@end
