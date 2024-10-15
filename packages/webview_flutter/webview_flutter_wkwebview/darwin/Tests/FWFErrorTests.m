// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import XCTest;

#import <XCTest/XCTest.h>

@interface FWFErrorTests : XCTestCase
@end

@implementation FWFErrorTests
- (void)testNSErrorUserInfoKey {
  // These MUST match the String values in the Dart class NSErrorUserInfoKey.
  XCTAssertEqualObjects(NSLocalizedDescriptionKey, @"NSLocalizedDescription");
  XCTAssertEqualObjects(NSURLErrorFailingURLStringErrorKey, @"NSErrorFailingURLStringKey");
}
@end
