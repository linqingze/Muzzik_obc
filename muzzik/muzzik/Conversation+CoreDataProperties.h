//
//  Conversation+CoreDataProperties.h
//  muzzik
//
//  Created by muzzik on 16/1/9.
//  Copyright © 2016年 muzziker. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Conversation.h"

NS_ASSUME_NONNULL_BEGIN

@interface Conversation (CoreDataProperties)

@property (nonatomic) NSTimeInterval sendTime;
@property (nullable, nonatomic, retain) NSString *targetId;
@property (nullable, nonatomic, retain) NSString *type;
@property (nullable, nonatomic, retain) Message *lastMessage;
@property (nullable, nonatomic, retain) NSSet<Message *> *messages;
@property (nullable, nonatomic, retain) NSSet<UserCore *> *targetUser;

@end

@interface Conversation (CoreDataGeneratedAccessors)

- (void)addMessagesObject:(Message *)value;
- (void)removeMessagesObject:(Message *)value;
- (void)addMessages:(NSSet<Message *> *)values;
- (void)removeMessages:(NSSet<Message *> *)values;

- (void)addTargetUserObject:(UserCore *)value;
- (void)removeTargetUserObject:(UserCore *)value;
- (void)addTargetUser:(NSSet<UserCore *> *)values;
- (void)removeTargetUser:(NSSet<UserCore *> *)values;

@end

NS_ASSUME_NONNULL_END
