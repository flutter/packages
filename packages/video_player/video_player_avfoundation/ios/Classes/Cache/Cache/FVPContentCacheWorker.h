// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import "FVPCacheConfiguration.h"

@class FVPCacheAction;

/*!
 responsible for managing the caching of content, particularly for a video player or media streaming
 functionality. It implements methods for reading and writing data to a cache file, handling cache
 fragments, managing cache actions, and tracking cache statistics.
 */
@interface FVPContentCacheWorker : NSObject

- (instancetype)initWithURL:(NSURL *)url;

/*!
 @property cacheConfiguration
 */
@property(nonatomic, strong, readonly) FVPCacheConfiguration *cacheConfiguration;

/*!
 @property setupError
 error callback, returns error when setup fails
 */
@property(nonatomic, strong, readonly) NSError *setupError;

/*!
 @property setupError
 error callback, returns error when setup fails
 */

- (void)cacheData:(NSData *)data forRange:(NSRange)range error:(NSError **)error;

/*!
 This method provides an array of CacheAction objects for a given range. It identifies the cached
 fragments within the range and returns an array of CacheAction objects, representing local and
 remote cache actions.*/
- (NSArray<FVPCacheAction *> *)cachedDataActionsForRange:(NSRange)range;

/*!
 This method retrieves cached data from the file for a given range. It reads the data from the cache
 file using the file handle, based on the provided range.
 */
- (NSData *)cachedDataForRange:(NSRange)range error:(NSError **)error;

/*!
 This method sets the content information for the cache, including the content length. It truncates
 the cache file to the specified content length and saves the content information in the internal
 cache configuration.*/
- (void)setContentInfo:(FVPContentInfo *)contentInfo error:(NSError **)error;

/*!
 This method is used to save the current state of the cache to disk. It synchronizes the file handle
 and saves the internal cache configuration.
 */
- (void)save;

/*!
 startWritting and finishWritting are used to indicate the start and end of writing data to the
 cache file. They keep track of the writing progress and time taken to write data.
 */
- (void)startWritting;

/*!
 startWritting and finishWritting are used to indicate the start and end of writing data to the
 cache file. They keep track of the writing progress and time taken to write data.
 */
- (void)finishWritting;

@end
