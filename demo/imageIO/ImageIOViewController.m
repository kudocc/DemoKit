//
//  ImageIOViewController.m
//  demo
//
//  Created by KudoCC on 16/5/16.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "ImageIOViewController.h"
#import <ImageIO/ImageIO.h>
#import "ImageSourceViewController.h"

@implementation ImageIOViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.arrayTitle = @[@"Image Source"];
    self.arrayClass = @[[ImageSourceViewController class]];
    
    CFArrayRef mySourceTypes = CGImageSourceCopyTypeIdentifiers();
    CFShow(mySourceTypes);
    CFArrayRef myDestinationTypes = CGImageDestinationCopyTypeIdentifiers();
    CFShow(myDestinationTypes);
    
    CFRelease(mySourceTypes);
    CFRelease(myDestinationTypes);
}


@end
