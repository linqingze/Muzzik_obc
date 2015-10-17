//
//  TopicModel.m
//  muzzik
//
//  Created by muzzik on 15/4/27.
//  Copyright (c) 2015年 muzziker. All rights reserved.
//

#import "TopicModel.h"

@implementation TopicModel


-(NSMutableArray*)makeTopicssByMuzzikArray:(NSMutableArray *)array{
    NSMutableArray *topics = [NSMutableArray array];
    for (NSDictionary *dic in array) {
        TopicModel *newtopic = [TopicModel new];
        newtopic.tid = [dic objectForKey:@"_id"];
        newtopic.name = [dic objectForKey:@"name"];
        newtopic.updateTime = [dic objectForKey:@"updateTime"];
        newtopic.lastPoster = [MuzzikUser new];
        newtopic.lastPoster.user_id =[[dic objectForKey:@"lastPoster"] objectForKey:@"_id"];
        newtopic.lastPoster.avatar = [[dic objectForKey:@"lastPoster"] objectForKey:@"avatar"];
        newtopic.lastPoster.gender = [[dic objectForKey:@"lastPoster"] objectForKey:@"gender"];
        newtopic.lastPoster.name = [[dic objectForKey:@"lastPoster"] objectForKey:@"name"];
        newtopic.rank = [dic objectForKey:@"rank"];
        newtopic.lastRank = [dic objectForKey:@"lastRank"];
        newtopic.amount = [dic objectForKey:@"amount"];
        newtopic.color = [dic objectForKey:@"color"];
        [topics addObject:newtopic];
    }
    return topics;
}
@end
