// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTVideoPlayerPlugin.h"

#import <AVFoundation/AVFoundation.h>

@protocol AVPlayerFactoryProtocol
- (AVPlayer *)playerWithPlayerItem:(AVPlayerItem *)playerItem;
@end

@interface AVPlayerFactory : NSObject <AVPlayerFactoryProtocol>
@end

@interface FLTVideoPlayerPlugin ()

- (instancetype)initWithAVPlayerFactory:(AVPlayerFactory *)playerFactory
                              registrar:(NSObject<FlutterPluginRegistrar> *)registrar;
@end
