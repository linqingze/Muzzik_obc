//
//  Account+CoreDataProperties.h
//  muzzik
//
//  Created by muzzik on 16/1/11.
//  Copyright © 2016年 muzziker. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Account.h"

NS_ASSUME_NONNULL_BEGIN

@interface Account (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *astro;
@property (nullable, nonatomic, retain) NSString *avatar;
@property (nullable, nonatomic, retain) NSData *avatar_Image;
@property (nullable, nonatomic, retain) NSString *avatar_small;
@property (nullable, nonatomic, retain) NSData *avatar_smallImage;
@property (nullable, nonatomic, retain) NSDate *birthday;
@property (nullable, nonatomic, retain) NSString *company;
@property (nullable, nonatomic, retain) NSString *descrip;
@property (nullable, nonatomic, retain) NSNumber *fansCount;
@property (nullable, nonatomic, retain) NSData *feedData;
@property (nullable, nonatomic, retain) NSNumber *followsCount;
@property (nullable, nonatomic, retain) NSString *gender;
@property (nullable, nonatomic, retain) NSData *genres;
@property (nullable, nonatomic, retain) NSData *moveData;
@property (nullable, nonatomic, retain) NSNumber *movedTotal;
@property (nullable, nonatomic, retain) NSNumber *musicsTotal;
@property (nullable, nonatomic, retain) NSNumber *muzzikTotal;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSData *ownerData;
@property (nullable, nonatomic, retain) NSString *school;
@property (nullable, nonatomic, retain) NSData *squareData;
@property (nullable, nonatomic, retain) NSData *suggestData;
@property (nullable, nonatomic, retain) NSString *token;
@property (nullable, nonatomic, retain) NSNumber *topicsTotal;
@property (nullable, nonatomic, retain) NSString *user_id;
@property (nullable, nonatomic, retain) NSSet<Conversation *> *myConversation;
@property (nullable, nonatomic, retain) NSSet<UserCore *> *myUser;

@end

@interface Account (CoreDataGeneratedAccessors)

- (void)addMyConversationObject:(Conversation *)value;
- (void)removeMyConversationObject:(Conversation *)value;
- (void)addMyConversation:(NSSet<Conversation *> *)values;
- (void)removeMyConversation:(NSSet<Conversation *> *)values;

- (void)addMyUserObject:(UserCore *)value;
- (void)removeMyUserObject:(UserCore *)value;
- (void)addMyUser:(NSSet<UserCore *> *)values;
- (void)removeMyUser:(NSSet<UserCore *> *)values;

@end

NS_ASSUME_NONNULL_END
