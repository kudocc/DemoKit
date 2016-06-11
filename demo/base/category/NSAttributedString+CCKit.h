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

/// get the background color of the first character
- (UIColor *)cc_bgColor;
- (UIColor *)cc_bgColorAtIndex:(NSUInteger)index;


+ (NSAttributedString *)attachmentStringWithContent:(id)content
                                        contentMode:(UIViewContentMode)contentMode
                                        contentSize:(CGSize)contentSize
                                        alignToFont:(UIFont *)font
                                 attachmentPosition:(CCTextAttachmentPosition)position;

+ (NSAttributedString *)attachmentStringWithContent:(id)content
                                        contentMode:(UIViewContentMode)contentMode
                                              width:(CGFloat)width
                                             ascent:(CGFloat)ascent
                                            descent:(CGFloat)descent;

@end

@interface NSMutableAttributedString (CCKit)

- (void)cc_setAttributes:(NSDictionary<NSString *, id> *)attributes;
- (void)cc_setAttributes:(NSDictionary<NSString *, id> *)attributes range:(NSRange)range;

- (void)cc_setFont:(UIFont *)font;
- (void)cc_setFont:(UIFont *)font range:(NSRange)range;

- (void)cc_setColor:(UIColor *)color;
- (void)cc_setColor:(UIColor *)color range:(NSRange)range;

- (void)cc_setBgColor:(UIColor *)bgColor;
- (void)cc_setBgColor:(UIColor *)bgColor range:(NSRange)range;


- (void)cc_setHighlightedColor:(UIColor *)color bgColor:(UIColor *)bgColor tapAction:(CCTapActionBlock)tapAction;
- (void)cc_setHighlightedColor:(UIColor *)color bgColor:(UIColor *)bgColor range:(NSRange)range tapAction:(CCTapActionBlock)tapAction;

@end
