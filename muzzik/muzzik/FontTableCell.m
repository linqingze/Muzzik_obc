//
//  FontTableCell.m
//  muzzik
//
//  Created by muzzik on 15/6/4.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "FontTableCell.h"

@implementation FontTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
        
    }
    return self;
}

-(void)setup{
    _fontImage = [[UIImageView alloc] initWithFrame:CGRectMake(20, 15, 85, 20)];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    [self addSubview:_fontImage];
    self.lineSeparate = [[UIView alloc] initWithFrame:CGRectMake(13, 49, SCREEN_WIDTH-26, 1)];
    [_lineSeparate setBackgroundColor:Color_line_1];
    [self addSubview:_lineSeparate];
    _downButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-47, 7, 36, 36)];
    [_downButton setImage:[UIImage imageNamed:@"downloadImage"] forState:UIControlStateNormal];
    [_downButton addTarget:self action:@selector(startDownload) forControlEvents:UIControlEventTouchUpInside];
    _pieProgress = [[SDTransparentPieProgressView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-39, 15, 20, 20)];
    _pieProgress.layer.cornerRadius = 10;
    _pieProgress.clipsToBounds = YES;
    [self addSubview:_pieProgress];
    
    [self addSubview:_downButton];
}

-(void)startDownload{
    if (!self.keeperVC.downLoadList) {
        self.keeperVC.downLoadList = [NSMutableArray array];
    }
    if ([self.keeperVC.downLoadList count] == 0) {
        [self.pieProgress setHidden:NO];
        [self.keeperVC.downLoadList addObject:self.dic];
        [self.keeperVC startDownload];
    }

    
    
    
}
@end
