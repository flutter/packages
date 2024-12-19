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
#import "MockAssetWriter.h"
#import "MockCaptureConnection.h"

@import camera_avfoundation;
@import AVFoundation;

@interface FakeMediaSettingsAVWrapper : FLTCamMediaSettingsAVWrapper
@property(readonly, nonatomic) MockAssetWriterInput *inputMock;
@end

@implementation FakeMediaSettingsAVWrapper
- (instancetype)initWithInputMock:(MockAssetWriterInput *)inputMock {
  _inputMock = inputMock;
  return self;
}

- (BOOL)lockDevice:(AVCaptureDevice *)captureDevice error:(NSError **)outError {
  return YES;
}

- (void)unlockDevice:(AVCaptureDevice *)captureDevice {
}

- (void)beginConfigurationForSession:(id<FLTCaptureSession>)videoCaptureSession {
}

- (void)commitConfigurationForSession:(id<FLTCaptureSession>)videoCaptureSession {
}

- (void)setMinFrameDuration:(CMTime)duration onDevice:(AVCaptureDevice *)captureDevice {
}

- (void)setMaxFrameDuration:(CMTime)duration onDevice:(AVCaptureDevice *)captureDevice {
}

- (id<FLTAssetWriterInput>)assetWriterAudioInputWithOutputSettings:
    (nullable NSDictionary<NSString *, id> *)outputSettings {
  return _inputMock;
}

- (id<FLTAssetWriterInput>)assetWriterVideoInputWithOutputSettings:
    (nullable NSDictionary<NSString *, id> *)outputSettings {
  return _inputMock;
}

- (void)addInput:(AVAssetWriterInput *)writerInput toAssetWriter:(AVAssetWriter *)writer {
}

- (NSDictionary<NSString *, id> *)
    recommendedVideoSettingsForAssetWriterWithFileType:(AVFileType)fileType
                                             forOutput:(AVCaptureVideoDataOutput *)output {
  return @{};
}
@end

/// Includes test cases related to sample buffer handling for FLTCam class.
@interface FLTCamSampleBufferTests : XCTestCase
@property(readonly, nonatomic) dispatch_queue_t captureSessionQueue;
@property(readonly, nonatomic) FLTCam *camera;
@property(readonly, nonatomic) MockAssetWriter *writerMock;
@property(readonly, nonatomic) MockCaptureConnection *connectionMock;
@property(readonly, nonatomic) MockAssetWriterInput *inputMock;
@property(readonly, nonatomic) MockPixelBufferAdaptor *adaptorMock;
@property(readonly, nonatomic) FakeMediaSettingsAVWrapper *mediaSettingsWrapper;
@end

@implementation FLTCamSampleBufferTests

- (void)setUp {
  _captureSessionQueue = dispatch_queue_create("testing", NULL);
  _writerMock = [[MockAssetWriter alloc] init];
  _connectionMock = [[MockCaptureConnection alloc] init];
  _inputMock = [[MockAssetWriterInput alloc] init];
  _adaptorMock = [[MockPixelBufferAdaptor alloc] init];
  _mediaSettingsWrapper = [[FakeMediaSettingsAVWrapper alloc] initWithInputMock:_inputMock];

  _camera = FLTCreateCamWithCaptureSessionQueueAndMediaSettings(
      _captureSessionQueue,
      [FCPPlatformMediaSettings makeWithResolutionPreset:FCPPlatformResolutionPresetMedium
                                         framesPerSecond:nil
                                            videoBitrate:nil
                                            audioBitrate:nil
                                             enableAudio:YES],
      _mediaSettingsWrapper, nil, nil, _writerMock, _adaptorMock);
}

- (void)testSampleBufferCallbackQueueMustBeCaptureSessionQueue {
  XCTAssertEqual(_captureSessionQueue, _camera.captureVideoOutput.sampleBufferCallbackQueue,
                 @"Sample buffer callback queue must be the capture session queue.");
}

