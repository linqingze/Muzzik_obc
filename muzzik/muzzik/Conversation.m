//
//  Conversation.m
//  muzzik
//
//  Created by muzzik on 16/1/8.
//  Copyright © 2016年 muzziker. All rights reserved.
//

#import "Conversation.h"
#import "Message.h"
#import "UserCore.h"

@implementation Conversation

// Insert code here to add functionality to your managed object subclass
- (void)addMessagesObject:(Message *)value{
    NSMutableOrderedSet* tempSet = [[NSMutableOrderedSet alloc] init];
    [tempSet addObjectsFromArray:[self.messages array]];
    [tempSet addObject:value];
    self.messages = tempSet;
}
@end
