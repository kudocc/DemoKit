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

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blueColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight-64)];
    [self.view addSubview:_scrollView];
    CGFloat y = 64;
    
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
    UIGraphicsBeginImageContextWithOptions(imageToMask.size, YES, imageToMask.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIColor blackColor] setFill];
    CGContextFillRect(context, (CGRect){CGPointZero, imageToMask.size});
    [[UIColor whiteColor] setStroke];
    CGContextSetLineWidth(context, 5.0);
    CGRect rectStroke = (CGRect){CGPointZero, imageToMask.size};
    rectStroke = CGRectInset(rectStroke, 5, 5);
    CGContextStrokeRect(context, rectStroke);
    CGContextMoveToPoint(context, 0, imageToMask.size.height/2);
    CGContextAddLineToPoint(context, imageToMask.size.width, imageToMask.size.height/2);
    CGContextMoveToPoint(context, imageToMask.size.width/2, 0);
    CGContextAddLineToPoint(context, imageToMask.size.width/2, imageToMask.size.height);
    CGContextStrokePath(context);
    UIImage *imageAsMask = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSLog(@"mask with image:%@", [imageAsMask kc_description]);
    
    y += imageToMask.size.height + 10;
    _imageViewMaskWithImage = [[UIImageView alloc] initWithImage:imageAsMask];
    [_scrollView addSubview:_imageViewMaskWithImage];
    _imageViewMaskWithImage.frame = (CGRect){(CGPoint){0, y}, imageToMask.size};
    
    y += imageToMask.size.height + 10;
    UIImage *imageMask = [imageAsMask imageMask];
    NSLog(@"mask with imageMask:%@", [imageAsMask kc_description]);
    _imageViewMaskWithImageMask = [[UIImageView alloc] initWithImage:imageMask];
    [_scrollView addSubview:_imageViewMaskWithImageMask];
    _imageViewMaskWithImageMask.frame = (CGRect){(CGPoint){0, y}, imageToMask.size};
    
    /*
     The resulting image depends on whether the mask parameter is an image mask or an image. If the mask parameter is an image mask, then the source samples of the image mask act as an inverse alpha value. That is, if the value of a source sample in the image mask is S, then the corresponding region in image is blended with the destination using an alpha value of (1-S). For example, if S is 1, then the region is not painted, while if S is 0, the region is fully painted.
     
     If the mask parameter is an image, then it serves as an alpha mask for blending the image onto the destination. The source samples of mask' act as an alpha value. If the value of the source sample in mask is S, then the corresponding region in image is blended with the destination with an alpha of S. For example, if S is 0, then the region is not painted, while if S is 1, the region is fully painted.
     */
    
    // mask with image, it can't have alpha components
    // however I can't create a image without alpha components!!!! don't know why!!!
    CGImageRef imageMaskedRef = CGImageCreateWithMask(imageToMask.CGImage, imageAsMask.CGImage);
    UIImage *imageMasked = [UIImage imageWithCGImage:imageMaskedRef];
    NSLog(@"masked with image: %@", [imageMasked kc_description]);
    CGImageRelease(imageMaskedRef);
    
    y += imageToMask.size.height + 10;
    _imageViewResultMaskWithImage = [[UIImageView alloc] initWithImage:imageMasked];
    [_scrollView addSubview:_imageViewResultMaskWithImage];
    _imageViewResultMaskWithImage.frame = (CGRect){(CGPoint){0, y}, imageToMask.size};
    
    
    // mask with image mask
    imageMaskedRef = CGImageCreateWithMask(imageToMask.CGImage, imageMask.CGImage);
    imageMasked = [UIImage imageWithCGImage:imageMaskedRef];
    NSLog(@"masked with image mask: %@", [imageMasked kc_description]);
    CGImageRelease(imageMaskedRef);
    
    y += imageToMask.size.height + 10;
    _imageViewResultMaskWithImageMask = [[UIImageView alloc] initWithImage:imageMasked];
    [_scrollView addSubview:_imageViewResultMaskWithImageMask];
    _imageViewResultMaskWithImageMask.frame = (CGRect){(CGPoint){0, y}, imageToMask.size};
    
    // mask with color
    y += imageToMask.size.height + 10;
    UIImage *imageMaskWithColor = [UIImage imageNamed:@"no_alpha"];
    UIColor *color = [UIColor colorWithRed:89.0/255 green:172.0/255 blue:216.0/255 alpha:1.0];
    UIImage *imageRes = [imageMaskWithColor kc_maskImageWithColor:color];
    _imageViewResultMaskWithColor = [[UIImageView alloc] initWithImage:imageRes];
    _imageViewResultMaskWithColor.frame = (CGRect){(CGPoint){0, y}, imageMaskWithColor.size};
    [_scrollView addSubview:_imageViewResultMaskWithColor];
    
    y += imageMaskWithColor.size.height;
    _scrollView.contentSize = CGSizeMake(ScreenWidth, y);
}

@end
