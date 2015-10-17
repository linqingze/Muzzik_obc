//
//  suggestCollectionCell.h
//  muzzik
//
//  Created by muzzik on 15/5/17.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuggestMuzzikVC.h"
#import "TTTAttributedLabel.h"
@interface suggestCollectionCell : UICollectionViewCell
@property (nonatomic,retain) UIImageView *muzzikImage;
@property (nonatomic,assign) CGFloat lastContentOffset;
@property (nonatomic,weak) SuggestMuzzikVC *suggestvc;
@property (nonatomic,retain) UIButton *headImage;
@property (nonatomic,retain) UIButton *playButton;
@property (nonatomic,retain) UILabel *nameLabel;
@property (nonatomic,retain) UIImageView *timeImage;
@property (nonatomic,retain) UILabel *timeLabel;
@property (nonatomic,retain) TTTAttributedLabel *message;
@property (nonatomic,retain) UIScrollView *scroll;
@property (nonatomic,retain) UIView *downLine;
@property (nonatomic,retain) UIView *ActionView;
@property (nonatomic,retain) UIButton *moveButton;
@property (nonatomic,retain) UIButton *repostButton;
@property (nonatomic,retain) UIButton *shareButton;
@property (nonatomic,retain) UIButton *commentButton;
@property (nonatomic,weak) id<CellDelegate> delegate;
@property (nonatomic,retain) muzzik *songModel;
@end
