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

/// get the NSParagrahStyle
- (NSParagraphStyle *)cc_paragraphStyle;
- (NSParagraphStyle *)cc_paragraphStyleAtIndex:(NSUInteger)index;


+ (NSAttributedString *)cc_attachmentStringWithContent:(id)content
                                           contentMode:(UIViewContentMode)contentMode
                                           contentSize:(CGSize)contentSize alignToFont:(UIFont *)font
                                    attachmentPosition:(CCTextAttachmentPosition)position;

+ (NSAttributedString *)cc_attachmentStringWithContent:(id)content
                                           contentMode:(UIViewContentMode)contentMode
                                                 width:(CGFloat)width ascent:(CGFloat)ascent descent:(CGFloat)descent;

@end

@interface NSMutableAttributedString (CCKit)

/// call `cc_addAttributes:overrideOldAttribute:` with overrideOld=YES.
- (void)cc_addAttributes:(NSDictionary<NSString *, id> *)attributes;
/// call `cc_addAttributes:range:overrideOldAttribute:` with range=NSMakeRange(0, self.length)
- (void)cc_addAttributes:(NSDictionary<NSString *, id> *)attributes overrideOldAttribute:(BOOL)overrideOld;
/// for each attribute and value in attributes, call `addAttribute:value:range`, if overideOld is NO and there is a value at range.location, do nothing on that attribute.
- (void)cc_addAttributes:(NSDictionary<NSString *, id> *)attributes range:(NSRange)range overrideOldAttribute:(BOOL)overrideOld;

- (void)cc_setAttributes:(NSDictionary<NSString *, id> *)attributes;
/// call `setAttributes:range:`
- (void)cc_setAttributes:(NSDictionary<NSString *, id> *)attributes range:(NSRange)range;

- (void)cc_setFont:(UIFont *)font;
- (void)cc_setFont:(UIFont *)font range:(NSRange)range;

- (void)cc_setColor:(UIColor *)color;
- (void)cc_setColor:(UIColor *)color range:(NSRange)range;

- (void)cc_setBgColor:(UIColor *)bgColor;
- (void)cc_setBgColor:(UIColor *)bgColor range:(NSRange)range;

- (void)cc_setHighlightedColor:(UIColor *)color bgColor:(UIColor *)bgColor tapAction:(CCTapActionBlock)tapAction;
- (void)cc_setHighlightedColor:(UIColor *)color bgColor:(UIColor *)bgColor range:(NSRange)range tapAction:(CCTapActionBlock)tapAction;

/// paragraphStyle
- (void)cc_setAlignment:(NSTextAlignment)alignment;
- (void)cc_setAlignment:(NSTextAlignment)alignment range:(NSRange)range;

/// attachment
- (void)cc_setAttachmentWithContent:(id)content
                        contentMode:(UIViewContentMode)contentMode
                        contentSize:(CGSize)contentSize alignToFont:(UIFont *)font
                 attachmentPosition:(CCTextAttachmentPosition)position range:(NSRange)range;
- (void)cc_setAttachmentStringWithContent:(id)content
                              contentMode:(UIViewContentMode)contentMode
                                    width:(CGFloat)width ascent:(CGFloat)ascent descent:(CGFloat)descent range:(NSRange)range;

@end
