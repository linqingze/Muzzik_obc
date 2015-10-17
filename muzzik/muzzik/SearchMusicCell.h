//
//  SearchMusicCell.h
//  muzzik
//
//  Created by muzzik on 15/4/26.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchLibraryMusicVC.h"
@interface SearchMusicCell : UITableViewCell
@property (nonatomic,retain) UILabel *songName;
@property (nonatomic,retain) UILabel *Artist;
@property (nonatomic,retain) UIButton *playButton;
@property (nonatomic,assign) NSInteger index;
@property (nonatomic,weak) id<CellDelegate> delegate;
@property (nonatomic,retain) muzzik *songMuzzik;
@end
