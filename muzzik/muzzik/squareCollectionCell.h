//
//  squareCollectionCell.h
//  muzzik
//
//  Created by muzzik on 15/12/9.
//  Copyright © 2015年 muzziker. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface squareCollectionCell : UICollectionViewCell<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,retain) UITableView *cellTableView;
@property (nonatomic,retain) NSMutableArray *MuzzikArray;
@end
