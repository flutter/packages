// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import google_maps_flutter_ios;
@import google_maps_flutter_ios.Test;
@import XCTest;

#import <OCMock/OCMock.h>
#import <google_maps_flutter_ios/GoogleMapMarkerController_Test.h>

@interface ExtractPinConfigFromDataTests : XCTestCase
- (UIImage *)createOnePixelImage;
@end

@implementation ExtractPinConfigFromDataTests

- (void)testExtractIconFromPinConfigWithGlyphColor {
  NSObject<FlutterPluginRegistrar> *mockRegistrar =
      OCMStrictProtocolMock(@protocol(FlutterPluginRegistrar));

  FGMPlatformColor *backgroundColor = [FGMPlatformColor makeWithRed:0.0
                                                              green:1.0
                                                               blue:1.0
                                                              alpha:1.0];
  FGMPlatformColor *borderColor = [FGMPlatformColor makeWithRed:1.0
                                                          green:0.0
                                                           blue:1.0
                                                          alpha:1.0];
  FGMPlatformColor *glyphColor = [FGMPlatformColor makeWithRed:0.1
                                                         green:0.2
                                                          blue:0.3
                                                         alpha:1.0];

  FGMPlatformBitmapPinConfig *pinConfig =
      [FGMPlatformBitmapPinConfig makeWithBackgroundColor:backgroundColor
                                              borderColor:borderColor
                                               glyphColor:glyphColor
                                           glyphTextColor:nil
                                                glyphText:nil
                                              glyphBitmap:nil];

  CGFloat screenScale = 3.0;

  UIImage *resultImage =
      FGMIconFromBitmap([FGMPlatformBitmap makeWithBitmap:pinConfig], mockRegistrar, screenScale);
  XCTAssertNotNil(resultImage);
}

- (void)testExtractIconFromPinConfigWithGlyphText {
  NSObject<FlutterPluginRegistrar> *mockRegistrar =
      OCMStrictProtocolMock(@protocol(FlutterPluginRegistrar));

  FGMPlatformColor *glyphTextColor = [FGMPlatformColor makeWithRed:1.0
                                                             green:1.0
                                                              blue:1.0
                                                             alpha:1.0];

  FGMPlatformBitmapPinConfig *pinConfig =
      [FGMPlatformBitmapPinConfig makeWithBackgroundColor:nil
                                              borderColor:nil
                                               glyphColor:nil
                                           glyphTextColor:glyphTextColor
                                                glyphText:@"Hi"
                                              glyphBitmap:nil];

  CGFloat screenScale = 3.0;

  UIImage *resultImage =
      FGMIconFromBitmap([FGMPlatformBitmap makeWithBitmap:pinConfig], mockRegistrar, screenScale);
  XCTAssertNotNil(resultImage);
}

- (void)testExtractIconFromPinConfigWithGlyphBitmap {
  NSObject<FlutterPluginRegistrar> *mockRegistrar =
      OCMStrictProtocolMock(@protocol(FlutterPluginRegistrar));
  id mockImageClass = OCMClassMock([UIImage class]);
  UIImage *testImage = [self createOnePixelImage];

  OCMStub([mockRegistrar lookupKeyForAsset:@"fakeImageNameKey"]).andReturn(@"fakeAssetKey");
  OCMStub(ClassMethod([mockImageClass imageNamed:@"fakeAssetKey"])).andReturn(testImage);

  FGMPlatformBitmapAssetMap *assetBitmap =
      [FGMPlatformBitmapAssetMap makeWithAssetName:@"fakeImageNameKey"
                                     bitmapScaling:FGMPlatformMapBitmapScalingAuto
                                   imagePixelRatio:1
                                             width:nil
                                            height:nil];
  FGMPlatformBitmap *glyphBitmap = [FGMPlatformBitmap makeWithBitmap:assetBitmap];

  FGMPlatformColor *backgroundColor = [FGMPlatformColor makeWithRed:1.0
                                                              green:1.0
                                                               blue:1.0
                                                              alpha:1.0];
  FGMPlatformColor *borderColor = [FGMPlatformColor makeWithRed:0.0
                                                          green:0.0
                                                           blue:0.0
                                                          alpha:1.0];

  FGMPlatformBitmapPinConfig *pinConfig =
      [FGMPlatformBitmapPinConfig makeWithBackgroundColor:backgroundColor
                                              borderColor:borderColor
                                               glyphColor:nil
                                           glyphTextColor:nil
                                                glyphText:nil
                                              glyphBitmap:glyphBitmap];

  CGFloat screenScale = 3.0;

  UIImage *resultImage =
      FGMIconFromBitmap([FGMPlatformBitmap makeWithBitmap:pinConfig], mockRegistrar, screenScale);
  XCTAssertNotNil(resultImage);
}

- (UIImage *)createOnePixelImage {
  CGSize size = CGSizeMake(1, 1);
  UIGraphicsImageRendererFormat *format = [UIGraphicsImageRendererFormat defaultFormat];
  format.scale = 1.0;
  format.opaque = YES;
  UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:size
                                                                             format:format];
  UIImage *image = [renderer imageWithActions:^(UIGraphicsImageRendererContext *_Nonnull context) {
    [UIColor.whiteColor setFill];
    [context fillRect:CGRectMake(0, 0, size.width, size.height)];
  }];
  return image;
}

@end
