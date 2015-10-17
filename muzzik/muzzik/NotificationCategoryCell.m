//
//  NotificationCategoryCell.m
//  muzzik
//
//  Created by muzzik on 15/9/8.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "NotificationCategoryCell.h"

@implementation NotificationCategoryCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
        
    }
    return self;
}
-(void)setup{
    _titleImage = [[UIImageView alloc] initWithFrame:CGRectMake(16, 14, 32, 32)];
    [self addSubview:_titleImage];
    _decriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(64, 0, SCREEN_WIDTH-128, 60)];
    [_decriptionLabel setTextColor:Color_Text_1];
    _decriptionLabel.font = [UIFont fontWithName:Font_Next_medium size:Font_Size_Muzzik_Message];
    [self addSubview:_decriptionLabel];
    _badgeImage = [[badgeImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-32, 22, 16, 16)];
    [_badgeImage setImage:[UIImage imageNamed:@"noti_cycle"]];
    [self addSubview:_badgeImage];

    
    CAShapeLayer *border = [CAShapeLayer layer];
    border.strokeColor = Color_Text_3.CGColor;
    border.fillColor = nil;
    border.contentsScale = [UIScreen mainScreen].scale;
    border.lineWidth =0.3;
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(16, 59)];
    [path addLineToPoint:CGPointMake(SCREEN_WIDTH-16, 59)];
    border.path = path.CGPath;
    [self.layer addSublayer:border];
    
}
//- (void)drawRect:(CGRect)rect
//{
//    CGContextRef context = UIGraphicsGetCurrentContext();
//      CGContextSetLineWidth(context, 1);
//    CGContextSetStrokeColorWithColor(context, Color_line_1.CGColor);
//     //CGContextSetRGBStrokeColor(context, 0.5, 0.5, 0.5, 0.5);//线条颜色
//     CGContextMoveToPoint(context, 16, 59);
//     CGContextAddLineToPoint(context, SCREEN_WIDTH-16,59);
//     CGContextStrokePath(context);
//    
//}
@end
