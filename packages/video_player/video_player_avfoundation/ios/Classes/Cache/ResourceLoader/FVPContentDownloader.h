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
 * Adds url source to downloadingUrls (NSSet of urls)
 */
- (void)addURL:(NSURL *)url;

/**
 * removes url source from downloadingUrls
 */
- (void)removeURL:(NSURL *)url;

/**
 * return YES if downloadingUrls contains the given url
 */
- (BOOL)containsURL:(NSURL *)url;

/**
 * return downloadingUrls set
 */
- (NSSet *)urls;

@end

@interface FVPContentDownloader : NSObject

- (instancetype)initWithURL:(NSURL *)url cacheWorker:(FVPContentCacheWorker *)cacheWorker;

/**
 * @property url
 * url of video
 */
@property(nonatomic, strong, readonly) NSURL *url;

/**
 * @property info
 * hold information about the content
 */
@property(nonatomic, strong) FVPContentInfo *info;

/**
 * @property saveToCache
 * should save to cache
 */
@property(nonatomic, assign) BOOL saveToCache;

/**
 * start download with offset
 */
- (void)downloadTaskFromOffset:(unsigned long long)fromOffset
                        length:(NSUInteger)length
                         toEnd:(BOOL)toEnd;

/**
 * cancels downloading
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
 * callback when download request received response
 */
- (void)contentDownloader:(FVPContentDownloader *)downloader
       didReceiveResponse:(NSURLResponse *)response;

/**
 * callback when received data
 */
- (void)contentDownloader:(FVPContentDownloader *)downloader didReceiveData:(NSData *)data;

/**
 * callback when error received
 */
- (void)contentDownloader:(FVPContentDownloader *)downloader didFinishedWithError:(NSError *)error;

@end
