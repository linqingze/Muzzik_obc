//
//  LineSlider.m
//  muzzik
//
//  Created by muzzik on 15/10/20.
//  Copyright © 2015年 muzziker. All rights reserved.
//

#import "LineSlider.h"

@implementation LineSlider

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (CGRect)trackRectForBounds:(CGRect)bounds {
    return CGRectMake(0, 0, SCREEN_WIDTH-75, 1);
}
@end
