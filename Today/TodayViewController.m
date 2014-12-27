//
//  TodayViewController.m
//  Today
//
//  Created by HuangPeng on 12/27/14.
//  Copyright (c) 2014 Beacon. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>

@interface TodayViewController () <NCWidgetProviding>

@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
     self.preferredContentSize = CGSizeMake(320, 80);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    completionHandler(NCUpdateResultNewData);
}

- (IBAction)queryPastebord:(id)sender {
    self.preferredContentSize = CGSizeMake(320, 180);
}

- (IBAction)review:(id)sender {
    [self openAppWithParam:@"review"];
}

- (IBAction)lookupWord:(id)sender {
    [self openAppWithParam:@"lookup"];
}

- (void)openAppWithParam:(NSString *)param {
    NSString *urlStr = [NSString stringWithFormat:@"easyword://%@", param];
    NSURL *url = [NSURL URLWithString:urlStr];
    [self.extensionContext openURL:url completionHandler:^(BOOL success) {
        NSLog(@"fun=%s after completion. success=%d", __func__, success);
    }];
}

- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets {
    defaultMarginInsets.bottom = 0;
    return defaultMarginInsets;
}

@end
