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
#import "MockCaptureDevice.h"
#import "MockCapturePhotoOutput.h"

/// Includes test cases related to photo capture operations for FLTCam class.
@interface FLTCamPhotoCaptureTests : XCTestCase

@end

@implementation FLTCamPhotoCaptureTests

- (FLTCam *)createCamWithCaptureSessionQueue:(dispatch_queue_t)captureSessionQueue {
  FLTCamConfiguration *configuration = FLTCreateTestCameraConfiguration();
  configuration.captureSessionQueue = captureSessionQueue;
  return FLTCreateCamWithConfiguration(configuration);
}

- (void)testCaptureToFile_mustReportErrorToResultIfSavePhotoDelegateCompletionsWithError {
  XCTestExpectation *errorExpectation =
      [self expectationWithDescription:
                @"Must send error to result if save photo delegate completes with error."];

  dispatch_queue_t captureSessionQueue = dispatch_queue_create("capture_session_queue", NULL);
  dispatch_queue_set_specific(captureSessionQueue, FLTCaptureSessionQueueSpecific,
                              (void *)FLTCaptureSessionQueueSpecific, NULL);
  FLTCam *cam = FLTCreateCamWithCaptureSessionQueue(captureSessionQueue);

  NSError *error = [NSError errorWithDomain:@"test" code:0 userInfo:nil];

  MockCapturePhotoOutput *mockOutput = [[MockCapturePhotoOutput alloc] init];
  mockOutput.capturePhotoWithSettingsStub =
      ^(AVCapturePhotoSettings *settings, NSObject<AVCapturePhotoCaptureDelegate> *photoDelegate) {
        FLTSavePhotoDelegate *delegate = cam.inProgressSavePhotoDelegates[@(settings.uniqueID)];
        // Completion runs on IO queue.
        dispatch_queue_t ioQueue = dispatch_queue_create("io_queue", NULL);
        dispatch_async(ioQueue, ^{
          delegate.completionHandler(nil, error);
        });
      };
  cam.capturePhotoOutput = mockOutput;

  // `FLTCam::captureToFile` runs on capture session queue.
  dispatch_async(captureSessionQueue, ^{
    [cam captureToFileWithCompletion:^(NSString *result, FlutterError *error) {
      XCTAssertNil(result);
      XCTAssertNotNil(error);
      [errorExpectation fulfill];
    }];
  });

  [self waitForExpectationsWithTimeout:30 handler:nil];
}

- (void)testCaptureToFile_mustReportPathToResultIfSavePhotoDelegateCompletionsWithPath {
  XCTestExpectation *pathExpectation =
      [self expectationWithDescription:
                @"Must send file path to result if save photo delegate completes with file path."];

  dispatch_queue_t captureSessionQueue = dispatch_queue_create("capture_session_queue", NULL);
  dispatch_queue_set_specific(captureSessionQueue, FLTCaptureSessionQueueSpecific,
                              (void *)FLTCaptureSessionQueueSpecific, NULL);
  FLTCam *cam = [self createCamWithCaptureSessionQueue:captureSessionQueue];

  NSString *filePath = @"test";

  MockCapturePhotoOutput *mockOutput = [[MockCapturePhotoOutput alloc] init];
  mockOutput.capturePhotoWithSettingsStub =
      ^(AVCapturePhotoSettings *settings, NSObject<AVCapturePhotoCaptureDelegate> *photoDelegate) {
        FLTSavePhotoDelegate *delegate = cam.inProgressSavePhotoDelegates[@(settings.uniqueID)];
        // Completion runs on IO queue.
        dispatch_queue_t ioQueue = dispatch_queue_create("io_queue", NULL);
        dispatch_async(ioQueue, ^{
          delegate.completionHandler(filePath, nil);
        });
      };
  cam.capturePhotoOutput = mockOutput;

  // `FLTCam::captureToFile` runs on capture session queue.
  dispatch_async(captureSessionQueue, ^{
    [cam captureToFileWithCompletion:^(NSString *result, FlutterError *error) {
      XCTAssertEqual(result, filePath);
      [pathExpectation fulfill];
    }];
  });
  [self waitForExpectationsWithTimeout:30 handler:nil];
}

- (void)testCaptureToFile_mustReportFileExtensionWithHeifWhenHEVCIsAvailableAndFileFormatIsHEIF {
  XCTestExpectation *expectation =
      [self expectationWithDescription:
                @"Test must set extension to heif if availablePhotoCodecTypes contains HEVC."];
  dispatch_queue_t captureSessionQueue = dispatch_queue_create("capture_session_queue", NULL);
  dispatch_queue_set_specific(captureSessionQueue, FLTCaptureSessionQueueSpecific,
                              (void *)FLTCaptureSessionQueueSpecific, NULL);
  FLTCam *cam = [self createCamWithCaptureSessionQueue:captureSessionQueue];
  [cam setImageFileFormat:FCPPlatformImageFileFormatHeif];

  MockCapturePhotoOutput *mockOutput = [[MockCapturePhotoOutput alloc] init];
  mockOutput.availablePhotoCodecTypes = @[ AVVideoCodecTypeHEVC ];
  mockOutput.capturePhotoWithSettingsStub =
      ^(AVCapturePhotoSettings *settings, NSObject<AVCapturePhotoCaptureDelegate> *photoDelegate) {
        FLTSavePhotoDelegate *delegate = cam.inProgressSavePhotoDelegates[@(settings.uniqueID)];
        // Completion runs on IO queue.
        dispatch_queue_t ioQueue = dispatch_queue_create("io_queue", NULL);
        dispatch_async(ioQueue, ^{
          delegate.completionHandler(delegate.filePath, nil);
        });
      };
  cam.capturePhotoOutput = mockOutput;

  // `FLTCam::captureToFile` runs on capture session queue.
  dispatch_async(captureSessionQueue, ^{
    [cam captureToFileWithCompletion:^(NSString *filePath, FlutterError *error) {
      XCTAssertEqualObjects([filePath pathExtension], @"heif");
      [expectation fulfill];
    }];
  });
  [self waitForExpectationsWithTimeout:30 handler:nil];
}

