//
//  ViewController.m
//  ImageMask
//
//  Created by KudoCC on 16/1/7.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "Quartz2DViewController.h"
#import "ImageMaskViewController.h"
#import "CoordinateViewController.h"

@interface Quartz2DViewController ()

@end

@implementation Quartz2DViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.arrayTitle = @[@"ImageMask", @"Coordinate Test"];
    self.arrayClass = @[[ImageMaskViewController class], [CoordinateViewController class]];
    
    /*
    UIImage *imageNoAlpha = [UIImage imageNamed:@"image_mask"];
    CGImageRef imageAsMaskRef = imageNoAlpha.CGImage;
    CGBitmapInfo bitmapInfo = 0;
    bitmapInfo |= kCGImageAlphaPremultipliedLast;
    bitmapInfo |= kCGBitmapFloatInfoMask;
    bitmapInfo |= kCGBitmapByteOrderDefault;
    
    CGContextRef bitmapContext = CGBitmapContextCreate(nil,
                                                       CGImageGetWidth(imageAsMaskRef),
                                                       CGImageGetHeight(imageAsMaskRef),
                                                       CGImageGetBitsPerComponent(imageAsMaskRef),
                                                       CGImageGetBytesPerRow(imageAsMaskRef),
                                                       CGImageGetColorSpace(imageAsMaskRef),
                                                       bitmapInfo);
    CGContextRef context = bitmapContext;
    [[UIColor blackColor] setFill];
    CGContextFillRect(context, (CGRect){CGPointZero, imageNoAlpha.size});
    [[UIColor whiteColor] setStroke];
    CGContextSetLineWidth(context, 5.0);
    CGRect rectStroke = (CGRect){CGPointZero, imageNoAlpha.size};
    rectStroke = CGRectInset(rectStroke, 5, 5);
    CGContextStrokeRect(context, rectStroke);
    CGImageRef imageRes = CGBitmapContextCreateImage(bitmapContext);
    CGContextRelease(bitmapContext);
    CGImageRelease(imageRes);
    UIImage *image = [UIImage imageWithCGImage:imageRes];
    */
    
}

@end
