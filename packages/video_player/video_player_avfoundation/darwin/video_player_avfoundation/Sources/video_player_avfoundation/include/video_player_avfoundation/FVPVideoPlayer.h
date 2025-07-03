// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <AVFoundation/AVFoundation.h>

#import "FVPAVFactory.h"
#import "FVPViewProvider.h"

#if TARGET_OS_OSX
#import <FlutterMacOS/FlutterMacOS.h>
#else
#import <Flutter/Flutter.h>
#endif

NS_ASSUME_NONNULL_BEGIN

/// FVPVideoPlayer manages video playback using AVPlayer.
/// It provides methods for controlling playback, adjusting volume, and handling seeking.
/// This class contains all functionalities needed to manage video playback in platform views and is
/// typically used alongside FVPNativeVideoViewFactory. If you need to display a video using a
/// texture, use FVPTextureBasedVideoPlayer instead.
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

/// Initializes a new instance of FVPVideoPlayer with the given asset, AV factory, and view
/// provider.
- (instancetype)initWithAsset:(NSString *)asset
                    avFactory:(id<FVPAVFactory>)avFactory
                 viewProvider:(NSObject<FVPViewProvider> *)viewProvider;

/// Initializes a new instance of FVPVideoPlayer with the given URL, HTTP headers, AV factory, and
/// view provider.
- (instancetype)initWithURL:(NSURL *)url
                httpHeaders:(nonnull NSDictionary<NSString *, NSString *> *)headers
                  avFactory:(id<FVPAVFactory>)avFactory
               viewProvider:(NSObject<FVPViewProvider> *)viewProvider;

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

NS_ASSUME_NONNULL_END
