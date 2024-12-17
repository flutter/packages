// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "CameraTestUtils.h"

#import <OCMock/OCMock.h>
@import AVFoundation;
@import camera_avfoundation;

#import "MockCaptureDeviceController.h"
#import "MockCaptureSession.h"
#import "MockAssetWriter.h"

static FCPPlatformMediaSettings *FCPGetDefaultMediaSettings(
    FCPPlatformResolutionPreset resolutionPreset) {
  return [FCPPlatformMediaSettings makeWithResolutionPreset:resolutionPreset
                                            framesPerSecond:nil
                                               videoBitrate:nil
                                               audioBitrate:nil
                                                enableAudio:YES];
}

FLTCam *FLTCreateCamWithCaptureSessionQueue(dispatch_queue_t captureSessionQueue) {
  return FLTCreateCamWithCaptureSessionQueueAndMediaSettings(captureSessionQueue, nil, nil, nil,
                                                             nil, nil);
}

FLTCam *FLTCreateCamWithCaptureSessionQueueAndMediaSettings(
    dispatch_queue_t captureSessionQueue, FCPPlatformMediaSettings *mediaSettings,
    FLTCamMediaSettingsAVWrapper *mediaSettingsAVWrapper, CaptureDeviceFactory captureDeviceFactory,
    id<FLTCapturePhotoOutput> capturePhotoOutput,
    id<FLTAssetWriter> assetWriter) {
  if (!mediaSettings) {
    mediaSettings = FCPGetDefaultMediaSettings(FCPPlatformResolutionPresetMedium);
  }

  if (!mediaSettingsAVWrapper) {
    mediaSettingsAVWrapper = [[FLTCamMediaSettingsAVWrapper alloc] init];
  }
  
  if (!assetWriter) {
    assetWriter = [[MockAssetWriter alloc] init];
  }

  MockCaptureSession *videoSessionMock = [[MockCaptureSession alloc] init];
  videoSessionMock.mockCanSetSessionPreset = YES;

  MockCaptureSession *audioSessionMock = [[MockCaptureSession alloc] init];
  audioSessionMock.mockCanSetSessionPreset = YES;

  __block MockCaptureDeviceController *mockDevice = [[MockCaptureDeviceController alloc] init];

  id frameRateRangeMock1 = OCMClassMock([AVFrameRateRange class]);
  OCMStub([frameRateRangeMock1 minFrameRate]).andReturn(3);
  OCMStub([frameRateRangeMock1 maxFrameRate]).andReturn(30);
  MockCaptureDeviceFormat *captureDeviceFormatMock1 = [[MockCaptureDeviceFormat alloc] init];
  captureDeviceFormatMock1.videoSupportedFrameRateRanges = @[ frameRateRangeMock1 ];

  id frameRateRangeMock2 = OCMClassMock([AVFrameRateRange class]);
  OCMStub([frameRateRangeMock2 minFrameRate]).andReturn(3);
  OCMStub([frameRateRangeMock2 maxFrameRate]).andReturn(60);
  MockCaptureDeviceFormat *captureDeviceFormatMock2 = [[MockCaptureDeviceFormat alloc] init];
  captureDeviceFormatMock1.videoSupportedFrameRateRanges = @[ frameRateRangeMock2 ];

    id inputMock = OCMClassMock([AVCaptureDeviceInput class]);
    OCMStub([inputMock deviceInputWithDevice:[OCMArg any] error:[OCMArg setTo:nil]])
        .andReturn(inputMock);

  mockDevice.formats = @[ captureDeviceFormatMock1, captureDeviceFormatMock2 ];
  mockDevice.activeFormat = captureDeviceFormatMock1;
  mockDevice.inputToReturn = inputMock;

  id fltCam = [[FLTCam alloc] initWithMediaSettings:mediaSettings
                             mediaSettingsAVWrapper:mediaSettingsAVWrapper
                             orientation:UIDeviceOrientationPortrait
                             videoCaptureSession:videoSessionMock
                             audioCaptureSession:audioSessionMock
                             captureSessionQueue:captureSessionQueue
                               captureDeviceFactory:captureDeviceFactory ?: ^id<FLTCaptureDeviceControlling>(void) {
                              return mockDevice;
                             }
                             videoDimensionsForFormat:^CMVideoDimensions(AVCaptureDeviceFormat *format) {
                               return CMVideoFormatDescriptionGetDimensions(format.formatDescription);
                             }
                             capturePhotoOutput:capturePhotoOutput
                             assetWriterFactory:^id<FLTAssetWriter> _Nonnull(NSURL *url, AVFileType fileType, NSError * _Nullable __autoreleasing * _Nullable error) {
                                  return assetWriter;
                            }
                            error:nil];

  id captureVideoDataOutputMock = [OCMockObject niceMockForClass:[AVCaptureVideoDataOutput class]];

  OCMStub([captureVideoDataOutputMock new]).andReturn(captureVideoDataOutputMock);

  OCMStub([captureVideoDataOutputMock
              recommendedVideoSettingsForAssetWriterWithOutputFileType:AVFileTypeMPEG4])
      .andReturn(@{});

  OCMStub([captureVideoDataOutputMock sampleBufferCallbackQueue]).andReturn(captureSessionQueue);

  
  MockPixelBufferAdaptor *videoMock = [[MockPixelBufferAdaptor alloc] init];
  MockAssetWriterInput *writerInputMock = [[MockAssetWriterInput alloc] init];

  return fltCam;
}

