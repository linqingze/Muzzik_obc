//
//  DetaiMuzzikVC.h
//  muzzik
//
//  Created by muzzik on 15/5/2.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "AMScrollingNavbarViewController.h"

@interface DetaiMuzzikVC : AMScrollingNavbarViewController
@property (nonatomic,retain) NSString *muzzik_id;
@property(nonatomic,retain) musicPlayer *musicplayer;
@property(nonatomic,copy) NSString *showType;          //区分普通进入，评论和看评论

@end
