//
//  HotSearchTopicCell.h
//  muzzik
//
//  Created by muzzik on 15/6/28.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HotSearchTopic.h"
@interface HotSearchTopicCell : UITableViewCell
@property(nonatomic,retain) UILabel *rankLabel;
@property(nonatomic,retain) UIImageView *rankImage;
@property(nonatomic,retain) UILabel *topicLabel;
@property(nonatomic,retain) UIButton *poButton;
@property (nonatomic,weak) HotSearchTopic *songVC;
@property (nonatomic,assign) NSInteger index;
@end
