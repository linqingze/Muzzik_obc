//
//  Message+CoreDataProperties.m
//  muzzik
//
//  Created by muzzik on 16/1/9.
//  Copyright © 2016年 muzziker. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Message+CoreDataProperties.h"

@implementation Message (CoreDataProperties)

@dynamic messageContent;
@dynamic messageImage;
@dynamic messageType;
@dynamic messageVoice;
@dynamic messageId;
@dynamic sendTime;
@dynamic lastMessage;
@dynamic messages;

@end
