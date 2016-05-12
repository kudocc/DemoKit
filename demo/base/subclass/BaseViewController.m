//
//  UIBaseViewController.m
//  AnimationDemo
//
//  Created by KudoCC on 15/4/27.
//  Copyright (c) 2015年 KudoCC. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@property (nonatomic, strong) UITapGestureRecognizer *tapGR;
@property (nonatomic, strong) CALayer *layerTips;

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor cc_colorWithRed:239 green:239 blue:244];
    self.view.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
    
    NSString *string = @"Tap触发动画";
    NSDictionary *attribute = @{NSFontAttributeName:[UIFont systemFontOfSize:14.0], NSForegroundColorAttributeName:[UIColor blueColor]};
    CGRect bounding = [string boundingRectWithSize:CGSizeMake(1024, 30.0) options:0 attributes:attribute context:nil];
    CGSize size = CGSizeMake(ceil(bounding.size.width), ceil(bounding.size.height));
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [string drawAtPoint:CGPointMake(0, 0) withAttributes:attribute];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    _layerTips = [[CALayer alloc] init];
    
    _layerTips.contents = (__bridge id)image.CGImage;
    [self.view.layer addSublayer:_layerTips];
    _layerTips.frame = CGRectMake(0, 0, size.width, size.height);
    _layerTips.position = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
}

- (void)setEnableTap:(BOOL)enableTap {
    _enableTap = enableTap;
    if (_enableTap) {
        if (!_tapGR) {
            _tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick:)];
        }
        [self.view addGestureRecognizer:_tapGR];
    } else {
        if (_tapGR) {
            [self.view removeGestureRecognizer:_tapGR];
        }
    }
}

- (void)tapClick:(UITapGestureRecognizer *)gr {
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
