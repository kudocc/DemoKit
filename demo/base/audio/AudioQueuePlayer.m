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
}

@end

static void HandleOutputBuffer (void *aqData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer) {
    AudioQueuePlayer *player = (__bridge AudioQueuePlayer *)aqData;
    
    UInt32 numPackets = [player.delegate player:player primeBuffer:inBuffer
                           streamPacketDescList:player->_packetDescription
                      numberOfPacketDescription:player->_numPacketRead];
    
    if (numPackets > 0) {
        inBuffer->mAudioDataByteSize = numPackets;
        OSStatus status = AudioQueueEnqueueBuffer(inAQ, inBuffer, (player->_packetDescription ? numPackets : 0), player->_packetDescription);
        if (status != noErr) {
            NSLog(@"AudioQueueEnqueueBuffer error:%d", status);
        } else {
            NSLog(@"Success Enqueue");
        }
    } else {
//        NSLog(@"AudioQueueStop");
//        AudioQueueStop(inAQ, false);
    }
}

@implementation AudioQueuePlayer

- (instancetype)initWithDelegate:(id<AudioQueuePlayerDelegate>)delegate {
    self = [super init];
    if (self) {
        _delegate = delegate;
        
        _audioQueue = NULL;
        for (NSInteger i = 0; i < kNumberBuffers; ++i) {
            _audioQueueBuffer[i] = NULL;
        }
        
        // set up `AudioStreamBasicDescription`
        _basicDescription = [_delegate audioStreamBasicDescriptionOfPlayer:self];
        
        // get max buffer size and packet to read
        [_delegate player:self bufferByteSize:&_bufferByteSize numPacketsToRead:&_numPacketRead];
    }
    return self;
}

- (void)dealloc {
    if (_audioQueue) {
        AudioQueueDispose(_audioQueue, YES);
        _audioQueue = NULL;
    }
    
    if (_packetDescription) {
        free(_packetDescription);
        _packetDescription = NULL;
    }
}

- (BOOL)startPlay {
    OSStatus status;
    // create a record audio queue
    status = AudioQueueNewOutput(&_basicDescription, HandleOutputBuffer, (__bridge void *)self,
                                NULL, kCFRunLoopCommonModes, 0, &_audioQueue);
    if (status != noErr) {
        // kAudioFormatUnsupportedDataFormatError is 1718449215
        goto Failed_label;
    }
    
    bool isFormatVBR = (_basicDescription.mBytesPerPacket == 0 ||
                        _basicDescription.mFramesPerPacket == 0);
    
    if (isFormatVBR) {
        _packetDescription = (AudioStreamPacketDescription*)malloc(_numPacketRead * sizeof(AudioStreamPacketDescription));
    } else {
        _packetDescription = NULL;
    }
    
    for (NSInteger i = 0; i < kNumberBuffers; ++i) {
        status = AudioQueueAllocateBuffer(_audioQueue, _bufferByteSize, &_audioQueueBuffer[i]);
        if (status != noErr) {
            goto Failed_label;
        }
        // prime audio
        HandleOutputBuffer((__bridge void *)self, _audioQueue, _audioQueueBuffer[i]);
    }
    
    Float32 gain = 1.0;
    // Optionally, allow user to override gain setting here
    status = AudioQueueSetParameter(_audioQueue, kAudioQueueParam_Volume, gain);
    if (status != noErr) {
        // -50 其中一个原因查看AVAudioSession的category是否正确设置
        goto Failed_label;
    }
    
//    UInt32 outNumberOfFramesPrepared;
//    status = AudioQueuePrime(_audioQueue, 0, &outNumberOfFramesPrepared);
//    if (status != noErr) {
//        goto Failed_label;
//    }
    
    // The second parameter
    // The time at which the audio queue should start.
    // To specify a start time relative to the timeline of the associated audio device, use the mSampleTime field of the AudioTimeStamp structure. Use NULL to indicate that the audio queue should start as soon as possible.
    status = AudioQueueStart(_audioQueue, NULL);
    if (status != noErr) {
        NSLog(@"AudioQueueStart %d", status);
        // -50 其中一个原因查看AVAudioSession的category是否正确设置
        goto Failed_label;
    }
    
    _playing = YES;
    
    return YES;
    
Failed_label:
    if (_audioQueue) {
        AudioQueueDispose(_audioQueue, true);
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

- (void)stopPlay {
    if (_audioQueue) {
        
        AudioQueueStop(_audioQueue, true);
        
        AudioQueueDispose(_audioQueue, true);
        
        _audioQueue = NULL;
    }
    
    _playing = NO;
}

- (BOOL)pause {
    if (_audioQueue) {
        OSStatus status = AudioQueuePause(_audioQueue);
        if (status == noErr) {
            _playing = NO;
        }
        return status == noErr;
    }
    return NO;
}

- (BOOL)resume {
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
