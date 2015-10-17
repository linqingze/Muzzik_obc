//
//  HostViewController.h
//  ICViewPager
//
//  Created by Ilter Cengiz on 28/08/2013.
//  Copyright (c) 2013 Ilter Cengiz. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@protocol searchSource <NSObject>


@optional
// The content for any tab. Return a view controller and ViewPager will use its view to show as content
-(void)updateDataSource:(NSString *)searchText;
-(void)searchDataSource:(NSString *)searchText;

@end
@interface ChooseMusicVC : AMScrollingNavbarViewController
@property (nonatomic,weak) id<searchSource> activityVC;
@property (nonatomic,copy) NSString *comeInType;
@property (nonatomic,retain)UISearchBar *searchBar;
@end
