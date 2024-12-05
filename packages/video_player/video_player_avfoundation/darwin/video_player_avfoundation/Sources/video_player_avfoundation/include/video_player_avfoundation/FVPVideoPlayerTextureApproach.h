// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FVPDisplayLink.h"
#import "FVPFrameUpdater.h"
#import "FVPVideoPlayer_Test.h"

NS_ASSUME_NONNULL_BEGIN

/// A subclass of FVPVideoPlayer that adds functionality related to texture-based view as a way of
/// displaying the video in the app. It manages the CALayer associated with the Flutter view,
/// updates frames, and handles display link callbacks.
@interface FVPVideoPlayerTextureApproach : FVPVideoPlayer <FlutterTexture>
/// Initializes a new instance of FVPVideoPlayerTextureApproach with the given URL, frame updater,
/// display link, HTTP headers, AV factory, and registrar.
- (instancetype)initWithURL:(NSURL *)url
               frameUpdater:(FVPFrameUpdater *)frameUpdater
                displayLink:(FVPDisplayLink *)displayLink
                httpHeaders:(nonnull NSDictionary<NSString *, NSString *> *)headers
                  avFactory:(id<FVPAVFactory>)avFactory
                  registrar:(NSObject<FlutterPluginRegistrar> *)registrar;

/// Initializes a new instance of FVPVideoPlayerTextureApproach with the given asset, frame updater,
/// display link, AV factory, and registrar.
- (instancetype)initWithAsset:(NSString *)asset
                 frameUpdater:(FVPFrameUpdater *)frameUpdater
                  displayLink:(FVPDisplayLink *)displayLink
                    avFactory:(id<FVPAVFactory>)avFactory
                    registrar:(NSObject<FlutterPluginRegistrar> *)registrar;

// Tells the player to run its frame updater until it receives a frame, regardless of the
// play/pause state.
- (void)expectFrame;
@end

NS_ASSUME_NONNULL_END