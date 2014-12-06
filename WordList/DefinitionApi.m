//
//  DefinitionApi.m
//  WordList
//
//  Created by HuangPeng on 12/6/14.
//  Copyright (c) 2014 Beacon. All rights reserved.
//

#import "DefinitionApi.h"
#import "AFHTTPSessionManager.h"
#import "WordItem.h"

NSString* const kYoudaoKeyFrom  = @"kernelpanic";
NSString* const kYoudaokey      = @"482091942";

@interface DefinitionApi ()

@property (nonatomic, strong) AFHTTPSessionManager *httpSession;

@end

@implementation DefinitionApi

+ (instancetype)sharedApi {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [DefinitionApi new];
    });
    return instance;
}

- (BOOL)query:(NSString *)query success:(void(^)(NSArray *results))success failure:(void(^)(NSError *error))failure {
    [self queryYoudao:query success:success failure:failure];
    return YES;
}

- (void)queryYoudao:(NSString*)word success:(void(^)(NSArray *results))success failure:(void(^)(NSError *error))failure {
    NSString *const kYoudaoURL = @"http://fanyi.youdao.com";
    
    if (self.httpSession) {
        [self.httpSession invalidateSessionCancelingTasks:YES];
        self.httpSession = nil;
    }
    
    self.httpSession = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:kYoudaoURL]];
    NSDictionary *params = @{ @"keyfrom": kYoudaoKeyFrom,
                              @"key": kYoudaokey,
                              @"type": @"data",
                              @"doctype": @"json",
                              @"version": @1.1,
                              @"q": word };
    [self.httpSession GET:@"openapi.do" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray *wordList = [self parseWordList:responseObject];
        if (success) {
            success(wordList);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NIDPRINT(@"%@", error);
        if (failure) {
            failure(error);
        }
    }];
}

- (NSArray *)parseWordList:(NSDictionary *)json {
    NSMutableArray *results = [NSMutableArray new];
    if ([json[@"errorCode"] integerValue] == 0) {
        NSString *query = json[@"query"];
        NSArray *translations = json[@"translation"];
        NSDictionary *basic = json[@"basic"];
        NSMutableArray *explains = [basic[@"explains"] mutableCopy];
        NSString *phontic = basic[@"phonetic"];
        NSString *ukPhonetic = basic[@"uk-phonetic"];
        NSString *usPhonetic = basic[@"us-phonetic"];
        
        WordItem *item = [WordItem new];
        item.word = query;
        item.phonetic = phontic;
        if (explains.count > 0) {
            item.definition = [explains componentsJoinedByString:@"\n"];
        }
        else {
            item.definition = [translations componentsJoinedByString:@"\n"];
        }
        [results addObject:item];
        
        for (NSDictionary *dict in json[@"web"]) {
            NSString *key = dict[@"key"];
            NSArray *value = dict[@"value"];
            WordItem *item = [WordItem new];
            item.word = key;
            item.definition = [value componentsJoinedByString:@"\n"];
            
            [results addObject:item];
        }
    }
    
    return results;
}

@end
