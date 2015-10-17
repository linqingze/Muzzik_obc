//
//  PlayListObject.h
//  muzzik
//
//  Created by muzzik on 15/5/1.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlayListObject : NSObject
@property(nonatomic,copy) NSString *listName;
@property(nonatomic,retain) NSMutableArray *muzziks;
@end
