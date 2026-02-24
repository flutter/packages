// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "./FVPFairPlayResourceLoaderDelegate.h"

@interface FVPFairPlayResourceLoaderDelegate ()
@property(nonatomic, copy) NSURL *certificateURL;
@property(nonatomic, copy) NSURL *licenseURL;
@property(nonatomic, copy) NSDictionary<NSString *, NSString *> *licenseHeaders;
@property(nonatomic, copy, nullable) NSString *contentId;
@end

@implementation FVPFairPlayResourceLoaderDelegate

- (instancetype)initWithCertificateURL:(NSURL *)certificateURL
                            licenseURL:(NSURL *)licenseURL
                        licenseHeaders:
                            (nullable NSDictionary<NSString *, NSString *> *)licenseHeaders
                             contentId:(nullable NSString *)contentId {
  self = [super init];
  if (self) {
    _certificateURL = [certificateURL copy];
    _licenseURL = [licenseURL copy];
    _licenseHeaders = [licenseHeaders copy] ?: @{};
    _contentId = [contentId copy];
  }
  return self;
}

- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader
    shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest {
  NSURL *assetURL = loadingRequest.request.URL;
  if (assetURL == nil || ![[assetURL scheme] isEqualToString:@"skd"]) {
    return NO;
  }

  [self handleLoadingRequest:loadingRequest];
  return YES;
}

- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader
    shouldWaitForRenewalOfRequestedResource:(AVAssetResourceRenewalRequest *)renewalRequest {
  return [self resourceLoader:resourceLoader
      shouldWaitForLoadingOfRequestedResource:renewalRequest];
}

- (void)handleLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
  NSError *certificateError;
  NSData *certificateData = [NSData dataWithContentsOfURL:self.certificateURL
                                                  options:0
                                                    error:&certificateError];
  if (certificateData == nil) {
    [loadingRequest finishLoadingWithError:certificateError];
    return;
  }

  NSString *requestContentId = self.contentId;
  if (requestContentId.length == 0) {
    requestContentId = loadingRequest.request.URL.absoluteString;
  }
  NSData *contentIdentifierData = [requestContentId dataUsingEncoding:NSUTF8StringEncoding];
  if (contentIdentifierData == nil) {
    [loadingRequest finishLoadingWithError:nil];
    return;
  }

  NSError *spcError;
  NSData *spcData = [loadingRequest streamingContentKeyRequestDataForApp:certificateData
                                                       contentIdentifier:contentIdentifierData
                                                                 options:nil
                                                                   error:&spcError];
  if (spcData == nil) {
    [loadingRequest finishLoadingWithError:spcError];
    return;
  }

  NSMutableURLRequest *licenseRequest = [NSMutableURLRequest requestWithURL:self.licenseURL];
  [licenseRequest setHTTPMethod:@"POST"];
  [licenseRequest setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
  for (NSString *headerName in self.licenseHeaders) {
    [licenseRequest setValue:self.licenseHeaders[headerName] forHTTPHeaderField:headerName];
  }
  [licenseRequest setHTTPBody:spcData];

  NSURLSessionDataTask *task = [[NSURLSession sharedSession]
      dataTaskWithRequest:licenseRequest
        completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response,
                            NSError *_Nullable error) {
          if (error != nil) {
            [loadingRequest finishLoadingWithError:error];
            return;
          }
          if (data == nil || data.length == 0) {
            [loadingRequest finishLoadingWithError:nil];
            return;
          }
          [loadingRequest.dataRequest respondWithData:data];
          [loadingRequest finishLoading];
        }];
  [task resume];
}

@end
