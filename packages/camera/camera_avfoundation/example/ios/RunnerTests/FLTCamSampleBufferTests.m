// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera_avfoundation;
#if __has_include(<camera_avfoundation/camera_avfoundation-umbrella.h>)
@import camera_avfoundation.Test;
#endif
@import AVFoundation;
@import XCTest;
#import <OCMock/OCMock.h>
#import "CameraTestUtils.h"

/// Includes test cases related to sample buffer handling for FLTCam class.
@interface FLTCamSampleBufferTests : XCTestCase

@end

@implementation FLTCamSampleBufferTests

- (void)testSampleBufferCallbackQueueMustBeCaptureSessionQueue {
  dispatch_queue_t captureSessionQueue = dispatch_queue_create("testing", NULL);
  FLTCam *cam = FLTCreateCamWithCaptureSessionQueue(captureSessionQueue);
  XCTAssertEqual(captureSessionQueue, cam.captureVideoOutput.sampleBufferCallbackQueue,
                 @"Sample buffer callback queue must be the capture session queue.");
}

- (void)testCopyPixelBuffer {
  FLTCam *cam = FLTCreateCamWithCaptureSessionQueue(dispatch_queue_create("test", NULL));
  CMSampleBufferRef capturedSampleBuffer = FLTCreateTestSampleBuffer();
  CVPixelBufferRef capturedPixelBuffer = CMSampleBufferGetImageBuffer(capturedSampleBuffer);
  // Mimic sample buffer callback when captured a new video sample
  [cam captureOutput:cam.captureVideoOutput
      didOutputSampleBuffer:capturedSampleBuffer
             fromConnection:OCMClassMock([AVCaptureConnection class])];
  CVPixelBufferRef deliveriedPixelBuffer = [cam copyPixelBuffer];
  XCTAssertEqual(deliveriedPixelBuffer, capturedPixelBuffer,
                 @"FLTCam must deliver the latest captured pixel buffer to copyPixelBuffer API.");
  CFRelease(capturedSampleBuffer);
  CFRelease(deliveriedPixelBuffer);
}

- (void)testDidOutputSampleBuffer_mustNotChangeSampleBufferRetainCountAfterPauseResumeRecording {
  FLTCam *cam = FLTCreateCamWithCaptureSessionQueue(dispatch_queue_create("test", NULL));
  CMSampleBufferRef sampleBuffer = FLTCreateTestSampleBuffer();

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

  // Pause then resume the recording.
  [cam
      startVideoRecordingWithCompletion:^(FlutterError *_Nullable error) {
      }
                  messengerForStreaming:nil];
  [cam pauseVideoRecording];
  [cam resumeVideoRecording];

  [cam captureOutput:cam.captureVideoOutput
      didOutputSampleBuffer:sampleBuffer
             fromConnection:OCMClassMock([AVCaptureConnection class])];
  XCTAssertEqual(CFGetRetainCount(sampleBuffer), 1,
                 @"didOutputSampleBuffer must not change the sample buffer retain count after "
                 @"pause resume recording.");
  CFRelease(sampleBuffer);
}

