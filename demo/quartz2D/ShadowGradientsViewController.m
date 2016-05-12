//
//  ShadowGradientsViewController.m
//  demo
//
//  Created by KudoCC on 16/5/12.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "ShadowGradientsViewController.h"
#import "UILinearGradientView.h"

@implementation ShadowGradientsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight-64)];
    [self.view addSubview:scrollView];
    scrollView.backgroundColor = [UIColor whiteColor];
    
    CGFloat y = 0;
    // create a shadow image
    CGSize size = CGSizeMake(ScreenWidth, ScreenWidth);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, CGSizeMake(10, 5), 0.5, [UIColor blueColor].CGColor);
    CGContextSetFillColorWithColor(context, [UIColor cc_colorWithRed:200 green:10 blue:10].CGColor);
    CGContextFillRect(context, CGRectMake(10, 10, 50, 50));
    CGContextRestoreGState(context);
    
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextStrokeRect(context, CGRectMake(61, 61, 30, 30));
    
    UIImage *imageShadow = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImageView *imageViewShadow = [[UIImageView alloc] initWithImage:imageShadow];
    [scrollView addSubview:imageViewShadow];
    imageViewShadow.frame = CGRectMake(0, 0, imageViewShadow.width, imageViewShadow.height);
    
    y = imageViewShadow.bottom + 10;
    // create a gradients view
    UILinearGradientView *gradientView = [[UILinearGradientView alloc] initWithFrame:CGRectMake(0, y, scrollView.width, scrollView.height) colors:@[[UIColor redColor], [UIColor greenColor], [UIColor blueColor]] axis:UILinerGradientViewAxisX];
    [scrollView addSubview:gradientView];
    y = gradientView.bottom + 10;
    scrollView.contentSize = CGSizeMake(ScreenWidth, y);
}

@end
