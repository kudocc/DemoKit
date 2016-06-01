//
//  CCTextLine.m
//  demo
//
//  Created by KudoCC on 16/6/1.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "CCTextLine.h"

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
    }
    return self;
}

@end
