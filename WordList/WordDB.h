//
//  WordDB.h
//  WordList
//
//  Created by HuangPeng on 11/25/14.
//  Copyright (c) 2014 Beacon. All rights reserved.
//

#import "CoreData.h"
#import "Word.h"
#import <CoreData/CoreData.h>

@interface WordDB : CoreData

+ (instancetype)sharedDB;

- (Word *)insertWord;

- (void)deleteWord:(Word *)word;

- (Word *)word:(NSString *)text;

- (NSFetchRequest *)fetchRequest;

- (NSFetchedResultsController *)fetchedResultsControllerSectioned:(BOOL)sectioned;

@end
