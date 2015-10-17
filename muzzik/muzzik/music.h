//
//  music.h
//  muzzik
//
//  Created by muzzik on 15/4/11.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface music : NSObject
@property (nonatomic,copy) NSString *artist;
@property (nonatomic,copy) NSString *key;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *music_id;
@property (nonatomic,retain) NSMutableArray *lyric;
@end
