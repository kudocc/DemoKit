//
//  AudioQueuePlayer.h
//  demo
//
//  Created by KudoCC on 16/8/17.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@protocol AudioQueuePlayerDelegate;
@interface AudioQueuePlayer : NSObject

- (instancetype)initWithDelegate:(id<AudioQueuePlayerDelegate>)delegate;

@property (nonatomic, weak, readonly) id<AudioQueuePlayerDelegate> delegate;

@property (nonatomic) BOOL playing;

- (BOOL)startPlay;
- (void)stopPlay;

- (BOOL)pause;
- (BOOL)resume;

@end

@protocol AudioQueuePlayerDelegate <NSObject>

- (AudioStreamBasicDescription)audioStreamBasicDescriptionOfPlayer:(AudioQueuePlayer *)player;

- (void)player:(AudioQueuePlayer *)player bufferByteSize:(UInt32 *)outBufferSize numPacketsToRead:(UInt32 *)outNumPacketsToRead;

// return writed number of packets
- (UInt32)player:(AudioQueuePlayer *)player primeBuffer:(AudioQueueBufferRef)buffer streamPacketDescList:(AudioStreamPacketDescription *)inPacketDesc numberOfPacketDescription:(UInt32)inNumPackets;

@end
