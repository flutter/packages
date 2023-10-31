// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

@protocol FVPContentDownloaderDelegate;
@class FVPContentInfo;
@class FVPContentCacheWorker;

@interface FVPContentDownloaderStatus : NSObject

+ (instancetype)shared;

/**
 * Adds url source to downloadingUrls (NSSet of urls).
 */
- (void)addURL:(NSURL *)url;

/**
 * Removes url source from downloadingUrls.
 */
- (void)removeURL:(NSURL *)url;

/**
 * Returns YES if downloadingUrls contains the given url.
 */
- (BOOL)containsURL:(NSURL *)url;

/**
 * Return downloadingUrls set.
 */
- (NSSet *)urls;

@end

@interface FVPContentDownloader : NSObject

- (instancetype)initWithURL:(NSURL *)url
                cacheWorker:(FVPContentCacheWorker *)cacheWorker NS_DESIGNATED_INITIALIZER;

/**
 * @property url
 * URL of media content.
 */
@property(nonatomic, strong, readonly) NSURL *url;

/**
 * @property info
 * Hold information about the content.
 */
@property(nonatomic, strong) FVPContentInfo *info;

/**
 * @property saveToCache
 * Should save to cache.
 */
@property(nonatomic, assign) BOOL saveToCache;

/**
 * Start download with offset.
 */
- (void)downloadTaskFromOffset:(unsigned long long)fromOffset
                        length:(NSUInteger)length
                         toEnd:(BOOL)toEnd;

/**
 * Cancels downloading.
 */
- (void)cancel;

/**
 * ContentDownloaderDelegate
 */
@property(nonatomic, weak) id<FVPContentDownloaderDelegate> delegate;

@end

@protocol FVPContentDownloaderDelegate <NSObject>

@optional

/**
 * Callback when download request received response.
 */
- (void)contentDownloader:(FVPContentDownloader *)downloader
       didReceiveResponse:(NSURLResponse *)response;

/**
 * Callback when received data.
 */
- (void)contentDownloader:(FVPContentDownloader *)downloader didReceiveData:(NSData *)data;

/**
 * Callback when error received.
 */
- (void)contentDownloader:(FVPContentDownloader *)downloader didFinishedWithError:(NSError *)error;

@end
