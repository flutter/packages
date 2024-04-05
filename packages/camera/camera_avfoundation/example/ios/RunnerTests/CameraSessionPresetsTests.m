// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera_avfoundation;
@import camera_avfoundation.Test;

@import AVFoundation;
@import XCTest;
#import <OCMock/OCMock.h>
#import "CameraTestUtils.h"

/// Includes test cases related to resolution presets setting  operations for FLTCam class.
@interface FLTCamSessionPresetsTest : XCTestCase
@end

@implementation FLTCamSessionPresetsTest

- (void)testResolutionPresetWithBestFormat_mustUpdateCaptureSessionPreset {
  NSString *expectedPreset = AVCaptureSessionPresetInputPriority;

  id videoSessionMock = OCMClassMock([AVCaptureSession class]);
  OCMStub([videoSessionMock addInputWithNoConnections:[OCMArg any]]);

  id captureFormatMock = OCMClassMock([AVCaptureDeviceFormat class]);
  id captureDeviceMock = OCMClassMock([AVCaptureDevice class]);
  OCMStub([captureDeviceMock formats]).andReturn(@[ captureFormatMock ]);

  OCMExpect([captureDeviceMock activeFormat]).andReturn(captureFormatMock);
  OCMExpect([captureDeviceMock lockForConfiguration:NULL]).andReturn(YES);
  OCMExpect([videoSessionMock setSessionPreset:expectedPreset]);

  FLTCreateCamWithVideoDimensionsForFormat(videoSessionMock, @"max", captureDeviceMock,
                                           ^CMVideoDimensions(AVCaptureDeviceFormat *format) {
                                             CMVideoDimensions videoDimensions;
                                             videoDimensions.width = 1;
                                             videoDimensions.height = 1;
                                             return videoDimensions;
                                           });

  OCMVerifyAll(captureDeviceMock);
  OCMVerifyAll(videoSessionMock);
}

- (void)testResolutionPresetWithCanSetSessionPresetMax_mustUpdateCaptureSessionPreset {
  NSString *expectedPreset = AVCaptureSessionPreset3840x2160;

  id videoSessionMock = OCMClassMock([AVCaptureSession class]);
  OCMStub([videoSessionMock addInputWithNoConnections:[OCMArg any]]);

  // Make sure that setting resolution preset for session always succeeds.
  OCMStub([videoSessionMock canSetSessionPreset:[OCMArg any]]).andReturn(YES);

  OCMExpect([videoSessionMock setSessionPreset:expectedPreset]);

  FLTCreateCamWithVideoCaptureSession(videoSessionMock, @"max");

  OCMVerifyAll(videoSessionMock);
}

- (void)testResolutionPresetWithCanSetSessionPresetUltraHigh_mustUpdateCaptureSessionPreset {
  NSString *expectedPreset = AVCaptureSessionPreset3840x2160;

  id videoSessionMock = OCMClassMock([AVCaptureSession class]);
  OCMStub([videoSessionMock addInputWithNoConnections:[OCMArg any]]);

  // Make sure that setting resolution preset for session always succeeds.
  OCMStub([videoSessionMock canSetSessionPreset:[OCMArg any]]).andReturn(YES);

  // Expect that setting "ultraHigh" resolutionPreset correctly updates videoCaptureSession.
  OCMExpect([videoSessionMock setSessionPreset:expectedPreset]);

  FLTCreateCamWithVideoCaptureSession(videoSessionMock, @"ultraHigh");

  OCMVerifyAll(videoSessionMock);
}

@end
