// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import ios_platform_images;
@import XCTest;

// The tests test the UIImage extension which is a public API intended for use from native code
// outside of the plugin (see package README). Any change that requires changing existing tests
// in this file (unless it's just to reflect changes to the test assets) is a BREAKING CHANGE for
// the package.
@interface UIImageExtensionTests : XCTestCase
@end

@implementation UIImageExtensionTests

- (void)testMultiResolutionImageUsesBest {
  UIImage *image = [UIImage flutterImageWithName:@"assets/multisize.png"];
  XCTAssertNotNil(image);
  // The 1x image height is is 125px, and the 2x is 250px.
  XCTAssertEqualWithAccuracy(image.size.height, 250, 0.00001);
}

- (void)testSingleResolutionFindsImage {
  UIImage *image = [UIImage flutterImageWithName:@"assets/monosize.png"];
  XCTAssertNotNil(image);
}

- (void)testMissingImageReturnsNil {
  UIImage *image = [UIImage flutterImageWithName:@"assets/no_such_image.png"];
  XCTAssertNil(image);
}

@end
