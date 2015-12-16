//
//  squareCollectionCell.m
//  muzzik
//
//  Created by muzzik on 15/12/9.
//  Copyright © 2015年 muzziker. All rights reserved.
//

#import "squareCollectionCell.h"
#import "SquareImageCell.h"
#import "SquareNoImageCell.h"
@interface squareCollectionCell()<UITableViewDataSource,UITableViewDelegate>{
    NSMutableDictionary *RefreshDic;
    NSInteger page;
    NSString *lastId;
    NSString *headId;
    UIImage *shareImage;
    //shareView
    muzzik *shareMuzzik;
    UIView *shareViewFull;
    UIView *shareView;
    UIButton *shareToTimeLineButton;
    UIButton *shareToWeiChatButton;
    UIButton *shareToWeiboButton;
    UIButton *shareToQQButton;
    UIButton *shareToQQZoneButton;
    CGFloat maxScaleY;
    NSMutableDictionary *ReFreshPoImageDic;
}
@end
@implementation squareCollectionCell
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    UIEdgeInsets insets = UIEdgeInsetsMake(15, 15, 15, 15);
    UIImage *image = [UIImage imageNamed:@"squarebg"];
    // 伸缩后重新赋值
    image = [image resizableImageWithCapInsets:insets];
    UIImageView *imview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SquareCELL_Width, SquareCELL_Height)];
    [imview setImage:image];
    [self.contentView addSubview:imview];
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    _cellTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SquareCELL_Width, SquareCELL_Height)];
    _cellTableView.delegate = self;
    _cellTableView.dataSource = self;
   // [self.contentView addSubview:_cellTableView];
    [_cellTableView registerClass:[SquareNoImageCell class] forCellReuseIdentifier:@"SquareNoImageCell"];
    [_cellTableView registerClass:[SquareImageCell class] forCellReuseIdentifier:@"SquareImageCell"];
    
    return self;
}
-(void)prepareForReuse{
    [_cellTableView setContentOffset:CGPointMake(0, 0)];
}
#pragma mark --tableViewDelegate Method--
//-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    
//}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    muzzik *tempMuzzik = self.MuzzikArray[indexPath.row];
    return tempMuzzik.cellHeight;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.MuzzikArray.count;
}
//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//
//}


@end
