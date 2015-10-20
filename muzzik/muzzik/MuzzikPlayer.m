//
//  MuzzikPlayer.m
//  muzzik
//
//  Created by muzzik on 15/10/20.
//  Copyright © 2015年 muzziker. All rights reserved.
//

#import "MuzzikPlayer.h"
#import "UIImageView+WebCache.h"
@interface MuzzikPlayer (){
    Globle *globle;
    NSURL *musicUrl;
    
}
@property (nonatomic,assign) NSInteger index;
@end
@implementation MuzzikPlayer

+(MuzzikPlayer *) shareClass{
    static MuzzikPlayer *myclass=nil;
    if(!myclass){
        myclass = [[super allocWithZone:NULL] init];
    }
    return myclass;
}
-(instancetype)init{
    self = [super init];
    globle = [Globle shareGloble];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playDidfinishedNotification:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playDidChangeNotification:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackgroundSetSongInformation:) name:String_SetSongInformationNotification object:nil];
    return self;
}
-(void)playnow{
    ;
    if (globle.isPause) {
        [self play];
    }else{
        [self pause];
    }
}
-(void)playPre{
    if (self.index == 0) {
        if ([MuzzikItem isLocalMusicContainKey:_playingMuzzik.music.key]) {
            NSString *path = [[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:MUSIC_FileName] stringByAppendingPathComponent:_playingMuzzik.music.key];
            musicUrl = [NSURL URLWithString:[NSString stringWithFormat:@"file://%@",path]];
        }
        else{
            musicUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL_audio,_playingMuzzik.music.key]];
        }
        self.contentURL = musicUrl;
        [self play];
    }else{
        [self playSongWithSongModel:self.MusicArray[self.index -1] Title:nil];
    }
}
-(void)playNext{
    if (self.index == self.MusicArray.count-1) {
        self.playingMuzzik = self.MusicArray[0];
        if ([MuzzikItem isLocalMusicContainKey:_playingMuzzik.music.key]) {
            NSString *path = [[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:MUSIC_FileName] stringByAppendingPathComponent:_playingMuzzik.music.key];
            musicUrl = [NSURL URLWithString:[NSString stringWithFormat:@"file://%@",path]];
        }
        else{
            musicUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL_audio,_playingMuzzik.music.key]];
        }
        self.contentURL = musicUrl;
        [self play];
    }else{
        [self playSongWithSongModel:self.MusicArray[self.index +1] Title:nil];
    }
}
#pragma mark public Action
-(void)playSongWithSongModel:(muzzik *)playMuzzik Title:(NSString *)title{
    

    if (globle.isPlaying && [_playingMuzzik isEqual:playMuzzik]) {
        if (globle.isPause) {
            [self play];
        }else{
            [self pause];
        }
        
    }else{
        _playingMuzzik = playMuzzik;
        if ([MuzzikItem isLocalMusicContainKey:playMuzzik.music.key]) {
            NSString *path = [[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:MUSIC_FileName] stringByAppendingPathComponent:playMuzzik.music.key];
            musicUrl = [NSURL URLWithString:[NSString stringWithFormat:@"file://%@",path]];
        }
        else{
            musicUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL_audio,playMuzzik.music.key]];
        }
        self.contentURL = musicUrl;
        [self play];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Muzzik_Player_PlayNewSong" object:nil userInfo:nil];
        muzzik *lastMuzzik = [self.MusicArray lastObject];
        if ([lastMuzzik.muzzik_id isEqualToString:playMuzzik.muzzik_id] ||([lastMuzzik.muzzik_id length] == 0 && [lastMuzzik.music.music_id isEqualToString:playMuzzik.music.music_id])) {
            MuzzikRequestCenter *center = [MuzzikRequestCenter shareClass];
            [center requestToAddMoreMuzziks:self.MusicArray];
        }
        //[_radioView setRadioViewLrc];
        
        //
        for (muzzik *tempmuzzik in self.MusicArray) {
            
            if ([tempmuzzik.muzzik_id isEqualToString:playMuzzik.muzzik_id] ||([playMuzzik.muzzik_id length]==0 && [tempmuzzik.music.music_id isEqualToString:playMuzzik.music.music_id])) {
                NSLog(@"%d",[tempmuzzik.muzzik_id isEqualToString:playMuzzik.muzzik_id]);
                NSLog(@"%d",([playMuzzik.muzzik_id length]==0 && [tempmuzzik.music.music_id isEqualToString:playMuzzik.music.music_id]));
                self.index = [self.MusicArray indexOfObject:tempmuzzik];
                break;
            }
        }
    }
    
    if (globle.isApplicationEnterBackground) {
        [self applicationDidEnterBackgroundSetSongInformation:nil];
    }
    
    
}
-(void)applicationDidEnterBackgroundSetSongInformation:(NSNotification *)notification
{
    Globle *glob = [Globle shareGloble];
    if (glob.isApplicationEnterBackground) {
        if (NSClassFromString(@"MPNowPlayingInfoCenter")) {
            
            NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
            if ([_playingMuzzik.music.key length]>0) {
                [dict setObject:_playingMuzzik.music.name forKey:MPMediaItemPropertyTitle];
                [dict setObject:_playingMuzzik.music.artist  forKey:MPMediaItemPropertyArtist];
            }
            
            
            // [dict setObject:retDic forKey:MPMediaItemPropertyArtwork];
            [dict setObject:[NSNumber numberWithDouble:self.duration] forKey:MPMediaItemPropertyPlaybackDuration];
            
            //音乐当前播放时间 在计时器中修改
            [dict setObject:[NSNumber numberWithDouble:self.currentPlaybackTime] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
            if ([_playingMuzzik.image length]>0) {
                UIImageView *imageview = [[UIImageView alloc] init];
                [imageview sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",BaseURL_image,_playingMuzzik.image,Image_Size_Big]] placeholderImage:nil options:SDWebImageRetryFailed  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    [dict setObject:[[MPMediaItemArtwork alloc] initWithImage:image] forKey:MPMediaItemPropertyArtwork];
                    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dict];
                }];
            }
            [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dict];
            
        }
    }
    
}

-(void)playDidfinishedNotification:(NSNotification *)notification{
    if (_isPlayBack) {
        [self playnow];
    }else{
        [self playNext];
    }
}
- (void)playDidChangeNotification:(NSNotification *)notification {
    MPMoviePlayerController *moviePlayer = notification.object;
    MPMoviePlaybackState playState = moviePlayer.playbackState;
    
    if (playState == MPMoviePlaybackStateStopped) {
        NSLog(@"停止");
        globle.isPlaying = NO;
        globle.isPause = NO;
    } else if(playState == MPMoviePlaybackStatePlaying) {
        NSLog(@"播放");
        globle.isPlaying = YES;
        globle.isPause = NO;
    } else if(playState == MPMoviePlaybackStatePaused) {
        NSLog(@"暂停");
        globle.isPause = YES;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:String_SetSongPlayNextNotification object:nil];
}
@end
