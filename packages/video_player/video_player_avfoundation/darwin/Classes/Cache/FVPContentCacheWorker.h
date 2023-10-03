// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import "FVPCacheConfiguration.h"

@class FVPCacheAction;

/**
 * Responsible for caching of (video or audio) content, particularly for a video player or media
 * streaming functionality. It implements methods for reading and writing data to a cache file,
 * handling cache fragments, managing cache actions, and tracking cache statistics.
 */
@interface FVPContentCacheWorker : NSObject

/**
 * Initializes a FVPContentCacheWorker instance with the provided content URL.
 *
 * @param url The URL of the content to be cached.
 * @return A new FVPContentCacheWorker instance, or nil if initialization fails.
 */
- (instancetype)initWithURL:(NSURL *)url NS_DESIGNATED_INITIALIZER;

/**
 * @property cacheConfiguration
 */
@property(nonatomic, strong, readonly) FVPCacheConfiguration *cacheConfiguration;

/**
 * Caches data for a specific range within the content (fragment).
 *
 * @param data The data to be cached.
 * @param range The range within the content where the data should be cached.
 * @param error If an error occurs during caching, this parameter will contain details about the
 * error.
 */
- (void)cacheData:(NSData *)data forRange:(NSRange)range error:(NSError **)error;

/**
 * Exposes the error during initialisation processes for debugging purposes.
 */
@property(nonatomic, strong, readonly) NSError *setupError;

/**
 * Returns an array of CacheAction objects for a given range. It identifies the cached
 * fragments within the range and returns an array of CacheAction objects, representing refreshing
 * cache actions.
 *
 * @param range of cached data actions
 */
- (NSArray<FVPCacheAction *> *)cachedDataActionsForRange:(NSRange)range;

/**
 * This method retrieves cached data from the file for a given range. It reads the data from the
 * cache file using the file handle, based on the provided range.
 *
 * @param range of cached data actions
 */
- (NSData *)cachedDataForRange:(NSRange)range error:(NSError **)error;

/**
 * This method sets the content information for the cache, including the content length. It
 * truncates the cache file to the specified content length and saves the content information in the
 * internal cache configuration.
 *
 * @param contentInfo holds content statistics
 */
- (void)setContentInfo:(FVPContentInfo *)contentInfo error:(NSError **)error;

/**
 * This method is used to save the current state of the cache to disk. It synchronizes the file
 * handle and saves the internal cache configuration.
 */
- (void)save;

/**
 * 'startWritting' is used to indicate the start of writing data to the
 * cache file. They keep track of the writing progress and time taken to write data.
 */
- (void)startWritting;

/**
 * 'finishWritting' is used to indicate the end of writing data to the
 * cache file. They keep track of the writing progress and time taken to write data.
 */
- (void)finishWritting;

@end
