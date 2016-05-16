//
//  ImageDestinationViewController.m
//  demo
//
//  Created by KudoCC on 16/5/16.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "ImageDestinationViewController.h"
#import <ImageIO/ImageIO.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "NSString+File.h"

@implementation ImageDestinationViewController {
    UIScrollView *scrollView;
}

- (void)addImageToViewWithCGImageSourceRef:(CGImageSourceRef)imageSource {
    CGFloat x = 0;
    CGFloat y = scrollView.contentSize.height;
    
    if (imageSource) {
        CFDictionaryRef property = CGImageSourceCopyProperties(imageSource, NULL);
        NSDictionary *dictProperty = (__bridge_transfer id)property;
        NSLog(@"container property:%@", dictProperty);
        
        property = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, NULL);
        dictProperty = (__bridge_transfer id)property;
        NSLog(@"image at index 0 property:%@", dictProperty);
        
        UIImageOrientation orientation = UIImageOrientationUp;
        int exifOrientation;
        CFTypeRef val = CFDictionaryGetValue(property, kCGImagePropertyOrientation);
        if (val) {
            CFNumberGetValue(val, kCFNumberIntType, &exifOrientation);
            orientation = [self sd_exifOrientationToiOSOrientation:exifOrientation];
        }
        
        size_t count = CGImageSourceGetCount(imageSource);
        NSLog(@"image count:%zu", count);
        
        for (size_t i = 0; i < count; ++i) {
            CGImageRef img = CGImageSourceCreateImageAtIndex(imageSource, i, NULL);
            if (img) {
                UIImage *image = [UIImage imageWithCGImage:img scale:[UIScreen mainScreen].scale orientation:orientation];
                UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
                [scrollView addSubview:imageView];
                imageView.origin = CGPointMake(x, y);
                y = imageView.bottom + 10;
                
                CGImageRelease(img);
            }
        }
    }
    
    scrollView.contentSize = CGSizeMake(ScreenWidth, y);
}

- (void)addImageToViewWithURL:(NSURL *)url {
    CGFloat x = 0;
    CGFloat y = scrollView.contentSize.height;
    
    CGImageSourceRef imageSource = CGImageSourceCreateWithURL((__bridge CFURLRef)url, NULL);
    if (imageSource) {
        CFDictionaryRef property = CGImageSourceCopyProperties(imageSource, NULL);
        NSDictionary *dictProperty = (__bridge_transfer id)property;
        NSLog(@"container property:%@", dictProperty);
        
        property = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, NULL);
        dictProperty = (__bridge_transfer id)property;
        NSLog(@"image at index 0 property:%@", dictProperty);
        
        UIImageOrientation orientation = UIImageOrientationUp;
        int exifOrientation;
        CFTypeRef val = CFDictionaryGetValue(property, kCGImagePropertyOrientation);
        if (val) {
            CFNumberGetValue(val, kCFNumberIntType, &exifOrientation);
            orientation = [self sd_exifOrientationToiOSOrientation:exifOrientation];
        }
        
        size_t count = CGImageSourceGetCount(imageSource);
        NSLog(@"image count:%zu", count);
        
        for (size_t i = 0; i < count; ++i) {
            CGImageRef img = CGImageSourceCreateImageAtIndex(imageSource, i, NULL);
            if (img) {
                UIImage *image = [UIImage imageWithCGImage:img scale:[UIScreen mainScreen].scale orientation:orientation];
                UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
                [scrollView addSubview:imageView];
                imageView.origin = CGPointMake(x, y);
                y = imageView.bottom + 10;
                
                CGImageRelease(img);
            }
        }
    }
    
    scrollView.contentSize = CGSizeMake(ScreenWidth, y);
    
    CFRelease(imageSource);
}

- (void)initView {
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Add Image" style:UIBarButtonItemStylePlain target:self action:@selector(addImage)];
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight-64)];
    [self.view addSubview:scrollView];
    scrollView.backgroundColor = [UIColor whiteColor];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"image_source" ofType:@"gif"];
    NSURL *url = [NSURL fileURLWithPath:path];
    [self addImageToViewWithURL:url];
}

- (void)addImage {
    [[ImageIO sharedImageIO] presentImagePickerWithBlock:^(NSDictionary<NSString *,id> *info) {
        // save image to file url
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        NSDictionary *dictMetadata = info[UIImagePickerControllerMediaMetadata];
        NSData *data = UIImageJPEGRepresentation(image, 1.0);
        CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
        [self addImageToViewWithCGImageSourceRef:imageSource];
        CFRelease(imageSource);
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *imageDirectory = [[NSString documentPath] stringByAppendingPathComponent:@"imageIO"];
            NSString *name = [NSString stringWithFormat:@"%d", (int)[[NSDate date] timeIntervalSinceNow]];
            NSString *path = [imageDirectory stringByAppendingPathComponent:name];
            NSURL *url = [NSURL fileURLWithPath:path];
            CGImageDestinationRef imageDest = CGImageDestinationCreateWithURL((__bridge CFTypeRef)url, CFSTR("public.jpeg"), 1, NULL);
            CGImageDestinationAddImage(imageDest, image.CGImage, NULL);
            NSDictionary *dictProperty = @{(__bridge id)kCGImagePropertyExifDictionary:dictMetadata};
            CGImageDestinationSetProperties(imageDest, (__bridge CFDictionaryRef)dictProperty);
            CGImageDestinationFinalize(imageDest);
            
            // retrive the exif
            CGImageSourceRef imageSource = CGImageSourceCreateWithURL((__bridge CFURLRef)url, NULL);
            if (imageSource) {
                CFDictionaryRef property = CGImageSourceCopyProperties(imageSource, NULL);
                dictProperty = (__bridge_transfer id)property;
                NSLog(@"container property:%@", dictProperty);
                
                property = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, NULL);
                dictProperty = (__bridge_transfer id)property;
                NSLog(@"image at index 0 property:%@", dictProperty);
                
//                CGImageMetadataRef metadata = CGImageSourceCopyMetadataAtIndex(imageSource, 0, NULL);
                
                CFRelease(imageSource);
            }
        });
    } viewController:self];
}

#pragma mark -

- (UIImageOrientation) sd_exifOrientationToiOSOrientation:(int)exifOrientation {
    UIImageOrientation orientation = UIImageOrientationUp;
    switch (exifOrientation) {
        case 1:
            orientation = UIImageOrientationUp;
            break;
            
        case 3:
            orientation = UIImageOrientationDown;
            break;
            
        case 8:
            orientation = UIImageOrientationLeft;
            break;
            
        case 6:
            orientation = UIImageOrientationRight;
            break;
            
        case 2:
            orientation = UIImageOrientationUpMirrored;
            break;
            
        case 4:
            orientation = UIImageOrientationDownMirrored;
            break;
            
        case 5:
            orientation = UIImageOrientationLeftMirrored;
            break;
            
        case 7:
            orientation = UIImageOrientationRightMirrored;
            break;
        default:
            break;
    }
    return orientation;
}

@end
