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
        return [self attributesAtIndex:0 effectiveRange:NULL];
    } else {
        return NULL;
    }
}

- (NSDictionary *)cc_attributes {
    return [self cc_attributesAtIndex:0];
}


- (UIFont *)cc_fontAtIndex:(NSUInteger)index {
    NSDictionary *attributes = [self cc_attributes];
    if (attributes) {
        return attributes[NSFontAttributeName];
    }
    return NULL;
}

- (UIFont *)cc_font {
    return [self cc_fontAtIndex:0];
}


- (UIColor *)cc_colorAtIndex:(NSUInteger)index {
    NSDictionary *attributes = [self cc_attributes];
    if (attributes) {
        return attributes[NSForegroundColorAttributeName];
    }
    return NULL;
}

- (UIColor *)cc_color {
    return [self cc_colorAtIndex:0];
}

#pragma mark - attachment

+ (NSAttributedString *)attachmentStringWithContent:(id)content position:(CCTextAttachmentPosition)position {
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:CCAttachmentCharacter];
    
    CCTextRunDelegate *runDelegate = [CCTextRunDelegate textRunDelegateWithContent:content position:position];
    [attrString addAttributes:@{CCAttachmentAttributeName:runDelegate} range:NSMakeRange(0, [attrString length])];
    return attrString;
}

@end

@implementation NSMutableAttributedString (CCKit)

#pragma mark - NSFontAttributeName

- (void)cc_setFont:(UIFont *)font range:(NSRange)range {
    [self setAttributes:@{NSFontAttributeName:font} range:range];
}

- (void)cc_setFont:(UIFont *)font {
    [self cc_setFont:font range:NSMakeRange(0, [self length])];
}

#pragma mark - NSForegroundColorAttributeName

- (void)cc_setColor:(UIColor *)color range:(NSRange)range {
    [self setAttributes:@{NSForegroundColorAttributeName:color} range:range];
}

- (void)cc_setColor:(UIColor *)color {
    [self cc_setColor:color range:NSMakeRange(0, [self length])];
}

@end
