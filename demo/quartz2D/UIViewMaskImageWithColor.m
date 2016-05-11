//
//  UIViewMaskImageWithColor.m
//  ImageMask
//
//  Created by KudoCC on 16/1/7.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "UIViewMaskImageWithColor.h"
#import "UIImage+ImageMask.h"

@implementation UIViewMaskImageWithColor

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // The image to be masked can't have alpha component
        UIImage *imageBg = [UIImage imageNamed:@"no_alpha"];
        
        _imageViewOri = [[UIImageView alloc] initWithImage:imageBg];
        [self addSubview:_imageViewOri];
        
        UIGraphicsBeginImageContextWithOptions(_imageViewOri.bounds.size, YES, 0.0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        const CGFloat myMaskingColors[6] = {255, 255, 255, 255, 254, 255};
        CGImageRef imageMaskedRef = CGImageCreateWithMaskingColors(imageBg.CGImage, myMaskingColors);
        UIImage *imageTest = [UIImage imageWithCGImage:imageMaskedRef];
        CGContextSetRGBFillColor(context, 1.0, 0.0, 0.0, 1);
        CGContextFillRect(context, _imageViewOri.bounds);
        CGContextDrawImage(context, _imageViewOri.bounds, imageMaskedRef);
        UIImage *imageMasked = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        _imageViewResult = [[UIImageView alloc] initWithImage:imageMasked];
        [self addSubview:_imageViewResult];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _imageViewOri.frame = CGRectMake(0.0, 64.0, _imageViewOri.bounds.size.width, _imageViewOri.bounds.size.height);
    _imageViewResult.frame = CGRectMake(0.0, floor(_imageViewOri.frame.origin.y+_imageViewOri.frame.size.height) + 10, _imageViewOri.bounds.size.width, _imageViewOri.bounds.size.height);
}

@end
