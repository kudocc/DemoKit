//
//  ImageDestinationViewController.m
//  demo
//
//  Created by KudoCC on 16/5/16.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "ImageDestinationViewController.h"
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "NSString+File.h"
#import <CoreLocation/CoreLocation.h>
#import "UIImage+CCKit.h"

// save meta data to photosalbum in iOS
// http://stackoverflow.com/questions/7965299/write-uiimage-along-with-metadata-exif-gps-tiff-in-iphones-photo-library

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
            orientation = [UIImage cc_exifOrientationToiOSOrientation:exifOrientation];
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
            orientation = [UIImage cc_exifOrientationToiOSOrientation:exifOrientation];
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

- (NSString *)fileDirectory {
    return [[NSString documentPath] stringByAppendingPathComponent:@"imageIO"];
}

- (void)initView {
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.navigationItem.rightBarButtonItem = nil;
    
    UIBarButtonItem *addImageItem = [[UIBarButtonItem alloc] initWithTitle:@"Add Image" style:UIBarButtonItemStylePlain target:self action:@selector(addImage)];
    UIBarButtonItem *cleanFileItem = [[UIBarButtonItem alloc] initWithTitle:@"Clean" style:UIBarButtonItemStylePlain target:self action:@selector(clean)];
    self.navigationItem.rightBarButtonItems = @[addImageItem, cleanFileItem];
    
    // create directory
    NSString *directory = [self fileDirectory];
    if (![[NSFileManager defaultManager] fileExistsAtPath:directory]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight-64)];
    [self.view addSubview:scrollView];
    scrollView.backgroundColor = [UIColor whiteColor];
}

- (void)addImage {
    [[ImageIO sharedImageIO] presentImagePickerWithBlock:^(NSDictionary<NSString *,id> *info) {
        [self showLoadingMessage:@"save image to file"];
        
        // save image to file url
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        NSDictionary *dictMetadata = info[UIImagePickerControllerMediaMetadata];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *data = UIImageJPEGRepresentation(image, 1.0);
            
            NSString *imageDirectory = [self fileDirectory];
            NSString *name = [NSString stringWithFormat:@"%d.jpeg", (int)[[NSDate date] timeIntervalSince1970]];
            NSString *path = [imageDirectory stringByAppendingPathComponent:name];
            
            NSData *photoData = [self taggedImageData:data metadata:dictMetadata orientation:image.imageOrientation];
            [photoData writeToFile:path atomically:YES];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
                [self addImageToViewWithCGImageSourceRef:imageSource];
                CFRelease(imageSource);
            });
            
            // retrive the exif
            NSURL *url = [NSURL fileURLWithPath:path];
            CGImageSourceRef imageSource = CGImageSourceCreateWithURL((__bridge CFURLRef)url, NULL);
            if (imageSource) {
                CFDictionaryRef property = CGImageSourceCopyProperties(imageSource, NULL);
                NSDictionary *dictProperty = (__bridge_transfer id)property;
                NSLog(@"container property:%@", dictProperty);
                
                property = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, NULL);
                dictProperty = (__bridge_transfer id)property;
                NSLog(@"image at index 0 property:%@", dictProperty);
                
                CFRelease(imageSource);
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideLoadingMessage];
            });
        });
    } viewController:self];
}

- (void)clean {
    [self showLoadingMessage:@"remove image files in imageIO directory"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *imageDirectory = [self fileDirectory];
        NSDirectoryEnumerator<NSString *> *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:imageDirectory];
        NSString *file = nil;
        while ((file = [enumerator nextObject]) != nil) {
            BOOL res = [[NSFileManager defaultManager] removeItemAtPath:file error:nil];
            if (!res) {
                NSLog(@"remove file %@ failed", file);
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideLoadingMessage];
        });
    });
}

#pragma mark -

- (NSData *)writeMetadataIntoImageData:(NSData *)imageData metadata:(NSMutableDictionary *)metadata {
    // create an imagesourceref
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef) imageData, NULL);
    
    // this is the type of image (e.g., public.jpeg)
    CFStringRef UTI = CGImageSourceGetType(source);
    
    // create a new data object and write the new image into it
    NSMutableData *dest_data = [NSMutableData data];
    CGImageDestinationRef destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)dest_data, UTI, 1, NULL);
    if (!destination) {
        NSLog(@"Error: Could not create image destination");
    }
    // add the image contained in the image source to the destination, overidding the old metadata with our modified metadata
    metadata = nil;
    CGImageDestinationAddImageFromSource(destination, source, 0, (__bridge CFDictionaryRef) metadata);
    BOOL success = CGImageDestinationFinalize(destination);
    if (!success) {
        NSLog(@"Error: Could not create data from image destination");
    }
    CFRelease(destination);
    CFRelease(source);
    return dest_data;
}

- (NSData *)taggedImageData:(NSData *)imageData metadata:(NSDictionary *)metadata orientation:(UIImageOrientation)orientation {
    NSMutableDictionary *newMetadata = [metadata mutableCopy];
    
    // add gps info
    if (!newMetadata[(__bridge id)kCGImagePropertyGPSDictionary]) {
        // TODO:location
//        CLLocationManager *locationManager = [CLLocationManager new];
//        // get nil here
//        CLLocation *location = [locationManager location];
//        newMetadata[(NSString *)kCGImagePropertyGPSDictionary] = [self gpsDictionaryForLocation:location];
    }
    
    // modify the orientation with exif format
    int exifOrientation = [UIImage cc_iOSOrientationToExifOrientation:orientation];
    if (exifOrientation != -1) {
        newMetadata[(__bridge id)kCGImagePropertyOrientation] = @(exifOrientation);
    }
    return [self writeMetadataIntoImageData:imageData metadata:newMetadata];
}

- (NSDictionary *)gpsDictionaryForLocation:(CLLocation *)location {
    NSTimeZone      *timeZone   = [NSTimeZone timeZoneWithName:@"UTC"];
    NSDateFormatter *formatter  = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:timeZone];
    [formatter setDateFormat:@"HH:mm:ss.SS"];
    
    NSDictionary *gpsDict = @{(NSString *)kCGImagePropertyGPSLatitude: @(fabs(location.coordinate.latitude)),
                              (NSString *)kCGImagePropertyGPSLatitudeRef: ((location.coordinate.latitude >= 0) ? @"N" : @"S"),
                              (NSString *)kCGImagePropertyGPSLongitude: @(fabs(location.coordinate.longitude)),
                              (NSString *)kCGImagePropertyGPSLongitudeRef: ((location.coordinate.longitude >= 0) ? @"E" : @"W"),
                              (NSString *)kCGImagePropertyGPSTimeStamp: [formatter stringFromDate:[location timestamp]],
                              (NSString *)kCGImagePropertyGPSAltitude: @(fabs(location.altitude)),
                              };
    return gpsDict;
}

@end
