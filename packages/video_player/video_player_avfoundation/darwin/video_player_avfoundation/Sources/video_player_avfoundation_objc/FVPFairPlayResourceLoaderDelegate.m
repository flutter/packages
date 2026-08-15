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
/// The task currently servicing each in-flight loading request.
///
/// A request is present exactly while it is being serviced, so this doubles as the record of which
/// requests are still live: AVFoundation can cancel a request at any point, after which the request
/// must not be finished. Keys are weak because AVFoundation owns the requests.
///
/// Mutated from both the resource loader's queue and NSURLSession's queue, so all access is
/// synchronized on the receiver.
@property(nonatomic, readonly)
    NSMapTable<AVAssetResourceLoadingRequest *, NSURLSessionTask *> *tasksByRequest;
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
    _tasksByRequest = [NSMapTable weakToStrongObjectsMapTable];
  }
  return self;
}

- (void)dealloc {
  // Cancels any key exchange still in flight, and releases the session, which would otherwise
  // outlive the delegate until its requests time out.
  [_session invalidateAndCancel];
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

- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader
    didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
  // AVFoundation gives up on the request when this is called - for example on seek, item
  // replacement, or teardown - so stop the exchange and make sure nothing finishes the request
  // afterwards.
  NSURLSessionTask *task;
  @synchronized(self) {
    task = [self.tasksByRequest objectForKey:loadingRequest];
    [self.tasksByRequest removeObjectForKey:loadingRequest];
  }
  [task cancel];
}

#pragma mark - Request tracking

/// Records `task` as the work in flight for `request`.
- (void)trackRequest:(AVAssetResourceLoadingRequest *)request task:(NSURLSessionTask *)task {
  @synchronized(self) {
    [self.tasksByRequest setObject:task forKey:request];
  }
}

/// Returns whether `request` is still live, i.e. hasn't been cancelled.
- (BOOL)isTrackingRequest:(AVAssetResourceLoadingRequest *)request {
  @synchronized(self) {
    return [self.tasksByRequest objectForKey:request] != nil;
  }
}

/// Swaps in `task` as the work in flight for `request`, returning NO if `request` was cancelled in
/// the meantime, in which case `task` is not tracked and must not be started.
- (BOOL)replaceTaskForRequest:(AVAssetResourceLoadingRequest *)request
                     withTask:(NSURLSessionTask *)task {
  @synchronized(self) {
    if ([self.tasksByRequest objectForKey:request] == nil) {
      return NO;
    }
    [self.tasksByRequest setObject:task forKey:request];
    return YES;
  }
}

/// Stops tracking `request`, returning NO if it was already cancelled, in which case the caller
/// must not finish it.
- (BOOL)finishTrackingRequest:(AVAssetResourceLoadingRequest *)request {
  @synchronized(self) {
    if ([self.tasksByRequest objectForKey:request] == nil) {
      return NO;
    }
    [self.tasksByRequest removeObjectForKey:request];
    return YES;
  }
}

#pragma mark - Private

/// Runs the FairPlay key exchange for `loadingRequest`, finishing the request with either the CKC
/// or an error.
- (void)loadContentKeyForRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
  // The block holds the delegate weakly: the session retains its tasks, which retain this block, so
  // capturing self strongly would keep the delegate - and through it the player item - alive until
  // the request completed or timed out.
  __weak FVPFairPlayResourceLoaderDelegate *weakSelf = self;
  NSURLSessionTask *task = [self.session
        dataTaskWithURL:self.certificateURL
      completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response,
                          NSError *_Nullable error) {
        FVPFairPlayResourceLoaderDelegate *strongSelf = weakSelf;
        if (strongSelf == nil || ![strongSelf isTrackingRequest:loadingRequest]) {
          // The player was torn down, or the request was cancelled, while the certificate was in
          // flight.
          return;
        }
        NSError *validationError =
            FVPValidateResponse(data, response, error, FVPFairPlayErrorCodeCertificateUnavailable,
                                @"Unable to fetch the FairPlay application certificate");
        if (validationError != nil) {
          if ([strongSelf finishTrackingRequest:loadingRequest]) {
            [loadingRequest finishLoadingWithError:validationError];
          }
          return;
        }
        [strongSelf requestLicenseForRequest:loadingRequest certificate:data];
      }];
  // Tracked before starting so that a cancellation arriving immediately can find the task. This
  // runs on the resource loader's queue, the same queue cancellations arrive on, so the task can't
  // be cancelled between these two lines.
  [self trackRequest:loadingRequest task:task];
  [task resume];
}

/// Generates the SPC for `loadingRequest` using `certificate`, exchanges it for a CKC, and finishes
/// the request.
- (void)requestLicenseForRequest:(AVAssetResourceLoadingRequest *)loadingRequest
                     certificate:(NSData *)certificate {
  // The content ID defaults to the full skd:// URI that AVFoundation asked to resolve. Providers
  // differ on what they expect here: some key licenses on the whole URI, others on just the
  // identifier within it. Anything other than the full URI has to be supplied explicitly via
  // FairPlayDrmConfiguration.contentId.
  NSString *contentId =
      self.contentId.length > 0 ? self.contentId : loadingRequest.request.URL.absoluteString;
  NSData *contentIdData = [contentId dataUsingEncoding:NSUTF8StringEncoding];

  NSError *spcError;
  NSData *spcData = [loadingRequest streamingContentKeyRequestDataForApp:certificate
                                                       contentIdentifier:contentIdData
                                                                 options:nil
                                                                   error:&spcError];
  if (spcData == nil) {
    if ([self finishTrackingRequest:loadingRequest]) {
      [loadingRequest finishLoadingWithError:spcError];
    }
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

  __weak FVPFairPlayResourceLoaderDelegate *weakSelf = self;
  NSURLSessionTask *task = [self.session
      dataTaskWithRequest:licenseRequest
        completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response,
                            NSError *_Nullable error) {
          FVPFairPlayResourceLoaderDelegate *strongSelf = weakSelf;
          if (strongSelf == nil || ![strongSelf finishTrackingRequest:loadingRequest]) {
            // The player was torn down, or the request was cancelled, while the license was in
            // flight.
            return;
          }
          NSError *validationError =
              FVPValidateResponse(data, response, error, FVPFairPlayErrorCodeLicenseUnavailable,
                                  @"Unable to fetch the FairPlay license");
          if (validationError != nil) {
            [loadingRequest finishLoadingWithError:validationError];
            return;
          }
          [loadingRequest.dataRequest respondWithData:data];
          [loadingRequest finishLoading];
        }];
  // Unlike the certificate request, this runs on the session's queue rather than the resource
  // loader's, so the request may already have been cancelled.
  if (![self replaceTaskForRequest:loadingRequest withTask:task]) {
    return;
  }
  [task resume];
}

@end
