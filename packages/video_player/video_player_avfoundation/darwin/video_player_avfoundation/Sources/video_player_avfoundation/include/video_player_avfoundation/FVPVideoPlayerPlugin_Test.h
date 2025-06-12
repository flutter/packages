// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FVPAVFactory.h"
#import "FVPDisplayLink.h"
#import "FVPVideoPlayer.h"
#import "FVPVideoPlayerPlugin.h"
#import "messages.g.h"

// Protocol for an AVPlayer instance factory. Used for injecting display links in tests.
@protocol FVPDisplayLinkFactory
- (FVPDisplayLink *)displayLinkWithRegistrar:(id<FlutterPluginRegistrar>)registrar
                                    callback:(void (^)(void))callback;
@end

#pragma mark -

@interface FVPVideoPlayerPlugin () <FVPAVFoundationVideoPlayerApi>

@property(readonly, strong, nonatomic)
    NSMutableDictionary<NSNumber *, FVPVideoPlayer *> *playersByIdentifier;

- (instancetype)initWithAVFactory:(id<FVPAVFactory>)avFactory
               displayLinkFactory:(id<FVPDisplayLinkFactory>)displayLinkFactory
                     viewProvider:(NSObject<FVPViewProvider> *)viewProvider
                        registrar:(NSObject<FlutterPluginRegistrar> *)registrar;

@end
