// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera_avfoundation;
@import camera_avfoundation.Test;
@import XCTest;
@import AVFoundation;
#import <OCMock/OCMock.h>

@interface CameraPreviewPauseTests : XCTestCase
@end

@implementation CameraPreviewPauseTests

- (void)testPausePreviewWithResult_shouldPausePreview {
  FLTCam *camera = [[FLTCam alloc] init];

  [camera pausePreviewWithResult:^(id _Nullable result){
  }];
  XCTAssertTrue(camera.isPreviewPaused);
}

- (void)testResumePreviewWithResult_shouldResumePreview {
  FLTCam *camera = [[FLTCam alloc] init];

  [camera resumePreviewWithResult:^(id _Nullable result){
  }];
  XCTAssertFalse(camera.isPreviewPaused);
}

@end
