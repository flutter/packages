// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>

@protocol FVPResourceLoaderManagerDelegate;

/**
 * Handles resource loading or caching during media playback.
 *
 * by managing the resource loading process for AVPlayer by utilizing
 * ResourceLoader instances to handle loading of resources with custom schemes. It acts as a bridge
 * between AVPlayer and the custom resource loading mechanism, allowing the AVPlayer to load media
 * resources using AVAssetResourceLoader and AVURLAsset.
 */
@interface FVPResourceLoaderManager : NSObject <AVAssetResourceLoaderDelegate>

@property(nonatomic, weak) id<FVPResourceLoaderManagerDelegate> delegate;

/**
 * Removes all loaders.
 */
- (void)cleanCache;

/**
 * Cancels the loaders and then removes all loaders
 */
- (void)cancelLoaders;

/**
 * resourceLoaderManagerLoadURL
 */
+ (NSURL *)assetURLWithURL:(NSURL *)url;

/**
 * playerItemWithURL
 */
- (AVPlayerItem *)playerItemWithURL:(NSURL *)url;

@end

@protocol FVPResourceLoaderManagerDelegate <NSObject>

/**
 *
 */
- (void)resourceLoaderManagerLoadURL:(NSURL *)url didFailWithError:(NSError *)error;

@end
