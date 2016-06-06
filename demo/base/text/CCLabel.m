//
//  CCLabel.m
//  demo
//
//  Created by KudoCC on 16/6/1.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "CCLabel.h"
#import "UIView+CCKit.h"
#import "NSAttributedString+CCKit.h"
#import "CCTextDefine.h"

@implementation CCLabel {
    NSMutableAttributedString *_innerAttributedString;
    CCTextContainer *_textContainer;
    BOOL _needUpdateLayout;
    
    NSArray<CCTextAttachment *> *_attachmentViews;
    NSArray<CCTextAttachment *> *_attachmentLayers;
}

+ (UIFont *)defaultLabelFont {
    return [UIFont systemFontOfSize:17.0];
}

+ (UIColor *)defaultLabelColor {
    return [UIColor blackColor];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        CCAsyncLayer *layer = (CCAsyncLayer *)self.layer;
        layer.asyncDisplay = YES;
        
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    _textContainer = [CCTextContainer textContainerWithContentSize:CGSizeMake(self.width, self.height) contentInsets:UIEdgeInsetsZero];
    
    _font = [CCLabel defaultLabelFont];
    _textColor = [CCLabel defaultLabelColor];
    _innerAttributedString = [[NSMutableAttributedString alloc] initWithString:@""];
    [_innerAttributedString cc_setFont:_font];
    [_innerAttributedString cc_setColor:_textColor];
    
    _verticleAlignment = CCTextVerticalAlignmentCenter;
}

- (void)extractValueFromTextLayout:(CCTextLayout *)textLayout {
    self.attributedText = textLayout.attributedString;
    _textContainer = [textLayout.textContainer copy];
    _contentInsets = _textContainer.contentInsets;
    _numberOfLines = _textContainer.maxNumberOfLines;
    self.size = _textContainer.contentSize;
}

#pragma mark - setter and getter

- (CCAsyncLayer *)asyncLayer {
    return (CCAsyncLayer *)self.layer;
}

- (void)setAsyncDisplay:(BOOL)asyncDisplay {
    [self asyncLayer].asyncDisplay = asyncDisplay;
}

- (void)setFont:(UIFont *)font {
    if ([_font isEqual:font]) return;
    _font = font;
    [_innerAttributedString cc_setFont:_font];
    [self _setNeedsUpdateLayout];
}

- (void)setTextColor:(UIColor *)textColor {
    if ([_textColor isEqual:textColor]) return;
    _textColor = textColor;
    [_innerAttributedString cc_setColor:textColor];
    [self _setNeedsUpdateDisplay];
}

- (NSString *)text {
    return [_innerAttributedString string];
}

- (void)setText:(NSString *)text {
    if ([self.text isEqualToString:text]) return;
    
    _innerAttributedString = [[NSMutableAttributedString alloc] initWithString:text];
    [_innerAttributedString cc_setColor:_textColor];
    [_innerAttributedString cc_setFont:_font];
    
    [self _setNeedsUpdateLayout];
}

- (NSAttributedString *)attributedText {
    return [_innerAttributedString copy];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    _innerAttributedString = [attributedText mutableCopy];
    
    _textColor = [_innerAttributedString cc_color];
    _font = [_innerAttributedString cc_font];
    
    [self _setNeedsUpdateLayout];
}

- (void)setContentInsets:(UIEdgeInsets)contentInsets {
    if (UIEdgeInsetsEqualToEdgeInsets(_contentInsets, contentInsets)) return;
    _textContainer.contentInsets = contentInsets;
    
    [self _setNeedsUpdateLayout];
}

- (void)setNumberOfLines:(NSInteger)numberOfLines {
    if (_numberOfLines == numberOfLines) return;
    _numberOfLines = numberOfLines;
    
    [self _setNeedsUpdateLayout];
}

- (void)setVerticleAlignment:(CCTextVerticalAlignment)verticleAlignment {
    if (_verticleAlignment == verticleAlignment) return;
    _verticleAlignment = verticleAlignment;
    
    [self _setNeedsUpdateLayout];
}

