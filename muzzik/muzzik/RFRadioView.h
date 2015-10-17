//
//  RFRadioView.h
//  RadioFree
//
//  Created by zhaojianguo-PC on 14-5-23.
//  Copyright (c) 2014年 xiaozi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FSPlaylistItem;
@class RFRadioView;
@class FMLrcView;
#import "AudioPlayer.h"
#import "muzzik.h"
#import "StyledPageControl.h"
#import "UIButton_UserMuzzik.h"
@protocol RFRadioViewDelegate <NSObject>
-(void)radioView:(RFRadioView *)view musicStop:(NSInteger)playModel;
-(void)radioView:(RFRadioView *)view preSwitchMusic:(UIButton *)pre;
-(void)radioView:(RFRadioView *)view nextSwitchMusic:(UIButton *)next;
-(void)radioView:(RFRadioView *)view playListButton:(UIButton *)btn;
-(void)radioView:(RFRadioView *)view downLoadButton:(UIButton *)btn;
@end
@interface RFRadioView : UIView<AudioPlayerDelegate,UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>
{
    NSTimer *_progressUpdateTimer;
    NSTimer *_playbackSeekTimer;
    double _seekToPoint;
    BOOL _paused;
    
    UILabel *_currentPlaybackTime;
    UILabel * _totalPlaybackTime;
    
    UILabel * noLrcLabel;
    
    BOOL isPlaying;
    BOOL isPasue;
    BOOL isLrc;
    
    NSInteger isPlayBack;
    
    id <RFRadioViewDelegate>delegate;
    UIImageView * backImageView;
        
   AudioPlayer* audioPlayer;
    
    //new
    UIButton *showButton;
    UILabel *songName;
    UILabel *artistName;
    UIButton *playButton;
    NSMutableArray *playList;
//    UILabel *titleLabel;
    UIButton_UserMuzzik *headerImage;
    UIButton *attentionButton;
    UILabel *nickLabel;
    StyledPageControl *pagecontrol;
    UIScrollView *Scroll;
    UITableView *lyricTableView;
//    UILabel *timeLabel;
    UIButton *commentButton;
    UIButton *movedButton;
    UIButton *playModelButton;
    UIButton *nextButton;
    UIButton *closeButton;
    UIView *detailView;
    UISlider *slider;
    UILabel *message;
    
    UIButton *smallPlayButton;
    UILabel *PsongName;
    UILabel *PartistName;
    UIButton *playListButton;
    UITableView *plistTableView;
    UIView *messageView;
    NSMutableArray *playListArray;
    UILabel *lyricTipsLabel;
    BOOL isError;
    
}
@property (nonatomic,retain) NSMutableArray *lyricArray;
@property (nonatomic,assign) BOOL IsShowDetail;
@property (nonatomic,assign) BOOL IsShowPlayList;
@property (nonatomic) BOOL isOpen;
@property (nonatomic,strong) FSPlaylistItem *selectedPlaylistItem;
@property (nonatomic,assign) id <RFRadioViewDelegate>delegate;
@property (nonatomic,retain) UIView *smallView;
@property (nonatomic,assign) BOOL playNext;
@property (nonatomic,retain) UIView *titleView;
@property (nonatomic,retain) UIView *playView;
@property (nonatomic,retain) UIView *playListView;
@property (nonatomic,retain) UIView *coverView;
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic, strong) UISlider *progress;
@property (nonatomic,retain) muzzik *playMuzzik;
@property (nonatomic,copy) NSURL *musicUrl;
-(void)playButtonEvent;
-(void) setTitleString:(NSString *)title;
@end
