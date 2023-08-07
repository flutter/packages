// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import "FVPContentInfo.h"

/*!
 Provide functionality related to caching configuration and content download statistics. Let's go
 through each class and its methods:
 */
@interface FVPCacheConfiguration : NSObject <NSCopying>

/*!
 return configuration based on the provided filePath
 */
+ (NSString *)configurationFilePathForFilePath:(NSString *)filePath;

/*!
 Ps used to create and retrieve a CacheConfiguration object based on the provided filePath. It
 attempts to unarchive a previously saved configuration from the file. If the file does not exist or
 the unarchiving fails, a new CacheConfiguration object is created and returned.
 */
+ (instancetype)configurationWithFilePath:(NSString *)filePath error:(NSError **)error;

/*!
 @property filePath
 filePath of the stored configuration
 */
@property(nonatomic, copy, readonly) NSString *filePath;

/*!
 @property contentInfo
 information about the content being downloaded or cached
 */
@property(nonatomic, strong) FVPContentInfo *contentInfo;

/*!
 @property url
 information about the content url
 */
@property(nonatomic, strong) NSURL *url;

/*!
 @property cacheFragments
 array of CacheAction objects for a given range
 */
- (NSArray<NSValue *> *)cacheFragments;

/*!
 @property progress
 information progress of the downloaded cache (0-100)
 */
@property(nonatomic, readonly) float progress;

#pragma mark - update API

/*!
 This method is used to save the CacheConfiguration object to disk. It uses NSKeyedArchiver to
 archive the object and writes the data to the specified file path with a slight delay using
 performSelector:afterDelay: to avoid excessive disk I/O.
 */
- (void)save;

/*!
 This method is used to add a cache fragment to the internal cache fragments array. It efficiently
 manages cache fragments, ensuring that overlapping fragments are combined, and new fragments are
 inserted in the correct order.
 */
- (void)addCacheFragment:(NSRange)fragment;

/*!
 This method is used to add downloaded bytes and time spent to the downloadInfo array. It tracks
 download statistics for the content.
 */
- (void)addDownloadedBytes:(long long)bytes spent:(NSTimeInterval)time;

@end

@interface FVPCacheConfiguration (Convenient)

/*!
 This class method is a convenient way to create and save a CacheConfiguration object with download
 statistics for a given URL. It creates a new CacheConfiguration object, sets the content
 information based on the provided URL, and saves it to disk.
 */
+ (BOOL)createAndSaveDownloadedConfigurationForURL:(NSURL *)url error:(NSError **)error;

@end
