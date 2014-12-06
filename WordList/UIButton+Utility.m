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
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:24];
    [btn setTitle:title forState:UIControlStateNormal];
    btn.backgroundColor = RGBCOLOR_HEX(hexColor);
    btn.layer.cornerRadius = btn.height / 2;
    btn.layer.borderWidth = 0.8;
    btn.layer.borderColor = [UIColor whiteColor].CGColor;
    btn.clipsToBounds = YES;
    return btn;
}

+ (UIButton *)buttonWithWidth:(CGFloat)width title:(NSString *)title hexBackground:(NSInteger)hexColor {
    CGFloat height = 56;
    if ([UIScreen mainScreen].bounds.size.width > 640) {
        height = 60;
    }
    return [self buttonWithWidth:width height:height title:title hexBackground:hexColor];
}

@end
