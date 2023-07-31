// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import "CacheConfiguration.h"

extern NSString *CacheConfigurationKey;
extern NSString *CacheFinishedErrorKey;

/*!
 responsible for managing caching (directory) of content
 */
@interface CacheManager : NSObject

/*!
 returns filepath for file (content) url
 */
+ (NSString *)cachedFilePathForURL:(NSURL *)url;

/*!
 returns CacheConfiguration for file (content) url
 */
+ (CacheConfiguration *)cacheConfigurationForURL:(NSURL *)url error:(NSError **)error;

/*!
 removes all (downloading)files in cache directory
 */
+ (void)cleanAllCacheWithError:(NSError **)error;

@end
