// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

@class FVPContentDownloader, AVAssetResourceLoadingRequest;
@protocol FVPResourceLoadingRequestWorkerDelegate;

/**
 *  `FVPResourceLoadingRequestWorker` is a class designed to handle the process of downloading and
 loading content resources for `AVAssetResourceLoader` in an `AVPlayer`. It works in conjunction
 with the `FVPContentDownloader` and facilitates the seamless integration of externally fetched
 media resources into the playback of audio or video content.

 *  Usage:
 *  1. Initialize an instance of `FVPResourceLoadingRequestWorker` with a `FVPContentDownloader` and
 an `AVAssetResourceLoadingRequest`.
 *  2. Use the `startWork` method to begin downloading and processing the requested media resource.
 *  3. Optionally, use the `cancel` method to stop the download and clear any resources.
 *  4. When the download is completed or canceled, the worker will automatically finish the loading
 request.

 *  Example:
 *
 *  NSError *error;
 *  NSURL *mediaURL = [NSURL URLWithString:@"https://example.com/media.mp4"];
 *  AVURLAsset *asset = [AVURLAsset assetWithURL:mediaURL];
 *  AVAssetResourceLoader *resourceLoader = asset.resourceLoader;
 *
 *  // Create a content downloader
 *  FVPContentDownloader *contentDownloader = [[FVPContentDownloader alloc] initWithURL:mediaURL];
 *
 *  // Create a resource loading request worker
 *  FVPResourceLoadingRequestWorker *requestWorker = [[FVPResourceLoadingRequestWorker alloc]
 initWithContentDownloader:contentDownloader  * resourceLoadingRequest:resourceLoader];
 *
 *  // Start downloading and processing the media resource
 *  [requestWorker startWork];
 *
 * @warning This class should be used in conjunction with FVPContentDownloader and is not intended
 for standalone use.
 *
 * @see FVPContentDownloader
 * @see FVPContentInfo
 */

@interface FVPResourceLoadingRequestWorker : NSObject 

/**
 * Initializes an FVPResourceLoadingRequestWorker instance with the provided FVPContentDownloader
 * and AVAssetResourceLoadingRequest.
 *
 * @param contentDownloader The content downloader responsible for fetching the media resource.
 * @param request The AVAssetResourceLoadingRequest representing the requested media resource.
 * @return A new FVPResourceLoadingRequestWorker instance.
 */

- (instancetype)initWithContentDownloader:(FVPContentDownloader *)contentDownloader
                   resourceLoadingRequest:(AVAssetResourceLoadingRequest *)request
    NS_DESIGNATED_INITIALIZER;

@property(nonatomic, weak) id<FVPResourceLoadingRequestWorkerDelegate> delegate;

@property(nonatomic, strong, readonly) AVAssetResourceLoadingRequest *request;

/**
 * Begins downloading and processing the requested media resource. This method should be called
 after initializing the worker.

 * @note The worker will automatically handle the download and loading process based on the provided
 AVAssetResourceLoadingRequest.
 */
- (void)startWork;
/**
 * Cancels the download and loading process. Use this method to stop the download and clear any
 * associated resources.
 */
- (void)cancel;
/**
 * Finishes the resource loading request. This method should be called after the download is
 * completed or canceled.
 *
 * @warning If not called explicitly, this method will be automatically called by the worker when
 * appropriate.
 */
- (void)finish;

@end

@protocol FVPResourceLoadingRequestWorkerDelegate <NSObject>

- (void)resourceLoadingRequestWorker:(FVPResourceLoadingRequestWorker *)requestWorker
                didCompleteWithError:(NSError *)error;

@end
