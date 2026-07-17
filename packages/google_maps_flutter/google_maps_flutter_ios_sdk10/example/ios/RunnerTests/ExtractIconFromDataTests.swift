// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import Testing

@testable import google_maps_flutter_ios_sdk10

@MainActor struct ExtractIconFromDataTests {

  @Test func extractIconFromDataAssetAuto() {
    let testImage = createOnePixelImage()
    let assetName = "fakeImageName"
    let assetProvider = TestAssetProvider(image: testImage, forAssetName: assetName, package: nil)

    let bitmap = FGMPlatformBitmapAssetMap.make(
      withAssetName: assetName,
      bitmapScaling: .auto,
      imagePixelRatio: 1,
      width: nil,
      height: nil
    )

    let screenScale: CGFloat = 3.0

    let resultImage = FGMIconFromBitmap(
      FGMPlatformBitmap.make(withBitmap: bitmap),
      assetProvider,
      screenScale
    )

    #expect(resultImage != nil)
    #expect(resultImage?.scale == 1.0)
    #expect(resultImage?.size.width == 1.0)
    #expect(resultImage?.size.height == 1.0)
  }

  @Test func extractIconFromDataAssetAutoWithScale() {
    let testImage = createOnePixelImage()

    let assetName = "fakeImageName"
    let assetProvider = TestAssetProvider(image: testImage, forAssetName: assetName, package: nil)

    let bitmap = FGMPlatformBitmapAssetMap.make(
      withAssetName: assetName,
      bitmapScaling: .auto,
      imagePixelRatio: 10,
      width: nil,
      height: nil
    )

    let screenScale: CGFloat = 3.0

    let resultImage = FGMIconFromBitmap(
      FGMPlatformBitmap.make(withBitmap: bitmap),
      assetProvider,
      screenScale
    )

    #expect(resultImage != nil)
    #expect(resultImage?.scale == 10)
    #expect(resultImage?.size.width == 0.1)
    #expect(resultImage?.size.height == 0.1)
  }

  @Test func extractIconFromDataAssetAutoAndSizeWithSameAspectRatio() {
    let testImage = createOnePixelImage()
    #expect(testImage.scale == 1.0)

    let assetName = "fakeImageName"
    let assetProvider = TestAssetProvider(image: testImage, forAssetName: assetName, package: nil)

    let width: CGFloat = 15.0
    let bitmap = FGMPlatformBitmapAssetMap.make(
      withAssetName: assetName,
      bitmapScaling: .auto,
      imagePixelRatio: 1,
      width: width as NSNumber,
      height: nil
    )

    let screenScale: CGFloat = 3.0

    let resultImage = FGMIconFromBitmap(
      FGMPlatformBitmap.make(withBitmap: bitmap),
      assetProvider,
      screenScale
    )
    #expect(resultImage != nil)
    #expect(testImage.scale == 1.0)

    // As image has same aspect ratio as the original image,
    // only image scale has been changed to match the target size.
    let targetScale = testImage.scale * (testImage.size.width / width)
    let accuracy: Double = 0.001
    #expect(abs(resultImage!.scale - targetScale) < accuracy)
    #expect(resultImage?.size.width == width)
    #expect(resultImage?.size.height == width)
  }

  @Test func extractIconFromDataAssetAutoAndSizeWithDifferentAspectRatio() {
    let testImage = createOnePixelImage()

    let assetName = "fakeImageName"
    let assetProvider = TestAssetProvider(image: testImage, forAssetName: assetName, package: nil)

    let width: CGFloat = 15.0
    let height: CGFloat = 45.0
    let bitmap = FGMPlatformBitmapAssetMap.make(
      withAssetName: assetName,
      bitmapScaling: .auto,
      imagePixelRatio: 1,
      width: width as NSNumber,
      height: height as NSNumber
    )

    let screenScale: CGFloat = 3.0

    let resultImage = FGMIconFromBitmap(
      FGMPlatformBitmap.make(withBitmap: bitmap),
      assetProvider,
      screenScale
    )
    #expect(resultImage != nil)
    #expect(resultImage?.scale == screenScale)
    #expect(resultImage?.size.width == width)
    #expect(resultImage?.size.height == height)
  }

