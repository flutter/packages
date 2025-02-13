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
@end

@implementation FLTCamSampleBufferTests

- (FLTCam *)createCameraWithAssetWriter:(MockAssetWriter *)assetWriter
                                adaptor:(MockAssetWriterInputPixelBufferAdaptor *)adaptor
                                  input:(MockAssetWriterInput *)input {
  FLTCamConfiguration *configuration = FLTCreateTestCameraConfiguration();
  configuration.mediaSettings =
      [FCPPlatformMediaSettings makeWithResolutionPreset:FCPPlatformResolutionPresetMedium
                                         framesPerSecond:nil
                                            videoBitrate:nil
                                            audioBitrate:nil
                                             enableAudio:YES];
  configuration.mediaSettingsWrapper = [[FakeMediaSettingsAVWrapper alloc] initWithInputMock:input];

  configuration.assetWriterFactory =
      ^NSObject<FLTAssetWriter> *_Nonnull(NSURL *url, AVFileType fileType, NSError **error) {
    return assetWriter;
  };
  configuration.inputPixelBufferAdaptorFactory =
      ^id<FLTAssetWriterInputPixelBufferAdaptor> _Nonnull(NSObject<FLTAssetWriterInput> *input,
                                                          NSDictionary<NSString *, id> *settings) {
    return adaptor;
  };

  return FLTCreateCamWithConfiguration(configuration);
}

- (void)testSampleBufferCallbackQueueMustBeCaptureSessionQueue {
  dispatch_queue_t captureSessionQueue = dispatch_queue_create("testing", NULL);
  FLTCam *camera = FLTCreateCamWithCaptureSessionQueue(captureSessionQueue);
  XCTAssertEqual(captureSessionQueue, camera.captureVideoOutput.sampleBufferCallbackQueue,
                 @"Sample buffer callback queue must be the capture session queue.");
}

- (void)testCopyPixelBuffer {
  FLTCam *camera = FLTCreateCamWithConfiguration(FLTCreateTestCameraConfiguration());
  MockCaptureConnection *connectionMock = [[MockCaptureConnection alloc] init];
  CMSampleBufferRef capturedSampleBuffer = FLTCreateTestSampleBuffer();
  CVPixelBufferRef capturedPixelBuffer = CMSampleBufferGetImageBuffer(capturedSampleBuffer);
  // Mimic sample buffer callback when captured a new video sample
  [camera captureOutput:camera.captureVideoOutput
      didOutputSampleBuffer:capturedSampleBuffer
             fromConnection:connectionMock];
  CVPixelBufferRef deliveriedPixelBuffer = [camera copyPixelBuffer];
  XCTAssertEqual(deliveriedPixelBuffer, capturedPixelBuffer,
                 @"FLTCam must deliver the latest captured pixel buffer to copyPixelBuffer API.");
  CFRelease(capturedSampleBuffer);
  CFRelease(deliveriedPixelBuffer);
}

- (void)testDidOutputSampleBuffer_mustNotChangeSampleBufferRetainCountAfterPauseResumeRecording {
  FLTCam *camera = FLTCreateCamWithConfiguration(FLTCreateTestCameraConfiguration());
  MockCaptureConnection *connectionMock = [[MockCaptureConnection alloc] init];
  CMSampleBufferRef sampleBuffer = FLTCreateTestSampleBuffer();

  // Pause then resume the recording.
  [camera
      startVideoRecordingWithCompletion:^(FlutterError *_Nullable error) {
      }
                  messengerForStreaming:nil];
  [camera pauseVideoRecording];
  [camera resumeVideoRecording];

  [camera captureOutput:camera.captureVideoOutput
      didOutputSampleBuffer:sampleBuffer
             fromConnection:connectionMock];
  XCTAssertEqual(CFGetRetainCount(sampleBuffer), 1,
                 @"didOutputSampleBuffer must not change the sample buffer retain count after "
                 @"pause resume recording.");
  CFRelease(sampleBuffer);
}

