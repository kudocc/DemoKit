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
            textHeight =  CGRectGetMaxY(frameRect) - lastLineOrigin.y + descent;
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
            po = CGPointMake(po.x, ceil(po.y-bottom));
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
                 view:(UIView *)view layer:(CALayer *)layer size:(CGSize)size isCancel:(BOOL(^)(void))isCancel {
    if (isCancel && isCancel()) {
        NSLog(@"good before draw cancel");
        return;
    }
    CGContextSaveGState(context);
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGFloat yOffset = size.height - _textBounds.height;
    for (CCTextLine *line in _textLines) {
        if (isCancel && isCancel()) {
            NSLog(@"not bad before draw line cancel");
            return;
        }
        CGContextSetTextPosition(context, line.position.x, yOffset + line.position.y);
        CTLineDraw(line.line, context);
        
        for (NSInteger i = 0; i < [line.attachments count]; ++i) {
            CCTextAttachment *attachment = line.attachments[i];
            CGRect frame = [line.attachmentFrames[i] CGRectValue];
            frame.origin.y += yOffset;
            frame = UIEdgeInsetsInsetRect(frame, attachment.contentInsets);
            CGRect frameInside = [UIView cc_frameOfContentWithContentSize:attachment.contentSize containerSize:frame.size contentMode:attachment.contentMode];
            frame = CGRectMake(frame.origin.x+frameInside.origin.x, frame.origin.y+frameInside.origin.y, frameInside.size.width, frameInside.size.height);
            if ([attachment.content isKindOfClass:[UIImage class]]) {
                UIImage *image = (UIImage *)attachment.content;
                CGContextDrawImage(context, frame, image.CGImage);
            } else {
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
    CGContextRestoreGState(context);
}

@end
