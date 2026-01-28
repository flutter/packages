// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import CoreFoundation;
@import AVFoundation;

NS_ASSUME_NONNULL_BEGIN

/// Protocol for abstracting access to an AVPlayerItemVideoOutput, to allow tests to control pixel
/// buffer delivery.
@protocol FVPPixelBufferSource <NSObject>

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

/// Protocol for AVFoundation object instance factory. Used for injecting framework objects in
/// tests.
@protocol FVPAVFactory
/// Creates and returns an AVPlayer instance with the specified AVPlayerItem.
@required
- (AVPlayer *)playerWithPlayerItem:(AVPlayerItem *)playerItem;

/// Creates and returns a wrapped AVPlayerItemVideoOutput instance with the specified pixel buffer
/// attributes.
- (NSObject<FVPPixelBufferSource> *)videoOutputWithPixelBufferAttributes:
    (NSDictionary<NSString *, id> *)attributes;
@end

/// A default implementation of the FVPAVFactory protocol.
@interface FVPDefaultAVFactory : NSObject <FVPAVFactory>
@end

NS_ASSUME_NONNULL_END
