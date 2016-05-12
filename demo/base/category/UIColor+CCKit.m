//
//  UIColor+CCKit.m
//  demo
//
//  Created by KudoCC on 16/5/12.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "UIColor+CCKit.h"

@implementation UIColor (CCKit)

+ (UIColor *)cc_colorWithRed:(int)red green:(int)green blue:(int)blue {
    return [self cc_colorWithRed:red green:green blue:blue alpha:255];
}

+ (UIColor *)cc_colorWithRed:(int)red green:(int)green blue:(int)blue alpha:(int)alpha {
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha/255.0];
}

@end
