//
//  SelectionLabel.m
//  muzzik
//
//  Created by muzzik on 15/6/19.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "SelectionLabel.h"

@implementation SelectionLabel

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
    if ([self.delegate respondsToSelector:@selector(tappedWithObject:)])
    {
        [self.delegate tappedWithObject:self];        
    }
}

@end
