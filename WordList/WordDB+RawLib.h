//
//  WordDB+RawLib.h
//  WordList
//
//  Created by HuangPeng on 12/6/14.
//  Copyright (c) 2014 Beacon. All rights reserved.
//

#import "WordDB.h"

#import "RawWord+Extension.h"

@interface WordDB (RawLib)

- (void)import:(NSArray *)words source:(RawWordSource)source;

- (NSArray *)wordsWithState:(RawWordState)state source:(RawWordSource)source limit:(NSInteger)limit;

- (NSFetchedResultsController *)fetchedResultsControllerForRawWordsWithState:(RawWordState)state source:(RawWordSource)source;

@end
