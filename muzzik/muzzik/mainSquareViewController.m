//
//  mainSquareViewController.m
//  muzzik
//
//  Created by muzzik on 15/12/8.
//  Copyright © 2015年 muzziker. All rights reserved.
//

#import "mainSquareViewController.h"
#import "HJCarouselViewLayout.h"
#import "squareCollectionCell.h"
@interface mainSquareViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>{
    UICollectionView *squareCollectionView;
}

@end

@implementation mainSquareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    HJCarouselViewLayout *layout = [[HJCarouselViewLayout alloc] initWithAnim:HJCarouselAnimLinear];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(SquareCELL_Width,SquareCELL_Height);
    
    squareCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, width, height -150) collectionViewLayout:layout];
    [squareCollectionView setBackgroundColor:[UIColor whiteColor]];
    squareCollectionView.delegate = self;
    
    squareCollectionView.dataSource = self;
    squareCollectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    [squareCollectionView registerClass:[squareCollectionCell class] forCellWithReuseIdentifier:@"squareCollectionCell"];
    [self.view addSubview: squareCollectionView];
    MuzzikHTTPSessionManager *muzzikhttp = [MuzzikHTTPSessionManager sharedManager];
    [muzzikhttp GET:API_Muzzik_Square parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@",responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
    }];
    // Do any additional setup after loading the view.
}
- (NSIndexPath *)curIndexPath {
    NSArray *indexPaths = [squareCollectionView indexPathsForVisibleItems];
    NSIndexPath *curIndexPath = nil;
    NSInteger curzIndex = 0;
    for (NSIndexPath *path in indexPaths.objectEnumerator) {
        UICollectionViewLayoutAttributes *attributes = [squareCollectionView layoutAttributesForItemAtIndexPath:path];
        if (!curIndexPath) {
            curIndexPath = path;
            curzIndex = attributes.zIndex;
            continue;
        }
        if (attributes.zIndex > curzIndex) {
            curIndexPath = path;
            curzIndex = attributes.zIndex;
        }
    }
    return curIndexPath;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSLog(@"stop");
}
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath *curIndexPath = [self curIndexPath];
    if (indexPath.row == curIndexPath.row) {
        return YES;
    }
    
    [squareCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
    
    //    HJCarouselViewLayout *layout = (HJCarouselViewLayout *)collectionView.collectionViewLayout;
    //    CGFloat cellHeight = layout.itemSize.height;
    //    CGRect visibleRect = CGRectZero;
    //    if (indexPath.row > curIndexPath.row) {
    //        visibleRect = CGRectMake(0, cellHeight * indexPath.row + cellHeight / 2, CGRectGetWidth(collectionView.frame), cellHeight / 2);
    //    } else {
    //        visibleRect = CGRectMake(0, cellHeight * indexPath.row, CGRectGetWidth(collectionView.frame), CGRectGetHeight(collectionView.frame));
    //    }
    //    [self.collectionView scrollRectToVisible:visibleRect animated:YES];
    
    return NO;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"click %ld", indexPath.row);
}

#pragma mark <UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 20;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    squareCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"squareCollectionCell" forIndexPath:indexPath];
    //cell.backgroundColor = [UIColor orangeColor];
    return cell;
}








- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
