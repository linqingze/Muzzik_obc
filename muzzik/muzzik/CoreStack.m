//
//  CoreStack.m
//  muzzik
//
//  Created by muzzik on 16/1/9.
//  Copyright © 2016年 muzziker. All rights reserved.
//

#import "CoreStack.h"

@implementation CoreStack
#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;



+ (id)sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{ sharedInstance = [[self alloc] init]; });
    return sharedInstance;
}


- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "BlueOrbit._____" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Muzzik_coreModel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Muzzik_coreModel.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

-(Account *) getAccountByUserName:(NSString *)name userId:(NSString *) uid userToken:(NSString *)token{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Account" inManagedObjectContext:self.managedObjectContext];
    Account *account;
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user_id == %@",uid];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        NSLog(@"无法打开");
        return nil;
    }else{
        if ([fetchedObjects count] >0) {
            return fetchedObjects[0];
        }else{
            account = [[Account alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];
            account.user_id = uid;
            account.token = token;
            account.name = name;
            [self.managedObjectContext save:nil];
            return account;
            
        }
    }
    return nil;
}
-(Message *) getNewMessage{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:self.managedObjectContext];
    Message *message = [[Message alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];
    return message;
}
-(UserCore *) getNewUser{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"UserCore" inManagedObjectContext:self.managedObjectContext];
    UserCore *user = [[UserCore alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];
    return user;
}
-(Conversation *) getNewConversation{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Conversation" inManagedObjectContext:self.managedObjectContext];
    Conversation *con = [[Conversation alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];
    return con;
}





//NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@api/user/%@",BaseURL,[responseObject objectForKey:@"_id"]]];
//NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
//[request setHTTPMethod:@"GET"];
//
////(2)超时时间
//[request setTimeoutInterval:15];
//[request setAllHTTPHeaderFields:[NSDictionary dictionaryWithObjectsAndKeys:@"application/json;encoding=utf-8",@"Content-Type",@"X-Auth-Token",token,nil]];
//NSURLResponse *response = nil;
//NSError *error = nil;
//NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
//if (!error && data) {
//    NSDictionary * responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
//    if (!error && responseObject) {
//        account = [[Account alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];
//        
//        if ([[responseObject allKeys] containsObject:@"name"] && [[responseObject objectForKey:@"name"] length] >0) {
//            account.name = [responseObject objectForKey:@"name"];
//        }
//        if ([[responseObject allKeys] containsObject:@"avatar"] && [[responseObject objectForKey:@"avatar"] length] >0) {
//            account.avatar = [responseObject objectForKey:@"avatar"];
//        }
//        
//        if ([[responseObject allKeys] containsObject:@"school"] && [[responseObject objectForKey:@"school"] length] >0) {
//            account.school = [responseObject objectForKey:@"school"];
//        }
//        
//        if ([[responseObject allKeys] containsObject:@"company"] && [[responseObject objectForKey:@"company"] length] >0) {
//            account.company = [responseObject objectForKey:@"company"];
//        }
//        
//        if ([[responseObject allKeys] containsObject:@"topicsTotal"] && [[responseObject objectForKey:@"topicsTotal"] length] >0) {
//            account.topicsTotal = (int32_t)[[responseObject objectForKey:@"topicsTotal"] integerValue];
//        }
//        
//        if ([[responseObject allKeys] containsObject:@"musicsTotal"] && [[responseObject objectForKey:@"musicsTotal"] length] >0) {
//            account.musicsTotal = (int32_t)[[responseObject objectForKey:@"musicsTotal"] integerValue];
//        }
//        if ([[responseObject allKeys] containsObject:@"muzzikTotal"] && [[responseObject objectForKey:@"muzzikTotal"] length] >0) {
//            account.muzzikTotal = (int32_t)[[responseObject objectForKey:@"muzzikTotal"] integerValue];
//        }
//        if ([[responseObject allKeys] containsObject:@"followsCount"] && [[responseObject objectForKey:@"followsCount"] length] >0) {
//            account.followsCount = (int32_t)[[responseObject objectForKey:@"followsCount"] integerValue];
//        }
//        if ([[responseObject allKeys] containsObject:@"fansCount"] && [[responseObject objectForKey:@"fansCount"] length] >0) {
//            account.fansCount = (int32_t)[[responseObject objectForKey:@"fansCount"] integerValue];
//        }
//        
//        if ([[responseObject allKeys] containsObject:@"gender"] && [[responseObject objectForKey:@"gender"] length] >0) {
//            account.gender = [responseObject objectForKey:@"gender"];
//        }
//        
//        if ([[responseObject allKeys] containsObject:@"astro"] && [[responseObject objectForKey:@"astro"] length] >0) {
//            account.astro = [responseObject objectForKey:@"astro"];
//        }
//        
//        if ([[responseObject allKeys] containsObject:@"description"] && [[responseObject objectForKey:@"description"] length] >0) {
//            account.descrip = [responseObject objectForKey:@"description"];
//        }
//        return account;
//        
//    }
//}

@end
