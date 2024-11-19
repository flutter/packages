// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#if TARGET_OS_OSX
#import <FlutterMacOS/FlutterMacOS.h>
#else
#import <Flutter/Flutter.h>
#endif

// FIXME Do we even need ifs below? MacOS currently doesn't support FlutterPlatformView.
//  But can we complie code without it? And is it good to put iOS-specific code in the main
//  directory (video_player_avfoundation?
#if TARGET_OS_OSX
@interface FVPNativeVideoView : NSView
#else
@interface FVPNativeVideoView : NSObject <FlutterPlatformView>
#endif
- (instancetype)initWithFrame:(CGRect)frame
               viewIdentifier:(int64_t)viewId
                    arguments:(id _Nullable)args
              binaryMessenger:(NSObject<FlutterBinaryMessenger> *)messenger
                       player:(AVPlayer *)player;

#if TARGET_OS_OSX
- (NSView *)view;
#else
- (UIView *)view;
#endif
@end
