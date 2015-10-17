//
//  SongListCell.h
//  muzzik
//
//  Created by muzzik on 15/5/15.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SongListCell : UITableViewCell
@property (nonatomic,retain) UIImageView *timeImage;
@property (nonatomic,retain) UILabel *songName;
@property (nonatomic,retain) UILabel *Artist;
@property (nonatomic,retain) UIButton *CommentButton;
@property (nonatomic,retain) UIButton *playButton;
@property (nonatomic,retain) UILabel *timeLabel;
@property (nonatomic,weak) id<CellDelegate>delegate;
@property (nonatomic,retain) muzzik *cellMuzzik;
@end