FLTCam *FLTCreateCamWithVideoCaptureSession(id<FLTCaptureSessionProtocol> captureSession,
                                            FCPPlatformResolutionPreset resolutionPreset) {
//    id inputMock = OCMClassMock([AVCaptureDeviceInput class]);
//    OCMStub([inputMock deviceInputWithDevice:[OCMArg any] error:[OCMArg setTo:nil]])
//        .andReturn(inputMock);

  MockCaptureSession *audioSessionMock = [[MockCaptureSession alloc] init];
  audioSessionMock.mockCanSetSessionPreset = YES;
  
  return [[FLTCam alloc] initWithMediaSettings:FCPGetDefaultMediaSettings(resolutionPreset)
                             mediaSettingsAVWrapper:[[FLTCamMediaSettingsAVWrapper alloc] init]
                             orientation:UIDeviceOrientationPortrait
                             videoCaptureSession:captureSession
                             audioCaptureSession:audioSessionMock
                             captureSessionQueue:dispatch_queue_create("capture_session_queue", NULL)
                               captureDeviceFactory: ^id<FLTCaptureDeviceControlling>(void) {
    return [[MockCaptureDeviceController alloc] init];
                             }
                             videoDimensionsForFormat:^CMVideoDimensions(AVCaptureDeviceFormat *format) {
                               return CMVideoFormatDescriptionGetDimensions(format.formatDescription);
                             }
                            capturePhotoOutput:[[FLTDefaultCapturePhotoOutput alloc] initWithPhotoOutput:[AVCapturePhotoOutput new]]                                 assetWriterFactory:^id<FLTAssetWriter> _Nonnull(NSURL *url, AVFileType fileType, NSError * _Nullable __autoreleasing * _Nullable error) {
    return [[FLTDefaultAssetWriter alloc] initWithURL:url fileType:fileType error:error];
  } error:nil];
}

FLTCam *FLTCreateCamWithVideoDimensionsForFormat(
    id<FLTCaptureSessionProtocol> captureSession, FCPPlatformResolutionPreset resolutionPreset,
    id<FLTCaptureDeviceControlling> captureDevice,
    VideoDimensionsForFormat videoDimensionsForFormat) {
  //  id inputMock = OCMClassMock([AVCaptureDeviceInput class]);
  //  OCMStub([inputMock deviceInputWithDevice:[OCMArg any] error:[OCMArg setTo:nil]])
  //      .andReturn(inputMock);
  //
  MockCaptureSession *audioSessionMock = [[MockCaptureSession alloc] init];
  audioSessionMock.mockCanSetSessionPreset = YES;

  return [[FLTCam alloc] initWithMediaSettings:FCPGetDefaultMediaSettings(resolutionPreset)
                        mediaSettingsAVWrapper:[[FLTCamMediaSettingsAVWrapper alloc] init]
                                   orientation:UIDeviceOrientationPortrait
                           videoCaptureSession:captureSession
                           audioCaptureSession:audioSessionMock
                           captureSessionQueue:dispatch_queue_create("capture_session_queue", NULL)
                          captureDeviceFactory:^id<FLTCaptureDeviceControlling>(void) {
                            return captureDevice;
                          }
                      videoDimensionsForFormat:videoDimensionsForFormat
                            capturePhotoOutput:[[FLTDefaultCapturePhotoOutput alloc]
                                                   initWithPhotoOutput:[AVCapturePhotoOutput new]]
                            assetWriterFactory:^id<FLTAssetWriter> _Nonnull(NSURL *url, AVFileType fileType, NSError * _Nullable __autoreleasing * _Nullable error) {
    return [[FLTDefaultAssetWriter alloc] initWithURL:url fileType:fileType error:error];
  }
                                         error:nil];
}

CMSampleBufferRef FLTCreateTestSampleBuffer(void) {
  CVPixelBufferRef pixelBuffer;
  CVPixelBufferCreate(kCFAllocatorDefault, 100, 100, kCVPixelFormatType_32BGRA, NULL, &pixelBuffer);

  CMFormatDescriptionRef formatDescription;
  CMVideoFormatDescriptionCreateForImageBuffer(kCFAllocatorDefault, pixelBuffer,
                                               &formatDescription);

  CMSampleTimingInfo timingInfo = {CMTimeMake(1, 44100), kCMTimeZero, kCMTimeInvalid};

  CMSampleBufferRef sampleBuffer;
  CMSampleBufferCreateReadyWithImageBuffer(kCFAllocatorDefault, pixelBuffer, formatDescription,
                                           &timingInfo, &sampleBuffer);

  CFRelease(pixelBuffer);
  CFRelease(formatDescription);
  return sampleBuffer;
}

CMSampleBufferRef FLTCreateTestAudioSampleBuffer(void) {
  CMBlockBufferRef blockBuffer;
  CMBlockBufferCreateWithMemoryBlock(kCFAllocatorDefault, NULL, 100, kCFAllocatorDefault, NULL, 0,
                                     100, kCMBlockBufferAssureMemoryNowFlag, &blockBuffer);

  CMFormatDescriptionRef formatDescription;
  AudioStreamBasicDescription basicDescription = {44100, kAudioFormatLinearPCM, 0, 1, 1, 1, 1, 8};
  CMAudioFormatDescriptionCreate(kCFAllocatorDefault, &basicDescription, 0, NULL, 0, NULL, NULL,
                                 &formatDescription);

  CMSampleBufferRef sampleBuffer;
  CMAudioSampleBufferCreateReadyWithPacketDescriptions(
      kCFAllocatorDefault, blockBuffer, formatDescription, 1, kCMTimeZero, NULL, &sampleBuffer);

  CFRelease(blockBuffer);
  CFRelease(formatDescription);
  return sampleBuffer;
}
