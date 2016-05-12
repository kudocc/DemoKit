//
//  ViewController.m
//  ImageMask
//
//  Created by KudoCC on 16/1/7.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "Quartz2DViewController.h"
#import "ImageMaskViewController.h"
#import "CoordinateViewController.h"
#import "ShadowGradientsViewController.h"

@interface Quartz2DViewController ()

@end

@implementation Quartz2DViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.arrayTitle = @[@"ImageMask", @"Coordinate Test", @"Shadow"];
    self.arrayClass = @[[ImageMaskViewController class],
                        [CoordinateViewController class],
                        [ShadowGradientsViewController class]];
}

@end
