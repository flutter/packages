// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AVFoundation
import XCTest

@testable import camera_avfoundation

// Import Objective-C part of the implementation when SwiftPM is used.
#if canImport(camera_avfoundation_objc)
  import camera_avfoundation_objc
#endif

final class CameraPreviewPauseTests: XCTestCase {
  func testPausePreviewWithResult_shouldPausePreview() {
    let camera = CameraTestUtils.createTestCamera()

    camera.pausePreview()

    XCTAssertTrue(camera.isPreviewPaused)
  }

  func testResumePreviewWithResult_shouldResumePreview() {
    let camera = CameraTestUtils.createTestCamera()

    camera.resumePreview()

    XCTAssertFalse(camera.isPreviewPaused)
  }
}
