//
//  AtFriendSearchVC.h
//  muzzik
//
//  Created by muzzik on 15/6/22.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "AMScrollingNavbarViewController.h"

@interface AtFriendSearchVC : AMScrollingNavbarViewController
@property (nonatomic,retain) NSMutableDictionary *Fdictionary;
@property (nonatomic,retain) NSMutableArray *localUsers;
@property (nonatomic,retain) NSMutableArray *searchLocalUsers;
@property (nonatomic,retain) NSMutableArray *friendArray;
@end
