// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera_avfoundation;
@import camera_avfoundation.Test;
@import AVFoundation;
@import XCTest;
#import <OCMock/OCMock.h>
#import "CameraTestUtils.h"

/// Includes test cases related to photo capture operations for FLTCam class.
@interface FLTCamSessionPresetsTest : XCTestCase

@end

@implementation FLTCamSessionPresetsTest

- (void)testResolutionPresetWithCanSetSessionPresetMax_mustUpdateCaptureSessionPreset {
  NSString *expectedUltraHighPreset = AVCaptureSessionPreset3840x2160;
  NSString *expectedMaxPreset = AVCaptureSessionPresetInputPriority;

  id videoSessionMock = OCMClassMock([AVCaptureSession class]);
  OCMStub([videoSessionMock addInputWithNoConnections:[OCMArg any]]);  // no-op
  OCMStub([videoSessionMock canSetSessionPreset:[OCMArg any]]).andReturn(YES);
  OCMExpect([videoSessionMock setSessionPreset:[OCMArg checkWithBlock:^BOOL(id value) {
                                // Return YES if the value is one of the expected presets
                                return [value isEqualToString:expectedUltraHighPreset] ||
                                       [value isEqualToString:expectedMaxPreset];
                              }]]);

  FLTCreateCamWithVideoCaptureSession(videoSessionMock, @"max");

  OCMVerifyAll(videoSessionMock);
}

- (void)testResolutionPresetWithCanSetSessionPresetUltraHigh_mustUpdateCaptureSessionPreset {
  NSString *expectedPreset = AVCaptureSessionPreset3840x2160;

  id videoSessionMock = OCMClassMock([AVCaptureSession class]);
  OCMStub([videoSessionMock addInputWithNoConnections:[OCMArg any]]);  // no-op
  OCMStub([videoSessionMock canSetSessionPreset:[OCMArg any]]).andReturn(YES);

  // expect that setting "ultraHigh" resolutionPreset correctly updates videoCaptureSession
  OCMExpect([videoSessionMock setSessionPreset:expectedPreset]);

  FLTCreateCamWithVideoCaptureSession(videoSessionMock, @"ultraHigh");

  OCMVerifyAll(videoSessionMock);
}

@end
