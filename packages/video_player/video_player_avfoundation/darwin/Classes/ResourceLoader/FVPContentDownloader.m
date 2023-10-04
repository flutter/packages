// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FVPContentDownloader.h"
#import <CoreServices/CoreServices.h>
#import "FVPCacheSessionManager.h"
#import "FVPContentInfo.h"

#import "FVPCacheAction.h"
#import "FVPCacheManager.h"
#import "FVPContentCacheWorker.h"

#pragma mark - Class: FVPURLSessionDelegateObject

@protocol FVPURLSessionDelegateObjectDelegate <NSObject>

- (void)URLSession:(NSURLSession *)session
    didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
      completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition,
                                  NSURLCredential *_Nullable))completionHandler;
- (void)URLSession:(NSURLSession *)session
              dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveResponse:(NSURLResponse *)response
     completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler;
- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data;
- (void)URLSession:(NSURLSession *)session
                    task:(NSURLSessionTask *)task
    didCompleteWithError:(nullable NSError *)error;

@end

static NSInteger kBufferSize = 10 * 1024;

@interface FVPURLSessionDelegateObject : NSObject <NSURLSessionDelegate>

- (instancetype)initWithDelegate:(id<FVPURLSessionDelegateObjectDelegate>)delegate;

@property(nonatomic, weak) id<FVPURLSessionDelegateObjectDelegate> delegate;
@property(nonatomic, strong) NSMutableData *bufferData;

@end

@implementation FVPURLSessionDelegateObject

- (instancetype)initWithDelegate:(id<FVPURLSessionDelegateObjectDelegate>)delegate {
  self = [super init];
  if (self) {
    _delegate = delegate;
    _bufferData = [NSMutableData data];
  }
  return self;
}

#pragma mark - NSURLSessionDataDelegate
- (void)URLSession:(NSURLSession *)session
    didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
      completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition,
                                  NSURLCredential *_Nullable))completionHandler {
  [self.delegate URLSession:session
        didReceiveChallenge:challenge
          completionHandler:completionHandler];
}

- (void)URLSession:(NSURLSession *)session
              dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveResponse:(NSURLResponse *)response
     completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
  [self.delegate URLSession:session
                   dataTask:dataTask
         didReceiveResponse:response
          completionHandler:completionHandler];
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
  @synchronized(self.bufferData) {
    [self.bufferData appendData:data];
    if (self.bufferData.length > kBufferSize) {
      NSRange chunkRange = NSMakeRange(0, self.bufferData.length);
      NSData *chunkData = [self.bufferData subdataWithRange:chunkRange];
      [self.bufferData replaceBytesInRange:chunkRange withBytes:NULL length:0];
      [self.delegate URLSession:session dataTask:dataTask didReceiveData:chunkData];
    }
  }
}

- (void)URLSession:(NSURLSession *)session
                    task:(NSURLSessionDataTask *)task
    didCompleteWithError:(nullable NSError *)error {
  @synchronized(self.bufferData) {
    if (self.bufferData.length > 0 && !error) {
      NSRange chunkRange = NSMakeRange(0, self.bufferData.length);
      NSData *chunkData = [self.bufferData subdataWithRange:chunkRange];
      [self.bufferData replaceBytesInRange:chunkRange withBytes:NULL length:0];
      [self.delegate URLSession:session dataTask:task didReceiveData:chunkData];
    }
  }
  [self.delegate URLSession:session task:task didCompleteWithError:error];
}

@end

#pragma mark - Class: ActionWorker

@class FVPActionWorker;

// This class is responsible for processing a sequence of FVPCacheAction objects to fetch content
// data from a URL either from a local cache or a remote server. It acts as an intermediary between
// the caching mechanism (ContentCacheWorker) and the URL session data task (NSURLSessionDataTask).
@protocol FVPActionWorkerDelegate <NSObject>

- (void)actionWorker:(FVPActionWorker *)actionWorker didReceiveResponse:(NSURLResponse *)response;
- (void)actionWorker:(FVPActionWorker *)actionWorker
      didReceiveData:(NSData *)data
             isLocal:(BOOL)isLocal;
- (void)actionWorker:(FVPActionWorker *)actionWorker didFinishWithError:(NSError *)error;

@end

@interface FVPActionWorker : NSObject <FVPURLSessionDelegateObjectDelegate>

