 //
//  musicPlayer.m
//  muzzik
//
//  Created by 林清泽 on 15/3/9.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//
#import "musicPlayer.h"
#import "UIImageView+WebCache.h"
#import "appConfiguration.h"
#import "FMLrcView.h"
#import "FSPlaylistItem.h"
#import <MediaPlayer/MediaPlayer.h>
#import "AudioPlayer.h"
#import "ASIHTTPRequest.h"
#import "Reachability.h"
#import <AVFoundation/AVFoundation.h>
static NSMutableArray *playList;
@interface musicPlayer()<RFRadioViewDelegate>{

}

@end
@implementation musicPlayer

+(musicPlayer *) shareClass{
    static musicPlayer *myclass=nil;
    if(!myclass){
        myclass = [[super allocWithZone:NULL] init];
    }
    return myclass;
}
-(id)init{
   self = [super init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackgroundSetSongInformation:) name:String_SetSongInformationNotification object:nil];
    _radioView = [[RFRadioView alloc] initWithFrame:CGRectMake(0,0,SCREEN_WIDTH,64)];
    _radioView.delegate = self;
    self.playModel = 0;
//    NSFileManager *fileMgr = [NSFileManager defaultManager];
//    NSString *dbPath = [DocumentsPath stringByAppendingPathComponent:@"myDataBase"];
//    NSLog(@"%@",dbPath);
    
//    if (![fileMgr fileExistsAtPath:dbPath]) {
//        NSString *srcPath = [[NSBundle mainBundle] pathForResource:@"myDataBase" ofType:@"db"];
//        [fileMgr copyItemAtPath:srcPath toPath:dbPath error:NULL];
//    }
    return self;
}
+(id)allocWithZone:(NSZone *)zone{
    return [self shareClass];
}

+(NSMutableArray *)playMusicList{
    return playList;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tabBarController.tabBar setHidden:YES];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.tabBarController.tabBar setHidden:NO];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    self.view.backgroundColor = [UIColor whiteColor];


    
    // Do any additional setup after loading the view.
}
-(void)playSongWithSongModel:(muzzik *)playMuzzik Title:(NSString *)title{
    if (title && [title length]>0) {
        [self.radioView setTitleString:[NSString stringWithFormat:@"正在播放 %@",title]];
        [UIView animateWithDuration:Play_timeinterval animations:^{
            [self.radioView setAlpha:1];
        }];
    }
    NSString *ss=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL_audio,playMuzzik.music.key]];;
    globle = [Globle shareGloble];
    if ([MuzzikItem isLocalMusicContainKey:playMuzzik.music.key]) {
        NSString *path = [[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:MUSIC_FileName] stringByAppendingPathComponent:playMuzzik.music.key];
        _radioView.musicUrl = [NSURL URLWithString:[NSString stringWithFormat:@"file://%@",path]];
    }
    else{
        //wifi条件下缓存
        _radioView.musicUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL_audio,playMuzzik.music.key]];
        if ([[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] == kReachableViaWiFi) {
            [self downLoadFileWithModel:_localMuzzik];
        }
    }
     _radioView.playMuzzik = playMuzzik;
     globle.isPlaying = YES;
     self.localMuzzik = playMuzzik;
    if (globle.isApplicationEnterBackground) {
        [self applicationDidEnterBackgroundSetSongInformation:nil];
    }
   
    //[_radioView setRadioViewLrc];
   
   
    for (muzzik *tempmuzzik in self.MusicArray) {
       
        if ([tempmuzzik.muzzik_id isEqualToString:playMuzzik.muzzik_id] ||([playMuzzik.muzzik_id length]==0 && [tempmuzzik.music.music_id isEqualToString:playMuzzik.music.music_id])) {
            NSLog(@"%d",[tempmuzzik.muzzik_id isEqualToString:playMuzzik.muzzik_id]);
            NSLog(@"%d",([playMuzzik.muzzik_id length]==0 && [tempmuzzik.music.music_id isEqualToString:playMuzzik.music.music_id]));
            self.index = [self.MusicArray indexOfObject:tempmuzzik];
            break;
        }
    }
    
}


