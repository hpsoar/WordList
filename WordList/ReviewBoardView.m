//
//  ReviewBoardView.m
//  WordList
//
//  Created by HuangPeng on 12/6/14.
//  Copyright (c) 2014 Beacon. All rights reserved.
//

#import "ReviewBoardView.h"
#import "WordItem.h"
#import "WordDefinition+Utility.h"

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
        self.backgroundColor = RGBCOLOR_HEX(0x4CABED);
        self.clipsToBounds = YES;
        
        self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        [self addSubview:self.scrollView];
        
        self.wordLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.width, 44)];
        self.wordLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:32];
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

- (void)setWord:(WordDefinition *)word {
    _wordItem = nil;
    _word = word;
    [self updateWordLabel];
    self.showDefinition = NO;
}

- (void)setWordItem:(WordItem *)wordItem {
    _word = nil;
    _wordItem = wordItem;
    [self updateWordLabel];
    self.showDefinition = YES;
}

- (void)updateWordLabel {
    if (self.word) {
        self.wordLabel.text = self.word.word;
    }
    else if (self.wordItem) {
        self.wordLabel.text = self.wordItem.word;
    }
    else {
        self.wordLabel.text = @"复习完了～～～";
    }
}

- (void)setShowDefinition:(BOOL)showDefinition {
    if (self.wordItem == nil && self.word == nil) {
        showDefinition = NO;
    }
    
    self.definitionLabel.hidden = !showDefinition;
    if (showDefinition) {
        if (self.word) {
            self.definitionLabel.text = self.word.definitions;
        }
        else if (self.wordItem) {
            self.definitionLabel.text = self.wordItem.definition;
        }
        else {
            self.definitionLabel.text = @"";
        }
        
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
