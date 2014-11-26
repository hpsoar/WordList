//
//  Word+Utility.m
//  WordList
//
//  Created by HuangPeng on 11/26/14.
//  Copyright (c) 2014 Beacon. All rights reserved.
//

#import "Word+Utility.h"

@implementation Word (Utility)

- (void)copyValues:(Word *)word {
    self.word = word.word;
    self.phonetic = word.phonetic;
    self.usPhonetic = word.usPhonetic;
    self.ukPhonetic = word.ukPhonetic;
    self.meanings = word.meanings;
}

@end
