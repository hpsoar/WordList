//
//  DefinitionApi.h
//  WordList
//
//  Created by HuangPeng on 12/6/14.
//  Copyright (c) 2014 Beacon. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^DefinitionQuerySuccess)(NSArray *results);
typedef void (^DefinitionQueryFailure)(NSError *error);

@interface DefinitionApi : NSObject

+ (instancetype)sharedApi;

- (BOOL)query:(NSString *)query success:(void(^)(NSArray *results))success failure:(void(^)(NSError *error))failure;

@end
