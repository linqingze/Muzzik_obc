//
//  Conversation+CoreDataProperties.m
//  muzzik
//
//  Created by muzzik on 16/1/19.
//  Copyright © 2016年 muzziker. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Conversation+CoreDataProperties.h"

@implementation Conversation (CoreDataProperties)

@dynamic abstractString;
@dynamic sendTime;
@dynamic targetId;
@dynamic type;
@dynamic unReadMessage;
@dynamic accountForConversation;
@dynamic messages;
@dynamic targetUser;

@end
