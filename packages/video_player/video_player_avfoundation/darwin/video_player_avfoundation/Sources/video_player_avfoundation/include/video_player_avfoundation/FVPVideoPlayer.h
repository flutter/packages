// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#if TARGET_OS_OSX
#import <FlutterMacOS/FlutterMacOS.h>
#else
#import <Flutter/Flutter.h>
#endif

#import <AVFoundation/AVFoundation.h>

#import "FVPAVFactory.h"
#import "FVPDisplayLink.h"
#import "FVPFrameUpdater.h"

NS_ASSUME_NONNULL_BEGIN

/// FVPVideoPlayer is responsible for managing video playback using AVPlayer.
/// It provides methods to control playback, adjust volume, handle seeking, and
/// notify the Flutter engine about new video frames.
@interface FVPVideoPlayer : NSObject <FlutterStreamHandler, FlutterTexture>
/// The Flutter event channel used to communicate with the Flutter engine.
@property(nonatomic) FlutterEventChannel *eventChannel;
/// Indicates whether the video player has been disposed.
@property(nonatomic, readonly) BOOL disposed;
/// Indicates whether the video player is set to loop.
@property(nonatomic) BOOL isLooping;
/// The AVPlayer instance used for video playback.
@property(readonly, nonatomic, nonnull) AVPlayer *player;
// This is to fix 2 bugs: 1. blank video for encrypted video streams on iOS 16
// (https://github.com/flutter/flutter/issues/111457) and 2. swapped width and height for some video
// streams (not just iOS 16).  (https://github.com/flutter/flutter/issues/109116).
// An invisible AVPlayerLayer is used to overwrite the protection of pixel buffers in those streams
// for issue #1, and restore the correct width and height for issue #2.
@property(nonatomic, nonnull) AVPlayerLayer *playerLayer;
/// The current playback position of the video, in milliseconds.
@property(readonly, nonatomic) int64_t position;

/// Initializes a new instance of FVPVideoPlayer with the given URL, frame updater, display link,
/// HTTP headers, AV factory, and registrar.
- (instancetype)initWithURL:(NSURL *)url
               frameUpdater:(FVPFrameUpdater *)frameUpdater
                displayLink:(FVPDisplayLink *)displayLink
                httpHeaders:(nonnull NSDictionary<NSString *, NSString *> *)headers
                  avFactory:(id<FVPAVFactory>)avFactory
                  registrar:(NSObject<FlutterPluginRegistrar> *)registrar;

/// Initializes a new instance of FVPVideoPlayer with the given AVPlayerItem, frame updater, display
/// link, AV factory, and registrar.
- (instancetype)initWithPlayerItem:(AVPlayerItem *)item
                      frameUpdater:(FVPFrameUpdater *)frameUpdater
                       displayLink:(FVPDisplayLink *)displayLink
                         avFactory:(id<FVPAVFactory>)avFactory
                         registrar:(NSObject<FlutterPluginRegistrar> *)registrar;

/// Initializes a new instance of FVPVideoPlayer with the given asset, frame updater, display link,
/// AV factory, and registrar.
- (instancetype)initWithAsset:(NSString *)asset
                 frameUpdater:(FVPFrameUpdater *)frameUpdater
                  displayLink:(FVPDisplayLink *)displayLink
                    avFactory:(id<FVPAVFactory>)avFactory
                    registrar:(NSObject<FlutterPluginRegistrar> *)registrar;

/// Disposes the video player and releases any resources it holds.
- (void)dispose;

/// Disposes the video player without touching the event channel. This
/// is useful for the case where the Engine is in the process of deconstruction
/// so the channel is going to die or is already dead.
- (void)disposeSansEventChannel;

/// Sets the volume of the video player.
- (void)setVolume:(double)volume;

/// Sets the playback speed of the video player.
- (void)setPlaybackSpeed:(double)speed;

/// Starts playing the video.
- (void)play;

/// Pauses the video.
- (void)pause;

/// Seeks to the specified location in the video and calls the completion handler when done, if one
/// is supplied.
- (void)seekTo:(int64_t)location completionHandler:(void (^_Nullable)(BOOL))completionHandler;

/// Tells the player to run its frame updater until it receives a frame, regardless of the
/// play/pause state.
- (void)expectFrame;

/// Called when the texture is unregistered.
/// This method is used to clean up resources associated with the texture.
- (void)onTextureUnregistered:(nullable NSObject<FlutterTexture> *)texture;
@end

NS_ASSUME_NONNULL_END
