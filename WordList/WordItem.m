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
    _w = [WordDB word:_word];
}

- (BOOL)favored {
    return _w != nil;
}

- (void)setFavored:(BOOL)favored {
    if (favored) {
        if (_w == nil) {
            _w = [WordDB insertWord];
            _w.word = self.word;
            _w.phonetic = self.phonetic;
            _w.meanings = self.definition;
            [WordDB save];
        }
    }
    else if (_w) {
        [WordDB deleteWord:_w];
        [WordDB save];
        _w = nil;
    }
}

- (Class)cellClass {
    return [WordItemCell class];
}

@end

#define kSelectedColor RGBCOLOR_HEX(0x8e44ad)
#define kNormalColor RGBCOLOR_HEX(0x2980b9)

@implementation WordItemCell {
    UILabel *_wordLabel;
    UILabel *_phoneticLabel;
    UILabel *_definitionLabel;
    UIView *_container;
    WordItem *_item;
}

+ (CGFloat)heightForObject:(id)object atIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    WordItem *item = object;
    CGFloat height = 0;
    height += [Utility heightForText:item.word fontSize:17 width:tableView.width - 30];
    height += [Utility heightForText:item.phonetic fontSize:17 width:tableView.width - 30];
    height += [Utility heightForText:item.definition fontSize:17 width:tableView.width - 30];
    if (item.phonetic) {
        return height + 30 + 10;
    }
    else {
        return height + 25 + 10;
    }
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _container = [[UIView alloc] initWithFrame:CGRectMake(5, 5, self.width - 10, 0)];
        _container.backgroundColor = kNormalColor;
        _container.layer.cornerRadius = 5;
        _container.clipsToBounds = YES;
        [self.contentView addSubview:_container];
        
        _wordLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 0, 0)];
        _wordLabel.textColor = RGBCOLOR_HEX(0xdcdcdc);
        _wordLabel.textAlignment = NSTextAlignmentCenter;
        [_container addSubview:_wordLabel];
        
        _phoneticLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 0, 0)];
        _phoneticLabel.textColor = RGBCOLOR_HEX(0xdcdcdc);
        _phoneticLabel.textAlignment = NSTextAlignmentCenter;
        [_container addSubview:_phoneticLabel];
        
        _definitionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 0, 0)];
        _definitionLabel.textColor = RGBCOLOR_HEX(0xdcdcdc);
        _definitionLabel.textAlignment = NSTextAlignmentCenter;
        _definitionLabel.numberOfLines = 0;
        [_container addSubview:_definitionLabel];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectItem)];
        _container.userInteractionEnabled = YES;
        [_container addGestureRecognizer:tap];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _container.frame = CGRectMake(5, 5, self.width - 10, self.height - 10);
}

- (BOOL)shouldUpdateCellWithObject:(id)object {
    _item = object;
    
    WordItem *item = object;
    _wordLabel.text = item.word;
    _wordLabel.width = _container.width - 20;
    [_wordLabel sizeToFit];
    
    _phoneticLabel.text = item.phonetic;
    _phoneticLabel.width = _container.width - 20;
    [_phoneticLabel sizeToFit];
    
    _definitionLabel.text = item.definition;
    _definitionLabel.width = _container.width - 20;
    [_definitionLabel sizeToFit];
    
    if (item.phonetic) {
        _phoneticLabel.top = _wordLabel.bottom + 5;
        _definitionLabel.top = _phoneticLabel.bottom + 5;
    }
    else {
        _definitionLabel.top = _wordLabel.bottom + 5;
    }
    
    if (item.favored) {
        _container.backgroundColor = kSelectedColor;
    }
    else {
        _container.backgroundColor = kNormalColor;
    }
    _wordLabel.centerX = _container.width / 2;
    _phoneticLabel.centerX = _wordLabel.centerX;
    _definitionLabel.centerX = _wordLabel.centerX;
    
    return YES;
}

- (void)selectItem {
    _item.favored = !_item.favored;
    [self shouldUpdateCellWithObject:_item];
}

@end