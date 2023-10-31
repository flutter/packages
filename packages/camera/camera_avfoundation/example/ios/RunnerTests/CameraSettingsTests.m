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

static const char *TEST_RESOLUTION_PRESET = "medium";
static const int TEST_FPS = 15;
static const int TEST_VIDEO_BITRATE = 200000;
static const int TEST_AUDIO_BITRATE = 32000;
static const bool TEST_ENABLE_AUDIO = YES;

@interface CameraSettingsTests : XCTestCase
@property(readonly, nonatomic) FLTCam *camera;
@end

@implementation CameraSettingsTests

/// Expect that FPS, video and audio bitrate are passed to camera device and asset writer.
- (void)testSettings_shouldPassConfigurationToCameraDeviceAndWriter {
  XCTestExpectation *lockExpectation = [self expectationWithDescription:@"lockExpectation"];
  XCTestExpectation *unlockExpectation = [self expectationWithDescription:@"unlockExpectation"];
  XCTestExpectation *minFrameDurationExpectation =
      [self expectationWithDescription:@"minFrameDurationExpectation"];
  XCTestExpectation *maxFrameDurationExpectation =
      [self expectationWithDescription:@"maxFrameDurationExpectation"];
  XCTestExpectation *beginConfigurationExpectation =
      [self expectationWithDescription:@"beginConfigurationExpectation"];
  XCTestExpectation *commitConfigurationExpectation =
      [self expectationWithDescription:@"commitConfigurationExpectation"];

  dispatch_queue_t captureSessionQueue = dispatch_queue_create("testing", NULL);

  id deviceMock = [OCMockObject niceMockForClass:[AVCaptureDevice class]];

  OCMStub([deviceMock deviceWithUniqueID:[OCMArg any]]).andReturn(deviceMock);

  OCMStub([deviceMock lockForConfiguration:[OCMArg setTo:nil]])
      .andDo(^(NSInvocation *invocation) {
        [lockExpectation fulfill];
      })
      .andReturn(YES);
  OCMStub([deviceMock unlockForConfiguration]).andDo(^(NSInvocation *invocation) {
    [unlockExpectation fulfill];
  });
  OCMStub([deviceMock setActiveVideoMinFrameDuration:CMTimeMake(1, TEST_FPS)])
      .andDo(^(NSInvocation *invocation) {
        [minFrameDurationExpectation fulfill];
      });
  OCMStub([deviceMock setActiveVideoMaxFrameDuration:CMTimeMake(1, TEST_FPS)])
      .andDo(^(NSInvocation *invocation) {
        [maxFrameDurationExpectation fulfill];
      });

  OCMStub([deviceMock devices]).andReturn(@[ deviceMock ]);

  id inputMock = OCMClassMock([AVCaptureDeviceInput class]);
  OCMStub([inputMock deviceInputWithDevice:[OCMArg any] error:[OCMArg setTo:nil]])
      .andReturn(inputMock);

  id videoSessionMock = OCMClassMock([AVCaptureSession class]);
  OCMStub([videoSessionMock beginConfiguration]).andDo(^(NSInvocation *invocation) {
    [beginConfigurationExpectation fulfill];
  });
  OCMStub([videoSessionMock commitConfiguration]).andDo(^(NSInvocation *invocation) {
    [commitConfigurationExpectation fulfill];
  });

  OCMStub([videoSessionMock addInputWithNoConnections:[OCMArg any]]);  // no-op
  OCMStub([videoSessionMock canSetSessionPreset:[OCMArg any]]).andReturn(YES);

  id audioSessionMock = OCMClassMock([AVCaptureSession class]);
  OCMStub([audioSessionMock addInputWithNoConnections:[OCMArg any]]);  // no-op
  OCMStub([audioSessionMock canSetSessionPreset:[OCMArg any]]).andReturn(YES);

  id captureVideoDataOutputMock = [OCMockObject niceMockForClass:[AVCaptureVideoDataOutput class]];

  OCMStub([captureVideoDataOutputMock new]).andReturn(captureVideoDataOutputMock);

  OCMStub([captureVideoDataOutputMock
              recommendedVideoSettingsForAssetWriterWithOutputFileType:AVFileTypeMPEG4])
      .andReturn(@{});

  OCMStub([captureVideoDataOutputMock sampleBufferCallbackQueue]).andReturn(captureSessionQueue);

  NSError *error = nil;
  _camera = [[FLTCam alloc] initWithCameraName:@"camera"
                              resolutionPreset:@(TEST_RESOLUTION_PRESET)
                                           fps:@(TEST_FPS)
                                  videoBitrate:@(TEST_VIDEO_BITRATE)
                                  audioBitrate:@(TEST_AUDIO_BITRATE)
                                   enableAudio:TEST_ENABLE_AUDIO
                                   orientation:UIDeviceOrientationPortrait
                           videoCaptureSession:videoSessionMock
                           audioCaptureSession:audioSessionMock
                           captureSessionQueue:captureSessionQueue
                                         error:&error];

  XCTAssertNotNil(_camera, @"FLTCreateCamWithQueue should not be nil");
  XCTAssertNil(error, @"FLTCreateCamWithQueue should not return error: %@",
               error.localizedDescription);

  id captureConnectionMock = OCMClassMock([AVCaptureConnection class]);

  id writerMock = OCMClassMock([AVAssetWriter class]);
  OCMStub([writerMock alloc]).andReturn(writerMock);
  OCMStub([writerMock initWithURL:OCMOCK_ANY fileType:OCMOCK_ANY error:[OCMArg setTo:nil]])
      .andReturn(writerMock);
  __block AVAssetWriterStatus status = AVAssetWriterStatusUnknown;
  OCMStub([writerMock startWriting]).andDo(^(NSInvocation *invocation) {
    status = AVAssetWriterStatusWriting;
  });
  OCMStub([writerMock status]).andDo(^(NSInvocation *invocation) {
    [invocation setReturnValue:&status];
  });

  // Expect FPS configuration is passed to camera device.
  [self waitForExpectations:@[
    lockExpectation, beginConfigurationExpectation, minFrameDurationExpectation,
    maxFrameDurationExpectation, commitConfigurationExpectation, unlockExpectation
  ]
                    timeout:1
               enforceOrder:YES];

  id videoMock = OCMClassMock([AVAssetWriterInputPixelBufferAdaptor class]);
  OCMStub([videoMock assetWriterInputPixelBufferAdaptorWithAssetWriterInput:OCMOCK_ANY
                                                sourcePixelBufferAttributes:OCMOCK_ANY])
      .andReturn(videoMock);

  id writerInputMock = [OCMockObject niceMockForClass:[AVAssetWriterInput class]];

  // Expect audio bitrate is passed to writer.
  XCTestExpectation *audioSettingsExpectation =
      [self expectationWithDescription:@"audioSettingsExpectation"];

  OCMStub([writerInputMock assetWriterInputWithMediaType:AVMediaTypeAudio
                                          outputSettings:[OCMArg any]])
      .andDo(^(NSInvocation *invocation) {
        NSMutableDictionary *args;
        [invocation getArgument:&args atIndex:3];

        if ([args[AVEncoderBitRateKey] isEqual:@(TEST_AUDIO_BITRATE)]) {
          [audioSettingsExpectation fulfill];
        }
      })
      .andReturn(writerInputMock);

  // Expect FPS and video bitrate are passed to writer.
  XCTestExpectation *videoSettingsExpectation =
      [self expectationWithDescription:@"videoSettingsExpectation"];

  OCMStub([writerInputMock assetWriterInputWithMediaType:AVMediaTypeVideo
                                          outputSettings:[OCMArg any]])
      .andDo(^(NSInvocation *invocation) {
        NSMutableDictionary *args;
        [invocation getArgument:&args atIndex:3];

        if ([args[AVVideoCompressionPropertiesKey][AVVideoAverageBitRateKey]
                isEqual:@(TEST_VIDEO_BITRATE)] &&
            [args[AVVideoCompressionPropertiesKey][AVVideoExpectedSourceFrameRateKey]
                isEqual:@(TEST_FPS)]) {
          [videoSettingsExpectation fulfill];
        }
      })
      .andReturn(writerInputMock);

  FLTThreadSafeFlutterResult *result =
      [[FLTThreadSafeFlutterResult alloc] initWithResult:^(id result){
      }];

  [_camera startVideoRecordingWithResult:result];

  [self waitForExpectations:@[ audioSettingsExpectation, videoSettingsExpectation ] timeout:1];

  [writerMock stopMocking];
  [videoMock stopMocking];
  [audioSessionMock stopMocking];
  [captureConnectionMock stopMocking];
  [captureVideoDataOutputMock stopMocking];
  [audioSessionMock stopMocking];
  [videoSessionMock stopMocking];
  [inputMock stopMocking];
  [deviceMock stopMocking];
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
                                          @"resolutionPreset" : @(TEST_RESOLUTION_PRESET),
                                          @"enableAudio" : @(TEST_ENABLE_AUDIO),
                                          @"fps" : @(TEST_FPS),
                                          @"videoBitrate" : @(TEST_VIDEO_BITRATE),
                                          @"audioBitrate" : @(TEST_AUDIO_BITRATE)
                                        }];

  [camera createCameraOnSessionQueueWithCreateMethodCall:call result:resultObject];
  [self waitForExpectationsWithTimeout:1 handler:nil];

  // Verify the result
  NSDictionary *dictionaryResult = (NSDictionary *)resultObject.receivedResult;
  XCTAssertNotNil(dictionaryResult);
  XCTAssert([[dictionaryResult allKeys] containsObject:@"cameraId"]);

  [avCaptureSessionMock stopMocking];
  [avCaptureDeviceInputMock stopMocking];
}

@end
