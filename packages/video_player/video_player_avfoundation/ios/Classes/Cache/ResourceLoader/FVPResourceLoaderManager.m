// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FVPResourceLoaderManager.h"
#import "FVPResourceLoader.h"

static NSString *kCacheScheme = @"FVPVideoPlayerCache:";

@interface FVPResourceLoaderManager () <FVPResourceLoaderDelegate>

@property(nonatomic, strong) NSMutableDictionary<id<NSCoding>, FVPResourceLoader *> *loaders;

@end

@implementation FVPResourceLoaderManager

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
  [self.loaders
      enumerateKeysAndObjectsUsingBlock:^(id<NSCoding> _Nonnull key,
                                          FVPResourceLoader *_Nonnull obj, BOOL *_Nonnull stop) {
        [obj cancel];
      }];
  [self.loaders removeAllObjects];
}

#pragma mark - AVAssetResourceLoaderDelegate

- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader
    shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest {
  NSURL *resourceURL = [loadingRequest.request URL];
  if ([resourceURL.absoluteString hasPrefix:kCacheScheme]) {
    FVPResourceLoader *loader = [self loaderForRequest:loadingRequest];
    if (!loader) {
      NSURL *originURL = nil;
      NSString *originStr = [resourceURL absoluteString];
      originStr = [originStr stringByReplacingOccurrencesOfString:kCacheScheme withString:@""];
      originURL = [NSURL URLWithString:originStr];
      loader = [[FVPResourceLoader alloc] initWithURL:originURL];
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
  FVPResourceLoader *loader = [self loaderForRequest:loadingRequest];
  [loader removeRequest:loadingRequest];
}

#pragma mark - ResourceLoaderDelegate

- (void)resourceLoader:(FVPResourceLoader *)resourceLoader didFailWithError:(NSError *)error {
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

- (FVPResourceLoader *)loaderForRequest:(AVAssetResourceLoadingRequest *)request {
  NSString *requestKey = [self keyForResourceLoaderWithURL:request.request.URL];
  FVPResourceLoader *loader = self.loaders[requestKey];
  return loader;
}

+ (NSURL *)assetURLWithURL:(NSURL *)url {
  if (!url) {
    return nil;
  }

  NSURL *assetURL =
      [NSURL URLWithString:[kCacheScheme stringByAppendingString:[url absoluteString]]];
  return assetURL;
}

- (AVPlayerItem *)playerItemWithURL:(NSURL *)url {
  NSURL *assetURL = [FVPResourceLoaderManager assetURLWithURL:url];
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
