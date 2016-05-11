//
//  UIImage+CCKit.m
//  performance
//
//  Created by KudoCC on 16/5/9.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "UIImage+CCKit.h"

@implementation UIImage (CCKit)

+ (CGRect)cc_frameOfImage:(UIImage *)image inContentSize:(CGSize)size withContentMode:(UIViewContentMode)contentMode {
    CGSize imageSize = image.size;
    
    CGFloat (^centerImageOriX)(void) = ^{
        return size.width/2 - imageSize.width/2;
    };
    CGFloat (^centerImageOriY)(void) = ^{
        return size.height/2 - imageSize.height/2;
    };
    
    CGRect frameImage = CGRectMake(0.0, 0.0, imageSize.width, imageSize.height);
    switch (contentMode) {
        case UIViewContentModeScaleToFill:
            frameImage = CGRectMake(0, 0, size.width, size.height);
            break;
        case UIViewContentModeScaleAspectFit: {
            CGFloat ratioW = size.width/imageSize.width;
            CGFloat ratioH = size.height/imageSize.height;
            CGFloat ratio = MIN(ratioW, ratioH);
            frameImage.size = CGSizeMake(floor(ratio * imageSize.width), floor(ratio * imageSize.height));
            frameImage.origin.x = size.width/2 - frameImage.size.width/2;
            frameImage.origin.y = size.height/2 - frameImage.size.height/2;
        }
            break;
        case UIViewContentModeScaleAspectFill: {
            CGFloat ratioW = size.width/imageSize.width;
            CGFloat ratioH = size.height/imageSize.height;
            CGFloat ratio = MAX(ratioW, ratioH);
            frameImage.size = CGSizeMake(floor(ratio * imageSize.width), floor(ratio * imageSize.height));
            frameImage.origin.x = size.width/2 - frameImage.size.width/2;
            frameImage.origin.y = size.height/2 - frameImage.size.height/2;
        }
            break;
            
        case UIViewContentModeCenter: {
            frameImage.origin.x = centerImageOriX();
            frameImage.origin.y = centerImageOriY();
        }
            break;
            
        case UIViewContentModeTop: {
            frameImage.origin.x = centerImageOriX();
            frameImage.origin.y = 0.0;
        }
            break;
            
        case UIViewContentModeBottom: {
            frameImage.origin.x = centerImageOriX();
            frameImage.origin.y = size.height - imageSize.height;
        }
            break;
            
        case UIViewContentModeLeft: {
            frameImage.origin.x = 0.0;
            frameImage.origin.y = centerImageOriY();
        }
            break;
            
        case UIViewContentModeRight: {
            frameImage.origin.x = size.width - imageSize.width;
            frameImage.origin.y = centerImageOriY();
        }
            break;
            
        case UIViewContentModeTopLeft: {
            frameImage.origin.x = 0.0;
            frameImage.origin.y = 0.0;
        }
            break;
            
        case UIViewContentModeTopRight: {
            frameImage.origin.x = size.width - imageSize.width;
            frameImage.origin.y = centerImageOriY();
        }
            break;
            
        case UIViewContentModeBottomLeft: {
            frameImage.origin.x = 0.0;
            frameImage.origin.y = size.height - imageSize.height;
        }
            break;
            
        case UIViewContentModeBottomRight: {
            frameImage.origin.x = size.width - imageSize.width;
            frameImage.origin.y = size.height - imageSize.height;
        }
            break;
            
        default:
            break;
    }
    return frameImage;
}

+ (UIImage *)cc_resizeImage:(UIImage *)image contentMode:(UIViewContentMode)contentMode size:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGRect frameImage = [self cc_frameOfImage:image inContentSize:size withContentMode:contentMode];
    [image drawInRect:frameImage];
    UIImage *resImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resImage;
}

+ (UIImage *)cc_transparentCenterImageWithSize:(CGSize)size cornerRadius:(CGFloat)radius backgroundColor:(UIColor *)bgColor {
    return [self cc_transparentCenterImageWithSize:size cornerRadius:radius backgroundColor:bgColor borderWidth:0 borderColor:nil];
}

+ (UIImage *)cc_transparentCenterImageWithSize:(CGSize)size cornerRadius:(CGFloat)radius backgroundColor:(UIColor *)bgColor borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor {
    // 如果opaque为YES，背景全黑了
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, bgColor.CGColor);
    CGContextFillRect(context, CGRectMake(0.0, 0.0, size.width, size.height));
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0.0, 0.0, size.width, size.height) cornerRadius:radius];
    [path addClip];
    CGContextClearRect(context, CGRectMake(0, 0, size.width, size.height));
    if (borderWidth > 0 && borderColor) {
        path.lineWidth = borderWidth*2;
        CGContextSetStrokeColorWithColor(context, borderColor.CGColor);
        [path stroke];
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


- (UIImage *)cc_imageWithSize:(CGSize)size cornerRadius:(CGFloat)radius {
    return [self cc_imageWithSize:size cornerRadius:radius contentMode:UIViewContentModeScaleToFill];
}

- (UIImage *)cc_imageWithSize:(CGSize)size cornerRadius:(CGFloat)radius contentMode:(UIViewContentMode)contentMode {
    return [self cc_imageWithSize:size cornerRadius:radius borderWidth:0 borderColor:nil contentMode:contentMode];
}

- (UIImage *)cc_imageWithSize:(CGSize)size cornerRadius:(CGFloat)radius borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor contentMode:(UIViewContentMode)contentMode {
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // add clip area
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0.0, 0.0, size.width, size.height) cornerRadius:radius];
    [path addClip];
    
    // draw image
    CGRect frame = [UIImage cc_frameOfImage:self inContentSize:size withContentMode:contentMode];
    [self drawInRect:frame];
    
    // draw border
    if (borderWidth > 0 && borderColor) {
        path.lineWidth = borderWidth*2;
        CGContextSetStrokeColorWithColor(context, borderColor.CGColor);
        [path stroke];
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
