//
//  AudioRecordViewController.m
//  audio
//
//  Created by KudoCC on 15/9/21.
//  Copyright (c) 2015年 KudoCC. All rights reserved.
//

#import "AudioRecordViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "NSString+CCKit.h"

@interface AudioRecordViewController ()

@property (nonatomic, strong) AVAudioRecorder *recorder;

@end

@implementation AudioRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSDate *current = [NSDate date];
    NSString *fileName = [NSString stringWithFormat:@"%ld", (long)[current timeIntervalSince1970]];
    NSString *filePath = [[NSString cc_documentPath] stringByAppendingPathComponent:fileName];
    NSDictionary *setting = @{AVFormatIDKey:@(kAudioFormatAppleIMA4), AVSampleRateKey:@(44100.0), AVNumberOfChannelsKey:@2};
    NSError *error = nil;
    _recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:filePath] settings:setting error:nil];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
    
    CGRect frame = CGRectMake(0.0, 100.0, self.view.bounds.size.width, 44.0);
    
    UIButton *buttonStartRecord = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:buttonStartRecord];
    [buttonStartRecord setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [buttonStartRecord setTitle:@"Start" forState:UIControlStateNormal];
    [buttonStartRecord addTarget:self action:@selector(startRecord:) forControlEvents:UIControlEventTouchUpInside];
    buttonStartRecord.frame = CGRectInset(frame, 10.0, 0.0);
    
    UIButton *buttonStopRecord = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:buttonStopRecord];
    [buttonStopRecord setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [buttonStopRecord setTitle:@"Stop" forState:UIControlStateNormal];
    [buttonStopRecord addTarget:self action:@selector(stopRecord:) forControlEvents:UIControlEventTouchUpInside];
    buttonStopRecord.frame = CGRectOffset(buttonStartRecord.frame, 0.0, 88.0);
}

- (void)startRecord:(id)obj {
    BOOL res = [_recorder record];
    if (res) {
        self.title = @"Recording";
    } else {
        self.title = @"Recording Error";
    }
}

- (void)stopRecord:(id)obj {
    [_recorder stop];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)pause {
    if ([_recorder isRecording]) {
        [_recorder pause];
    } else {
        [_recorder record];
    }
}

@end