- (void)testDidOutputSampleBufferIgnoreAudioSamplesBeforeVideoSamples {
  MockAssetWriter *writerMock = [[MockAssetWriter alloc] init];
  MockAssetWriterInputPixelBufferAdaptor *adaptorMock =
      [[MockAssetWriterInputPixelBufferAdaptor alloc] init];
  MockAssetWriterInput *inputMock = [[MockAssetWriterInput alloc] init];
  MockCaptureConnection *connectionMock = [[MockCaptureConnection alloc] init];

  __block AVAssetWriterStatus status = AVAssetWriterStatusUnknown;
  writerMock.startWritingStub = ^{
    status = AVAssetWriterStatusWriting;
  };
  writerMock.statusStub = ^AVAssetWriterStatus {
    return status;
  };

  FLTCam *camera = [self createCameraWithAssetWriter:writerMock
                                             adaptor:adaptorMock
                                               input:inputMock];
  CMSampleBufferRef videoSample = FLTCreateTestSampleBuffer();
  CMSampleBufferRef audioSample = FLTCreateTestAudioSampleBuffer();

  __block NSArray *writtenSamples = @[];

  adaptorMock.appendPixelBufferStub = ^BOOL(CVPixelBufferRef buffer, CMTime time) {
    writtenSamples = [writtenSamples arrayByAddingObject:@"video"];
    return YES;
  };

  inputMock.readyForMoreMediaData = YES;
  inputMock.appendSampleBufferStub = ^BOOL(CMSampleBufferRef buffer) {
    writtenSamples = [writtenSamples arrayByAddingObject:@"audio"];
    return YES;
  };

  [camera
      startVideoRecordingWithCompletion:^(FlutterError *_Nullable error) {
      }
                  messengerForStreaming:nil];

  [camera captureOutput:nil didOutputSampleBuffer:audioSample fromConnection:connectionMock];
  [camera captureOutput:nil didOutputSampleBuffer:audioSample fromConnection:connectionMock];
  [camera captureOutput:camera.captureVideoOutput
      didOutputSampleBuffer:videoSample
             fromConnection:connectionMock];
  [camera captureOutput:nil didOutputSampleBuffer:audioSample fromConnection:connectionMock];

  NSArray *expectedSamples = @[ @"video", @"audio" ];
  XCTAssertEqualObjects(writtenSamples, expectedSamples, @"First appended sample must be video.");

  CFRelease(videoSample);
  CFRelease(audioSample);
}

- (void)testDidOutputSampleBufferSampleTimesMustBeNumericAfterPauseResume {
  MockAssetWriter *writerMock = [[MockAssetWriter alloc] init];
  MockAssetWriterInputPixelBufferAdaptor *adaptorMock =
      [[MockAssetWriterInputPixelBufferAdaptor alloc] init];
  MockAssetWriterInput *inputMock = [[MockAssetWriterInput alloc] init];
  MockCaptureConnection *connectionMock = [[MockCaptureConnection alloc] init];

  FLTCam *camera = [self createCameraWithAssetWriter:writerMock
                                             adaptor:adaptorMock
                                               input:inputMock];
  CMSampleBufferRef videoSample = FLTCreateTestSampleBuffer();
  CMSampleBufferRef audioSample = FLTCreateTestAudioSampleBuffer();

  __block AVAssetWriterStatus status = AVAssetWriterStatusUnknown;
  writerMock.startWritingStub = ^{
    status = AVAssetWriterStatusWriting;
  };
  writerMock.statusStub = ^AVAssetWriterStatus {
    return status;
  };

  __block BOOL videoAppended = NO;
  adaptorMock.appendPixelBufferStub = ^BOOL(CVPixelBufferRef buffer, CMTime time) {
    XCTAssert(CMTIME_IS_NUMERIC(time));
    videoAppended = YES;
    return YES;
  };

  __block BOOL audioAppended = NO;
  inputMock.readyForMoreMediaData = YES;
  inputMock.appendSampleBufferStub = ^BOOL(CMSampleBufferRef buffer) {
    CMTime sampleTime = CMSampleBufferGetPresentationTimeStamp(buffer);
    XCTAssert(CMTIME_IS_NUMERIC(sampleTime));
    audioAppended = YES;
    return YES;
  };

  [camera
      startVideoRecordingWithCompletion:^(FlutterError *_Nullable error) {
      }
                  messengerForStreaming:nil];

  [camera pauseVideoRecording];
  [camera resumeVideoRecording];

  [camera captureOutput:camera.captureVideoOutput
      didOutputSampleBuffer:videoSample
             fromConnection:connectionMock];
  [camera captureOutput:nil didOutputSampleBuffer:audioSample fromConnection:connectionMock];
  [camera captureOutput:camera.captureVideoOutput
      didOutputSampleBuffer:videoSample
             fromConnection:connectionMock];
  [camera captureOutput:nil didOutputSampleBuffer:audioSample fromConnection:connectionMock];
  XCTAssert(videoAppended && audioAppended, @"Video or audio was not appended.");

  CFRelease(videoSample);
  CFRelease(audioSample);
}

- (void)testDidOutputSampleBufferMustNotAppendSampleWhenReadyForMoreMediaDataIsNo {
  MockAssetWriter *writerMock = [[MockAssetWriter alloc] init];
  MockAssetWriterInputPixelBufferAdaptor *adaptorMock =
      [[MockAssetWriterInputPixelBufferAdaptor alloc] init];
  MockAssetWriterInput *inputMock = [[MockAssetWriterInput alloc] init];
  MockCaptureConnection *connectionMock = [[MockCaptureConnection alloc] init];
  FLTCam *camera = [self createCameraWithAssetWriter:writerMock
                                             adaptor:adaptorMock
                                               input:inputMock];

  CMSampleBufferRef videoSample = FLTCreateTestSampleBuffer();

  __block BOOL sampleAppended = NO;
  adaptorMock.appendPixelBufferStub = ^BOOL(CVPixelBufferRef buffer, CMTime time) {
    sampleAppended = YES;
    return YES;
  };

  [camera
      startVideoRecordingWithCompletion:^(FlutterError *_Nullable error) {
      }
                  messengerForStreaming:nil];

  inputMock.readyForMoreMediaData = YES;
  sampleAppended = NO;
  [camera captureOutput:camera.captureVideoOutput
      didOutputSampleBuffer:videoSample
             fromConnection:connectionMock];
  XCTAssertTrue(sampleAppended, @"Sample was not appended.");

  inputMock.readyForMoreMediaData = NO;
  sampleAppended = NO;
  [camera captureOutput:camera.captureVideoOutput
      didOutputSampleBuffer:videoSample
             fromConnection:connectionMock];
  XCTAssertFalse(sampleAppended, @"Sample cannot be appended when readyForMoreMediaData is NO.");

  CFRelease(videoSample);
}

