//
//  WordDB.m
//  WordList
//
//  Created by HuangPeng on 11/25/14.
//  Copyright (c) 2014 Beacon. All rights reserved.
//

#import "WordDB.h"

static NSString *wordEntityName = @"Word";

@implementation WordDB {
    NSString *_entityName;
}

+ (instancetype)sharedDB {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [WordDB new];
    });
    return instance;
}

- (id)init {
    self = [super initWithModelName:@"WordList" storeURL:@"WordList.sqlite" ubiquitousContentName:@"iCloudWordListStore"];
    if (self) {
        NSNotificationCenter *dc = [NSNotificationCenter defaultCenter];
        [dc addObserver:self
               selector:@selector(persistentStoreDidImportUbiquitousContentChanges:)
                   name:NSPersistentStoreDidImportUbiquitousContentChangesNotification
                 object:self.persistentStoreCoordinator];
    }
    return self;
}

- (Word *)insertWord {
    return [self insertObjectForEntityWithName:wordEntityName];
}

- (void)deleteWord:(Word *)word {
    [self deleteObject:word];
}

- (Word *)word:(NSString *)text {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"word = %@", text];
    return [self queryOneFromEntityWithName:wordEntityName withPredicate:predicate];
}

- (NSFetchRequest *)fetchRequest {
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"word" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    NSFetchRequest *fetchRequest = [self fetchRequestForEntity:wordEntityName predicate:nil sortDescriptor:sortDescriptor batchSize:20];
    return fetchRequest;
}

- (NSFetchedResultsController *)fetchedResultsControllerSectioned:(BOOL)sectioned {
    NSFetchRequest *fetchRequest = [self fetchRequest];
    NSFetchedResultsController *controller = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"firstLetter" cacheName:nil];
    return controller;
}

- (void)persistentStoreDidImportUbiquitousContentChanges:(NSNotification *)notification {
    NSManagedObjectContext *moc = self.managedObjectContext;
    [moc performBlock:^{
        [moc mergeChangesFromContextDidSaveNotification:notification];
        
        // you may want to post a notification here so that which ever part of your app
        // needs to can react appropriately to what was merged.
        // An exmaple of how to iterate over what was merged follows, although I wouldn't
        // recommend doing it here. Better handle it in a delegate or use notifications.
        // Note that the notification contains NSManagedObjectIDs
        // and not NSManagedObjects.
        NSDictionary *changes = notification.userInfo;
        NSMutableSet *allChanges = [NSMutableSet new];
        [allChanges unionSet:changes[NSInsertedObjectsKey]];
        [allChanges unionSet:changes[NSUpdatedObjectsKey]];
        [allChanges unionSet:changes[NSDeletedObjectsKey]];

        for (NSManagedObjectID *objID in allChanges) {
            // do whatever you need to with the NSManagedObjectID
            // you can retrieve the object from with [moc objectWithID:objID]
            NSLog(@"object: %@",[moc objectWithID:objID]);
        }
    }];
}

@end
