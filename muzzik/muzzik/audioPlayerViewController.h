//
//  audioPlayerViewController.h
//  muzzik
//
//  Created by muzzik on 15/10/17.
//  Copyright © 2015年 muzziker. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface audioPlayerViewController : UIViewController
+(audioPlayerViewController *) shareClass;
-(void)playSongWithSongModel:(muzzik *)playMuzzik Title:(NSString *)title;
@property (nonatomic,strong) NSMutableArray * MusicArray;
@property (nonatomic,retain) muzzik *playingMuzzik;
-(void) play;
-(void) playNext;
-(void) playBefore;
@end
