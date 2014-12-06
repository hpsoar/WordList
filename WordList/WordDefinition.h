//
//  WordDefinition.h
//  WordList
//
//  Created by HuangPeng on 12/6/14.
//  Copyright (c) 2014 Beacon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Review;

@interface WordDefinition : NSManagedObject

@property (nonatomic, retain) NSString * definitions;
@property (nonatomic, retain) NSString * phonetic;
@property (nonatomic, retain) NSString * ukPhonetic;
@property (nonatomic, retain) NSString * usPhonetic;
@property (nonatomic, retain) NSString * word;
@property (nonatomic, retain) Review *review;

@end
