//
//  CoreStack.h
//  muzzik
//
//  Created by muzzik on 16/1/9.
//  Copyright © 2016年 muzziker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Account.h"
#import "Message.h"
#import "Conversation.h"
#import "UserCore.h"
@interface CoreStack : NSObject
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;




+ (id)sharedInstance ;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
-(Account *) getAccountByUserName:(NSString *)name userId:(NSString *) uid userToken:(NSString *)token;
-(Message *) getNewMessage;
-(UserCore *) getNewUser;
-(Conversation *) getNewConversation;
@end
