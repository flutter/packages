// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import camera_avfoundation
import XCTest
import AVFoundation

final class CameraPreviewPauseTests: XCTestCase {
  private var camera: FLTCam!
  
  override func setUp() {
    camera = FLTCam()
  }
  
  func testPausePreviewWithResult_shouldPausePreview() {
    camera.pausePreview()
      
    XCTAssertTrue(camera.isPreviewPaused)
  }
  
  func testResumePreviewWithResult_shouldResumePreview() {
    camera.resumePreview()
      
    XCTAssertFalse(camera.isPreviewPaused)
  }
}
