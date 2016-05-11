//
//  ViewController.m
//  performance
//
//  Created by KudoCC on 16/1/19.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "PerformanceViewController.h"
#import "TableViewPerformanceViewController.h"
#import "TestMissalignedViewController.h"
#import "TestBlendViewController.h"
#import "TestDrawScaleViewController.h"

@interface PerformanceViewController ()

@end

@implementation PerformanceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.arrayTitle = @[@"Test clipToMask", @"Test draw scale", @"Test missaligned", @"Test blend"];
    self.arrayClass = @[[TableViewPerformanceViewController class],
                    [TestDrawScaleViewController class],
                    [TestBlendViewController class],
                    [TestMissalignedViewController class]];
}

@end
