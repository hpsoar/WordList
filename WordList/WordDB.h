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

- (void)activate;

- (Word *)insertWord;

- (void)deleteWord:(Word *)word;

- (Word *)word:(NSString *)text;

- (NSFetchRequest *)fetchRequest;

- (NSFetchedResultsController *)fetchedResultsControllerSectioned:(BOOL)sectioned;

#pragma mark - review

/* 
 * FETCH STRAGEGY
 * 1. select a batch of words whose schedule_time < now, limit 50;
 * 2. if less than 50, say A, select a batch of words, whose schedule_time is 0 (from 1970) limit 50 - A;
 *      a. goto 4;
 *    //a. if less than 50 - A, select words with schedule_time closest to now;
 *    //b. else got to 4;
 * 3. else goto 4;
 * 4. review this tbatch of words;
 * 5. update their scheduled_time to a future time according to review_count;
 * 6. if user choose to continue, goto 1;
 * 7. finish, otherwise;
 */
- (NSArray *)wordsToReview;

/*
 * HH. 复习点的确定（根据艾宾浩斯记忆曲线制定）：
 * 1． 第一个记忆周期：5分钟
 * 2． 第二个记忆周期：30分钟
 * 3． 第三个记忆周期：12小时
 * 4． 第四个记忆周期：1天
 * 5． 第五个记忆周期：2天
 * 6． 第六个记忆周期：4天
 * 7． 第七个记忆周期：7天
 * 8． 第八个记忆周期：15天
 *
 * UPDATE STRATEGY
 * 0. we start at HH.0, when we have done HH.0, we are at HH.1, etc.
 * 1. if the word is first time reviewed update as expected;
 * 2. if we reviewed before word.review.next_review_time:
 *      eg. we have done HH.2, and scheduled a review 12 hours later;
 *          however, we reviewed 1 hours later, we should stay at HH.3,
 *          which is to review 12 hours later, rather than 1 day later;
 * 3. if we reviewed long after word.review.next_review_time:
 *      eg. we have done HH.1, then we didn't review it for a long time, say 1 month, 
 *          we should be at HH.1, after current review;
 * 4. otherwise, we update as normally;
 */
- (void)scheduleNextReviewTimeForWord:(Word *)word remembered:(BOOL)remembered;

@end
