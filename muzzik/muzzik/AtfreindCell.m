//
//  AtfreindCell.m
//  muzzik
//
//  Created by muzzik on 15/4/28.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "AtfreindCell.h"

@implementation AtfreindCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
        
    }
    return self;
}

-(void)setup{
    self.headerImage = [[UIImageView alloc] initWithFrame:CGRectMake(13, 10, 40, 40)];
    self.headerImage.layer.cornerRadius = 20;
    self.headerImage.clipsToBounds = YES;
    [self addSubview: self.headerImage];
    self.label = [[UILabel alloc] initWithFrame:CGRectMake(60, 20, SCREEN_WIDTH-80, 20)];
    [self.label setFont:[UIFont boldSystemFontOfSize:14]];
    [self.label setTextColor:Color_Text_2];
    [self addSubview:self.label];
    [MuzzikItem addLineOnView:self heightPoint:59 toLeft:13 toRight:13 withColor:Color_line_1];
}
@end
