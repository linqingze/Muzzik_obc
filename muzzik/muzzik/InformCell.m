//
//  InformCell.m
//  muzzik
//
//  Created by muzzik on 15/7/8.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "InformCell.h"

@implementation InformCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
        
    }
    return self;
}
-(void)setup{
    [self setBackgroundColor:[UIColor whiteColor]];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    self.informTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, SCREEN_WIDTH-100, 60)];
    self.informTextLabel.textColor = Color_Text_1;
    [self.informTextLabel setFont:[UIFont systemFontOfSize:14]];
    [MuzzikItem addLineOnView:self heightPoint:59 toLeft:13 toRight:13 withColor:Color_line_1];
    self.informImage = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-50, 12, 36, 36)];
    [self addSubview:self.informImage];
    [self addSubview:self.informTextLabel];
    
}

@end