- (void)testCopyPixelBuffer {
  CMSampleBufferRef capturedSampleBuffer = FLTCreateTestSampleBuffer();
  CVPixelBufferRef capturedPixelBuffer = CMSampleBufferGetImageBuffer(capturedSampleBuffer);
  // Mimic sample buffer callback when captured a new video sample
  [_camera captureOutput:_camera.captureVideoOutput
      didOutputSampleBuffer:capturedSampleBuffer
             fromConnection:_connectionMock];
  CVPixelBufferRef deliveriedPixelBuffer = [_camera copyPixelBuffer];
  XCTAssertEqual(deliveriedPixelBuffer, capturedPixelBuffer,
                 @"FLTCam must deliver the latest captured pixel buffer to copyPixelBuffer API.");
  CFRelease(capturedSampleBuffer);
  CFRelease(deliveriedPixelBuffer);
}

- (void)testDidOutputSampleBuffer_mustNotChangeSampleBufferRetainCountAfterPauseResumeRecording {
  CMSampleBufferRef sampleBuffer = FLTCreateTestSampleBuffer();

  // Pause then resume the recording.
  [_camera
      startVideoRecordingWithCompletion:^(FlutterError *_Nullable error) {
      }
                  messengerForStreaming:nil];
  [_camera pauseVideoRecording];
  [_camera resumeVideoRecording];

  [_camera captureOutput:_camera.captureVideoOutput
      didOutputSampleBuffer:sampleBuffer
             fromConnection:_connectionMock];
  XCTAssertEqual(CFGetRetainCount(sampleBuffer), 1,
                 @"didOutputSampleBuffer must not change the sample buffer retain count after "
                 @"pause resume recording.");
  CFRelease(sampleBuffer);
}

- (void)testDidOutputSampleBufferIgnoreAudioSamplesBeforeVideoSamples {
  CMSampleBufferRef videoSample = FLTCreateTestSampleBuffer();
  CMSampleBufferRef audioSample = FLTCreateTestAudioSampleBuffer();

  __block NSArray *writtenSamples = @[];

  _adaptorMock.appendPixelBufferStub = ^BOOL(CVPixelBufferRef buffer, CMTime time) {
    writtenSamples = [writtenSamples arrayByAddingObject:@"video"];
    return YES;
  };

  _inputMock.isReadyForMoreMediaData = YES;
  _inputMock.appendSampleBufferStub = ^BOOL(CMSampleBufferRef buffer) {
    writtenSamples = [writtenSamples arrayByAddingObject:@"audio"];
    return YES;
  };

  [_camera
      startVideoRecordingWithCompletion:^(FlutterError *_Nullable error) {
      }
                  messengerForStreaming:nil];

  [_camera captureOutput:nil didOutputSampleBuffer:audioSample fromConnection:_connectionMock];
  [_camera captureOutput:nil didOutputSampleBuffer:audioSample fromConnection:_connectionMock];
  [_camera captureOutput:_camera.captureVideoOutput
      didOutputSampleBuffer:videoSample
             fromConnection:_connectionMock];
  [_camera captureOutput:nil didOutputSampleBuffer:audioSample fromConnection:_connectionMock];

  NSArray *expectedSamples = @[ @"video", @"audio" ];
  XCTAssertEqualObjects(writtenSamples, expectedSamples, @"First appended sample must be video.");

  CFRelease(videoSample);
  CFRelease(audioSample);
}

- (void)testDidOutputSampleBufferSampleTimesMustBeNumericAfterPauseResume {
  CMSampleBufferRef videoSample = FLTCreateTestSampleBuffer();
  CMSampleBufferRef audioSample = FLTCreateTestAudioSampleBuffer();

  __block BOOL videoAppended = NO;
  _adaptorMock.appendPixelBufferStub = ^BOOL(CVPixelBufferRef buffer, CMTime time) {
    XCTAssert(CMTIME_IS_NUMERIC(time));
    videoAppended = YES;
    return YES;
  };

  __block BOOL audioAppended = NO;
  _inputMock.isReadyForMoreMediaData = YES;
  _inputMock.appendSampleBufferStub = ^BOOL(CMSampleBufferRef buffer) {
    CMTime sampleTime = CMSampleBufferGetPresentationTimeStamp(buffer);
    XCTAssert(CMTIME_IS_NUMERIC(sampleTime));
    audioAppended = YES;
    return YES;
  };

  [_camera
      startVideoRecordingWithCompletion:^(FlutterError *_Nullable error) {
      }
                  messengerForStreaming:nil];

  [_camera pauseVideoRecording];
  [_camera resumeVideoRecording];

  [_camera captureOutput:_camera.captureVideoOutput
      didOutputSampleBuffer:videoSample
             fromConnection:_connectionMock];
  [_camera captureOutput:nil didOutputSampleBuffer:audioSample fromConnection:_connectionMock];
  [_camera captureOutput:_camera.captureVideoOutput
      didOutputSampleBuffer:videoSample
             fromConnection:_connectionMock];
  [_camera captureOutput:nil didOutputSampleBuffer:audioSample fromConnection:_connectionMock];
  XCTAssert(videoAppended && audioAppended, @"Video or audio was not appended.");

  CFRelease(videoSample);
  CFRelease(audioSample);
}

