//
//  RawWord+Extension.h
//  WordList
//
//  Created by HuangPeng on 12/6/14.
//  Copyright (c) 2014 Beacon. All rights reserved.
//

#import "RawWord.h"

typedef NS_ENUM(NSInteger, RawWordSource) {
    kRawWordSourceUnknown,
    kRawWordSourceGRE,
    kRawWordSourceTOEFL,
    kRawWordSourceLevel8,
};

typedef NS_ENUM(NSInteger, RawWordState) {
    kRawWordStateUndetermined,
    kRawWordStateSkipped,
    kRawWordStateFavored,
    kRawWordStateAll,
};

@interface RawWord (Extension)

@property (nonatomic) RawWordSource source;

@property (nonatomic) RawWordState state;

@end
