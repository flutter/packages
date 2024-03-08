// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import google_maps_flutter_ios;
@import google_maps_flutter_ios.Test;
@import XCTest;
#import <OCMock/OCMock.h>

@interface ExtractIconFromDataTests : XCTestCase
- (UIImage *)createOnePixelImage;
- (NSData *)convertImageToPNGData:(UIImage *)image;
@end

@implementation ExtractIconFromDataTests

- (void)testExtractIconFromDataAssetAuto {
  FLTGoogleMapMarkerController *instance = [[FLTGoogleMapMarkerController alloc] init];
  NSObject<FlutterPluginRegistrar> *mockRegistrar =
      OCMStrictProtocolMock(@protocol(FlutterPluginRegistrar));
  id mockImageClass = OCMClassMock([UIImage class]);
  UIImage *testImage = [self createOnePixelImage];

  OCMStub([mockRegistrar lookupKeyForAsset:@"fakeImageNameKey"]).andReturn(@"fakeAssetKey");
  OCMStub(ClassMethod([mockImageClass imageNamed:@"fakeAssetKey"])).andReturn(testImage);

  NSArray *iconData = @[ @"asset", @"fakeImageNameKey", @"auto", @1 ];

  UIImage *resultImage = [instance extractIconFromData:iconData registrar:mockRegistrar];
  XCTAssertNotNil(resultImage);
  XCTAssertEqual(resultImage.scale, 1.0);
  XCTAssertEqual(resultImage.size.width, 1.0);
  XCTAssertEqual(resultImage.size.height, 1.0);
  [mockImageClass stopMocking];
}

- (void)testExtractIconFromDataAssetAutoWithScale {
  FLTGoogleMapMarkerController *instance = [[FLTGoogleMapMarkerController alloc] init];
  NSObject<FlutterPluginRegistrar> *mockRegistrar =
      OCMStrictProtocolMock(@protocol(FlutterPluginRegistrar));
  id mockImageClass = OCMClassMock([UIImage class]);
  UIImage *testImage = [self createOnePixelImage];

  OCMStub([mockRegistrar lookupKeyForAsset:@"fakeImageNameKey"]).andReturn(@"fakeAssetKey");
  OCMStub(ClassMethod([mockImageClass imageNamed:@"fakeAssetKey"])).andReturn(testImage);

  NSArray *iconData = @[ @"asset", @"fakeImageNameKey", @"auto", @10 ];

  UIImage *resultImage = [instance extractIconFromData:iconData registrar:mockRegistrar];
  XCTAssertNotNil(resultImage);
  XCTAssertEqual(resultImage.scale, 10);  // image pixel ration (as scale) should be set to 10.
  XCTAssertEqual(resultImage.size.width, 0.1);   // width in logical pixels should be 0.1.
  XCTAssertEqual(resultImage.size.height, 0.1);  // height in logical pixels should be 0.1.
  [mockImageClass stopMocking];
}

- (void)testExtractIconFromDataAssetAutoAndSizeWithSameAspectRatio {
  FLTGoogleMapMarkerController *instance = [[FLTGoogleMapMarkerController alloc] init];
  NSObject<FlutterPluginRegistrar> *mockRegistrar =
      OCMStrictProtocolMock(@protocol(FlutterPluginRegistrar));
  id mockImageClass = OCMClassMock([UIImage class]);
  UIImage *testImage = [self createOnePixelImage];
  XCTAssertEqual(testImage.scale, 1.0);

  OCMStub([mockRegistrar lookupKeyForAsset:@"fakeImageNameKey"]).andReturn(@"fakeAssetKey");
  OCMStub(ClassMethod([mockImageClass imageNamed:@"fakeAssetKey"])).andReturn(testImage);

  NSArray *iconData = @[ @"asset", @"fakeImageNameKey", @"auto", @1, @[ @15.0, @15.0 ] ];

  UIImage *resultImage = [instance extractIconFromData:iconData registrar:mockRegistrar];
  XCTAssertNotNil(resultImage);
  XCTAssertEqual(testImage.scale, 1.0);

  // As image has same aspect ratio as the original image,
  // only image scale has been changed to match the target size.
  CGFloat targetScale = testImage.scale * (testImage.size.width / 15.0);
  XCTAssertEqual(resultImage.scale, targetScale);
  XCTAssertEqual(resultImage.size.width, 15.0);
  XCTAssertEqual(resultImage.size.height, 15.0);
  [mockImageClass stopMocking];
}

