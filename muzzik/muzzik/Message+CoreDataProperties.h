//
//  Message+CoreDataProperties.h
//  muzzik
//
//  Created by muzzik on 16/1/11.
//  Copyright © 2016年 muzziker. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Message.h"

NS_ASSUME_NONNULL_BEGIN

@interface Message (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *messageContent;
@property (nullable, nonatomic, retain) NSNumber *messageId;
@property (nullable, nonatomic, retain) NSString *messageImage;
@property (nullable, nonatomic, retain) NSString *messageType;
@property (nullable, nonatomic, retain) NSData *messageVoice;
@property (nullable, nonatomic, retain) NSDate *sendTime;
@property (nullable, nonatomic, retain) NSNumber *needsToShowTime;
@property (nullable, nonatomic, retain) NSNumber *isOwner;
@property (nullable, nonatomic, retain) NSNumber *cellHeight;
@property (nullable, nonatomic, retain) Conversation *lastMessage;
@property (nullable, nonatomic, retain) Conversation *messages;

@end

NS_ASSUME_NONNULL_END
