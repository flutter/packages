// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AVFoundation
import XCTest

@testable import camera_avfoundation

/// Includes test cases related to the `start` method of the Camera class.
final class CameraStartTests: XCTestCase {
  func testStart_setsMaxPhotoDimensionsToTheLargestSupportedByTheActiveFormat() throws {
    guard #available(iOS 16.0, *) else {
      throw XCTSkip("maxPhotoDimensions requires iOS 16.")
    }

    let activeFormatMock = MockCaptureDeviceFormat()
    activeFormatMock.supportedMaxPhotoDimensions = [
      CMVideoDimensions(width: 1920, height: 1080),
      CMVideoDimensions(width: 4032, height: 3024),
      CMVideoDimensions(width: 3264, height: 2448),
    ]
    let captureDeviceMock = MockCaptureDevice()
    captureDeviceMock.activeFormatStub = { activeFormatMock }

    let configuration = CameraTestUtils.createTestCameraConfiguration()
    configuration.videoCaptureDeviceFactory = { _ in captureDeviceMock }
    let cam = CameraTestUtils.createTestCamera(configuration)

    let mockOutput = MockCapturePhotoOutput()
    cam.capturePhotoOutput = mockOutput

    cam.start()

    XCTAssertEqual(mockOutput.maxPhotoDimensions.width, 4032)
    XCTAssertEqual(mockOutput.maxPhotoDimensions.height, 3024)
  }
}
