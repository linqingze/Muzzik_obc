//
//  SearchtopicCell.h
//  muzzik
//
//  Created by muzzik on 15/5/4.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchForTopic.h"
@interface SearchtopicCell : UITableViewCell
@property(nonatomic,retain) UILabel *rankLabel;
@property(nonatomic,retain) UIImageView *rankImage;
@property(nonatomic,retain) UILabel *topicLabel;
@property(nonatomic,retain) UIButton *poButton;
@property (nonatomic,weak) SearchForTopic *songVC;
@property (nonatomic,assign) NSInteger index;
@end
