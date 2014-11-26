//
//  WordItem.h
//  WordList
//
//  Created by HuangPeng on 11/26/14.
//  Copyright (c) 2014 Beacon. All rights reserved.
//

#import "NICellFactory.h"

@interface WordItem : NICellObject

@property (nonatomic, strong) NSString *word;
@property (nonatomic, strong) NSString *definition;
@property (nonatomic, strong) NSString *phonetic;

@property (nonatomic) BOOL favored;

@end

@interface WordItemCell : UITableViewCell <NICell>

@end