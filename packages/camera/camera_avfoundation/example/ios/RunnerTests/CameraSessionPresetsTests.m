// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera_avfoundation;
#if __has_include(<camera_avfoundation/camera_avfoundation-umbrella.h>)
@import camera_avfoundation.Test;
#endif

@import AVFoundation;
@import XCTest;
#import "CameraTestUtils.h"
#import "MockCaptureDeviceController.h"
#import "MockCaptureSession.h"

/// Includes test cases related to resolution presets setting  operations for FLTCam class.
@interface FLTCamSessionPresetsTest : XCTestCase
@end

@implementation FLTCamSessionPresetsTest

- (void)testResolutionPresetWithBestFormat_mustUpdateCaptureSessionPreset {
  NSString *expectedPreset = AVCaptureSessionPresetInputPriority;
  XCTestExpectation *presetExpectation = [self expectationWithDescription:@"Expected preset set"];

  FLTCamConfiguration *configuration = FLTCreateTestConfiguration();
  configuration.mediaSettings = FCPGetDefaultMediaSettings(FCPPlatformResolutionPresetMax);

  MockCaptureDeviceController *captureDeviceMock = [[MockCaptureDeviceController alloc] init];
  MockCaptureDeviceFormat *fakeFormat = [[MockCaptureDeviceFormat alloc] init];
  captureDeviceMock.formats = @[ fakeFormat ];
  captureDeviceMock.activeFormat = fakeFormat;
  configuration.captureDeviceFactory = ^id<FLTCaptureDeviceControlling> _Nonnull {
    return captureDeviceMock;
  };

  MockCaptureSession *videoSessionMock = [[MockCaptureSession alloc] init];
  videoSessionMock.setSessionPresetStub = ^(AVCaptureSessionPreset _Nonnull preset) {
    if (preset == expectedPreset) {
      [presetExpectation fulfill];
    }
  };
  configuration.videoCaptureSession = videoSessionMock;

  configuration.videoDimensionsForFormat = ^CMVideoDimensions(id<FLTCaptureDeviceFormat> format) {
    CMVideoDimensions videoDimensions;
    videoDimensions.width = 1;
    videoDimensions.height = 1;
    return videoDimensions;
  };

  FLTCreateCamWithConfiguration(configuration);

  [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testResolutionPresetWithCanSetSessionPresetMax_mustUpdateCaptureSessionPreset {
  NSString *expectedPreset = AVCaptureSessionPreset3840x2160;
  XCTestExpectation *expectation = [self expectationWithDescription:@"Expected preset set"];

  FLTCamConfiguration *configuration = FLTCreateTestConfiguration();

  MockCaptureSession *videoSessionMock = [[MockCaptureSession alloc] init];
  // Make sure that setting resolution preset for session always succeeds.
  videoSessionMock.mockCanSetSessionPreset = YES;
  videoSessionMock.setSessionPresetStub = ^(AVCaptureSessionPreset _Nonnull preset) {
    if (preset == expectedPreset) {
      [expectation fulfill];
    }
  };

  configuration.videoCaptureSession = videoSessionMock;
  configuration.mediaSettings = FCPGetDefaultMediaSettings(FCPPlatformResolutionPresetMax);
  configuration.captureDeviceFactory = ^id<FLTCaptureDeviceControlling> _Nonnull {
    return [[MockCaptureDeviceController alloc] init];
  };

  FLTCreateCamWithConfiguration(configuration);

  [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testResolutionPresetWithCanSetSessionPresetUltraHigh_mustUpdateCaptureSessionPreset {
  NSString *expectedPreset = AVCaptureSessionPreset3840x2160;
  XCTestExpectation *expectation = [self expectationWithDescription:@"Expected preset set"];

  FLTCamConfiguration *configuration = FLTCreateTestConfiguration();

  MockCaptureSession *videoSessionMock = [[MockCaptureSession alloc] init];
  // Make sure that setting resolution preset for session always succeeds.
  videoSessionMock.mockCanSetSessionPreset = YES;
  // Expect that setting "ultraHigh" resolutionPreset correctly updates videoCaptureSession.
  videoSessionMock.setSessionPresetStub = ^(AVCaptureSessionPreset _Nonnull preset) {
    if (preset == expectedPreset) {
      [expectation fulfill];
    }
  };

  configuration.videoCaptureSession = videoSessionMock;
  configuration.mediaSettings = FCPGetDefaultMediaSettings(FCPPlatformResolutionPresetUltraHigh);
  configuration.captureDeviceFactory = ^id<FLTCaptureDeviceControlling> _Nonnull {
    return [[MockCaptureDeviceController alloc] init];
  };

  FLTCreateCamWithConfiguration(configuration);

  [self waitForExpectationsWithTimeout:1 handler:nil];
}

@end
