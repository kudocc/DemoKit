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
#import "ChatViewController.h"
#import "CCLabelDemoViewController.h"
#import "HTMLParserViewController.h"
#import "HTMLWebViewController.h"
#import <CoreText/CoreText.h>
#import "NSAttributedString+CCKit.h"

@interface TestLayer : CALayer

@property (nonatomic) UIImage *image;

@end

@implementation TestLayer

- (void)display {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    self.contents = (__bridge id)_image.CGImage;
}

@end

@interface TestLayerView : UIView
@end

@implementation TestLayerView

+ (Class)layerClass {
    return [TestLayer class];
}

@end

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
        
        NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc] initWithString:@"just test a b c d e f g h i j k l m n o p q r s t u v w x y z" attributes:@{NSForegroundColorAttributeName:[UIColor blackColor], NSFontAttributeName:[UIFont systemFontOfSize:14]}];
        [attriString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, 10)];
        [attriString cc_setColor:[UIColor blueColor] range:NSMakeRange(0, 3)];
        _attributedString = [attriString copy];
        
        _framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)_attributedString);
        CGRect bounds = CGRectMake(0, 0, frame.size.width, frame.size.height);
        CGPathRef path = CGPathCreateWithRect(bounds, NULL);
        _frame = CTFramesetterCreateFrame(_framesetter, CFRangeMake(0, [_attributedString length]), path, NULL);
        CGPathRelease(path);
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
    
    CGContextSetTextPosition(context, 10, 10);
    CFArrayRef lines = CTFrameGetLines(_frame);
    
    // CTRun保存着自己应绘制的位置，当时都是相对于包含其的Line中的，所以只需要调整Y轴坐标就好了
    {
        for (CFIndex lineIndex = 0; lineIndex < CFArrayGetCount(lines); ++lineIndex) {
            CTLineRef line = CFArrayGetValueAtIndex(lines, lineIndex);
            CFArrayRef runs = CTLineGetGlyphRuns(line);
            if (CFArrayGetCount(runs) > 1) {
                for (CFIndex i = 0; i < CFArrayGetCount(runs); ++i) {
                    CGContextSetTextPosition(context, 0, self.height-10.0);
                    CTRunRef run = CFArrayGetValueAtIndex(runs, i);
                    CTRunDraw(run, context, CFRangeMake(0, 0));
                }
            }
        }
        
    }
}
@end

@implementation CoreTextViewController {
    TestLayerView *lv;
}

- (void)initView {
    [super initView];
    
//    NSArray *familyNames = [UIFont familyNames];
//    for (NSString *familyName in familyNames) {
//        NSArray *fontNames = [UIFont fontNamesForFamilyName:familyName];
//        for (NSString *fontName in fontNames) {
//            NSLog(@"family name:%@, font name:%@", familyName, fontName);
//        }
//    }
    
    
    NSLog(@"%@, %@", NSUnderlineStyleAttributeName, (id)kCTUnderlineStyleAttributeName);
    NSLog(@"%@, %@", NSUnderlineColorAttributeName, (id)kCTUnderlineColorAttributeName);
    NSLog(@"%@, %@", NSFontAttributeName, (id)kCTFontAttributeName);
    NSLog(@"%@, %@", NSForegroundColorAttributeName, (id)kCTForegroundColorAttributeName);
    NSLog(@"%@, %@", NSParagraphStyleAttributeName, (id)kCTParagraphStyleAttributeName);
    
    self.arrayTitle = @[@"Simple Chat",
                        @"Core Text Chat",
                        @"Asynchonized Text",
                        @"CCLabel demo",
                        @"HTML parser",
                        @"WebView represents the same HTML content of HTML parser"];
    
    self.arrayClass = @[[SimpleChatViewController class],
                        [CoreTextChatViewController class],
                        [ChatViewController class],
                        [CCLabelDemoViewController class],
                        [HTMLParserViewController class],
                        [HTMLWebViewController class]];
    
//    CoreView *v = [[CoreView alloc] initWithFrame:CGRectMake(0, 84, 100, 100)];
//    v.backgroundColor = [UIColor greenColor];
//    [self.view addSubview:v];
}

//- (void)repeate:(id)timer {
//    static int i = 0;
//    ++i;
//    if (i > 6) {
//        i = 0;
//    }
//    NSString *str = [NSString stringWithFormat:@"image%d.jpg", i];
//    UIImage *image = [UIImage imageNamed:str];
//    ((TestLayer *)lv.layer).image = image;
//    lv.frame = CGRectInset(lv.frame, 1, 1);
//}

@end
