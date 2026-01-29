// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "./include/video_player_avfoundation/FVPAVFactory.h"

@import AVFoundation;

@interface FVPDefaultAVPlayerItemVideoOutput : NSObject <FVPPixelBufferSource>
@property(nonatomic, readwrite) AVPlayerItemVideoOutput *videoOutput;
@end

@implementation FVPDefaultAVPlayerItemVideoOutput
- (instancetype)initWithPixelBufferAttributes:(NSDictionary<NSString *, id> *)attributes {
  self = [super init];
  if (self) {
    _videoOutput = [[AVPlayerItemVideoOutput alloc] initWithPixelBufferAttributes:attributes];
  }
  return self;
}

- (CMTime)itemTimeForHostTime:(CFTimeInterval)hostTimeInSeconds {
  return [_videoOutput itemTimeForHostTime:hostTimeInSeconds];
}

- (BOOL)hasNewPixelBufferForItemTime:(CMTime)itemTime {
  return [_videoOutput hasNewPixelBufferForItemTime:itemTime];
}

- (nullable CVPixelBufferRef)copyPixelBufferForItemTime:(CMTime)itemTime
                                     itemTimeForDisplay:(nullable CMTime *)outItemTimeForDisplay
    CF_RETURNS_RETAINED {
  return [_videoOutput copyPixelBufferForItemTime:itemTime
                               itemTimeForDisplay:outItemTimeForDisplay];
}
@end

#pragma mark -

#if TARGET_OS_IOS
@interface FVPDefaultAVAudioSession : NSObject <FVPAVAudioSession>
@end

@implementation FVPDefaultAVAudioSession
- (AVAudioSessionCategory)category {
  return AVAudioSession.sharedInstance.category;
}

- (AVAudioSessionCategoryOptions)categoryOptions {
  return AVAudioSession.sharedInstance.categoryOptions;
}

- (BOOL)setCategory:(AVAudioSessionCategory)category
        withOptions:(AVAudioSessionCategoryOptions)options
              error:(NSError **)outError {
  return [AVAudioSession.sharedInstance setCategory:category withOptions:options error:outError];
}
@end
#endif

#pragma mark -

@implementation FVPDefaultAVFactory
- (AVPlayer *)playerWithPlayerItem:(AVPlayerItem *)playerItem {
  return [AVPlayer playerWithPlayerItem:playerItem];
}

- (NSObject<FVPPixelBufferSource> *)videoOutputWithPixelBufferAttributes:
    (NSDictionary<NSString *, id> *)attributes {
  return [[FVPDefaultAVPlayerItemVideoOutput alloc] initWithPixelBufferAttributes:attributes];
}

#if TARGET_OS_IOS
- (NSObject<FVPAVAudioSession> *)sharedAudioSession {
  return [[FVPDefaultAVAudioSession alloc] init];
}
#endif
@end
