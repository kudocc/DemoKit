//
//  UIImage+ImageMask.m
//  ImageMask
//
//  Created by KudoCC on 16/1/7.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "UIImage+ImageMask.h"

@implementation UIImage (ImageMask)

- (NSString *)kcc_description:(CGImageRef)imageRef {
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef);
    NSString *strAlphaInfo = @"";
    switch (alphaInfo) {
        case kCGImageAlphaNone:
            strAlphaInfo = @"None";
            break;
        case kCGImageAlphaPremultipliedLast:
            strAlphaInfo = @"PremultipliedLast";
            break;
        case kCGImageAlphaPremultipliedFirst:
            strAlphaInfo = @"PremultipliedFirst";
            break;
        case kCGImageAlphaLast:
            strAlphaInfo = @"AlphaLast";
            break;
        case kCGImageAlphaFirst:
            strAlphaInfo = @"AlphaFirst";
            break;
        case kCGImageAlphaNoneSkipLast:
            strAlphaInfo = @"NoneSkipLast";
            break;
        case kCGImageAlphaNoneSkipFirst:
            strAlphaInfo = @"NoneSkipFirst";
            break;
        case kCGImageAlphaOnly:
            strAlphaInfo = @"AlphaOnly";
            break;
        default:
            break;
    }
    size_t bitsPerPixel = CGImageGetBitsPerPixel(imageRef);
    size_t bitsPerComponent = CGImageGetBitsPerComponent(imageRef);
    NSString *des = [NSString stringWithFormat:@"alpha:%@, bitsPerPixel:%@, bitsPerComponent:%@", strAlphaInfo, @(bitsPerPixel), @(bitsPerComponent)];
    return des;
}

- (UIImage *)imageMask {
    CGImageRef maskRef = self.CGImage;
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);
    UIImage *image = [UIImage imageWithCGImage:mask scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
    CGImageRelease(mask);
    return image;
}

+ (UIImage*) maskImage:(UIImage *)image withMask:(UIImage *)maskImage {
    
    CGImageRef maskRef = maskImage.CGImage;
    
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);
    
    CGImageRef maskedImageRef = CGImageCreateWithMask([image CGImage], mask);
    UIImage *maskedImage = [UIImage imageWithCGImage:maskedImageRef];
    
    CGImageRelease(mask);
    CGImageRelease(maskedImageRef);
    
    // returns new image with mask applied
    return maskedImage;
}


- (UIImage *)kc_maskImageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, self.scale);
    CGContextRef c = UIGraphicsGetCurrentContext();
    [self drawInRect:rect];
    CGContextSetFillColorWithColor(c, [color CGColor]);
    CGContextSetBlendMode(c, kCGBlendModeSourceAtop);
    CGContextFillRect(c, rect);
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

- (NSString *)kc_description {
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(self.CGImage);
    NSString *strAlphaInfo = @"";
    switch (alphaInfo) {
        case kCGImageAlphaNone:
            strAlphaInfo = @"None";
            break;
        case kCGImageAlphaPremultipliedLast:
            strAlphaInfo = @"PremultipliedLast";
            break;
        case kCGImageAlphaPremultipliedFirst:
            strAlphaInfo = @"PremultipliedFirst";
            break;
        case kCGImageAlphaLast:
            strAlphaInfo = @"AlphaLast";
            break;
        case kCGImageAlphaFirst:
            strAlphaInfo = @"AlphaFirst";
            break;
        case kCGImageAlphaNoneSkipLast:
            strAlphaInfo = @"NoneSkipLast";
            break;
        case kCGImageAlphaNoneSkipFirst:
            strAlphaInfo = @"NoneSkipFirst";
            break;
        case kCGImageAlphaOnly:
            strAlphaInfo = @"AlphaOnly";
            break;
        default:
            break;
    }
    size_t bitsPerPixel = CGImageGetBitsPerPixel(self.CGImage);
    size_t bitsPerComponent = CGImageGetBitsPerComponent(self.CGImage);
    NSString *des = [NSString stringWithFormat:@"alpha:%@, bitsPerPixel:%@, bitsPerComponent:%@, size:%@", strAlphaInfo, @(bitsPerPixel), @(bitsPerComponent), NSStringFromCGSize(self.size)];
    return des;
}

@end