- (void)testExtractIconFromDataAssetAutoAndSizeWithDifferentAspectRatio {
  FLTGoogleMapMarkerController *instance = [[FLTGoogleMapMarkerController alloc] init];
  NSObject<FlutterPluginRegistrar> *mockRegistrar =
      OCMStrictProtocolMock(@protocol(FlutterPluginRegistrar));
  id mockImageClass = OCMClassMock([UIImage class]);
  UIImage *testImage = [self createOnePixelImage];

  OCMStub([mockRegistrar lookupKeyForAsset:@"fakeImageNameKey"]).andReturn(@"fakeAssetKey");
  OCMStub(ClassMethod([mockImageClass imageNamed:@"fakeAssetKey"])).andReturn(testImage);

  NSArray *iconData = @[ @"asset", @"fakeImageNameKey", @"auto", @1, @[ @15.0, @45.0 ] ];

  UIImage *resultImage = [instance extractIconFromData:iconData registrar:mockRegistrar];
  XCTAssertNotNil(resultImage);

  // If image is scaled using locigal pixel size, screen scale is used as image pixel density
  CGFloat screenScale = [[UIScreen mainScreen] scale];
  XCTAssertEqual(resultImage.scale, screenScale);
  XCTAssertEqual(resultImage.size.width, 15.0);
  XCTAssertEqual(resultImage.size.height, 45.0);
  [mockImageClass stopMocking];
}

- (void)testExtractIconFromDataAssetNoScaling {
  FLTGoogleMapMarkerController *instance = [[FLTGoogleMapMarkerController alloc] init];
  NSObject<FlutterPluginRegistrar> *mockRegistrar =
      OCMStrictProtocolMock(@protocol(FlutterPluginRegistrar));
  id mockImageClass = OCMClassMock([UIImage class]);
  UIImage *testImage = [self createOnePixelImage];

  OCMStub([mockRegistrar lookupKeyForAsset:@"fakeImageNameKey"]).andReturn(@"fakeAssetKey");
  OCMStub(ClassMethod([mockImageClass imageNamed:@"fakeAssetKey"])).andReturn(testImage);

  NSArray *iconData = @[ @"asset", @"fakeImageNameKey", @"noScaling", @10 ];

  UIImage *resultImage = [instance extractIconFromData:iconData registrar:mockRegistrar];
  XCTAssertNotNil(resultImage);
  XCTAssertEqual(resultImage.scale, 1.0);
  XCTAssertEqual(resultImage.size.width, 1.0);
  XCTAssertEqual(resultImage.size.height, 1.0);
  [mockImageClass stopMocking];
}

- (void)testExtractIconFromDataBytesAuto {
  FLTGoogleMapMarkerController *instance = [[FLTGoogleMapMarkerController alloc] init];
  NSObject<FlutterPluginRegistrar> *mockRegistrar =
      OCMStrictProtocolMock(@protocol(FlutterPluginRegistrar));
  UIImage *testImage = [self createOnePixelImage];
  NSData *pngData = [self convertImageToPNGData:testImage];
  XCTAssertNotNil(pngData);

  FlutterStandardTypedData *typedData = [FlutterStandardTypedData typedDataWithBytes:pngData];

  NSArray *iconData = @[ @"bytes", typedData, @"auto", @1 ];

  UIImage *resultImage = [instance extractIconFromData:iconData registrar:mockRegistrar];
  XCTAssertNotNil(resultImage);
  XCTAssertEqual(resultImage.scale, 1.0);
  XCTAssertEqual(resultImage.size.width, 1.0);
  XCTAssertEqual(resultImage.size.height, 1.0);
}

- (void)testExtractIconFromDataBytesAutoWithScaling {
  FLTGoogleMapMarkerController *instance = [[FLTGoogleMapMarkerController alloc] init];
  NSObject<FlutterPluginRegistrar> *mockRegistrar =
      OCMStrictProtocolMock(@protocol(FlutterPluginRegistrar));
  UIImage *testImage = [self createOnePixelImage];
  NSData *pngData = [self convertImageToPNGData:testImage];
  XCTAssertNotNil(pngData);

  FlutterStandardTypedData *typedData = [FlutterStandardTypedData typedDataWithBytes:pngData];

  NSArray *iconData = @[ @"bytes", typedData, @"auto", @10 ];

  UIImage *resultImage = [instance extractIconFromData:iconData registrar:mockRegistrar];
  XCTAssertNotNil(resultImage);
  XCTAssertEqual(resultImage.scale, 10);  // image pixel ration (as scale) should be set to 10.
  XCTAssertEqual(resultImage.size.width, 0.1);   // width in logical pixels should be 0.1.
  XCTAssertEqual(resultImage.size.height, 0.1);  // height in logical pixels should be 0.1.
}

