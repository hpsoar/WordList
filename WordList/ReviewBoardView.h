//
//  ReviewBoardView.h
//  WordList
//
//  Created by HuangPeng on 12/6/14.
//  Copyright (c) 2014 Beacon. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WordDefinition;
@class WordItem;

@interface ReviewBoardView : UIView
@property (nonatomic) BOOL showDefinition;
@property (nonatomic, strong) WordDefinition *word;
@property (nonatomic, strong) WordItem *wordItem;
@end
