//
//  NotifyObject.h
//  muzzik
//
//  Created by muzzik on 15/5/18.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface NotifyObject : NSObject
@property (nonatomic,copy) NSString *notify_id;
@property (nonatomic,copy) NSString *type;
@property (nonatomic,assign) double date;
@property (nonatomic,copy) NSString *owner;
@property (nonatomic,retain) MuzzikUser *user;
@property (nonatomic,retain) muzzik *muzzik;
@property (nonatomic,assign) BOOL readed;
@property (nonatomic,assign) BOOL saw;
-(NSMutableArray*)makeMuzziksByNotifyArray:(NSMutableArray *)array;
@end
