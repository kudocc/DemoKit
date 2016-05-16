//
//  ImageIO.h
//  demo
//
//  Created by KudoCC on 16/5/16.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ImagePickerInfoCallback)(NSDictionary<NSString *,id> *info);

@interface ImageIO : NSObject <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

+ (instancetype)sharedImageIO;


@property (nonatomic, copy) ImagePickerInfoCallback callback;

- (void)presentImagePickerWithBlock:(ImagePickerInfoCallback)callback viewController:(UIViewController *)vc;

@end