@property(nonatomic, strong) NSMutableArray<FVPCacheAction *> *actions;
- (instancetype)initWithActions:(NSArray<FVPCacheAction *> *)actions
                            url:(NSURL *)url
                    cacheWorker:(FVPContentCacheWorker *)cacheWorker;

@property(nonatomic, assign) BOOL canSaveToCache;
@property(nonatomic, weak) id<FVPActionWorkerDelegate> delegate;

- (void)start;
- (void)cancel;

@property(nonatomic, getter=isCancelled) BOOL cancelled;

@property(nonatomic, strong) FVPContentCacheWorker *cacheWorker;
@property(nonatomic, strong) NSURL *url;

@property(nonatomic, strong) NSURLSession *session;
@property(nonatomic, strong) FVPURLSessionDelegateObject *sessionDelegateObject;
@property(nonatomic, strong) NSURLSessionDataTask *task;
@property(nonatomic) NSInteger startOffset;

@end

@interface FVPActionWorker ()

@property(nonatomic) NSTimeInterval notifyTime;

@end

@implementation FVPActionWorker

- (void)dealloc {
  [self cancel];
}

- (instancetype)initWithActions:(NSArray<FVPCacheAction *> *)actions
                            url:(NSURL *)url
                    cacheWorker:(FVPContentCacheWorker *)cacheWorker {
  self = [super init];
  if (self) {
    _canSaveToCache = YES;
    _actions = [actions mutableCopy];
    _cacheWorker = cacheWorker;
    _url = url;
  }
  return self;
}

- (void)start {
  [self processActions];
}

// Cancel NSURLSession
- (void)cancel {
  if (_session) {
    [self.session invalidateAndCancel];
  }
  self.cancelled = YES;
}

- (FVPURLSessionDelegateObject *)sessionDelegateObject {
  if (!_sessionDelegateObject) {
    _sessionDelegateObject = [[FVPURLSessionDelegateObject alloc] initWithDelegate:self];
  }

  return _sessionDelegateObject;
}

// returns the NSURLSession with a default configuration; a sessionDelegateObject and (our) download
// queu.
- (NSURLSession *)session {
  if (!_session) {
    NSURLSessionConfiguration *configuration =
        [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session =
        [NSURLSession sessionWithConfiguration:configuration
                                      delegate:self.sessionDelegateObject
                                 delegateQueue:[FVPCacheSessionManager shared].downloadQueue];
    _session = session;
  }
  return _session;
}

- (void)processActions {
  if (self.isCancelled) {
    return;
  }

  FVPCacheAction *action = [self popFirstActionInList];
  if (!action) {
    return;
  }

  // FVPCacheTypeLocal
  if (action.cacheType == FVPCacheTypeUseLocal) {
    NSError *error;
    NSData *data = [self.cacheWorker cachedDataForRange:action.range error:&error];
    if (error) {
      if ([self.delegate respondsToSelector:@selector(actionWorker:didFinishWithError:)]) {
        [self.delegate actionWorker:self didFinishWithError:error];
      }
    } else {
      if ([self.delegate respondsToSelector:@selector(actionWorker:didReceiveData:isLocal:)]) {
        [self.delegate actionWorker:self didReceiveData:data isLocal:YES];
      }
      [self processActionsLater];
    }
  } else {
    // FVPCacheTypeRemote or default
    long long fromOffset = action.range.location;
    long long endOffset = action.range.location + action.range.length - 1;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.url];
    request.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
    NSString *range = [NSString stringWithFormat:@"bytes=%lld-%lld", fromOffset, endOffset];
    [request setValue:range forHTTPHeaderField:@"Range"];
    self.startOffset = action.range.location;
    self.task = [self.session dataTaskWithRequest:request];
    [self.task resume];
  }
}

// process data recursively,
- (void)processActionsLater {
  __weak typeof(self) weakSelf = self;
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    __strong typeof(self) self = weakSelf;
    [self processActions];
  });
}

- (FVPCacheAction *)popFirstActionInList {
  @synchronized(self) {
    FVPCacheAction *action = [self.actions firstObject];
    if (action) {
      [self.actions removeObjectAtIndex:0];
      return action;
    }
  }
  if ([self.delegate respondsToSelector:@selector(actionWorker:didFinishWithError:)]) {
    [self.delegate actionWorker:self didFinishWithError:nil];
  }
  return nil;
}

#pragma mark - FVPURLSessionDelegateObjectDelegate

