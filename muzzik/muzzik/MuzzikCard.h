//
//  MuzzikCard.h
//  muzzik
//
//  Created by muzzik on 15/5/1.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"

@interface MuzzikCard : UITableViewCell
@property (nonatomic) UIImageView *muzzikCardImage;
@property (nonatomic) UIImageView *muzzikCardLogo;
@property (nonatomic) UIView *cardView;
@property (nonatomic) UILabel *cardTitle;
@property (nonatomic) UIButton *userImage;                  //用户头像
@property (nonatomic) UILabel *userName;                       //用户名
@property (nonatomic) UILabel *timeStamp;                      //时间
@property (nonatomic) UIProgressView *progress;
@property (nonatomic) UIView *musicPlayView;                   //播放器图层
@property (nonatomic) UIButton *playButton;
@property (nonatomic) UIButton *likeButton;
@property (nonatomic) TTTAttributedLabel *muzzikMessage;        //muzzik文字
@property (nonatomic) UILabel *musicName;                      //音乐名称
@property (nonatomic) UILabel *musicArtist;                    //音乐家
@property (nonatomic) UIImageView *timeImage;                  //时间图标
@property (nonatomic) UILabel *muzzikRepostText;               //转发文字
@property (nonatomic) NSString *colorName;
@property (nonatomic,weak) id<CellDelegate> delegate;
@property (nonatomic) muzzik *songModel;
@property (nonatomic) NSString *muzzik_id;
@property (nonatomic) BOOL isMoved;
@property (nonatomic) NSInteger index;
@property (nonatomic) BOOL hasLoad;
@property (nonatomic) BOOL isReposted;
@property (nonatomic) BOOL isPlaying;
@property (nonatomic) NSString *RepostID;
-(void) colorViewWithColorString:(NSString *) colorString;
@end
