//
//  badgeImageView.m
//  muzzik
//
//  Created by muzzik on 15/9/8.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "badgeImageView.h"
@interface badgeImageView(){
    CGRect orginalRect;
}
@property (nonatomic,retain) UILabel *badgeLabel;

@end

@implementation badgeImageView
@synthesize badgeNum = _badgeNum;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.badgeLabel = [[UILabel alloc] init];
        [self.badgeLabel setFont:[UIFont fontWithName:Font_Next_medium size:10]];
        [self.badgeLabel setTextColor:[UIColor whiteColor]];
        [self addSubview:self.badgeLabel];
        orginalRect = frame;
    }
    return self;
}

-(void)setBadgeNum:(NSInteger)badgeNum{
    _badgeNum = badgeNum;
    if (self.isNew) {
        [self.badgeLabel setText:@"New"];
        [self fixCycleFrame];
        [self setHidden:NO];
    }else{
        if (badgeNum > 99) {
            [self.badgeLabel setText:@"99+"];
            [self fixCycleFrame];
            [self setHidden:NO];
        }
        else if(badgeNum>0){
            [self.badgeLabel setText:[NSString stringWithFormat:@"%ld",badgeNum]];
            [self fixCycleFrame];
            [self setHidden:NO];
        }else{
            [self setHidden:YES];
        }
    }
    
}
-(NSInteger)badgeNum{
    return self.badgeNum;
}


-(void)fixCycleFrame{
    self.frame = orginalRect;
    UILabel *tempLabel = [[UILabel alloc] init];
    tempLabel.font = self.badgeLabel.font;
    tempLabel.text = @"9";
    [tempLabel sizeToFit];
    [self.badgeLabel sizeToFit];
    NSInteger Distance = self.badgeLabel.frame.size.width -tempLabel.frame.size.width;
    
    UIEdgeInsets insets = UIEdgeInsetsMake(0, self.frame.size.width/2, 0, self.frame.size.width/2);
    // 指定为拉伸模式，伸缩后重新赋值
    self.image = [self.image resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
    self.frame = CGRectMake(self.frame.origin.x-Distance, self.frame.origin.y, self.bounds.size.width+Distance, self.bounds.size.height);
    [self.badgeLabel setFrame:CGRectMake(self.frame.size.width/2 - self.badgeLabel.frame.size.width/2, self.frame.size.height/2 - self.badgeLabel.frame.size.height/2, self.badgeLabel.frame.size.width, self.badgeLabel.frame.size.height)];
    
}
@end
