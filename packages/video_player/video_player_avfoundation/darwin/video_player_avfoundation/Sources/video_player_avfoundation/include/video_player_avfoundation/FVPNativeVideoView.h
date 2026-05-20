// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import AVFoundation;

#if TARGET_OS_OSX
@import FlutterMacOS;
#else
@import Flutter;
#endif

/// A class used to create a native video view that can be embedded in a Flutter app.
/// This class wraps an AVPlayer instance and displays its video content.
#if TARGET_OS_IOS
@interface FVPNativeVideoView : NSObject <FlutterPlatformView>
#else
@interface FVPNativeVideoView : NSView
#endif
/// Initializes a new instance of a native view.
/// It creates a video view instance and sets the provided AVPlayer instance to it.
- (instancetype)initWithPlayer:(AVPlayer *)player;
@end
