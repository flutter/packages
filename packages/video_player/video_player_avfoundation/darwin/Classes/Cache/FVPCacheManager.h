// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import "FVPCacheConfiguration.h"

/**
 * Responsible for managing caching (directory) of content.
 */

extern NSString *CacheConfigurationKey;
extern NSString *CacheFinishedErrorKey;

@interface FVPCacheManager : NSObject

/**
 * Returns cache filepath for content url.
 */
+ (NSString *)cachedFilePathForURL:(NSURL *)url;

+ (FVPCacheConfiguration *)cacheConfigurationForURL:(NSURL *)url error:(NSError **)error;

/**
 * Removes all files in cache directory and all downloading (in progress) files.
 */
+ (void)cleanAllCacheWithError:(NSError **)error;

/**
 * Currently used for testing pusposes.
 */
+ (void)setCacheDirectory:(NSString *)cacheDirectory;

/**
 * Currently used for debugging pusposes. It returns the total size of the cache files.
 * Size = 0 when cache is empty.
 */
+ (unsigned long long)calculateCachedSizeWithError:(NSError **)error;

@end
