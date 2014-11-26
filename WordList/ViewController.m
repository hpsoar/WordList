//
//  ViewController.m
//  WordList
//
//  Created by HuangPeng on 11/24/14.
//  Copyright (c) 2014 Beacon. All rights reserved.
//

#import "ViewController.h"
#import "AFHTTPSessionManager.h"
#import "WordItem.h"

NSString* const kYoudaoKeyFrom  = @"kernelpanic";
NSString* const kYoudaokey      = @"482091942";

@interface ViewController ()

@end

@implementation ViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"PasteBoard Word";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(search)];
   
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(showWordbook)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(lookupWordInPasteBoard) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [self lookupWordInPasteBoard];
}

- (void)loadView {
    [super loadView];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)lookupWordInPasteBoard {
    NSString *word = [UIPasteboard generalPasteboard].string;
    NSLog(@"%@", word);
    if (word) {
        [self queryYoudao:word];
    }
}

- (void)updateModelWithWordList:(NSArray *)wordList {
    [self resetModel];

    [self.model addObjectsFromArray:wordList];
    
    [self reloadTableView];
}

-(void)queryYoudao:(NSString*)word {
    NSString *const kYoudaoURL = @"http://fanyi.youdao.com";
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:kYoudaoURL]];
    NSDictionary *params = @{ @"keyfrom": kYoudaoKeyFrom,
                              @"key": kYoudaokey,
                              @"type": @"data",
                              @"doctype": @"json",
                              @"version": @1.1,
                              @"q": word };
    [manager GET:@"openapi.do" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray *wordList = [self parseWordList:responseObject];
        [self updateModelWithWordList:wordList];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@", error);
    }];
}

- (NSArray *)parseWordList:(NSDictionary *)json {
    NSMutableArray *results = [NSMutableArray new];
    if ([json[@"errorCode"] integerValue] == 0) {
        NSString *query = json[@"query"];
        NSArray *translations = json[@"translation"];
        NSDictionary *basic = json[@"basic"];
        NSArray *explains = basic[@"explains"];
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

- (void)search {
    
}

- (void)showWordbook {
    
}

@end
