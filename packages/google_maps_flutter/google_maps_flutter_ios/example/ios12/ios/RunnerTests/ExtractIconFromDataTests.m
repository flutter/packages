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

  NSArray *iconData = @[ @"asset", @"fakeImageNameKey", @"auto", @2 ];

  UIImage *resultImage = [instance extractIconFromData:iconData registrar:mockRegistrar];
  XCTAssertNotNil(resultImage);
  [mockImageClass stopMocking];
}

- (void)testExtractIconFromDataAssetAutoAndSize {
  FLTGoogleMapMarkerController *instance = [[FLTGoogleMapMarkerController alloc] init];
  NSObject<FlutterPluginRegistrar> *mockRegistrar =
      OCMStrictProtocolMock(@protocol(FlutterPluginRegistrar));
  id mockImageClass = OCMClassMock([UIImage class]);
  UIImage *testImage = [self createOnePixelImage];

  OCMStub([mockRegistrar lookupKeyForAsset:@"fakeImageNameKey"]).andReturn(@"fakeAssetKey");
  OCMStub(ClassMethod([mockImageClass imageNamed:@"fakeAssetKey"])).andReturn(testImage);

  NSArray *iconData = @[ @"asset", @"fakeImageNameKey", @"auto", @2, @[ @15.0, @15.0 ] ];

  UIImage *resultImage = [instance extractIconFromData:iconData registrar:mockRegistrar];
  XCTAssertNotNil(resultImage);
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

  NSArray *iconData = @[ @"asset", @"fakeImageNameKey", @"noScaling", @2 ];

  UIImage *resultImage = [instance extractIconFromData:iconData registrar:mockRegistrar];
  XCTAssertNotNil(resultImage);
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

  NSArray *iconData = @[ @"bytes", typedData, @"auto", @2 ];

  UIImage *resultImage = [instance extractIconFromData:iconData registrar:mockRegistrar];
  XCTAssertNotNil(resultImage);
}

- (void)testExtractIconFromDataBytesAutoAndSize {
  FLTGoogleMapMarkerController *instance = [[FLTGoogleMapMarkerController alloc] init];
  NSObject<FlutterPluginRegistrar> *mockRegistrar =
      OCMStrictProtocolMock(@protocol(FlutterPluginRegistrar));
  UIImage *testImage = [self createOnePixelImage];
  NSData *pngData = [self convertImageToPNGData:testImage];
  XCTAssertNotNil(pngData);

  FlutterStandardTypedData *typedData = [FlutterStandardTypedData typedDataWithBytes:pngData];

  NSArray *iconData = @[ @"bytes", typedData, @"auto", @2, @[ @15.0, @15.0 ] ];

  UIImage *resultImage = [instance extractIconFromData:iconData registrar:mockRegistrar];
  XCTAssertNotNil(resultImage);
}

- (void)testExtractIconFromDataBytesNoScaling {
  FLTGoogleMapMarkerController *instance = [[FLTGoogleMapMarkerController alloc] init];
  NSObject<FlutterPluginRegistrar> *mockRegistrar =
      OCMStrictProtocolMock(@protocol(FlutterPluginRegistrar));
  UIImage *testImage = [self createOnePixelImage];
  NSData *pngData = [self convertImageToPNGData:testImage];
  XCTAssertNotNil(pngData);

  FlutterStandardTypedData *typedData = [FlutterStandardTypedData typedDataWithBytes:pngData];

  NSArray *iconData = @[ @"bytes", typedData, @"noScaling", @2 ];

  UIImage *resultImage = [instance extractIconFromData:iconData registrar:mockRegistrar];
  XCTAssertNotNil(resultImage);
}

- (void)testScaleSizeToInt {
  FLTGoogleMapMarkerController *instance = [[FLTGoogleMapMarkerController alloc] init];

  NSArray *testCases = @[
    @{
      @"startSize" : [NSValue valueWithCGSize:CGSizeMake(10.0, 10.0)],
      @"scaleFactor" : @3.0f,
      @"expectedSize" : [NSValue valueWithCGSize:CGSizeMake(30.0, 30.0)]
    },
    @{
      @"startSize" : [NSValue valueWithCGSize:CGSizeMake(10.0, 10.0)],
      @"scaleFactor" : @1.0f,
      @"expectedSize" : [NSValue valueWithCGSize:CGSizeMake(10.0, 10.0)]
    },
    @{
      @"startSize" : [NSValue valueWithCGSize:CGSizeMake(0.0, 0.0)],
      @"scaleFactor" : @3.0f,
      @"expectedSize" : [NSValue valueWithCGSize:CGSizeMake(0.0, 0.0)]
    },
    @{
      @"startSize" : [NSValue valueWithCGSize:CGSizeMake(10.0, 10.0)],
      @"scaleFactor" : @0.0f,
      @"expectedSize" : [NSValue valueWithCGSize:CGSizeMake(0.0, 0.0)]
    },
  ];

  for (NSDictionary *testCase in testCases) {
    CGSize startSize = [testCase[@"startSize"] CGSizeValue];
    CGFloat scaleFactor = [testCase[@"scaleFactor"] floatValue];
    CGSize expectedSize = [testCase[@"expectedSize"] CGSizeValue];

    CGSize resultSize = [instance scaleSizeToInt:startSize withFactor:scaleFactor];

    XCTAssertEqualWithAccuracy(resultSize.width, expectedSize.width, 0.001,
                               @"Failed with startSize: %@, scaleFactor: %f",
                               NSStringFromCGSize(startSize), scaleFactor);
    XCTAssertEqualWithAccuracy(resultSize.height, expectedSize.height, 0.001,
                               @"Failed with startSize: %@, scaleFactor: %f",
                               NSStringFromCGSize(startSize), scaleFactor);
  }
}

- (UIImage *)createOnePixelImage {
  CGSize size = CGSizeMake(1, 1);
  UIGraphicsBeginImageContextWithOptions(size, YES, 0);

  [[UIColor whiteColor] setFill];
  UIRectFill(CGRectMake(0, 0, 1, 1));

  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();

  return image;
}

- (NSData *)convertImageToPNGData:(UIImage *)image {
  return UIImagePNGRepresentation(image);
}

@end
