//
//  topicRankCell.m
//  muzzik
//
//  Created by muzzik on 15/5/21.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "topicRankCell.h"

@implementation topicRankCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
        
    }
    return self;
}

-(void)setup{
    self.rankImage = [[UIImageView alloc] initWithFrame:CGRectMake(24, 0, 23, 60)];
    [self addSubview:self.rankImage];
    self.timeImage = [[UIImageView alloc] initWithFrame:CGRectMake(60, 13, 8, 8)];
    [self.timeImage setImage:[UIImage imageNamed:Image_newtopictimeImage]];
    [self addSubview:self.timeImage];
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(72, 13, 30, 10)];
    [self.timeLabel setFont:[UIFont boldSystemFontOfSize:9]];
    [self addSubview:self.timeLabel];
    self.commentImage = [[UIImageView alloc] initWithFrame:CGRectMake(102, 13, 8, 8)];
    [self addSubview:self.commentImage];
    self.commentNum = [[UILabel alloc] initWithFrame:CGRectMake(114, 13, 100, 10)];
    [self.commentNum setFont:[UIFont boldSystemFontOfSize:9]];
    [self addSubview:self.commentNum];
    self.topicLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 35, SCREEN_WIDTH-110, 15)];
    [self.topicLabel setFont:[UIFont fontWithName:Font_Next_medium size:14]];
    [self addSubview:self.topicLabel];
    self.rankNumber = [[UILabel alloc]  initWithFrame:CGRectMake(10, 25, 14, 10)];
    self.rankNumber.textAlignment = NSTextAlignmentRight;
    [self.rankNumber setFont:[UIFont systemFontOfSize:9]];
    [self addSubview:self.rankNumber];
    self.userHead = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-48, 12.5, 35, 35)];
    self.userHead.layer.cornerRadius = 17.5;
    self.userHead.clipsToBounds = YES;
    [self.userHead addTarget:self action:@selector(goUser) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.userHead];
    _lineView = [[UIView alloc] initWithFrame:CGRectMake(60, 59, SCREEN_WIDTH-73, 1)];
    [_lineView setBackgroundColor:Color_line_1];
    [self addSubview:_lineView];
}

-(void)goUser{
    [self.delegate userDetail:self.topicModel.lastPoster.user_id];
}
@end
