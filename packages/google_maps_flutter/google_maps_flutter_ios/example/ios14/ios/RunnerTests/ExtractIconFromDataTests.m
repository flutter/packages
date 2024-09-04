// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import google_maps_flutter_ios;
@import google_maps_flutter_ios.Test;
@import XCTest;
#import <OCMock/OCMock.h>
#import <google_maps_flutter_ios/GoogleMapMarkerController_Test.h>

@interface ExtractIconFromDataTests : XCTestCase
- (UIImage *)createOnePixelImage;
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

  NSDictionary *assetData =
      @{@"assetName" : @"fakeImageNameKey", @"bitmapScaling" : @"auto", @"imagePixelRatio" : @1};

  NSArray *iconData = @[ @"asset", assetData ];

  CGFloat screenScale = 3.0;

  UIImage *resultImage = [instance extractIconFromData:iconData
                                             registrar:mockRegistrar
                                           screenScale:screenScale];
  XCTAssertNotNil(resultImage);
  XCTAssertEqual(resultImage.scale, 1.0);
  XCTAssertEqual(resultImage.size.width, 1.0);
  XCTAssertEqual(resultImage.size.height, 1.0);
}

- (void)testExtractIconFromDataAssetAutoWithScale {
  FLTGoogleMapMarkerController *instance = [[FLTGoogleMapMarkerController alloc] init];
  NSObject<FlutterPluginRegistrar> *mockRegistrar =
      OCMStrictProtocolMock(@protocol(FlutterPluginRegistrar));
  id mockImageClass = OCMClassMock([UIImage class]);
  UIImage *testImage = [self createOnePixelImage];

  OCMStub([mockRegistrar lookupKeyForAsset:@"fakeImageNameKey"]).andReturn(@"fakeAssetKey");
  OCMStub(ClassMethod([mockImageClass imageNamed:@"fakeAssetKey"])).andReturn(testImage);

  NSDictionary *assetData =
      @{@"assetName" : @"fakeImageNameKey", @"bitmapScaling" : @"auto", @"imagePixelRatio" : @10};

  NSArray *iconData = @[ @"asset", assetData ];

  CGFloat screenScale = 3.0;

  UIImage *resultImage = [instance extractIconFromData:iconData
                                             registrar:mockRegistrar
                                           screenScale:screenScale];

  XCTAssertNotNil(resultImage);
  XCTAssertEqual(resultImage.scale, 10);
  XCTAssertEqual(resultImage.size.width, 0.1);
  XCTAssertEqual(resultImage.size.height, 0.1);
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

  NSDictionary *assetData = @{
    @"assetName" : @"fakeImageNameKey",
    @"bitmapScaling" : @"auto",
    @"imagePixelRatio" : @1,
    @"width" : @15.0
  };  // Target height

  NSArray *iconData = @[ @"asset", assetData ];
  CGFloat screenScale = 3.0;

  UIImage *resultImage = [instance extractIconFromData:iconData
                                             registrar:mockRegistrar
                                           screenScale:screenScale];
  XCTAssertNotNil(resultImage);
  XCTAssertEqual(testImage.scale, 1.0);

  // As image has same aspect ratio as the original image,
  // only image scale has been changed to match the target size.
  CGFloat targetScale = testImage.scale * (testImage.size.width / 15.0);
  const CGFloat accuracy = 0.001;
  XCTAssertEqualWithAccuracy(resultImage.scale, targetScale, accuracy);
  XCTAssertEqual(resultImage.size.width, 15.0);
  XCTAssertEqual(resultImage.size.height, 15.0);
}

- (void)testExtractIconFromDataAssetAutoAndSizeWithDifferentAspectRatio {
  FLTGoogleMapMarkerController *instance = [[FLTGoogleMapMarkerController alloc] init];
  NSObject<FlutterPluginRegistrar> *mockRegistrar =
      OCMStrictProtocolMock(@protocol(FlutterPluginRegistrar));
  id mockImageClass = OCMClassMock([UIImage class]);
  UIImage *testImage = [self createOnePixelImage];

  OCMStub([mockRegistrar lookupKeyForAsset:@"fakeImageNameKey"]).andReturn(@"fakeAssetKey");
  OCMStub(ClassMethod([mockImageClass imageNamed:@"fakeAssetKey"])).andReturn(testImage);

  NSDictionary *assetData = @{
    @"assetName" : @"fakeImageNameKey",
    @"bitmapScaling" : @"auto",
    @"imagePixelRatio" : @1,
    @"width" : @15.0,
    @"height" : @45.0
  };

  NSArray *iconData = @[ @"asset", assetData ];

  CGFloat screenScale = 3.0;

  UIImage *resultImage = [instance extractIconFromData:iconData
                                             registrar:mockRegistrar
                                           screenScale:screenScale];
  XCTAssertNotNil(resultImage);
  XCTAssertEqual(resultImage.scale, screenScale);
  XCTAssertEqual(resultImage.size.width, 15.0);
  XCTAssertEqual(resultImage.size.height, 45.0);
}

