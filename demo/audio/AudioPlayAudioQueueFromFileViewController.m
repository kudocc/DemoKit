//
//  AudioPlayAudioQueueFromFileViewController.m
//  demo
//
//  Created by KudoCC on 16/8/17.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "AudioPlayAudioQueueFromFileViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "NSString+CCKit.h"
#import "UIView+CCKit.h"
#import "AudioQueuePlayer.h"

@interface AudioPlayAudioQueueFromFileViewController () <AudioQueuePlayerDelegate> {
    NSString *_oldAudioSessionCategory;
    
    AudioStreamBasicDescription _basicDescription;
    UInt32 _bufferByteSize;
    UInt32 _numPacketRead;
    SInt64 _currentPacket;
}

@property (nonatomic) UIButton *buttonPlay;
@property (nonatomic) AudioQueuePlayer *player;

@property (nonatomic, assign) AudioFileID audioFileID;

@end

@implementation AudioPlayAudioQueueFromFileViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (_player.playing) {
        [_player stopPlay];
    }
    
    if (_oldAudioSessionCategory) {
        NSError *error = nil;
        [[AVAudioSession sharedInstance] setCategory:_oldAudioSessionCategory
                                               error:&error];
        if (error) {
            NSLog(@"set category: %@", [error localizedDescription]);
            return;
        }
    }
    
    // When passed in the flags parameter of the setActive:withOptions:error: instance method, indicates that when your audio session deactivates, other audio sessions that had been interrupted by your session can return to their active state
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setActive:NO
                                   withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation
                                         error:&error];
    if (error) {
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
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
    if (error) {
        NSLog(@"audioSession: %@", [error localizedDescription]);
        return;
    }
    error = nil;
    [[AVAudioSession sharedInstance] setActive:YES error:&error];
    if (error) {
        NSLog(@"audioSession: %@", [error localizedDescription]);
        return;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleInterruption:)
                                                 name:AVAudioSessionInterruptionNotification
                                               object:[AVAudioSession sharedInstance]];
    
    CGRect frame = CGRectMake(0.0, 100.0, self.view.bounds.size.width, 44.0);
    
    _buttonPlay = [UIButton buttonWithType:UIButtonTypeCustom];
    [_buttonPlay setTitle:@"Play" forState:UIControlStateNormal];
    [_buttonPlay setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_buttonPlay addTarget:self action:@selector(playButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    _buttonPlay.layer.borderColor = [UIColor blackColor].CGColor;
    _buttonPlay.layer.borderWidth = 1.0;
    _buttonPlay.frame = CGRectInset(frame, 10, 0);
    [self.view addSubview:_buttonPlay];
    
    // create audio queue file
    const char *pFilePath = [_audioPath UTF8String];
    CFURLRef audioFileURL = CFURLCreateFromFileSystemRepresentation(NULL, (const UInt8 *)pFilePath, strlen(pFilePath), false);
    OSStatus status = AudioFileOpenURL(audioFileURL, kAudioFileReadPermission, 0, &_audioFileID);
    if (status != noErr) {
        // kAudioFileUnspecifiedError 2003334207
        _audioFileID = NULL;
    }
    
    if (_audioFileID) {
        UInt32 dataFormatSize = sizeof (_basicDescription);
        status = AudioFileGetProperty(_audioFileID, kAudioFilePropertyDataFormat, &dataFormatSize, &_basicDescription);
        if (status == noErr) {
            UInt32 maxPacketSize;
            UInt32 propertySize = sizeof(maxPacketSize);
            AudioFileGetProperty(_audioFileID, kAudioFilePropertyPacketSizeUpperBound, &propertySize, &maxPacketSize);
            [self deriveBufferSize:maxPacketSize seconds:1 outBufferSize:&_bufferByteSize outNumPacketsToRead:&_numPacketRead];
            
            _player = [[AudioQueuePlayer alloc] initWithDelegate:self];
        }
    }
}

- (void)deriveBufferSize:(UInt32)maxPacketSize seconds:(Float64)seconds outBufferSize:(UInt32 *)outBufferSize outNumPacketsToRead:(UInt32 *)outNumPacketsToRead {
    static const int maxBufferSize = 0x50000;
    static const int minBufferSize = 0x4000;
    
    if (_basicDescription.mFramesPerPacket != 0) {
        Float64 numPacketsForTime = _basicDescription.mSampleRate / _basicDescription.mFramesPerPacket * seconds;
        *outBufferSize = numPacketsForTime * maxPacketSize;
    } else {
        *outBufferSize = maxBufferSize > maxPacketSize ? maxBufferSize : maxPacketSize;
    }
    
    if (*outBufferSize > maxBufferSize &&
        *outBufferSize > maxPacketSize)
        *outBufferSize = maxBufferSize;
    else {
        if (*outBufferSize < minBufferSize)
            *outBufferSize = minBufferSize;
    }
    *outNumPacketsToRead = *outBufferSize / maxPacketSize;
}

- (void)playButtonPressed:(UIButton *)button {
    if (_player.playing) {
        [_player pause];
        self.title = @"Paused";
        [_buttonPlay setTitle:@"Play" forState:UIControlStateNormal];
    } else {
        if ([_player startPlay]) {
            self.title = @"Playing";
            [_buttonPlay setTitle:@"Pause" forState:UIControlStateNormal];
        } else {
            self.title = @"Play error";
            [_buttonPlay setTitle:@"Play" forState:UIControlStateNormal];
            NSLog(@"Play error");
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

#pragma mark - AudioQueuePlayerDelegate

- (AudioStreamBasicDescription)audioStreamBasicDescriptionOfPlayer:(AudioQueuePlayer *)player {
    return _basicDescription;
}

- (void)player:(AudioQueuePlayer *)player bufferByteSize:(UInt32 *)outBufferSize numPacketsToRead:(UInt32 *)outNumPacketsToRead {
    *outBufferSize = _bufferByteSize;
    *outNumPacketsToRead = _numPacketRead;
}

// return writed number of packets
- (UInt32)player:(AudioQueuePlayer *)player
     primeBuffer:(AudioQueueBufferRef)buffer
streamPacketDescList:(AudioStreamPacketDescription *)inPacketDesc numberOfPacketDescription:(UInt32)inNumPackets {
    
    UInt32 numBytesReadFromFile = buffer->mAudioDataBytesCapacity;
    UInt32 numPackets = _numPacketRead;
    
    OSStatus status = AudioFileReadPackets(_audioFileID, false, &numBytesReadFromFile, inPacketDesc, _currentPacket, &numPackets, buffer->mAudioData);
    if (status != noErr) {
        NSLog(@"read packets error:%d", status);
        return 0;
    }
    _currentPacket += numPackets;
    return numBytesReadFromFile;
}

@end