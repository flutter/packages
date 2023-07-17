

#import "ContentDownloader.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "CacheSessionManager.h"
#import "ContentInfo.h"

#import "CacheAction.h"
#import "CacheManager.h"
#import "ContentCacheWorker.h"

#pragma mark - Class: URLSessionDelegateObject

@protocol URLSessionDelegateObjectDelegate <NSObject>

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

@interface URLSessionDelegateObject : NSObject <NSURLSessionDelegate>

- (instancetype)initWithDelegate:(id<URLSessionDelegateObjectDelegate>)delegate;

@property(nonatomic, weak) id<URLSessionDelegateObjectDelegate> delegate;
@property(nonatomic, strong) NSMutableData *bufferData;

@end

@implementation URLSessionDelegateObject

- (instancetype)initWithDelegate:(id<URLSessionDelegateObjectDelegate>)delegate {
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

@class ActionWorker;

@protocol ActionWorkerDelegate <NSObject>

- (void)actionWorker:(ActionWorker *)actionWorker didReceiveResponse:(NSURLResponse *)response;
- (void)actionWorker:(ActionWorker *)actionWorker
      didReceiveData:(NSData *)data
             isLocal:(BOOL)isLocal;
- (void)actionWorker:(ActionWorker *)actionWorker didFinishWithError:(NSError *)error;

@end

@interface ActionWorker : NSObject <URLSessionDelegateObjectDelegate>

@property(nonatomic, strong) NSMutableArray<CacheAction *> *actions;
- (instancetype)initWithActions:(NSArray<CacheAction *> *)actions
                            url:(NSURL *)url
                    cacheWorker:(ContentCacheWorker *)cacheWorker;

@property(nonatomic, assign) BOOL canSaveToCache;
@property(nonatomic, weak) id<ActionWorkerDelegate> delegate;

- (void)start;
- (void)cancel;

@property(nonatomic, getter=isCancelled) BOOL cancelled;

@property(nonatomic, strong) ContentCacheWorker *cacheWorker;
@property(nonatomic, strong) NSURL *url;

@property(nonatomic, strong) NSURLSession *session;
@property(nonatomic, strong) URLSessionDelegateObject *sessionDelegateObject;
@property(nonatomic, strong) NSURLSessionDataTask *task;
@property(nonatomic) NSInteger startOffset;

@end

@interface ActionWorker ()

@property(nonatomic) NSTimeInterval notifyTime;

@end

@implementation ActionWorker

- (void)dealloc {
  [self cancel];
}

- (instancetype)initWithActions:(NSArray<CacheAction *> *)actions
                            url:(NSURL *)url
                    cacheWorker:(ContentCacheWorker *)cacheWorker {
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

- (void)cancel {
  if (_session) {
    [self.session invalidateAndCancel];
  }
  self.cancelled = YES;
}

- (URLSessionDelegateObject *)sessionDelegateObject {
  if (!_sessionDelegateObject) {
    _sessionDelegateObject = [[URLSessionDelegateObject alloc] initWithDelegate:self];
  }

  return _sessionDelegateObject;
}

- (NSURLSession *)session {
  if (!_session) {
    NSURLSessionConfiguration *configuration =
        [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session =
        [NSURLSession sessionWithConfiguration:configuration
                                      delegate:self.sessionDelegateObject
                                 delegateQueue:[CacheSessionManager shared].downloadQueue];
    _session = session;
  }
  return _session;
}

- (void)processActions {
  if (self.isCancelled) {
    return;
  }

  CacheAction *action = [self popFirstActionInList];
  if (!action) {
    return;
  }

  if (action.cacheType == CacheTypeLocal) {
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

- (CacheAction *)popFirstActionInList {
  @synchronized(self) {
    CacheAction *action = [self.actions firstObject];
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

#pragma mark - URLSessionDelegateObjectDelegate

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
  // Only download video/audio data
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

#pragma mark - Class: ContentDownloaderStatus

@interface ContentDownloaderStatus ()

@property(nonatomic, strong) NSMutableSet *downloadingURLS;

@end

@implementation ContentDownloaderStatus

+ (instancetype)shared {
  static ContentDownloaderStatus *instance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    instance = [[self alloc] init];
    instance.downloadingURLS = [NSMutableSet set];
  });

  return instance;
}

- (void)addURL:(NSURL *)url {
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
  return [self.downloadingURLS copy];
}

@end

#pragma mark - Class: ContentDownloader

@interface ContentDownloader () <ActionWorkerDelegate>

@property(nonatomic, strong) NSURL *url;
@property(nonatomic, strong) NSURLSessionDataTask *task;

@property(nonatomic, strong) ContentCacheWorker *cacheWorker;
@property(nonatomic, strong) ActionWorker *actionWorker;

@property(nonatomic) BOOL downloadToEnd;

@end

@implementation ContentDownloader

- (void)dealloc {
  [[ContentDownloaderStatus shared] removeURL:self.url];
}

- (instancetype)initWithURL:(NSURL *)url cacheWorker:(ContentCacheWorker *)cacheWorker {
  self = [super init];
  if (self) {
    _saveToCache = YES;
    _url = url;
    _cacheWorker = cacheWorker;
    _info = _cacheWorker.cacheConfiguration.contentInfo;
    [[ContentDownloaderStatus shared] addURL:self.url];
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

  self.actionWorker = [[ActionWorker alloc] initWithActions:actions
                                                        url:self.url
                                                cacheWorker:self.cacheWorker];
  self.actionWorker.canSaveToCache = self.saveToCache;
  self.actionWorker.delegate = self;
  [self.actionWorker start];
}

- (void)downloadFromStartToEnd {
  // ---
  self.downloadToEnd = YES;
  NSRange range = NSMakeRange(0, 2);
  NSArray *actions = [self.cacheWorker cachedDataActionsForRange:range];

  self.actionWorker = [[ActionWorker alloc] initWithActions:actions
                                                        url:self.url
                                                cacheWorker:self.cacheWorker];
  self.actionWorker.canSaveToCache = self.saveToCache;
  self.actionWorker.delegate = self;
  [self.actionWorker start];
}

- (void)cancel {
  self.actionWorker.delegate = nil;
  [[ContentDownloaderStatus shared] removeURL:self.url];
  [self.actionWorker cancel];
  self.actionWorker = nil;
}

#pragma mark - ActionWorkerDelegate

- (void)actionWorker:(ActionWorker *)actionWorker didReceiveResponse:(NSURLResponse *)response {
  if (!self.info) {
    ContentInfo *info = [ContentInfo new];

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

- (void)actionWorker:(ActionWorker *)actionWorker
      didReceiveData:(NSData *)data
             isLocal:(BOOL)isLocal {
  if ([self.delegate respondsToSelector:@selector(contentDownloader:didReceiveData:)]) {
    [self.delegate contentDownloader:self didReceiveData:data];
  }
}

- (void)actionWorker:(ActionWorker *)actionWorker didFinishWithError:(NSError *)error {
  [[ContentDownloaderStatus shared] removeURL:self.url];

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
