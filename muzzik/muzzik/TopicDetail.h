//
//  TopicDetail.h
//  muzzik
//
//  Created by muzzik on 15/5/10.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "AMScrollingNavbarViewController.h"

@interface TopicDetail : AMScrollingNavbarViewController
@property (nonatomic,copy) NSString *topic_id;
@property(nonatomic) musicPlayer *musicplayer;
@end
