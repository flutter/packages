// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Platform views are only supported on iOS as of now. Ifdefs are used to avoid compilation errors.

#import <AVFoundation/AVFoundation.h>

#if TARGET_OS_OSX
#import <FlutterMacOS/FlutterMacOS.h>
#else
#import <Flutter/Flutter.h>
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
