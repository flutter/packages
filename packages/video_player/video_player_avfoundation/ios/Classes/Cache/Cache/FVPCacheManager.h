// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import "FVPCacheConfiguration.h"

/**
 * responsible for managing caching (directory) of content
 */
@interface FVPCacheManager : NSObject

/**
 * returns cache filepath for content url
 */
+ (NSString *)cachedFilePathForURL:(NSURL *)url;

/**
 * removes all files in cache directory and all downloading (in progress) files.
 */
+ (void)cleanAllCacheWithError:(NSError **)error;

/**
 * currently used for testing pusposes. 
 */
+ (void)setCacheDirectory:(NSString *)cacheDirectory;

/**
 * currently used for debugging pusposes. It returns the total size of the cache files. Size = 0
 * when cache is empty
 */
+ (unsigned long long)calculateCachedSizeWithError:(NSError **)error;

@end
