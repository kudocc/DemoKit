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

@interface CCTextLine : NSObject

+ (CCTextLine *)textLineWithPosition:(CGPoint)position line:(CTLineRef)line;

@property (nonatomic) CGPoint position;

@property (nonatomic) CTLineRef line;

@end
