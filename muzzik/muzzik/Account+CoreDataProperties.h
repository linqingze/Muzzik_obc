//
//  Account+CoreDataProperties.h
//  muzzik
//
//  Created by muzzik on 16/1/9.
//  Copyright © 2016年 muzziker. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Account.h"

NS_ASSUME_NONNULL_BEGIN

@interface Account (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *user_id;
@property (nullable, nonatomic, retain) NSString *avatar;
@property (nonatomic) NSTimeInterval birthday;
@property (nullable, nonatomic, retain) NSString *school;
@property (nullable, nonatomic, retain) NSString *token;
@property (nullable, nonatomic, retain) NSString *company;
@property (nullable, nonatomic, retain) NSString *astro;
@property (nonatomic) int32_t followsCount;
@property (nonatomic) int32_t musicsTotal;
@property (nullable, nonatomic, retain) NSString *descrip;
@property (nonatomic) int32_t fansCount;
@property (nullable, nonatomic, retain) NSString *gender;
@property (nonatomic) int32_t muzzikTotal;
@property (nonatomic) int32_t topicsTotal;
@property (nonatomic) int32_t movedTotal;
@property (nullable, nonatomic, retain) NSData *genres;
@property (nullable, nonatomic, retain) NSString *avatar_small;
@property (nullable, nonatomic, retain) NSData *feedData;
@property (nullable, nonatomic, retain) NSData *squareData;
@property (nullable, nonatomic, retain) NSData *moveData;
@property (nullable, nonatomic, retain) NSData *suggestData;
@property (nullable, nonatomic, retain) NSData *ownerData;
@property (nullable, nonatomic, retain) NSData *avatar_Image;
@property (nullable, nonatomic, retain) NSData *avatar_smallImage;
@property (nullable, nonatomic, retain) Conversation *myConversation;
@property (nullable, nonatomic, retain) UserCore *myUser;

@end

NS_ASSUME_NONNULL_END
