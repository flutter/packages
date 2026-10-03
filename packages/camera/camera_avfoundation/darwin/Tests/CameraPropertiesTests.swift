// Copyright 2013 The Flutter Authors
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
      getAVCaptureFlashMode(for: .off))
    XCTAssertEqual(
      AVCaptureDevice.FlashMode.auto,
      getAVCaptureFlashMode(for: .auto))
    XCTAssertEqual(
      AVCaptureDevice.FlashMode.on,
      getAVCaptureFlashMode(for: .always))
  }

  // MARK: - Video Format Tests

  func testGetPixelFormatForPigeonFormat() {
    XCTAssertEqual(
      kCVPixelFormatType_32BGRA,
      getPixelFormat(for: .bgra8888))
    XCTAssertEqual(
      kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange,
      getPixelFormat(for: .yuv420))
  }

  // MARK: - Device Orientation Tests

  func testGetUIDeviceOrientationForPigeonDeviceOrientation() {
    XCTAssertEqual(
      UIDeviceOrientation.portraitUpsideDown,
      getUIDeviceOrientation(for: .portraitDown)
    )
    XCTAssertEqual(
      UIDeviceOrientation.landscapeLeft,
      getUIDeviceOrientation(for: .landscapeLeft))
    XCTAssertEqual(
      UIDeviceOrientation.landscapeRight,
      getUIDeviceOrientation(for: .landscapeRight))
    XCTAssertEqual(
      UIDeviceOrientation.portrait,
      getUIDeviceOrientation(for: .portraitUp))
  }

  func testGetPigeonDeviceOrientationForUIDeviceOrientation() {
    XCTAssertEqual(
      PlatformDeviceOrientation.portraitDown,
      getPigeonDeviceOrientation(for: .portraitUpsideDown))
    XCTAssertEqual(
      PlatformDeviceOrientation.landscapeLeft,
      getPigeonDeviceOrientation(for: .landscapeLeft))
    XCTAssertEqual(
      PlatformDeviceOrientation.landscapeRight,
      getPigeonDeviceOrientation(for: .landscapeRight))
    XCTAssertEqual(
      PlatformDeviceOrientation.portraitUp,
      getPigeonDeviceOrientation(for: .portrait))
    // Test default case.
    XCTAssertEqual(
      PlatformDeviceOrientation.portraitUp,
      getPigeonDeviceOrientation(for: .unknown))
  }
}
