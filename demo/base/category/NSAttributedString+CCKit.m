//
//  NSAttributedString+CCKit.m
//  demo
//
//  Created by KudoCC on 16/6/1.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "NSAttributedString+CCKit.h"
#import "CCTextRunDelegate.h"

@implementation NSAttributedString (CCKit)

- (NSDictionary *)cc_attributesAtIndex:(NSUInteger)index {
    if ([self length] > 0) {
        return [self attributesAtIndex:index effectiveRange:NULL];
    } else {
        return NULL;
    }
}

- (NSDictionary *)cc_attributes {
    return [self cc_attributesAtIndex:0];
}


- (UIFont *)cc_fontAtIndex:(NSUInteger)index {
    NSDictionary *attributes = [self cc_attributesAtIndex:index];
    if (attributes) {
        return attributes[NSFontAttributeName];
    }
    return NULL;
}

- (UIFont *)cc_font {
    return [self cc_fontAtIndex:0];
}


- (UIColor *)cc_colorAtIndex:(NSUInteger)index {
    NSDictionary *attributes = [self cc_attributesAtIndex:index];
    if (attributes) {
        return attributes[NSForegroundColorAttributeName];
    }
    return NULL;
}

- (UIColor *)cc_color {
    return [self cc_colorAtIndex:0];
}


- (UIColor *)cc_bgColorAtIndex:(NSUInteger)index {
    NSDictionary *attributes = [self cc_attributesAtIndex:index];
    if (attributes) {
        return attributes[NSBackgroundColorAttributeName];
    }
    return NULL;
}

- (UIColor *)cc_bgColor {
    return [self cc_bgColorAtIndex:0];
}

#pragma mark - attachment

+ (NSAttributedString *)cc_attachmentStringWithContent:(id)content contentMode:(UIViewContentMode)contentMode contentSize:(CGSize)contentSize alignToFont:(UIFont *)font attachmentPosition:(CCTextAttachmentPosition)position {
    CGFloat ascent, descent, width;
    width = contentSize.width;
    CGSize size = contentSize;
    switch (position) {
        case CCTextAttachmentPositionTop:
            ascent = font.ascender;
            descent = size.height - ascent;
            break;
        case CCTextAttachmentPositionBottom:
            descent = -font.descender;
            ascent = size.height-descent;
            break;
        default:
            ascent = font.ascender + floor((size.height - font.ascender + font.descender)/2);
            ascent = ascent > 0 ? ascent : 0;
            descent = size.height - ascent;
            break;
    }
    return [self cc_attachmentStringWithContent:content contentMode:contentMode width:width ascent:ascent descent:descent];
}

+ (NSAttributedString *)cc_attachmentStringWithContent:(id)content contentMode:(UIViewContentMode)contentMode width:(CGFloat)width ascent:(CGFloat)ascent descent:(CGFloat)descent {
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:CCAttachmentCharacter];
    
    CCTextAttachment *attachment = [CCTextAttachment textAttachmentWithContent:content];
    attachment.content = content;
    attachment.contentMode = contentMode;
    
    CCTextRunDelegate *runDelegate = [[CCTextRunDelegate alloc] init];
    runDelegate.width = width;
    runDelegate.ascent = ascent;
    runDelegate.descent = descent;
    CTRunDelegateRef ctRunDelegate = [runDelegate createCTRunDelegateRef];
    [attrString addAttributes:@{CCAttachmentAttributeName:attachment, (__bridge id)kCTRunDelegateAttributeName: (__bridge id)ctRunDelegate} range:NSMakeRange(0, [attrString length])];
    CFRelease(ctRunDelegate);
    return attrString;
}

@end

@implementation NSMutableAttributedString (CCKit)

- (void)cc_addAttributes:(NSDictionary<NSString *, id> *)attributes {
    [self cc_addAttributes:attributes overrideOldAttribute:YES];
}

- (void)cc_addAttributes:(NSDictionary<NSString *, id> *)attributes overrideOldAttribute:(BOOL)overrideOld {
    [self cc_addAttributes:attributes range:NSMakeRange(0, self.length) overrideOldAttribute:overrideOld];
}

- (void)cc_addAttributes:(NSDictionary<NSString *, id> *)attributes range:(NSRange)range overrideOldAttribute:(BOOL)overrideOld {
    [attributes enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
        if (overrideOld) {
            [self addAttribute:key value:obj range:range];
        } else {
            NSDictionary *attributes = [self cc_attributesAtIndex:range.location];
            if (!attributes[key]) {
                [self addAttribute:key value:obj range:range];
            }
        }
    }];
}


- (void)cc_setAttributes:(NSDictionary<NSString *, id> *)attributes {
    [self cc_setAttributes:attributes range:NSMakeRange(0, self.length)];
}

- (void)cc_setAttributes:(NSDictionary<NSString *, id> *)attributes range:(NSRange)range {
    [self setAttributes:attributes range:range];
}

#pragma mark - NSFontAttributeName

- (void)cc_setFont:(UIFont *)font range:(NSRange)range {
    [self addAttribute:NSFontAttributeName value:font range:range];
}

- (void)cc_setFont:(UIFont *)font {
    [self cc_setFont:font range:NSMakeRange(0, self.length)];
}

#pragma mark - NSForegroundColorAttributeName

- (void)cc_setColor:(UIColor *)color range:(NSRange)range {
    [self addAttribute:NSForegroundColorAttributeName value:color range:range];
}

- (void)cc_setColor:(UIColor *)color {
    [self cc_setColor:color range:NSMakeRange(0, self.length)];
}

#pragma mark - CCBackgroundColorAttributeName

- (void)cc_setBgColor:(UIColor *)bgColor range:(NSRange)range {
    [self addAttribute:CCBackgroundColorAttributeName value:bgColor range:range];
}

- (void)cc_setBgColor:(UIColor *)bgColor {
    [self cc_setBgColor:bgColor range:NSMakeRange(0, self.length)];
}

#pragma mark - CCHighlightedAttributeName

- (void)cc_setHighlightedColor:(UIColor *)color bgColor:(UIColor *)bgColor tapAction:(CCTapActionBlock)tapAction {
    CCTextHighlighted *hi = [[CCTextHighlighted alloc] init];
    hi.highlightedColor = color;
    hi.bgColor = bgColor;
    hi.tapAction = tapAction;
    [self addAttribute:CCHighlightedAttributeName value:hi range:NSMakeRange(0, self.length)];
}

- (void)cc_setHighlightedColor:(UIColor *)color bgColor:(UIColor *)bgColor range:(NSRange)range tapAction:(CCTapActionBlock)tapAction {
    CCTextHighlighted *hi = [[CCTextHighlighted alloc] init];
    hi.highlightedColor = color;
    hi.bgColor = bgColor;
    hi.tapAction = tapAction;
    [self addAttribute:CCHighlightedAttributeName value:hi range:range];
}

@end
