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

static const int TEST_FPS = 15;
static const int TEST_VIDEO_BITRATE = 200000;
static const int TEST_AUDIO_BITRATE = 32000;

@interface CameraSettingsTests : XCTestCase
@end

@implementation CameraSettingsTests {
  XCTestExpectation *lockExpectation;
  XCTestExpectation *unlockExpectation;
  XCTestExpectation *minFrameDurationExpectation;
  XCTestExpectation *maxFrameDurationExpectation;
  XCTestExpectation *beginConfigurationExpectation;
  XCTestExpectation *commitConfigurationExpectation;
}

- (void)initExpectations {
  lockExpectation = [self expectationWithDescription:@"lockExpectation"];
  unlockExpectation = [self expectationWithDescription:@"unlockExpectation"];
  minFrameDurationExpectation = [self expectationWithDescription:@"minFrameDurationExpectation"];
  maxFrameDurationExpectation = [self expectationWithDescription:@"maxFrameDurationExpectation"];
  beginConfigurationExpectation =
      [self expectationWithDescription:@"beginConfigurationExpectation"];
  commitConfigurationExpectation =
      [self expectationWithDescription:@"commitConfigurationExpectation"];
}

- (FLTCam *)FLTCreateCamWithQueue:(dispatch_queue_t)captureSessionQueue
                 resolutionPreset:(NSString *)resolutionPreset
                              fps:(NSNumber *)fps
                     videoBitrate:(NSNumber *)videoBitrate
                     audioBitrate:(NSNumber *)audioBitrate
                      enableAudio:(BOOL)enableAudio {
  id deviceMock = [OCMockObject niceMockForClass:[AVCaptureDevice class]];

  [[[deviceMock stub] andReturn:deviceMock] deviceWithUniqueID:[OCMArg any]];

  OCMStub([deviceMock lockForConfiguration:[OCMArg setTo:nil]])
      .andDo(^(NSInvocation *invocation) {
        [self->lockExpectation fulfill];
      })
      .andReturn(YES);

  OCMStub([deviceMock unlockForConfiguration]).andDo(^(NSInvocation *invocation) {
    [self->unlockExpectation fulfill];
  });
  OCMStub([deviceMock setActiveVideoMinFrameDuration:CMTimeMake(1, TEST_FPS)])
      .andDo(^(NSInvocation *invocation) {
        [self->minFrameDurationExpectation fulfill];
      });
  OCMStub([deviceMock setActiveVideoMaxFrameDuration:CMTimeMake(1, TEST_FPS)])
      .andDo(^(NSInvocation *invocation) {
        [self->maxFrameDurationExpectation fulfill];
      });

  [[[deviceMock stub] andReturn:@[ deviceMock ]] devices];

  id inputMock = OCMClassMock([AVCaptureDeviceInput class]);
  OCMStub([inputMock deviceInputWithDevice:[OCMArg any] error:[OCMArg setTo:nil]])
      .andReturn(inputMock);

  id videoSessionMock = OCMClassMock([AVCaptureSession class]);
  OCMStub([videoSessionMock beginConfiguration]).andDo(^(NSInvocation *invocation) {
    [self->beginConfigurationExpectation fulfill];
  });
  OCMStub([videoSessionMock commitConfiguration]).andDo(^(NSInvocation *invocation) {
    [self->commitConfigurationExpectation fulfill];
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

  return [[FLTCam alloc] initWithCameraName:@"camera"
                           resolutionPreset:resolutionPreset
                                        fps:fps
                               videoBitrate:videoBitrate
                               audioBitrate:audioBitrate
                                enableAudio:enableAudio
                                orientation:UIDeviceOrientationPortrait
                        videoCaptureSession:videoSessionMock
                        audioCaptureSession:audioSessionMock
                        captureSessionQueue:captureSessionQueue
                                      error:nil];
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
                                          @"resolutionPreset" : @"medium",
                                          @"enableAudio" : @(true),
                                          @"fps" : @(TEST_FPS),
                                          @"videoBitrate" : @(TEST_VIDEO_BITRATE),
                                          @"audioBitrate" : @(TEST_AUDIO_BITRATE)
                                        }];

  [camera createCameraOnSessionQueueWithCreateMethodCall:call result:resultObject];
  [self waitForExpectationsWithTimeout:0.1 handler:nil];

  // Verify the result
  NSDictionary *dictionaryResult = (NSDictionary *)resultObject.receivedResult;
  XCTAssertNotNil(dictionaryResult);
  XCTAssert([[dictionaryResult allKeys] containsObject:@"cameraId"]);

  [avCaptureSessionMock stopMocking];
  [avCaptureDeviceInputMock stopMocking];
}

- (void)testSettings_ShouldPassConfigurationToCameraDeviceAndWriter {
  [self initExpectations];

  dispatch_queue_t captureSessionQueue = dispatch_queue_create("testing", NULL);

  FLTCam *camera = [self FLTCreateCamWithQueue:captureSessionQueue
                              resolutionPreset:@"low"
                                           fps:@(TEST_FPS)
                                  videoBitrate:@(TEST_VIDEO_BITRATE)
                                  audioBitrate:@(TEST_AUDIO_BITRATE)
                                   enableAudio:true];

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
                    timeout:0.1
               enforceOrder:YES];

  id videoMock = OCMClassMock([AVAssetWriterInputPixelBufferAdaptor class]);
  OCMStub([videoMock assetWriterInputPixelBufferAdaptorWithAssetWriterInput:OCMOCK_ANY
                                                sourcePixelBufferAttributes:OCMOCK_ANY])
      .andReturn(videoMock);

  id writerInputMock = [OCMockObject niceMockForClass:[AVAssetWriterInput class]];

  // Expect audio bitrate is passed to writer.
  XCTestExpectation *audioSettingsExpectation =
      [self expectationWithDescription:@"audioSettingsExpectation"];

  [[[[writerInputMock stub] andDo:^(NSInvocation *invocation) {
    NSMutableDictionary *args;
    [invocation getArgument:&args atIndex:3];

    if ([args[AVEncoderBitRateKey] isEqual:@(TEST_AUDIO_BITRATE)]) {
      [audioSettingsExpectation fulfill];
    }
  }] andReturn:writerInputMock] assetWriterInputWithMediaType:AVMediaTypeAudio
                                               outputSettings:[OCMArg any]];

  // Expect FPS and video bitrate are passed to writer.
  XCTestExpectation *videoSettingsExpectation =
      [self expectationWithDescription:@"videoSettingsExpectation"];

  [[[[writerInputMock stub] andDo:^(NSInvocation *invocation) {
    NSMutableDictionary *args;
    [invocation getArgument:&args atIndex:3];

    if ([args[AVVideoCompressionPropertiesKey][AVVideoAverageBitRateKey]
            isEqual:@(TEST_VIDEO_BITRATE)] &&
        [args[AVVideoCompressionPropertiesKey][AVVideoExpectedSourceFrameRateKey]
            isEqual:@(TEST_FPS)]) {
      [videoSettingsExpectation fulfill];
    }
  }] andReturn:writerInputMock] assetWriterInputWithMediaType:AVMediaTypeVideo
                                               outputSettings:[OCMArg any]];

  FLTThreadSafeFlutterResult *result =
      [[FLTThreadSafeFlutterResult alloc] initWithResult:^(id result){
      }];

  [camera startVideoRecordingWithResult:result];

  [self waitForExpectations:@[ audioSettingsExpectation, videoSettingsExpectation ] timeout:0.1];

  [captureConnectionMock stopMocking];
}

@end
