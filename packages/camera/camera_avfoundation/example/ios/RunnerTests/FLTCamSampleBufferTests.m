// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera_avfoundation;
@import camera_avfoundation.Test;
@import AVFoundation;
@import XCTest;
#import <OCMock/OCMock.h>
#import "CameraTestUtils.h"

/// Includes test cases related to sample buffer handling for FLTCam class.
@interface FLTCamSampleBufferTests : XCTestCase
@property(readonly, nonatomic) dispatch_queue_t captureSessionQueue;
@property(readonly, nonatomic) FLTCam *camera;
@property(readonly, nonatomic) CMSampleBufferRef sampleBuffer;
@end

@implementation FLTCamSampleBufferTests

- (void)setUp {
  _captureSessionQueue = dispatch_queue_create("testing", NULL);
  _camera = FLTCreateCamWithCaptureSessionQueue(_captureSessionQueue);
  _sampleBuffer = FLTCreateTestSampleBuffer();
}

- (void)tearDown {
  CFRelease(_sampleBuffer);
}

- (void)testSampleBufferCallbackQueueMustBeCaptureSessionQueue {
  XCTAssertEqual(_captureSessionQueue, _camera.captureVideoOutput.sampleBufferCallbackQueue,
                 @"Sample buffer callback queue must be the capture session queue.");
}

- (void)testCopyPixelBuffer {
  CVPixelBufferRef capturedPixelBuffer = CMSampleBufferGetImageBuffer(_sampleBuffer);
  // Mimic sample buffer callback when captured a new video sample
  [_camera captureOutput:_camera.captureVideoOutput
      didOutputSampleBuffer:_sampleBuffer
             fromConnection:OCMClassMock([AVCaptureConnection class])];
  CVPixelBufferRef deliveriedPixelBuffer = [_camera copyPixelBuffer];
  XCTAssertEqual(deliveriedPixelBuffer, capturedPixelBuffer,
                 @"FLTCam must deliver the latest captured pixel buffer to copyPixelBuffer API.");
  CFRelease(deliveriedPixelBuffer);
}

- (void)testFirstAppendedSampleShouldBeVideo {
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

  __block NSString *writtenSamples = @"";

  id videoMock = OCMClassMock([AVAssetWriterInputPixelBufferAdaptor class]);
  OCMStub([videoMock
           assetWriterInputPixelBufferAdaptorWithAssetWriterInput:OCMOCK_ANY
           sourcePixelBufferAttributes:OCMOCK_ANY]).andReturn(videoMock);
  OCMStub([videoMock appendPixelBuffer:[OCMArg anyPointer] withPresentationTime:kCMTimeZero])
    .andDo(^(NSInvocation *invocation) {
      writtenSamples = [writtenSamples stringByAppendingString:@"v"];
  });

  id audioMock = OCMClassMock([AVAssetWriterInput class]);
  OCMStub([audioMock
           assetWriterInputWithMediaType:[OCMArg isEqual:AVMediaTypeAudio]
           outputSettings:OCMOCK_ANY]).andReturn(audioMock);
  OCMStub([audioMock isReadyForMoreMediaData]).andReturn(YES);
  OCMStub([audioMock appendSampleBuffer:[OCMArg anyPointer]]).andDo(^(NSInvocation *invocation) {
    writtenSamples = [writtenSamples stringByAppendingString:@"a"];
  });

  FLTThreadSafeFlutterResult *result = [[FLTThreadSafeFlutterResult alloc] initWithResult:^(id result) {}];
  [_camera startVideoRecordingWithResult:result];

  char *samples = "aaavava";
  CMSampleBufferRef audioSampleBuffer = FLTCreateTestAudioSampleBuffer();
  for (int i = 0; i < strlen(samples); i++) {
    if(samples[i] == 'v') {
      [_camera captureOutput:_camera.captureVideoOutput didOutputSampleBuffer:_sampleBuffer
              fromConnection:connectionMock];
    } else {
      [_camera captureOutput:nil didOutputSampleBuffer:audioSampleBuffer
              fromConnection:connectionMock];
    }
  }
  CFRelease(audioSampleBuffer);

  XCTAssertEqualObjects(writtenSamples, @"vava", @"First appended sample must be video.");
}

@end
