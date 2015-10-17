//
//  SettingCell.m
//  muzzik
//
//  Created by muzzik on 15/5/11.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "SettingCell.h"

@implementation SettingCell

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
    _label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, SCREEN_WIDTH-150, 60)];
    [_label setFont:[UIFont systemFontOfSize:14]];
    _label.textColor = Color_Text_1;
    [self addSubview:_label];
    
    _dataNum = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-135, 0, 120 , 60)];
    [_dataNum setFont:[UIFont systemFontOfSize:14]];
    _dataNum.textColor = Color_Text_1;
    [self addSubview:_dataNum];
    _dataNum.textAlignment = NSTextAlignmentRight;
    
    _shakeSwitch = [[ZJSwitch alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-90, 12, 70, 25)];
    _shakeSwitch.backgroundColor = [UIColor clearColor];
    _shakeSwitch.tintColor = Color_line_1;
    _shakeSwitch.onText = @"打开";
    _shakeSwitch.offText = @"关闭";
    [self addSubview:_shakeSwitch];
     [_shakeSwitch addTarget:self action:@selector(handleSwitchEvent:) forControlEvents:UIControlEventValueChanged];
    
    [MuzzikItem addLineOnView:self heightPoint:59 toLeft:13 toRight:13 withColor:Color_line_1];
    
}
-(void)handleSwitchEvent:(id)sender{
    if (self.cellKeeper.isClosed) {
        self.cellKeeper.isClosed = NO;
        [MuzzikItem addObjectToLocal:@"open" ForKey:@"User_shakeActionSwitch"];
    }else{
        self.cellKeeper.isClosed = YES;
        [MuzzikItem addObjectToLocal:@"close" ForKey:@"User_shakeActionSwitch"];
    }
}
@end
