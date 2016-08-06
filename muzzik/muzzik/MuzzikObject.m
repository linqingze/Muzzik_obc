//
//  MuzzikObject.m
//  muzzik
//
//  Created by muzzik on 15/4/27.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "MuzzikObject.h"

@implementation MuzzikObject
+(MuzzikObject *) shareClass{
    static MuzzikObject *myclass=nil;
    if(!myclass){
        myclass = [[super allocWithZone:NULL] init];
    }
    return myclass;
}

+(id)allocWithZone:(NSZone *)zone{
    return [self shareClass];
}

-(void)clearObject{
    self.music = nil;
    self.message = nil;
    self.tempmessage = nil;
    self.imageKey = nil;
    self.lyricArray = nil;
    self.isPrivate = NO;
    self.isMessageVCOpen = NO;
    self.lyricArray = nil;
    self.image = nil;
    
}
@end
