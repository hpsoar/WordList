//
//  Review.h
//  WordList
//
//  Created by HuangPeng on 11/30/14.
//  Copyright (c) 2014 Beacon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Review : NSManagedObject

@property (nonatomic, retain) NSNumber * reviewed_count;
@property (nonatomic, retain) NSNumber * next_review_time;
@property (nonatomic, retain) NSNumber * known_count;
@property (nonatomic, retain) NSNumber * unknown_count;
@property (nonatomic, retain) NSNumber * successive_known_count;
@property (nonatomic, retain) NSNumber * last_review_time;

@end
