//
//  CCLabel.m
//  demo
//
//  Created by KudoCC on 16/6/1.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "CCLabel.h"

@implementation CCLabel {
    
}

- (id)init {
    self = [super init];
    if (self) {
        self.layer.contentsScale = [UIScreen mainScreen].scale;
        NSLog(@"%@", self.layer.contentsGravity);
        self.contentMode = UIViewContentModeTop;
        NSLog(@"%@", self.layer.contentsGravity);
        CCAsyncLayer *layer = (CCAsyncLayer *)self.layer;
        layer.asyncDisplay = YES;
    }
    return self;
}

- (void)setTextLayout:(CCTextLayout *)textLayout {
    _textLayout = textLayout;
    
    [self _clearContents];
    [self.layer setNeedsDisplay];
}

- (void)_clearContents {
//    CGImageRef image = (__bridge_retained CGImageRef)(self.layer.contents);
    self.layer.contents = nil;
//    if (image) {
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
//            CFRelease(image);
//        });
//    }
}

- (void)setFrame:(CGRect)frame {
    if (!CGRectEqualToRect(self.frame, frame)) {
        [super setFrame:frame];
        
        [self _clearContents];
        [self.layer setNeedsDisplay];
    }
}

/*

- (void)setAttributedText:(NSAttributedString *)attributedText {
    _attributedText = attributedText;
}

*/

+ (Class)layerClass {
    return [CCAsyncLayer class];
}

#pragma mark - CCAsyncLayerDelegate

- (CCAsyncLayerDisplayTask *)newAsyncDisplayTask {
    if (!_textLayout) {
        return nil;
    }
    
    CCAsyncLayerDisplayTask *task = [CCAsyncLayerDisplayTask new];
    task.display = ^(CGContextRef context, CGSize size, BOOL(^isCancelled)(void)) {
        [_textLayout drawInContext:context size:size isCancel:isCancelled];
    };
    return task;
}

@end
