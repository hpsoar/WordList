//
//  ViewController.m
//  WordList
//
//  Created by HuangPeng on 11/24/14.
//  Copyright (c) 2014 Beacon. All rights reserved.
//

#import "ViewController.h"
#import "WordItem.h"
#import "WordListViewController.h"
#import "ReviewWordViewController.h"
#import "UIButton+Utility.h"
#import "DefinitionApi.h"

@protocol WordEditingActionViewDelegate <NSObject>

- (void)wordEdittingViewDidEditWord;

- (void)chooseToSearch;

@end

@interface WordEditingActionView : UIView
@property (nonatomic, weak) id<WordEditingActionViewDelegate> delegate;
@property (nonatomic, readonly) NSString *editedWord;
@property (nonatomic, strong) NSString *word;

@end

@interface WordEditingActionView ()
@property (nonatomic, strong)  CollapsableButton *editButton;

@property (nonatomic, strong)  CollapsableButton *pasteBtn;
@property (nonatomic, strong)  CollapsableButton *oneBtn;
@property (nonatomic, strong)  CollapsableButton *twoBtn;
@end

@implementation WordEditingActionView {
    NSString *_editedWord;
    CGFloat _xSpace;
    CGFloat _btnWidth;
    NSArray *_btns;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        if (self.width > 640) {
            _btnWidth = 60;
        }
        else {
            _btnWidth = 56;
        }
        _xSpace = (self.width - 4 * _btnWidth) / 5;
        
        CGFloat bigWidth = (self.width - 3 * _xSpace) / 2;
        self.editButton = [[CollapsableButton alloc] initWithFrame:CGRectMake(_xSpace, 0, bigWidth, _btnWidth)];
        self.editButton.title = @"Edit";
        self.editButton.collapseToLeft = YES;
        self.editButton.backgroundColor = RGBCOLOR_HEX(0xF1C40F);
        [self addSubview:self.editButton];
        
        
        self.pasteBtn = [[CollapsableButton alloc] initWithFrame:CGRectMake(self.width - bigWidth - _xSpace, 0, bigWidth, _btnWidth)];
        self.pasteBtn.title = @"Paste";
        self.pasteBtn.collapseToLeft = YES;
        self.pasteBtn.backgroundColor = RGBCOLOR_HEX(0x2ECD71);
        [self addSubview:self.pasteBtn];
        
        self.oneBtn = [[CollapsableButton alloc] initWithFrame:CGRectMake(self.width, 0, _btnWidth, _btnWidth)];
        self.oneBtn.title = @"1";
        self.oneBtn.backgroundColor = RGBCOLOR_HEX(0x2ECD71);
        [self addSubview:self.oneBtn];
        self.twoBtn = [[CollapsableButton alloc] initWithFrame:CGRectMake(self.width, 0, _btnWidth, _btnWidth)];
        self.twoBtn.title = @"2";
        self.twoBtn.backgroundColor = RGBCOLOR_HEX(0x2ECD71);
        [self addSubview:self.twoBtn];
        
        _btns = @[ self.editButton, self.pasteBtn, self.oneBtn, self.twoBtn ];
        for (CollapsableButton *btn in _btns) {
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedBtn:)];
            btn.userInteractionEnabled = YES;
            [btn addGestureRecognizer:tap];
        }
    }
    return self;
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
        case 4:
            if ([self.editedWord isEqualToString:self.word]) {
                return;
            }
            _editedWord = self.word;
            break;
        case 2: {
            NSString *word = [UIPasteboard generalPasteboard].string;
            if ([_editedWord isEqualToString:word]) {
                return;
            }
            _word = word;
            _editedWord = word;
            if (word != nil) {
               
            }
            else {
               
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

- (void)setWord:(NSString *)word {
    _word = word;
    _editedWord = word;
}

- (void)tappedBtn:(UIGestureRecognizer *)sender {
    NSInteger index = [_btns indexOfObject:sender.view];
    if (index == 0) {
        [self.delegate chooseToSearch];
        return;
    }
    else if (index == 1) {
//        if (self.pasteBtn.width > _btnWidth + 10) {
            [self animate];
 //       }
        //
        NSString *word = [UIPasteboard generalPasteboard].string;
        if ([_editedWord isEqualToString:word]) {
            return;
        }
        _word = word;
        _editedWord = word;
    }
    else if (index == 2) {
        if (self.word.length < 2) return;
        _editedWord = [self.word substringToIndex:self.word.length - 1];
    }
    else if (index == 3) {
        if (self.word.length < 3) return;
        _editedWord = [self.word substringToIndex:self.word.length - 2];
    }
    
    [self.delegate wordEdittingViewDidEditWord];
}

- (CGFloat)stride {
    return _xSpace + _btnWidth;
}

- (void)animate {
    CGFloat duration = 0.3;
    if (self.pasteBtn.width == self.pasteBtn.height) {
        [self popAnimation];
        return;
    }
    
    [self.editButton animateToX:_xSpace duration:duration];
    [self.pasteBtn animateToX:_xSpace + [self stride] duration:duration];
    
    NSArray *keyTimes = @[ @0, @1 ];
    CGFloat xOffset = self.width;
    {
        CGFloat x0 = xOffset + self.oneBtn.width / 2;
        CGFloat x2 = _xSpace + [self stride] * 2 + self.oneBtn.width / 2;
        CAKeyframeAnimation *xAni = [CAKeyframeAnimation animationWithKeyPath:@"position.x"];
        xAni.values = @[ @(x0), @(x2) ];
        xAni.duration = duration;
        xAni.keyTimes = keyTimes;
        self.oneBtn.layer.position = CGPointMake(x2, self.oneBtn.layer.position.y);
        [self.oneBtn.layer addAnimation:xAni forKey:nil];
    }
    {
        CGFloat x0 = xOffset + [self stride] + self.twoBtn.width / 2;
        CGFloat x2 = _xSpace + [self stride] * 3 + self.oneBtn.width / 2;
        CAKeyframeAnimation *xAni = [CAKeyframeAnimation animationWithKeyPath:@"position.x"];
        xAni.values = @[ @(x0), @(x2) ];
        xAni.duration = duration;
        xAni.keyTimes = keyTimes;
        xAni.delegate = self;
        self.twoBtn.layer.position = CGPointMake(x2, self.twoBtn.layer.position.y);
        [self.twoBtn.layer addAnimation:xAni forKey:nil];
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    NIDPRINTMETHODNAME();
    
    [self popAnimation];
}

- (void)popAnimation {
    for (UIView *btn in _btns) {
        [self addPopAnimationToLayer:btn.layer withBounce:0.1 damp:0.055];
    }
}

- (void) addPopAnimationToLayer:(CALayer *)aLayer withBounce:(CGFloat)bounce damp:(CGFloat)damp{
    // TESTED WITH BOUNCE = 0.2, DAMP = 0.055
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.duration = 1;
    
    int steps = 100;
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:steps];
    double value = 0;
    float e = 2.71;
    for (int t=0; t<100; t++) {
        value = pow(e, -damp*t) * sin(bounce*t) + 1;
        [values addObject:[NSNumber numberWithFloat:value]];
    }
    animation.values = values;
    [aLayer addAnimation:animation forKey:@"appear"];
}


@end


@implementation  CollapsableButton {
    UILabel *_titleLabel;
    UILabel *_secondLabel;
    NSInteger _originalX;
    NSInteger _originalWidth;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = self.height / 2;
        self.clipsToBounds = YES;
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.layer.borderWidth = 0.8;
        _titleLabel = [[UILabel alloc] initWithFrame:NIRectContract(self.bounds, 20, 10)];
        _titleLabel.textColor = [UIColor whiteColor];
        [self addSubview:_titleLabel];
        
        _secondLabel = [[UILabel alloc] initWithFrame:NIRectContract(self.bounds, self.width - self.height, 0)];
        _secondLabel.alpha = 1;
        _secondLabel.textColor = [UIColor whiteColor];
        [self addSubview:_secondLabel];
        
        _originalWidth = self.width;
        _originalX = self.left;
        
        UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Light" size:24];
        _titleLabel.font = font;
        _secondLabel.font = font;
    }
    return self;
}

- (NSString *)title {
    return _titleLabel.text;
}

- (void)setTitle:(NSString *)title {
    BOOL shouldReset = self.width == _originalWidth || _titleLabel.text == nil;
    _titleLabel.text = title;
    [_titleLabel sizeToFit];
    
    _secondLabel.text = [title substringToIndex:1];
    [_secondLabel sizeToFit];
    
    if (shouldReset) {
        [self reset];
    }
}

- (void)reset {
    _titleLabel.alpha = 1;
    self.left = _originalX;
    self.width = _originalWidth;
    
    _titleLabel.center = CGPointMake(self.width / 2, self.height / 2);
    _secondLabel.left = _titleLabel.left;
    _secondLabel.centerY = _titleLabel.centerY;
}

- (void)animateToX:(CGFloat)toX duration:(CGFloat)duration {
    [self reset];
    
    /*
     * 1. frame1: x, y, width, height
     * 2. frame2: x, y, left * 2 + _title.width, height
     * 3. frame3: x, y, height, height
     */
    CGFloat left = (self.height - _secondLabel.width) / 2;

    CGFloat w0 = self.width;
    CGFloat w1 = left * 2 + _titleLabel.width;
    CGFloat w2 = self.height;
    
    CGFloat ratio = (w1 - w0) / (w2 - w0);
    NSArray *keyTimes = @[ @0, @(ratio), @1.0 ];
    
    {
        CGFloat fromX = self.left;
        CGFloat middleX = ratio * (fromX - toX) + toX;
        CGFloat x0 = fromX + w0 / 2;
        CGFloat x1 = middleX + w1 / 2;
        CGFloat x2 = toX + w2 / 2;
        self.left = toX;
        self.width = w2;
        CAKeyframeAnimation *wAni = [CAKeyframeAnimation animationWithKeyPath:@"bounds.size.width"];
        wAni.values = @[ @(w0), @(w1), @(w2) ];
        wAni.duration = duration;
        wAni.keyTimes = keyTimes;
        [self.layer addAnimation:wAni forKey:nil];
         
         CAKeyframeAnimation *xAni = [CAKeyframeAnimation animationWithKeyPath:@"position.x"];
         xAni.values = @[ @(x0), @(x1), @(x2) ];
         xAni.duration = duration;
         xAni.keyTimes = keyTimes;
         [self.layer addAnimation:xAni forKey:nil];
     }
    
    {
        CGFloat x0 = w0 / 2 - _titleLabel.width / 2 + _secondLabel.width / 2;
        CGFloat x1 = w1 / 2 - _titleLabel.width / 2 + _secondLabel.width / 2;
        CGFloat x2 = w2 / 2;
        _secondLabel.layer.position = CGPointMake(x2, self.height / 2);
        NSArray *values = @[ @(x0), @(x1), @(x2) ];
        CAKeyframeAnimation* anim = [CAKeyframeAnimation animationWithKeyPath:@"position.x"];
        anim.values = values;
        anim.duration = duration;
        anim.keyTimes = keyTimes;
        [_secondLabel.layer addAnimation:anim forKey:nil];
    }
    _titleLabel.layer.opacity = 0;
    {
        CGFloat x0 = w0 / 2;
        CGFloat x1 = w1 / 2;
        CGFloat x2 = w2 / 2;
        CAKeyframeAnimation *xAni = [CAKeyframeAnimation animationWithKeyPath:@"position.x"];
        xAni.values = @[ @(x0), @(x1), @(x1) ];
        xAni.duration = duration;
        xAni.keyTimes = keyTimes;
        [_titleLabel.layer addAnimation:xAni forKey:nil];
        
        CAKeyframeAnimation *aAni = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
        aAni.values = @[ @1, @0, @0 ];
        aAni.duration = duration;
        aAni.keyTimes = keyTimes;
        [_titleLabel.layer addAnimation:aAni forKey:nil];
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {

}

@end

@interface SearchView () <UITextFieldDelegate>

@end

@implementation SearchView {
    UITextField *_textField;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _textField = [[UITextField alloc] initWithFrame:CGRectMake(20, 0, self.width - 40, self.height)];
        _textField.placeholder = @"Enter a word";
        _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _textField.returnKeyType = UIReturnKeyDone;
        _textField.keyboardType = UIKeyboardTypeAlphabet;
        _textField.textColor = [UIColor whiteColor];
        self.backgroundColor = RGBCOLOR_HEX(0x3598DC);
        _textField.delegate = self;
        
        [self addSubview:_textField];
        
        UIView *line = [UIView lineWithColor:[UIColor whiteColor] width:self.width height:0.5];
        line.top = self.height - 1;
        [self addSubview:line];
        
        [_textField addTarget:self
                       action:@selector(valueChanged:)
             forControlEvents:UIControlEventEditingChanged];
    }
    return self;
}

- (void)setWord:(NSString *)word {
    _textField.text = word;
}

- (NSString *)word {
    return _textField.text;
}

- (BOOL)becomeFirstResponder {
    return [_textField becomeFirstResponder];
}

- (BOOL)resignFirstResponder {
    return [_textField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [_textField resignFirstResponder];
    return YES;
}

- (void)valueChanged:(id)sender {
    [self.delegate searchTextChanged];
}

@end

@interface ViewController () <WordEditingActionViewDelegate, SearchViewDelegate, UIActionSheetDelegate>
@property (nonatomic, strong) WordEditingActionView *editingView;

@property (nonatomic, strong) SearchView *searchView;

@end

@implementation ViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupNotifications {
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(onKeyboardWillHide:)
                                                name:UIKeyboardWillHideNotification
                                              object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(onKeyboardWillShow:)
                                                name:UIKeyboardWillShowNotification
                                              object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(onKeyboardDidHide:)
                                                name:UIKeyboardDidHideNotification
                                              object:nil];
}

- (void)onKeyboardWillShow:(NSNotification *)notification {
    NIDPRINT(@"%@", notification);
    CGRect endRect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.searchView.bottom = self.view.height - endRect.size.height;
}

- (void)onKeyboardWillHide:(NSNotification *)notification {
    NIDPRINT(@"%@", notification);
    self.searchView.top = self.view.height;
    self.editingView.bottom = self.view.height - 10;
}

- (void)onKeyboardDidHide:(NSNotification *)notification {
    [UIView animateWithDuration:0.1 animations:^{
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = RGBCOLOR_HEX(0x3598DC);
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self updateTitle];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    
    [self setupNotifications];
    
    self.editingView = [[WordEditingActionView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 60)];
    self.editingView.delegate = self;
    [self.view addSubview:self.editingView];
    
    self.searchView = [[SearchView alloc] initWithFrame:CGRectMake(0, self.view.height, self.view.width, 44)];
    self.searchView.delegate = self;
    [self.view addSubview:self.searchView];
    
    self.tableView.tableFooterView = [UIView viewWithFrame:CGRectMake(0, 0, self.view.width, 70) andBkColor:[UIColor clearColor]];
    
    self.headerView = [[ActivityView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 80)];
    self.headerView.pullHint = @"Pull to show menu";
    self.headerView.releaseHint = @"Release to show menu";
    self.headerView.loadingHint = @"";
}

- (void)refresh {
    [super refresh];
    
    [self refreshCompleted];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"单词本", @"复习",nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            [self showWordbook];
            break;
        case 1:
            [self reviewWord];
            break;
        default:
            break;
    }
}

- (void)reviewWord {
    ReviewWordViewController *controller = [ReviewWordViewController new];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.editingView.bottom = self.view.height - 10;
}

- (void)loadView {
    [super loadView];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
}

- (void)updateModelWithWordList:(NSArray *)wordList {
    [self resetModel];

    [self.model addObjectsFromArray:wordList];
    
    [self.tableView reloadData];
}

- (void)search {
    ReviewWordViewController *controller = [ReviewWordViewController new];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)showWordbook {
    WordListViewController *controller = [WordListViewController new];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)updateTitle {
    self.title = self.editingView.editedWord.notEmpty ? self.editingView.editedWord : @"No Word";
}

- (void)wordEdittingViewDidEditWord {
    [self queryWord:self.editingView.editedWord];
}

- (void)queryWord:(NSString *)word {
    [self updateTitle];
    
    [[DefinitionApi sharedApi] query:self.editingView.editedWord success:^(NSArray *results) {
        [self updateModelWithWordList:results];
    } failure:^(NSError *error) {
        
    }];
}

- (void)chooseToSearch {
    [UIView animateWithDuration:0.1 animations:^{
        self.editingView.top = self.view.height;
    } completion:^(BOOL finished) {
        [self.searchView becomeFirstResponder];
        self.searchView.word = self.editingView.editedWord;
    }];
}

- (void)searchTextChanged {
    self.editingView.word = self.searchView.word;
    [self queryWord:self.searchView.word];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [super scrollViewWillBeginDragging:scrollView];
    [self.searchView resignFirstResponder];
}

@end
