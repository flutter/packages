// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

/**
 * FVPCacheTypeIgnoreLocal and FVPCacheTypeUseLocal are cache optimization options.
 * FVPCacheTypeIgnoreLocal acts as a local cache refresh action by setting the
 * NSURLRequestReloadIgnoringLocalAndRemoteCacheData flag. When this cache policy is used, it means
 * Ignore local cache data, and instruct proxies and other intermediates to disregard their caches
 * so far as the protocol allows. FVPCacheTypeUseLocal uses localCache. It does not validate the
 * relevance of it.
 */
typedef enum { FVPCacheTypeUseLocal = 0, FVPCacheTypeIgnoreLocal } FVPCacheType;

@interface FVPCacheAction : NSObject

/**
 * Returns a instance using the provided cacheType and range.
 */
- (instancetype)initWithCacheType:(FVPCacheType)cacheType range:(NSRange)range;

/**
 * @property cacheType
 */
@property(nonatomic) FVPCacheType cacheType;

/**
 * @property range for a cache fragement
 */
@property(nonatomic) NSRange range;

@end
