//
//  AudioQueueRecorder.h
//  demo
//
//  Created by KudoCC on 16/8/17.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

/**
 AAC-HE recorder
 */

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

- (AudioStreamBasicDescription)audioStreamBasicDescription;

- (void)recordBuffer:(AudioQueueBufferRef)buffer streamPacketDescriptionList:(const AudioStreamPacketDescription *)inPacketDesc numberOfPacketDescription:(UInt32)inNumPackets;

@end
