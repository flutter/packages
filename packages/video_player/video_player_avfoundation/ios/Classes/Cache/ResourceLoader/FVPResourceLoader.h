// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
@import AVFoundation;
@protocol FVPResourceLoaderDelegate;

@interface FVPResourceLoader : NSObject

/**
* `FVPResourceLoader` is a class responsible for managing resource loading requests, caching, and
downloading media content for AVAssetResourceLoader in an AVPlayer. It is designed to work with
`AVURLAsset`.

* Usage:
* 1. Initialize an instance of `FVPResourceLoader` with a media URL to enable resource loading and
caching.
* 2. Use the `addRequest:` method to handle resource loading requests from an
`AVAssetResourceLoadingRequest`.
* 3. Optionally, cancel resource loading and clean up resources using the `cancel` method.
*
* Example:
* // Initialize a resource loader with a media URL
* NSURL *mediaURL = [NSURL URLWithString:@"https://example.com/media.mp4"];
* NSError *error;
* FVPResourceLoader *resourceLoader = [[FVPResourceLoader alloc] initWithURL:mediaURL error:error];
*
* // Handle resource loading requests
* [resourceLoader addRequest:loadingRequest];

* // Optionally, cancel resource loading and clean up resources
* [resourceLoader cancel];
* @warning This class should be used in conjunction with FVPContentCacheWorker and
FVPContentDownloader.
*
* @see FVPContentCacheWorker
* @see FVPContentDownloader
*/

// Video URL
@property(nonatomic, strong, readonly) NSURL *url;
@property(nonatomic, weak) id<FVPResourceLoaderDelegate> delegate;

/**
 * Initializes an FVPResourceLoader instance with a media URL.
 *
 * @param url The URL of the media resource to be loaded and played.
 *
 * @return A new FVPResourceLoader instance.
 */
- (instancetype)initWithURL:(NSURL *)url NS_DESIGNATED_INITIALIZER;

/**
 * Adds an AVAssetResourceLoadingRequest for resource loading and caching.
 *
 * @param request An AVAssetResourceLoadingRequest to be handled by the resource loader.
 */
- (void)addRequest:(AVAssetResourceLoadingRequest *)request;

/**
 * Removed an AVAssetResourceLoadingRequest for resource loading and caching.
 *
 * @param request An AVAssetResourceLoadingRequest to be handled by the resource loader.
 */
- (void)removeRequest:(AVAssetResourceLoadingRequest *)request;

/**
 * Cancels all resource loading requests and clears associated resources.
 */
- (void)cancel;

@end

@protocol FVPResourceLoaderDelegate <NSObject>

- (void)resourceLoader:(FVPResourceLoader *)resourceLoader didFailWithError:(NSError *)error;

@end
