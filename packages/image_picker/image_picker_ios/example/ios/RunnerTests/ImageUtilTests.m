// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "ImagePickerTestImages.h"

@import image_picker_ios;
#if __has_include(<image_picker_ios/image_picker_ios-umbrella.h>)
@import image_picker_ios.Test;
#endif
@import XCTest;

// Corner colors of test image scaled to 3x2. Format is "R G B A".
static NSString *const kColorRepresentation3x2BottomLeftYellow = @"1 0.776471 0 1";
static NSString *const kColorRepresentation3x2TopLeftRed = @"1 0.0666667 0 1";
static NSString *const kColorRepresentation3x2BottomRightCyan = @"0 0.772549 1 1";
static NSString *const kColorRepresentation3x2TopRightBlue = @"0 0.0705882 0.996078 1";

@interface ImageUtilTests : XCTestCase
@end

@implementation ImageUtilTests

static NSString *ColorStringAtPixel(UIImage *image, int pixelX, int pixelY) {
  CGImageRef cgImage = image.CGImage;

  uint32_t argb;
  CGContextRef context1 = CGBitmapContextCreate(
      &argb, 1, 1, CGImageGetBitsPerComponent(cgImage), CGImageGetBytesPerRow(cgImage),
      CGColorSpaceCreateDeviceRGB(), CGImageGetBitmapInfo(cgImage));
  CGContextDrawImage(
      context1, CGRectMake(-pixelX, -pixelY, CGImageGetWidth(cgImage), CGImageGetHeight(cgImage)),
      cgImage);
  CGContextRelease(context1);
  int blue = argb & 0xff;
  int green = argb >> 8 & 0xff;
  int red = argb >> 16 & 0xff;
  int alpha = argb >> 24 & 0xff;

  return [CIColor colorWithRed:red / 255.f
                         green:green / 255.f
                          blue:blue / 255.f
                         alpha:alpha / 255.f]
      .stringRepresentation;
}

- (void)testScaledImage_EqualSizeReturnsSameImage {
  UIImage *image = [UIImage imageWithData:ImagePickerTestImages.JPGTestData];
  UIImage *scaledImage = [FLTImagePickerImageUtil scaledImage:image
                                                     maxWidth:@(image.size.width)
                                                    maxHeight:@(image.size.height)
                                          isMetadataAvailable:YES];

  // Assert the same bytes pointer (not just equal objects).
  XCTAssertEqual(image, scaledImage);
}

- (void)testScaledImage_NilSizeReturnsSameImage {
  UIImage *image = [UIImage imageWithData:ImagePickerTestImages.JPGTestData];
  UIImage *scaledImage = [FLTImagePickerImageUtil scaledImage:image
                                                     maxWidth:nil
                                                    maxHeight:nil
                                          isMetadataAvailable:YES];

  // Assert the same bytes pointer (not just equal objects).
  XCTAssertEqual(image, scaledImage);
}

- (void)testScaledImage_ShouldBeScaled {
  UIImage *image = [UIImage imageWithData:ImagePickerTestImages.JPGTestData];

  CGFloat scaledWidth = 3;
  CGFloat scaledHeight = 2;
  UIImage *scaledImage = [FLTImagePickerImageUtil scaledImage:image
                                                     maxWidth:@(scaledWidth)
                                                    maxHeight:@(scaledHeight)
                                          isMetadataAvailable:YES];
  XCTAssertEqual(scaledImage.size.width, scaledWidth);
  XCTAssertEqual(scaledImage.size.height, scaledHeight);

  // Check the corners to make sure nothing has been rotated.
  XCTAssertEqualObjects(ColorStringAtPixel(scaledImage, 0, 0),
                        kColorRepresentation3x2BottomLeftYellow);
  XCTAssertEqualObjects(ColorStringAtPixel(scaledImage, 0, scaledHeight - 1),
                        kColorRepresentation3x2TopLeftRed);
  XCTAssertEqualObjects(ColorStringAtPixel(scaledImage, scaledWidth - 1, 0),
                        kColorRepresentation3x2BottomRightCyan);
  XCTAssertEqualObjects(ColorStringAtPixel(scaledImage, scaledWidth - 1, scaledHeight - 1),
                        kColorRepresentation3x2TopRightBlue);
}

- (void)testScaledImage_ShouldBeScaledWithNoMetadata {
  UIImage *image = [UIImage imageWithData:ImagePickerTestImages.JPGTestData];

  CGFloat scaledWidth = 3;
  CGFloat scaledHeight = 2;
  UIImage *scaledImage = [FLTImagePickerImageUtil scaledImage:image
                                                     maxWidth:@(scaledWidth)
                                                    maxHeight:@(scaledHeight)
                                          isMetadataAvailable:NO];
  XCTAssertEqual(scaledImage.size.width, scaledWidth);
  XCTAssertEqual(scaledImage.size.height, scaledHeight);

  // Check the corners to make sure nothing has been rotated.
  XCTAssertEqualObjects(ColorStringAtPixel(scaledImage, 0, 0),
                        kColorRepresentation3x2BottomLeftYellow);
  XCTAssertEqualObjects(ColorStringAtPixel(scaledImage, 0, scaledHeight - 1),
                        kColorRepresentation3x2TopLeftRed);
  XCTAssertEqualObjects(ColorStringAtPixel(scaledImage, scaledWidth - 1, 0),
                        kColorRepresentation3x2BottomRightCyan);
  XCTAssertEqualObjects(ColorStringAtPixel(scaledImage, scaledWidth - 1, scaledHeight - 1),
                        kColorRepresentation3x2TopRightBlue);
}

