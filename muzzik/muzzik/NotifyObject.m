//
//  NotifyObject.m
//  muzzik
//
//  Created by muzzik on 15/5/18.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "NotifyObject.h"

@implementation NotifyObject
-(NSMutableArray*)makeMuzziksByNotifyArray:(NSMutableArray *)array{
     NSMutableArray *notifies = [NSMutableArray array];
    for (NSDictionary *dic in array) {
        NotifyObject *notify = [NotifyObject new];
        if ([[dic allKeys] containsObject:@"muzzik"] && [[dic  objectForKey:@"muzzik"] isKindOfClass:[NSDictionary class]]) {
            muzzik *newmuzzik = [muzzik new];
            newmuzzik.muzzik_id = [[dic  objectForKey:@"muzzik"] objectForKey:@"_id"];
            newmuzzik.ismoved = [[[dic  objectForKey:@"muzzik"] objectForKey:@"ismoved"] boolValue];
            newmuzzik.date = [[dic  objectForKey:@"muzzik"] objectForKey:@"date"];
            newmuzzik.message = [[dic  objectForKey:@"muzzik"] objectForKey:@"message"];
            newmuzzik.image = [[dic  objectForKey:@"muzzik"]  objectForKey:@"image"];
            newmuzzik.topics = [[dic  objectForKey:@"muzzik"]objectForKey:@"topics"];
            newmuzzik.users = [[dic  objectForKey:@"muzzik"] objectForKey:@"users"];
            newmuzzik.type = [[dic  objectForKey:@"muzzik"] objectForKey:@"type"];
            newmuzzik.onlytext = [[[dic  objectForKey:@"muzzik"] objectForKey:@"onlyText"] boolValue];
            newmuzzik.reposts = [[dic  objectForKey:@"muzzik"] objectForKey:@"reposts"];
            newmuzzik.shares = [[dic  objectForKey:@"muzzik"] objectForKey:@"shares"];
            newmuzzik.comments = [[dic  objectForKey:@"muzzik"] objectForKey:@"comments"];
            newmuzzik.color = [[dic  objectForKey:@"muzzik"] objectForKey:@"color"];
            newmuzzik.moveds = [[dic  objectForKey:@"muzzik"] objectForKey:@"moveds"];
            newmuzzik.isprivate = [[[dic  objectForKey:@"muzzik"] objectForKey:@"private"] boolValue];
            newmuzzik.plays = [[dic  objectForKey:@"muzzik"] objectForKey:@"plays"];
            newmuzzik.repostID = [[dic  objectForKey:@"muzzik"] objectForKey:@"repostID"];
            newmuzzik.title = [[dic  objectForKey:@"muzzik"]objectForKey:@"title"];
            newmuzzik.repostDate = [[dic  objectForKey:@"muzzik"] objectForKey:@"repostDate"];
            newmuzzik.reposter = [MuzzikUser new];
            newmuzzik.reposter.name = [[[dic  objectForKey:@"muzzik"] objectForKey:@"repostUser"] objectForKey:@"name"];
            newmuzzik.reposter.user_id = [[[dic  objectForKey:@"muzzik"] objectForKey:@"repostUser"] objectForKey:@"_id"];
            newmuzzik.reposter.avatar = [[[dic  objectForKey:@"muzzik"] objectForKey:@"repostUser"] objectForKey:@"avatar"];
            newmuzzik.reposter.gender = [[[dic  objectForKey:@"muzzik"] objectForKey:@"repostUser"] objectForKey:@"gender"];
            if ([[[dic  objectForKey:@"muzzik"] allKeys] containsObject:@"user"]  ) {
                newmuzzik.MuzzikUser = [MuzzikUser new];
                newmuzzik.MuzzikUser.user_id = [[dic  objectForKey:@"muzzik"] objectForKey:@"user"];

            }
            if ([[[dic  objectForKey:@"muzzik"] allKeys] containsObject:@"music"]) {
                newmuzzik.music = [music new];
                newmuzzik.music.music_id = [[[dic  objectForKey:@"muzzik"] objectForKey:@"music"] objectForKey:@"_id"];
                newmuzzik.music.artist = [[[dic  objectForKey:@"muzzik"] objectForKey:@"music"] objectForKey:@"artist"];
                //NSLog(@"%@",[[dic objectForKey:@"music"] objectForKey:@"artist"]);
                newmuzzik.music.key = [[[dic  objectForKey:@"muzzik"] objectForKey:@"music"] objectForKey:@"key"];
                // newmuzzik.music.block = [[[dic objectForKey:@"music"] objectForKey:@"block"] boolValue];
                newmuzzik.music.name = [[[dic  objectForKey:@"muzzik"] objectForKey:@"music"] objectForKey:@"name"];
            }
            
            if ([[dic allKeys ] containsObject:@"reply"]) {
                newmuzzik.reply = [ReplyObject new];
                newmuzzik.reply.reply_id = [[dic objectForKey:@"reply"] objectForKey:@"_id"];
                newmuzzik.reply.message = [[dic objectForKey:@"reply"] objectForKey:@"message"];
                newmuzzik.reply.color = [[dic objectForKey:@"reply"] objectForKey:@"color"];
            }
            notify.muzzik = newmuzzik;
        }
        
        
        MuzzikUser *newUser = [MuzzikUser new];
        newUser.user_id =  [[dic objectForKey:@"user" ]  objectForKey:Parameter_Id];
        newUser.avatar =  [[dic objectForKey:@"user" ]  objectForKey:Parameter_avatar];
        newUser.name =  [[dic objectForKey:@"user" ]  objectForKey:Parameter_name];

        notify.user = newUser;
        notify.notify_id = [dic objectForKey:@"_id"];
        notify.type = [dic objectForKey:@"type"];
        notify.date = [[dic objectForKey:@"date"] doubleValue];
        notify.owner = [dic objectForKey:@"owner"];
        notify.readed = [[dic objectForKey:@"readed"] boolValue];
        notify.saw = [[dic objectForKey: @"saw"] boolValue];
        [notifies addObject:notify];
    }
    return notifies;
}
@end
