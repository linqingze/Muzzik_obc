//
//  UserCore+CoreDataProperties.h
//  muzzik
//
//  Created by muzzik on 16/1/9.
//  Copyright © 2016年 muzziker. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "UserCore.h"

NS_ASSUME_NONNULL_BEGIN

@interface UserCore (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *avatar;
@property (nonatomic) NSTimeInterval birthday;
@property (nullable, nonatomic, retain) NSString *descrip;
@property (nullable, nonatomic, retain) NSString *gender;
@property (nonatomic) BOOL isFans;
@property (nonatomic) BOOL isFollow;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *school;
@property (nullable, nonatomic, retain) NSString *user_id;
@property (nullable, nonatomic, retain) NSString *company;
@property (nonatomic) int32_t musicsTotal;
@property (nonatomic) int32_t muzzikTotal;
@property (nonatomic) int32_t followsCount;
@property (nonatomic) int32_t fansCount;
@property (nonatomic) int32_t topicsTotal;
@property (nullable, nonatomic, retain) NSString *astro;
@property (nullable, nonatomic, retain) NSData *genres;
@property (nullable, nonatomic, retain) Conversation *conversation;

@end

NS_ASSUME_NONNULL_END
