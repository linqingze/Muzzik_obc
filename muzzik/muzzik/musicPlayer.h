//
//  musicPlayer.h
//  muzzik
//
//  Created by 林清泽 on 15/3/9.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RFRadioView.h"
#import "Globle.h"
#import "FMDatabase.h"
@interface musicPlayer : UIViewController{
        Globle * globle;
    NSString *songpath;
}
@property (nonatomic,retain)muzzik * localMuzzik;
@property (nonatomic,strong) NSMutableArray * MusicArray;

@property (nonatomic,assign) NSInteger index;
@property (nonatomic) NSInteger playModel;
@property (nonatomic,retain) RFRadioView * radioView;
@property (nonatomic,copy) NSString *listType;
+(musicPlayer *) shareClass;
+(NSMutableArray *)playMusicList;
-(void)playSongWithSongModel:(muzzik *)playMuzzik Title:(NSString *)title;
-(void)play;
-(void)playNext;
-(void)PlayPre;
-(void)downLoadFileWithModel:(muzzik*)playMuzzik;
@end
