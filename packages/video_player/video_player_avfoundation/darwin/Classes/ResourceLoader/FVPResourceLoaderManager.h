// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>

@protocol FVPResourceLoaderManagerDelegate;

/**
 *  `FVPResourceLoaderManager` is a manager class responsible for coordinating and managing multiple
 * `FVPResourceLoader` instances within the context of an `AVAssetResourceLoader`. It enables
 * seamless integration of media resource loading, caching, and playback with an `AVPlayer` by
 * intercepting and handling resource loading requests.
 *
 *  Usage:
 *  1. Initialize an instance of `FVPResourceLoaderManager` to manage resource loading requests.
 *  2. Use the `playerItemWithURL:` method to create an `AVPlayerItem` for playback with URL-based
 * assets.
 *  3. Optionally, clean the cache or cancel active loaders when necessary.
 *
 *  Example:
 *
 *  // Create a resource loader manager
 *  FVPResourceLoaderManager *loaderManager = [[FVPResourceLoaderManager alloc] init];
 *
 *  // Create an AVPlayerItem for playback with a media URL
 *  NSURL *mediaURL = [NSURL URLWithString:@"https://example.com/media.mp4"];
 *  AVPlayerItem *playerItem = [loaderManager playerItemWithURL:mediaURL];
 *
 *  // Optionally, clean the cache or cancel active loaders
 *  [loaderManager cleanCache];
 *  [loaderManager cancelLoaders];
 *
 * @warning This class should be used in conjunction with FVPResourceLoader and is not intended for
 * standalone use.
 *
 * @see FVPResourceLoader
 */
@interface FVPResourceLoaderManager : NSObject <AVAssetResourceLoaderDelegate>

@property(nonatomic, weak) id<FVPResourceLoaderManagerDelegate> delegate;

/**
 * Cleans the cache by removing all loaded resources.
 */
- (void)cleanCache;

/**
 * Cancels all active resource loaders and clears associated resources.
 */
- (void)cancelLoaders;

/**
 * Returns assetUrl with the provided URL. Returns nil if no URL provided
 *
 * @param url The URL of the media resource to be played.
 * @return An AVPlayerItem configured for playback of the specified media URL.
 */
+ (NSURL *)assetURLWithURL:(NSURL *)url;

/**
 * Creates an AVPlayerItem for playback with the provided URL. This method sets up the necessary
 * resource loader delegate and configurations.
 *
 * @param url The URL of the media resource to be played.
 * @return An AVPlayerItem configured for playback of the specified media URL.
 */
- (AVPlayerItem *)playerItemWithURL:(NSURL *)url;

@end

@protocol FVPResourceLoaderManagerDelegate <NSObject>

/**
 * Callback when NSError
 */
- (void)resourceLoaderManagerLoadURL:(NSURL *)url didFailWithError:(NSError *)error;

@end
