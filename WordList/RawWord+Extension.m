//
//  RawWord+Extension.m
//  WordList
//
//  Created by HuangPeng on 12/6/14.
//  Copyright (c) 2014 Beacon. All rights reserved.
//

#import "RawWord+Extension.h"

@implementation RawWord (Extension)

- (RawWordState )state {
    return [self.rawState integerValue];
}

- (RawWordSource)source {
    return [self.rawSource integerValue];
}

- (void)setSource:(RawWordSource)source {
    self.rawSource = @(source);
}

- (void)setState:(RawWordState)state {
    self.rawState = @(state);
}

@end
