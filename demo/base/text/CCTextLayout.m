//
//  CCTextLayout.m
//  demo
//
//  Created by KudoCC on 16/6/1.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "CCTextLayout.h"
#import "CCTextDefine.h"
#import "UIView+CCKit.h"
#import "CCKitMacro.h"

@implementation CCTextLayout {
    CTFramesetterRef _ctFramesetter;
    CTFrameRef _ctFrame;
}

+ (id)textLayoutWithSize:(CGSize)size text:(NSString *)text {
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:text];
    return [self textLayoutWithSize:size attributedText:attributedString];
}

+ (id)textLayoutWithSize:(CGSize)size attributedText:(NSAttributedString *)attributedText {
    CCTextContainer *container = [CCTextContainer textContainerWithContentSize:size contentInsets:UIEdgeInsetsZero];
    return [self textLayoutWithContainer:container attributedText:attributedText];
}

+ (id)textLayoutWithContainer:(CCTextContainer *)textContainer text:(NSString *)text {
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:text];
    return [self textLayoutWithContainer:textContainer attributedText:attributedString];
}

+ (id)textLayoutWithContainer:(CCTextContainer *)textContainer attributedText:(NSAttributedString *)attributedText {
    CCTextLayout *textLayout = [[CCTextLayout alloc] initWithContainer:textContainer attributedString:attributedText];
    return textLayout;
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
            textHeight =  CGRectGetMaxY(frameRect) - lastLineOrigin.y + descent + leading;
        }
    }
    return CGSizeMake(ceil(maxWidth), ceil(textHeight));
}

- (void)dealloc {
    if (_ctFramesetter) {
        CFRelease(_ctFramesetter);
    }
}

- (id)initWithContainer:(CCTextContainer *)container attributedString:(NSAttributedString *)attributedText {
    self = [super init];
    if (self) {
        _textContainer = container;
        _attributedString = attributedText;
        
        [self layout];
    }
    return self;
}

- (void)layout {
    CGRect boundsContent = CGRectMake(0, 0, _textContainer.contentSize.width, _textContainer.contentSize.height);
    CGRect textFrame = UIEdgeInsetsInsetRect(boundsContent, _textContainer.contentInsets);
    CGPathRef textConstraintPath = CGPathCreateWithRect(textFrame, NULL);
    
    _ctFramesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)_attributedString);
    _ctFrame = CTFramesetterCreateFrame(_ctFramesetter, CFRangeMake(0, 0), textConstraintPath, NULL);
    
    CFArrayRef lines = CTFrameGetLines(_ctFrame);
    CFIndex count = CFArrayGetCount(lines);
    if (count > 0) {
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
            po = CGPointMake(po.x, po.y-bottom);
            CCTextLine *ccLine = [CCTextLine textLineWithPosition:po line:line];
            [mutableArray addObject:ccLine];
        }
        _textLines = [mutableArray copy];
    } else {
        _textLines = nil;
    }
    
    NSMutableArray *attachments = [NSMutableArray array];
    NSMutableArray *attachmentFrames = [NSMutableArray array];
    for (CCTextLine *textLine in _textLines) {
        [attachments addObjectsFromArray:textLine.attachments];
        [attachmentFrames addObjectsFromArray:textLine.attachmentFrames];
    }
    _attachments = [attachments copy];
    _attachmentFrames = [attachmentFrames copy];
    
    CGSize size = [CCTextLayout measureFrame:_ctFrame];
    _textBounds = size;
}

- (void)drawInContext:(CGContextRef)context
                 view:(UIView *)view layer:(CALayer *)layer
             position:(CGPoint)position size:(CGSize)size
           isCanceled:(BOOL(^)(void))isCanceled {
    
    // textContainer.contentInsets
    position.x += _textContainer.contentInsets.left;
    position.y += _textContainer.contentInsets.top;
    
    if (context) {
        [self drawTextInContext:context position:position size:size isCanceled:isCanceled];
    }
    
    if (view && layer) {
        [self drawViewOrLayerContentAttachmentOnView:view layer:layer position:position size:size];
    }
}

