// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

@class ContentDownloader, AVAssetResourceLoadingRequest;
@protocol ResourceLoadingRequestWorkerDelegate;

/*!
 to handle the process of downloading and loading media resources for AVAssetResourceLoader in an AVPlayer
 */
@interface ResourceLoadingRequestWorker : NSObject

- (instancetype)initWithContentDownloader:(ContentDownloader *)contentDownloader
                   resourceLoadingRequest:(AVAssetResourceLoadingRequest *)request;

@property(nonatomic, weak) id<ResourceLoadingRequestWorkerDelegate> delegate;

@property(nonatomic, strong, readonly) AVAssetResourceLoadingRequest *request;

/*!
 This method is called to initiate the downloading and loading process. It uses the information from the AVAssetResourceLoadingDataRequest associated with the request to determine the offset, length, and whether to download the content till the end.
 */
- (void)startWork;
/*!
 This method is called to cancel the downloading and loading process.
 */
- (void)cancel;
/*!
 This method is called to finish the downloading and loading process.
 */
- (void)finish;

@end

@protocol ResourceLoadingRequestWorkerDelegate <NSObject>

- (void)resourceLoadingRequestWorker:(ResourceLoadingRequestWorker *)requestWorker
                didCompleteWithError:(NSError *)error;

@end
