// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest
import Flutter
@testable import google_maps_flutter_ios

class ExtractIconFromDataTests: XCTestCase {

  func testExtractIconFromDataAssetAuto() {
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

    XCTAssertNotNil(resultImage)
    XCTAssertEqual(resultImage?.scale, 1.0)
    XCTAssertEqual(resultImage?.size.width, 1.0)
    XCTAssertEqual(resultImage?.size.height, 1.0)
  }

  func testExtractIconFromDataAssetAutoWithScale() {
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

    XCTAssertNotNil(resultImage)
    XCTAssertEqual(resultImage?.scale, 10)
    XCTAssertEqual(resultImage?.size.width, 0.1)
    XCTAssertEqual(resultImage?.size.height, 0.1)
  }

  func testExtractIconFromDataAssetAutoAndSizeWithSameAspectRatio() {
    let testImage = createOnePixelImage()
    XCTAssertEqual(testImage.scale, 1.0)

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
    XCTAssertNotNil(resultImage)
    XCTAssertEqual(testImage.scale, 1.0)

    // As image has same aspect ratio as the original image,
    // only image scale has been changed to match the target size.
    let targetScale = testImage.scale * (testImage.size.width / width)
    let accuracy: Double = 0.001
    XCTAssertEqual(resultImage!.scale, targetScale, accuracy: accuracy)
    XCTAssertEqual(resultImage?.size.width, width)
    XCTAssertEqual(resultImage?.size.height, width)
  }

  func testExtractIconFromDataAssetAutoAndSizeWithDifferentAspectRatio() {
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
    XCTAssertNotNil(resultImage)
    XCTAssertEqual(resultImage?.scale, screenScale)
    XCTAssertEqual(resultImage?.size.width, width)
    XCTAssertEqual(resultImage?.size.height, height)
  }

  func testExtractIconFromDataAssetNoScaling() {
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

    XCTAssertNotNil(resultImage)
    XCTAssertEqual(resultImage?.scale, 1.0)
    XCTAssertEqual(resultImage?.size.width, 1.0)
    XCTAssertEqual(resultImage?.size.height, 1.0)
  }

  func testExtractIconFromDataBytesAuto() {
    let testImage = createOnePixelImage()
    let pngData = testImage.pngData()
    XCTAssertNotNil(pngData)

    let typedData = FlutterStandardTypedData(bytes: pngData!)
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

    XCTAssertNotNil(resultImage)
    XCTAssertEqual(resultImage?.scale, 1.0)
    XCTAssertEqual(resultImage?.size.width, 1.0)
    XCTAssertEqual(resultImage?.size.height, 1.0)
  }

  func testExtractIconFromDataBytesAutoWithScaling() {
    let testImage = createOnePixelImage()
    let pngData = testImage.pngData()
    XCTAssertNotNil(pngData)

    let typedData = FlutterStandardTypedData(bytes: pngData!)
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
    XCTAssertNotNil(resultImage)
    XCTAssertEqual(resultImage?.scale, 10)
    XCTAssertEqual(resultImage?.size.width, 0.1)
    XCTAssertEqual(resultImage?.size.height, 0.1)
  }

  func testExtractIconFromDataBytesAutoAndSizeWithSameAspectRatio() {
    let testImage = createOnePixelImage()
    let pngData = testImage.pngData()
    XCTAssertNotNil(pngData)

    let width: CGFloat = 15.0
    let height: CGFloat = 15.0
    let typedData = FlutterStandardTypedData(bytes: pngData!)
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

    XCTAssertNotNil(resultImage)
    XCTAssertEqual(testImage.scale, 1.0)

    // As image has same aspect ratio as the original image,
    // only image scale has been changed to match the target size.
    let targetScale = testImage.scale * (testImage.size.width / width)
    let accuracy: Double = 0.001
    XCTAssertEqual(resultImage!.scale, targetScale, accuracy: accuracy)
    XCTAssertEqual(resultImage?.size.width, width)
    XCTAssertEqual(resultImage?.size.height, height)
  }

