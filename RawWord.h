//
//  RawWord.h
//  WordList
//
//  Created by HuangPeng on 12/6/14.
//  Copyright (c) 2014 Beacon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface RawWord : NSManagedObject

@property (nonatomic, retain) NSString * word;
@property (nonatomic, retain) NSNumber * rawState;
@property (nonatomic, retain) NSNumber * rawSource;

@end
