//
//  CCTextLine.m
//  demo
//
//  Created by KudoCC on 16/6/1.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "CCTextLine.h"
#import "CCTextDefine.h"

@implementation CCTextLine

+ (CCTextLine *)textLineWithPosition:(CGPoint)position line:(CTLineRef)line {
    CCTextLine *textLine = [[CCTextLine alloc] initWithPosition:position line:line];
    return textLine;
}

- (id)initWithPosition:(CGPoint)position line:(CTLineRef)line {
    self = [super init];
    if (self) {
        _position = position;
        _line = line;
        
        CGFloat lineAscent = 0, lineDescent = 0, lineLeading = 0;
        CTLineGetTypographicBounds(_line, &lineAscent, &lineDescent, &lineLeading);
        NSMutableArray *attachments = [NSMutableArray array];
        NSMutableArray *frames = [NSMutableArray array];
        CFArrayRef runs = CTLineGetGlyphRuns(_line);
        CFIndex count = CFArrayGetCount(runs);
        for (CFIndex i = 0; i < count; ++i) {
            CTRunRef run = CFArrayGetValueAtIndex(runs, i);
            CFDictionaryRef cfAttributes = CTRunGetAttributes(run);
            CCTextAttachment *attachment = CFDictionaryGetValue(cfAttributes, (__bridge void *)CCAttachmentAttributeName);
            if (!attachment) {
                continue;
            }
            [attachments addObject:attachment];
            CFRange range = CTRunGetStringRange(run);
            NSAssert(range.length == 1, @"error");
            CGFloat ascent = 0, descent = 0, leading = 0;
            CGFloat width = CTRunGetTypographicBounds(run, CFRangeMake(0, 1), &ascent, &descent, &leading);
            CGPoint runPosition;
            CTRunGetPositions(run, CFRangeMake(0, 1), &runPosition);
            // TODO:1.run的position是以line的descent为0还是leading为0点的？2.run的高度是ascent+descent+or not leading?
            CGRect frame = CGRectMake(runPosition.x+_position.x, _position.y-lineDescent-leading+runPosition.y, width, ascent+descent+leading);
            [frames addObject:[NSValue valueWithCGRect:frame]];
        }
        _attachments = [attachments copy];
        _attachmentFrames = [frames copy];
    }
    return self;
}

@end
