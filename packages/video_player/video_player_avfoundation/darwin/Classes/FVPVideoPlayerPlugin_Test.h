// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FVPVideoPlayerPlugin.h"

#import <AVFoundation/AVFoundation.h>

#import "FVPDisplayLink.h"
#import "messages.g.h"

// Protocol for AVFoundation object instance factory. Used for injecting framework objects in tests.
@protocol FVPAVFactory
@required
- (AVPlayer *)playerWithPlayerItem:(AVPlayerItem *)playerItem;
- (AVPlayerItemVideoOutput *)videoOutputWithPixelBufferAttributes:
    (NSDictionary<NSString *, id> *)attributes;
@end

// Protocol for an AVPlayer instance factory. Used for injecting display links in tests.
@protocol FVPDisplayLinkFactory
- (FVPDisplayLink *)displayLinkWithRegistrar:(id<FlutterPluginRegistrar>)registrar
                                    callback:(void (^)(void))callback;
@end

#pragma mark -

// TODO(stuartmorgan): Move this whole class to its own files.
@interface FVPVideoPlayer : NSObject <FlutterStreamHandler, FlutterTexture>
@property(readonly, nonatomic) AVPlayer *player;
// This is to fix 2 bugs: 1. blank video for encrypted video streams on iOS 16
// (https://github.com/flutter/flutter/issues/111457) and 2. swapped width and height for some video
// streams (not just iOS 16).  (https://github.com/flutter/flutter/issues/109116).
// An invisible AVPlayerLayer is used to overwrite the protection of pixel buffers in those streams
// for issue #1, and restore the correct width and height for issue #2.
@property(readonly, nonatomic) AVPlayerLayer *playerLayer;
@property(readonly, nonatomic) int64_t position;

- (void)onTextureUnregistered:(NSObject<FlutterTexture> *)texture;
@end

#pragma mark -

@interface FVPVideoPlayerPlugin () <FVPAVFoundationVideoPlayerApi>

@property(readonly, strong, nonatomic)
    NSMutableDictionary<NSNumber *, FVPVideoPlayer *> *playersByTextureId;

- (instancetype)initWithAVFactory:(id<FVPAVFactory>)avFactory
               displayLinkFactory:(id<FVPDisplayLinkFactory>)displayLinkFactory
                        registrar:(NSObject<FlutterPluginRegistrar> *)registrar;

@end
