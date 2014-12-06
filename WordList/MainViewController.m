//
//  MainViewController.m
//  WordList
//
//  Created by HuangPeng on 12/5/14.
//  Copyright (c) 2014 Beacon. All rights reserved.
//

#import "MainViewController.h"
#import "ReviewWordViewController.h"
#import "WordListViewController.h"
#import "ViewController.h"
#import "CustomNavigationController.h"

@interface MainViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate>
@property (nonatomic, strong) UIPageViewController *pageViewController;
@property (nonatomic, strong) NSArray *controllers;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = RGBCOLOR_HEX(0x3598DC);
    self.controllers = @[
                         [[CustomNavigationController alloc] initWithRootViewController:[WordListViewController new]],
                         [[CustomNavigationController alloc] initWithRootViewController:[ViewController new]],
                         [[CustomNavigationController alloc] initWithRootViewController:[ReviewWordViewController new]],
                         ];
    
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
   
    self.pageViewController.delegate = self;
    self.pageViewController.dataSource = self;
   
    [self.pageViewController setViewControllers:@[ self.controllers[1] ] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [self import:kRawWordSourceGRE file:@"gre.txt"];
    [self import:kRawWordSourceTOEFL file:@"toefl.txt"];
}

- (void)import:(RawWordSource)source file:(NSString *)file {
    NSString *importedKey = DefStr(@"word_imported_key%d", source);
    BOOL imported = [[Utility userDefaultObjectForKey:importedKey] boolValue];
    
    if (!imported) {
        // check iCloud;
        NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
        imported = [[store objectForKey:importedKey] boolValue];
        if (imported) {
            [self syncImportState:importedKey];
        }
    }
    if (!imported) {
        NSArray *words = [[WordDB sharedDB] wordsWithState:kRawWordStateAll source:source limit:1];
        imported = words.count > 0;
        if (imported) {
            [self syncImportState:importedKey];
        }
    }
    
    if (!imported) {
        NSString *path = NIPathForBundleResource(nil, file);
        NSString* fileContents = [NSString stringWithContentsOfFile:path
                                                           encoding:NSUTF8StringEncoding error:nil];
        
        // first, separate by new line
        NSArray* words = [fileContents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        [[WordDB sharedDB] import:words source:source];
        NIDPRINT(@"%@", words);
        NSArray *importedWords = [[WordDB sharedDB] wordsWithState:kRawWordStateUndetermined source:source limit:0];
        NIDPRINT(@"%d", importedWords.count);
        NIDASSERT(words.count == importedWords.count);
        for (int i = 0; i < importedWords.count && i < 10; ++i) {
            RawWord *word = importedWords[i];
            NIDPRINT(@"%@", word.word);
        }
        [self syncImportState:importedKey];
    }
}

- (void)syncImportState:(NSString *)key {
    [Utility setUserDefaultObjects:@{ key: @YES }];
    
    // Save To iCloud
    NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
    [store setObject:@YES forKey:key];
    [store synchronize];
}


- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSInteger index = [self.controllers indexOfObject:viewController];
    if (index + 1 < self.controllers.count) {
        return self.controllers[index + 1];
    }
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSInteger index = [self.controllers indexOfObject:viewController];
    if (index > 0) {
        return self.controllers[index - 1];
    }
    return nil;
}

@end
