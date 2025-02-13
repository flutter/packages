// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AVFoundation
import Foundation
import XCTest

@testable import camera_avfoundation

final class CameraPropertiesTests: XCTestCase {
  // MARK: - Flash Mode Tests

  func testGetAVCaptureFlashModeForPigeonFlashMode() {
    XCTAssertEqual(
      AVCaptureDevice.FlashMode.off,
      FCPGetAVCaptureFlashModeForPigeonFlashMode(FCPPlatformFlashMode.off))
    XCTAssertEqual(
      AVCaptureDevice.FlashMode.auto,
      FCPGetAVCaptureFlashModeForPigeonFlashMode(FCPPlatformFlashMode.auto))
    XCTAssertEqual(
      AVCaptureDevice.FlashMode.on,
      FCPGetAVCaptureFlashModeForPigeonFlashMode(FCPPlatformFlashMode.always))

    // TODO(FirentisTFW): Migrate implementation to throw Swift error in this case.
    let exception = ExceptionCatcher.catchException {
      _ = FCPGetAVCaptureFlashModeForPigeonFlashMode(.torch)
    }
    XCTAssertNotNil(exception)
  }

  // MARK: - Video Format Tests

  func testGetPixelFormatForPigeonFormat() {
    XCTAssertEqual(
      kCVPixelFormatType_32BGRA,
      FCPGetPixelFormatForPigeonFormat(FCPPlatformImageFormatGroup.bgra8888))
    XCTAssertEqual(
      kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange,
      FCPGetPixelFormatForPigeonFormat(FCPPlatformImageFormatGroup.yuv420))
  }

  // MARK: - Device Orientation Tests

  func testGetUIDeviceOrientationForPigeonDeviceOrientation() {
    XCTAssertEqual(
      UIDeviceOrientation.portraitUpsideDown,
      FCPGetUIDeviceOrientationForPigeonDeviceOrientation(FCPPlatformDeviceOrientation.portraitDown)
    )
    XCTAssertEqual(
      UIDeviceOrientation.landscapeLeft,
      FCPGetUIDeviceOrientationForPigeonDeviceOrientation(
        FCPPlatformDeviceOrientation.landscapeLeft))
    XCTAssertEqual(
      UIDeviceOrientation.landscapeRight,
      FCPGetUIDeviceOrientationForPigeonDeviceOrientation(
        FCPPlatformDeviceOrientation.landscapeRight))
    XCTAssertEqual(
      UIDeviceOrientation.portrait,
      FCPGetUIDeviceOrientationForPigeonDeviceOrientation(FCPPlatformDeviceOrientation.portraitUp))
  }

  func testGetPigeonDeviceOrientationForUIDeviceOrientation() {
    XCTAssertEqual(
      FCPPlatformDeviceOrientation.portraitDown,
      FCPGetPigeonDeviceOrientationForOrientation(UIDeviceOrientation.portraitUpsideDown))
    XCTAssertEqual(
      FCPPlatformDeviceOrientation.landscapeLeft,
      FCPGetPigeonDeviceOrientationForOrientation(UIDeviceOrientation.landscapeLeft))
    XCTAssertEqual(
      FCPPlatformDeviceOrientation.landscapeRight,
      FCPGetPigeonDeviceOrientationForOrientation(UIDeviceOrientation.landscapeRight))
    XCTAssertEqual(
      FCPPlatformDeviceOrientation.portraitUp,
      FCPGetPigeonDeviceOrientationForOrientation(UIDeviceOrientation.portrait))
    // Test default case.
    XCTAssertEqual(
      FCPPlatformDeviceOrientation.portraitUp,
      FCPGetPigeonDeviceOrientationForOrientation(UIDeviceOrientation.unknown))
  }
}
