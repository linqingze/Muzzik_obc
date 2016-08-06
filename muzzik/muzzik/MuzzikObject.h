//
//  MuzzikObject.h
//  muzzik
//
//  Created by muzzik on 15/4/27.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NotifyButton.h"
@interface MuzzikObject : NSObject

@property (nonatomic,retain) music *music;
@property (nonatomic,copy) NSString *message;
@property (nonatomic,copy) NSString *tempmessage;   //保存话题的选择的临时字段，添加到文本后，清空该字段数据。
@property (nonatomic,copy) NSString *imageKey;
@property (nonatomic,retain)NSMutableArray *lyricArray;
@property (nonatomic,assign) BOOL isPrivate;
@property (nonatomic,assign) BOOL isMessageVCOpen;    //信息选择界面是否已经开启，若是，选择音乐后会pop回该界面，否则push一个新的信息选择界面。
@property (nonatomic,copy) NSString *lastDate;
@property (nonatomic,retain) NotifyButton *notifyBUtton;
@property (nonatomic,retain) UILabel *lyricTipsLabel;
@property (nonatomic,copy) NSString *GeiLyricType;
@property (nonatomic,retain) UIImage *image;
@property (nonatomic,copy) NSString *atFriendFrom;    //@好友回跳区别参数

+(MuzzikObject *) shareClass;
-(void) clearObject;
@end
