//
//  MuzzikPlayer.h
//  muzzik
//
//  Created by muzzik on 15/10/20.
//  Copyright © 2015年 muzziker. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>

@interface MuzzikPlayer : MPMoviePlayerController
+(MuzzikPlayer *) shareClass;
-(void)playSongWithSongModel:(muzzik *)playMuzzik Title:(NSString *)title;
@property (nonatomic,strong) NSMutableArray * MusicArray;
@property (nonatomic,retain) muzzik *playingMuzzik;
@property (nonatomic,assign) BOOL isPlayBack;
@property (nonatomic,assign) NSString *listType;
-(void) playnow;
-(void) playNext;
-(void) playPre;
@end
