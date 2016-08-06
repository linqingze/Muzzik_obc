//
//  Account.m
//  muzzik
//
//  Created by muzzik on 16/1/9.
//  Copyright © 2016年 muzziker. All rights reserved.
//

#import "Account.h"
#import "Conversation.h"
#import "UserCore.h"

@implementation Account

// Insert code here to add functionality to your managed object subclass
- (void)addMyConversationObject:(Conversation *)value{
    NSMutableOrderedSet* tempSet = [[NSMutableOrderedSet alloc] init];
    [tempSet addObjectsFromArray:[self.myConversation array]];
    [tempSet addObject:value];
    self.myConversation = tempSet;
}
- (void)insertObject:(Conversation *)value inMyConversationAtIndex:(NSUInteger)idx{
    NSMutableOrderedSet* tempSet = [[NSMutableOrderedSet alloc] init];
    [tempSet addObjectsFromArray:[self.myConversation array]];
    [tempSet insertObject:value atIndex:idx];
    self.myConversation = tempSet;
}

- (void)removeMyConversationObject:(Conversation *)value{
    NSMutableOrderedSet* tempSet = [[NSMutableOrderedSet alloc] init];
    [tempSet addObjectsFromArray:[self.myConversation array]];
    [tempSet removeObject:value];
    self.myConversation = [tempSet copy];
}
@end
