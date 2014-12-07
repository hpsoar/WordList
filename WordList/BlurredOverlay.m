//
//  BlurredOverlay.m
//  WordList
//
//  Created by HuangPeng on 12/7/14.
//  Copyright (c) 2014 Beacon. All rights reserved.
//

#import "BlurredOverlay.h"

@implementation BlurredOverlay

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    return NO;
}

@end

@implementation OverlayView

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    return NO;
}

@end