- (void)URLSession:(NSURLSession *)session
    didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
      completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition,
                                  NSURLCredential *_Nullable))completionHandler {
  NSURLCredential *card =
      [[NSURLCredential alloc] initWithTrust:challenge.protectionSpace.serverTrust];
  completionHandler(NSURLSessionAuthChallengeUseCredential, card);
}

- (void)URLSession:(NSURLSession *)session
              dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveResponse:(NSURLResponse *)response
     completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
  NSString *mimeType = response.MIMEType;
  // Only download video/audio data, else cancel the NSUrlSession
  if ([mimeType rangeOfString:@"video/"].location == NSNotFound &&
      [mimeType rangeOfString:@"audio/"].location == NSNotFound) {
    completionHandler(NSURLSessionResponseCancel);
  } else {
    if ([self.delegate respondsToSelector:@selector(actionWorker:didReceiveResponse:)]) {
      [self.delegate actionWorker:self didReceiveResponse:response];
    }
    if (self.canSaveToCache) {
      [self.cacheWorker startWritting];
    }
    completionHandler(NSURLSessionResponseAllow);
  }
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
  if (self.isCancelled) {
    return;
  }

  if (self.canSaveToCache) {
    NSRange range = NSMakeRange(self.startOffset, data.length);
    NSError *error;
    [self.cacheWorker cacheData:data forRange:range error:&error];
    if (error) {
      if ([self.delegate respondsToSelector:@selector(actionWorker:didFinishWithError:)]) {
        [self.delegate actionWorker:self didFinishWithError:error];
      }
      return;
    }
    [self.cacheWorker save];
  }

  self.startOffset += data.length;
  if ([self.delegate respondsToSelector:@selector(actionWorker:didReceiveData:isLocal:)]) {
    [self.delegate actionWorker:self didReceiveData:data isLocal:NO];
  }

  //    [self notifyDownloadProgressWithFlush:NO finished:NO];
}

- (void)URLSession:(NSURLSession *)session
                    task:(NSURLSessionTask *)task
    didCompleteWithError:(nullable NSError *)error {
  if (self.canSaveToCache) {
    [self.cacheWorker finishWritting];
    [self.cacheWorker save];
  }
  if (error) {
    if ([self.delegate respondsToSelector:@selector(actionWorker:didFinishWithError:)]) {
      [self.delegate actionWorker:self didFinishWithError:error];
    }
    //        [self notifyDownloadFinishedWithError:error];
  } else {
    //        [self notifyDownloadProgressWithFlush:YES finished:YES];
    [self processActions];
  }
}

@end

#pragma mark - Class: FVPContentDownloaderStatus

// This class manages the status of content downloading by keeping track of URLs that are currently
// being downloaded. It uses a shared instance pattern (shared) to maintain a central state for all
// downloaders.

@interface FVPContentDownloaderStatus ()

@property(nonatomic, strong) NSMutableSet *downloadingURLS;

@end

@implementation FVPContentDownloaderStatus

+ (instancetype)shared {
  static FVPContentDownloaderStatus *instance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    instance = [[self alloc] init];
    instance.downloadingURLS = [NSMutableSet set];
  });

  return instance;
}

- (void)addURL:(NSURL *)url {
  // to prevent threading issues.
  @synchronized(self.downloadingURLS) {
    [self.downloadingURLS addObject:url];
  }
}

- (void)removeURL:(NSURL *)url {
  @synchronized(self.downloadingURLS) {
    [self.downloadingURLS removeObject:url];
  }
}

- (BOOL)containsURL:(NSURL *)url {
  @synchronized(self.downloadingURLS) {
    return [self.downloadingURLS containsObject:url];
  }
}

- (NSSet *)urls {
  // returns a copy of the downloadingUrls.
  return [self.downloadingURLS copy];
}

@end

#pragma mark - Class: FVPContentDownloader

@interface FVPContentDownloader () <FVPActionWorkerDelegate>

@property(nonatomic, strong) NSURL *url;
@property(nonatomic, strong) NSURLSessionDataTask *task;

@property(nonatomic, strong) FVPContentCacheWorker *cacheWorker;
@property(nonatomic, strong) FVPActionWorker *actionWorker;

@property(nonatomic) BOOL downloadToEnd;

@end

// This class handles content downloading from a URL. It interacts with a
// FVPContentCacheWorker for caching the downloaded content and uses an FVPActionWorker for handling
// the downloading process.
@implementation FVPContentDownloader

