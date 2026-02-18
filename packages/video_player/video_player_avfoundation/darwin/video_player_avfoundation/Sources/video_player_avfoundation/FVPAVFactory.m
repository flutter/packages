// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "./include/video_player_avfoundation/FVPAVFactory.h"

@import AVFoundation;

@interface FVPDefaultAVAsset : NSObject <FVPAVAsset>
@property(nonatomic, readwrite) AVAsset *asset;
@end

@implementation FVPDefaultAVAsset
- (instancetype)initWithAsset:(AVAsset *)asset {
  self = [super init];
  if (self) {
    _asset = asset;
  }
  return self;
}

- (CMTime)duration {
  return self.asset.duration;
}

- (AVKeyValueStatus)statusOfValueForKey:(NSString *)key
                                  error:(NSError *_Nullable *_Nullable)outError {
  return [self.asset statusOfValueForKey:key error:outError];
}

- (void)loadValuesAsynchronouslyForKeys:(NSArray<NSString *> *)keys
                      completionHandler:(nullable void (^NS_SWIFT_SENDABLE)(void))handler {
  [self.asset loadValuesAsynchronouslyForKeys:keys completionHandler:handler];
}

- (NSArray<AVAssetTrack *> *)tracksWithMediaType:(NSString *)mediaType {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
  return [self.asset tracksWithMediaType:mediaType];
#pragma clang diagnostic pop
}

- (void)loadTracksWithMediaType:(AVMediaType)mediaType
              completionHandler:(void (^NS_SWIFT_SENDABLE)(NSArray<AVAssetTrack *> *_Nullable,
                                                           NSError *_Nullable))completionHandler
    API_AVAILABLE(macos(12.0), ios(15.0)) {
  [self.asset loadTracksWithMediaType:mediaType completionHandler:completionHandler];
}

@end

#pragma mark -

@interface FVPDefaultAVPlayerItem : NSObject <FVPAVPlayerItem>
@property(nonatomic, readwrite) AVPlayerItem *playerItem;
@end

@implementation FVPDefaultAVPlayerItem
- (instancetype)initWithPlayerItem:(AVPlayerItem *)playerItem {
  self = [super init];
  if (self) {
    _playerItem = playerItem;
  }
  return self;
}

- (NSObject<FVPAVAsset> *)asset {
  return [[FVPDefaultAVAsset alloc] initWithAsset:self.playerItem.asset];
}

- (AVVideoComposition *)videoComposition {
  return self.playerItem.videoComposition;
}

- (void)setVideoComposition:(AVVideoComposition *)videoComposition {
  self.playerItem.videoComposition = videoComposition;
}
@end

#pragma mark -

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
  return [self.videoOutput itemTimeForHostTime:hostTimeInSeconds];
}

- (BOOL)hasNewPixelBufferForItemTime:(CMTime)itemTime {
  return [self.videoOutput hasNewPixelBufferForItemTime:itemTime];
}

- (nullable CVPixelBufferRef)copyPixelBufferForItemTime:(CMTime)itemTime
                                     itemTimeForDisplay:(nullable CMTime *)outItemTimeForDisplay
    CF_RETURNS_RETAINED {
  return [self.videoOutput copyPixelBufferForItemTime:itemTime
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
- (NSObject<FVPAVAsset> *)URLAssetWithURL:(NSURL *)URL
                                  options:(nullable NSDictionary<NSString *, id> *)options {
  return [[FVPDefaultAVAsset alloc] initWithAsset:[AVURLAsset URLAssetWithURL:URL options:options]];
}

- (NSObject<FVPAVPlayerItem> *)playerItemWithAsset:(NSObject<FVPAVAsset> *)asset {
  // The default factory always vends FVPDefault* implementations, so it is safe to cast back.
  return [[FVPDefaultAVPlayerItem alloc]
      initWithPlayerItem:[AVPlayerItem playerItemWithAsset:((FVPDefaultAVAsset *)asset).asset]];
}

- (AVPlayer *)playerWithPlayerItem:(NSObject<FVPAVPlayerItem> *)playerItem {
  // The default factory always vends FVPDefault* implementations, so it is safe to cast back.
  return [AVPlayer playerWithPlayerItem:((FVPDefaultAVPlayerItem *)playerItem).playerItem];
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
