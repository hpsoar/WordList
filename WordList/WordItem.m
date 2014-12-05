//
//  WordItem.m
//  WordList
//
//  Created by HuangPeng on 11/26/14.
//  Copyright (c) 2014 Beacon. All rights reserved.
//

#import "WordItem.h"

@implementation WordItem {
    Word *_w;
}

- (void)setWord:(NSString *)word {
    _word = word;
    _w = [[WordDB sharedDB] word:word];
}

- (BOOL)favored {
    return _w != nil;
}

- (void)setFavored:(BOOL)favored {
    if (favored) {
        if (_w == nil) {
            _w = [[WordDB sharedDB] insertWord];
            _w.word = self.word;
            _w.phonetic = self.phonetic;
            _w.definitions = self.definition;
            [[WordDB sharedDB] saveContext];
        }
    }
    else if (_w) {
        [[WordDB sharedDB] deleteWord:_w];
        [[WordDB sharedDB] saveContext];
        _w = nil;
    }
}

- (Class)cellClass {
    return [WordItemCell class];
}

@end

#define kSelectedColor RGBCOLOR_HEX(0x4CABED)
#define kNormalColor [UIColor clearColor]

@implementation WordItemCell {
    UILabel *_wordLabel;
    UIView *_seperator;
    UILabel *_phoneticLabel;
    UILabel *_definitionLabel;
    UIView *_container;
    WordItem *_item;
    UIImageView *_checkmark;
}

+ (UIFont *)wordFont {
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
}

+ (UIFont *)definitionFont {
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
}

+ (UIFont *)phoneticFont {
    return [UIFont fontWithName:@"HelveticaNeue-LightItalic" size:14];
}

+ (CGFloat)heightForObject:(id)object atIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    WordItem *item = object;
    CGFloat height = 0;
    height += [Utility heightForText:item.word font:[self wordFont] width:tableView.width - 38];
    height += [Utility heightForText:item.phonetic font:[self phoneticFont] width:tableView.width - 38];
    height += [Utility heightForText:item.definition font:[self definitionFont] width:tableView.width - 38];
    if (item.phonetic) {
        return height + 30 + 20;
    }
    else {
        return height + 25 + 20;
    }
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _container = [[UIView alloc] initWithFrame:[self containerRect]];
        _container.layer.cornerRadius = 8;
        _container.layer.borderColor = [UIColor whiteColor].CGColor;
//        _container.layer.borderWidth = 0.5;
        _container.backgroundColor = kSelectedColor;
        _container.clipsToBounds = YES;
        [self.contentView addSubview:_container];
        
        _seperator = [UIView lineWithColor:RGBCOLOR_HEX(0xd8d8d8) width:self.width - 28 height:0.5];
        _seperator.centerX = self.width / 2;
        [_container addSubview:_seperator];
        
        _wordLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 0, 0)];
        _wordLabel.textColor = [UIColor whiteColor];
        _wordLabel.font = [WordItemCell wordFont];
        _wordLabel.left = 14;
        [_container addSubview:_wordLabel];
        
        _phoneticLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 0, 0)];
        _phoneticLabel.textColor = RGBCOLOR_HEX(0xdcdcdc);
        _phoneticLabel.font = [WordItemCell phoneticFont];
        _phoneticLabel.left = 14;
        [_container addSubview:_phoneticLabel];
        
        _definitionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 0, 0)];
        _definitionLabel.textColor = [UIColor whiteColor];
        _definitionLabel.numberOfLines = 0;
        _definitionLabel.font = [WordItemCell definitionFont];
        _definitionLabel.left = 14;
        [_container addSubview:_definitionLabel];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectItem)];
        _container.userInteractionEnabled = YES;
        [_container addGestureRecognizer:tap];
        
        _checkmark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark.png"]];
        _checkmark.frame = CGRectMake(0, 0, 20, 20);
        _checkmark.contentMode = UIViewContentModeScaleAspectFit;
        _checkmark.right = _container.width - 10;
        [_container addSubview:_checkmark];
        
        self.contentView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _container.frame = [self containerRect];
    
    [self doLayout];
}

- (CGRect)containerRect {
    return CGRectMake(5, 2, self.width - 10, self.height - 10);
}

- (BOOL)shouldUpdateCellWithObject:(id)object {
    _item = object;
    
    WordItem *item = object;
    _wordLabel.text = item.word;
    _wordLabel.width = _container.width - 28;
    [_wordLabel sizeToFit];
    _checkmark.centerY = _wordLabel.centerY;
    
    _seperator.top = _wordLabel.bottom + 5;
    
    _phoneticLabel.text = DefStr(@"[%@]", item.phonetic);
    _phoneticLabel.width = _container.width - 28;
    [_phoneticLabel sizeToFit];
    
    _definitionLabel.text = item.definition;
    _definitionLabel.width = _container.width - 28;
    [_definitionLabel sizeToFit];
    
    _phoneticLabel.hidden = item.phonetic == nil;
    if (item.phonetic) {
        _phoneticLabel.top = _seperator.bottom + 10;
        _definitionLabel.top = _phoneticLabel.bottom + 5;
    }
    else {
        _definitionLabel.top = _seperator.bottom + 10;
    }
    
    _checkmark.hidden = !_item.favored;

    [self doLayout];
    
    return YES;
}

- (void)doLayout {
//    _wordLabel.centerX = _container.width / 2;
//    _phoneticLabel.centerX = _wordLabel.centerX;
//    _definitionLabel.centerX = _wordLabel.centerX;
}

- (void)selectItem {
    _item.favored = !_item.favored;
    [self shouldUpdateCellWithObject:_item];
}

@end