//
//  WordItem.h
//  WordList
//
//  Created by HuangPeng on 11/26/14.
//  Copyright (c) 2014 Beacon. All rights reserved.
//

#import "NICellFactory.h"

@interface WordItem : NICellObject

- (id)initWithWord:(Word *)word;

@property (nonatomic, readonly) Word *word;
@property (nonatomic) BOOL inWordbook;
@end

@interface WordItemCell : UITableViewCell <NICell>

@end