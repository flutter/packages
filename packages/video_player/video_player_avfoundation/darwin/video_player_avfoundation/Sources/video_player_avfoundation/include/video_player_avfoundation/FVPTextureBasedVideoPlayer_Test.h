// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FVPTextureBasedVideoPlayer.h"

#if TARGET_OS_OSX
#import <FlutterMacOS/FlutterMacOS.h>
#else
#import <Flutter/Flutter.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface FVPTextureBasedVideoPlayer ()
/// The AVPlayerLayer used to display the video content.
/// This is to fix 2 bugs: 1. blank video for encrypted video streams on iOS 16
/// (https://github.com/flutter/flutter/issues/111457) and 2. swapped width and height for some
/// video streams (not just iOS 16).  (https://github.com/flutter/flutter/issues/109116). An
/// invisible AVPlayerLayer is used to overwrite the protection of pixel buffers in those streams
/// for issue #1, and restore the correct width and height for issue #2.
@property(readonly, nonatomic) AVPlayerLayer *playerLayer;

/// Called when the texture is unregistered.
/// This method is used to clean up resources associated with the texture.
- (void)onTextureUnregistered:(nullable NSObject<FlutterTexture> *)texture;
@end

NS_ASSUME_NONNULL_END
