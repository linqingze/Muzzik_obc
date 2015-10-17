//
//  CommentMuzzikCell.h
//  muzzik
//
//  Created by muzzik on 15/5/9.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"
#import "repostVC.h"
@interface CommentMuzzikCell : UITableViewCell<UIActionSheetDelegate>

@property(nonatomic ,retain) UIButton *userImage;
@property(nonatomic ,retain) UILabel *userName;
@property(nonatomic ,retain) TTTAttributedLabel *message;
@property(nonatomic ,retain) UIButton *playButton;
@property(nonatomic ,retain) UILabel *songName;
@property(nonatomic ,retain) UILabel *timeLabel;
@property (nonatomic,weak) id<CellDelegate> delegate;
@property(nonatomic,retain)muzzik *MuzzikModel;
@property (nonatomic,retain) UIImageView *timeImage;
@property(nonatomic,retain) UIView *lineview;
@property(nonatomic ,retain) UIImageView *privateImage;
@property(nonatomic,retain) UILongPressGestureRecognizer *longPress;
@end
