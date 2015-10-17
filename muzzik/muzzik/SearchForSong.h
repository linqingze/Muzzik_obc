//
//  SearchForSong.h
//  muzzik
//
//  Created by muzzik on 15/5/4.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "searchViewController.h"
#import "AMScrollingNavbarViewController.h"
@interface SearchForSong : AMScrollingNavbarViewController
@property (nonatomic,weak) searchViewController *keeper;
-(void) playMuzzikWithIndex:(NSInteger) index;
-(void) commentMuzzikWithIndex:(NSInteger) index;
- (void)viewDidCurrentView;
@property (nonatomic,retain) NSMutableDictionary *shareDic;
@end
