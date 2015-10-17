//
//  MuzzikTopic.h
//  muzzik
//
//  Created by muzzik on 15/7/29.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MuzzikTopic : UITableViewCell
@property (nonatomic,retain) UIImageView *MusicCardLogo;
@property (nonatomic,retain) UIView *cardView;
@property (nonatomic,retain) UILabel *cardTitle;
@property (nonatomic,retain) UILabel *TopicLabel;
@property (nonatomic,weak) id<CellDelegate> delegate;
@property (nonatomic) muzzik *songModel;
@property (nonatomic,retain) UIButton *addtopicButton;
@end