- (void)testStopVideoRecordingWithCompletionMustCallCompletion {
  MockAssetWriter *writerMock = [[MockAssetWriter alloc] init];
  MockAssetWriterInputPixelBufferAdaptor *adaptorMock =
      [[MockAssetWriterInputPixelBufferAdaptor alloc] init];
  MockAssetWriterInput *inputMock = [[MockAssetWriterInput alloc] init];
  FLTCam *camera = [self createCameraWithAssetWriter:writerMock
                                             adaptor:adaptorMock
                                               input:inputMock];

  __block AVAssetWriterStatus status = AVAssetWriterStatusUnknown;
  writerMock.startWritingStub = ^{
    status = AVAssetWriterStatusWriting;
  };
  writerMock.statusStub = ^AVAssetWriterStatus {
    return status;
  };
  writerMock.finishWritingStub = ^(void (^param)(void)) {
    XCTAssert(writerMock.status == AVAssetWriterStatusWriting,
              @"Cannot call finishWritingWithCompletionHandler when status is "
              @"not AVAssetWriterStatusWriting.");
    void (^handler)(void) = param;
    handler();
  };

  [camera
      startVideoRecordingWithCompletion:^(FlutterError *_Nullable error) {
      }
                  messengerForStreaming:nil];

  __block BOOL completionCalled = NO;
  [camera
      stopVideoRecordingWithCompletion:^(NSString *_Nullable path, FlutterError *_Nullable error) {
        completionCalled = YES;
      }];
  XCTAssert(completionCalled, @"Completion was not called.");
}

- (void)testStartWritingShouldNotBeCalledBetweenSampleCreationAndAppending {
  MockAssetWriter *writerMock = [[MockAssetWriter alloc] init];
  MockAssetWriterInputPixelBufferAdaptor *adaptorMock =
      [[MockAssetWriterInputPixelBufferAdaptor alloc] init];
  MockAssetWriterInput *inputMock = [[MockAssetWriterInput alloc] init];
  MockCaptureConnection *connectionMock = [[MockCaptureConnection alloc] init];
  FLTCam *camera = [self createCameraWithAssetWriter:writerMock
                                             adaptor:adaptorMock
                                               input:inputMock];

  CMSampleBufferRef videoSample = FLTCreateTestSampleBuffer();

  __block BOOL startWritingCalled = NO;
  writerMock.startWritingStub = ^{
    startWritingCalled = YES;
  };

  __block BOOL videoAppended = NO;
  adaptorMock.appendPixelBufferStub = ^BOOL(CVPixelBufferRef buffer, CMTime time) {
    videoAppended = YES;
    return YES;
  };

  inputMock.readyForMoreMediaData = YES;

  [camera
      startVideoRecordingWithCompletion:^(FlutterError *_Nullable error) {
      }
                  messengerForStreaming:nil];

  BOOL startWritingCalledBefore = startWritingCalled;
  [camera captureOutput:camera.captureVideoOutput
      didOutputSampleBuffer:videoSample
             fromConnection:connectionMock];
  XCTAssert((startWritingCalledBefore && videoAppended) || (startWritingCalled && !videoAppended),
            @"The startWriting was called between sample creation and appending.");

  [camera captureOutput:camera.captureVideoOutput
      didOutputSampleBuffer:videoSample
             fromConnection:connectionMock];
  XCTAssert(videoAppended, @"Video was not appended.");

  CFRelease(videoSample);
}

- (void)testStartVideoRecordingWithCompletionShouldNotDisableMixWithOthers {
  FLTCam *cam = FLTCreateCamWithCaptureSessionQueue(dispatch_queue_create("testing", NULL));

  [AVAudioSession.sharedInstance setCategory:AVAudioSessionCategoryPlayback
                                 withOptions:AVAudioSessionCategoryOptionMixWithOthers
                                       error:nil];
  [cam
      startVideoRecordingWithCompletion:^(FlutterError *_Nullable error) {
      }
                  messengerForStreaming:nil];
  XCTAssert(
      AVAudioSession.sharedInstance.categoryOptions & AVAudioSessionCategoryOptionMixWithOthers,
      @"Flag MixWithOthers was removed.");
  XCTAssert(AVAudioSession.sharedInstance.category == AVAudioSessionCategoryPlayAndRecord,
            @"Category should be PlayAndRecord.");
}

@end
