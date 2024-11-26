// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FVPDisplayLink.h"
#import "FVPFrameUpdater.h"
#import "FVPVideoPlayer.h"

/// A subclass of FVPVideoPlayer that adds functionality related to texture-based view as a way of
/// displaying the video in the app. It manages the CALayer associated with the Flutter view,
/// updates frames, and handles display link callbacks.
@interface FVPVideoPlayerTextureApproach : FVPVideoPlayer <FlutterTexture>
// The CALayer associated with the Flutter view this plugin is associated with, if any.
@property(nonatomic, readonly, nullable) CALayer *flutterViewLayer;
// The updater that drives callbacks to the engine to indicate that a new frame is ready.
@property(nonatomic, nullable) FVPFrameUpdater *frameUpdater;
// The display link that drives frameUpdater.
@property(nonatomic, nullable) FVPDisplayLink *displayLink;
// Whether a new frame needs to be provided to the engine regardless of the current play/pause state
// (e.g., after a seek while paused). If YES, the display link should continue to run until the next
// frame is successfully provided.
@property(nonatomic, assign) BOOL waitingForFrame;

NS_ASSUME_NONNULL_BEGIN

- (instancetype)initWithURL:(NSURL *)url
               frameUpdater:(FVPFrameUpdater *)frameUpdater
                displayLink:(FVPDisplayLink *)displayLink
                httpHeaders:(nonnull NSDictionary<NSString *, NSString *> *)headers
                  avFactory:(id<FVPAVFactory>)avFactory
                  registrar:(NSObject<FlutterPluginRegistrar> *)registrar;

- (instancetype)initWithAsset:(NSString *)asset
                 frameUpdater:(FVPFrameUpdater *)frameUpdater
                  displayLink:(FVPDisplayLink *)displayLink
                    avFactory:(id<FVPAVFactory>)avFactory
                    registrar:(NSObject<FlutterPluginRegistrar> *)registrar;

NS_ASSUME_NONNULL_END

// Tells the player to run its frame updater until it receives a frame, regardless of the
// play/pause state.
- (void)expectFrame;
@end