- (void)setTextLayout:(CCTextLayout *)textLayout {
    _textLayout = textLayout;
    [self extractValueFromTextLayout:_textLayout];
    
    [self _setNeedsUpdateLayout];
}

- (void)setFrame:(CGRect)frame {
    CGRect oldFrame = self.frame;
    if (CGRectEqualToRect(oldFrame, frame)) return;
    [super setFrame:frame];
    if (!CGSizeEqualToSize(oldFrame.size, frame.size)) {
        _textContainer.contentSize = frame.size;
        [self _setNeedsUpdateLayout];
    }
}

#pragma mark -

- (void)_clearContents {
//    CGImageRef image = (__bridge_retained CGImageRef)(self.layer.contents);
    self.layer.contents = nil;
//    if (image) {
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
//            CFRelease(image);
//        });
//    }
}

// 不用改变布局，比如text颜色变化，作为优化，现在还是完全重新绘制布局
- (void)_setNeedsUpdateDisplay {
    _needUpdateLayout = YES;
    [self _clearContents];
    [self.layer setNeedsDisplay];
}

- (void)_setNeedsUpdateLayout {
    _needUpdateLayout = YES;
    [self _clearContents];
    [self.layer setNeedsDisplay];
}

+ (Class)layerClass {
    return [CCAsyncLayer class];
}

#pragma mark - CCAsyncLayerDelegate

- (CCAsyncLayerDisplayTask *)newAsyncDisplayTask {
    CCAsyncLayerDisplayTask *task = [CCAsyncLayerDisplayTask new];
    task.willDisplay = ^(CALayer *layer) {
        if (_needUpdateLayout) {
            for (CCTextAttachment *attachment in _attachmentViews) {
                UIView *v = attachment.content;
                [v removeFromSuperview];
            }
            for (CCTextAttachment *attachment in _attachmentLayers) {
                CALayer *layer = attachment.content;
                [layer removeFromSuperlayer];
            }
        }
    };
    
    BOOL needUpdateLayout = _needUpdateLayout;
    CCTextVerticalAlignment verticalAlignment = _verticleAlignment;
    NSAttributedString *attributedString = [_innerAttributedString copy];
    __block CCTextLayout *layout = _textLayout;
    
    task.display = ^(CGContextRef context, CGSize size, BOOL(^isCancelled)(void)) {
        if (needUpdateLayout) {
            layout = [CCTextLayout textLayoutWithContainer:_textContainer attributedText:attributedString];
        }
        
        CGPoint position = CGPointZero;
        if (verticalAlignment == CCTextVerticalAlignmentCenter) {
            position.y = (size.height - layout.textBounds.height)/2;
        } else if (verticalAlignment == CCTextVerticalAlignmentBottom) {
            position.y = size.height - layout.textBounds.height;
        }
        if (position.y < 0) {
            position.y = 0;
        }
        
        [layout drawInContext:context view:nil layer:nil position:position size:size isCanceled:isCancelled];
    };
    
    task.didDisplay = ^(CALayer *layer, BOOL finished) {
        CCMainThreadBlock(^() {
            CGSize size = layer.bounds.size;
            CGPoint position = CGPointZero;
            if (verticalAlignment == CCTextVerticalAlignmentCenter) {
                position.y = (size.height - layout.textBounds.height)/2;
            } else if (verticalAlignment == CCTextVerticalAlignmentBottom) {
                position.y = size.height - layout.textBounds.height;
            }
            if (position.y < 0) {
                position.y = 0;
            }
            [layout drawInContext:nil view:self layer:self.layer position:position size:size isCanceled:nil];
            
            NSMutableArray *attachViews = [NSMutableArray array];
            NSMutableArray *attachLayers = [NSMutableArray array];
            for (CCTextAttachment *attachment in layout.attachments) {
                if ([attachment.content isKindOfClass:[UIView class]]) {
                    [attachViews addObject:attachment];
                } else if ([attachment.content isKindOfClass:[CALayer class]]) {
                    [attachLayers addObject:attachment];
                }
            }
            _attachmentViews = [attachViews copy];
            _attachmentLayers = [attachLayers copy];
            _needUpdateLayout = NO;
            _textLayout = layout;
        });
    };
    return task;
}

@end