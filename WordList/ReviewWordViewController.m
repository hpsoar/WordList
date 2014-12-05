//
//  ReviewWordViewController.m
//  WordList
//
//  Created by HuangPeng on 11/30/14.
//  Copyright (c) 2014 Beacon. All rights reserved.
//

#import "ReviewWordViewController.h"

@interface ReviewBoardView : UIView
@property (nonatomic) BOOL showDefinition;
@property (nonatomic, strong) Word *word;
@end

@interface ReviewBoardView ()

@property (nonatomic, strong) UILabel *wordLabel;
@property (nonatomic, strong) UILabel *definitionLabel;
@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation ReviewBoardView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 6;
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.layer.borderWidth = 0.5;
        self.backgroundColor = RGBCOLOR_HEX(0x4CABED);
        self.clipsToBounds = YES;

        self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        [self addSubview:self.scrollView];
        
        self.wordLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.width, 44)];
        self.wordLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:32];
        self.wordLabel.textColor = [UIColor whiteColor];
        self.wordLabel.textAlignment = NSTextAlignmentCenter;
        [self.scrollView addSubview:self.wordLabel];
        
        self.definitionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.wordLabel.bottom + 5, self.width, 0)];
        self.definitionLabel.textAlignment = NSTextAlignmentCenter;
        self.definitionLabel.font = [UIFont fontWithName:@"STHeitiSC-Light" size:22];
        self.definitionLabel.textColor = [UIColor whiteColor];
        self.definitionLabel.numberOfLines = 0;
        [self.scrollView addSubview:self.definitionLabel];
        
        self.showDefinition = NO;
    }
    return self;
}

- (void)setWord:(Word *)word {
    self.showDefinition = NO;
    if (word) {
        _word = word;
        self.wordLabel.text = word.word;
    }
    else {
        _word = nil;
        self.wordLabel.text = @"复习完了～～～";
    }
}

- (void)setShowDefinition:(BOOL)showDefinition {
    self.definitionLabel.hidden = !showDefinition;
    if (showDefinition) {
        self.definitionLabel.text = _word.definitions;
        self.definitionLabel.width = self.scrollView.width - 10;
        [self.definitionLabel sizeToFit];
        self.definitionLabel.centerX = self.scrollView.width / 2;
        
        CGFloat height = self.wordLabel.height + self.definitionLabel.height + 10;
        CGFloat top = MAX(10, (self.scrollView.height - height) / 2);
        self.wordLabel.top = top;
        self.definitionLabel.top = self.wordLabel.bottom + 5;
    }
    else {
        self.wordLabel.center = CGPointMake(self.width / 2, self.height / 2);
        self.scrollView.contentSize = self.scrollView.bounds.size;
    }
}

@end

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
    self.reviewBoardView.autoresizingMask = self.reviewBoardView.autoresizingMask;
    [self.view addSubview:self.buttonArea];
    
    self.buttonArea.top = self.reviewBoardView.bottom + 20;
    
    self.markNotRememberedBtn = [self buttonWithColor:RGBCOLOR_HEX(0xf1c40f) title:@"不记得" width:140];
    [self.markNotRememberedBtn addTarget:self action:@selector(markNotRemember) forControlEvents:UIControlEventTouchUpInside];
    
    self.markNotRememberedBtn.left = 10;
    [self.buttonArea addSubview:self.markNotRememberedBtn];
    
    self.markRememberedBtn = [self buttonWithColor:RGBCOLOR_HEX(0x2ecc71) title:@"记得" width:140];
    [self.markRememberedBtn addTarget:self
                               action:@selector(markRemember)
                     forControlEvents:UIControlEventTouchUpInside];
    self.markRememberedBtn.right = self.view.width - 10;
    [self.buttonArea addSubview:self.markRememberedBtn];
    
    self.nextButton = [self buttonWithColor:RGBCOLOR_HEX(0x3498db)
                                      title:@"下一个"
                                      width:self.view.width - 20];
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
    self.nextButton.hidden = !showNextButton;
    self.markNotRememberedBtn.hidden = showNextButton;
    self.markRememberedBtn.hidden = showNextButton;
    if (showNextButton) {
        self.nextButton.tag = tag;
        [self.nextButton setTitle:tag == 1 ? @"下一个": @"再来一组" forState:UIControlStateNormal];
    }
}

- (void)updateButtonFrame {
}

- (UIButton *)buttonWithColor:(UIColor *)color title:(NSString *)title width:(CGFloat)width {
    CGFloat height = 56;
    if (self.view.width > 640) {
        height = 60;
    }
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:24];
    [btn setTitle:title forState:UIControlStateNormal];
    btn.backgroundColor = color;
    btn.layer.cornerRadius = btn.height / 2;
    btn.layer.borderWidth = 0.8;
    btn.layer.borderColor = [UIColor whiteColor].CGColor;
    return btn;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

@end
