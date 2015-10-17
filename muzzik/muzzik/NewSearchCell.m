//
//  NewSearchCell.m
//  muzzik
//
//  Created by muzzik on 15/6/23.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "NewSearchCell.h"

@implementation NewSearchCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
        
    }
    return self;
}

-(void)setup{
    self.searchImage = [[UIImageView alloc] initWithFrame:CGRectMake(13, 24, 12, 12)];
    [self.searchImage setImage:[UIImage imageNamed:Image_search_Oranger]];
    [self addSubview: self.searchImage];
    self.searchText = [[UILabel alloc] initWithFrame:CGRectMake(35, 20, SCREEN_WIDTH-80, 20)];
    [self.searchText setFont:[UIFont boldSystemFontOfSize:13]];
    [self.searchText setTextColor:Color_Active_Button_2];
    [self addSubview:self.searchText];
    [MuzzikItem addLineOnView:self heightPoint:59 toLeft:13 toRight:13 withColor:Color_line_1];
}

@end
