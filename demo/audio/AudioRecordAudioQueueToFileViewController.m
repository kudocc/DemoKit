//
//  AudioRecordAudioQueueToFileViewController.m
//  demo
//
//  Created by KudoCC on 16/8/17.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "AudioRecordAudioQueueToFileViewController.h"
#import "AudioQueueRecorder.h"
#import <AVFoundation/AVFoundation.h>
#import "NSString+CCKit.h"

@interface AudioRecordAudioQueueToFileViewController () <AudioQueueRecorderDelegate> {
    NSString *_oldAudioSessionCategory;
    
    AudioStreamBasicDescription _basicDescription;
    SInt64 _currentPacket;
}

@property (nonatomic) UIButton *buttonRecord;

@property (nonatomic) AudioQueueRecorder *recorder;
@property (nonatomic, assign) AudioFileID audioFileID;

@end

@implementation AudioRecordAudioQueueToFileViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (_recorder.recording) {
        [_recorder stopRecord];
    }
    
    if (_oldAudioSessionCategory) {
        NSError *error = nil;
        [[AVAudioSession sharedInstance] setCategory:_oldAudioSessionCategory
                                               error:&error];
        if (error){
            NSLog(@"set category: %@", [error localizedDescription]);
            return;
        }
    }
    
    // When passed in the flags parameter of the setActive:withOptions:error: instance method, indicates that when your audio session deactivates, other audio sessions that had been interrupted by your session can return to their active state
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setActive:NO
                                   withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation
                                         error:&error];
    if (error){
        NSLog(@"deactive audio session: %@", [error localizedDescription]);
    }
    
    if (_audioFileID) {
        AudioFileClose(_audioFileID);
    }
}

- (void)initView {
    
    // set up audio session
    
    _oldAudioSessionCategory = [AVAudioSession sharedInstance].category;
    NSLog(@"old audio session category:%@", _oldAudioSessionCategory);
    
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord
                                           error:&error];
    if (error){
        NSLog(@"audioSession: %@", [error localizedDescription]);
        return;
    }
    error = nil;
    [[AVAudioSession sharedInstance] setActive:YES error:&error];
    if (error){
        NSLog(@"audioSession: %@", [error localizedDescription]);
        return;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleInterruption:)
                                                 name:AVAudioSessionInterruptionNotification
                                               object:[AVAudioSession sharedInstance]];
    
    CGRect frame = CGRectMake(0.0, 100.0, self.view.bounds.size.width, 44.0);
    
    _buttonRecord = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:_buttonRecord];
    [_buttonRecord setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_buttonRecord setTitle:@"Start" forState:UIControlStateNormal];
    [_buttonRecord addTarget:self action:@selector(startRecord:) forControlEvents:UIControlEventTouchUpInside];
    _buttonRecord.layer.borderColor = [UIColor blackColor].CGColor;
    _buttonRecord.layer.borderWidth = 1.0;
    _buttonRecord.frame = CGRectInset(frame, 10.0, 0.0);
    
    
    // set up `AudioStreamBasicDescription`
    _basicDescription.mSampleRate = 44100.0;// 44.1HZ
    _basicDescription.mFormatID = kAudioFormatMPEG4AAC_HE;
    _basicDescription.mFormatFlags = 0;
    // The number of bytes in a packet of audio data. To indicate variable packet size, set this field to 0. For a format that uses variable packet size, specify the size of each packet using an AudioStreamPacketDescription structure.
    _basicDescription.mBytesPerPacket = 0;
    // The number of frames in a packet of audio data. For uncompressed audio, the value is 1. For variable bit-rate formats, the value is a larger fixed number, such as 1024 for AAC. For formats with a variable number of frames per packet, such as Ogg Vorbis, set this field to 0.
    _basicDescription.mFramesPerPacket = 2048;// must be 2048 for AAC-HE
    _basicDescription.mChannelsPerFrame = 2;
    // The number of bytes from the start of one frame to the start of the next frame in an audio buffer. Set this field to 0 for compressed formats.
    // For an audio buffer containing interleaved data for n channels, with each sample of type AudioSampleType, calculate the value for this field as follows:
    //    mBytesPerFrame = n * sizeof (AudioSampleType);
    // For an audio buffer containing noninterleaved (monophonic) data, also using AudioSampleType samples, calculate the value for this field as follows:
    //    mBytesPerFrame = sizeof (AudioSampleType);
    _basicDescription.mBytesPerFrame = 0;
    // The number of bits for one audio sample. For example, for linear PCM audio using the kAudioFormatFlagsCanonical format flags, calculate the value for this field as follows:
    // mBitsPerChannel = 8 * sizeof (AudioSampleType);
    // Set this field to 0 for compressed formats.
    _basicDescription.mBitsPerChannel = 0;
    _basicDescription.mReserved = 0;
    
    // create audio queue file
    NSDate *current = [NSDate date];
    NSString *fileName = [NSString stringWithFormat:@"%ld", (long)[current timeIntervalSince1970]];
    NSString *filePath = [[NSString cc_documentPath] stringByAppendingPathComponent:fileName];
    const char *pFilePath = [filePath UTF8String];
    CFURLRef audioFileURL = CFURLCreateFromFileSystemRepresentation(NULL, (const UInt8 *)pFilePath, strlen(pFilePath), false);
    OSStatus status = AudioFileCreateWithURL(audioFileURL, kAudioFileCAFType, &_basicDescription, kAudioFileFlags_EraseFile, &_audioFileID);
    if (status != noErr) {
        _audioFileID = NULL;
    }
    
    _recorder = [[AudioQueueRecorder alloc] initWithDelegate:self];
}