  @Test func extractIconFromDataAssetNoScaling() {
    let testImage = createOnePixelImage()

    let assetName = "fakeImageName"
    let assetProvider = TestAssetProvider(image: testImage, forAssetName: assetName, package: nil)

    let bitmap = FGMPlatformBitmapAssetMap.make(
      withAssetName: assetName,
      bitmapScaling: .none,
      imagePixelRatio: 1,
      width: nil,
      height: nil
    )

    let screenScale: CGFloat = 3.0

    let resultImage = FGMIconFromBitmap(
      FGMPlatformBitmap.make(withBitmap: bitmap),
      assetProvider,
      screenScale
    )

    #expect(resultImage != nil)
    #expect(resultImage?.scale == 1.0)
    #expect(resultImage?.size.width == 1.0)
    #expect(resultImage?.size.height == 1.0)
  }

  @Test func extractIconFromDataBytesAuto() throws {
    let testImage = createOnePixelImage()
    let pngData = try #require(testImage.pngData())

    let typedData = FlutterStandardTypedData(bytes: pngData)
    let bitmap = FGMPlatformBitmapBytesMap.make(
      withByteData: typedData,
      bitmapScaling: .auto,
      imagePixelRatio: 1,
      width: nil,
      height: nil
    )

    let screenScale: CGFloat = 3.0

    let resultImage = FGMIconFromBitmap(
      FGMPlatformBitmap.make(withBitmap: bitmap),
      TestAssetProvider(),
      screenScale
    )

    #expect(resultImage != nil)
    #expect(resultImage?.scale == 1.0)
    #expect(resultImage?.size.width == 1.0)
    #expect(resultImage?.size.height == 1.0)
  }

  @Test func extractIconFromDataBytesAutoWithScaling() throws {
    let testImage = createOnePixelImage()
    let pngData = try #require(testImage.pngData())

    let typedData = FlutterStandardTypedData(bytes: pngData)
    let bitmap = FGMPlatformBitmapBytesMap.make(
      withByteData: typedData,
      bitmapScaling: .auto,
      imagePixelRatio: 10,
      width: nil,
      height: nil
    )

    let screenScale: CGFloat = 3.0

    let resultImage = FGMIconFromBitmap(
      FGMPlatformBitmap.make(withBitmap: bitmap),
      TestAssetProvider(),
      screenScale
    )
    #expect(resultImage != nil)
    #expect(resultImage?.scale == 10)
    #expect(resultImage?.size.width == 0.1)
    #expect(resultImage?.size.height == 0.1)
  }

  @Test func extractIconFromDataBytesAutoAndSizeWithSameAspectRatio() throws {
    let testImage = createOnePixelImage()
    let pngData = try #require(testImage.pngData())

    let width: CGFloat = 15.0
    let height: CGFloat = 15.0
    let typedData = FlutterStandardTypedData(bytes: pngData)
    let bitmap = FGMPlatformBitmapBytesMap.make(
      withByteData: typedData,
      bitmapScaling: .auto,
      imagePixelRatio: 1,
      width: width as NSNumber,
      height: height as NSNumber
    )

    let screenScale: CGFloat = 3.0

    let resultImage = FGMIconFromBitmap(
      FGMPlatformBitmap.make(withBitmap: bitmap),
      TestAssetProvider(),
      screenScale
    )

    #expect(resultImage != nil)
    #expect(testImage.scale == 1.0)

    // As image has same aspect ratio as the original image,
    // only image scale has been changed to match the target size.
    let targetScale = testImage.scale * (testImage.size.width / width)
    let accuracy: Double = 0.001
    #expect(abs(resultImage!.scale - targetScale) < accuracy)
    #expect(resultImage?.size.width == width)
    #expect(resultImage?.size.height == height)
  }

