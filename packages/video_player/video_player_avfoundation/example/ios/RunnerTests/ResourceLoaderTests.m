// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import AVFoundation;
#import <XCTest/XCTest.h>
#import "FVPResourceLoader.h"

@interface FVPResourceLoaderTests : XCTestCase

@end

@implementation FVPResourceLoaderTests

- (void)testInitResourceLoader {
    NSURL *testURL = [NSURL URLWithString:@"https://example.com/test.mp4"];
    NSError *error = nil;
    FVPResourceLoader *resourceLoader = [[FVPResourceLoader alloc] initWithURL:testURL error:error];
    
    XCTAssertNotNil(resourceLoader);
}

@end
