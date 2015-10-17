//
//  myTopicCell.m
//  muzzik
//
//  Created by muzzik on 15/6/17.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "myTopicCell.h"

@implementation myTopicCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
        
    }
    return self;
}

-(void)setup{

    self.topicLabel = [[UILabel alloc] initWithFrame:CGRectMake(13, 23, SCREEN_WIDTH-80,20 )];
    [self.topicLabel setFont:[UIFont systemFontOfSize:14]];
    [self.topicLabel setTextColor:Color_Text_2];
    [self addSubview:self.topicLabel];
    [MuzzikItem addLineOnView:self heightPoint:59 toLeft:13 toRight:13 withColor:Color_line_1];
}
@end
