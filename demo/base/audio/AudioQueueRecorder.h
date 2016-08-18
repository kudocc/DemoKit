//
//  AudioQueueRecorder.h
//  demo
//
//  Created by KudoCC on 16/8/17.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@protocol AudioQueueRecorderDelegate;
@interface AudioQueueRecorder : NSObject

- (instancetype)initWithDelegate:(id<AudioQueueRecorderDelegate>)delegate;

@property (nonatomic, weak, readonly) id<AudioQueueRecorderDelegate> delegate;

@property (nonatomic) BOOL recording;

- (BOOL)startRecord;
- (void)stopRecord;

- (BOOL)pause;
- (BOOL)resume;

@end

@protocol AudioQueueRecorderDelegate <NSObject>

- (AudioStreamBasicDescription)audioStreamBasicDescriptionOfRecorder:(AudioQueueRecorder *)recorder;

- (void)recorder:(AudioQueueRecorder *)recorder recordBuffer:(AudioQueueBufferRef)buffer streamPacketDescList:(const AudioStreamPacketDescription *)inPacketDesc numberOfPacketDescription:(UInt32)inNumPackets;

@end