- (void)testScaledImage_ShouldBeCorrectRotation {
  NSURL *imageURL =
      [[NSBundle bundleForClass:[self class]] URLForResource:@"jpgImageWithRightOrientation"
                                               withExtension:@"jpg"];
  NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
  UIImage *image = [UIImage imageWithData:imageData];
  XCTAssertEqual(image.size.width, 130);
  XCTAssertEqual(image.size.height, 174);
  XCTAssertEqual(image.imageOrientation, UIImageOrientationRight);

  UIImage *newImage = [FLTImagePickerImageUtil scaledImage:image
                                                  maxWidth:@10
                                                 maxHeight:@10
                                       isMetadataAvailable:YES];
  XCTAssertEqual(newImage.size.width, 10);
  XCTAssertEqual(newImage.size.height, 7);
  XCTAssertEqual(newImage.imageOrientation, UIImageOrientationUp);
}

- (void)testScaledGIFImage_ShouldBeScaled {
  // gif image that frame size is 3 and the duration is 1 second.
  GIFInfo *info = [FLTImagePickerImageUtil scaledGIFImage:ImagePickerTestImages.GIFTestData
                                                 maxWidth:@3
                                                maxHeight:@2];

  NSArray<UIImage *> *images = info.images;
  NSTimeInterval duration = info.interval;

  XCTAssertEqual(images.count, 3);
  XCTAssertEqual(duration, 1);

  for (UIImage *newImage in images) {
    XCTAssertEqual(newImage.size.width, 3);
    XCTAssertEqual(newImage.size.height, 2);
  }
}

- (void)testScaledImage_TallImage_ShouldBeScaledBelowMaxHeight {
  UIImage *image = [UIImage imageWithData:ImagePickerTestImages.JPGTallTestData];
  XCTAssertEqual(image.size.width, 4);
  XCTAssertEqual(image.size.height, 7);
  UIImage *newImage = [FLTImagePickerImageUtil scaledImage:image
                                                  maxWidth:@5
                                                 maxHeight:@5
                                       isMetadataAvailable:YES];

  XCTAssertEqual(newImage.size.width, 3);
  XCTAssertEqual(newImage.size.height, 5);
}

- (void)testScaledImage_TallImage_ShouldBeScaledBelowMaxWidth {
  UIImage *image = [UIImage imageWithData:ImagePickerTestImages.JPGTallTestData];
  UIImage *newImage = [FLTImagePickerImageUtil scaledImage:image
                                                  maxWidth:@3
                                                 maxHeight:@10
                                       isMetadataAvailable:YES];

  XCTAssertEqual(newImage.size.width, 3);
  XCTAssertEqual(newImage.size.height, 5);
}

- (void)testScaledImage_TallImage_ShouldNotBeScaledAboveOriginaWidthOrHeight {
  UIImage *image = [UIImage imageWithData:ImagePickerTestImages.JPGTallTestData];
  UIImage *newImage = [FLTImagePickerImageUtil scaledImage:image
                                                  maxWidth:@10
                                                 maxHeight:@10
                                       isMetadataAvailable:YES];

  XCTAssertEqual(newImage.size.width, 4);
  XCTAssertEqual(newImage.size.height, 7);
}

- (void)testScaledImage_WideImage_ShouldBeScaledBelowMaxHeight {
  UIImage *image = [UIImage imageWithData:ImagePickerTestImages.JPGTestData];
  XCTAssertEqual(image.size.width, 12);
  XCTAssertEqual(image.size.height, 7);
  UIImage *newImage = [FLTImagePickerImageUtil scaledImage:image
                                                  maxWidth:@20
                                                 maxHeight:@6
                                       isMetadataAvailable:YES];

  XCTAssertEqual(newImage.size.width, 10);
  XCTAssertEqual(newImage.size.height, 6);
}

- (void)testScaledImage_WideImage_ShouldBeScaledBelowMaxWidth {
  UIImage *image = [UIImage imageWithData:ImagePickerTestImages.JPGTestData];
  UIImage *newImage = [FLTImagePickerImageUtil scaledImage:image
                                                  maxWidth:@10
                                                 maxHeight:@10
                                       isMetadataAvailable:YES];

  XCTAssertEqual(newImage.size.width, 10);
  XCTAssertEqual(newImage.size.height, 6);
}

- (void)testScaledImage_WideImage_ShouldNotBeScaledAboveOriginaWidthOrHeight {
  UIImage *image = [UIImage imageWithData:ImagePickerTestImages.JPGTestData];
  UIImage *newImage = [FLTImagePickerImageUtil scaledImage:image
                                                  maxWidth:@100
                                                 maxHeight:@100
                                       isMetadataAvailable:YES];

  XCTAssertEqual(newImage.size.width, 12);
  XCTAssertEqual(newImage.size.height, 7);
}

- (void)testScaledImage_ImageIsNil {
  UIImage *image = nil;
  UIImage *newImage = [FLTImagePickerImageUtil scaledImage:image
                                                  maxWidth:@1440
                                                 maxHeight:@1440
                                       isMetadataAvailable:YES];

  XCTAssertEqual(newImage, nil);
}

- (void)testScaledImage_ImageMaxWidthZeroAndMaxHeightIsZero {
  UIImage *image = [UIImage imageWithData:ImagePickerTestImages.JPGTestData];
  UIImage *newImage = [FLTImagePickerImageUtil scaledImage:image
                                                  maxWidth:@0
                                                 maxHeight:@0
                                       isMetadataAvailable:YES];

  XCTAssertEqual(newImage, nil);
}

@end
