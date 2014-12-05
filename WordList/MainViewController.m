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
