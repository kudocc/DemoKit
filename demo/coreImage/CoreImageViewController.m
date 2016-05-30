//
//  CoreImageViewController.m
//  demo
//
//  Created by KudoCC on 16/5/18.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "CoreImageViewController.h"
#import "BuiltinFilterViewController.h"
#import "BuiltinFilterChainViewController.h"
#import "FaceDetectorViewController.h"

@implementation CoreImageViewController

- (void)initView {
    self.arrayTitle = @[@"builtin filter",
                        @"builtin chained filter",
                        @"face detector"];
    self.arrayClass = @[[BuiltinFilterViewController class],
                        [BuiltinFilterChainViewController class],
                        [FaceDetectorViewController class]];
    
//    [self logAllFilters];
}

- (void)logAllFilters {
    NSArray *properties = [CIFilter filterNamesInCategory:
                           kCICategoryBuiltIn];
    NSLog(@"%@", properties);
    for (NSString *filterName in properties) {
        CIFilter *fltr = [CIFilter filterWithName:filterName];
        NSLog(@"%@", [fltr attributes]);
    }
}

@end