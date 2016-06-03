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

@implementation CCLabel {
    NSMutableAttributedString *_innerAttributedString;
    CCTextContainer *_textContainer;
    BOOL _needUpdateLayout;
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
    task.display = ^(CGContextRef context, CGSize size, BOOL(^isCancelled)(void)) {
        if (_needUpdateLayout) {
            // TODO:it may occur in background thread
            _textLayout = [CCTextLayout textLayoutWithContainer:_textContainer attributedText:[_innerAttributedString copy]];
        }
        
        [_textLayout drawInContext:context size:size isCancel:isCancelled];
    };
    return task;
}

@end
