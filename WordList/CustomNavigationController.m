//
//  CustomNavigationController.m
//  WordList
//
//  Created by HuangPeng on 12/5/14.
//  Copyright (c) 2014 Beacon. All rights reserved.
//

#import "CustomNavigationController.h"

@interface CustomNavigationController ()

@end

@implementation CustomNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationBar.backgroundColor = RGBCOLOR_HEX(0x3598DC);
    
    self.navigationBar.shadowImage = [UIImage new];
    self.navigationBar.translucent = NO;
}

@end
