//
//  ViewController.h
//  WordList
//
//  Created by HuangPeng on 11/24/14.
//  Copyright (c) 2014 Beacon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OCTableViewController.h"

@interface ViewController : OCTableViewController


@end

@interface CollapsableButton : UIView

@property (nonatomic, assign) NSString *title;

@property (nonatomic) BOOL collapseToLeft;

- (void)animateToX:(CGFloat)toX duration:(CGFloat)duration;

- (void)reset;


@end

@protocol SearchViewDelegate <NSObject>

- (void)searchTextChanged;

@end

@interface SearchView : UIView
@property (nonatomic, strong) NSString *word;
@property (nonatomic, weak) id<SearchViewDelegate> delegate;
@end

