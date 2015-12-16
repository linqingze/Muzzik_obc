//
//  SquareImageCell.m
//  muzzik
//
//  Created by muzzik on 15/12/9.
//  Copyright © 2015年 muzziker. All rights reserved.
//

#import "SquareImageCell.h"

@implementation SquareImageCell

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
    
}
@end
