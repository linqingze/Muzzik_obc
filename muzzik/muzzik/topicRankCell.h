//
//  topicRankCell.h
//  muzzik
//
//  Created by muzzik on 15/5/21.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TopicModel.h"
@interface topicRankCell : UITableViewCell
@property (nonatomic,retain)UIImageView *rankImage;
@property (nonatomic,retain)UIButton *userHead;
@property (nonatomic,retain)UILabel *rankNumber;
@property (nonatomic,retain)UILabel *timeLabel;
@property (nonatomic,retain)UILabel *commentNum;
@property (nonatomic,retain)UILabel *topicLabel;
@property (nonatomic,retain)UIImageView *timeImage;
@property (nonatomic,retain)UIImageView *commentImage;
@property (nonatomic,retain)UIView *lineView;
@property (nonatomic,weak) id<CellDelegate> delegate;
@property (nonatomic,retain)TopicModel *topicModel;
@end