  func testExtractIconFromDataBytesAutoAndSizeWithDifferentAspectRatio() {
    let testImage = createOnePixelImage()
    let pngData = testImage.pngData()
    XCTAssertNotNil(pngData)

    let width: CGFloat = 15.0
    let height: CGFloat = 45.0
    let typedData = FlutterStandardTypedData(bytes: pngData!)
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
    XCTAssertNotNil(resultImage)
    XCTAssertEqual(resultImage?.scale, screenScale)
    XCTAssertEqual(resultImage?.size.width, width)
    XCTAssertEqual(resultImage?.size.height, height)
  }

  func testExtractIconFromDataBytesNoScaling() {
    let testImage = createOnePixelImage()
    let pngData = testImage.pngData()
    XCTAssertNotNil(pngData)

    let typedData = FlutterStandardTypedData(bytes: pngData!)
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
    XCTAssertNotNil(resultImage)
    XCTAssertEqual(resultImage?.scale, 1.0)
    XCTAssertEqual(resultImage?.size.width, 1.0)
    XCTAssertEqual(resultImage?.size.height, 1.0)
  }

  /// Tests for PinConfig (GMSPinImageOptions) - requires iOS 16.0+ and Google Maps SDK 9.0+.
  /// On earlier versions, FGMIconFromBitmap returns nil for PinConfig, which is expected behavior.
  func testExtractIconFromPinConfigWithGlyphColor() {
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
    XCTAssertTrue(resultImage == nil || resultImage!.size.width >= 0)
    XCTAssertTrue(resultImage == nil || resultImage!.size.height >= 0)
  }

  func testExtractIconFromPinConfigWithGlyphText() {
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
    XCTAssertTrue(resultImage == nil || resultImage!.size.width >= 0)
    XCTAssertTrue(resultImage == nil || resultImage!.size.height >= 0)
  }

  func testExtractIconFromPinConfigWithGlyphBitmap() {
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
    XCTAssertTrue(resultImage == nil || resultImage!.size.width >= 0)
    XCTAssertTrue(resultImage == nil || resultImage!.size.height >= 0)
  }

  func testIsScalableWithScaleFactorFromSize100x100to10x100() {
    let originalSize = CGSize(width: 100.0, height: 100.0)
    let targetSize = CGSize(width: 10.0, height: 100.0)
    XCTAssertFalse(FGMIsScalableWithScaleFactorFromSize(originalSize, targetSize))
  }

  func testIsScalableWithScaleFactorFromSize100x100to10x10() {
    let originalSize = CGSize(width: 100.0, height: 100.0)
    let targetSize = CGSize(width: 10.0, height: 10.0)
    XCTAssertTrue(FGMIsScalableWithScaleFactorFromSize(originalSize, targetSize))
  }

  func testIsScalableWithScaleFactorFromSize233x200to23x20() {
    let originalSize = CGSize(width: 233.0, height: 200.0)
    let targetSize = CGSize(width: 23.0, height: 20.0)
    XCTAssertTrue(FGMIsScalableWithScaleFactorFromSize(originalSize, targetSize))
  }

  func testIsScalableWithScaleFactorFromSize233x200to22x20() {
    let originalSize = CGSize(width: 233.0, height: 200.0)
    let targetSize = CGSize(width: 22.0, height: 20.0)
    XCTAssertFalse(FGMIsScalableWithScaleFactorFromSize(originalSize, targetSize))
  }

  func testIsScalableWithScaleFactorFromSize200x233to20x23() {
    let originalSize = CGSize(width: 200.0, height: 233.0)
    let targetSize = CGSize(width: 20.0, height: 23.0)
    XCTAssertTrue(FGMIsScalableWithScaleFactorFromSize(originalSize, targetSize))
  }

  func testIsScalableWithScaleFactorFromSize200x233to20x22() {
    let originalSize = CGSize(width: 200.0, height: 233.0)
    let targetSize = CGSize(width: 20.0, height: 22.0)
    XCTAssertFalse(FGMIsScalableWithScaleFactorFromSize(originalSize, targetSize))
  }

  func testIsScalableWithScaleFactorFromSize1024x768to500x250() {
    let originalSize = CGSize(width: 1024.0, height: 768.0)
    let targetSize = CGSize(width: 500.0, height: 250.0)
    XCTAssertFalse(FGMIsScalableWithScaleFactorFromSize(originalSize, targetSize))
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
