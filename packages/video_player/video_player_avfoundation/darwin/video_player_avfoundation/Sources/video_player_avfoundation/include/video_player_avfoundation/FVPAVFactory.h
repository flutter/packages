// Copyright 2013 The Flutter Authors
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

/// Creates and returns an AVPlayerItemVideoOutput instance with the specified output settings.
///
/// The dictionary is passed as output settings rather than pixel buffer attributes, so it may
/// carry AVFoundation output setting keys (such as AVVideoColorPropertiesKey) in addition to
/// pixel buffer attribute keys.
- (AVPlayerItemVideoOutput *)videoOutputWithOutputSettings:
    (NSDictionary<NSString *, id> *)outputSettings;
@end

/// A default implementation of the FVPAVFactory protocol.
@interface FVPDefaultAVFactory : NSObject <FVPAVFactory>
@end

NS_ASSUME_NONNULL_END
