//
//  CoreData.h
//  WordList
//
//  Created by HuangPeng on 11/25/14.
//  Copyright (c) 2014 Beacon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface CoreData : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

- (id)insertObjectForEntityWithName:(NSString *)name;
- (void)deleteObject:(id)object;

- (id)entityWithName:(NSString *)name;

- (id)queryOneFromEntityWithName:(NSString *)name withPredicate:(NSPredicate *)predicate;

- (NSArray *)queryFromEntityWithName:(NSString *)name withPredicate:(NSPredicate *)predicate;

@end