- (void)startRecord:(id)obj {
    if (!_recorder.recording) {
        BOOL res = [_recorder startRecord];
        if (res) {
            [_buttonRecord setTitle:@"Pause" forState:UIControlStateNormal];
            self.title = @"Recording";
        } else {
            self.title = @"Recording Error";
        }
    } else {
        if ([_recorder pause]) {
            [_buttonRecord setTitle:@"Start" forState:UIControlStateNormal];
            self.title = @"Record paused";
        } else {
            self.title = @"Paused error";
        }
    }
}

#pragma mark -

- (void)handleInterruption:(NSNotification *)notification {
    AVAudioSessionInterruptionType type = [notification.userInfo[AVAudioSessionInterruptionTypeKey] unsignedIntegerValue];
    if (type == AVAudioSessionInterruptionTypeBegan) {
        self.title = @"begin interruption";
        NSLog(@"begin interruption");
    } else {
        self.title = @"end interruption";
        NSLog(@"end interruption");
    }
}

#pragma mark - AudioQueueRecorderDelegate

- (AudioStreamBasicDescription)audioStreamBasicDescriptionOfRecorder:(AudioQueueRecorder *)recorder {
    return _basicDescription;
}

- (void)recorder:(AudioQueueRecorder *)recorder recordBuffer:(AudioQueueBufferRef)buffer streamPacketDescList:(const AudioStreamPacketDescription *)inPacketDesc numberOfPacketDescription:(UInt32)inNumPackets {
    if (inNumPackets == 0 && _basicDescription.mBytesPerPacket != 0)
        inNumPackets = buffer->mAudioDataByteSize / _basicDescription.mBytesPerPacket;
    
    if (_audioFileID) {
        OSStatus status = AudioFileWritePackets(_audioFileID,
                                                false,
                                                buffer->mAudioDataByteSize,
                                                inPacketDesc, _currentPacket,
                                                &inNumPackets,
                                                buffer->mAudioData);
        if (status != noErr) {
            NSLog(@"fail write to file with error:%d", status);
            return;
        }
        NSLog(@"success write audio file packet %d", inNumPackets);
        _currentPacket += inNumPackets;
    }
}

@end
