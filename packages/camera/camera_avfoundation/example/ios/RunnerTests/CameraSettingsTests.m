// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera_avfoundation;
#if __has_include(<camera_avfoundation/camera_avfoundation-umbrella.h>)
@import camera_avfoundation.Test;
#endif
@import XCTest;
@import AVFoundation;

#import "CameraTestUtils.h"
#import "MockCameraDeviceDiscoverer.h"
#import "MockCaptureDevice.h"
#import "MockCaptureSession.h"
#import "MockFlutterBinaryMessenger.h"
#import "MockFlutterTextureRegistry.h"
#import "MockGlobalEventApi.h"

static const FCPPlatformResolutionPreset gTestResolutionPreset = FCPPlatformResolutionPresetMedium;
static const int gTestFramesPerSecond = 15;
static const int gTestVideoBitrate = 200000;
static const int gTestAudioBitrate = 32000;
static const BOOL gTestEnableAudio = YES;

@interface CameraSettingsTests : XCTestCase
@end

/**
 * A test implemetation of `FLTCamMediaSettingsAVWrapper`
 *
 * This xctest-expectation-checking implementation of `FLTCamMediaSettingsAVWrapper` is injected
 * into `camera-avfoundation` plugin instead of real AVFoundation-based realization.
 * Such kind of Dependency Injection (DI) allows to run media-settings tests without
 * any additional mocking of AVFoundation classes.
 */
@interface TestMediaSettingsAVWrapper : FLTCamMediaSettingsAVWrapper
@property(nonatomic, readonly) XCTestExpectation *lockExpectation;
@property(nonatomic, readonly) XCTestExpectation *unlockExpectation;
@property(nonatomic, readonly) XCTestExpectation *minFrameDurationExpectation;
@property(nonatomic, readonly) XCTestExpectation *maxFrameDurationExpectation;
@property(nonatomic, readonly) XCTestExpectation *beginConfigurationExpectation;
@property(nonatomic, readonly) XCTestExpectation *commitConfigurationExpectation;
@property(nonatomic, readonly) XCTestExpectation *audioSettingsExpectation;
@property(nonatomic, readonly) XCTestExpectation *videoSettingsExpectation;
@end

@implementation TestMediaSettingsAVWrapper

- (instancetype)initWithTestCase:(XCTestCase *)test {
  _lockExpectation = [test expectationWithDescription:@"lockExpectation"];
  _unlockExpectation = [test expectationWithDescription:@"unlockExpectation"];
  _minFrameDurationExpectation = [test expectationWithDescription:@"minFrameDurationExpectation"];
  _maxFrameDurationExpectation = [test expectationWithDescription:@"maxFrameDurationExpectation"];
  _beginConfigurationExpectation =
      [test expectationWithDescription:@"beginConfigurationExpectation"];
  _commitConfigurationExpectation =
      [test expectationWithDescription:@"commitConfigurationExpectation"];
  _audioSettingsExpectation = [test expectationWithDescription:@"audioSettingsExpectation"];
  _videoSettingsExpectation = [test expectationWithDescription:@"videoSettingsExpectation"];

  return self;
}

- (BOOL)lockDevice:(AVCaptureDevice *)captureDevice error:(NSError **)outError {
  [_lockExpectation fulfill];
  return YES;
}

- (void)unlockDevice:(AVCaptureDevice *)captureDevice {
  [_unlockExpectation fulfill];
}

- (void)beginConfigurationForSession:(NSObject<FLTCaptureSession> *)videoCaptureSession {
  [_beginConfigurationExpectation fulfill];
}

- (void)commitConfigurationForSession:(NSObject<FLTCaptureSession> *)videoCaptureSession {
  [_commitConfigurationExpectation fulfill];
}

- (void)setMinFrameDuration:(CMTime)duration onDevice:(AVCaptureDevice *)captureDevice {
  // FLTCam allows to set frame rate with 1/10 precision.
  CMTime expectedDuration = CMTimeMake(10, gTestFramesPerSecond * 10);

  if (duration.value == expectedDuration.value &&
      duration.timescale == expectedDuration.timescale) {
    [_minFrameDurationExpectation fulfill];
  }
}

- (void)setMaxFrameDuration:(CMTime)duration onDevice:(AVCaptureDevice *)captureDevice {
  // FLTCam allows to set frame rate with 1/10 precision.
  CMTime expectedDuration = CMTimeMake(10, gTestFramesPerSecond * 10);

  if (duration.value == expectedDuration.value &&
      duration.timescale == expectedDuration.timescale) {
    [_maxFrameDurationExpectation fulfill];
  }
}

- (AVAssetWriterInput *)assetWriterAudioInputWithOutputSettings:
    (nullable NSDictionary<NSString *, id> *)outputSettings {
  if ([outputSettings[AVEncoderBitRateKey] isEqual:@(gTestAudioBitrate)]) {
    [_audioSettingsExpectation fulfill];
  }

  return [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio
                                            outputSettings:outputSettings];
}

- (AVAssetWriterInput *)assetWriterVideoInputWithOutputSettings:
    (nullable NSDictionary<NSString *, id> *)outputSettings {
  if ([outputSettings[AVVideoCompressionPropertiesKey] isKindOfClass:[NSMutableDictionary class]]) {
    NSDictionary *compressionProperties = outputSettings[AVVideoCompressionPropertiesKey];

    if ([compressionProperties[AVVideoAverageBitRateKey] isEqual:@(gTestVideoBitrate)] &&
        [compressionProperties[AVVideoExpectedSourceFrameRateKey]
            isEqual:@(gTestFramesPerSecond)]) {
      [_videoSettingsExpectation fulfill];
    }
  }

  return [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo
                                            outputSettings:outputSettings];
}