- (void)testExtractIconFromDataBytesAutoAndSizeWithSameAspectRatio {
  FLTGoogleMapMarkerController *instance = [[FLTGoogleMapMarkerController alloc] init];
  NSObject<FlutterPluginRegistrar> *mockRegistrar =
      OCMStrictProtocolMock(@protocol(FlutterPluginRegistrar));
  UIImage *testImage = [self createOnePixelImage];
  NSData *pngData = [self convertImageToPNGData:testImage];
  XCTAssertNotNil(pngData);

  FlutterStandardTypedData *typedData = [FlutterStandardTypedData typedDataWithBytes:pngData];

  NSArray *iconData = @[ @"bytes", typedData, @"auto", @1, @[ @15.0, @15.0 ] ];

  UIImage *resultImage = [instance extractIconFromData:iconData registrar:mockRegistrar];
  XCTAssertNotNil(resultImage);
  XCTAssertEqual(testImage.scale, 1.0);

  // As image has same aspect ratio as the original image,
  // only image scale has been changed to match the target size.
  CGFloat targetScale = testImage.scale * (testImage.size.width / 15.0);
  XCTAssertEqual(resultImage.scale, targetScale);
  XCTAssertEqual(resultImage.size.width, 15.0);
  XCTAssertEqual(resultImage.size.height, 15.0);
}

- (void)testExtractIconFromDataBytesAutoAndSizeWithDifferentAspectRatio {
  FLTGoogleMapMarkerController *instance = [[FLTGoogleMapMarkerController alloc] init];
  NSObject<FlutterPluginRegistrar> *mockRegistrar =
      OCMStrictProtocolMock(@protocol(FlutterPluginRegistrar));
  UIImage *testImage = [self createOnePixelImage];
  NSData *pngData = [self convertImageToPNGData:testImage];
  XCTAssertNotNil(pngData);

  FlutterStandardTypedData *typedData = [FlutterStandardTypedData typedDataWithBytes:pngData];

  NSArray *iconData = @[ @"bytes", typedData, @"auto", @1, @[ @15.0, @45.0 ] ];

  UIImage *resultImage = [instance extractIconFromData:iconData registrar:mockRegistrar];
  XCTAssertNotNil(resultImage);

  // If image is scaled using locigal pixel size, screen scale is used as image pixel density
  CGFloat screenScale = [[UIScreen mainScreen] scale];
  XCTAssertEqual(resultImage.scale, screenScale);
  XCTAssertEqual(resultImage.size.width, 15.0);
  XCTAssertEqual(resultImage.size.height, 45.0);
}

- (void)testExtractIconFromDataBytesNoScaling {
  FLTGoogleMapMarkerController *instance = [[FLTGoogleMapMarkerController alloc] init];
  NSObject<FlutterPluginRegistrar> *mockRegistrar =
      OCMStrictProtocolMock(@protocol(FlutterPluginRegistrar));
  UIImage *testImage = [self createOnePixelImage];
  NSData *pngData = [self convertImageToPNGData:testImage];
  XCTAssertNotNil(pngData);

  FlutterStandardTypedData *typedData = [FlutterStandardTypedData typedDataWithBytes:pngData];

  NSArray *iconData = @[ @"bytes", typedData, @"noScaling", @10 ];

  UIImage *resultImage = [instance extractIconFromData:iconData registrar:mockRegistrar];
  XCTAssertNotNil(resultImage);
  XCTAssertEqual(resultImage.scale, 1.0);
  XCTAssertEqual(resultImage.size.width, 1.0);
  XCTAssertEqual(resultImage.size.height, 1.0);
}

- (void)testScaleSizeAndRoundToInt {
  FLTGoogleMapMarkerController *instance = [[FLTGoogleMapMarkerController alloc] init];

  NSArray *testCases = @[
    @{
      @"originalSize" : [NSValue valueWithCGSize:CGSizeMake(10.0, 10.0)],
      @"scaleFactor" : @3.0f,
      @"expectedSize" : [NSValue valueWithCGSize:CGSizeMake(30.0, 30.0)]
    },
    @{
      @"originalSize" : [NSValue valueWithCGSize:CGSizeMake(10.0, 10.0)],
      @"scaleFactor" : @1.0f,
      @"expectedSize" : [NSValue valueWithCGSize:CGSizeMake(10.0, 10.0)]
    },
    @{
      @"originalSize" : [NSValue valueWithCGSize:CGSizeMake(0.0, 0.0)],
      @"scaleFactor" : @3.0f,
      @"expectedSize" : [NSValue valueWithCGSize:CGSizeMake(0.0, 0.0)]
    },
    @{
      @"originalSize" : [NSValue valueWithCGSize:CGSizeMake(10.0, 10.0)],
      @"scaleFactor" : @0.0f,
      @"expectedSize" : [NSValue valueWithCGSize:CGSizeMake(0.0, 0.0)]
    },
    @{
      @"originalSize" : [NSValue valueWithCGSize:CGSizeMake(1.0, 1.0)],
      @"scaleFactor" : @3.5f,
      @"expectedSize" : [NSValue valueWithCGSize:CGSizeMake(3.0, 3.0)]
    },
  ];

  for (NSDictionary *testCase in testCases) {
    CGSize originalSize = [testCase[@"originalSize"] CGSizeValue];
    CGFloat scaleFactor = [testCase[@"scaleFactor"] floatValue];
    CGSize expectedSize = [testCase[@"expectedSize"] CGSizeValue];

    CGSize resultSize = [instance scaleSizeAndFloorToInt:originalSize withFactor:scaleFactor];

    XCTAssertEqualWithAccuracy(resultSize.width, expectedSize.width, 0.001,
                               @"Failed with originalSize: %@, scaleFactor: %f",
                               NSStringFromCGSize(originalSize), scaleFactor);
    XCTAssertEqualWithAccuracy(resultSize.height, expectedSize.height, 0.001,
                               @"Failed with originalSize: %@, scaleFactor: %f",
                               NSStringFromCGSize(originalSize), scaleFactor);
  }
}

