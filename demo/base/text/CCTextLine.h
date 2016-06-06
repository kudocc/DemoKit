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
@interface CCTextLine : NSObject

+ (CCTextLine *)textLineWithPosition:(CGPoint)position line:(CTLineRef)line;

@property (nonatomic) CGPoint position;
@property (nonatomic) CTLineRef line;

@property (nonatomic) NSArray<CCTextAttachment *> *attachments;
// array of attach frame in Core Text Coordinate, zero position is the last line's leading position
@property (nonatomic) NSArray<NSValue *> *attachmentFrames;

@end
