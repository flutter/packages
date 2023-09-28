// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FVPCacheManager.h"
#import "FVPContentDownloader.h"

static NSString *kMContentCacheDirectory;

@implementation FVPCacheManager

+ (void)load {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    [self setCacheDirectory:[NSTemporaryDirectory() stringByAppendingPathComponent:
                                                        @"video_player_temporary_cache_directory"]];
  });
}

// Sets NSTemporaryDirectory cacheDirectory with name.
+ (void)setCacheDirectory:(NSString *)cacheDirectory {
  kMContentCacheDirectory = cacheDirectory;
}

// Returns cacheDirectory for file (content) url.
+ (NSString *)cacheDirectory {
  return kMContentCacheDirectory;
}

+ (NSString *)cachedFilePathForURL:(NSURL *)url {
  //  NSLog(@"%@", url);
  NSString *pathComponent = url.absoluteString;
  return [[self cacheDirectory] stringByAppendingPathComponent:pathComponent];
}

// This method calculates the total size of all the cached files in the cache directory.
// It iterates through each file in the cache directory, retrieves its attributes (including file
// size), and accumulates the total size. If an error occurs during the process, the error parameter
// will be populated.
+ (unsigned long long)calculateCachedSizeWithError:(NSError **)error {
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSString *cacheDirectory = [self cacheDirectory];
  NSArray *files = [fileManager contentsOfDirectoryAtPath:cacheDirectory error:error];
  unsigned long long size = 0;
  if (files) {
    for (NSString *path in files) {
      NSString *filePath = [cacheDirectory stringByAppendingPathComponent:path];
      NSDictionary<NSFileAttributeKey, id> *attribute = [fileManager attributesOfItemAtPath:filePath
                                                                                      error:error];
      if (!attribute) {
        size = -1;
        break;
      }

      size += [attribute fileSize];
    }
  }
  return size;
}

+ (void)cleanAllCacheWithError:(NSError **)error {
  NSMutableSet *downloadingFiles = [NSMutableSet set];

  // Loop over all downloadingUrls (NSSet).
  // Get the cachedfile and confuguration and add them to downloading files.
  [[[FVPContentDownloaderStatus shared] urls]
      enumerateObjectsUsingBlock:^(NSURL *_Nonnull obj, BOOL *_Nonnull stop) {
        NSString *file = [self cachedFilePathForURL:obj];
        [downloadingFiles addObject:file];
      }];

  // Remove files.
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSString *cacheDirectory = [self cacheDirectory];

  NSArray *files = [fileManager contentsOfDirectoryAtPath:cacheDirectory error:error];
  if (files) {
    for (NSString *path in files) {
      NSString *filePath = [cacheDirectory stringByAppendingPathComponent:path];
      if ([downloadingFiles containsObject:filePath]) {
        continue;
      }
      if (![fileManager removeItemAtPath:filePath error:error]) {
        break;
      }
    }
  }
}

@end
