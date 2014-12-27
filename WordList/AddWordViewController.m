//
//  AddWordViewController.m
//  WordList
//
//  Created by HuangPeng on 12/6/14.
//  Copyright (c) 2014 Beacon. All rights reserved.
//

#import "AddWordViewController.h"
#import "ReviewBoardView.h"
#import "DefinitionApi.h"
#import "WordItem.h"

@interface AddWordViewController ()
@property (nonatomic, strong) ReviewBoardView *reviewBoardView;
@property (nonatomic, strong) UIView *buttonArea;
@property (nonatomic, strong) UIButton *addButton;
@property (nonatomic, strong) UIButton *passButton;
@property (nonatomic, strong) NSMutableArray *undeterminedRawWords;
@property (nonatomic, strong) RawWord *currentWord;
@end

@implementation AddWordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = RGBCOLOR_HEX(0x3598DC);
    
    self.title = self.source == kRawWordSourceGRE ? @"GRE" : @"TOEFL";
    
    self.reviewBoardView = [[ReviewBoardView alloc] initWithFrame:CGRectMake(10, 0, self.view.width - 20, 385)];
    [self.view addSubview:self.reviewBoardView];
    
    self.buttonArea = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44)];
    [self.view addSubview:self.buttonArea];
    
    self.buttonArea.top = self.reviewBoardView.bottom + 20;
    
    self.passButton = [UIButton buttonWithWidth:140 title:@"Skip" hexBackground:0xf1c40f];
    [self.passButton addTarget:self action:@selector(pass) forControlEvents:UIControlEventTouchUpInside];
    
    self.passButton.left = 10;
    [self.buttonArea addSubview:self.passButton];
    
    self.addButton = [UIButton buttonWithWidth:140 title:@"Add" hexBackground:0x2ecc71];
    [self.addButton addTarget:self action:@selector(addWord) forControlEvents:UIControlEventTouchUpInside];
    self.addButton.right = self.view.width - 10;
    [self.buttonArea addSubview:self.addButton];
    
    [self showNext];
}

- (void)updateData {
    self.undeterminedRawWords = [[[WordDB sharedDB] wordsWithState:kRawWordStateUndetermined source:self.source limit:30] mutableCopy];
    
    if (self.undeterminedRawWords.count > 0) {
        [self showNext];
    }
    else {
        self.currentWord = nil;
        self.reviewBoardView.wordItem = nil;
    }
}

- (void)pass {
    [self mark:kRawWordStateSkipped];
    [self showNext];
}

- (void)addWord {
    [self mark:kRawWordStateFavored];
    [self showNext];
}

- (void)mark:(RawWordState)state {
    if (state == kRawWordStateFavored) {
        self.reviewBoardView.wordItem.favored = YES;
        if (!self.reviewBoardView.wordItem.favored) {
            return;
        }
    }
    
    self.currentWord.state = kRawWordStateFavored;
    [[WordDB sharedDB] saveContext];
    [self.undeterminedRawWords removeObject:self.currentWord];
}

- (void)showNext {
    if (self.undeterminedRawWords.count > 0) {
        self.currentWord = self.undeterminedRawWords.lastObject;
        [[DefinitionApi sharedApi] query:self.currentWord.word success:^(NSArray *results) {
            self.reviewBoardView.wordItem = results.firstObject;
        } failure:^(NSError *error) {
            
        }];
    }
    else {
        [self updateData];
    }
}

@end
