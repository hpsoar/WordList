//
//  Word+Utility.m
//  WordList
//
//  Created by HuangPeng on 11/26/14.
//  Copyright (c) 2014 Beacon. All rights reserved.
//

#import "WordDefinition+Utility.h"

@implementation WordDefinition (Utility)

- (NSString *)firstLetter {
    return [[self.word substringToIndex:1] uppercaseString];
}

@end
