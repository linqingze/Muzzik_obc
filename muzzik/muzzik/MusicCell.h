//
//  MusicCell.h
//  muzzik
//
//  Created by muzzik on 15/4/24.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SongTableViewController.h"
@interface MusicCell : UITableViewCell
@property (nonatomic,retain) UILabel *songName;
@property (nonatomic,retain) UILabel *Artist;
@property (nonatomic,retain) UIButton *DeleButton;
@property (nonatomic,retain) UIButton *playButton;
@property (nonatomic,assign) NSInteger index;
@property (nonatomic,weak) SongTableViewController *songVC;
@end
