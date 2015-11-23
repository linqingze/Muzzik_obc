//
//  muzzik.m
//  muzzik
//
//  Created by muzzik on 15/4/11.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "muzzik.h"

@implementation muzzik
-(NSMutableArray*)makeMuzziksByMuzzikArray:(NSMutableArray *)array{
    NSMutableArray *muzziks = [NSMutableArray array];
    userInfo *user = [userInfo shareClass];
    if (!user.followDic) {
        user.followDic = [NSMutableDictionary dictionary];
    }
    for (NSDictionary *dic in array) {
        muzzik *newmuzzik = [muzzik new];
        newmuzzik.muzzik_id = [dic objectForKey:@"_id"];
        newmuzzik.ismoved = [[dic objectForKey:@"ismoved"] boolValue];
        newmuzzik.date = [dic objectForKey:@"date"];
        newmuzzik.message = [dic objectForKey:@"message"];
        if ([[dic allKeys] containsObject:@"image"] ) {
            newmuzzik.image = [dic objectForKey:@"image"];
        }
        
        newmuzzik.topics = [dic objectForKey:@"topics"];
        newmuzzik.users = [dic objectForKey:@"users"];
        newmuzzik.type = [dic objectForKey:@"type"];
        newmuzzik.onlytext = [[dic objectForKey:@"onlyText"] boolValue];
        newmuzzik.isReposted = [[dic objectForKey:@"isReposted"] boolValue];
        newmuzzik.reposts = [dic objectForKey:@"reposts"];
        newmuzzik.shares = [dic objectForKey:@"shares"];
        newmuzzik.comments = [dic objectForKey:@"comments"];
        newmuzzik.color = [dic objectForKey:@"color"];
        newmuzzik.moveds = [dic objectForKey:@"moveds"];
        newmuzzik.isprivate = [[dic objectForKey:@"private"] boolValue];
        newmuzzik.plays = [dic objectForKey:@"plays"];
        newmuzzik.repostID = [dic objectForKey:@"repostID"];
        newmuzzik.title = [dic objectForKey:@"title"];
        newmuzzik.repostDate = [dic objectForKey:@"repostDate"];
        newmuzzik.reposter = [MuzzikUser new];
        newmuzzik.reposter.name = [[dic objectForKey:@"repostUser"] objectForKey:@"name"];
        newmuzzik.reposter.user_id = [[dic objectForKey:@"repostUser"] objectForKey:@"_id"];
        newmuzzik.reposter.avatar = [[dic objectForKey:@"repostUser"] objectForKey:@"avatar"];
        newmuzzik.reposter.gender = [[dic objectForKey:@"repostUser"] objectForKey:@"gender"];
        
        newmuzzik.MuzzikUser = [MuzzikUser new];
        newmuzzik.MuzzikUser.avatar = [[dic objectForKey:@"user"] objectForKey:@"avatar"];
        newmuzzik.MuzzikUser.user_id = [[dic objectForKey:@"user"] objectForKey:@"_id"];
        newmuzzik.MuzzikUser.gender = [[dic objectForKey:@"user"] objectForKey:@"gender"];
        newmuzzik.MuzzikUser.name = [[dic objectForKey:@"user"] objectForKey:@"name"];
        newmuzzik.MuzzikUser.isFollow =[[[dic objectForKey:@"user"] objectForKey:@"isFollow"] boolValue];
        [user.followDic setValue:[[dic objectForKey:@"user"] objectForKey:@"isFollow"] forKey:[[dic objectForKey:@"user"] objectForKey:@"_id"]];
        newmuzzik.MuzzikUser.isFans =[[[dic objectForKey:@"user"] objectForKey:@"isFans"] boolValue];
        newmuzzik.music = [music new];
        newmuzzik.music.music_id = [[dic objectForKey:@"music"] objectForKey:@"_id"];
         newmuzzik.music.artist = [[dic objectForKey:@"music"] objectForKey:@"artist"];
        //NSLog(@"%@",[[dic objectForKey:@"music"] objectForKey:@"artist"]);
        newmuzzik.music.key = [[dic objectForKey:@"music"] objectForKey:@"key"];
       // newmuzzik.music.block = [[[dic objectForKey:@"music"] objectForKey:@"block"] boolValue];
        newmuzzik.music.name = [[dic objectForKey:@"music"] objectForKey:@"name"];
        if ([[dic allKeys ] containsObject:@"reply"] &&[[dic objectForKey:@"reply"] isKindOfClass:[NSDictionary class]] &&[[[dic objectForKey:@"reply"] allKeys] count]>1) {
            newmuzzik.reply = [ReplyObject new];
            newmuzzik.reply.reply_id = [[dic objectForKey:@"reply"] objectForKey:@"_id"];
            newmuzzik.reply.message = [[dic objectForKey:@"reply"] objectForKey:@"message"];
            newmuzzik.reply.color = [[dic objectForKey:@"reply"] objectForKey:@"color"];
        }else if([[dic allKeys ] containsObject:@"reply"] &&[[dic objectForKey:@"reply"] isKindOfClass:[NSString class]] && [[dic objectForKey:@"reply"] length]>0 ){
            newmuzzik.replystring = [dic objectForKey:@"reply"];
        }
        [muzziks addObject:newmuzzik];
    }
    return muzziks;
}

-(NSMutableArray*)makeMuzziksByMusicArray:(NSMutableArray *)array{
    NSMutableArray *muzziks = [NSMutableArray array];
    for (NSDictionary *dic in array) {
        muzzik *newmuzzik = [muzzik new];
        newmuzzik.music = [music new];
        newmuzzik.music.music_id = [dic objectForKey:@"_id"];
        newmuzzik.music.artist = [dic objectForKey:@"artist"];
        newmuzzik.music.key = [dic objectForKey:@"key"];
        newmuzzik.music.name = [dic objectForKey:@"name"];
        [muzziks addObject:newmuzzik];
    }
    return muzziks;
}
-(NSString *)description{
    return [NSString stringWithFormat:@"music Key :%@%@",BaseURL_audio,self.music.key];
}
-(BOOL)isEqual:(id)object{
    if (object == nil)
    {
        return NO;
    }
    
    if ([object class] != [muzzik class])
    {
        return NO;
    }else{
        muzzik *myMuzzik = (muzzik *)object;
        if ([self.muzzik_id length] >0) {
            if ([self.muzzik_id isEqualToString:myMuzzik.muzzik_id]) {
                return YES;
            }else{
                return NO;
            }
        }else{
            if ([self.music.music_id isEqualToString:myMuzzik.music.music_id]) {
                return YES;
            }else{
                return NO;
            }
        }
    }
}
@end
