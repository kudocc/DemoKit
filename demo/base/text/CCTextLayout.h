//
//  CCTextLayout.h
//  demo
//
//  Created by KudoCC on 16/6/1.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import "CCTextLine.h"
#import "CCTextContainer.h"

@interface CCTextLayout : NSObject

+ (id)textLayoutWithSize:(CGSize)size text:(NSString *)text;
+ (id)textLayoutWithSize:(CGSize)size attributedText:(NSAttributedString *)attributedText;
+ (id)textLayoutWithContainer:(CCTextContainer *)textContainer text:(NSString *)text;
+ (id)textLayoutWithContainer:(CCTextContainer *)textContainer attributedText:(NSAttributedString *)attributedText;

@property (nonatomic, readonly) CCTextContainer *textContainer;
@property (nonatomic, readonly) NSAttributedString *attributedString;
@property (nonatomic, readonly) CGSize textBounds;
@property (nonatomic, readonly) NSArray<CCTextLine *> *textLines;
@property (nonatomic, readonly) NSArray<CCTextAttachment *> *attachments;
@property (nonatomic, readonly) NSArray<NSValue *> *attachmentFrames;

+ (CGSize)measureFrame:(CTFrameRef)frame;

- (void)drawInContext:(CGContextRef)context
                 view:(UIView *)view layer:(CALayer *)layer
             position:(CGPoint)position size:(CGSize)size
           isCanceled:(BOOL(^)(void))isCanceled;

/// position is in Core Text coordinate
- (NSInteger)stringIndexAtPosition:(CGPoint)position;

@end
