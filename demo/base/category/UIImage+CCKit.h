//
//  UIImage+CCKit.h
//  performance
//
//  Created by KudoCC on 16/5/9.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (CCKit)

+ (UIImage *)cc_resizeImage:(UIImage *)image contentMode:(UIViewContentMode)contentMode size:(CGSize)size;

+ (UIImage *)cc_transparentCenterImageWithSize:(CGSize)size cornerRadius:(CGFloat)radius backgroundColor:(UIColor *)bgColor;
+ (UIImage *)cc_transparentCenterImageWithSize:(CGSize)size cornerRadius:(CGFloat)radius backgroundColor:(UIColor *)bgColor borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor;

- (UIImage *)cc_imageWithSize:(CGSize)size cornerRadius:(CGFloat)radius;
- (UIImage *)cc_imageWithSize:(CGSize)size cornerRadius:(CGFloat)radius contentMode:(UIViewContentMode)contentMode;
- (UIImage *)cc_imageWithSize:(CGSize)size cornerRadius:(CGFloat)radius borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor contentMode:(UIViewContentMode)contentMode;

+ (int)cc_iOSOrientationToExifOrientation:(UIImageOrientation)iOSOrientation;
+ (UIImageOrientation)cc_exifOrientationToiOSOrientation:(int)exifOrientation;

@end


@interface UIImage (fixOrientation)

// http://stackoverflow.com/questions/5427656/ios-uiimagepickercontroller-result-image-orientation-after-upload
// http://stackoverflow.com/questions/7838699/save-uiimage-load-it-in-wrong-orientation/10632187#10632187
// orientation保存在图片的metadata中
// 因为PNG并没有orientation的信息，或者上传的图片可能丢失了orientation的信息，这里的两个方法都将图片转换成了UIImageOrientationUp
// 所以即使丢失了信息，UIImageOrientationUp也是默认的展示方式，不会出现问题
- (UIImage *)fixOrientation;
- (UIImage *)fixOrientationV2;

@end

@interface UIImage (UIImagePickerController)

- (NSData *)pngDataWithMetadata:(NSDictionary *)metadata;
- (NSData *)jpegDataWithMetadata:(NSDictionary *)metadata compressQuality:(CGFloat)compressionQuality;

- (BOOL)writePNGDataWithMetadata:(NSDictionary *)metadata toURL:(NSURL *)url;
- (BOOL)writeJPEGDataWithMetadata:(NSDictionary *)metadata compressQuality:(CGFloat)compressionQuality toURL:(NSURL *)url;

@end