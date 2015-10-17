//
//  SearchtopicCell.m
//  muzzik
//
//  Created by muzzik on 15/5/4.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "SearchtopicCell.h"

@implementation SearchtopicCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
        
    }
    return self;
}

-(void)setup{
    self.rankLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, 25, 10, 10)];
    [self.rankLabel setFont:[UIFont systemFontOfSize:7]];
    [self addSubview:self.rankLabel];
    self.rankImage = [[UIImageView alloc] initWithFrame:CGRectMake(15, 25, 10, 10)];
    [self addSubview:self.rankImage];
    self.topicLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, 20, SCREEN_WIDTH-80,20 )];
    [self.topicLabel setFont:[UIFont systemFontOfSize:14]];
    [self.topicLabel setTextColor:Color_Text_2];
    [self addSubview:self.topicLabel];
    self.poButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-60, 0, 60, 60)];
    [self.poButton setImage:[UIImage imageNamed:Image_songlistpostweetImage] forState:UIControlStateNormal];
    [self.poButton addTarget:self action:@selector(poAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.poButton];
    [MuzzikItem addLineOnView:self heightPoint:59 toLeft:13 toRight:13 withColor:Color_line_1];
}
-(void)poAction{
    NSLog(@"play");
    [self.songVC poAction:self.index];
}
@end
