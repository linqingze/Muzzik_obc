//
//  MuzzikPlayer.m
//  muzzik
//
//  Created by muzzik on 15/10/20.
//  Copyright © 2015年 muzziker. All rights reserved.
//

#import "MuzzikPlayer.h"
#import "UIImageView+WebCache.h"
@interface MuzzikPlayer ()<STKAudioPlayerDelegate,STKDataSourceDelegate>{
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
    _player = [[STKAudioPlayer alloc] initWithOptions:(STKAudioPlayerOptions){ .flushQueueOnSeek = YES, .enableVolumeMixer = NO, .equalizerBandFrequencies = {50, 100, 200, 400, 800, 1600, 2600, 16000} }];
    _player.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackgroundSetSongInformation:) name:String_SetSongInformationNotification object:nil];
    return self;
}
-(void)playnow{
    if (globle.isPlaying) {
        if (globle.isPause) {
            [_player resume];
        }else{
            [_player pause];
        }
    }else{
        [_player playURL:musicUrl];
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
        [_player playURL:musicUrl];
    }else{
        [self playSongWithSongModel:self.MusicArray[self.index -1] Title:self.viewTitle];
    }
}
-(void)playNext{
    if (self.index == self.MusicArray.count-1 && [self.MusicArray count] >1) {
        self.playingMuzzik = self.MusicArray[0];
        if ([MuzzikItem isLocalMusicContainKey:_playingMuzzik.music.key]) {
            NSString *path = [[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:MUSIC_FileName] stringByAppendingPathComponent:_playingMuzzik.music.key];
            musicUrl = [NSURL URLWithString:[NSString stringWithFormat:@"file://%@",path]];
        }
        else{
            musicUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL_audio,_playingMuzzik.music.key]];
        }
        [_player playURL:musicUrl];
    }else if([self.MusicArray count] >1){
        [self playSongWithSongModel:self.MusicArray[self.index +1] Title:self.viewTitle];
    }else{
        [_player stop];
    }
}
#pragma mark public Action
-(void)playSongWithSongModel:(muzzik *)playMuzzik Title:(NSString *)title{
    
    self.viewTitle = title;
    if (globle.isPlaying && [_playingMuzzik isEqual:playMuzzik]) {
        if (globle.isPause) {
            [_player resume];
        }else{
            [_player pause];
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
        [_player playURL:musicUrl];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Muzzik_Player_PlayNewSong" object:nil userInfo:nil];
        muzzik *lastMuzzik = [self.MusicArray lastObject];
        if (([lastMuzzik.muzzik_id isEqualToString:playMuzzik.muzzik_id] ||([lastMuzzik.muzzik_id length] == 0 && [lastMuzzik.music.music_id isEqualToString:playMuzzik.music.music_id])) && _MusicArray.count >1) {
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
            [dict setObject:[NSNumber numberWithDouble:_player.duration] forKey:MPMediaItemPropertyPlaybackDuration];
            
            //音乐当前播放时间 在计时器中修改
            [dict setObject:[NSNumber numberWithDouble:_player.progress] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
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
#pragma mark stkPlayerDataSource
-(void) dataSourceDataAvailable:(STKDataSource*)dataSource{
    NSLog(@"%u",(unsigned int)[dataSource audioFileTypeHint]);
}
-(void) dataSourceErrorOccured:(STKDataSource*)dataSource{
    NSLog(@"%u",(unsigned int)[dataSource audioFileTypeHint]);
}
-(void) dataSourceEof:(STKDataSource*)dataSource{
     NSLog(@"%u",(unsigned int)[dataSource audioFileTypeHint]);
}


#pragma mark Delegate
/// Raised when an item has started playing
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didStartPlayingQueueItemId:(NSObject*)queueItemId{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Muzzik_Music_start_Playing" object:nil];
}
/// Raised when an item has finished buffering (may or may not be the currently playing item)
/// This event may be raised multiple times for the same item if seek is invoked on the player
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didFinishBufferingSourceWithQueueItemId:(NSObject*)queueItemId{


}
/// Raised when the state of the player has changed
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer stateChanged:(STKAudioPlayerState)state previousState:(STKAudioPlayerState)previousState{

    
    
    
    if (state == STKAudioPlayerStateReady) {
        NSLog(@"state : STKAudioPlayerStateReady");
    }else if(state == STKAudioPlayerStateRunning){
        NSLog(@"state : STKAudioPlayerStateRunning");
    }else if(state == STKAudioPlayerStatePlaying){
        globle.isPlaying = YES;
        globle.isPause = NO;
        if (previousState == STKAudioPlayerStatePaused) {
            [[NSNotificationCenter defaultCenter] postNotificationName:String_SetSongPlayNextNotification object:[NSNumber numberWithInt:STKAudioPlayerStateBuffering]];
        }
        
        NSLog(@"state : STKAudioPlayerStatePlaying");
    }
    else if(state == STKAudioPlayerStateBuffering){
        globle.isPlaying = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:String_SetSongPlayNextNotification object:[NSNumber numberWithInt:STKAudioPlayerStateBuffering]];
    }
    else if(state == STKAudioPlayerStatePaused){
        globle.isPause = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:String_SetSongPlayNextNotification object:[NSNumber numberWithInt:STKAudioPlayerStateBuffering]];
    }
    else if(state == STKAudioPlayerStateStopped){
        
        globle.isPlaying = NO;
    }
    else if(state == STKAudioPlayerStateError){
        NSLog(@"state : STKAudioPlayerStateError");
    }
    else if(state == STKAudioPlayerStateDisposed){
        NSLog(@"state : STKAudioPlayerStateDisposed");
    }
    if (state == STKAudioPlayerStatePlaying && previousState == STKAudioPlayerStateBuffering) {
        [[NSNotificationCenter defaultCenter] postNotificationName:String_SetSongPlayNextNotification object:[NSNumber numberWithInt:909]];
    }
//    if (previousState == STKAudioPlayerStateReady) {
//        NSLog(@"previousState : STKAudioPlayerStateReady");
//    }else if(previousState == STKAudioPlayerStateRunning){
//        NSLog(@"previousState : STKAudioPlayerStateRunning");
//    }else if(previousState == STKAudioPlayerStatePlaying){
//        NSLog(@"previousState : STKAudioPlayerStatePlaying");
//    }
//    else if(previousState == STKAudioPlayerStateBuffering){
//        NSLog(@"previousState : STKAudioPlayerStateBuffering");
//    }
//    else if(previousState == STKAudioPlayerStatePaused){
//        NSLog(@"previousState : STKAudioPlayerStatePaused");
//    }
//    else if(previousState == STKAudioPlayerStateStopped){
//        NSLog(@"previousState : STKAudioPlayerStateStopped");
//    }
//    else if(previousState == STKAudioPlayerStateError){
//        NSLog(@"previousState : STKAudioPlayerStateError");
//    }
//    else if(previousState == STKAudioPlayerStateDisposed){
//        NSLog(@"previousState : STKAudioPlayerStateDisposed");
//    }
    

}
/// Raised when an item has finished playing
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didFinishPlayingQueueItemId:(NSObject*)queueItemId withReason:(STKAudioPlayerStopReason)stopReason andProgress:(double)progress andDuration:(double)duration{

    if ( stopReason == STKAudioPlayerStopReasonError){
        [ MuzzikItem showNotifyOnView:nil text:@"歌曲文件读取失败"];
        if (![Reachability reachabilityWithHostName:@"www.muzziker.com"].currentReachabilityStatus == NotReachable) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self playNext];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"Muzzik_Player_PlayNewSong" object:nil];
            });
        }else{
            globle.isPlaying = NO;
            [[NSNotificationCenter defaultCenter] postNotificationName:String_SetSongPlayNextNotification object:[NSNumber numberWithInt:STKAudioPlayerStateStopped]];
        }
    } else if (stopReason != STKAudioPlayerStopReasonNone) {
        if (_isPlayBack) {
            [self playnow];
        }else{
            [self.player stop];
            [self playNext];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Muzzik_Player_PlayNewSong" object:nil];
        }
    }
    
}
/// Raised when an unexpected and possibly unrecoverable error has occured (usually best to recreate the STKAudioPlauyer)
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer unexpectedError:(STKAudioPlayerErrorCode)errorCode{
    
    
}

/// Raised when items queued items are cleared (usually because of a call to play, setDataSource or stop)
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didCancelQueuedItems:(NSArray*)queuedItems{

}

@end
