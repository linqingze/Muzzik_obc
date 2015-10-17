//
//  MessageStepViewController.h
//  muzzik
//
//  Created by muzzik on 15/4/27.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "shareBaseController.h"

@interface MessageStepViewController : shareBaseController
@property (nonatomic,copy) NSString *message;
@property (nonatomic,retain) music *muzzikmusic;
@property (nonatomic,assign) BOOL isNewSelected;
@end
