//
//  SuggestMuzzikVC.h
//  muzzik
//
//  Created by muzzik on 15/5/17.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "AMScrollingNavbarViewController.h"

@interface SuggestMuzzikVC : AMScrollingNavbarViewController
@property (nonatomic,retain) UICollectionView *suggestCollectionView;
@property (nonatomic,copy) NSString *viewTittle;
@property (nonatomic,retain) NSMutableArray *suggestArray;
@end
