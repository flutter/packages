// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import AVFoundation;

NS_ASSUME_NONNULL_BEGIN

/// Protocol for abstracting access to an AVPlayerItemVideoOutput, to enable unit testing.
@protocol FVPPixelBufferSource <NSObject>
@required
/// The underlying AVFoundation object.
///
/// This can't be fully abstracted away because it's passed to other AVFoundation calls. Plugin
/// code should only use this to pass into AVFoundation; other calls should be made on the
/// protocol.
@property(nonatomic, readonly) AVPlayerItemVideoOutput *videoOutput;

/// Wraps the underlying videoOutput's itemTimeForHostTime: method.
- (CMTime)itemTimeForHostTime:(CFTimeInterval)hostTimeInSeconds;

/// Wraps the underlying videoOutput's hasNewPixelBufferForItemTime: method.
- (BOOL)hasNewPixelBufferForItemTime:(CMTime)itemTime;

/// Wraps the underlying videoOutput's copyPixelBufferForItemTime:itemTimeForDisplay: method.
- (nullable CVPixelBufferRef)copyPixelBufferForItemTime:(CMTime)itemTime
                                     itemTimeForDisplay:(nullable CMTime *)outItemTimeForDisplay
    CF_RETURNS_RETAINED;

@end

@protocol FVPAVAsset <NSObject>
@required
/// Wraps the underlying asset's duration property.
@property(nonatomic, readonly) CMTime duration;

/// Wraps the underlying asset's statusOfValueForKey:error: method.
- (AVKeyValueStatus)statusOfValueForKey:(NSString *)key
                                  error:(NSError *_Nullable *_Nullable)outError;

/// Wraps the underlying asset's loadValuesAsynchronouslyForKeys:completionHandler: method.
- (void)loadValuesAsynchronouslyForKeys:(NSArray<NSString *> *)keys
                      completionHandler:(nullable void (^NS_SWIFT_SENDABLE)(void))handler;

/// Wraps the underlying asset's loadTracksWithMediaType:completionHandler: method.
- (void)loadTracksWithMediaType:(AVMediaType)mediaType
              completionHandler:(void (^NS_SWIFT_SENDABLE)(NSArray<AVAssetTrack *> *_Nullable,
                                                           NSError *_Nullable))completionHandler
    API_AVAILABLE(macos(12.0), ios(15.0));

/// Wraps the underlying asset's tracksWithMediaType: method.
- (NSArray<AVAssetTrack *> *)tracksWithMediaType:(AVMediaType)mediaType
    API_DEPRECATED("Use loadTracksWithMediaType:completionHandler: instead", macos(10.7, 15.0),
                   ios(4.0, 18.0));
@end

/// Protocol for abstracting access to an AVPlayerItem, to enable unit testing.
@protocol FVPAVPlayerItem <NSObject>
@required
/// Wraps the underlying playerItem's asset property.
@property(nonatomic, readonly) NSObject<FVPAVAsset> *asset;

/// Wraps the underlying playerItem's videoComposition property.
@property(nonatomic, copy, nullable) AVVideoComposition *videoComposition;
@end

#if TARGET_OS_IOS
/// Protocol for abstracting access to an AVAudioSession, to enable unit testing.
@protocol FVPAVAudioSession <NSObject>
@required
/// Wraps the AVAudioSession property of the same name.
@property(nonatomic, readonly) AVAudioSessionCategory category;
/// Wraps the AVAudioSession property of the same name.
@property(nonatomic, readonly) AVAudioSessionCategoryOptions categoryOptions;
/// Wraps the AVAudioSession method of the same name.
- (BOOL)setCategory:(AVAudioSessionCategory)category
        withOptions:(AVAudioSessionCategoryOptions)options
              error:(NSError **)outError;
@end
#endif

/// Protocol for AVFoundation object instance factory. Used for injecting framework objects in
/// tests.
@protocol FVPAVFactory
@required

/// Creates and returns a wrapped AVAsset instance with the specified URL and options.
- (NSObject<FVPAVAsset> *)URLAssetWithURL:(NSURL *)URL
                                  options:(nullable NSDictionary<NSString *, id> *)options;

/// Creates and returns a wrapped AVPlayerItem instance with the specified asset.
- (NSObject<FVPAVPlayerItem> *)playerItemWithAsset:(NSObject<FVPAVAsset> *)asset;

/// Creates and returns an AVPlayer instance with the specified player item.
- (AVPlayer *)playerWithPlayerItem:(NSObject<FVPAVPlayerItem> *)playerItem;

/// Creates and returns a wrapped AVPlayerItemVideoOutput instance with the specified pixel buffer
/// attributes.
- (NSObject<FVPPixelBufferSource> *)videoOutputWithPixelBufferAttributes:
    (NSDictionary<NSString *, id> *)attributes;

#if TARGET_OS_IOS
/// Returns the AVAudioSession shared instance, wrapped in the protocol.
- (NSObject<FVPAVAudioSession> *)sharedAudioSession;
#endif
@end

/// A default implementation of the FVPAVFactory protocol, using real AVFoundation objects.
@interface FVPDefaultAVFactory : NSObject <FVPAVFactory>
@end

NS_ASSUME_NONNULL_END
