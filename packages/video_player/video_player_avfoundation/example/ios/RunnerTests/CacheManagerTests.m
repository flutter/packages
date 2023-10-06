// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import AVFoundation;
@import video_player_avfoundation;
@import XCTest;
#import "FVPCacheManager.h"
#import "FVPContentDownloader.h"

@interface FVPCacheManagerTests : XCTestCase

@end

@implementation FVPCacheManagerTests

- (void)testCleanAllCacheWithError {
  // Create some temporary files in the cache directory
  NSString *fakeCacheDirectory = NSTemporaryDirectory();
  [FVPCacheManager setCacheDirectory:fakeCacheDirectory];

  NSString *testFile1 = [fakeCacheDirectory stringByAppendingPathComponent:@"test_file_1.txt"];
  [@"Test content 1" writeToFile:testFile1 atomically:YES encoding:NSUTF8StringEncoding error:nil];

  NSString *testFile2 = [fakeCacheDirectory stringByAppendingPathComponent:@"test_file_2.txt"];
  [@"Test content 2" writeToFile:testFile2 atomically:YES encoding:NSUTF8StringEncoding error:nil];

  NSURL *downloadingURL = [NSURL URLWithString:@"http://example.com/downloading.mp4"];
  [[FVPContentDownloaderStatus shared] addURL:downloadingURL];
  NSString *downloadingFilePath = [FVPCacheManager cachedFilePathForURL:downloadingURL];
  [@"Downloading content" writeToFile:downloadingFilePath
                           atomically:YES
                             encoding:NSUTF8StringEncoding
                                error:nil];

  NSError *error = nil;
  [FVPCacheManager cleanAllCacheWithError:&error];

  XCTAssertNil(error);
  XCTAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:testFile1]);
  XCTAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:testFile2]);

  // Clean up temporary files
  [[NSFileManager defaultManager] removeItemAtPath:testFile1 error:nil];
  [[NSFileManager defaultManager] removeItemAtPath:testFile2 error:nil];
  [[NSFileManager defaultManager] removeItemAtPath:downloadingFilePath error:nil];
}

@end
