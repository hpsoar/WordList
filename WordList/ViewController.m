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
#import "WordListViewController.h"

@protocol WordEditingActionViewDelegate <NSObject>

- (void)wordEdittingViewDidEditWord;

@end

@interface WordEditingActionView : UIView
@property (nonatomic, weak) id<WordEditingActionViewDelegate> delegate;
@property (nonatomic, strong) NSString *word;
@property (nonatomic, readonly) NSString *editedWord;
@end

@implementation WordEditingActionView {
    UILabel *_wordLabel;
    NSString *_editedWord;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor lightGrayColor];
        CGFloat xOffset = 10;
        NSArray *titles = @[@"Trim 1", @"Trim 2", @"Reset", @"Edit" ];
        _wordLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.width, 36)];
        _wordLabel.numberOfLines = 0;
        _wordLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_wordLabel];
        
        for (int i = 0; i < titles.count; ++i) {
            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(xOffset, 36, 60, 44)];
            [btn setTitle:titles[i] forState:UIControlStateNormal];
            btn.tag = i;
            [btn addTarget:self action:@selector(actionSelected:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btn];
            xOffset += btn.width + 10;
        }
    }
    return self;
}

- (void)setWord:(NSString *)word {
    _word = word;
    self.editedWord = word;
}

- (void)setEditedWord:(NSString *)word {
    _editedWord = word;
    _wordLabel.text = _editedWord;
}

- (void)actionSelected:(id)sender {
    UIButton *btn = sender;
    switch (btn.tag) {
        case 0:
            self.editedWord = [self.word substringToIndex:self.word.length - 1];
            break;
        case 1:
            self.editedWord = [self.word substringToIndex:self.word.length - 2];
            break;
        case 2:
            if ([self.editedWord isEqualToString:self.word]) {
                return;
            }
            self.editedWord = self.word;
            break;
        default:
            break;
    }
    if (btn.tag < 3) {
        [self.delegate wordEdittingViewDidEditWord];
    }
}

@end

NSString* const kYoudaoKeyFrom  = @"kernelpanic";
NSString* const kYoudaokey      = @"482091942";

@interface ViewController () <WordEditingActionViewDelegate>
@property (nonatomic, strong) WordEditingActionView *editingView;
@property (nonatomic, strong) AFHTTPSessionManager *httpSession;
@end

@implementation ViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Word";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(search)];
   
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(showWordbook)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(lookupWordInPasteBoard) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    self.editingView = [[WordEditingActionView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 80)];
    self.editingView.delegate = self;
    
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
        self.tableView.tableHeaderView = self.editingView;
        self.editingView.word = word;
        [self queryYoudao:word];
    }
}

- (void)updateModelWithWordList:(NSArray *)wordList {
    [self resetModel];

    [self.model addObjectsFromArray:wordList];
    
    [self.tableView reloadData];
}

-(void)queryYoudao:(NSString*)word {
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
    WordListViewController *controller = [WordListViewController new];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)wordEdittingViewDidEditWord {
    [self queryYoudao:self.editingView.editedWord];
}

@end
