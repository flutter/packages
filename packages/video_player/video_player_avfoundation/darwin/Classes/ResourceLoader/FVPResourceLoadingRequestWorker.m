// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FVPResourceLoadingRequestWorker.h"
#import "FVPContentDownloader.h"
#import "FVPContentInfo.h"

@import MobileCoreServices;
@import AVFoundation;
@import UIKit;

@interface FVPResourceLoadingRequestWorker () <FVPContentDownloaderDelegate>

@property(nonatomic, strong, readwrite) AVAssetResourceLoadingRequest *request;
@property(nonatomic, strong) FVPContentDownloader *contentDownloader;

@end

// To handle the process of downloading and loading media resources for AVAssetResourceLoader in an
// AVPlayer
@implementation FVPResourceLoadingRequestWorker

- (instancetype)initWithContentDownloader:(FVPContentDownloader *)contentDownloader
                   resourceLoadingRequest:(AVAssetResourceLoadingRequest *)request {
  self = [super init];
  if (self) {
    _contentDownloader = contentDownloader;
    _contentDownloader.delegate = self;
    _request = request;

    [self storeMetaData];
  }
  return self;
}

- (instancetype)init NS_UNAVAILABLE {
  NSAssert(NO, @"Use - initWithContentDownloader: resourceLoadingRequest: instead");
  return nil;
}

- (void)startWork {
  AVAssetResourceLoadingDataRequest *dataRequest = self.request.dataRequest;

  long long offset = dataRequest.requestedOffset;
  NSInteger length = dataRequest.requestedLength;
  if (dataRequest.currentOffset != 0) {
    offset = dataRequest.currentOffset;
  }

  BOOL toEnd = NO;
  if ([[UIDevice currentDevice].systemVersion floatValue] >= 9.0) {
    if (dataRequest.requestsAllDataToEndOfResource) {
      toEnd = YES;
    }
  }
  [self.contentDownloader downloadTaskFromOffset:offset length:length toEnd:toEnd];
}

- (void)cancel {
  [self.contentDownloader cancel];
}

- (void)finish {
  if (!self.request.isFinished) {
    [self.contentDownloader cancel];
    [self.request finishLoadingWithError:[self loaderCancelledError]];
  }
}

- (NSError *)loaderCancelledError {
  NSError *error =
      [[NSError alloc] initWithDomain:@"video_player"
                                 code:-3
                             userInfo:@{NSLocalizedDescriptionKey : @"Resource loader cancelled"}];
  return error;
}

// When a response from the server is received it retrieved essential information
// (contentInformationRequest) like content type and content length
// (AVAssetResourceLoadingContentInformationRequest) from the request. It checks if the content
// information is missing and then fills it using the information from the contentDownloader.
- (void)storeMetaData {
  // retrieves the metadata from the request
  AVAssetResourceLoadingContentInformationRequest *contentInformationRequest =
      self.request.contentInformationRequest;

  if (self.contentDownloader.info && !contentInformationRequest.contentType) {
    // Fullfill content information
    contentInformationRequest.contentType = self.contentDownloader.info.contentType;
    contentInformationRequest.contentLength = self.contentDownloader.info.contentLength;
    contentInformationRequest.byteRangeAccessSupported =
        self.contentDownloader.info.byteRangeAccessSupported;
  }
}

#pragma mark - FVPContentDownloaderDelegate

/**
 * @method         contentDownloader:didReceiveResponse
 * @abstract       Starts storing essential meta data like e.g. content type and content length upon
 * server response.
 * @param          response
 *                 An instance of NSURLResponse containing the reponse (with metadata
 * AVAssetResourceLoadingContentInformationRequest).
 */
- (void)contentDownloader:(FVPContentDownloader *)downloader
       didReceiveResponse:(NSURLResponse *)response {
  // When a response has been received we can store essential metadata like e.g. content type and
  // content length.
  [self storeMetaData];
}

- (void)contentDownloader:(FVPContentDownloader *)downloader didReceiveData:(NSData *)data {
  // When a response has been received we can store essential information like e.g. content type and
  // content length.
  [self.request.dataRequest respondWithData:data];
}

- (void)contentDownloader:(FVPContentDownloader *)downloader didFinishedWithError:(NSError *)error {
  if (error.code == NSURLErrorCancelled) {
    return;
  }

  if (!error) {
    [self.request finishLoading];
  } else {
    [self.request finishLoadingWithError:error];
  }

  [self.delegate resourceLoadingRequestWorker:self didCompleteWithError:error];
}

@end
