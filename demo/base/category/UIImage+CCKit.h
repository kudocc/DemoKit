//
//  UIImage+CCKit.h
//  performance
//
//  Created by KudoCC on 16/5/9.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (CCKit)

+ (CGRect)cc_frameOfImage:(UIImage *)image inContentSize:(CGSize)size withContentMode:(UIViewContentMode)contentMode;

+ (UIImage *)cc_resizeImage:(UIImage *)image contentMode:(UIViewContentMode)contentMode size:(CGSize)size;

+ (UIImage *)cc_transparentCenterImageWithSize:(CGSize)size cornerRadius:(CGFloat)radius backgroundColor:(UIColor *)bgColor;
+ (UIImage *)cc_transparentCenterImageWithSize:(CGSize)size cornerRadius:(CGFloat)radius backgroundColor:(UIColor *)bgColor borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor;

- (UIImage *)cc_imageWithSize:(CGSize)size cornerRadius:(CGFloat)radius;
- (UIImage *)cc_imageWithSize:(CGSize)size cornerRadius:(CGFloat)radius contentMode:(UIViewContentMode)contentMode;
- (UIImage *)cc_imageWithSize:(CGSize)size cornerRadius:(CGFloat)radius borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor contentMode:(UIViewContentMode)contentMode;

+ (int)cc_iOSOrientationToExifOrientation:(UIImageOrientation)iOSOrientation;
+ (UIImageOrientation)cc_exifOrientationToiOSOrientation:(int)exifOrientation;

@end
