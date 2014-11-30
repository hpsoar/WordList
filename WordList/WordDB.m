//
//  WordDB.m
//  WordList
//
//  Created by HuangPeng on 11/25/14.
//  Copyright (c) 2014 Beacon. All rights reserved.
//

#import "WordDB.h"
#import "Review.h"

static NSString *wordEntityName = @"Word";
static NSString *reviewEntityName = @"Review";

@implementation WordDB {
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
    }
    return self;
}

- (void)activate {
    
}

- (Word *)insertWord {
    Word *word = [self insertObjectForEntityWithName:wordEntityName];
    word.review = [self insertObjectForEntityWithName:reviewEntityName];
    return word;
}

- (void)deleteWord:(Word *)word {
    [self deleteObject:word];
}

- (Word *)word:(NSString *)text {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"word = %@", text];
    return [self queryOneFromEntityWithName:wordEntityName withPredicate:predicate];
}

- (NSFetchRequest *)fetchRequest {
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"word"
                                                                     ascending:YES
                                                                      selector:@selector(localizedCaseInsensitiveCompare:)];
    NSFetchRequest *fetchRequest = [self fetchRequestForEntity:wordEntityName
                                                     predicate:nil
                                                sortDescriptor:sortDescriptor
                                                     batchSize:20];
    return fetchRequest;
}

- (NSFetchedResultsController *)fetchedResultsControllerSectioned:(BOOL)sectioned {
    return [[NSFetchedResultsController alloc] initWithFetchRequest:[self fetchRequest]
                                               managedObjectContext:self.managedObjectContext
                                                 sectionNameKeyPath:@"firstLetter"
                                                          cacheName:nil];
}

#pragma mark - review

- (NSArray *)wordsToReview {
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    NSMutableArray *results = [NSMutableArray new];
    NSInteger limit = 50;
    [results addObjectsFromArray:[self wordsWithNextReviewTimeLessThan: time limit:limit]];
    if (results.count < limit) {
        [results addObjectsFromArray:[self wordsNotScheduled:limit - results.count]];
    }
    if (results.count < limit) {
        [results addObjectsFromArray:[self wordsScheduledInTheFutureWithReferenceTime:time limit:limit - results.count]];
    }
    return results;
}

- (NSTimeInterval)intervalOfStage:(NSInteger)stage {
    NSDictionary *map = @{
                          @0: @0,
                          @1: @(5 * 60),
                          @2: @(30 * 60),
                          @3: @(12 * 3600),
                          @4: @(24 * 3600),
                          @5: @(2 * 24 * 3600),
                          @6: @(4 * 24 * 3600),
                          @7: @(7 * 24 * 3600),
                          @8: @(15 * 23 *3600),
                          };
    if (stage > 8) {
        return 30 * 24 * 3600;
    }
    return [map[@(stage)] doubleValue];
}

- (NSTimeInterval)expirationIntervalOfStage:(NSInteger)stage {
    NSDictionary *map = @{
                          @0: @0,
                          @1: @(5 * 60),
                          @2: @(30 * 60),
                          @3: @(6 * 3600),
                          @4: @(6 * 3600),
                          @5: @(12 * 3600),
                          @6: @(24 * 3600),
                          @7: @(2 * 24 * 3600),
                          @8: @(4 * 23 *3600),
                          };
    if (stage > 8) {
        return 7 * 24 * 3600;
    }
    return [map[@(stage)] doubleValue];
}

// > 0 -- yes
// < 0 -- rest
// == 0 -- no
- (BOOL)shouldUpdateStageForWord:(Word *)word {
    NSInteger stage = [word.review.reviewed_count integerValue];
    if (stage == 0) {
        return 1;
    }
    
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval interval = [word.review.next_review_time doubleValue] - time;
    NSTimeInterval expected_interval = [self intervalOfStage:stage];
    if (interval > 0) {
        if ((interval / expected_interval) < 0.2) {
            return 1;
        }
        else {
            return 0;
        }
    }
    else if (interval < 0) {
        NSTimeInterval expirationInterval = [self expirationIntervalOfStage:stage];
        if (-interval < expirationInterval) {
            return 1;
        }
        else {
            return -1;
        }
    }
    return 1;
}

- (void)scheduleNextReviewTimeForWord:(Word *)word remembered:(BOOL)remembered {
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
  
    word.review.last_review_time = @(time);
    if (remembered) {
        word.review.successive_known_count = [word.review.successive_known_count addInt:1];
        word.review.known_count = [word.review.known_count addInt:1];
    }
    else {
        word.review.successive_known_count = @0;
        word.review.unknown_count = [word.review.unknown_count addInt:1];
    }
    
    int shouldUpdate = [self shouldUpdateStageForWord:word];
    if (shouldUpdate > 0) {
        word.review.reviewed_count = [word.review.reviewed_count addInt:1];
    }
    else if (shouldUpdate < 0) {
        NIDASSERT([word.review.reviewed_count integerValue] > 0);
        if ([word.review.reviewed_count integerValue] > 0) {
            word.review.reviewed_count = [word.review.reviewed_count addInt:-1];
        }
    }
    
    word.review.next_review_time = @([self intervalOfStage:[word.review.reviewed_count integerValue]] + time);
    
    [self saveContext];
}

- (NSArray *)wordsWithNextReviewTimeLessThan:(NSTimeInterval)time limit:(NSInteger)limit {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY review.next_review_time > 0 and review.next_review_time <= %lf", time];
    NSArray *sorters = @[ ];
    
    return [self queryWithPredicate:predicate sorters:sorters limit:limit];
}

- (NSArray *)wordsNotScheduled:(NSInteger)limit {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY review.reviewed_count = 0"];
    return [self queryWithPredicate:predicate sorters:nil limit:limit];
}

- (NSArray *)wordsScheduledInTheFutureWithReferenceTime:(NSTimeInterval)referenceTime limit:(NSInteger)limit {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY review.next_review_time > %lf", referenceTime];
    NSArray *sorters = @[[NSSortDescriptor sortDescriptorWithKey:@"review.next_review_time" ascending:YES]];
    return [self queryWithPredicate:predicate sorters:sorters limit:limit];
}

- (NSArray *)queryWithPredicate:(NSPredicate *)predicate sorters:(NSArray *)sorters limit:(NSInteger)limit {
    NSFetchRequest *fetchRequest = [self fetchRequestForEntity:wordEntityName
                                                     predicate:predicate
                                               sortDescriptors:sorters
                                                     batchSize:limit];
    return [self execute: fetchRequest];
}

@end
