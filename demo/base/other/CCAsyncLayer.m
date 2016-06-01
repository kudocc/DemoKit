//
//  CCAsyncLayer.m
//  demo
//
//  Created by KudoCC on 16/6/1.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "CCAsyncLayer.h"
#import <UIKit/UIKit.h>

@implementation CCAsyncLayer {
    NSInteger _displayCycle;
}

+ (id)defaultValueForKey:(NSString *)key {
    if ([key isEqualToString:@"asyncDisplay"]) {
        return @(YES);
    } else {
        return [super defaultValueForKey:key];
    }
}

- (instancetype)init {
    self = [super init];
    self.contentsScale = [UIScreen mainScreen].scale;
    _asyncDisplay = YES;
    _displayCycle = 0;
    
    return self;
}

- (void)setNeedsDisplay {
    [self cancelCurrentDisplay];
//    NSLog(@"in setNeedsDisplay %p, %ld", self, (long)_displayCycle);
    [super setNeedsDisplay];
}

- (void)display {
    id<CCAsyncLayerDelegate> asyncDelegate = self.delegate;
    CCAsyncLayerDisplayTask *task = [asyncDelegate newAsyncDisplayTask];
    if (!task) {
        return;
    }
    
    NSInteger cycle = _displayCycle;
    BOOL(^isCancel)() = ^BOOL() {
        return cycle != _displayCycle;
    };
    
    BOOL opaque = self.opaque;
    CGFloat scale = [UIScreen mainScreen].scale;
    if (_asyncDisplay) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (isCancel()) {
                NSLog(@"cancel before create image context");
                return;
            }
            UIGraphicsBeginImageContextWithOptions(self.bounds.size, opaque, scale);
            CGContextRef context = UIGraphicsGetCurrentContext();
            task.display(context, self.bounds.size, isCancel);
            UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            if (isCancel()) {
                NSLog(@"cancel add block to before set content");
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
//                NSLog(@"in global queue %p, %ld, %ld", self, (long)cycle, (long)_displayCycle);
                if (isCancel()) {
                    NSLog(@"cancel before set content");
                    return;
                }
                self.contents = (__bridge id)image.CGImage;
            });
        });
    } else {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, opaque, scale);
        CGContextRef context = UIGraphicsGetCurrentContext();
        task.display(context, self.bounds.size, nil);
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        self.contents = image;
    }
}

- (void)cancelCurrentDisplay {
    ++_displayCycle;
}

@end


@implementation CCAsyncLayerDisplayTask

@end