-(void)applicationDidEnterBackgroundSetSongInformation:(NSNotification *)notification
{
    Globle *glob = [Globle shareGloble];
    if (glob.isApplicationEnterBackground) {
        if (NSClassFromString(@"MPNowPlayingInfoCenter")) {
           // NSMutableDictionary *retDic = [[NSMutableDictionary alloc] init];
            
            
            
//            AVURLAsset *mp3Asset = [AVURLAsset URLAssetWithURL:self.radioView.musicUrl options:nil];
//            
//            //    NSLog(@"%@",mp3Asset);
//            
//            for (NSString *format in [mp3Asset availableMetadataFormats]) {
//                NSLog(@"format type = %@",format);
//                for (AVMetadataItem *metadataItem in [mp3Asset metadataForFormat:format]) {
//                    
//                    if(metadataItem.commonKey)
//                        [retDic setObject:metadataItem.value forKey:metadataItem.commonKey];
//                    
//                }
//            }
//            NSLog(@"%@",retDic);
            
           
            
            
            
            
            
            NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
            if ([_localMuzzik.music.key length]>0) {
                [dict setObject:_localMuzzik.music.name forKey:MPMediaItemPropertyTitle];
                [dict setObject:_localMuzzik.music.artist  forKey:MPMediaItemPropertyArtist];
            }
            

           // [dict setObject:retDic forKey:MPMediaItemPropertyArtwork];
            NSLog(@"%f",[AudioPlayer shareClass].duration);
            [dict setObject:[NSNumber numberWithDouble:[AudioPlayer shareClass].duration] forKey:MPMediaItemPropertyPlaybackDuration];
            NSLog(@"%f",[AudioPlayer shareClass].progress);
            //音乐当前播放时间 在计时器中修改
            [dict setObject:[NSNumber numberWithDouble:[AudioPlayer shareClass].progress] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
            if ([_localMuzzik.image length]>0) {
                UIImageView *imageview = [[UIImageView alloc] init];
                [imageview sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",BaseURL_image,_localMuzzik.image,Image_Size_Big]] placeholderImage:nil options:SDWebImageRetryFailed  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    [dict setObject:[[MPMediaItemArtwork alloc] initWithImage:image] forKey:MPMediaItemPropertyArtwork];
                    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dict];
                }];
            }
            [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dict];
            
        }
    }
    
}

-(void)playModleIsLock
{
    _radioView.playMuzzik = nil;
    _radioView.playMuzzik = _localMuzzik;
    globle.isPlaying = YES;
}
-(void)play{
    if (globle.isPlaying == YES) {
        if (globle.isPause) {
            [[AudioPlayer shareClass] resume];
            globle.isPause = !globle.isPause;
        }else{
            globle.isPause = !globle.isPause;
            [[AudioPlayer shareClass] pause];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:String_SetSongPlayNextNotification object:nil];
    }else{
        switch (self.playModel) {
            case 0:
            {
                self.index+=1;
                if (self.index < [self.MusicArray count]) {
                    _localMuzzik = [self.MusicArray objectAtIndex:self.index];
                    [self playSongWithSongModel:_localMuzzik Title:nil];
                }
                
            }
                break;
            case 1:
            {
                NSInteger  number = [self.MusicArray count];
                _localMuzzik = [self.MusicArray objectAtIndex:arc4random()%number];
                [self playSongWithSongModel:_localMuzzik Title:nil];
            }
                break;
            case -1:
            {
                [self playModleIsLock];
            }
                break;
            default:
                break;
        }

    }
    
}
-(void)playNext{
    if ([self.MusicArray count]!=0) {
        
        self.index+=1;
        if (self.index < [self.MusicArray count]) {
            _localMuzzik = [self.MusicArray objectAtIndex:self.index];
            [self playSongWithSongModel:_localMuzzik Title:nil];
        }else{
            [[AudioPlayer shareClass] stop];
            globle.isPlaying = NO;
            [[NSNotificationCenter defaultCenter] postNotificationName:String_SetSongPlayNextNotification object:nil];
        }
//        
//        
//        self.index+=1;
//
//        if ([self.MusicArray count]>1) {
//            muzzik *tempMuzzik =[self.MusicArray objectAtIndex:self.index];
//            if (tempMuzzik.music) {
//                [self playSongWithSongModel:[self.MusicArray objectAtIndex:self.index] Title:nil];
//            }else{
//                [self playNext];
//            }
//            
//        }else{
//            [[AudioPlayer shareClass] stop];
//            globle.isPlaying = NO;
//            [[NSNotificationCenter defaultCenter] postNotificationName:String_SetSongPlayNextNotification object:nil];
//        }
        
    }

}
-(void)PlayPre{
    if ([self.MusicArray count]!=0) {
        self.index-=1;
        if (self.index<0) {
            self.index = 0;
        }
        [self playSongWithSongModel:[self.MusicArray objectAtIndex:self.index] Title:nil];
    }
}
#pragma mark RFRadioViewDelegate
-(void)radioView:(RFRadioView *)view musicStop:(NSInteger)playModel
{
    if (playModel == 0) {
        [self playNext];
        
    }
    else if(playModel == -1){
        [self playModleIsLock];
    }
    
    }
