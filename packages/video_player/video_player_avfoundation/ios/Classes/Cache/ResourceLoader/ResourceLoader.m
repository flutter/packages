
#import "ResourceLoader.h"
#import "ContentCacheWorker.h"
#import "ContentDownloader.h"
#import "ContentInfo.h"
#import "ResourceLoadingRequestWorker.h"

NSString *const MCResourceLoaderErrorDomainE = @"LSFilePlayerResourceLoaderErrorDomain";

@interface ResourceLoader () <ResourceLoadingRequestWorkerDelegate>

@property(nonatomic, strong, readwrite) NSURL *url;
@property(nonatomic, strong) ContentCacheWorker *cacheWorker;
@property(nonatomic, strong) ContentDownloader *contentDownloader;
@property(nonatomic, strong) NSMutableArray<ResourceLoadingRequestWorker *> *pendingRequestWorkers;

@property(nonatomic, getter=isCancelled) BOOL cancelled;

@end

@implementation ResourceLoader

- (void)dealloc {
  [_contentDownloader cancel];
}

- (instancetype)initWithURL:(NSURL *)url {
  self = [super init];
  if (self) {
    _url = url;
    _cacheWorker = [[ContentCacheWorker alloc] initWithURL:url];
    _contentDownloader = [[ContentDownloader alloc] initWithURL:url cacheWorker:_cacheWorker];
    _pendingRequestWorkers = [NSMutableArray array];
  }
  return self;
}

- (instancetype)init {
  NSAssert(NO, @"Use - initWithURL: instead");
  return nil;
}

- (void)addRequest:(AVAssetResourceLoadingRequest *)request {
  if (self.pendingRequestWorkers.count > 0) {
    [self startNoCacheWorkerWithRequest:request];
  } else {
    [self startWorkerWithRequest:request];
  }
}

- (void)removeRequest:(AVAssetResourceLoadingRequest *)request {
  __block ResourceLoadingRequestWorker *requestWorker = nil;
  [self.pendingRequestWorkers
      enumerateObjectsUsingBlock:^(ResourceLoadingRequestWorker *_Nonnull obj, NSUInteger idx,
                                   BOOL *_Nonnull stop) {
        if (obj.request == request) {
          requestWorker = obj;
          *stop = YES;
        }
      }];
  if (requestWorker) {
    [requestWorker finish];
    [self.pendingRequestWorkers removeObject:requestWorker];
  }
}

- (void)cancel {
  [self.contentDownloader cancel];
  [self.pendingRequestWorkers removeAllObjects];

  [[ContentDownloaderStatus shared] removeURL:self.url];
}

#pragma mark - ResourceLoadingRequestWorkerDelegate

- (void)resourceLoadingRequestWorker:(ResourceLoadingRequestWorker *)requestWorker
                didCompleteWithError:(NSError *)error {
  [self removeRequest:requestWorker.request];
  if (error && [self.delegate respondsToSelector:@selector(resourceLoader:didFailWithError:)]) {
    [self.delegate resourceLoader:self didFailWithError:error];
  }
  if (self.pendingRequestWorkers.count == 0) {
    [[ContentDownloaderStatus shared] removeURL:self.url];
  }
}

#pragma mark - Helper

- (void)startNoCacheWorkerWithRequest:(AVAssetResourceLoadingRequest *)request {
  [[ContentDownloaderStatus shared] addURL:self.url];
  ContentDownloader *contentDownloader = [[ContentDownloader alloc] initWithURL:self.url
                                                                    cacheWorker:self.cacheWorker];
  ResourceLoadingRequestWorker *requestWorker =
      [[ResourceLoadingRequestWorker alloc] initWithContentDownloader:contentDownloader
                                               resourceLoadingRequest:request];
  [self.pendingRequestWorkers addObject:requestWorker];
  requestWorker.delegate = self;
  [requestWorker startWork];
}

- (void)startWorkerWithRequest:(AVAssetResourceLoadingRequest *)request {
  [[ContentDownloaderStatus shared] addURL:self.url];
  ResourceLoadingRequestWorker *requestWorker =
      [[ResourceLoadingRequestWorker alloc] initWithContentDownloader:self.contentDownloader
                                               resourceLoadingRequest:request];
  [self.pendingRequestWorkers addObject:requestWorker];
  requestWorker.delegate = self;
  [requestWorker startWork];
}

- (NSError *)loaderCancelledError {
  NSError *error =
      [[NSError alloc] initWithDomain:MCResourceLoaderErrorDomainE
                                 code:-3
                             userInfo:@{NSLocalizedDescriptionKey : @"Resource loader cancelled"}];
  return error;
}

@end
