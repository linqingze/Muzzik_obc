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
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    _titleImage = [[UIImageView alloc] initWithFrame:CGRectMake(16, 10, 40, 40)];
    _titleImage.layer.cornerRadius = 20;
    _titleImage.layer.masksToBounds = YES;
    [self addSubview:_titleImage];
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(72, 12, SCREEN_WIDTH-180, 17)];
    [_nameLabel setTextColor:Color_Text_1];
    _nameLabel.font = [UIFont fontWithName:Font_Next_medium size:Font_Size_Muzzik_Message];
    [self addSubview:_nameLabel];
    
    _messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(72, 36, SCREEN_WIDTH-128, 14)];
    [_messageLabel setTextColor:Color_Text_2];
    _messageLabel.font = [UIFont fontWithName:Font_Next_medium size:12];
    [self addSubview:_messageLabel];
    
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-116, 15, 100, 12)];
    _timeLabel.textAlignment = NSTextAlignmentRight;
    [_timeLabel setTextColor:Color_Additional_5];
    _timeLabel.font = [UIFont fontWithName:Font_Next_medium size:8];
    [self addSubview:_timeLabel];
    
    _badgeImage = [[badgeImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-32, 34, 16, 16)];
    [_badgeImage setImage:[UIImage imageNamed:@"noti_cycle"]];
    [self addSubview:_badgeImage];

    
    CAShapeLayer *border = [CAShapeLayer layer];
    border.strokeColor = Color_Text_3.CGColor;
    border.fillColor = nil;
    border.contentsScale = [UIScreen mainScreen].scale;
    border.lineWidth =0.3;
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(16, 60)];
    [path addLineToPoint:CGPointMake(SCREEN_WIDTH-16, 60)];
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
