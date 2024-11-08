// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera_avfoundation;
#if __has_include(<camera_avfoundation/camera_avfoundation-umbrella.h>)
@import camera_avfoundation.Test;
#endif
@import XCTest;
@import AVFoundation;
#import <OCMock/OCMock.h>

@interface CameraPreviewPauseTests : XCTestCase
@end

@implementation CameraPreviewPauseTests

- (void)testPausePreviewWithResult_shouldPausePreview {
  FLTCam *camera = [[FLTCam alloc] init];

  [camera pausePreview];
  XCTAssertTrue(camera.isPreviewPaused);
}

- (void)testResumePreviewWithResult_shouldResumePreview {
  FLTCam *camera = [[FLTCam alloc] init];

  [camera resumePreview];
  XCTAssertFalse(camera.isPreviewPaused);
}

@end
