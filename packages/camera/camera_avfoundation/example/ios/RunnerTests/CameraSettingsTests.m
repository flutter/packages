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

static const char *gTestResolutionPreset = "medium";
static const int gTestFramesPerSecond = 15;
static const int gTestVideoBitrate = 200000;
static const int gTestAudioBitrate = 32000;
static const bool gTestEnableAudio = YES;

@interface CameraCreateWithMediaSettingsParseTests : XCTestCase
@end

@interface MockErrorFlutterResult : MockFLTThreadSafeFlutterResult
@property(nonatomic, nullable) NSError *receivedError;
@end

@implementation MockErrorFlutterResult

- (void)sendError:(NSError *)error {
  _receivedError = error;
  [self.expectation fulfill];
}

@end

/// Expect that optional positive numbers can be parsed
@implementation CameraCreateWithMediaSettingsParseTests

- (NSError *)failingTestWithArguments:(NSDictionary *)arguments {
  CameraPlugin *camera = [[CameraPlugin alloc] initWithRegistry:nil messenger:nil];

  XCTestExpectation *expectation = [self expectationWithDescription:@"Result finished"];

  MockErrorFlutterResult *resultObject =
      [[MockErrorFlutterResult alloc] initWithExpectation:expectation];

  // Set up method call
  FlutterMethodCall *call = [FlutterMethodCall methodCallWithMethodName:@"create"
                                                              arguments:arguments];

  [camera createCameraOnSessionQueueWithCreateMethodCall:call result:resultObject];
  [self waitForExpectationsWithTimeout:1 handler:nil];

  // Verify the result
  NSError *receivedError = resultObject.receivedError;
  XCTAssertNotNil(receivedError);
  return receivedError;
}

- (NSError *)goodTestWithArguments:(NSDictionary *)arguments {
  CameraPlugin *camera = [[CameraPlugin alloc] initWithRegistry:nil messenger:nil];

  XCTestExpectation *expectation = [self expectationWithDescription:@"Result finished"];

  // Set up mocks for initWithCameraName method
  id avCaptureDeviceInputMock = OCMClassMock([AVCaptureDeviceInput class]);
  OCMStub([avCaptureDeviceInputMock deviceInputWithDevice:[OCMArg any] error:[OCMArg anyObjectRef]])
      .andReturn([AVCaptureInput alloc]);

  id avCaptureSessionMock = OCMClassMock([AVCaptureSession class]);
  OCMStub([avCaptureSessionMock alloc]).andReturn(avCaptureSessionMock);
  OCMStub([avCaptureSessionMock canSetSessionPreset:[OCMArg any]]).andReturn(YES);

  MockErrorFlutterResult *resultObject =
      [[MockErrorFlutterResult alloc] initWithExpectation:expectation];

  // Set up method call
  FlutterMethodCall *call = [FlutterMethodCall
      methodCallWithMethodName:@"create"
                     arguments:@{@"resolutionPreset" : @"medium", @"enableAudio" : @(1)}];

  [camera createCameraOnSessionQueueWithCreateMethodCall:call result:resultObject];
  [self waitForExpectationsWithTimeout:1 handler:nil];

  // Verify the result
  NSDictionary *dictionaryResult = (NSDictionary *)resultObject.receivedResult;
  XCTAssertNotNil(dictionaryResult);
  XCTAssert([[dictionaryResult allKeys] containsObject:@"cameraId"]);

  return resultObject.receivedError;
}

- (void)testCameraCreateWithMediaSettings_shouldRejectNegativeIntNumbers {
  id errorOrNil =
      [self failingTestWithArguments:@{@"fps" : @(-1), @"resolutionPreset" : @"medium"}];
  XCTAssertEqualObjects([errorOrNil localizedDescription], @"fps should be a positive number",
                        "should reject negative int number");
}

- (void)testCameraCreateWithMediaSettings_shouldRejectNegativeFloatingPointNumbers {
  id errorOrNil =
      [self failingTestWithArguments:@{@"fps" : @(-3.7), @"resolutionPreset" : @"medium"}];
  XCTAssertEqualObjects([errorOrNil localizedDescription], @"fps should be a positive number",
                        "should reject negative floating point number");
}

- (void)testCameraCreateWithMediaSettings_nanShouldBeParsedAsNil {
  id errorOrNil =
      [self failingTestWithArguments:@{@"fps" : @(NAN), @"resolutionPreset" : @"medium"}];
  XCTAssertEqualObjects([errorOrNil localizedDescription], @"fps should not be a nan",
                        "should reject NAN");
}

- (void)testCameraCreateWithMediaSettings_shouldNotRejectNilArguments {
  id errorOrNil = [self goodTestWithArguments:@{@"resolutionPreset" : @"medium"}];
  XCTAssertNil(errorOrNil, "should accept nil");
}

- (void)testCameraCreateWithMediaSettings_shouldAcceptNull {
  id errorOrNil =
      [self goodTestWithArguments:@{@"fps" : [NSNull null], @"resolutionPreset" : @"medium"}];
  XCTAssertNil(errorOrNil, "should accept [NSNull null]");
}

- (void)testCameraCreateWithMediaSettings_shouldAcceptPositiveDecimalNumbers {
  id errorOrNil = [self goodTestWithArguments:@{@"fps" : @(5), @"resolutionPreset" : @"medium"}];
  XCTAssertNil(errorOrNil, "should parse positive int number");
}

