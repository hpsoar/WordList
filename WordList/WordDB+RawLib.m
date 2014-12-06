//
//  WordDB+RawLib.m
//  WordList
//
//  Created by HuangPeng on 12/6/14.
//  Copyright (c) 2014 Beacon. All rights reserved.
//

#import "WordDB+RawLib.h"

static NSString *rawWordEntityName = @"RawWord";

@implementation WordDB (RawLib)

- (void)import:(NSArray *)words source:(RawWordSource)source {
    for (NSString *word in words) {
        RawWord *rawWord = [self insertObjectForEntityWithName:rawWordEntityName];
        rawWord.word = word;
        rawWord.source = source;
        rawWord.state = kRawWordStateUndetermined;
    }
    [self saveContext];
}

- (NSFetchRequest *)fetchRequestForRawWordsWithState:(RawWordState)state source:(RawWordSource)source {
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"word"
                                                                     ascending:YES
                                                                      selector:@selector(localizedCaseInsensitiveCompare:)];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"rawState = %d and rawSource = %d", state, source];
    if (state == kRawWordStateAll) {
        predicate = [NSPredicate predicateWithFormat:@"ANY rawSource = %d", source];
    }
    NSFetchRequest *fetchRequest = [self fetchRequestForEntity:rawWordEntityName
                                                     predicate:predicate
                                                sortDescriptor:sortDescriptor
                                                     batchSize:20];
    return fetchRequest;
}

- (NSArray *)wordsWithState:(RawWordState)state source:(RawWordSource)source limit:(NSInteger)limit {
    NSFetchRequest *fetchRequest = [self fetchRequestForRawWordsWithState:state source:source];
    if (limit > 0) {
        fetchRequest.fetchLimit = limit;
    }
    NSError *error;
    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NIDPRINT(@"%@", error);
    }
    return results;
}

- (NSFetchedResultsController *)fetchedResultsControllerForRawWordsWithState:(RawWordState)state source:(RawWordSource)source {
    NSFetchRequest *fetchRequest = [self fetchRequestForRawWordsWithState:state source:source];
    return [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                               managedObjectContext:self.managedObjectContext
                                                 sectionNameKeyPath:nil
                                                          cacheName:nil];
}

@end
