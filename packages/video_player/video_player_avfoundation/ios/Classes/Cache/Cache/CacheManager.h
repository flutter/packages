// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import "CacheConfiguration.h"

extern NSString *CacheConfigurationKey;
extern NSString *CacheFinishedErrorKey;

@interface CacheManager : NSObject

+ (NSString *)cachedFilePathForURL:(NSURL *)url;
+ (CacheConfiguration *)cacheConfigurationForURL:(NSURL *)url error:(NSError **)error;

+ (void)cleanAllCacheWithError:(NSError **)error;

@end
