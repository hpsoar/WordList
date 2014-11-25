//
//  WordItem.m
//  WordList
//
//  Created by HuangPeng on 11/26/14.
//  Copyright (c) 2014 Beacon. All rights reserved.
//

#import "WordItem.h"

@implementation WordItem

- (id)initWithWord:(Word *)word {
    self = [super init];
    if (self) {
        _word = word;
    }
    return self;
}

- (Class)cellClass {
    return [WordItemCell class];
}

@end

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
    height += [Utility heightForText:item.word.word fontSize:17 width:tableView.width - 30];
    height += [Utility heightForText:item.word.phonetic fontSize:17 width:tableView.width - 30];
    height += [Utility heightForText:item.word.meanings fontSize:17 width:tableView.width - 30];
    if (item.word.phonetic) {
        return height + 30 + 10;
    }
    else {
        return height + 25 + 10;
    }
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _container = [[UIView alloc] initWithFrame:CGRectMake(5, 5, 0, 0)];
        _container.backgroundColor = [UIColor blueColor];
        _container.layer.cornerRadius = 5;
        _container.clipsToBounds = YES;
        [self.contentView addSubview:_container];
        
        _wordLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 0, 0)];
        [_container addSubview:_wordLabel];
        
        _phoneticLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 0, 0)];
        [_container addSubview:_phoneticLabel];
        
        _definitionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 0, 0)];
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
    _wordLabel.text = item.word.word;
    [_wordLabel sizeToFit];
    
    _phoneticLabel.text = item.word.phonetic;
    [_phoneticLabel sizeToFit];
    
    _definitionLabel.text = item.word.meanings;
    [_definitionLabel sizeToFit];
    
    if (item.word.phonetic) {
        _phoneticLabel.top = _wordLabel.bottom + 5;
        _definitionLabel.top = _phoneticLabel.bottom + 5;
    }
    else {
        _definitionLabel.top = _wordLabel.bottom + 5;
    }
    
    if (item.inWordbook) {
        _container.backgroundColor = [UIColor greenColor];
    }
    else {
        _container.backgroundColor = [UIColor blueColor];
    }
    
    return YES;
}

- (void)selectItem {
    _item.inWordbook = !_item.inWordbook;
    [self shouldUpdateCellWithObject:_item];
}

@end