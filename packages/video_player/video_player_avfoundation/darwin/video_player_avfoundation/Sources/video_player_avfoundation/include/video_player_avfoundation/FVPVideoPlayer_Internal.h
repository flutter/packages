// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <AVFoundation/AVFoundation.h>
#import "FVPAVFactory.h"
#import "FVPVideoPlayer.h"
#import "FVPViewProvider.h"

#if TARGET_OS_OSX
#import <FlutterMacOS/FlutterMacOS.h>
#else
#import <Flutter/Flutter.h>
#endif

NS_ASSUME_NONNULL_BEGIN

/// Interface intended for use by subclasses, but not other callers.
@interface FVPVideoPlayer ()
/// The AVPlayerItemVideoOutput associated with this video player.
@property(nonatomic, readonly) AVPlayerItemVideoOutput *videoOutput;
/// The view provider, to obtain view information from.
@property(nonatomic, readonly, nullable) NSObject<FVPViewProvider> *viewProvider;
/// The Flutter event sink used to send events to the Flutter engine.
@property(nonatomic) FlutterEventSink eventSink;
/// The preferred transform for the video. It can be used to handle the rotation of the video.
@property(nonatomic) CGAffineTransform preferredTransform;
/// The target playback speed requested by the plugin client.
@property(nonatomic, readonly) NSNumber *targetPlaybackSpeed;
/// Indicates whether the video player is currently playing.
@property(nonatomic, readonly) BOOL isPlaying;
/// Indicates whether the video player has been initialized.
@property(nonatomic, readonly) BOOL isInitialized;

/// Initializes a new instance of FVPVideoPlayer with the given AVPlayerItem, frame updater, display
/// link, AV factory, and view provider.
- (instancetype)initWithPlayerItem:(AVPlayerItem *)item
                         avFactory:(id<FVPAVFactory>)avFactory
                      viewProvider:(NSObject<FVPViewProvider> *)viewProvider;

/// Updates the playing state of the video player.
- (void)updatePlayingState;

/// Returns the absolute file path for a given asset name.
/// This method attempts to locate the specified asset within the app bundle.
+ (NSString *)absolutePathForAssetName:(NSString *)assetName;
@end

NS_ASSUME_NONNULL_END
