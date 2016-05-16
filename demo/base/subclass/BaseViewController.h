//
//  UIBaseViewController.h
//  AnimationDemo
//
//  Created by KudoCC on 15/4/27.
//  Copyright (c) 2015年 KudoCC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+CCKit.h"
#import "UIColor+CCKit.h"

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

#define Pixel(x) (x/[UIScreen mainScreen])

@interface BaseViewController : UIViewController

@property (nonatomic, assign) BOOL enableTap;

@end

@interface BaseViewController (need_override)

// called after `viewDidLoad`
- (void)initView;

- (void)tapClick:(UITapGestureRecognizer *)gr;

@end
