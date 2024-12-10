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
@interface FVPVideoPlayer : NSObject <FlutterStreamHandler>
/// The Flutter event channel used to communicate with the Flutter engine.
@property(nonatomic) FlutterEventChannel *eventChannel;
/// The AVPlayer instance used for video playback.
@property(nonatomic, readonly) AVPlayer *player;
/// Indicates whether the video player has been disposed.
@property(nonatomic, readonly) BOOL disposed;
/// Indicates whether the video player is set to loop.
@property(nonatomic) BOOL isLooping;
/// The current playback position of the video, in milliseconds.
@property(nonatomic, readonly) int64_t position;

/// Initializes a new instance of FVPVideoPlayer with the given asset, AV factory, and registrar.
- (instancetype)initWithAsset:(NSString *)asset
                    avFactory:(id<FVPAVFactory>)avFactory
                    registrar:(NSObject<FlutterPluginRegistrar> *)registrar;

/// Initializes a new instance of FVPVideoPlayer with the given URL, HTTP headers, AV factory, and
/// registrar.
- (instancetype)initWithURL:(NSURL *)url
                httpHeaders:(nonnull NSDictionary<NSString *, NSString *> *)headers
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
@end

@interface FVPVideoPlayer ()
/// The AVPlayerItemVideoOutput associated with this video player.
@property(nonatomic, readonly) AVPlayerItemVideoOutput *videoOutput;
/// The plugin registrar, to obtain view information from.
@property(nonatomic, readonly) NSObject<FlutterPluginRegistrar> *registrar;
/// The CALayer associated with the Flutter view this plugin is associated with, if any.
@property(nonatomic, readonly, nullable) CALayer *flutterViewLayer;
/// The Flutter event sink used to send events to the Flutter engine.
@property(nonatomic) FlutterEventSink eventSink;
/// The preferred transform for the video. It can be used to handle the rotation of the video.
@property(nonatomic) CGAffineTransform preferredTransform;
/// Indicates whether the video player is currently playing.
@property(nonatomic, readonly) BOOL isPlaying;
/// Indicates whether the video player has been initialized.
@property(nonatomic, readonly) BOOL isInitialized;

/// Initializes a new instance of FVPVideoPlayer with the given AVPlayerItem, frame updater, display
/// link, AV factory, and registrar.
- (instancetype)initWithPlayerItem:(AVPlayerItem *)item
                         avFactory:(id<FVPAVFactory>)avFactory
                         registrar:(NSObject<FlutterPluginRegistrar> *)registrar;

/// Updates the playing state of the video player.
- (void)updatePlayingState;
@end

NS_ASSUME_NONNULL_END
