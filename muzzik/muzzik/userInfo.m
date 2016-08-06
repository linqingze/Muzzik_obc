//
//  userInfo.m
//  ShopUpUp
//
//  Created by kevin's mac on 14-8-1.
//  Copyright (c) 2014年 IOS. All rights reserved.
//
#import "LoginViewController.h"
#import "userInfo.h"

@implementation userInfo
+(userInfo *) shareClass{
    static userInfo *myclass=nil;
    if(!myclass){
        myclass = [[super allocWithZone:NULL] init];
    }
    return myclass;
}

+(id)allocWithZone:(NSZone *)zone{
    return [self shareClass];
}
+(void)checkLoginWithVC:(UIViewController *)vc{
    LoginViewController *login = [[LoginViewController alloc] init];
    [vc.navigationController pushViewController:login animated:YES];
}

-(id)init{
    self = [super init];
    if(self){
        _playList = [NSMutableDictionary dictionary];
        NSMutableDictionary *square = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSMutableArray array],@"muzziks",@"广场列表",@"descrip",@"square",@"type", nil];
        [_playList setValue:square forKey:Constant_userInfo_square];
        _listenUser = [NSMutableArray array];
        _wacthUser = [NSMutableArray array];
        NSMutableDictionary *follow = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSMutableArray array],@"muzziks",@"关注列表",@"descrip",@"follow",@"type", nil];
        [_playList setValue:follow forKey:Constant_userInfo_follow];
        
        NSMutableDictionary *myMuzzik = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSMutableArray array],@"muzziks",@"我的Muzzik",@"descrip",@"own",@"type", nil];
       [_playList setValue:myMuzzik forKey:Constant_userInfo_own];
        
        NSMutableDictionary *suggest = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSMutableArray array],@"muzziks",@"推荐列表",@"descrip",@"suggest",@"type", nil];
        [_playList setValue:suggest forKey:Constant_userInfo_suggest];
        
        NSMutableDictionary *move = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSMutableArray array],@"muzziks",@"喜欢列表",@"descrip",@"move",@"type", nil];
       [_playList setValue:move forKey:Constant_userInfo_move];
        
        NSMutableDictionary *temp = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSMutableArray array],@"muzziks",@"临时列表",@"descrip",@"temp",@"type", nil];
        [_playList setValue:temp forKey:Constant_userInfo_temp];
        
        
     //   _token = [[NSString alloc]init];
     //   _customer_id = [[NSString alloc]init];
    }
    return self;
}

@end
