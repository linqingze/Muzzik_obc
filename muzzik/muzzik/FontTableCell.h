//
//  FontTableCell.h
//  muzzik
//
//  Created by muzzik on 15/6/4.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChooseLyricVC.h"
@interface FontTableCell : UITableViewCell
@property (nonatomic,retain) UIImageView *fontImage;
@property (nonatomic,retain) UIView *lineSeparate;
@property (nonatomic,retain) UIButton *downButton;
@property (nonatomic,copy) NSString *urlString;
@property (nonatomic,retain) ASIHTTPRequest *asiRequest;
@property (nonatomic,retain) NSDictionary *dic;
@property (nonatomic,weak) ChooseLyricVC *keeperVC;
@property(nonatomic,retain) SDTransparentPieProgressView *pieProgress;
@end
