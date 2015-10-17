//
//  SettingCell.h
//  muzzik
//
//  Created by muzzik on 15/5/11.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZJSwitch.h"
#import "settingSystemVC.h"
@interface SettingCell : UITableViewCell
@property (nonatomic,retain)UILabel *label;
@property (nonatomic,retain)ZJSwitch *shakeSwitch;
@property (nonatomic,weak) settingSystemVC *cellKeeper;
@property (nonatomic,retain) UILabel *dataNum;
@end
