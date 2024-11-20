// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// FIXME Do we even need if statement below? MacOS currently doesn't support
// FlutterPlatformView.
//  But can we complie code without it? And is it good to put iOS-specific code
//  in the main directory (video_player_avfoundation?

#import <Flutter/Flutter.h>

@interface FVPNativeVideoView : NSObject <FlutterPlatformView>
- (instancetype)initWithFrame:(CGRect)frame
               viewIdentifier:(int64_t)viewId
                    arguments:(id _Nullable)args
              binaryMessenger:(NSObject<FlutterBinaryMessenger> *)messenger
                       player:(AVPlayer *)player;

- (UIView *)view;
@end
