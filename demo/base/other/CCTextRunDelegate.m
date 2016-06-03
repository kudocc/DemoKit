//
//  CCTextRunDelegate.m
//  demo
//
//  Created by KudoCC on 16/6/3.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "CCTextRunDelegate.h"

static void CCCTRunDelegateDeallocateCallback(void * refCon) {
    return;
}

static CGFloat CCCTRunDelegateGetAscentCallback(void * refCon) {
    CCTextRunDelegate *delegate = (__bridge CCTextRunDelegate *)refCon;
    return delegate.ascent;
}

static CGFloat CCCTRunDelegateGetDescentCallback(void * refCon) {
    CCTextRunDelegate *delegate = (__bridge CCTextRunDelegate *)refCon;
    return delegate.descent;
}

static CGFloat CCCTRunDelegateGetWidthCallback(void * refCon) {
    CCTextRunDelegate *delegate = (__bridge CCTextRunDelegate *)refCon;
    return delegate.width;
}

@implementation CCTextRunDelegate

+ (CCTextRunDelegate *)textRunDelegateWithContent:(id)content position:(CCTextAttachmentPosition)position {
    CCTextRunDelegate *delegate = [[CCTextRunDelegate alloc] initWithContent:content position:position];
    return delegate;
}

- (CTRunDelegateRef)createCTRunDelegateRef {
    const CTRunDelegateCallbacks callbacks = {kCTRunDelegateCurrentVersion, &CCCTRunDelegateDeallocateCallback, &CCCTRunDelegateGetAscentCallback, &CCCTRunDelegateGetDescentCallback, &CCCTRunDelegateGetWidthCallback};
    CTRunDelegateRef runDelegate = CTRunDelegateCreate(&callbacks, (__bridge_retained void *)self);
    return runDelegate;
}

- (id)initWithContent:(id)content position:(CCTextAttachmentPosition)position {
    self = [super init];
    if (self) {
        _content = content;
        _position = position;
        
        CGSize size = CGSizeZero;
        if ([content isKindOfClass:[UIView class]]) {
            size = ((UIView *)content).frame.size;
        } else if ([content isKindOfClass:[CALayer class]]) {
            size = ((CALayer *)content).frame.size;
        } else if ([content isKindOfClass:[UIImage class]]) {
            size = ((UIImage *)content).size;
        } else {
            NSAssert(NO, @"don't support the attachment type");
            return nil;
        }
        
    }
    return self;
}

@end
