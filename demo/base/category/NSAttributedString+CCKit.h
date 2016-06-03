//
//  NSAttributedString+CCKit.h
//  demo
//
//  Created by KudoCC on 16/6/1.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CCTextDefine.h"

@interface NSAttributedString (CCKit)

/// get the attributes of the first character
- (NSDictionary *)cc_attributes;
- (NSDictionary *)cc_attributesAtIndex:(NSUInteger)index;

/// get the font of the first character
- (UIFont *)cc_font;
- (UIFont *)cc_fontAtIndex:(NSUInteger)index;

/// get the color of the first character
- (UIColor *)cc_color;
- (UIColor *)cc_colorAtIndex:(NSUInteger)index;

+ (NSAttributedString *)attachmentStringWithContent:(id)content position:(CCTextAttachmentPosition)position;

@end

@interface NSMutableAttributedString (CCKit)

- (void)cc_setFont:(UIFont *)font;
- (void)cc_setFont:(UIFont *)font range:(NSRange)range;

- (void)cc_setColor:(UIColor *)color;
- (void)cc_setColor:(UIColor *)color range:(NSRange)range;

@end
