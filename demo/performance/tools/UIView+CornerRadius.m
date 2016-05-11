//
//  UIView+CornerRadius.m
//  performance
//
//  Created by KudoCC on 16/3/9.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "UIView+CornerRadius.h"
#import "UIImage+CCKit.h"
#import <objc/runtime.h>

static char cornerRadiusImageViewKey;

@implementation UIView (CornerRadius)

- (UIImageView *)cornerRadius_imageView {
    return objc_getAssociatedObject(self, &cornerRadiusImageViewKey);
}

- (void)cornerRadius_addCornerRadius:(CGFloat)radius backgroundColor:(UIColor *)bgColor {
    [self cornerRadius_addCornerRadius:radius backgroundColor:bgColor borderWidth:0 borderColor:nil];
}

- (void)cornerRadius_addCornerRadius:(CGFloat)radius backgroundColor:(UIColor *)bgColor borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor {
    UIImageView *imageView = [self cornerRadius_imageView];
    CGSize size = self.bounds.size;
    if (!imageView) {
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, size.width, size.height)];
        [self addSubview:imageView];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    UIImage *image = [UIImage cc_transparentCenterImageWithSize:size
                               cornerRadius:radius
                            backgroundColor:bgColor
                                borderWidth:borderWidth
                                borderColor:borderColor];
    if (size.width > 0 && size.height > 0) {
        image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(floor(size.height/2)-1, floor(size.width/2)-1, floor(size.height/2), floor(size.width/2))];
    }
    imageView.image = image;
    objc_setAssociatedObject(self, &cornerRadiusImageViewKey, imageView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