- (void)setLineDashContext:(CGContextRef)context withUnderlineStyle:(NSUnderlineStyle)underlineStyle {
    switch (underlineStyle & 0xff00) {
        case NSUnderlinePatternDot: {
            CGFloat pattern[] = {3, 3};
            CGContextSetLineDash(context, 0, pattern, sizeof(pattern)/sizeof(CGFloat));
        }
            break;
        case NSUnderlinePatternDash: {
            CGFloat pattern[] = {10, 5};
            CGContextSetLineDash(context, 0, pattern, sizeof(pattern)/sizeof(CGFloat));
        }
            break;
        case NSUnderlinePatternDashDot: {
            CGFloat pattern[] = {10, 3, 3, 3};
            CGContextSetLineDash(context, 0, pattern, sizeof(pattern)/sizeof(CGFloat));
        }
            break;
        case NSUnderlinePatternDashDotDot: {
            CGFloat pattern[] = {10, 3, 3, 3, 3, 3};
            CGContextSetLineDash(context, 0, pattern, sizeof(pattern)/sizeof(CGFloat));
        }
            break;
        default:
            break;
    }
}

- (void)drawTextInContext:(CGContextRef)context position:(CGPoint)position size:(CGSize)size isCanceled:(BOOL(^)(void))isCanceled {
    if (isCanceled && isCanceled()) {
        return;
    }
//    position = size.height - (size.height - position);
    CGContextSaveGState(context);
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    for (CCTextLine *line in _textLines) {
        if (isCanceled && isCanceled()) {
            return;
        }
        
        // draw attachments
        for (NSInteger i = 0; i < [line.attachments count]; ++i) {
            CCTextAttachment *attachment = line.attachments[i];
            CGRect frame = [line.attachmentFrames[i] CGRectValue];
            CGRect frameContainer = CGRectOffset(frame, position.x, position.y);
            frameContainer = UIEdgeInsetsInsetRect(frameContainer, attachment.contentInsets);
            CGRect frameInside = [UIView cc_frameOfContentWithContentSize:attachment.contentSize containerSize:frameContainer.size contentMode:attachment.contentMode];
            frame = CGRectMake(frameContainer.origin.x+frameInside.origin.x, frameContainer.origin.y+frameInside.origin.y, frameInside.size.width, frameInside.size.height);
            if ([attachment.content isKindOfClass:[UIImage class]]) {
                CGContextSaveGState(context);
                CGContextClipToRect(context, frameContainer);
                UIImage *image = (UIImage *)attachment.content;
                CGContextDrawImage(context, frame, image.CGImage);
                CGContextRestoreGState(context);
            }
        }
        
        CGPoint linePosition = line.position;
        linePosition = CGPointMake(linePosition.x + position.x, line.position.y + position.y);
        CGContextSetTextPosition(context, linePosition.x, linePosition.y);
        // draw text run
        for (CCTextRun *textRun in line.textRuns) {
            CGRect frame = textRun.frame;
            frame = CGRectOffset(frame, position.x, position.y);
            CTRunRef run = (__bridge CTRunRef)textRun.run;
            NSDictionary *attr = (__bridge id)CTRunGetAttributes(run);
            {// draw background color
                UIColor *bgColor = attr[CCBackgroundColorAttributeName];
                if (bgColor) {
                    CGContextSetFillColorWithColor(context, bgColor.CGColor);
                    CGContextFillRect(context, frame);
                }
            }
            {// draw ctrun
                CTRunDraw(run, context, CFRangeMake(0, 0));
            }
            
            {// draw strikethrough line
                [self drawStrikethroughInContext:context run:textRun inFrame:frame];
            }
        }
    }
    CGContextRestoreGState(context);
}

- (void)addStrikethroughLineInContext:(CGContextRef)context fromPosition:(CGPoint)from toPosition:(CGPoint)to {
    CGContextMoveToPoint(context, from.x, from.y);
    CGContextAddLineToPoint(context, to.x, to.y);
}