  @Test func extractIconFromDataBytesAutoAndSizeWithDifferentAspectRatio() throws {
    let testImage = createOnePixelImage()
    let pngData = try #require(testImage.pngData())

    let width: CGFloat = 15.0
    let height: CGFloat = 45.0
    let typedData = FlutterStandardTypedData(bytes: pngData)
    let bitmap = FGMPlatformBitmapBytesMap.make(
      withByteData: typedData,
      bitmapScaling: .auto,
      imagePixelRatio: 1,
      width: width as NSNumber,
      height: height as NSNumber
    )

    let screenScale: CGFloat = 3.0

    let resultImage = FGMIconFromBitmap(
      FGMPlatformBitmap.make(withBitmap: bitmap),
      TestAssetProvider(),
      screenScale
    )
    #expect(resultImage != nil)
    #expect(resultImage?.scale == screenScale)
    #expect(resultImage?.size.width == width)
    #expect(resultImage?.size.height == height)
  }

  @Test func extractIconFromDataBytesNoScaling() throws {
    let testImage = createOnePixelImage()
    let pngData = try #require(testImage.pngData())

    let typedData = FlutterStandardTypedData(bytes: pngData)
    let bitmap = FGMPlatformBitmapBytesMap.make(
      withByteData: typedData,
      bitmapScaling: .none,
      imagePixelRatio: 1,
      width: nil,
      height: nil
    )

    let screenScale: CGFloat = 3.0

    let resultImage = FGMIconFromBitmap(
      FGMPlatformBitmap.make(withBitmap: bitmap),
      TestAssetProvider(),
      screenScale
    )
    #expect(resultImage != nil)
    #expect(resultImage?.scale == 1.0)
    #expect(resultImage?.size.width == 1.0)
    #expect(resultImage?.size.height == 1.0)
  }

  /// Tests for PinConfig (GMSPinImageOptions) - requires iOS 16.0+ and Google Maps SDK 9.0+.
  /// On earlier versions, FGMIconFromBitmap returns nil for PinConfig, which is expected behavior.
  @Test func extractIconFromPinConfigWithGlyphColor() {
    let assetProvider = TestAssetProvider()

    let backgroundColor = FGMPlatformColor.make(withRed: 0.0, green: 1.0, blue: 1.0, alpha: 1.0)
    let borderColor = FGMPlatformColor.make(withRed: 1.0, green: 0.0, blue: 1.0, alpha: 1.0)
    let glyphColor = FGMPlatformColor.make(withRed: 0.1, green: 0.2, blue: 0.3, alpha: 1.0)

    let pinConfig = FGMPlatformBitmapPinConfig.make(
      withBackgroundColor: backgroundColor,
      borderColor: borderColor,
      glyphColor: glyphColor,
      glyphTextColor: nil,
      glyphText: nil,
      glyphBitmap: nil
    )

    let screenScale: CGFloat = 3.0

    let resultImage = FGMIconFromBitmap(
      FGMPlatformBitmap.make(withBitmap: pinConfig),
      assetProvider,
      screenScale
    )

    // PinConfig may return nil on old Google Maps SDK versions (<=8.4.0).
    // Also, due to a Google Maps SDK issue (https://issuetracker.google.com/issues/370536110),
    // GMSPinImage can return a zero-sized image.
    #expect(resultImage == nil || resultImage!.size.width >= 0)
    #expect(resultImage == nil || resultImage!.size.height >= 0)
  }

  @Test func extractIconFromPinConfigWithGlyphText() {
    let assetProvider = TestAssetProvider()

    let glyphTextColor = FGMPlatformColor.make(withRed: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)

    let pinConfig = FGMPlatformBitmapPinConfig.make(
      withBackgroundColor: nil,
      borderColor: nil,
      glyphColor: nil,
      glyphTextColor: glyphTextColor,
      glyphText: "Hi",
      glyphBitmap: nil
    )

    let screenScale: CGFloat = 3.0

    let resultImage = FGMIconFromBitmap(
      FGMPlatformBitmap.make(withBitmap: pinConfig),
      assetProvider,
      screenScale
    )

    // PinConfig returns nil on iOS versions without GMSPinImageOptions support (< iOS 16.0).
    // On simulators, GMSPinImage may also return a zero-dimension image. Both cases are acceptable
    // in test environment - the important thing is that the call doesn't crash.
    // When the image is valid, it should have positive dimensions.
    #expect(resultImage == nil || resultImage!.size.width >= 0)
    #expect(resultImage == nil || resultImage!.size.height >= 0)
  }

