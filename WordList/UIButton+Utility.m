//
//  UIButton+Utility.m
//  WordList
//
//  Created by HuangPeng on 12/3/14.
//  Copyright (c) 2014 Beacon. All rights reserved.
//

#import "UIButton+Utility.h"

@implementation UIButton (Utility)

+ (UIButton *)buttonWithWidth:(CGFloat)width height:(CGFloat)height title:(NSString *)title hexBackground:(NSInteger)hexColor {
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    [btn setTitle:title forState:UIControlStateNormal];
    btn.backgroundColor = RGBCOLOR_HEX(hexColor);
    btn.layer.borderColor = [UIColor whiteColor].CGColor;
    btn.layer.borderWidth = 0.5;
    btn.layer.cornerRadius = height / 2;
    return btn;
}

@end
