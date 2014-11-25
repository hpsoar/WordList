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
    NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:wordList.count];
    for (Word *word in wordList) {
        [items addObject:[[WordItem alloc] initWithWord:word]];
    }
    [self.model addObjectsFromArray:items];
    
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
        
        Word *word = [WordDB insertWord];
        word.word = query;
        word.phonetic = phontic;
        word.usPhonetic = usPhonetic;
        word.ukPhonetic = ukPhonetic;
        if (explains.count > 0) {
            word.meanings = [explains componentsJoinedByString:@"\n"];
        }
        else {
            word.meanings = [translations componentsJoinedByString:@"\n"];
        }
        [WordDB save];
        [results addObject:word];
        
        for (NSDictionary *dict in json[@"web"]) {
            NSString *key = dict[@"key"];
            NSArray *value = dict[@"value"];
            Word *word = [WordDB insertWord];
            word.word = key;
            word.meanings = [value componentsJoinedByString:@"\n"];
            
            [results addObject:word];
        }
        [WordDB save];
    }
    
    return results;
}

- (void)search {
    
}

- (void)showWordbook {
    
}

@end
