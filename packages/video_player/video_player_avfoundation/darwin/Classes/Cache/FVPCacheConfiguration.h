// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import "FVPContentInfo.h"

/**
 * The caching configuration keeps track of information related to the cache and content download
 * statistics. This Configuration can be stored,updated and retrieved.
 */
@interface FVPCacheConfiguration : NSObject <NSCopying>

/**
 * Returns a CacheConfiguration based on the provided url.
 *
 * @param filePath of the configuration
 */
+ (NSString *)configurationFilePathForFilePath:(NSString *)filePath;

/**
 * Instanciates a CacheConfiguration based on the provided url. It
 * attempts to unarchive a previously saved configuration from the file. If the file does not exist
 * or the unarchiving fails, a new CacheConfiguration is created and returned.
 *
 * @param filePath of the configuration
 */
+ (instancetype)configurationWithFilePath:(NSString *)filePath error:(NSError **)error;

/**
 * @property filePath
 * FilePath of the stored configuration.
 */
@property(nonatomic, copy, readonly) NSString *filePath;

/**
 * @property contentInfo
 * Information about the content being downloaded or cached.
 */
@property(nonatomic, strong) FVPContentInfo *contentInfo;

/**
 * @property url
 * Information about the content url.
 */
@property(nonatomic, strong) NSURL *url;

/**
 * @property cacheFragments
 * Array of CacheAction objects for a given range.
 */
- (NSArray<NSValue *> *)cacheFragments;

/**
 * @property progress
 * Information progress of the downloaded cache (0-100).
 */
@property(nonatomic, readonly) float progress;

#pragma mark - update API

/**
 * Saves the CacheConfiguration object to disk. It uses NSKeyedArchiver to
 * archive the object and writes the data to the specified file path with a slight delay using
 * performSelector:afterDelay: to avoid excessive disk I/O.
 */
- (void)save;

/**
 * Adds a cache fragment to the internal cache fragments array. It efficiently
 * manages cache fragments, ensuring that overlapping fragments are combined, and new fragments are
 * inserted in the correct order.
 */
- (void)addCacheFragment:(NSRange)fragment;

/**
 * Adds downloaded bytes and time spent to the downloadInfo array. It tracks
 * download statistics for the content.
 */
- (void)addDownloadedBytes:(long long)bytes spent:(NSTimeInterval)time;

@end
