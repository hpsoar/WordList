//
//  ViewController.m
//  WordList
//
//  Created by HuangPeng on 11/24/14.
//  Copyright (c) 2014 Beacon. All rights reserved.
//

#import "ViewController.h"
#import "AFHTTPSessionManager.h"

NSString* const kYoudaoKeyFrom  = @"kernelpanic";
NSString* const kYoudaokey      = @"482091942";

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *label;

@end

@implementation ViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(lookupWordInPasteBoard) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    self.label.numberOfLines = 0;
    [self lookupWordInPasteBoard];
}

- (void)lookupWordInPasteBoard {
    NSString *word = [UIPasteboard generalPasteboard].string;
    NSLog(@"%@", word);
    if (word) {
        [self queryYoudao:word];
    }
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
        NSLog(@"%@", responseObject);
        NSArray *translations = responseObject[@"translation"];
        self.label.text = [translations componentsJoinedByString:@"\n"];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@", error);
    }];
}

@end
