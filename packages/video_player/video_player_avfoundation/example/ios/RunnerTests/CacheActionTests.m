// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import AVFoundation;
@import video_player_avfoundation;
@import XCTest;
#import "FVPCacheAction.h"

@interface FVPCacheActionTests : XCTestCase

@end

@implementation FVPCacheActionTests

- (void)testCacheActionInitialization {
  NSRange fakeRange = NSMakeRange(0, 100);
  FVPCacheAction *cacheAction = [[FVPCacheAction alloc] initWithCacheType:FVPCacheTypeUseLocal
                                                                    range:fakeRange];

  XCTAssertNotNil(cacheAction);
  XCTAssertEqual(cacheAction.cacheType, FVPCacheTypeUseLocal);
  XCTAssertTrue(NSEqualRanges(cacheAction.range, fakeRange));
}

@end
