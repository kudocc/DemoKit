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

- (void)drawInContext:(CGContextRef)context size:(CGSize)size isCancel:(BOOL(^)(void))isCancel;

@end
