// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FVPCacheSessionManager.h"

@interface FVPCacheSessionManager ()

@property(nonatomic, strong) NSOperationQueue *downloadQueue;

@end

@implementation FVPCacheSessionManager

+ (instancetype)shared {
  static id instance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    instance = [[self alloc] init];
  });

  return instance;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.name = @"video_player.download_cache_queue";
    _downloadQueue = queue;
  }
  return self;
}

@end
