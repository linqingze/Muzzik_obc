//
//  NotifyMuzzikCell.h
//  muzzik
//
//  Created by muzzik on 15/5/18.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotifyMuzzikCell : UITableViewCell
@property (nonatomic,retain) UIImageView *preImage;
@property (nonatomic,retain) UIButton *headImage;
@property (nonatomic,retain) UILabel *nameLabel;
@property (nonatomic,retain) UILabel *message;
@property (nonatomic,retain) UIView *lineView;
@property (nonatomic,retain) UIView *messageView;
@property (nonatomic,retain) UILabel *commentLabel;
@property (nonatomic,retain) UILabel *songname;
@property (nonatomic,retain) UILabel *artist;
@property (nonatomic,weak) id<CellDelegate> delegate;
@property (nonatomic,copy) NSString *user_id;
@end
