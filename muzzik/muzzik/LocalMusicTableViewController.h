//
//  LocalMusicTableViewController.h
//  muzzik
//
//  Created by muzzik on 15/8/14.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChooseMusicVC.h"
@interface LocalMusicTableViewController : UITableViewController
@property (nonatomic,weak) ChooseMusicVC *keeper;
- (void)viewDidCurrentView;
@property (nonatomic,retain) NSMutableDictionary *shareDic;
@end
