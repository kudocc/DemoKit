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
        CGFloat width = CTLineGetTypographicBounds(_line, &lineAscent, &lineDescent, &lineLeading);
        _frame = CGRectMake(_position.x, _position.y-lineDescent-lineLeading, width, lineAscent+lineDescent+lineLeading);
        
        NSMutableArray *attachments = [NSMutableArray array];
        NSMutableArray *textRuns = [NSMutableArray array];
        NSMutableArray *attachmentFrames = [NSMutableArray array];
        CFArrayRef runs = CTLineGetGlyphRuns(_line);
        CFIndex count = CFArrayGetCount(runs);
        NSLog(@"run counts at line:%@", @(count));
        for (CFIndex i = 0; i < count; ++i) {
            CTRunRef run = CFArrayGetValueAtIndex(runs, i);
            CFDictionaryRef cfAttributes = CTRunGetAttributes(run);
            CGPoint runPosition;
            CTRunGetPositions(run, CFRangeMake(0, 1), &runPosition);
            CGFloat ascent = 0, descent = 0, leading = 0;
            CGFloat width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, &leading);
            CGRect frame = CGRectMake(runPosition.x+_position.x, _position.y-(runPosition.y+descent+leading), width, ascent+descent+leading);
            // TODO:1.run的position是以line的descent为0还是leading为0点的？2.run的高度是ascent+descent+or not leading?
            CCTextAttachment *attachment = CFDictionaryGetValue(cfAttributes, (__bridge void *)CCAttachmentAttributeName);
            if (attachment) {
                [attachments addObject:attachment];
                [attachmentFrames addObject:[NSValue valueWithCGRect:frame]];
            } else {
                CCTextRun *textRun = [[CCTextRun alloc] init];
                textRun.position = CGPointMake(runPosition.x+_position.x, _position.y);
                textRun.frame = frame;
                textRun.run = (__bridge_transfer id)run;
                [textRuns addObject:textRun];
            }
        }
        _attachments = [attachments copy];
        _attachmentFrames = [attachmentFrames copy];
        _textRuns = [textRuns copy];
    }
    return self;
}

@end


@implementation CCTextRun

@end