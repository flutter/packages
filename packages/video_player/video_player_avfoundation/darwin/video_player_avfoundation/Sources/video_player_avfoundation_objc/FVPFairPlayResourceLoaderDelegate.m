// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "./include/video_player_avfoundation_objc/FVPFairPlayResourceLoaderDelegate.h"

/// The key URI scheme that AVFoundation hands to the resource loader for FairPlay content.
static NSString *const kFairPlayKeyScheme = @"skd";

static NSString *const kErrorDomain = @"dev.flutter.video_player.fairplay";

typedef NS_ENUM(NSInteger, FVPFairPlayErrorCode) {
  FVPFairPlayErrorCodeCertificateUnavailable = 1,
  FVPFairPlayErrorCodeLicenseUnavailable = 2,
};

/// Returns an error to fail a key request with, using `underlyingError` as the cause if there is
/// one.
static NSError *FVPFairPlayError(FVPFairPlayErrorCode code, NSString *description,
                                 NSError *_Nullable underlyingError) {
  NSMutableDictionary<NSErrorUserInfoKey, id> *userInfo =
      [@{NSLocalizedDescriptionKey : description} mutableCopy];
  if (underlyingError != nil) {
    userInfo[NSUnderlyingErrorKey] = underlyingError;
  }
  return [NSError errorWithDomain:kErrorDomain code:code userInfo:userInfo];
}

/// Returns the error in a response to `request`, or nil if it was a successful response with a
/// non-empty body.
static NSError *_Nullable FVPValidateResponse(NSData *_Nullable data,
                                              NSURLResponse *_Nullable response,
                                              NSError *_Nullable error, FVPFairPlayErrorCode code,
                                              NSString *description) {
  if (error != nil) {
    return FVPFairPlayError(code, description, error);
  }
  if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
    NSInteger statusCode = ((NSHTTPURLResponse *)response).statusCode;
    if (statusCode < 200 || statusCode > 299) {
      return FVPFairPlayError(
          code, [NSString stringWithFormat:@"%@ (HTTP status %ld)", description, (long)statusCode],
          nil);
    }
  }
  if (data.length == 0) {
    return FVPFairPlayError(code, [NSString stringWithFormat:@"%@ (empty response)", description],
                            nil);
  }
  return nil;
}

@interface FVPFairPlayResourceLoaderDelegate ()
@property(nonatomic, copy, readonly) NSURL *certificateURL;
@property(nonatomic, copy, readonly) NSURL *licenseURL;
@property(nonatomic, copy, readonly) NSDictionary<NSString *, NSString *> *licenseHeaders;
@property(nonatomic, copy, readonly, nullable) NSString *contentId;
@property(nonatomic, readonly) NSURLSession *session;
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
    _session = [NSURLSession
        sessionWithConfiguration:NSURLSessionConfiguration.defaultSessionConfiguration];
  }
  return self;
}

#pragma mark - AVAssetResourceLoaderDelegate

- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader
    shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest {
  if (![loadingRequest.request.URL.scheme isEqualToString:kFairPlayKeyScheme]) {
    // Not a FairPlay key request; let AVFoundation handle it as it normally would.
    return NO;
  }
  [self loadContentKeyForRequest:loadingRequest];
  return YES;
}

- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader
    shouldWaitForRenewalOfRequestedResource:(AVAssetResourceRenewalRequest *)renewalRequest {
  return [self resourceLoader:resourceLoader
      shouldWaitForLoadingOfRequestedResource:renewalRequest];
}

#pragma mark - Private

/// Runs the FairPlay key exchange for `loadingRequest`, finishing the request with either the CKC
/// or an error.
- (void)loadContentKeyForRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
  [[self.session dataTaskWithURL:self.certificateURL
               completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response,
                                   NSError *_Nullable error) {
                 NSError *validationError = FVPValidateResponse(
                     data, response, error, FVPFairPlayErrorCodeCertificateUnavailable,
                     @"Unable to fetch the FairPlay application certificate");
                 if (validationError != nil) {
                   [loadingRequest finishLoadingWithError:validationError];
                   return;
                 }
                 [self requestLicenseForRequest:loadingRequest certificate:data];
               }] resume];
}

/// Generates the SPC for `loadingRequest` using `certificate`, exchanges it for a CKC, and finishes
/// the request.
- (void)requestLicenseForRequest:(AVAssetResourceLoadingRequest *)loadingRequest
                     certificate:(NSData *)certificate {
  // The content ID defaults to the skd:// URL that AVFoundation asked to resolve, which is what
  // most providers key their licenses on.
  NSString *contentId =
      self.contentId.length > 0 ? self.contentId : loadingRequest.request.URL.absoluteString;
  NSData *contentIdData = [contentId dataUsingEncoding:NSUTF8StringEncoding];

  NSError *spcError;
  NSData *spcData = [loadingRequest streamingContentKeyRequestDataForApp:certificate
                                                       contentIdentifier:contentIdData
                                                                 options:nil
                                                                   error:&spcError];
  if (spcData == nil) {
    [loadingRequest finishLoadingWithError:spcError];
    return;
  }

  NSMutableURLRequest *licenseRequest = [NSMutableURLRequest requestWithURL:self.licenseURL];
  licenseRequest.HTTPMethod = @"POST";
  [licenseRequest setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
  [self.licenseHeaders
      enumerateKeysAndObjectsUsingBlock:^(NSString *name, NSString *value, BOOL *stop) {
        [licenseRequest setValue:value forHTTPHeaderField:name];
      }];
  licenseRequest.HTTPBody = spcData;

  [[self.session dataTaskWithRequest:licenseRequest
                   completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response,
                                       NSError *_Nullable error) {
                     NSError *validationError = FVPValidateResponse(
                         data, response, error, FVPFairPlayErrorCodeLicenseUnavailable,
                         @"Unable to fetch the FairPlay license");
                     if (validationError != nil) {
                       [loadingRequest finishLoadingWithError:validationError];
                       return;
                     }
                     [loadingRequest.dataRequest respondWithData:data];
                     [loadingRequest finishLoading];
                   }] resume];
}

@end
