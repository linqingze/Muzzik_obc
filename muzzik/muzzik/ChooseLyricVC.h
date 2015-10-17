//
//  ChooseLyricVC.h
//  muzzik
//
//  Created by muzzik on 15/4/28.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "shareBaseController.h"
#import "SDProgressView.h"
@interface ChooseLyricVC : shareBaseController
@property(nonatomic,retain) UIImage *image;
@property(nonatomic,retain) NSMutableArray *downLoadList;
@property(nonatomic,retain) SDTransparentPieProgressView *pieProgress;
-(void)startDownload;
-(void) reloadTableView;
-(void) reloadLyricTableView;
-(void)hideTips;
-(void)Notips;
@end
