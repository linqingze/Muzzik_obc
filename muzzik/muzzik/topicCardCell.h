//
//  topicCardCell.h
//  muzzik
//
//  Created by 林清泽 on 15/3/7.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"
#import "appConfiguration.h"

@interface topicCardCell : UICollectionViewCell
@property (nonatomic) UIImageView *userImage;                  //用户头像
@property (nonatomic) UIImageView *repostImage;                //muzzik类型图标
@property (nonatomic) UILabel *userName;                       //用户名
@property (nonatomic) UILabel *repostUserName;                 //转发用户名
@property (nonatomic) UILabel *timeStamp;                      //时间
@property (nonatomic) UIView *musicPlayView;                   //播放器图层
@property (nonatomic) UIButton *playButton;
@property (nonatomic) TTTAttributedLabel *muzzikMessage;        //muzzik文字
@property (nonatomic) UILabel *musicName;                      //音乐名称
@property (nonatomic) UILabel *musicArtist;                    //音乐家
@property (nonatomic) UIImageView *timeImage;                  //时间图标
@property (nonatomic) UILabel *muzzikRepostText;               //转发文字
@property (nonatomic) UIView *socialView;                      //社交图层
@property (nonatomic) UIImageView *upperLine;
@property (nonatomic) UIImageView *downLine;
@property (nonatomic) UILabel *moves;
@property (nonatomic) UILabel *reposts;
@property (nonatomic) UILabel *shares;
@property (nonatomic) UILabel *comments;
@property (nonatomic) UIButton *repostButton;
@property (nonatomic) UIButton *shareButton;
@property (nonatomic) UIButton *commentButton;
@property (nonatomic) NSString *colorName;
@end
