// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import AVFoundation;
@import video_player_avfoundation;
@import XCTest;
#import "FVPCacheConfiguration.h"

@interface FVPCacheConfigurationTests : XCTestCase

@end

@implementation FVPCacheConfigurationTests

- (void)testConfigurationInitialization {
  NSString *fakeFilePath = @"fakeTestFilePath";
  NSError *error;
  FVPCacheConfiguration *fakeConfiguration =
      [FVPCacheConfiguration configurationWithFilePath:fakeFilePath error:&error];

  XCTAssertNotNil(fakeConfiguration);
  XCTAssertEqualObjects(fakeConfiguration.filePath,
                        [fakeFilePath stringByAppendingPathExtension:@".cache_configuration"]);
}

@end
