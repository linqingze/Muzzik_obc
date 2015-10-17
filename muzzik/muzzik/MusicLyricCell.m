//
//  MusicLyricCell.m
//  muzzik
//
//  Created by muzzik on 15/6/26.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "MusicLyricCell.h"

@implementation MusicLyricCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
        
    }
    return self;
}

-(void)setup{
    self.label = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, SCREEN_WIDTH-40, 50)];
    self.label.numberOfLines = 0;
    self.label.lineBreakMode = NSLineBreakByWordWrapping;
    self.label.textAlignment = NSTextAlignmentCenter;
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    [self addSubview:self.label];
    self.backgroundColor=[UIColor clearColor];
}

@end
