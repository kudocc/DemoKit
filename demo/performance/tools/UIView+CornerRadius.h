//
//  UIView+CornerRadius.h
//  performance
//
//  Created by KudoCC on 16/3/9.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (CornerRadius)

- (void)cornerRadius_addCornerRadius:(CGFloat)radius backgroundColor:(UIColor *)bgColor;
- (void)cornerRadius_addCornerRadius:(CGFloat)radius backgroundColor:(UIColor *)bgColor borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor;

@end
