//
//  ImagePickerViewControllerHelper.h
//  demo
//
//  Created by KudoCC on 16/5/18.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ImagePickerInfoCallback)(NSDictionary<NSString *,id> *info);

@interface ImagePickerViewControllerHelper : NSObject <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

+ (instancetype)sharedHelper;

@property (nonatomic, copy) ImagePickerInfoCallback callback;

- (void)presentImagePickerWithBlock:(ImagePickerInfoCallback)callback viewController:(UIViewController *)vc;

@end
