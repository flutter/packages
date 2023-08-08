// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

/**
 * the CacheSessionManager class is a singleton class responsible for managing an NSOperationQueue
 * named downloadQueue, which can be used to handle download operations efficiently. This type of
 * design is commonly used for managing background tasks, such as downloading and caching content for
 * a video player, to ensure proper concurrency and control over the operations. The singleton pattern
 * guarantees that all parts of the application that need access to the download queue use the same
 * instance, avoiding duplication and synchronization issues.
 */
@interface FVPCacheSessionManager : NSObject

/**
 * @Property downloadQueue
 *
 * NSOperationQueue that is reponsible for download operations.
 */
@property(nonatomic, strong, readonly) NSOperationQueue *downloadQueue;

/**
 * @Property shared
 * 
 * Instance of FVPCacheSessionManager.
 */

+ (instancetype)shared;

@end
