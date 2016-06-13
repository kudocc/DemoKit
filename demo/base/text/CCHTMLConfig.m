//
//  CCHTMLConfig.m
//  demo
//
//  Created by KudoCC on 16/6/13.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "CCHTMLConfig.h"

@implementation CCHTMLConfig

+ (CCHTMLConfig *)defaultConfig {
    return [[CCHTMLConfig alloc] init];
}

- (id)init {
    self = [super init];
    if (self) {
        _defaultFontSize = 14.0;
        _defaultTextColor = [UIColor blackColor];
        _fontName = @"Helvetica";
//        _boldFontName = @"Helvetica-Bold";
//        _italicFontName = @"Helvetica-Oblique";
//        _boldItalicFontName = @"Helvetica-BoldOblique";
    }
    return self;
}

@end
