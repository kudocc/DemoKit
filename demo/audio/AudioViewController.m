//
//  ViewController.m
//  audio
//
//  Created by KudoCC on 15/9/21.
//  Copyright (c) 2015年 KudoCC. All rights reserved.
//

#import "AudioViewController.h"
#import "AudioRecordViewController.h"
#import "AudioPlaybackViewController.h"

@interface AudioViewController ()
@end

@implementation AudioViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.arrayTitle = @[@"Record", @"Playback"];
    self.arrayClass = @[[AudioRecordViewController class], [AudioPlaybackViewController class]];
}

@end
