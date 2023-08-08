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
 * add url source to downloading
 */
- (void)addURL:(NSURL *)url;

/**
 * removes url source from downloading
 */
- (void)removeURL:(NSURL *)url;

/**
 * return YES if downloading the url source
 */
- (BOOL)containsURL:(NSURL *)url;

/**
 * return downloading urls
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
 * @property delegate
 * ContentDownloaderDelegate
 */
@property(nonatomic, weak) id<FVPContentDownloaderDelegate> delegate;

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
 * start download and sets the startToEnd property
 */
- (void)downloadFromStartToEnd;

/**
 * cancels downloading
 */
- (void)cancel;

@end

@protocol FVPContentDownloaderDelegate <NSObject>

@optional

/**
 * callback when received response
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
