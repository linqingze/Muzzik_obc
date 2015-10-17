//
//  MuzzikSongCell.h
//  muzzik
//
//  Created by muzzik on 15/7/29.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MuzzikSongCell : UITableViewCell
@property (nonatomic) UIImageView *MusicCardLogo;
@property (nonatomic) UIView *cardView;
@property (nonatomic) UILabel *cardTitle;
@property (nonatomic) UILabel *musicName;                      //音乐名称
@property (nonatomic) UILabel *musicArtist;                    //音乐家
@property (nonatomic) UIButton *playButton;
@property (nonatomic) UIButton *NewMuzzikButton;
@property (nonatomic,weak) id<CellDelegate> delegate;
@property (nonatomic) muzzik *songModel;
@end
