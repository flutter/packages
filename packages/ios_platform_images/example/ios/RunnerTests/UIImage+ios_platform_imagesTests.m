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
  const double height1x = 125;  // The height of assets/multisize.png.
  const double height2x = 250;  // The height of assets/2.0x/multisize.png.
  // Loading assets should get the best available asset for the screen scale when resolution-aware
  // assets are available (and the example app has 1x and 2x for this asset). See
  // https://flutter.dev/to/resolution-aware-images
  if (UIScreen.mainScreen.scale > 1.0) {
    XCTAssertEqualWithAccuracy(image.size.height, height2x, 0.00001);
  } else {
    XCTAssertEqualWithAccuracy(image.size.height, height1x, 0.00001);
  }
}

- (void)testSingleResolutionFindsImage {
  // When there is no resolution-aware asset, the main asset should be used.
  UIImage *image = [UIImage flutterImageWithName:@"assets/monosize.png"];
  XCTAssertNotNil(image);
}

- (void)testMissingImageReturnsNil {
  UIImage *image = [UIImage flutterImageWithName:@"assets/no_such_image.png"];
  XCTAssertNil(image);
}

@end
