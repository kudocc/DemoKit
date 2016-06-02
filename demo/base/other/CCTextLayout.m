//
//  CCTextLayout.m
//  demo
//
//  Created by KudoCC on 16/6/1.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "CCTextLayout.h"

@implementation CCTextLayout {
    CTFramesetterRef _ctFramesetter;
    CTFrameRef _ctFrame;
}

+ (id)textLayoutWithSize:(CGSize)size text:(NSString *)text {
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:text];
    return [self textLayoutWithSize:size attributedText:attributedString];
}

+ (id)textLayoutWithSize:(CGSize)size attributedText:(NSAttributedString *)attributedText {
    CCTextLayout *textLayout = [[CCTextLayout alloc] initWithSize:size attributedString:attributedText];
    return textLayout;
}

- (void)dealloc {
    if (_ctFramesetter) {
        CFRelease(_ctFramesetter);
    }
}

- (id)initWithSize:(CGSize)size attributedString:(NSAttributedString *)attributedText {
    self = [super init];
    if (self) {
        _textConstraintSize = size;
        _textConstraintPath = CGPathCreateWithRect(CGRectMake(0, 0, size.width, size.height), NULL);
        _attributedString = attributedText;
        
        [self layout];
    }
    return self;
}

+ (CGSize)measureFrame:(CTFrameRef)frame {
    CGPathRef framePath = CTFrameGetPath(frame);
    CGRect frameRect = CGPathGetBoundingBox(framePath);
    CFArrayRef lines = CTFrameGetLines(frame);
    CFIndex numLines = CFArrayGetCount(lines);
    CGFloat maxWidth = 0;
    CGFloat textHeight = 0;
    CFIndex lastLineIndex = numLines - 1;
    
    for(CFIndex index = 0; index < numLines; index++) {
        CGFloat ascent, descent, leading, width;
        CTLineRef line = (CTLineRef) CFArrayGetValueAtIndex(lines, index);
        width = CTLineGetTypographicBounds(line, &ascent,  &descent, &leading);
        if (width > maxWidth) { maxWidth = width; }
        if (index == lastLineIndex) {
            CGPoint lastLineOrigin;
            CTFrameGetLineOrigins(frame, CFRangeMake(lastLineIndex, 1), &lastLineOrigin);
            textHeight =  CGRectGetMaxY(frameRect) - lastLineOrigin.y + descent;
        }
    }
    return CGSizeMake(ceil(maxWidth), ceil(textHeight));
}

- (void)layout {
    _ctFramesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)_attributedString);
    _ctFrame = CTFramesetterCreateFrame(_ctFramesetter, CFRangeMake(0, 0), _textConstraintPath, NULL);
    
    CFArrayRef lines = CTFrameGetLines(_ctFrame);
    CFIndex count = CFArrayGetCount(lines);
    CGPoint positions[count];
    CTFrameGetLineOrigins(_ctFrame, CFRangeMake(0, 0), positions);
    
    CTLineRef bottomLine = CFArrayGetValueAtIndex(lines, count-1);
    CGPoint bottomPosition = positions[count-1];
    CGFloat bottomLineDescent, bottomLineLeading;
    CTLineGetTypographicBounds(bottomLine, NULL, &bottomLineDescent, &bottomLineLeading);
    CGFloat bottom = bottomPosition.y - bottomLineDescent - bottomLineLeading;
    
    NSMutableArray *mutableArray = [NSMutableArray array];
    for (CFIndex i = count-1; i >= 0; --i) {
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        CGPoint po = positions[i];
        po = CGPointMake(po.x, ceil(po.y-bottom));
        CCTextLine *ccLine = [CCTextLine textLineWithPosition:po line:line];
        [mutableArray addObject:ccLine];
    }
    _textLines = [mutableArray copy];
    
    CGSize size = [CCTextLayout measureFrame:_ctFrame];
    _textBounds = size;
}

- (void)drawInContext:(CGContextRef)context size:(CGSize)size isCancel:(BOOL(^)(void))isCancel {
    if (isCancel && isCancel()) {
        NSLog(@"good before draw cancel");
        return;
    }
    CGContextSaveGState(context);
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    for (CCTextLine *line in _textLines) {
        if (isCancel && isCancel()) {
            NSLog(@"not bad before draw line cancel");
            return;
        }
        CGContextSetTextPosition(context, line.position.x, line.position.y);
        CTLineDraw(line.line, context);
    }
    CGContextRestoreGState(context);
}

@end
