// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Protocol for AVFoundation object instance factory. Used for injecting framework objects in
/// tests.
@protocol FVPAVFactory
/// Creates and returns an AVPlayer instance with the specified AVPlayerItem.
@required
- (AVPlayer *)playerWithPlayerItem:(AVPlayerItem *)playerItem;

/// Creates and returns an AVPlayerItemVideoOutput instance with the specified pixel buffer
/// attributes.
- (AVPlayerItemVideoOutput *)videoOutputWithPixelBufferAttributes:
    (NSDictionary<NSString *, id> *)attributes;
@end

/// A default implementation of the FVPAVFactory protocol.
@interface FVPDefaultAVFactory : NSObject <FVPAVFactory>
@end

NS_ASSUME_NONNULL_END
