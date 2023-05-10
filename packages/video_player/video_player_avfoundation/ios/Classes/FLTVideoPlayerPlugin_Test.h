// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTVideoPlayerPlugin.h"

#import <AVFoundation/AVFoundation.h>

// Protocol for an AVPlayer instance factory. Used for injecting players in tests.
@protocol FVPAVPlayerFactoryProtocol
- (AVPlayer *)playerWithPlayerItem:(AVPlayerItem *)playerItem;
@end

@interface FLTVideoPlayerPlugin ()

- (instancetype)initWithFVPAVPlayerFactory:(id<FVPAVPlayerFactoryProtocol>)playerFactory
                                 registrar:(NSObject<FlutterPluginRegistrar> *)registrar;
@end
