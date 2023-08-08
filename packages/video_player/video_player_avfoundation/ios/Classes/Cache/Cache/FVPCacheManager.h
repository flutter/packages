// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import "FVPCacheConfiguration.h"

extern NSString *FVPCacheConfigurationKey;
extern NSString *FVPCacheFinishedErrorKey;

/**
 * responsible for managing caching (directory) of content
 */
@interface FVPCacheManager : NSObject

/**
 * returns filepath for
 * @param file (content) url
 */
+ (NSString *)cachedFilePathForURL:(NSURL *)url;

/**
 * returns CacheConfiguration for
 * @param file (content) url
 */
+ (FVPCacheConfiguration *)cacheConfigurationForURL:(NSURL *)url error:(NSError **)error;

/**
 * removes all (downloading)files in cache directory
 */
+ (void)cleanAllCacheWithError:(NSError **)error;

@end