- (void)testDidOutputSampleBufferMustNotAppendSampleWhenReadyForMoreMediaDataIsNo {
  CMSampleBufferRef videoSample = FLTCreateTestSampleBuffer();

  __block BOOL sampleAppended = NO;
  _adaptorMock.appendPixelBufferStub = ^BOOL(CVPixelBufferRef buffer, CMTime time) {
    sampleAppended = YES;
    return YES;
  };

  [_camera
      startVideoRecordingWithCompletion:^(FlutterError *_Nullable error) {
      }
                  messengerForStreaming:nil];

  _inputMock.isReadyForMoreMediaData = YES;
  sampleAppended = NO;
  [_camera captureOutput:_camera.captureVideoOutput
      didOutputSampleBuffer:videoSample
             fromConnection:_connectionMock];
  XCTAssertTrue(sampleAppended, @"Sample was not appended.");

  _inputMock.isReadyForMoreMediaData = NO;
  sampleAppended = NO;
  [_camera captureOutput:_camera.captureVideoOutput
      didOutputSampleBuffer:videoSample
             fromConnection:_connectionMock];
  XCTAssertFalse(sampleAppended, @"Sample cannot be appended when readyForMoreMediaData is NO.");

  CFRelease(videoSample);
}

- (void)testStopVideoRecordingWithCompletionMustCallCompletion {
  __weak MockAssetWriter *weakWriter = _writerMock;
  _writerMock.finishWritingStub = ^(void (^param)(void)) {
    XCTAssert(weakWriter.status == AVAssetWriterStatusWriting,
              @"Cannot call finishWritingWithCompletionHandler when status is "
              @"not AVAssetWriterStatusWriting.");
    void (^handler)(void) = param;
    handler();
  };

  [_camera
      startVideoRecordingWithCompletion:^(FlutterError *_Nullable error) {
      }
                  messengerForStreaming:nil];

  __block BOOL completionCalled = NO;
  [_camera
      stopVideoRecordingWithCompletion:^(NSString *_Nullable path, FlutterError *_Nullable error) {
        completionCalled = YES;
      }];
  XCTAssert(completionCalled, @"Completion was not called.");
}

- (void)testStartWritingShouldNotBeCalledBetweenSampleCreationAndAppending {
  CMSampleBufferRef videoSample = FLTCreateTestSampleBuffer();

  __block BOOL startWritingCalled = NO;
  _writerMock.startWritingStub = ^{
    startWritingCalled = YES;
  };

  __block BOOL videoAppended = NO;
  _adaptorMock.appendPixelBufferStub = ^BOOL(CVPixelBufferRef buffer, CMTime time) {
    videoAppended = YES;
    return YES;
  };

  _inputMock.isReadyForMoreMediaData = YES;

  [_camera
      startVideoRecordingWithCompletion:^(FlutterError *_Nullable error) {
      }
                  messengerForStreaming:nil];

  BOOL startWritingCalledBefore = startWritingCalled;
  [_camera captureOutput:_camera.captureVideoOutput
      didOutputSampleBuffer:videoSample
             fromConnection:_connectionMock];
  XCTAssert((startWritingCalledBefore && videoAppended) || (startWritingCalled && !videoAppended),
            @"The startWriting was called between sample creation and appending.");

  [_camera captureOutput:_camera.captureVideoOutput
      didOutputSampleBuffer:videoSample
             fromConnection:_connectionMock];
  XCTAssert(videoAppended, @"Video was not appended.");

  CFRelease(videoSample);
}

@end
