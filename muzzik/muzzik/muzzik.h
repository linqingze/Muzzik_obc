//
//  muzzik.h
//  muzzik
//
//  Created by muzzik on 15/4/11.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//
#import "MuzzikUser.h"
#import "music.h"
#import "ReplyObject.h"
#import <Foundation/Foundation.h>

@interface muzzik : NSObject
@property (nonatomic,copy) NSString *muzzik_id;
@property (nonatomic,copy) NSString *date;
@property (nonatomic,assign) BOOL ismoved;
@property (nonatomic,retain) ReplyObject *reply;
@property (nonatomic,retain) MuzzikUser *MuzzikUser;
@property (nonatomic,retain) MuzzikUser *reposter;
@property (nonatomic,copy) NSString *message;
@property (nonatomic,copy) NSString *image;
@property (nonatomic,copy) NSArray *topics;
@property (nonatomic,copy) NSArray *users;
@property (nonatomic,retain) music *music;
@property (nonatomic,copy) NSString *type;
@property (nonatomic) BOOL onlytext;
@property (nonatomic,copy) NSString *reposts;
@property (nonatomic,copy) NSString *shares;
@property (nonatomic,copy) NSString *comments;
@property (nonatomic,copy) NSString *color;
@property (nonatomic,copy) NSString *moveds;
@property (nonatomic) BOOL isprivate;
@property (nonatomic,copy) NSString *plays;
@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *repostID;
@property (nonatomic,copy) NSString *repostDate;
@property (nonatomic,assign) BOOL isReposted;
@property (nonatomic,assign) BOOL isCheckFollow;
@property (nonatomic,copy) NSString *replystring;
-(NSMutableArray*)makeMuzziksByMuzzikArray:(NSMutableArray *)array;
-(NSMutableArray*)makeMuzziksByMusicArray:(NSMutableArray *)array;

@end
