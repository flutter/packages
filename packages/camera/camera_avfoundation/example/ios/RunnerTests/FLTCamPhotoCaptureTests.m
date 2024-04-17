// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera_avfoundation;
@import camera_avfoundation.Test;
@import AVFoundation;
@import XCTest;
#import <OCMock/OCMock.h>
#import "CameraTestUtils.h"

/// Includes test cases related to photo capture operations for FLTCam class.
@interface FLTCamPhotoCaptureTests : XCTestCase

@end

@implementation FLTCamPhotoCaptureTests

- (void)testCaptureToFile_mustReportErrorToResultIfSavePhotoDelegateCompletionsWithError {
  XCTestExpectation *errorExpectation =
      [self expectationWithDescription:
                @"Must send error to result if save photo delegate completes with error."];

  dispatch_queue_t captureSessionQueue = dispatch_queue_create("capture_session_queue", NULL);
  dispatch_queue_set_specific(captureSessionQueue, FLTCaptureSessionQueueSpecific,
                              (void *)FLTCaptureSessionQueueSpecific, NULL);
  FLTCam *cam = FLTCreateCamWithCaptureSessionQueue(captureSessionQueue);
  AVCapturePhotoSettings *settings = [AVCapturePhotoSettings photoSettings];
  id mockSettings = OCMClassMock([AVCapturePhotoSettings class]);
  OCMStub([mockSettings photoSettings]).andReturn(settings);

  NSError *error = [NSError errorWithDomain:@"test" code:0 userInfo:nil];

  id mockOutput = OCMClassMock([AVCapturePhotoOutput class]);
  OCMStub([mockOutput capturePhotoWithSettings:OCMOCK_ANY delegate:OCMOCK_ANY])
      .andDo(^(NSInvocation *invocation) {
        FLTSavePhotoDelegate *delegate = cam.inProgressSavePhotoDelegates[@(settings.uniqueID)];
        // Completion runs on IO queue.
        dispatch_queue_t ioQueue = dispatch_queue_create("io_queue", NULL);
        dispatch_async(ioQueue, ^{
          delegate.completionHandler(nil, error);
        });
      });
  cam.capturePhotoOutput = mockOutput;

  // `FLTCam::captureToFile` runs on capture session queue.
  dispatch_async(captureSessionQueue, ^{
    [cam captureToFile:^(id _Nullable result) {
      XCTAssertTrue([result isKindOfClass:[FlutterError class]]);
      [errorExpectation fulfill];
    }];
  });

  [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testCaptureToFile_mustReportPathToResultIfSavePhotoDelegateCompletionsWithPath {
  XCTestExpectation *pathExpectation =
      [self expectationWithDescription:
                @"Must send file path to result if save photo delegate completes with file path."];

  dispatch_queue_t captureSessionQueue = dispatch_queue_create("capture_session_queue", NULL);
  dispatch_queue_set_specific(captureSessionQueue, FLTCaptureSessionQueueSpecific,
                              (void *)FLTCaptureSessionQueueSpecific, NULL);
  FLTCam *cam = FLTCreateCamWithCaptureSessionQueue(captureSessionQueue);

  AVCapturePhotoSettings *settings = [AVCapturePhotoSettings photoSettings];
  id mockSettings = OCMClassMock([AVCapturePhotoSettings class]);
  OCMStub([mockSettings photoSettings]).andReturn(settings);

  NSString *filePath = @"test";

  id mockOutput = OCMClassMock([AVCapturePhotoOutput class]);
  OCMStub([mockOutput capturePhotoWithSettings:OCMOCK_ANY delegate:OCMOCK_ANY])
      .andDo(^(NSInvocation *invocation) {
        FLTSavePhotoDelegate *delegate = cam.inProgressSavePhotoDelegates[@(settings.uniqueID)];
        // Completion runs on IO queue.
        dispatch_queue_t ioQueue = dispatch_queue_create("io_queue", NULL);
        dispatch_async(ioQueue, ^{
          delegate.completionHandler(filePath, nil);
        });
      });
  cam.capturePhotoOutput = mockOutput;

  // `FLTCam::captureToFile` runs on capture session queue.
  dispatch_async(captureSessionQueue, ^{
    [cam captureToFile:^(id _Nullable result) {
      XCTAssertEqual(result, filePath);
      [pathExpectation fulfill];
    }];
  });
  [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testCaptureToFile_mustReportFileExtensionWithHeifWhenHEVCIsAvailableAndFileFormatIsHEIF {
  XCTestExpectation *expectation =
      [self expectationWithDescription:
                @"Test must set extension to heif if availablePhotoCodecTypes contains HEVC."];
  dispatch_queue_t captureSessionQueue = dispatch_queue_create("capture_session_queue", NULL);
  dispatch_queue_set_specific(captureSessionQueue, FLTCaptureSessionQueueSpecific,
                              (void *)FLTCaptureSessionQueueSpecific, NULL);
  FLTCam *cam = FLTCreateCamWithCaptureSessionQueue(captureSessionQueue);
  [cam setImageFileFormat:FCPFileFormatHEIF];

  AVCapturePhotoSettings *settings =
      [AVCapturePhotoSettings photoSettingsWithFormat:@{AVVideoCodecKey : AVVideoCodecTypeHEVC}];

  id mockSettings = OCMClassMock([AVCapturePhotoSettings class]);
  OCMStub([mockSettings photoSettingsWithFormat:OCMOCK_ANY]).andReturn(settings);

  id mockOutput = OCMClassMock([AVCapturePhotoOutput class]);
  // Set availablePhotoCodecTypes to HEVC
  NSArray *codecTypes = @[ AVVideoCodecTypeHEVC ];
  OCMStub([mockOutput availablePhotoCodecTypes]).andReturn(codecTypes);

  OCMStub([mockOutput capturePhotoWithSettings:OCMOCK_ANY delegate:OCMOCK_ANY])
      .andDo(^(NSInvocation *invocation) {
        FLTSavePhotoDelegate *delegate = cam.inProgressSavePhotoDelegates[@(settings.uniqueID)];
        // Completion runs on IO queue.
        dispatch_queue_t ioQueue = dispatch_queue_create("io_queue", NULL);
        dispatch_async(ioQueue, ^{
          delegate.completionHandler(delegate.filePath, nil);
        });
      });
  cam.capturePhotoOutput = mockOutput;
  // `FLTCam::captureToFile` runs on capture session queue.
  dispatch_async(captureSessionQueue, ^{
    [cam captureToFile:^(id _Nullable result) {
      NSString *filePath = (NSString *)result;
      XCTAssertEqualObjects([filePath pathExtension], @"heif");
      [expectation fulfill];
    }];
  });
  [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testCaptureToFile_mustReportFileExtensionWithJpgWhenHEVCNotAvailableAndFileFormatIsHEIF {
  XCTestExpectation *expectation = [self
      expectationWithDescription:
          @"Test must set extension to jpg if availablePhotoCodecTypes does not contain HEVC."];
  dispatch_queue_t captureSessionQueue = dispatch_queue_create("capture_session_queue", NULL);
  dispatch_queue_set_specific(captureSessionQueue, FLTCaptureSessionQueueSpecific,
                              (void *)FLTCaptureSessionQueueSpecific, NULL);
  FLTCam *cam = FLTCreateCamWithCaptureSessionQueue(captureSessionQueue);
  [cam setImageFileFormat:FCPFileFormatHEIF];

  AVCapturePhotoSettings *settings = [AVCapturePhotoSettings photoSettings];
  id mockSettings = OCMClassMock([AVCapturePhotoSettings class]);
  OCMStub([mockSettings photoSettings]).andReturn(settings);

  id mockOutput = OCMClassMock([AVCapturePhotoOutput class]);

  OCMStub([mockOutput capturePhotoWithSettings:OCMOCK_ANY delegate:OCMOCK_ANY])
      .andDo(^(NSInvocation *invocation) {
        FLTSavePhotoDelegate *delegate = cam.inProgressSavePhotoDelegates[@(settings.uniqueID)];
        // Completion runs on IO queue.
        dispatch_queue_t ioQueue = dispatch_queue_create("io_queue", NULL);
        dispatch_async(ioQueue, ^{
          delegate.completionHandler(delegate.filePath, nil);
        });
      });
  cam.capturePhotoOutput = mockOutput;
  // `FLTCam::captureToFile` runs on capture session queue.
  dispatch_async(captureSessionQueue, ^{
    [cam captureToFile:^(id _Nullable result) {
      NSString *filePath = (NSString *)result;
      XCTAssertEqualObjects([filePath pathExtension], @"jpg");
      [expectation fulfill];
    }];
  });
  [self waitForExpectationsWithTimeout:1 handler:nil];
}
@end
