//
//  AudioQueuePlayer.m
//  demo
//
//  Created by KudoCC on 16/8/17.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "AudioQueuePlayer.h"

#define kNumberBuffers 3

@interface AudioQueuePlayer () {
@public
    AudioStreamBasicDescription _basicDescription;
    AudioQueueRef _audioQueue;
    AudioQueueBufferRef _audioQueueBuffer[kNumberBuffers];
    UInt32 _bufferByteSize;
    UInt32 _numPacketRead;
    AudioStreamPacketDescription *_packetDescription;
    
    BOOL _finished;
}

- (void)stopImmediately:(BOOL)immediate;

@end

static void HandleOutputBuffer (void *aqData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer) {
    AudioQueuePlayer *player = (__bridge AudioQueuePlayer *)aqData;
    if (player->_finished) {
        return;
    }
    
    UInt32 readPacketNumber = 0;
    UInt32 readByteNumber = 0;
    [player.delegate audioQueuePlayer:player
                          primeBuffer:inBuffer
              streamPacketDescription:player->_packetDescription
                    descriptionNumber:player->_numPacketRead
                     readPacketNumber:&readPacketNumber
                       readByteNumber:&readByteNumber];
#ifdef DEBUG
    NSLog(@"read %@ packets, %@ bytes from file", @(readPacketNumber), @(readByteNumber));
#endif
    
    if (readPacketNumber > 0) {
        inBuffer->mAudioDataByteSize = readByteNumber;
        OSStatus status = AudioQueueEnqueueBuffer(inAQ, inBuffer, (player->_packetDescription ? readPacketNumber : 0), player->_packetDescription);
        if (status != noErr) {
#ifdef DEBUG
            NSLog(@"AudioQueueEnqueueBuffer error:%d", status);
#endif
        }
    } else {
#ifdef DEBUG
        NSLog(@"AudioQueueStop");
#endif
        [player stopImmediately:NO];
    }
}

@implementation AudioQueuePlayer

- (instancetype)initWithDelegate:(id<AudioQueuePlayerDelegate>)delegate {
    self = [super init];
    if (self) {
        _finished = YES;
        _delegate = delegate;
        
        _audioQueue = NULL;
        for (NSInteger i = 0; i < kNumberBuffers; ++i) {
            _audioQueueBuffer[i] = NULL;
        }
        
        // set up `AudioStreamBasicDescription`
        _basicDescription = [_delegate audioStreamBasicDescriptionOfPlayer:self];
        
        // create a playback audio queue
        OSStatus status = AudioQueueNewOutput(&_basicDescription, HandleOutputBuffer, (__bridge void *)self,
                                              CFRunLoopGetMain(), kCFRunLoopCommonModes, 0, &_audioQueue);
        if (status != noErr) {
            // kAudioFormatUnsupportedDataFormatError is 1718449215
            _audioQueue = NULL;
            
            // Does it cause memory leak?
            return nil;
        }
        
        // get max buffer size and packet to read
        [_delegate audioQueuePlayer:self getBufferByteSize:&_bufferByteSize packetToReadNumber:&_numPacketRead];
        
        bool isFormatVBR = (_basicDescription.mBytesPerPacket == 0 ||
                            _basicDescription.mFramesPerPacket == 0);
        
        if (isFormatVBR) {
            _packetDescription = (AudioStreamPacketDescription*)malloc(_numPacketRead * sizeof(AudioStreamPacketDescription));
        } else {
            _packetDescription = NULL;
        }
        
        status = noErr;
        for (NSInteger i = 0; i < kNumberBuffers; ++i) {
            status = AudioQueueAllocateBuffer(_audioQueue, _bufferByteSize, &_audioQueueBuffer[i]);
            if (status != noErr) {
                break;
            }
        }
        
        if (status != noErr) {
            AudioQueueDispose(_audioQueue, false);
            return nil;
        }
    }
    return self;
}

- (void)dealloc {
    if (_audioQueue) {
        // if audio queue doesn't finish, stop it
        if (!_finished) {
            AudioQueueStop(_audioQueue, true);
        }
        AudioQueueDispose(_audioQueue, true);
        
        _audioQueue = NULL;
    }
    
    if (_packetDescription) {
        free(_packetDescription);
        _packetDescription = NULL;
    }
}

- (BOOL)play {
    
    // already playing
    if (_playing) {
        return YES;
    }
    
    // now audio queue is paused, resume play
    if (!_finished) {
        return [self resume];
    }
    
    _finished = NO;
    for (NSInteger i = 0; i < kNumberBuffers; ++i) {
        // prime audio
        HandleOutputBuffer((__bridge void *)self, _audioQueue, _audioQueueBuffer[i]);
    }
    
    OSStatus status = noErr;
    
    Float32 gain = 1.0;
    // Optionally, allow user to override gain setting here
    status = AudioQueueSetParameter(_audioQueue, kAudioQueueParam_Volume, gain);
    if (status != noErr) {
#ifdef DEBUG
        NSLog(@"Set Audio Queue Volume error:%d", status);
#endif
    }
    
    // The second parameter
    // The time at which the audio queue should start.
    // To specify a start time relative to the timeline of the associated audio device, use the mSampleTime field of the AudioTimeStamp structure. Use NULL to indicate that the audio queue should start as soon as possible.
    status = AudioQueueStart(_audioQueue, NULL);
    if (status != noErr) {
#ifdef DEBUG
        NSLog(@"AudioQueueStart %d", status);
#endif
        // -50 其中一个原因查看AVAudioSession的category是否正确设置
        goto Failed_label;
    }
    
    _playing = YES;
    _finished = NO;
    
    return YES;
    
Failed_label:
    _finished = YES;
    _playing = NO;
    
    if (_audioQueue) {
        AudioQueueDispose(_audioQueue, false);
        _audioQueue = NULL;
    }
    for (NSInteger i = 0; i < kNumberBuffers; ++i) {
        _audioQueueBuffer[i] = NULL;
    }
    
    if (_packetDescription) {
        free(_packetDescription);
        _packetDescription = NULL;
    }
    
    return NO;
}

- (void)stop {
    [self stopImmediately:YES];
}

- (void)stopImmediately:(BOOL)immediate {
    // aq is already finished
    if (_finished) {
        return;
    }
    
    if (_audioQueue) {
        Boolean imme = immediate ? true : false;
        AudioQueueStop(_audioQueue, imme);
    }
    _playing = NO;
    _finished = YES;
    
    [_delegate audioQueuePlayerDidFinishPlay:self];
}

- (BOOL)pause {
    // currently aq is not playing
    if (!_playing) {
        return YES;
    }
    
    if (_audioQueue) {
        OSStatus status = AudioQueuePause(_audioQueue);
        NSLog(@"call pause");
        if (status == noErr) {
            _playing = NO;
        }
        return status == noErr;
    }
    return NO;
}

- (BOOL)resume {
    // currently aq is playing
    if (_playing) {
        return YES;
    }
    
    if (_audioQueue) {
        OSStatus status = AudioQueueStart(_audioQueue, NULL);
        if (status == noErr) {
            _playing = YES;
        }
        return status != noErr;
    }
    return NO;
}

@end
