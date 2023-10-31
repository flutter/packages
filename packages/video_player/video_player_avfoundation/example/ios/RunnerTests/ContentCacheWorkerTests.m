// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import AVFoundation;
@import video_player_avfoundation;
@import XCTest;
#import "FVPCacheAction.h"
#import "FVPCacheManager.h"
#import "FVPContentCacheWorker.h"
#import "FVPContentInfo.h"

@interface FVPContentCacheWorkerTests : XCTestCase

@property(nonatomic, strong) FVPContentCacheWorker *cacheWorker;

@end

@implementation FVPContentCacheWorkerTests

- (void)setUp {
  [super setUp];
  NSURL *testURL = [NSURL URLWithString:@"https://example.com/test-video.mp4"];
  self.cacheWorker = [[FVPContentCacheWorker alloc] initWithURL:testURL];
  XCTAssertNotNil(self.cacheWorker);
}

- (void)tearDown {
  self.cacheWorker = nil;
  [super tearDown];
}

- (void)testCacheData {
  NSError *error = nil;
  NSData *data = [@"Test Cache Data" dataUsingEncoding:NSUTF8StringEncoding];
  NSRange range = NSMakeRange(0, data.length);

  [self.cacheWorker cacheData:data forRange:range error:&error];

  XCTAssertNil(error);
  NSData *cachedData = [self.cacheWorker cachedDataForRange:range error:&error];
  XCTAssertNotNil(cachedData);
  XCTAssertEqualObjects(cachedData, data);
  XCTAssertNil(error);
}

- (void)testCachedDataActionsForRange {
  NSRange fakeRange = NSMakeRange(0, 1024);

  NSArray<FVPCacheAction *> *actions = [self.cacheWorker cachedDataActionsForRange:fakeRange];
  XCTAssertNotNil(actions);
  XCTAssertEqual(actions.count, 1);

  FVPCacheAction *action = actions.firstObject;
  XCTAssertEqualObjects(NSStringFromRange(action.range), NSStringFromRange(fakeRange));
}

@end
