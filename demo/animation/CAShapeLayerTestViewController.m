//
//  CAShapeLayerTestViewController.m
//  AnimationDemo
//
//  Created by KudoCC on 15/10/26.
//  Copyright © 2015年 KudoCC. All rights reserved.
//

#import "CAShapeLayerTestViewController.h"

@interface CAShapeLayerTestViewController ()

@property (nonatomic, strong) CAShapeLayer *shapeLayer;

@end

@implementation CAShapeLayerTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor grayColor];
    self.enableTap = YES;
    
    _shapeLayer = [CAShapeLayer layer];
    [self.view.layer addSublayer:_shapeLayer];
    _shapeLayer.frame = CGRectMake(0.0, 64.0, 300.0, 300.0);
    _shapeLayer.backgroundColor = [UIColor whiteColor].CGColor;
    _shapeLayer.lineWidth = 1.0;
    _shapeLayer.strokeColor = [UIColor greenColor].CGColor;
    _shapeLayer.fillColor = [UIColor clearColor].CGColor;
}

- (void)animatePath {
    CGMutablePathRef spath = CGPathCreateMutable();
    CGPathMoveToPoint(spath, NULL, 0, 0);
    CGPathAddLineToPoint(spath, NULL, 30.0, 30.0);
    CGPathAddLineToPoint(spath, NULL, 80.0, 30.0);
    CGPathAddLineToPoint(spath, NULL, 80.0, 80.0);
    CGPathAddLineToPoint(spath, NULL, 130.0, 80.0);
    CGPathCloseSubpath(spath);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0, 0);
    CGPathAddLineToPoint(path, NULL, 50.0, 50.0);
    CGPathAddLineToPoint(path, NULL, 100.0, 50.0);
    CGPathAddLineToPoint(path, NULL, 100.0, 100.0);
    CGPathAddLineToPoint(path, NULL, 150.0, 100.0);
    CGPathCloseSubpath(path);
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
    animation.fromValue = (__bridge id)spath;
    animation.toValue = (__bridge id)path;
    animation.duration = 2.0;
    animation.autoreverses = NO;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [_shapeLayer addAnimation:animation forKey:@"animatePath"];
    
    _shapeLayer.path = path;
    
    CGPathRelease(path);
    CGPathRelease(spath);
}

- (void)animateStrokePath {
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0, 0);
    CGPathAddLineToPoint(path, NULL, 50.0, 50.0);
    CGPathAddLineToPoint(path, NULL, 100.0, 50.0);
    CGPathAddLineToPoint(path, NULL, 100.0, 100.0);
    CGPathAddLineToPoint(path, NULL, 150.0, 100.0);
    CGPathCloseSubpath(path);
    
    CGPathMoveToPoint(path, NULL, 150, 150);
    CGPathAddLineToPoint(path, NULL, 150, 200);
    CGPathAddLineToPoint(path, NULL, 200, 200);
    CGPathCloseSubpath(path);
    
    _shapeLayer.path = path;
    CGPathRelease(path);
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.fromValue = @0.0;
    animation.toValue = @1.0;
    animation.duration = 2.0;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [_shapeLayer addAnimation:animation forKey:@"animatePath"];
}

- (void)tapClick:(UITapGestureRecognizer *)gr {
    [self animateStrokePath];
}

@end
