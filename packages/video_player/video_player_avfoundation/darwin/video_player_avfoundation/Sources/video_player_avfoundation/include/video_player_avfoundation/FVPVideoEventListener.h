// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

/// Handles event/status callbacks from FVPVideoPlayer.
///
/// This is an abstraction around the event channel to avoid coupling FVPVideoPlayer directly to
/// implementation details specific to the plugin communication method.
@protocol FVPVideoEventListener <NSObject>
@required
// Called when the video player has initialized.
- (void)videoPlayerDidInitializeWithDuration:(int64_t)duration size:(CGSize)size;
// Called if there is an error in video load or playback.
- (void)videoPlayerDidErrorWithMessage:(NSString *)errorMessage;
/// Called when the video player plays to the end and then stops (i.e., looping is not enabled).
- (void)videoPlayerDidComplete;
/// Called when the video player needs to buffer more in order to play witohut stopping.
- (void)videoPlayerDidStartBuffering;
/// Called when the video player has buffered enough to likely be able to play witohut stopping.
- (void)videoPlayerDidEndBuffering;
/// Called when the buffered regions change.
///
/// The array elements are two-element arrays, each containing the start and duration, in
/// milliseconds, of a buffered region.
- (void)videoPlayerDidUpdateBufferRegions:(NSArray<NSArray<NSNumber *> *> *)regions;
/// Called when the player starts or stops playing.
- (void)videoPlayerDidSetPlaying:(BOOL)playing;
/// Called when the video player has been disposed on the Dart side.
- (void)videoPlayerWasDisposed;
@end
