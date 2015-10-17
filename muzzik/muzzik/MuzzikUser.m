//
//  user.m
//  muzzik
//
//  Created by muzzik on 15/4/11.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "MuzzikUser.h"

@implementation MuzzikUser
-(NSMutableArray*)makeMuzziksByUserArray:(NSMutableArray *)array{
    NSMutableArray *users = [NSMutableArray array];
    for (NSDictionary *dic in array) {
        MuzzikUser *newUser = [MuzzikUser new];
        
        newUser.descrip = [dic objectForKey:@"description"];
        newUser.user_id = [dic objectForKey:Parameter_Id];
        newUser.avatar = [dic objectForKey:Parameter_avatar];
        newUser.gender = [dic objectForKey:Parameter_Gender];
        newUser.name = [dic objectForKey:Parameter_name];
        if ([[dic allKeys] containsObject:@"isFollow"]) {
            newUser.isFollow = [[dic objectForKey:@"isFollow"] boolValue];
        }
        if ([[dic allKeys] containsObject:@"isFans"]) {
            newUser.isFans = [[dic objectForKey:@"isFans"] boolValue];
        }
        
        
        [users addObject:newUser];
    }
    return users;
}
@end