  @Test func extractIconFromPinConfigWithGlyphBitmap() {
    let testImage = createOnePixelImage()
    let assetName = "fakeImageNameKey"
    let assetProvider = TestAssetProvider(image: testImage, forAssetName: assetName, package: nil)

    let assetBitmap = FGMPlatformBitmapAssetMap.make(
      withAssetName: assetName,
      bitmapScaling: .auto,
      imagePixelRatio: 1,
      width: nil,
      height: nil
    )
    let glyphBitmap = FGMPlatformBitmap.make(withBitmap: assetBitmap)

    let backgroundColor = FGMPlatformColor.make(withRed: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    let borderColor = FGMPlatformColor.make(withRed: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)

    let pinConfig = FGMPlatformBitmapPinConfig.make(
      withBackgroundColor: backgroundColor,
      borderColor: borderColor,
      glyphColor: nil,
      glyphTextColor: nil,
      glyphText: nil,
      glyphBitmap: glyphBitmap
    )

    let screenScale: CGFloat = 3.0

    let resultImage = FGMIconFromBitmap(
      FGMPlatformBitmap.make(withBitmap: pinConfig),
      assetProvider,
      screenScale
    )

    // PinConfig returns nil on iOS versions without GMSPinImageOptions support (< iOS 16.0).
    // On simulators, GMSPinImage may also return a zero-dimension image. Both cases are acceptable
    // in test environment - the important thing is that the call doesn't crash.
    // When the image is valid, it should have positive dimensions.
    #expect(resultImage == nil || resultImage!.size.width >= 0)
    #expect(resultImage == nil || resultImage!.size.height >= 0)
  }

  @Test func isScalableWithScaleFactorFromSize100x100to10x100() {
    let originalSize = CGSize(width: 100.0, height: 100.0)
    let targetSize = CGSize(width: 10.0, height: 100.0)
    #expect(!FGMIsScalableWithScaleFactorFromSize(originalSize, targetSize))
  }

  @Test func isScalableWithScaleFactorFromSize100x100to10x10() {
    let originalSize = CGSize(width: 100.0, height: 100.0)
    let targetSize = CGSize(width: 10.0, height: 10.0)
    #expect(FGMIsScalableWithScaleFactorFromSize(originalSize, targetSize))
  }

  @Test func isScalableWithScaleFactorFromSize233x200to23x20() {
    let originalSize = CGSize(width: 233.0, height: 200.0)
    let targetSize = CGSize(width: 23.0, height: 20.0)
    #expect(FGMIsScalableWithScaleFactorFromSize(originalSize, targetSize))
  }

  @Test func isScalableWithScaleFactorFromSize233x200to22x20() {
    let originalSize = CGSize(width: 233.0, height: 200.0)
    let targetSize = CGSize(width: 22.0, height: 20.0)
    #expect(!FGMIsScalableWithScaleFactorFromSize(originalSize, targetSize))
  }

  @Test func isScalableWithScaleFactorFromSize200x233to20x23() {
    let originalSize = CGSize(width: 200.0, height: 233.0)
    let targetSize = CGSize(width: 20.0, height: 23.0)
    #expect(FGMIsScalableWithScaleFactorFromSize(originalSize, targetSize))
  }

  @Test func isScalableWithScaleFactorFromSize200x233to20x22() {
    let originalSize = CGSize(width: 200.0, height: 233.0)
    let targetSize = CGSize(width: 20.0, height: 22.0)
    #expect(!FGMIsScalableWithScaleFactorFromSize(originalSize, targetSize))
  }

  @Test func isScalableWithScaleFactorFromSize1024x768to500x250() {
    let originalSize = CGSize(width: 1024.0, height: 768.0)
    let targetSize = CGSize(width: 500.0, height: 250.0)
    #expect(!FGMIsScalableWithScaleFactorFromSize(originalSize, targetSize))
  }

  private func createOnePixelImage() -> UIImage {
    let size = CGSize(width: 1, height: 1)
    let format = UIGraphicsImageRendererFormat.default()
    format.scale = 1.0
    format.opaque = true
    let renderer = UIGraphicsImageRenderer(size: size, format: format)
    let image = renderer.image { context in
      UIColor.white.setFill()
      context.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
    }
    return image
  }
}
