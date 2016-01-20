//
//  Conversation+CoreDataProperties.h
//  muzzik
//
//  Created by muzzik on 16/1/19.
//  Copyright © 2016年 muzziker. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Conversation.h"

NS_ASSUME_NONNULL_BEGIN

@interface Conversation (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *abstractString;
@property (nullable, nonatomic, retain) NSDate *sendTime;
@property (nullable, nonatomic, retain) NSString *targetId;
@property (nullable, nonatomic, retain) NSString *type;
@property (nullable, nonatomic, retain) NSNumber *unReadMessage;
@property (nullable, nonatomic, retain) Account *accountForConversation;
@property (nullable, nonatomic, retain) NSOrderedSet<Message *> *messages;
@property (nullable, nonatomic, retain) UserCore *targetUser;

@end

@interface Conversation (CoreDataGeneratedAccessors)

- (void)insertObject:(Message *)value inMessagesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromMessagesAtIndex:(NSUInteger)idx;
- (void)insertMessages:(NSArray<Message *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeMessagesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInMessagesAtIndex:(NSUInteger)idx withObject:(Message *)value;
- (void)replaceMessagesAtIndexes:(NSIndexSet *)indexes withMessages:(NSArray<Message *> *)values;
- (void)addMessagesObject:(Message *)value;
- (void)removeMessagesObject:(Message *)value;
- (void)addMessages:(NSOrderedSet<Message *> *)values;
- (void)removeMessages:(NSOrderedSet<Message *> *)values;

@end

NS_ASSUME_NONNULL_END
