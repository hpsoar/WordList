//
//  ReviewWordViewController.m
//  WordList
//
//  Created by HuangPeng on 11/30/14.
//  Copyright (c) 2014 Beacon. All rights reserved.
//

#import "ReviewWordViewController.h"
#import "ReviewBoardView.h"

@interface ReviewWordViewController ()

@property (nonatomic, strong) UIButton *markRememberedBtn;
@property (nonatomic, strong) UIButton *markNotRememberedBtn;
@property (nonatomic, strong) UIButton *nextButton;
@property (nonatomic, strong) ReviewBoardView *reviewBoardView;

@property (nonatomic, strong) UIView *buttonArea;

@property (nonatomic, strong) NSMutableArray *wordsToReview;
@property (nonatomic) NSInteger currentIndex;
@property (nonatomic) BOOL firstRound;

@end

@implementation ReviewWordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.title =  @"REVIEW";
    
    self.view.backgroundColor = RGBCOLOR_HEX(0x3598DC);
    
    self.reviewBoardView = [[ReviewBoardView alloc] initWithFrame:CGRectMake(10, 0, self.view.width - 20, 385)];
    self.reviewBoardView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [self.view addSubview:self.reviewBoardView];
    
    self.buttonArea = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44)];
    self.buttonArea.autoresizingMask = self.reviewBoardView.autoresizingMask;
    [self.view addSubview:self.buttonArea];
    
    self.buttonArea.top = self.reviewBoardView.bottom + 20;
    
    self.markNotRememberedBtn = [UIButton buttonWithWidth:140 title:@"不记得" hexBackground:0xf1c40f];
    [self.markNotRememberedBtn addTarget:self action:@selector(markNotRemember) forControlEvents:UIControlEventTouchUpInside];
    
    self.markNotRememberedBtn.left = 10;
    [self.buttonArea addSubview:self.markNotRememberedBtn];
    
    self.markRememberedBtn = [UIButton buttonWithWidth:140 title:@"记得" hexBackground:0x2ecc71];
    [self.markRememberedBtn addTarget:self
                               action:@selector(markRemember)
                     forControlEvents:UIControlEventTouchUpInside];
    self.markRememberedBtn.right = self.view.width - 10;
    [self.buttonArea addSubview:self.markRememberedBtn];
    
    self.nextButton = [UIButton buttonWithWidth:140 title:@"不记得" hexBackground:0xf1c40f];
    [self.nextButton addTarget:self action:@selector(next:) forControlEvents:UIControlEventTouchUpInside];
    self.nextButton.left = 10;
    [self.buttonArea addSubview:self.nextButton];
    
    self.wordsToReview = [[[WordDB sharedDB] wordsToReview] mutableCopy];
}

- (void)setWordsToReview:(NSMutableArray *)wordsToReview {
    _wordsToReview = wordsToReview;
    self.firstRound = YES;
    
    if (_wordsToReview.count > 0) {
        self.currentIndex = 0;
    }
    else {
        self.reviewBoardView.word = nil;
        [self updateButtonsShowNextButton:YES withTag:0];
    }
}

- (void)setCurrentIndex:(NSInteger)currentIndex {
    NIDASSERT(self.wordsToReview.count > 0);
    if (self.wordsToReview.count <= 0) return;
    
    if (currentIndex < self.wordsToReview.count) {
        _currentIndex = currentIndex;
    }
    else {
        self.firstRound = NO;
        _currentIndex = 0;
    }
    self.reviewBoardView.word = self.wordsToReview[_currentIndex];
    [self updateButtonsShowNextButton:NO withTag:0];
}

- (void)markRemember {
    [[WordDB sharedDB] scheduleNextReviewTimeForWord:self.reviewBoardView.word remembered:self.firstRound];
    [self.wordsToReview removeObject:self.reviewBoardView.word];
    if (self.wordsToReview.count > 0) {
        self.currentIndex = self.currentIndex;
    }
    else {
        self.reviewBoardView.word = nil;
        [self updateButtonsShowNextButton:YES withTag:0];
    }
}

- (void)markNotRemember {
    self.reviewBoardView.showDefinition = YES;
    [self updateButtonsShowNextButton:YES withTag:1];
}

- (void)next:(id)sender {
    if (self.nextButton.tag == 1) {
        self.currentIndex++;
    }
    else {
        NSArray *wordsToReview = [[WordDB sharedDB] wordsToReview];
        if (wordsToReview.count > 0) {
            self.wordsToReview = [wordsToReview mutableCopy];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"remind" message:@"no more word" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }
}

- (void)updateButtonsShowNextButton:(BOOL)showNextButton withTag:(NSInteger)tag {
    CGFloat duration = .3;
    if (showNextButton) {
        self.nextButton.hidden = NO;
        self.markNotRememberedBtn.hidden = YES;
        self.nextButton.tag = tag;
        [UIView animateWithDuration:duration animations:^{
            [self.nextButton setTitle:tag == 1 ? @"下一个": @"再来一组" forState:UIControlStateNormal];
            self.nextButton.width = self.view.width - 20;
            self.nextButton.backgroundColor = RGBCOLOR_HEX(0x3498db);
            self.markRememberedBtn.width = 50;
            self.markRememberedBtn.right = self.view.width - 10;
        } completion:^(BOOL finished) {
        }];
    }
    else {
       [UIView animateWithDuration:duration animations:^{
           [self.nextButton setTitle:@"不记得" forState:UIControlStateNormal];
           self.nextButton.backgroundColor = RGBCOLOR_HEX(0xf1c40f);
           self.nextButton.width = 140;
           self.markRememberedBtn.width = 140;
           self.markRememberedBtn.right = self.view.width - 10;
       } completion:^(BOOL finished) {
           self.nextButton.hidden = YES;
           self.markNotRememberedBtn.hidden = NO;
       }];
    }
}

- (void)updateButtonFrame {
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

@end