- (void)drawStrikethroughInContext:(CGContextRef)context run:(CCTextRun *)textRun inFrame:(CGRect)frame {
    CTRunRef run = (__bridge CTRunRef)textRun.run;
    NSDictionary *attr = (__bridge id)CTRunGetAttributes(run);
    NSNumber *numberStyle = attr[NSStrikethroughStyleAttributeName];
    NSUnderlineStyle style = [numberStyle integerValue];
    if (!numberStyle || (style & 0xff) == NSUnderlineStyleNone) {
        return;
    }
    
    CGContextSaveGState(context);
    // set strikethrough color
    UIColor *strikethroughColor = attr[NSStrikethroughColorAttributeName];
    if (strikethroughColor) {
        CGContextSetStrokeColorWithColor(context, strikethroughColor.CGColor);
    }
    [self setLineDashContext:context withUnderlineStyle:style];
    CGFloat x = frame.origin.x;
    CGFloat centerY = frame.origin.y + frame.size.height/2;
    switch (style & 0xff) {
        case NSUnderlineStyleSingle:
            CGContextSetLineWidth(context, 1);
            break;
        case NSUnderlineStyleDouble: {
            NSInteger pixel = (NSInteger)((2 * [UIScreen mainScreen].scale)/3);
            if (pixel == 0) pixel = 1;
            CGFloat h = PixelToPoint(pixel);
            CGContextSetLineWidth(context, h);
        }
            break;
        case NSUnderlineStyleThick:
            CGContextSetLineWidth(context, 2);
            break;
        default:
            break;
    }
    
    // TODO:NSUnderlineByWord
    // BOOL underLineByWord = (style & 0xff0000) == NSUnderlineByWord;
    CGPoint p0, p1;
    switch (style & 0xff) {
        case NSUnderlineStyleSingle:
            p0 = CGPointMake(x, centerY);
            p1 = CGPointMake(p0.x + frame.size.width, p0.y);
            [self addStrikethroughLineInContext:context fromPosition:p0 toPosition:p1];
            break;
        case NSUnderlineStyleDouble: {
            NSInteger pixel = (NSInteger)((2 * [UIScreen mainScreen].scale)/3);
            if (pixel == 0) pixel = 1;
            CGFloat h = PixelToPoint(pixel);
            p0 = CGPointMake(x, centerY-h);
            p1 = CGPointMake(p0.x + frame.size.width, p0.y);
            [self addStrikethroughLineInContext:context fromPosition:p0 toPosition:p1];
            p0 = CGPointMake(x, centerY+h);
            p1 = CGPointMake(p0.x + frame.size.width, p0.y);
            [self addStrikethroughLineInContext:context fromPosition:p0 toPosition:p1];
        }
            break;
        case NSUnderlineStyleThick: {
            p0 = CGPointMake(x, centerY);
            p1 = CGPointMake(p0.x + frame.size.width, p0.y);
            [self addStrikethroughLineInContext:context fromPosition:p0 toPosition:p1];
        }
            break;
        default:
            break;
    }
    
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
}

- (void)drawViewOrLayerContentAttachmentOnView:(UIView *)view layer:(CALayer *)layer position:(CGPoint)position size:(CGSize)size {
//    position = size.height - (size.height - position);
    for (CCTextLine *line in _textLines) {
        for (NSInteger i = 0; i < [line.attachments count]; ++i) {
            CCTextAttachment *attachment = line.attachments[i];
            CGRect frame = [line.attachmentFrames[i] CGRectValue];
            frame = CGRectOffset(frame, position.x, position.y);
            frame = UIEdgeInsetsInsetRect(frame, attachment.contentInsets);
            CGRect frameInside = [UIView cc_frameOfContentWithContentSize:attachment.contentSize containerSize:frame.size contentMode:attachment.contentMode];
            frame = CGRectMake(frame.origin.x+frameInside.origin.x, frame.origin.y+frameInside.origin.y, frameInside.size.width, frameInside.size.height);
            if ([attachment.content isKindOfClass:[UIView class]] ||
                [attachment.content isKindOfClass:[CALayer class]]) {
                CGAffineTransform transform = CGAffineTransformMakeTranslation(0, size.height);
                transform = CGAffineTransformScale(transform, 1, -1);
                frame = CGRectApplyAffineTransform(frame, transform);
                if ([attachment.content isKindOfClass:[UIView class]]) {
                    UIView *viewAttachment = (UIView *)attachment.content;
                    [view addSubview:viewAttachment];
                    viewAttachment.frame = frame;
                } else if ([attachment.content isKindOfClass:[CALayer class]]) {
                    CALayer *layerAttachment = attachment.content;
                    [layer addSublayer:layerAttachment];
                    layer.frame = frame;
                }
            }
        }
    }
}

- (NSInteger)stringIndexAtPosition:(CGPoint)position {
    for (CCTextLine *line in _textLines) {
        if (CGRectContainsPoint(line.frame, position)) {
            CGPoint positionInLine = CGPointMake(position.x-line.position.x, position.y-line.position.y);
            CFIndex position = CTLineGetStringIndexForPosition(line.line, positionInLine);
            if (position == kCFNotFound) {
                return NSNotFound;
            }
            return (NSInteger)position;
        }
    }
    return NSNotFound;
}

@end
