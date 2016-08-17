//
//  AudioQueueRecorder.m
//  demo
//
//  Created by KudoCC on 16/8/17.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "AudioQueueRecorder.h"

#define kNumberBuffers 3

@interface AudioQueueRecorder () {
    @public
    AudioStreamBasicDescription _basicDescription;
    AudioQueueRef _audioQueue;
    AudioQueueBufferRef _audioQueueBuffer[kNumberBuffers];
    UInt32 _bufferByteSize;
}

@end

static void HandleInputBuffer (void *aqData,
                               AudioQueueRef inAQ,
                               AudioQueueBufferRef inBuffer,
                               const AudioTimeStamp *inStartTime,
                               UInt32 inNumPackets,
                               const AudioStreamPacketDescription *inPacketDesc) {
    AudioQueueRecorder *sself = (__bridge AudioQueueRecorder *)aqData;
    
    // call delegate
    [sself.delegate recordBuffer:inBuffer streamPacketDescriptionList:inPacketDesc numberOfPacketDescription:inNumPackets];
    
    // enqueue buffer
    AudioQueueEnqueueBuffer(sself->_audioQueue, inBuffer, 0, NULL);
}

@implementation AudioQueueRecorder

- (UInt32)deriveAudioBufferWithSeconds:(Float64)seconds {
    static const int maxBufferSize = 0x50000;
    
    int maxPacketSize = _basicDescription.mBytesPerPacket;
    if (maxPacketSize == 0) {
        UInt32 maxVBRPacketSize = sizeof(maxPacketSize);
        AudioQueueGetProperty (_audioQueue,
                               kAudioQueueProperty_MaximumOutputPacketSize,
                               &maxPacketSize,
                               &maxVBRPacketSize);
    }
    
    Float64 numBytesForTime = _basicDescription.mSampleRate * maxPacketSize * seconds;
    return numBytesForTime < maxBufferSize ? numBytesForTime : maxBufferSize;
}

- (instancetype)initWithDelegate:(id<AudioQueueRecorderDelegate>)delegate {
    self = [super init];
    if (self) {
        _delegate = delegate;
        
        _audioQueue = NULL;
        for (NSInteger i = 0; i < kNumberBuffers; ++i) {
            _audioQueueBuffer[i] = NULL;
        }
        
        // set up `AudioStreamBasicDescription`
        _basicDescription = [_delegate audioStreamBasicDescription];
    }
    return self;
}

- (void)dealloc {
    if (_audioQueue) {
        AudioQueueDispose(_audioQueue, YES);
        _audioQueue = NULL;
    }
}

- (BOOL)startRecord {
    // set up `AudioStreamBasicDescription`
    _basicDescription = [_delegate audioStreamBasicDescription];
    
    OSStatus status;
    // create a record audio queue
    status = AudioQueueNewInput(&_basicDescription, HandleInputBuffer, (__bridge void *)self,
                                CFRunLoopGetMain(), kCFRunLoopCommonModes, 0, &_audioQueue);
    if (status != noErr) {
        // kAudioFormatUnsupportedDataFormatError is 1718449215
        goto Failed_label;
    }
    
    UInt32 basicDescriptionSize = sizeof(_basicDescription);
    status = AudioQueueGetProperty(_audioQueue, kAudioQueueProperty_StreamDescription, &_basicDescription, &basicDescriptionSize);
    if (status != noErr) {
        goto Failed_label;
    }
    
    _bufferByteSize = [self deriveAudioBufferWithSeconds:0.5];

    for (NSInteger i = 0; i < kNumberBuffers; ++i) {
        status = AudioQueueAllocateBuffer(_audioQueue, _bufferByteSize, &_audioQueueBuffer[i]);
        if (status != noErr) {
            goto Failed_label;
        }
        status = AudioQueueEnqueueBuffer(_audioQueue, _audioQueueBuffer[i], 0, NULL);
        if (status != noErr) {
            goto Failed_label;
        }
    }
    
    // The second parameter
    // The time at which the audio queue should start.
    // To specify a start time relative to the timeline of the associated audio device, use the mSampleTime field of the AudioTimeStamp structure. Use NULL to indicate that the audio queue should start as soon as possible.
    status = AudioQueueStart(_audioQueue, NULL);
    if (status != noErr) {
        goto Failed_label;
    }
    
    _recording = YES;
    
    return YES;
    
Failed_label:
    if (_audioQueue) {
        AudioQueueDispose(_audioQueue, true);
        _audioQueue = NULL;
    }
    for (NSInteger i = 0; i < kNumberBuffers; ++i) {
        _audioQueueBuffer[i] = NULL;
    }
    
    return NO;
}

- (void)stopRecord {
    if (_audioQueue) {
        AudioQueueDispose(_audioQueue, false);
        _audioQueue = NULL;
    }
    
    _recording = NO;
}

- (BOOL)pause {
    if (_audioQueue) {
        OSStatus status = AudioQueuePause(_audioQueue);
        if (status == noErr) {
            _recording = NO;
        }
        return status == noErr;
    }
    return NO;
}

- (BOOL)resume {
    if (_audioQueue) {
        OSStatus status = AudioQueueStart(_audioQueue, NULL);
        if (status == noErr) {
            _recording = YES;
        }
        return status != noErr;
    }
    return NO;
}

@end
