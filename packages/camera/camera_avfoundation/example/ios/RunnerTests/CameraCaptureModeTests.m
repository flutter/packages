// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera_avfoundation;
@import camera_avfoundation.Test;
@import XCTest;
@import AVFoundation;
#import <OCMock/OCMock.h>
#import "CameraTestUtils.h"
#import "MockFLTThreadSafeFlutterResult.h"

@interface CameraCaptureModeTests : XCTestCase
@property(readonly, nonatomic) FLTCam *camera;
@end

@implementation CameraCaptureModeTests

- (void)setUp {
  dispatch_queue_t captureSessionQueue = dispatch_queue_create("capture_session_queue", NULL);
  dispatch_queue_set_specific(captureSessionQueue, FLTCaptureSessionQueueSpecific,
                              (void *)FLTCaptureSessionQueueSpecific, NULL);

  _camera = FLTCreateCamWithCaptureSessionQueue(captureSessionQueue);
}

- (void)testCaptureMode_shouldBeVideoByDefault {
  XCTAssertEqual(_camera.captureMode, FLTCaptureModeVideo);
}

- (void)testCaptureMode_shouldBeVideoAfterSettingVideo {
  [_camera setCaptureMode:FLTCaptureModePhoto];
  [_camera setCaptureMode:FLTCaptureModeVideo];
  XCTAssertEqual(_camera.captureMode, FLTCaptureModeVideo);
}

- (void)testCaptureMode_shouldBePhotoAfterSettingPhoto {
  [_camera setCaptureMode:FLTCaptureModePhoto];
  XCTAssertEqual(_camera.captureMode, FLTCaptureModePhoto);
}

@end