- (void)testExtractIconFromDataAssetNoScaling {
  FLTGoogleMapMarkerController *instance = [[FLTGoogleMapMarkerController alloc] init];
  NSObject<FlutterPluginRegistrar> *mockRegistrar =
      OCMStrictProtocolMock(@protocol(FlutterPluginRegistrar));
  id mockImageClass = OCMClassMock([UIImage class]);
  UIImage *testImage = [self createOnePixelImage];

  OCMStub([mockRegistrar lookupKeyForAsset:@"fakeImageNameKey"]).andReturn(@"fakeAssetKey");
  OCMStub(ClassMethod([mockImageClass imageNamed:@"fakeAssetKey"])).andReturn(testImage);

  NSDictionary *assetData =
      @{@"assetName" : @"fakeImageNameKey", @"bitmapScaling" : @"none", @"imagePixelRatio" : @10};

  NSArray *iconData = @[ @"asset", assetData ];

  CGFloat screenScale = 3.0;

  UIImage *resultImage = [instance extractIconFromData:iconData
                                             registrar:mockRegistrar
                                           screenScale:screenScale];

  XCTAssertNotNil(resultImage);
  XCTAssertEqual(resultImage.scale, 1.0);
  XCTAssertEqual(resultImage.size.width, 1.0);
  XCTAssertEqual(resultImage.size.height, 1.0);
}

- (void)testExtractIconFromDataBytesAuto {
  FLTGoogleMapMarkerController *instance = [[FLTGoogleMapMarkerController alloc] init];
  NSObject<FlutterPluginRegistrar> *mockRegistrar =
      OCMStrictProtocolMock(@protocol(FlutterPluginRegistrar));
  UIImage *testImage = [self createOnePixelImage];
  NSData *pngData = UIImagePNGRepresentation(testImage);
  XCTAssertNotNil(pngData);

  FlutterStandardTypedData *typedData = [FlutterStandardTypedData typedDataWithBytes:pngData];

  NSDictionary *bytesData =
      @{@"byteData" : typedData, @"bitmapScaling" : @"auto", @"imagePixelRatio" : @1};

  NSArray *iconData = @[ @"bytes", bytesData ];
  CGFloat screenScale = 3.0;

  UIImage *resultImage = [instance extractIconFromData:iconData
                                             registrar:mockRegistrar
                                           screenScale:screenScale];

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
  NSData *pngData = UIImagePNGRepresentation(testImage);
  XCTAssertNotNil(pngData);

  FlutterStandardTypedData *typedData = [FlutterStandardTypedData typedDataWithBytes:pngData];

  NSDictionary *bytesData =
      @{@"byteData" : typedData, @"bitmapScaling" : @"auto", @"imagePixelRatio" : @10};

  NSArray *iconData = @[ @"bytes", bytesData ];

  CGFloat screenScale = 3.0;

  UIImage *resultImage = [instance extractIconFromData:iconData
                                             registrar:mockRegistrar
                                           screenScale:screenScale];
  XCTAssertNotNil(resultImage);
  XCTAssertEqual(resultImage.scale, 10);
  XCTAssertEqual(resultImage.size.width, 0.1);
  XCTAssertEqual(resultImage.size.height, 0.1);
}

- (void)testExtractIconFromDataBytesAutoAndSizeWithSameAspectRatio {
  FLTGoogleMapMarkerController *instance = [[FLTGoogleMapMarkerController alloc] init];
  NSObject<FlutterPluginRegistrar> *mockRegistrar =
      OCMStrictProtocolMock(@protocol(FlutterPluginRegistrar));
  UIImage *testImage = [self createOnePixelImage];
  NSData *pngData = UIImagePNGRepresentation(testImage);
  XCTAssertNotNil(pngData);

  FlutterStandardTypedData *typedData = [FlutterStandardTypedData typedDataWithBytes:pngData];

  NSDictionary *bytesData = @{
    @"byteData" : typedData,
    @"bitmapScaling" : @"auto",
    @"imagePixelRatio" : @1,
    @"width" : @15.0,
    @"height" : @15.0
  };

  NSArray *iconData = @[ @"bytes", bytesData ];

  CGFloat screenScale = 3.0;

  UIImage *resultImage = [instance extractIconFromData:iconData
                                             registrar:mockRegistrar
                                           screenScale:screenScale];

  XCTAssertNotNil(resultImage);
  XCTAssertEqual(testImage.scale, 1.0);

  // As image has same aspect ratio as the original image,
  // only image scale has been changed to match the target size.
  CGFloat targetScale = testImage.scale * (testImage.size.width / 15.0);
  const CGFloat accuracy = 0.001;
  XCTAssertEqualWithAccuracy(resultImage.scale, targetScale, accuracy);
  XCTAssertEqual(resultImage.size.width, 15.0);
  XCTAssertEqual(resultImage.size.height, 15.0);
}

