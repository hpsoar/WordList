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
@property (nonatomic, readonly) NSString *editedWord;
@property (nonatomic, readonly) NSString *word;
@end

@implementation WordEditingActionView {
    NSString *_editedWord;
    NSMutableArray *_btns;
    UIButton *_bigPasteBtn;
    UIView *_container;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        NSArray *titles = @[@"1", @"2", @"R", @"E", @"P" ];
        
        _bigPasteBtn = [self btnWithXOffset:20 width:self.width - 40 title:@"Paste" color:[UIColor redColor]];
        _bigPasteBtn.tag = titles.count - 1;
        [self addSubview:_bigPasteBtn];
        
        _container = [[UIView alloc] initWithFrame:self.bounds];
        
        _btns = [[NSMutableArray alloc] initWithCapacity:titles.count];
        
        UIColor *red = [UIColor redColor];
        UIColor *gray = RGBCOLOR_HEX(0xf1c40f);
        CGFloat xOffset = (self.width - titles.count * 44 - MAX(0, titles.count - 1) * 10) / 2;
        
        for (int i = 0; i < titles.count; ++i) {
            UIButton *btn = [self btnWithXOffset:xOffset
                                           width:44
                                           title:titles[i]
                                           color:i + 1 < titles.count ? gray : red ];
            xOffset += btn.width + 10;
            btn.tag = i;
            
            [_container addSubview:btn];
            [_btns addObject:btn];
        }
    }
    return self;
}

- (UIButton *)btnWithXOffset:(CGFloat)xOffset width:(CGFloat)width title:(NSString *)title color:(UIColor *)color {
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(xOffset, 8, width, 44)];
    [btn setTitle:title forState:UIControlStateNormal];
    btn.backgroundColor = color;
    
    btn.layer.cornerRadius = 3;
    btn.clipsToBounds = YES;
    
    [btn addTarget:self action:@selector(actionSelected:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

- (void)actionSelected:(id)sender {
    UIButton *btn = sender;
    switch (btn.tag) {
        case 0:
            if (self.word.length < 2) return;
            _editedWord = [self.word substringToIndex:self.word.length - 1];
            break;
        case 1:
            if (self.word.length < 3) return;
            _editedWord = [self.word substringToIndex:self.word.length - 2];
            break;
        case 2:
            if ([self.editedWord isEqualToString:self.word]) {
                return;
            }
            _editedWord = self.word;
            break;
        case 4: {
            NSString *word = [UIPasteboard generalPasteboard].string;
            if ([_editedWord isEqualToString:word]) {
                return;
            }
            _word = word;
            _editedWord = word;
            if (word != nil) {
                if (_bigPasteBtn.superview) {
                    [_bigPasteBtn removeFromSuperview];
                    [self addSubview:_container];
                }
            }
            else {
                if (_bigPasteBtn.superview == nil) {
                    [_container removeFromSuperview];
                    [self addSubview:_bigPasteBtn];
                }
            }
        }
            break;
        default:
            break;
    }
    
    if (btn.tag != 3) {
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
    self.title = @"No Word";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(search)];
   
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(showWordbook)];
    
    self.editingView = [[WordEditingActionView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 60)];
    self.editingView.delegate = self;
    self.tableView.tableHeaderView = self.editingView;
}

- (void)loadView {
    [super loadView];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
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
    self.title = self.editingView.word == nil ? @"No Word" : self.editingView.word;
        
    [self queryYoudao:self.editingView.editedWord];
}

@end
