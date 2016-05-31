//
//  CoreTextViewController.m
//  demo
//
//  Created by KudoCC on 16/5/31.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "CoreTextViewController.h"
#import "SimpleChatViewController.h"
#import "CoreTextChatViewController.h"
/*
#import <CoreText/CoreText.h>
@interface CoreView : UIView
@end

@implementation CoreView {
    CTFramesetterRef _framesetter;
    CTFrameRef _frame;
    CFArrayRef _lines;
    NSAttributedString *_attributedString;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _attributedString = [[NSAttributedString alloc] initWithString:@"just test a b c d e f g h i j k l m n o p q r s t u v w x y z" attributes:@{NSForegroundColorAttributeName:[UIColor blackColor], NSFontAttributeName:[UIFont systemFontOfSize:14]}];
        _framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)_attributedString);
        CGRect bounds = CGRectMake(0, 0, frame.size.width, frame.size.height);
        CGPathRef path = CGPathCreateWithRect(bounds, NULL);
        _frame = CTFramesetterCreateFrame(_framesetter, CFRangeMake(0, [_attributedString length]), path, NULL);
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGAffineTransform transform = CGContextGetCTM(context);
    NSLog(@"%@", NSStringFromCGAffineTransform(transform));
    
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    transform = CGContextGetCTM(context);
    NSLog(@"%@", NSStringFromCGAffineTransform(transform));
    
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, 10, 10);
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    CGContextStrokePath(context);
    
    CGContextSetTextPosition(context, 0, 0);
    CFArrayRef lines = CTFrameGetLines(_frame);
    CTLineRef line = CFArrayGetValueAtIndex(lines, 0);
//    CTFrameDraw(_frame, context);
    CTLineDraw(line, context);
}
@end
*/
@implementation CoreTextViewController

- (void)initView {
    [super initView];
    
    self.arrayTitle = @[@"Simple Chat",
                        @"Core Text Chat"];
    
    self.arrayClass = @[[SimpleChatViewController class],
                        [CoreTextChatViewController class]];
    
//    CoreView *v = [[CoreView alloc] initWithFrame:CGRectMake(0, 84, 100, 100)];
//    v.backgroundColor = [UIColor greenColor];
//    [self.view addSubview:v];
}

@end
