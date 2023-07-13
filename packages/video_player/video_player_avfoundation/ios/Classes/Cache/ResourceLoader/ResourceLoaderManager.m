
#import "ResourceLoaderManager.h"
#import "ResourceLoader.h"

static NSString *kCacheScheme = @"VideoPlayerCache:";

@interface ResourceLoaderManager () <ResourceLoaderDelegate>

@property(nonatomic, strong) NSMutableDictionary<id<NSCoding>, ResourceLoader *> *loaders;

@end

@implementation ResourceLoaderManager

- (instancetype)init {
  self = [super init];
  if (self) {
    _loaders = [NSMutableDictionary dictionary];
  }
  return self;
}

- (void)cleanCache {
  NSLog(@"Loaders: %@", self.loaders);
  [self.loaders removeAllObjects];
}

- (void)cancelLoaders {
  [self.loaders enumerateKeysAndObjectsUsingBlock:^(
                    id<NSCoding> _Nonnull key, ResourceLoader *_Nonnull obj, BOOL *_Nonnull stop) {
    [obj cancel];
  }];
  [self.loaders removeAllObjects];
}

#pragma mark - AVAssetResourceLoaderDelegate

- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader
    shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest {
  NSURL *resourceURL = [loadingRequest.request URL];
  if ([resourceURL.absoluteString hasPrefix:kCacheScheme]) {
    ResourceLoader *loader = [self loaderForRequest:loadingRequest];
    if (!loader) {
      NSURL *originURL = nil;
      NSString *originStr = [resourceURL absoluteString];
      originStr = [originStr stringByReplacingOccurrencesOfString:kCacheScheme withString:@""];
      originURL = [NSURL URLWithString:originStr];
      loader = [[ResourceLoader alloc] initWithURL:originURL];
      loader.delegate = self;
      NSString *key = [self keyForResourceLoaderWithURL:resourceURL];
      self.loaders[key] = loader;
    }
    [loader addRequest:loadingRequest];
    return YES;
  }

  return NO;
}

- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader
    didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
  ResourceLoader *loader = [self loaderForRequest:loadingRequest];
  [loader removeRequest:loadingRequest];
}

#pragma mark - ResourceLoaderDelegate

- (void)resourceLoader:(ResourceLoader *)resourceLoader didFailWithError:(NSError *)error {
  [resourceLoader cancel];
  if ([self.delegate respondsToSelector:@selector(resourceLoaderManagerLoadURL:
                                                              didFailWithError:)]) {
    [self.delegate resourceLoaderManagerLoadURL:resourceLoader.url didFailWithError:error];
  }
}

#pragma mark - Helper

- (NSString *)keyForResourceLoaderWithURL:(NSURL *)requestURL {
  if ([[requestURL absoluteString] hasPrefix:kCacheScheme]) {
    NSString *s = requestURL.absoluteString;
    return s;
  }
  return nil;
}

- (ResourceLoader *)loaderForRequest:(AVAssetResourceLoadingRequest *)request {
  NSString *requestKey = [self keyForResourceLoaderWithURL:request.request.URL];
  ResourceLoader *loader = self.loaders[requestKey];
  return loader;
}

@end

@implementation ResourceLoaderManager (Convenient)

+ (NSURL *)assetURLWithURL:(NSURL *)url {
  if (!url) {
    return nil;
  }

  NSURL *assetURL =
      [NSURL URLWithString:[kCacheScheme stringByAppendingString:[url absoluteString]]];
  return assetURL;
}

- (AVPlayerItem *)playerItemWithURL:(NSURL *)url {
  NSURL *assetURL = [ResourceLoaderManager assetURLWithURL:url];
  AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:assetURL options:nil];
  [urlAsset.resourceLoader setDelegate:self queue:dispatch_get_main_queue()];
  AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:urlAsset];
  if ([playerItem
          respondsToSelector:@selector(setCanUseNetworkResourcesForLiveStreamingWhilePaused:)]) {
    playerItem.canUseNetworkResourcesForLiveStreamingWhilePaused = YES;
  }
  return playerItem;
}

@end
