//
//  setNameVc.h
//  muzzik
//
//  Created by muzzik on 15/4/15.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//


@interface setNameVc : AMScrollingNavbarViewController<UITextFieldDelegate>{
    UITextField *nameText;
    UILabel * tipsLabel;
    BOOL isOk;
    BOOL isCheck;
}
@end
