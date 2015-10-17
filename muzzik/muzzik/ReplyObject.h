//
//  ReplyObject.h
//  muzzik
//
//  Created by muzzik on 15/5/18.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReplyObject : NSObject
@property (nonatomic,copy) NSString *reply_id;
@property (nonatomic,copy) NSString *message;
@property (nonatomic,copy) NSString *color;
@end