- (void)testIsScalableFromSizeToSize {
  FLTGoogleMapMarkerController *instance = [[FLTGoogleMapMarkerController alloc] init];

  NSArray *testCases = @[
    @{
      @"originalSize" : [NSValue valueWithCGSize:CGSizeMake(100.0, 100.0)],
      @"targetSize" : [NSValue valueWithCGSize:CGSizeMake(10.0, 100.0)],
      @"expectedResult" : @NO
    },
    @{
      @"originalSize" : [NSValue valueWithCGSize:CGSizeMake(100.0, 100.0)],
      @"targetSize" : [NSValue valueWithCGSize:CGSizeMake(10.0, 10.0)],
      @"expectedResult" : @YES
    },
    @{
      @"originalSize" : [NSValue valueWithCGSize:CGSizeMake(233.0, 200.0)],
      @"targetSize" : [NSValue valueWithCGSize:CGSizeMake(23.0, 20.0)],
      @"expectedResult" : @YES
    },
    @{
      @"originalSize" : [NSValue valueWithCGSize:CGSizeMake(233.0, 200.0)],
      @"targetSize" : [NSValue valueWithCGSize:CGSizeMake(22.0, 20.0)],
      @"expectedResult" : @NO
    },
    @{
      @"originalSize" : [NSValue valueWithCGSize:CGSizeMake(200.0, 233.0)],
      @"targetSize" : [NSValue valueWithCGSize:CGSizeMake(20.0, 23.0)],
      @"expectedResult" : @YES
    },
    @{
      @"originalSize" : [NSValue valueWithCGSize:CGSizeMake(200.0, 233.0)],
      @"targetSize" : [NSValue valueWithCGSize:CGSizeMake(20.0, 22.0)],
      @"expectedResult" : @NO
    },
    @{
      @"originalSize" : [NSValue valueWithCGSize:CGSizeMake(1024.0, 768.0)],
      @"targetSize" : [NSValue valueWithCGSize:CGSizeMake(500.0, 250.0)],
      @"expectedResult" : @NO
    }
  ];

  // Iterate through test cases
  for (NSDictionary *testCase in testCases) {
    CGSize originalSize = [testCase[@"originalSize"] CGSizeValue];
    CGSize targetSize = [testCase[@"targetSize"] CGSizeValue];
    BOOL expectedResult = [testCase[@"expectedResult"] boolValue];

    BOOL result = [instance isScalableWithScaleFactorFromSize:originalSize toSize:targetSize];

    XCTAssertEqual(result, expectedResult,
                   @"Failed with originalSize: %@, targetSize: %@, expected: %@, got: %@",
                   NSStringFromCGSize(originalSize), NSStringFromCGSize(targetSize),
                   expectedResult ? @"YES" : @"NO", result ? @"YES" : @"NO");
  }
}

- (UIImage *)createOnePixelImage {
  CGSize size = CGSizeMake(1, 1);
  UIGraphicsImageRendererFormat *format = [UIGraphicsImageRendererFormat defaultFormat];
  format.scale = 1.0;
  format.opaque = YES;
  UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:size
                                                                             format:format];
  UIImage *image = [renderer imageWithActions:^(UIGraphicsImageRendererContext *_Nonnull context) {
    [[UIColor whiteColor] setFill];
    [context fillRect:CGRectMake(0, 0, size.width, size.height)];
  }];
  return image;
}

- (NSData *)convertImageToPNGData:(UIImage *)image {
  return UIImagePNGRepresentation(image);
}

@end
