//
//  CCKitMacro.h
//  demo
//
//  Created by KudoCC on 16/6/14.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

#define PixelToPoint(x) (x/[UIScreen mainScreen].scale)

#define CCMainThreadBlock(block) \
    if ([NSThread isMainThread]) {\
        block();\
    } else {\
        dispatch_async(dispatch_get_main_queue(), ^() {\
            block();\
        });\
    }
