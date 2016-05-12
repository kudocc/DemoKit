//
//  ImageMaskViewController.m
//  ImageMask
//
//  Created by KudoCC on 16/5/11.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "ImageMaskViewController.h"
#import "UIImage+ImageMask.h"

@implementation ImageMaskViewController

- (NSString *)kc_description:(CGImageRef)imageRef {
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

- (UIImage *)noAlphaChannelImageWithSize:(CGSize)size {
    int pixelsWide = size.width * [UIScreen mainScreen].scale;
    int pixelsHigh = size.height * [UIScreen mainScreen].scale;
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    int             bitmapByteCount;
    int             bitmapBytesPerRow;
    
    bitmapBytesPerRow   = (pixelsWide * 4);
    bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
    
    colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    context = CGBitmapContextCreate (NULL, pixelsWide, pixelsHigh,
                                     8, bitmapBytesPerRow,
                                     colorSpace, kCGImageAlphaNoneSkipLast);
    
    CGContextSetFillColorWithColor(context, [UIColor cc_colorWithRed:200 green:200 blue:100].CGColor);
    CGContextFillRect(context, (CGRect){CGPointZero, CGSizeMake(pixelsWide, pixelsHigh)});
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(context, 5.0);
    CGRect rectStroke = (CGRect){CGPointZero, CGSizeMake(pixelsWide, pixelsHigh)};
    rectStroke = CGRectInset(rectStroke, 5, 5);
    CGContextStrokeRect(context, rectStroke);
    
    CGContextMoveToPoint(context, 0, pixelsHigh/2);
    CGContextAddLineToPoint(context, pixelsWide, pixelsHigh/2);
    CGContextMoveToPoint(context, pixelsWide/2, 0);
    CGContextAddLineToPoint(context, pixelsWide/2, pixelsHigh);
    CGContextStrokePath(context);
    
    CGImageRef imageRes = CGBitmapContextCreateImage(context);
    UIImage *image = [UIImage imageWithCGImage:imageRes scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
    CGImageRelease(imageRes);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    return image;
}

- (UIImage *)deviceGrayColorSpaceImage:(CGSize)size {
    int pixelsWide = size.width * [UIScreen mainScreen].scale;
    int pixelsHigh = size.height * [UIScreen mainScreen].scale;
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    int             bitmapByteCount;
    int             bitmapBytesPerRow;
    
    bitmapBytesPerRow   = (pixelsWide);
    bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
    
    colorSpace = CGColorSpaceCreateDeviceGray();
    context = CGBitmapContextCreate (NULL, pixelsWide, pixelsHigh,
                                     8, bitmapBytesPerRow,
                                     colorSpace, kCGImageAlphaNone);
    
    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextFillRect(context, (CGRect){CGPointZero, CGSizeMake(pixelsWide, pixelsHigh)});
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(context, 5.0);
    CGRect rectStroke = (CGRect){CGPointZero, CGSizeMake(pixelsWide, pixelsHigh)};
    rectStroke = CGRectInset(rectStroke, 5, 5);
    CGContextStrokeRect(context, rectStroke);
    
    CGContextMoveToPoint(context, 0, pixelsHigh/2);
    CGContextAddLineToPoint(context, pixelsWide, pixelsHigh/2);
    CGContextMoveToPoint(context, pixelsWide/2, 0);
    CGContextAddLineToPoint(context, pixelsWide/2, pixelsHigh);
    CGContextStrokePath(context);
    
    CGImageRef imageRes = CGBitmapContextCreateImage(context);
    UIImage *image = [UIImage imageWithCGImage:imageRes scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
    CGImageRelease(imageRes);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    return image;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blueColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight-64)];
    [self.view addSubview:_scrollView];
    CGFloat y = 10;
    
    /*
     The image to apply the mask parameter to. This image must not be an image mask and may not have an image mask or masking color associated with it.
     */
    UIImage *imageToMask = [UIImage imageNamed:@"bg"];
    NSLog(@"imageToMask:%@", [imageToMask kc_description]);
    _imageViewOri = [[UIImageView alloc] initWithImage:imageToMask];
    [_scrollView addSubview:_imageViewOri];
    _imageViewOri.frame = (CGRect){(CGPoint){0, y}, imageToMask.size};
    
    /*
     A mask. If the mask is an image, it must be in the DeviceGray color space, must not have an alpha component, and may not itself be masked by an image mask or a masking color. If the mask is not the same size as the image specified by the image parameter, then Quartz scales the mask to fit the image.
     */
    UIImage *imageAsMask = [self deviceGrayColorSpaceImage:imageToMask.size];
    NSLog(@"mask with image:%@", [imageAsMask kc_description]);
    y += imageToMask.size.height + 10;
    _imageViewMaskWithImage = [[UIImageView alloc] initWithImage:imageAsMask];
    [_scrollView addSubview:_imageViewMaskWithImage];
    _imageViewMaskWithImage.frame = (CGRect){(CGPoint){0, y}, imageToMask.size};
    
    y += imageToMask.size.height + 10;
    // The image is used as a mask
    UIImage *imageMask = [self noAlphaChannelImageWithSize:imageToMask.size];
    NSLog(@"image as mask:%@", [imageMask kc_description]);
    _imageViewMaskWithImageMask = [[UIImageView alloc] initWithImage:imageMask];
    [_scrollView addSubview:_imageViewMaskWithImageMask];
    _imageViewMaskWithImageMask.frame = (CGRect){(CGPoint){0, y}, imageToMask.size};
    // generate a mask
    imageMask = [imageMask imageMask];
    
    /*
     The resulting image depends on whether the mask parameter is an image mask or an image. If the mask parameter is an image mask, then the source samples of the image mask act as an inverse alpha value. That is, if the value of a source sample in the image mask is S, then the corresponding region in image is blended with the destination using an alpha value of (1-S). For example, if S is 1, then the region is not painted, while if S is 0, the region is fully painted.
     
     If the mask parameter is an image, then it serves as an alpha mask for blending the image onto the destination. The source samples of mask' act as an alpha value. If the value of the source sample in mask is S, then the corresponding region in image is blended with the destination with an alpha of S. For example, if S is 0, then the region is not painted, while if S is 1, the region is fully painted.
     */
    
    // mask with image, it must be DeviceGray color space, must not have an alpha component
    CGImageRef imageMaskedRef = CGImageCreateWithMask(imageToMask.CGImage, imageAsMask.CGImage);
    UIImage *imageMasked = [UIImage imageWithCGImage:imageMaskedRef];
    NSLog(@"result masked with image: %@", [imageMasked kc_description]);
    CGImageRelease(imageMaskedRef);
    
    y += imageToMask.size.height + 10;
    _imageViewResultMaskWithImage = [[UIImageView alloc] initWithImage:imageMasked];
    [_scrollView addSubview:_imageViewResultMaskWithImage];
    _imageViewResultMaskWithImage.frame = (CGRect){(CGPoint){0, y}, imageToMask.size};
    
    
    // mask with image mask
    imageMaskedRef = CGImageCreateWithMask(imageToMask.CGImage, imageMask.CGImage);
    imageMasked = [UIImage imageWithCGImage:imageMaskedRef];
    NSLog(@"result masked with image mask: %@", [imageMasked kc_description]);
    CGImageRelease(imageMaskedRef);
    
    y += imageToMask.size.height + 10;
    _imageViewResultMaskWithImageMask = [[UIImageView alloc] initWithImage:imageMasked];
    [_scrollView addSubview:_imageViewResultMaskWithImageMask];
    _imageViewResultMaskWithImageMask.frame = (CGRect){(CGPoint){0, y}, imageToMask.size};
    y = _imageViewResultMaskWithImageMask.bottom + 10;
    
    UILabel *labelColor = [[UILabel alloc] initWithFrame:CGRectMake(0, y, ScreenWidth, 20)];
    [_scrollView addSubview:labelColor];
    labelColor.textAlignment = NSTextAlignmentCenter;
    labelColor.text = @"mask with color";
    labelColor.font = [UIFont systemFontOfSize:17];
    y = labelColor.bottom + 10;
    
    // mask with color
    {
        /*
         The image to mask. This parameter may not be an image mask, may not already have an image mask or masking color associated with it, and cannot have an alpha component.
         */
        UIImage *imageBg = [self noAlphaChannelImageWithSize:CGSizeMake(200, 200)];
        UIImageView *imageViewOri = [[UIImageView alloc] initWithImage:imageBg];
        [_scrollView addSubview:imageViewOri];
        imageViewOri.frame = (CGRect){(CGPoint){0, y}, imageBg.size};
        y = imageViewOri.bottom + 10;
        
        // mask out white color
        const CGFloat myMaskingColors[6] = {255, 255, 255, 255, 255, 255};
        // mask out black color
//        const CGFloat myMaskingColors[6] = {0, 0, 0, 0, 0, 0};
        CGImageRef imageMaskedRef = CGImageCreateWithMaskingColors(imageBg.CGImage, myMaskingColors);
        UIImage *imageMasked = [UIImage imageWithCGImage:imageMaskedRef];
        _imageViewResultMaskWithColor = [[UIImageView alloc] initWithImage:imageMasked];
        _imageViewResultMaskWithColor.frame = (CGRect){(CGPoint){0, y}, imageBg.size};
        [_scrollView addSubview:_imageViewResultMaskWithColor];
        
        y = _imageViewResultMaskWithColor.bottom + 10;
    }
    
    _scrollView.contentSize = CGSizeMake(ScreenWidth, y);
}

@end
