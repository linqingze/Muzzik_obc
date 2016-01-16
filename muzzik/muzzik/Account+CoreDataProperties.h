//
//  Account+CoreDataProperties.h
//  muzzik
//
//  Created by muzzik on 16/1/16.
//  Copyright © 2016年 muzziker. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Account.h"

NS_ASSUME_NONNULL_BEGIN

@interface Account (CoreDataProperties)

@property (nullable, nonatomic, retain) NSData *avatar_Image;
@property (nullable, nonatomic, retain) NSString *avatar_small;
@property (nullable, nonatomic, retain) NSData *avatar_smallImage;
@property (nullable, nonatomic, retain) NSData *feedData;
@property (nullable, nonatomic, retain) NSData *moveData;
@property (nullable, nonatomic, retain) NSData *ownerData;
@property (nullable, nonatomic, retain) NSData *squareData;
@property (nullable, nonatomic, retain) NSData *suggestData;
@property (nullable, nonatomic, retain) NSString *token;
@property (nullable, nonatomic, retain) NSString *user_id;
@property (nullable, nonatomic, retain) NSOrderedSet<Conversation *> *myConversation;
@property (nullable, nonatomic, retain) NSSet<UserCore *> *myUser;
@property (nullable, nonatomic, retain) UserCore *ownerUser;

@end

@interface Account (CoreDataGeneratedAccessors)

- (void)insertObject:(Conversation *)value inMyConversationAtIndex:(NSUInteger)idx;
- (void)removeObjectFromMyConversationAtIndex:(NSUInteger)idx;
- (void)insertMyConversation:(NSArray<Conversation *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeMyConversationAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInMyConversationAtIndex:(NSUInteger)idx withObject:(Conversation *)value;
- (void)replaceMyConversationAtIndexes:(NSIndexSet *)indexes withMyConversation:(NSArray<Conversation *> *)values;
- (void)addMyConversationObject:(Conversation *)value;
- (void)removeMyConversationObject:(Conversation *)value;
- (void)addMyConversation:(NSOrderedSet<Conversation *> *)values;
- (void)removeMyConversation:(NSOrderedSet<Conversation *> *)values;

- (void)addMyUserObject:(UserCore *)value;
- (void)removeMyUserObject:(UserCore *)value;
- (void)addMyUser:(NSSet<UserCore *> *)values;
- (void)removeMyUser:(NSSet<UserCore *> *)values;

@end

NS_ASSUME_NONNULL_END
