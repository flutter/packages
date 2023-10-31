// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import AVFoundation;
@import video_player_avfoundation;
@import XCTest;
#if PLATFORM_IS_IOS
#import "FVPContentInfo.h"
#endif

@interface FVPContentInfoTests : XCTestCase

@end

@implementation FVPContentInfoTests

- (void)testEncodingAndDecoding {
  // Create a sample content info object
  FVPContentInfo *contentInfo = [FVPContentInfo new];
  contentInfo.contentLength = 1024;
  contentInfo.contentType = @"video/mp4";
  contentInfo.byteRangeAccessSupported = YES;

  // Archive the content info
  NSData *encodedData = [NSKeyedArchiver archivedDataWithRootObject:contentInfo];
  XCTAssertNotNil(encodedData);

  // Unarchive the content info
  FVPContentInfo *decodedContentInfo = [NSKeyedUnarchiver unarchiveObjectWithData:encodedData];
  XCTAssertNotNil(decodedContentInfo);

  // Compare the original and decoded content info objects
  XCTAssertEqual(contentInfo.contentLength, decodedContentInfo.contentLength);
  XCTAssertEqualObjects(contentInfo.contentType, decodedContentInfo.contentType);
  XCTAssertEqual(contentInfo.byteRangeAccessSupported, decodedContentInfo.byteRangeAccessSupported);
}

@end