- (void)testCaptureToFile_mustReportFileExtensionWithJpgWhenHEVCNotAvailableAndFileFormatIsHEIF {
  XCTestExpectation *expectation = [self
      expectationWithDescription:
          @"Test must set extension to jpg if availablePhotoCodecTypes does not contain HEVC."];
  dispatch_queue_t captureSessionQueue = dispatch_queue_create("capture_session_queue", NULL);
  dispatch_queue_set_specific(captureSessionQueue, FLTCaptureSessionQueueSpecific,
                              (void *)FLTCaptureSessionQueueSpecific, NULL);
  FLTCam *cam = [self createCamWithCaptureSessionQueue:captureSessionQueue];
  [cam setImageFileFormat:FCPPlatformImageFileFormatHeif];

  MockCapturePhotoOutput *mockOutput = [[MockCapturePhotoOutput alloc] init];
  mockOutput.capturePhotoWithSettingsStub =
      ^(AVCapturePhotoSettings *settings, NSObject<AVCapturePhotoCaptureDelegate> *photoDelegate) {
        FLTSavePhotoDelegate *delegate = cam.inProgressSavePhotoDelegates[@(settings.uniqueID)];
        // Completion runs on IO queue.
        dispatch_queue_t ioQueue = dispatch_queue_create("io_queue", NULL);
        dispatch_async(ioQueue, ^{
          delegate.completionHandler(delegate.filePath, nil);
        });
      };
  cam.capturePhotoOutput = mockOutput;

  // `FLTCam::captureToFile` runs on capture session queue.
  dispatch_async(captureSessionQueue, ^{
    [cam captureToFileWithCompletion:^(NSString *filePath, FlutterError *error) {
      XCTAssertEqualObjects([filePath pathExtension], @"jpg");
      [expectation fulfill];
    }];
  });
  [self waitForExpectationsWithTimeout:30 handler:nil];
}

- (void)testCaptureToFile_handlesTorchMode {
  XCTestExpectation *pathExpectation =
      [self expectationWithDescription:
                @"Must send file path to result if save photo delegate completes with file path."];
  XCTestExpectation *setTorchExpectation =
      [self expectationWithDescription:@"Should set torch mode to AVCaptureTorchModeOn."];

  MockCaptureDevice *captureDeviceMock = [[MockCaptureDevice alloc] init];
  captureDeviceMock.hasTorch = YES;
  captureDeviceMock.isTorchAvailable = YES;
  captureDeviceMock.torchMode = AVCaptureTorchModeAuto;
  captureDeviceMock.setTorchModeStub = ^(AVCaptureTorchMode mode) {
    if (mode == AVCaptureTorchModeOn) {
      [setTorchExpectation fulfill];
    }
  };

  dispatch_queue_t captureSessionQueue = dispatch_queue_create("capture_session_queue", NULL);
  dispatch_queue_set_specific(captureSessionQueue, FLTCaptureSessionQueueSpecific,
                              (void *)FLTCaptureSessionQueueSpecific, NULL);

  FLTCamConfiguration *configuration = FLTCreateTestCameraConfiguration();
  configuration.captureSessionQueue = captureSessionQueue;
  configuration.captureDeviceFactory = ^NSObject<FLTCaptureDevice> * { return captureDeviceMock; };
  FLTCam *cam = FLTCreateCamWithConfiguration(configuration);

  NSString *filePath = @"test";

  MockCapturePhotoOutput *mockOutput = [[MockCapturePhotoOutput alloc] init];
  mockOutput.capturePhotoWithSettingsStub =
      ^(AVCapturePhotoSettings *settings, NSObject<AVCapturePhotoCaptureDelegate> *photoDelegate) {
        FLTSavePhotoDelegate *delegate = cam.inProgressSavePhotoDelegates[@(settings.uniqueID)];
        // Completion runs on IO queue.
        dispatch_queue_t ioQueue = dispatch_queue_create("io_queue", NULL);
        dispatch_async(ioQueue, ^{
          delegate.completionHandler(filePath, nil);
        });
      };
  cam.capturePhotoOutput = mockOutput;

  // `FLTCam::captureToFile` runs on capture session queue.
  dispatch_async(captureSessionQueue, ^{
    [cam setFlashMode:FCPPlatformFlashModeTorch
        withCompletion:^(FlutterError *_){
        }];
    [cam captureToFileWithCompletion:^(NSString *result, FlutterError *error) {
      XCTAssertEqual(result, filePath);
      [pathExpectation fulfill];
    }];
  });
  [self waitForExpectationsWithTimeout:30 handler:nil];
}
@end
