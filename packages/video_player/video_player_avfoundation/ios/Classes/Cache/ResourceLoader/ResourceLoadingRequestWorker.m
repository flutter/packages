
#import "ResourceLoadingRequestWorker.h"
#import "ContentDownloader.h"
#import "ContentInfo.h"

@import MobileCoreServices;
@import AVFoundation;
@import UIKit;

@interface ResourceLoadingRequestWorker () <ContentDownloaderDelegate>

@property(nonatomic, strong, readwrite) AVAssetResourceLoadingRequest *request;
@property(nonatomic, strong) ContentDownloader *contentDownloader;

@end

@implementation ResourceLoadingRequestWorker

- (instancetype)initWithContentDownloader:(ContentDownloader *)contentDownloader
                   resourceLoadingRequest:(AVAssetResourceLoadingRequest *)request {
  self = [super init];
  if (self) {
    _contentDownloader = contentDownloader;
    _contentDownloader.delegate = self;
    _request = request;

    [self fullfillContentInfo];
  }
  return self;
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

- (void)fullfillContentInfo {
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

#pragma mark - ContentDownloaderDelegate

- (void)contentDownloader:(ContentDownloader *)downloader
       didReceiveResponse:(NSURLResponse *)response {
  [self fullfillContentInfo];
}

- (void)contentDownloader:(ContentDownloader *)downloader didReceiveData:(NSData *)data {
  [self.request.dataRequest respondWithData:data];
}

- (void)contentDownloader:(ContentDownloader *)downloader didFinishedWithError:(NSError *)error {
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
