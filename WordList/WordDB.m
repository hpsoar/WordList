//
//  WordDB.m
//  WordList
//
//  Created by HuangPeng on 11/25/14.
//  Copyright (c) 2014 Beacon. All rights reserved.
//

#import "WordDB.h"

static NSString *wordEntityName = @"WordList";

@implementation WordDB

+ (CoreData *)db {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [CoreData new];
    });
    return instance;
}

+ (Word *)insertWord {
    return [self.db insertObjectForEntityWithName:wordEntityName];
}

+ (void)deleteWord:(Word *)word {
    [self.db deleteObject:word];
}

+ (Word *)word:(NSString *)text {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"word = %@", text];
    return [self.db queryOneFromEntityWithName:wordEntityName withPredicate:predicate];
}

+ (void)save {
    [self.db saveContext];
}

@end