- (void)dealloc {
  // Remove the url from the current downloading URL's NSSet.
  [[FVPContentDownloaderStatus shared] removeURL:self.url];
}

- (instancetype)init NS_UNAVAILABLE {
  NSAssert(NO, @"Use - initWithURL:cacheWorker: instead");
  return nil;
}

- (instancetype)initWithURL:(NSURL *)url cacheWorker:(FVPContentCacheWorker *)cacheWorker {
  self = [super init];
  if (self) {
    _saveToCache = YES;
    _url = url;
    _cacheWorker = cacheWorker;

    _info = _cacheWorker.cacheConfiguration.contentInfo;

    // add url to NSSet of downloadingUrls to keep track of urls that are currently downloading.
    [[FVPContentDownloaderStatus shared] addURL:self.url];
  }
  return self;
}

- (void)downloadTaskFromOffset:(unsigned long long)fromOffset
                        length:(NSUInteger)length
                         toEnd:(BOOL)toEnd {
  // ---
  NSRange range = NSMakeRange((NSUInteger)fromOffset, length);

  if (toEnd) {
    range.length =
        (NSUInteger)self.cacheWorker.cacheConfiguration.contentInfo.contentLength - range.location;
  }

  NSArray *actions = [self.cacheWorker cachedDataActionsForRange:range];

  self.actionWorker = [[FVPActionWorker alloc] initWithActions:actions
                                                           url:self.url
                                                   cacheWorker:self.cacheWorker];
  self.actionWorker.canSaveToCache = self.saveToCache;
  self.actionWorker.delegate = self;
  [self.actionWorker start];
}

- (void)cancel {
  self.actionWorker.delegate = nil;

  // Remove the url from the current downloading URL's NSSet.
  [[FVPContentDownloaderStatus shared] removeURL:self.url];
  [self.actionWorker cancel];
  self.actionWorker = nil;
}

#pragma mark - ActionWorkerDelegate

- (void)actionWorker:(FVPActionWorker *)actionWorker didReceiveResponse:(NSURLResponse *)response {
  if (!self.info) {
    FVPContentInfo *info = [FVPContentInfo new];

    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
      NSHTTPURLResponse *HTTPURLResponse = (NSHTTPURLResponse *)response;
      NSString *acceptRange = HTTPURLResponse.allHeaderFields[@"Accept-Ranges"];
      info.byteRangeAccessSupported = [acceptRange isEqualToString:@"bytes"];
      info.contentLength = [[[HTTPURLResponse.allHeaderFields[@"Content-Range"]
          componentsSeparatedByString:@"/"] lastObject] longLongValue];
    }
    NSString *mimeType = response.MIMEType;
    CFStringRef contentType = UTTypeCreatePreferredIdentifierForTag(
        kUTTagClassMIMEType, (__bridge CFStringRef)(mimeType), NULL);
    info.contentType = CFBridgingRelease(contentType);
    self.info = info;

    NSError *error;
    [self.cacheWorker setContentInfo:info error:&error];
    if (error) {
      if ([self.delegate respondsToSelector:@selector(contentDownloader:didFinishedWithError:)]) {
        [self.delegate contentDownloader:self didFinishedWithError:error];
      }
      return;
    }
  }

  if ([self.delegate respondsToSelector:@selector(contentDownloader:didReceiveResponse:)]) {
    [self.delegate contentDownloader:self didReceiveResponse:response];
  }
}

- (void)actionWorker:(FVPActionWorker *)actionWorker
      didReceiveData:(NSData *)data
             isLocal:(BOOL)isLocal {
  if ([self.delegate respondsToSelector:@selector(contentDownloader:didReceiveData:)]) {
    [self.delegate contentDownloader:self didReceiveData:data];
  }
}

- (void)actionWorker:(FVPActionWorker *)actionWorker didFinishWithError:(NSError *)error {
  // Remove the url from the current downloading URL's NSSet.

  [[FVPContentDownloaderStatus shared] removeURL:self.url];

  if (!error && self.downloadToEnd) {
    self.downloadToEnd = NO;
    [self downloadTaskFromOffset:2
                          length:(NSUInteger)(self.cacheWorker.cacheConfiguration.contentInfo
                                                  .contentLength -
                                              2)
                           toEnd:YES];
  } else {
    if ([self.delegate respondsToSelector:@selector(contentDownloader:didFinishedWithError:)]) {
      [self.delegate contentDownloader:self didFinishedWithError:error];
    }
  }
}

@end
