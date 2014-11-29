//
//  Word.h
//  WordList
//
//  Created by HuangPeng on 11/29/14.
//  Copyright (c) 2014 Beacon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Word : NSManagedObject

@property (nonatomic, retain) NSString * meanings;
@property (nonatomic, retain) NSString * phonetic;
@property (nonatomic, retain) NSString * ukPhonetic;
@property (nonatomic, retain) NSString * usPhonetic;
@property (nonatomic, retain) NSString * word;

@end
