//
//  NormalCell.h
//  muzzik
//
//  Created by 林清泽 on 15/3/4.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"

@interface NormalCell : UITableViewCell
@property (nonatomic) UILabel *repostUserName;                 //转发用户名
@property (nonatomic) UIImageView *repostImage;                //muzzik类型图标
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
@property (nonatomic) UIView *socialView;                      //社交图层
@property (nonatomic) UIImageView *upperLine;
@property (nonatomic) UIImageView *downLine;
@property (nonatomic) UIButton *moves;
@property (nonatomic) UIButton *reposts;
@property (nonatomic) UIButton *shares;
@property (nonatomic) UIButton *comments;
@property (nonatomic) UIButton *repostButton;
@property (nonatomic) UIButton *shareButton;
@property (nonatomic) UIButton *commentButton;
@property (nonatomic) NSString *colorName;
@property (nonatomic,weak) UIViewController<CellDelegate> *delegate;
@property (nonatomic) muzzik *songModel;
@property (nonatomic) NSString *muzzik_id;
@property (nonatomic) BOOL isMoved;
@property (nonatomic) NSInteger index;
@property (nonatomic) BOOL hasLoad;
@property (nonatomic) BOOL isReposted;
@property (nonatomic) BOOL isPlaying;
@property (nonatomic) UIImageView *poImage;
@property (nonatomic) UIImageView *privateImage;
@property (nonatomic) NSString *colorstring;
@property (nonatomic,retain) NSIndexPath *indexpath;
@property (nonatomic,retain) UIButton *attentionButton;
@property (nonatomic,retain) UIButton *notifyBtn;
@property (nonatomic,assign) BOOL isFollow;
-(void) colorViewWithColorString:(NSString *) colorString;
@end
