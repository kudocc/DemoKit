//
//  CaptureScalarBlock.m
//  demo
//
//  Created by KudoCC on 16/5/20.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^captureScalar)(void);

captureScalar _block;

void blockMethod() {
    int a = 10;
    NSObject *o = [NSObject new];
    captureScalar block = ^() {
        int b = a;
        ++b;
        NSObject *oo = o;
    };
    
    [block copy];
}

