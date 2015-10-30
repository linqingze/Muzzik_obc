//
//  UIButton+autoCycle.m
//  muzzik
//
//  Created by muzzik on 15/10/23.
//  Copyright © 2015年 muzziker. All rights reserved.
//

#import "UIButton+autoCycle.h"
static BOOL isanimating = NO;
@implementation UIButton (autoCycle)
-(void)startAnimation{
    if (!isanimating) {
        isanimating = YES;
        CABasicAnimation *monkeyAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        monkeyAnimation.toValue = [NSNumber numberWithFloat:2.0 *M_PI];
        monkeyAnimation.duration = 1.0f;
        monkeyAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        monkeyAnimation.cumulative = NO;
        monkeyAnimation.removedOnCompletion = NO; //No Remove
        
        monkeyAnimation.repeatCount = FLT_MAX;
        [self.layer addAnimation:monkeyAnimation forKey:@"AnimatedKey"];
        self.layer.speed = 0.4;
        self.layer.beginTime = 0.0;
    }
    
}
-(void)stopAnimation{
    [self.layer removeAllAnimations];
    isanimating = NO;
}
@end
