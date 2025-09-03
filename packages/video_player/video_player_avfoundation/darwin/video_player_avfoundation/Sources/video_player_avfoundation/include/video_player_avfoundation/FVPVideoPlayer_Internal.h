// Copyright 2013 The Flutter Authors. All rights reserved.
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
@property(nonatomic, readonly) AVPlayerItemVideoOutput *videoOutput;
/// The view provider, to obtain view information from.
@property(nonatomic, readonly, nullable) NSObject<FVPViewProvider> *viewProvider;
/// The preferred transform for the video. It can be used to handle the rotation of the video.
@property(nonatomic) CGAffineTransform preferredTransform;
/// The target playback speed requested by the plugin client.
@property(nonatomic, readonly) NSNumber *targetPlaybackSpeed;
/// Indicates whether the video player is currently playing.
@property(nonatomic, readonly) BOOL isPlaying;
/// Indicates whether the video player has been initialized.
@property(nonatomic, readonly) BOOL isInitialized;

/// Updates the playing state of the video player.
- (void)updatePlayingState;
@end

NS_ASSUME_NONNULL_END