- (void)testDidOutputSampleBufferIgnoreAudioSamplesBeforeVideoSamples {
  FLTCam *cam = FLTCreateCamWithCaptureSessionQueue(dispatch_queue_create("testing", NULL));
  CMSampleBufferRef videoSample = FLTCreateTestSampleBuffer();
  CMSampleBufferRef audioSample = FLTCreateTestAudioSampleBuffer();

  id connectionMock = OCMClassMock([AVCaptureConnection class]);

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

  __block NSArray *writtenSamples = @[];

  id videoMock = OCMClassMock([AVAssetWriterInputPixelBufferAdaptor class]);
  OCMStub([videoMock assetWriterInputPixelBufferAdaptorWithAssetWriterInput:OCMOCK_ANY
                                                sourcePixelBufferAttributes:OCMOCK_ANY])
      .andReturn(videoMock);
  OCMStub([videoMock appendPixelBuffer:[OCMArg anyPointer] withPresentationTime:kCMTimeZero])
      .ignoringNonObjectArgs()
      .andDo(^(NSInvocation *invocation) {
        writtenSamples = [writtenSamples arrayByAddingObject:@"video"];
      });

  id audioMock = OCMClassMock([AVAssetWriterInput class]);
  OCMStub([audioMock assetWriterInputWithMediaType:[OCMArg isEqual:AVMediaTypeAudio]
                                    outputSettings:OCMOCK_ANY])
      .andReturn(audioMock);
  OCMStub([audioMock isReadyForMoreMediaData]).andReturn(YES);
  OCMStub([audioMock appendSampleBuffer:[OCMArg anyPointer]]).andDo(^(NSInvocation *invocation) {
    writtenSamples = [writtenSamples arrayByAddingObject:@"audio"];
  });

  [cam
      startVideoRecordingWithCompletion:^(FlutterError *_Nullable error) {
      }
                  messengerForStreaming:nil];

  [cam captureOutput:nil didOutputSampleBuffer:audioSample fromConnection:connectionMock];
  [cam captureOutput:nil didOutputSampleBuffer:audioSample fromConnection:connectionMock];
  [cam captureOutput:cam.captureVideoOutput
      didOutputSampleBuffer:videoSample
             fromConnection:connectionMock];
  [cam captureOutput:nil didOutputSampleBuffer:audioSample fromConnection:connectionMock];

  NSArray *expectedSamples = @[ @"video", @"audio" ];
  XCTAssertEqualObjects(writtenSamples, expectedSamples, @"First appended sample must be video.");

  CFRelease(videoSample);
  CFRelease(audioSample);
}

- (void)testDidOutputSampleBufferSampleTimesMustBeNumericAfterPauseResume {
  FLTCam *cam = FLTCreateCamWithCaptureSessionQueue(dispatch_queue_create("testing", NULL));
  CMSampleBufferRef videoSample = FLTCreateTestSampleBuffer();
  CMSampleBufferRef audioSample = FLTCreateTestAudioSampleBuffer();

  id connectionMock = OCMClassMock([AVCaptureConnection class]);

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

  __block BOOL videoAppended = NO;
  id adaptorMock = OCMClassMock([AVAssetWriterInputPixelBufferAdaptor class]);
  OCMStub([adaptorMock assetWriterInputPixelBufferAdaptorWithAssetWriterInput:OCMOCK_ANY
                                                  sourcePixelBufferAttributes:OCMOCK_ANY])
      .andReturn(adaptorMock);
  OCMStub([adaptorMock appendPixelBuffer:[OCMArg anyPointer] withPresentationTime:kCMTimeZero])
      .ignoringNonObjectArgs()
      .andDo(^(NSInvocation *invocation) {
        CMTime presentationTime;
        [invocation getArgument:&presentationTime atIndex:3];
        XCTAssert(CMTIME_IS_NUMERIC(presentationTime));
        videoAppended = YES;
      });

  __block BOOL audioAppended = NO;
  id inputMock = OCMClassMock([AVAssetWriterInput class]);
  OCMStub([inputMock assetWriterInputWithMediaType:OCMOCK_ANY outputSettings:OCMOCK_ANY])
      .andReturn(inputMock);
  OCMStub([inputMock isReadyForMoreMediaData]).andReturn(YES);
  OCMStub([inputMock appendSampleBuffer:[OCMArg anyPointer]]).andDo(^(NSInvocation *invocation) {
    CMSampleBufferRef sampleBuffer;
    [invocation getArgument:&sampleBuffer atIndex:2];
    CMTime sampleTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    XCTAssert(CMTIME_IS_NUMERIC(sampleTime));
    audioAppended = YES;
  });

  [cam
      startVideoRecordingWithCompletion:^(FlutterError *_Nullable error) {
      }
                  messengerForStreaming:nil];

  [cam pauseVideoRecording];
  [cam resumeVideoRecording];

  [cam captureOutput:cam.captureVideoOutput
      didOutputSampleBuffer:videoSample
             fromConnection:connectionMock];
  [cam captureOutput:nil didOutputSampleBuffer:audioSample fromConnection:connectionMock];
  [cam captureOutput:cam.captureVideoOutput
      didOutputSampleBuffer:videoSample
             fromConnection:connectionMock];
  [cam captureOutput:nil didOutputSampleBuffer:audioSample fromConnection:connectionMock];
  XCTAssert(videoAppended && audioAppended, @"Video or audio was not appended.");

  CFRelease(videoSample);
  CFRelease(audioSample);
}

@end
