// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <AVFoundation/AVFoundation.h>
#import "FVPAVFactory.h"
#import "FVPVideoEventListener.h"
#import "FVPVideoPlayer.h"
#import "FVPViewProvider.h"

NS_ASSUME_NONNULL_BEGIN

/// Interface intended for use by subclasses, but not other callers.
@interface FVPVideoPlayer ()
/// The AVPlayerItemVideoOutput associated with this video player.
@property(nonatomic) AVPlayerItemVideoOutput *videoOutput;
/// The view provider, to obtain view information from.
@property(nonatomic, readonly, nullable) NSObject<FVPViewProvider> *viewProvider;
/// The preferred transform for the video. It can be used to handle the rotation of the video.
@property(nonatomic) CGAffineTransform preferredTransform;
/// The target playback speed requested by the plugin client.
@property(nonatomic, readonly) NSNumber *targetPlaybackSpeed;
/// Indicates whether the video player is currently playing.
@property(nonatomic, readonly) BOOL isPlaying;
/// Indicates whether an "initialized" message has been sent to the current Flutter event listener.
///
/// The video player sends an "initialized" message to the event listener when its underlying
/// AVPlayerItem is ready to play and the event listener is set to a non-nil value, whichever occurs
/// last.
///
/// This flag is set to YES when the "initialized" message is first sent, and is never set to NO
/// again.
@property(nonatomic, readonly) BOOL isInitialized;
/// Indicates whether the video player is currently loading a new asset.
@property(nonatomic) BOOL loadingNewAsset;

/// Returns whether the player should apply a video composition to handle rotation.
/// The base implementation returns NO (platform view players let AVPlayerLayer handle rotation
/// natively, which preserves HDR metadata). FVPTextureBasedVideoPlayer overrides this to return
/// YES since pixel buffers need explicit rotation via video composition.
- (BOOL)shouldApplyVideoCompositionForTransform;

/// Updates the playing state of the video player.
- (void)updatePlayingState;

/// Sends the "initialized" message. Called once, when the first item this
/// player was given is ready to play. Subclasses override to defer it.
- (void)reportInitialized;

/// Sends the "reloadingEnd" message, which tells Dart the player is ready to
/// display again after loadAsset. Called when the new item is ready to play.
/// Subclasses override to defer it.
- (void)finishLoadingNewAsset;

/// Called when the player item reaches AVPlayerItemStatusReadyToPlay, on the initial load and after
/// each asset reload, once track metadata (dimensions, frame rate) is available. Subclasses override
/// to configure rate-dependent behavior. The base implementation does nothing.
- (void)configureForReadyToPlayItem:(AVPlayerItem *)item;

/// Loads a new video asset with the specified URL and HTTP headers.
/// @param url The URL of the video asset to load.
/// @param httpHeaders HTTP headers to include with the request.
- (void)loadAsset:(NSURL *)url httpHeaders:(NSDictionary<NSString *, NSString *> *)httpHeaders;
@end

NS_ASSUME_NONNULL_END
