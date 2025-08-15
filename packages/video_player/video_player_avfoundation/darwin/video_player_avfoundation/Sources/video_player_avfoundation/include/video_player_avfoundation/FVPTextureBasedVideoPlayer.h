// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FVPDisplayLink.h"
#import "FVPFrameUpdater.h"
#import "FVPVideoPlayer.h"
#import "FVPVideoPlayer_Internal.h"

NS_ASSUME_NONNULL_BEGIN

/// A subclass of FVPVideoPlayer that adds functionality related to texture-based view as a way of
/// displaying the video in the app. It manages the CALayer associated with the Flutter view,
/// updates frames, and handles display link callbacks.
/// If you need to display a video using platform view, use FVPVideoPlayer instead.
@interface FVPTextureBasedVideoPlayer : FVPVideoPlayer <FlutterTexture>
/// Initializes a new instance of FVPTextureBasedVideoPlayer with the given player item,
/// frame updater, display link, AV factory, and view provider.
- (instancetype)initWithPlayerItem:(AVPlayerItem *)item
                      frameUpdater:(FVPFrameUpdater *)frameUpdater
                       displayLink:(NSObject<FVPDisplayLink> *)displayLink
                         avFactory:(id<FVPAVFactory>)avFactory
                      viewProvider:(NSObject<FVPViewProvider> *)viewProvider;

/// Sets the texture Identifier for the frame updater. This method should be called once the texture
/// identifier is obtained from the texture registry.
- (void)setTextureIdentifier:(int64_t)textureIdentifier;
@end

NS_ASSUME_NONNULL_END
