// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

/**
* `FVPCacheSessionManager` is a singleton class responsible for managing the download operations
related to caching media content. It provides a shared instance for coordinating download tasks,
ensuring controlled concurrent downloads within the application.

*  Usage:
*  1. Access the shared instance of `FVPCacheSessionManager` using the `shared` class method.
*  2. Enqueue download operations using the `downloadQueue` property.

*  Example:
*  // Access the shared instance of FVPCacheSessionManager
*  FVPCacheSessionManager *cacheManager = [FVPCacheSessionManager shared];

*  // Create and enqueue a download operation
*  NSOperation *downloadOperation = [NSBlockOperation blockOperationWithBlock:^{
*      // Perform the download operation here
*  }];
*  [cacheManager.downloadQueue addOperation:downloadOperation];
* @warning It is recommended to use the shared instance for download operations to ensure efficient
resource utilization and control over concurrent downloads.
*
* @see NSOperationQueue
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
