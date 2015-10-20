//
//  MuzzikTableVC.h
//  muzzik
//
//  Created by muzzik on 15/5/7.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMScrollingNavbarViewController.h"
#import "TTTAttributedLabel.h"
#import "WXApiObject.h"
#import "UserMuzzikVC.h"
@interface MuzzikTableVC : AMScrollingNavbarViewController<UITableViewDataSource,UITableViewDelegate,UICollectionViewDelegateFlowLayout,TTTAttributedLabelDelegate,CellDelegate>{
    NSInteger isPlayBack;
    
}
@property(nonatomic) NSMutableArray *muzziks;
@property(nonatomic) MuzzikPlayer *musicplayer;
@property(nonatomic) NSString *topicName;
@property(nonatomic) NSURL *imageURL;
@property(nonatomic,copy)NSString *uid;
@property(nonatomic,weak) UserMuzzikVC *keeper;
@property(nonatomic,copy) NSString *requstType;
- (void)viewDidCurrentView;
@end
