//
//  TapImageView.m
//  TestLayerImage
//
//  Created by lcc on 14-8-1.
//  Copyright (c) 2014年 lcc. All rights reserved.
//

#import "TapImageView.h"

@implementation TapImageView

- (void)dealloc
{
    _delegate = nil;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Tapped:)];
        [self addGestureRecognizer:tap];
        self.clipsToBounds = YES;
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void) Tapped:(UIGestureRecognizer *) gesture
{
    if ([self.delegate respondsToSelector:@selector(tappedWithImage:)])
    {
        if ([self.followType length]>0) {
            [self.delegate tappedWithImage:self];
        }else{
            [UIView animateWithDuration:0.2 animations:^{
                [self setFrame:CGRectMake(self.frame.origin.x+10, self.frame.origin.y+4, self.frame.size.width-20, self.frame.size.height-8)];
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.3 animations:^{
                    [self setFrame:CGRectMake(self.frame.origin.x-10, self.frame.origin.y-4, self.frame.size.width+20, self.frame.size.height+8)];
                } completion:^(BOOL finished) {
                    [self.delegate tappedWithImage:self];
                }];
            }];
        }
        
    }
}





@end
