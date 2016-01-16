//
//  UserCore+CoreDataProperties.h
//  muzzik
//
//  Created by muzzik on 16/1/16.
//  Copyright © 2016年 muzziker. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "UserCore.h"

NS_ASSUME_NONNULL_BEGIN

@interface UserCore (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *astro;
@property (nullable, nonatomic, retain) NSString *avatar;
@property (nullable, nonatomic, retain) NSString *birthday;
@property (nullable, nonatomic, retain) NSString *company;
@property (nullable, nonatomic, retain) NSString *descrip;
@property (nullable, nonatomic, retain) NSNumber *fansCount;
@property (nullable, nonatomic, retain) NSNumber *followsCount;
@property (nullable, nonatomic, retain) NSString *gender;
@property (nullable, nonatomic, retain) NSData *genres;
@property (nullable, nonatomic, retain) NSNumber *isFans;
@property (nullable, nonatomic, retain) NSNumber *isFollow;
@property (nullable, nonatomic, retain) NSNumber *musicsTotal;
@property (nullable, nonatomic, retain) NSNumber *muzzikTotal;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *school;
@property (nullable, nonatomic, retain) NSNumber *topicsTotal;
@property (nullable, nonatomic, retain) NSString *user_id;
@property (nullable, nonatomic, retain) Account *accountOwner;
@property (nullable, nonatomic, retain) Conversation *conversation;
@property (nullable, nonatomic, retain) NSSet<Message *> *messageOwner;
@property (nullable, nonatomic, retain) Account *userForAccount;

@end

@interface UserCore (CoreDataGeneratedAccessors)

- (void)addMessageOwnerObject:(Message *)value;
- (void)removeMessageOwnerObject:(Message *)value;
- (void)addMessageOwner:(NSSet<Message *> *)values;
- (void)removeMessageOwner:(NSSet<Message *> *)values;

@end

NS_ASSUME_NONNULL_END
