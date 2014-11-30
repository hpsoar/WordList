//
//  WordDB.m
//  WordList
//
//  Created by HuangPeng on 11/25/14.
//  Copyright (c) 2014 Beacon. All rights reserved.
//

#import "WordDB.h"

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
    self = [super initWithModelName:@"WordList"
                           storeURL:@"WordList.sqlite"
              ubiquitousContentName:@"iCloudWordListStore"];
    if (self) {
        _entityName = @"Word";
    }
    return self;
}

- (void)activate {
    
}

- (Word *)insertWord {
    return [self insertObjectForEntityWithName:_entityName];
}

- (void)deleteWord:(Word *)word {
    [self deleteObject:word];
}

- (Word *)word:(NSString *)text {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"word = %@", text];
    return [self queryOneFromEntityWithName:_entityName withPredicate:predicate];
}

- (NSFetchRequest *)fetchRequest {
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"word"
                                                                     ascending:YES
                                                                      selector:@selector(localizedCaseInsensitiveCompare:)];
    NSFetchRequest *fetchRequest = [self fetchRequestForEntity:_entityName
                                                     predicate:nil
                                                sortDescriptor:sortDescriptor
                                                     batchSize:20];
    return fetchRequest;
}

- (NSFetchedResultsController *)fetchedResultsControllerSectioned:(BOOL)sectioned {
    NSFetchRequest *fetchRequest = [self fetchRequest];
    return [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                               managedObjectContext:self.managedObjectContext
                                                 sectionNameKeyPath:@"firstLetter"
                                                          cacheName:nil];
}

@end
