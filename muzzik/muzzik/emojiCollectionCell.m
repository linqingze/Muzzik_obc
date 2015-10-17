//
//  emojiCollectionCell.m
//  muzzik
//
//  Created by muzzik on 15/4/27.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "emojiCollectionCell.h"

@implementation emojiCollectionCell

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
        
    }
    return self;
}

-(void)setup{
    [self setBackgroundColor:[UIColor whiteColor]];
    _emojiLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, (SCREEN_WIDTH-10)/5, (SCREEN_WIDTH-10)/5)];
    [self addSubview:_emojiLabel];
}
@end
