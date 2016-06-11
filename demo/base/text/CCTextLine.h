//
//  CCTextLine.h
//  demo
//
//  Created by KudoCC on 16/6/1.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CoreText/CoreText.h"

@class CCTextAttachment;
@class CCTextRun;
@interface CCTextLine : NSObject

+ (CCTextLine *)textLineWithPosition:(CGPoint)position line:(CTLineRef)line;

/// line's origin in CTFrame
@property (nonatomic) CGPoint position;
/// line's frame in CTFrame
@property (nonatomic) CGRect frame;

@property (nonatomic) CTLineRef line;

@property (nonatomic) NSArray<CCTextAttachment *> *attachments;
/// array of attachment frame in Core Text Coordinate, zero position is the last line's leading position
@property (nonatomic) NSArray<NSValue *> *attachmentFrames;
/// array of CCTextRun
@property (nonatomic) NSArray<CCTextRun *> *textRuns;

@end


@interface CCTextRun : NSObject

/// position.x is x offset from its line's origin.x, position.y is its line's position.y
@property (nonatomic) CGPoint position;
/// text frame in Core Text Coordinate, zero position is the last line's leading position
@property (nonatomic) CGRect frame;

@property (nonatomic, strong) id run;

@end