- (void)testCameraCreateWithMediaSettings_shouldAcceptPositiveFloatingPointNumbers {
  id errorOrNil = [self goodTestWithArguments:@{@"fps" : @(3.7), @"resolutionPreset" : @"medium"}];
  XCTAssertNil(errorOrNil, "should accept positive floating point number");
}

- (void)testCameraCreateWithMediaSettings_shouldRejectWrongVideoBitrate {
  id errorOrNil =
      [self failingTestWithArguments:@{@"videoBitrate" : @(-1), @"resolutionPreset" : @"medium"}];
  XCTAssertEqualObjects([errorOrNil localizedDescription],
                        @"videoBitrate should be a positive number",
                        "should reject wrong video bitrate");
}

- (void)testCameraCreateWithMediaSettings_shouldRejectWrongAudioBitrate {
  id errorOrNil =
      [self failingTestWithArguments:@{@"audioBitrate" : @(-1), @"resolutionPreset" : @"medium"}];
  XCTAssertEqualObjects([errorOrNil localizedDescription],
                        @"audioBitrate should be a positive number",
                        "should reject wrong audio bitrate");
}

- (void)testCameraCreateWithMediaSettings_shouldAcceptGoodVideoBitrate {
  id errorOrNil =
      [self goodTestWithArguments:@{@"videoBitrate" : @(200000), @"resolutionPreset" : @"medium"}];
  XCTAssertNil(errorOrNil, "should accept good video bitrate");
}

- (void)testCameraCreateWithMediaSettings_shouldAcceptGoodAudioBitrate {
  id errorOrNil =
      [self goodTestWithArguments:@{@"audioBitrate" : @(32000), @"resolutionPreset" : @"medium"}];
  XCTAssertNil(errorOrNil, "should accept good audio bitrate");
}

@end

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

- (void)beginConfigurationForSession:(AVCaptureSession *)videoCaptureSession {
  [_beginConfigurationExpectation fulfill];
}

- (void)commitConfigurationForSession:(AVCaptureSession *)videoCaptureSession {
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
  FLTCamMediaSettings *settings =
      [[FLTCamMediaSettings alloc] initWithFramesPerSecond:@(gTestFramesPerSecond)
                                              videoBitrate:@(gTestVideoBitrate)
                                              audioBitrate:@(gTestAudioBitrate)
                                               enableAudio:gTestEnableAudio];
  TestMediaSettingsAVWrapper *injectedWrapper =
      [[TestMediaSettingsAVWrapper alloc] initWithTestCase:self];

  FLTCam *camera = FLTCreateCamWithCaptureSessionQueueAndMediaSettings(
      dispatch_queue_create("test", NULL), settings, injectedWrapper);

  // Expect FPS configuration is passed to camera device.
  [self waitForExpectations:@[
    injectedWrapper.lockExpectation, injectedWrapper.beginConfigurationExpectation,
    injectedWrapper.minFrameDurationExpectation, injectedWrapper.maxFrameDurationExpectation,
    injectedWrapper.commitConfigurationExpectation, injectedWrapper.unlockExpectation
  ]
                    timeout:1
               enforceOrder:YES];

  FLTThreadSafeFlutterResult *result =
      [[FLTThreadSafeFlutterResult alloc] initWithResult:^(id result){
      }];

  [camera startVideoRecordingWithResult:result];

  [self waitForExpectations:@[
    injectedWrapper.audioSettingsExpectation, injectedWrapper.videoSettingsExpectation
  ]
                    timeout:1];
}

- (void)testSettings_ShouldBeSupportedByMethodCall {
  CameraPlugin *camera = [[CameraPlugin alloc] initWithRegistry:nil messenger:nil];

  XCTestExpectation *expectation = [self expectationWithDescription:@"Result finished"];

  // Set up mocks for initWithCameraName method
  id avCaptureDeviceInputMock = OCMClassMock([AVCaptureDeviceInput class]);
  OCMStub([avCaptureDeviceInputMock deviceInputWithDevice:[OCMArg any] error:[OCMArg anyObjectRef]])
      .andReturn([AVCaptureInput alloc]);

  id avCaptureSessionMock = OCMClassMock([AVCaptureSession class]);
  OCMStub([avCaptureSessionMock alloc]).andReturn(avCaptureSessionMock);
  OCMStub([avCaptureSessionMock canSetSessionPreset:[OCMArg any]]).andReturn(YES);

  MockFLTThreadSafeFlutterResult *resultObject =
      [[MockFLTThreadSafeFlutterResult alloc] initWithExpectation:expectation];

  // Set up method call
  FlutterMethodCall *call =
      [FlutterMethodCall methodCallWithMethodName:@"create"
                                        arguments:@{
                                          @"resolutionPreset" : @(gTestResolutionPreset),
                                          @"enableAudio" : @(gTestEnableAudio),
                                          @"fps" : @(gTestFramesPerSecond),
                                          @"videoBitrate" : @(gTestVideoBitrate),
                                          @"audioBitrate" : @(gTestAudioBitrate)
                                        }];

  [camera createCameraOnSessionQueueWithCreateMethodCall:call result:resultObject];
  [self waitForExpectationsWithTimeout:1 handler:nil];

  // Verify the result
  NSDictionary *dictionaryResult = (NSDictionary *)resultObject.receivedResult;
  XCTAssertNotNil(dictionaryResult);
  XCTAssert([[dictionaryResult allKeys] containsObject:@"cameraId"]);
}

@end
