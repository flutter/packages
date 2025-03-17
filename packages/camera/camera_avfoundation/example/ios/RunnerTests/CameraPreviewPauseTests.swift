// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AVFoundation
import XCTest

@testable import camera_avfoundation

final class CameraPreviewPauseTests: XCTestCase {
  func testPausePreviewWithResult_shouldPausePreview() {
    let camera = FLTCam()

    camera.pausePreview()

    XCTAssertTrue(camera.isPreviewPaused)
  }

  func testResumePreviewWithResult_shouldResumePreview() {
    let camera = FLTCam()

    camera.resumePreview()

    XCTAssertFalse(camera.isPreviewPaused)
  }
}
