//
//  TopicHeaderView.m
//  ShopUU
//
//  Created by 林清泽 on 15/1/20.
//  Copyright (c) 2015年 陆秦网络科技有限公司. All rights reserved.
//

#import "TopicHeaderView.h"

@implementation TopicHeaderView
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

-(void)setup{
    self.headerView = [[UIImageView alloc] initWithFrame:self.frame];
    [self.headerView setAlpha:0];
    [self addSubview:self.headerView];
}
@end