-(void)radioView:(RFRadioView *)view preSwitchMusic:(UIButton *)pre
{
    [self PlayPre];
}
-(void)radioView:(RFRadioView *)view nextSwitchMusic:(UIButton *)next
{
    [self playNext];
}
-(void)radioView:(RFRadioView *)view playListButton:(UIButton *)btn
{
//    FMPlayingListViewController * viewController = [[FMPlayingListViewController alloc] init];
//    UINavigationController * navigation = [[UINavigationController alloc] initWithRootViewController:viewController];
//    [self.navigationController presentViewController:navigation animated:YES completion:^{
//        
//    }];
}
-(void)downLoadFileWithModel:(muzzik*)model{
    
    
    
    //初始化Documents路径
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *folderPath = [path stringByAppendingPathComponent:MUSIC_FileName];
    //创建文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //判断temp文件夹是否存在
    BOOL fileExists = [fileManager fileExistsAtPath:folderPath];
    if (!fileExists) {//如果不存在说创建,因为下载时,不会自动创建文件夹
        [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    BOOL musicExists = false;
    NSArray *array = [fileManager contentsOfDirectoryAtPath: folderPath error:nil];
    for (NSString *pathstring in array) {
        if ([pathstring isEqualToString:model.music.key]) {
            musicExists = YES;
        }
    }
    if (!musicExists) {
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL_audio,model.music.key]];
        //设置下载路径
        ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:url];
        //设置ASIHTTPRequest代理
        request.delegate = self;
        //初始化保存ZIP文件路径
        NSString *savePath = [folderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", model.music.key]];
        //初始化临时文件路径
        NSString *tempPath = [folderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.temp",model.music.key]];
        //设置文件保存路径
        [request setDownloadDestinationPath:savePath];
        //设置临时文件路径
        [request setTemporaryFileDownloadPath:tempPath];
        //设置进度条的代理,
        //[request setDownloadProgressDelegate:cell];
        //设置是是否支持断点下载
        [request setAllowResumeForFileDownloads:YES];
        __weak ASIHTTPRequest *weakrequest = request;
        [request setCompletionBlock :^{
             if ([weakrequest responseStatusCode] == 200) {
                 [MuzzikItem addMusicAddressToLocal:savePath Key:model.music.key];
             }
        }];
        [request setFailedBlock:^{
            NSLog(@"%@%@",[weakrequest responseString],[weakrequest responseData]);
            NSLog(@"%@",[weakrequest responseHeaders]);
        }];
        [request startAsynchronous];
    }

}
-(void)radioView:(RFRadioView *)view downLoadButton:(UIButton *)btn
{
   
}

@end
