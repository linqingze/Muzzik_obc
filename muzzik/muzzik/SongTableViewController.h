//
//  SongTableViewController.h
//  muzzik
//
//  Created by muzzik on 15/4/24.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChooseMusicVC.h"
@interface SongTableViewController : UITableViewController<searchSource,UIAlertViewDelegate>
@property (nonatomic,weak) ChooseMusicVC *keeper;
-(void) playMuzzikWithIndex:(NSInteger) index;
-(void) deleleMuzzikWithIndex:(NSInteger) index;
- (void)viewDidCurrentView;
@property (nonatomic,retain) NSMutableDictionary *shareDic;
@end
