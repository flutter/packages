// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import AVFoundation;
@import video_player_avfoundation;
@import XCTest;
#import "FVPCacheSessionManager.h"

@interface FVPCacheSessionManagerTests : XCTestCase

@property(nonatomic, strong) FVPCacheSessionManager *cacheSessionManager;

@end

@implementation FVPCacheSessionManagerTests

- (void)setUp {
  [super setUp];
  self.cacheSessionManager = [FVPCacheSessionManager shared];
}

- (void)testSharedInstance {
  XCTAssertNotNil(self.cacheSessionManager);
  XCTAssertEqual(self.cacheSessionManager, [FVPCacheSessionManager shared]);
}

- (void)testInitialization {
  XCTAssertNotNil(self.cacheSessionManager.downloadQueue);
  XCTAssertTrue([self.cacheSessionManager.downloadQueue.name
      isEqualToString:@"video_player.download_cache_queue"]);
  XCTAssertEqual(self.cacheSessionManager.downloadQueue.maxConcurrentOperationCount,
                 NSOperationQueueDefaultMaxConcurrentOperationCount);
}

@end