- (void)testExtractIconFromDataBytesAutoAndSizeWithDifferentAspectRatio {
  FLTGoogleMapMarkerController *instance = [[FLTGoogleMapMarkerController alloc] init];
  NSObject<FlutterPluginRegistrar> *mockRegistrar =
      OCMStrictProtocolMock(@protocol(FlutterPluginRegistrar));
  UIImage *testImage = [self createOnePixelImage];
  NSData *pngData = UIImagePNGRepresentation(testImage);
  XCTAssertNotNil(pngData);

  FlutterStandardTypedData *typedData = [FlutterStandardTypedData typedDataWithBytes:pngData];

  NSDictionary *bytesData = @{
    @"byteData" : typedData,
    @"bitmapScaling" : @"auto",
    @"imagePixelRatio" : @1,
    @"width" : @15.0,
    @"height" : @45.0
  };

  NSArray *iconData = @[ @"bytes", bytesData ];
  CGFloat screenScale = 3.0;

  UIImage *resultImage = [instance extractIconFromData:iconData
                                             registrar:mockRegistrar
                                           screenScale:screenScale];
  XCTAssertNotNil(resultImage);
  XCTAssertEqual(resultImage.scale, screenScale);
  XCTAssertEqual(resultImage.size.width, 15.0);
  XCTAssertEqual(resultImage.size.height, 45.0);
}

- (void)testExtractIconFromDataBytesNoScaling {
  FLTGoogleMapMarkerController *instance = [[FLTGoogleMapMarkerController alloc] init];
  NSObject<FlutterPluginRegistrar> *mockRegistrar =
      OCMStrictProtocolMock(@protocol(FlutterPluginRegistrar));
  UIImage *testImage = [self createOnePixelImage];
  NSData *pngData = UIImagePNGRepresentation(testImage);
  XCTAssertNotNil(pngData);

  FlutterStandardTypedData *typedData = [FlutterStandardTypedData typedDataWithBytes:pngData];

  NSDictionary *bytesData =
      @{@"byteData" : typedData, @"bitmapScaling" : @"none", @"imagePixelRatio" : @1};

  NSArray *iconData = @[ @"bytes", bytesData ];
  CGFloat screenScale = 3.0;

  UIImage *resultImage = [instance extractIconFromData:iconData
                                             registrar:mockRegistrar
                                           screenScale:screenScale];
  XCTAssertNotNil(resultImage);
  XCTAssertEqual(resultImage.scale, 1.0);
  XCTAssertEqual(resultImage.size.width, 1.0);
  XCTAssertEqual(resultImage.size.height, 1.0);
}

- (void)testIsScalableWithScaleFactorFromSize100x100to10x100 {
  CGSize originalSize = CGSizeMake(100.0, 100.0);
  CGSize targetSize = CGSizeMake(10.0, 100.0);
  XCTAssertFalse([FLTGoogleMapMarkerController isScalableWithScaleFactorFromSize:originalSize
                                                                          toSize:targetSize]);
}

- (void)testIsScalableWithScaleFactorFromSize100x100to10x10 {
  CGSize originalSize = CGSizeMake(100.0, 100.0);
  CGSize targetSize = CGSizeMake(10.0, 10.0);
  XCTAssertTrue([FLTGoogleMapMarkerController isScalableWithScaleFactorFromSize:originalSize
                                                                         toSize:targetSize]);
}

- (void)testIsScalableWithScaleFactorFromSize233x200to23x20 {
  CGSize originalSize = CGSizeMake(233.0, 200.0);
  CGSize targetSize = CGSizeMake(23.0, 20.0);
  XCTAssertTrue([FLTGoogleMapMarkerController isScalableWithScaleFactorFromSize:originalSize
                                                                         toSize:targetSize]);
}

- (void)testIsScalableWithScaleFactorFromSize233x200to22x20 {
  CGSize originalSize = CGSizeMake(233.0, 200.0);
  CGSize targetSize = CGSizeMake(22.0, 20.0);
  XCTAssertFalse([FLTGoogleMapMarkerController isScalableWithScaleFactorFromSize:originalSize
                                                                          toSize:targetSize]);
}

- (void)testIsScalableWithScaleFactorFromSize200x233to20x23 {
  CGSize originalSize = CGSizeMake(200.0, 233.0);
  CGSize targetSize = CGSizeMake(20.0, 23.0);
  XCTAssertTrue([FLTGoogleMapMarkerController isScalableWithScaleFactorFromSize:originalSize
                                                                         toSize:targetSize]);
}

- (void)testIsScalableWithScaleFactorFromSize200x233to20x22 {
  CGSize originalSize = CGSizeMake(200.0, 233.0);
  CGSize targetSize = CGSizeMake(20.0, 22.0);
  XCTAssertFalse([FLTGoogleMapMarkerController isScalableWithScaleFactorFromSize:originalSize
                                                                          toSize:targetSize]);
}

- (void)testIsScalableWithScaleFactorFromSize1024x768to500x250 {
  CGSize originalSize = CGSizeMake(1024.0, 768.0);
  CGSize targetSize = CGSizeMake(500.0, 250.0);
  XCTAssertFalse([FLTGoogleMapMarkerController isScalableWithScaleFactorFromSize:originalSize
                                                                          toSize:targetSize]);
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

@end
