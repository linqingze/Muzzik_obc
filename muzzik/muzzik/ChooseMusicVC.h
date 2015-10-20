//
//  HostViewController.h
//  ICViewPager
//
//  Created by Ilter Cengiz on 28/08/2013.
//  Copyright (c) 2013 Ilter Cengiz. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface ChooseMusicVC : AMScrollingNavbarViewController
@property (nonatomic,weak) id<searchSource> activityVC;
@property (nonatomic,copy) NSString *comeInType;
@property (nonatomic,retain)UISearchBar *searchBar;
@end
