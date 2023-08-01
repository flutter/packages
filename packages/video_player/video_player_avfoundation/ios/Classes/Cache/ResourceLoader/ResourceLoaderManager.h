// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>

@protocol ResourceLoaderManagerDelegate;

/*!
 the ResourceLoaderManager class manages the resource loading process for AVPlayer by utilizing
 ResourceLoader instances to handle loading of resources with custom schemes. It acts as a bridge
 between AVPlayer and the custom resource loading mechanism, allowing the AVPlayer to load media
 resources using AVAssetResourceLoader and AVURLAsset. This setup is useful for scenarios where
 custom resource loading or caching is required during media playback.
 */
@interface ResourceLoaderManager : NSObject <AVAssetResourceLoaderDelegate>

@property(nonatomic, weak) id<ResourceLoaderManagerDelegate> delegate;

/*!
 cleans the cache
 */
- (void)cleanCache;

/*!
 cancels the loaders
 */
- (void)cancelLoaders;

@end

@protocol ResourceLoaderManagerDelegate <NSObject>

/*!
 resourceLoaderManagerLoadURL
 */
- (void)resourceLoaderManagerLoadURL:(NSURL *)url didFailWithError:(NSError *)error;

@end

@interface ResourceLoaderManager (Convenient)

/*!
 assetURLWithURL
 */
+ (NSURL *)assetURLWithURL:(NSURL *)url;
/*!
 playerItemWithURL
 */
- (AVPlayerItem *)playerItemWithURL:(NSURL *)url;

@end
