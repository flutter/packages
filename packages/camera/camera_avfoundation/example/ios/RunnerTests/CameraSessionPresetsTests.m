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
#import "MockCaptureDevice.h"
#import "MockCaptureDeviceFormat.h"
#import "MockCaptureSession.h"

/// Includes test cases related to resolution presets setting  operations for FLTCam class.
@interface FLTCamSessionPresetsTest : XCTestCase
@end

@implementation FLTCamSessionPresetsTest

- (void)testResolutionPresetWithBestFormat_mustUpdateCaptureSessionPreset {
  NSString *expectedPreset = AVCaptureSessionPresetInputPriority;
  XCTestExpectation *presetExpectation = [self expectationWithDescription:@"Expected preset set"];
  XCTestExpectation *lockForConfigurationExpectation =
      [self expectationWithDescription:@"Expected lockForConfiguration called"];

  MockCaptureSession *videoSessionMock = [[MockCaptureSession alloc] init];
  videoSessionMock.setSessionPresetStub = ^(NSString *preset) {
    if (preset == expectedPreset) {
      [presetExpectation fulfill];
    }
  };

  MockCaptureDeviceFormat *captureFormatMock = [[MockCaptureDeviceFormat alloc] init];

  MockCaptureDevice *captureDeviceMock = [[MockCaptureDevice alloc] init];
  captureDeviceMock.formats = @[ captureFormatMock ];
  captureDeviceMock.activeFormat = captureFormatMock;
  captureDeviceMock.lockForConfigurationStub =
      ^BOOL(NSError *__autoreleasing _Nullable *_Nullable error) {
        [lockForConfigurationExpectation fulfill];
        return YES;
      };

  FLTCamConfiguration *configuration = FLTCreateTestCameraConfiguration();
  configuration.captureDeviceFactory = ^NSObject<FLTCaptureDevice> *_Nonnull {
    return captureDeviceMock;
  };
  configuration.videoDimensionsForFormat =
      ^CMVideoDimensions(NSObject<FLTCaptureDeviceFormat> *format) {
        CMVideoDimensions videoDimensions;
        videoDimensions.width = 1;
        videoDimensions.height = 1;
        return videoDimensions;
      };
  configuration.videoCaptureSession = videoSessionMock;
  configuration.mediaSettings = FCPGetDefaultMediaSettings(FCPPlatformResolutionPresetMax);

  FLTCreateCamWithConfiguration(configuration);

  [self waitForExpectationsWithTimeout:30 handler:nil];
}

- (void)testResolutionPresetWithCanSetSessionPresetMax_mustUpdateCaptureSessionPreset {
  NSString *expectedPreset = AVCaptureSessionPreset3840x2160;
  XCTestExpectation *expectation = [self expectationWithDescription:@"Expected preset set"];

  MockCaptureSession *videoSessionMock = [[MockCaptureSession alloc] init];

  // Make sure that setting resolution preset for session always succeeds.
  videoSessionMock.canSetSessionPreset = YES;

  videoSessionMock.setSessionPresetStub = ^(NSString *preset) {
    if (preset == expectedPreset) {
      [expectation fulfill];
    }
  };

  FLTCamConfiguration *configuration = FLTCreateTestCameraConfiguration();
  configuration.videoCaptureSession = videoSessionMock;
  configuration.mediaSettings = FCPGetDefaultMediaSettings(FCPPlatformResolutionPresetMax);
  configuration.captureDeviceFactory = ^NSObject<FLTCaptureDevice> * {
    return [[MockCaptureDevice alloc] init];
  };

  FLTCreateCamWithConfiguration(configuration);

  [self waitForExpectationsWithTimeout:30 handler:nil];
}

- (void)testResolutionPresetWithCanSetSessionPresetUltraHigh_mustUpdateCaptureSessionPreset {
  NSString *expectedPreset = AVCaptureSessionPreset3840x2160;
  XCTestExpectation *expectation = [self expectationWithDescription:@"Expected preset set"];

  MockCaptureSession *videoSessionMock = [[MockCaptureSession alloc] init];

  // Make sure that setting resolution preset for session always succeeds.
  videoSessionMock.canSetSessionPreset = YES;

  // Expect that setting "ultraHigh" resolutionPreset correctly updates videoCaptureSession.
  videoSessionMock.setSessionPresetStub = ^(NSString *preset) {
    if (preset == expectedPreset) {
      [expectation fulfill];
    }
  };

  FLTCamConfiguration *configuration = FLTCreateTestCameraConfiguration();
  configuration.videoCaptureSession = videoSessionMock;
  configuration.mediaSettings = FCPGetDefaultMediaSettings(FCPPlatformResolutionPresetUltraHigh);

  FLTCreateCamWithConfiguration(configuration);

  [self waitForExpectationsWithTimeout:30 handler:nil];
}

@end
