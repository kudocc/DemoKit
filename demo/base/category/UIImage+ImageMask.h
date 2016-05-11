//
//  UIImage+ImageMask.h
//  ImageMask
//
//  Created by KudoCC on 16/1/7.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ImageMask)

- (UIImage *)imageMask;

+ (UIImage*) maskImage:(UIImage *)image withMask:(UIImage *)maskImage;


- (UIImage *)kc_maskImageWithColor:(UIColor *)color;

- (NSString *)kc_description;

@end
