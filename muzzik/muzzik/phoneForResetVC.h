//
//  phoneForResetVC.h
//  muzzik
//
//  Created by muzzik on 15/4/16.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//


@interface phoneForResetVC : AMScrollingNavbarViewController<UITextFieldDelegate>{
    UITextField *phoneText;
    BOOL isOk;
    UILabel *tipsLabel;
}

@end
