// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FVPVideoPlayerPlugin.h"

#if TARGET_OS_OSX
@import FlutterMacOS;
#else
@import Flutter;
#endif

#import "FVPAVFactory.h"
#import "FVPAssetProvider.h"
#import "FVPDisplayLink.h"
#import "FVPVideoPlayer.h"
#import "FVPViewProvider.h"
#import "messages.g.h"

NS_ASSUME_NONNULL_BEGIN

// Protocol for an AVPlayer instance factory. Used for injecting display links in tests.
@protocol FVPDisplayLinkFactory
- (NSObject<FVPDisplayLink> *)displayLinkWithViewProvider:(NSObject<FVPViewProvider> *)viewProvider
                                                 callback:(void (^)(void))callback;
@end

#pragma mark -

@interface FVPVideoPlayerPlugin () <FVPAVFoundationVideoPlayerApi>

@property(readonly, strong, nonatomic)
    NSMutableDictionary<NSNumber *, FVPVideoPlayer *> *playersByIdentifier;

- (instancetype)initWithAVFactory:(id<FVPAVFactory>)avFactory
               displayLinkFactory:(id<FVPDisplayLinkFactory>)displayLinkFactory
                  binaryMessenger:(NSObject<FlutterBinaryMessenger> *)binaryMessenger
                  textureRegistry:(NSObject<FlutterTextureRegistry> *)textureRegistry
                     viewProvider:(NSObject<FVPViewProvider> *)viewProvider
                    assetProvider:(NSObject<FVPAssetProvider> *)assetProvider;

@end

NS_ASSUME_NONNULL_END