- (void)addInput:(AVAssetWriterInput *)writerInput toAssetWriter:(AVAssetWriter *)writer {
}

- (NSDictionary<NSString *, id> *)
    recommendedVideoSettingsForAssetWriterWithFileType:(AVFileType)fileType
                                             forOutput:(AVCaptureVideoDataOutput *)output {
  return @{};
}

@end

@implementation CameraSettingsTests

/// Expect that FPS, video and audio bitrate are passed to camera device and asset writer.
- (void)testSettings_shouldPassConfigurationToCameraDeviceAndWriter {
  FCPPlatformMediaSettings *settings =
      [FCPPlatformMediaSettings makeWithResolutionPreset:gTestResolutionPreset
                                         framesPerSecond:@(gTestFramesPerSecond)
                                            videoBitrate:@(gTestVideoBitrate)
                                            audioBitrate:@(gTestAudioBitrate)
                                             enableAudio:gTestEnableAudio];
  TestMediaSettingsAVWrapper *injectedWrapper =
      [[TestMediaSettingsAVWrapper alloc] initWithTestCase:self];

  FLTCamConfiguration *configuration = FLTCreateTestCameraConfiguration();
  configuration.mediaSettingsWrapper = injectedWrapper;
  configuration.mediaSettings = settings;
  FLTCam *camera = FLTCreateCamWithConfiguration(configuration);

  // Expect FPS configuration is passed to camera device.
  [self waitForExpectations:@[
    injectedWrapper.lockExpectation, injectedWrapper.beginConfigurationExpectation,
    injectedWrapper.minFrameDurationExpectation, injectedWrapper.maxFrameDurationExpectation,
    injectedWrapper.commitConfigurationExpectation, injectedWrapper.unlockExpectation
  ]
                    timeout:1
               enforceOrder:YES];

  [camera
      startVideoRecordingWithCompletion:^(FlutterError *_Nullable error) {
      }
                  messengerForStreaming:nil];

  [self waitForExpectations:@[
    injectedWrapper.audioSettingsExpectation, injectedWrapper.videoSettingsExpectation
  ]
                    timeout:1];
}

- (void)testSettings_ShouldBeSupportedByMethodCall {
  MockCaptureDevice *mockDevice = [[MockCaptureDevice alloc] init];
  MockCaptureSession *mockSession = [[MockCaptureSession alloc] init];
  mockSession.canSetSessionPreset = YES;

  CameraPlugin *camera =
      [[CameraPlugin alloc] initWithRegistry:[[MockFlutterTextureRegistry alloc] init]
          messenger:[[MockFlutterBinaryMessenger alloc] init]
          globalAPI:[[MockGlobalEventApi alloc] init]
          deviceDiscoverer:[[MockCameraDeviceDiscoverer alloc] init]
          deviceFactory:^NSObject<FLTCaptureDevice> *(NSString *name) {
            return mockDevice;
          }
          captureSessionFactory:^NSObject<FLTCaptureSession> *_Nonnull {
            return mockSession;
          }
          captureDeviceInputFactory:[[MockCaptureDeviceInputFactory alloc] init]];

  XCTestExpectation *expectation = [self expectationWithDescription:@"Result finished"];

  // Set up method call
  FCPPlatformMediaSettings *mediaSettings =
      [FCPPlatformMediaSettings makeWithResolutionPreset:gTestResolutionPreset
                                         framesPerSecond:@(gTestFramesPerSecond)
                                            videoBitrate:@(gTestVideoBitrate)
                                            audioBitrate:@(gTestAudioBitrate)
                                             enableAudio:gTestEnableAudio];

  __block NSNumber *resultValue;
  [camera createCameraOnSessionQueueWithName:@"acamera"
                                    settings:mediaSettings
                                  completion:^(NSNumber *result, FlutterError *error) {
                                    XCTAssertNil(error);
                                    resultValue = result;
                                    [expectation fulfill];
                                  }];
  [self waitForExpectationsWithTimeout:30 handler:nil];

  // Verify the result
  XCTAssertNotNil(resultValue);
}

- (void)testSettings_ShouldSelectFormatWhichSupports60FPS {
  FCPPlatformMediaSettings *settings =
      [FCPPlatformMediaSettings makeWithResolutionPreset:gTestResolutionPreset
                                         framesPerSecond:@(60)
                                            videoBitrate:@(gTestVideoBitrate)
                                            audioBitrate:@(gTestAudioBitrate)
                                             enableAudio:gTestEnableAudio];

  FLTCamConfiguration *configuration = FLTCreateTestCameraConfiguration();
  configuration.mediaSettings = settings;
  FLTCam *camera = FLTCreateCamWithConfiguration(configuration);

  NSObject<FLTFrameRateRange> *range =
      camera.captureDevice.activeFormat.videoSupportedFrameRateRanges[0];
  XCTAssertLessThanOrEqual(range.minFrameRate, 60);
  XCTAssertGreaterThanOrEqual(range.maxFrameRate, 60);
}

@end
