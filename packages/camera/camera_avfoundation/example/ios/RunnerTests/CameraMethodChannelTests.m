// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera_avfoundation;
#if __has_include(<camera_avfoundation/camera_avfoundation-umbrella.h>)
@import camera_avfoundation.Test;
#endif
@import XCTest;
@import AVFoundation;

#import "MockCameraDeviceDiscoverer.h"
#import "MockCaptureDevice.h"
#import "MockCaptureSession.h"
#import "MockFlutterBinaryMessenger.h"
#import "MockFlutterTextureRegistry.h"
#import "MockGlobalEventApi.h"

@interface CameraMethodChannelTests : XCTestCase
@end

@implementation CameraMethodChannelTests

- (CameraPlugin *)createCameraPluginWithSession:(MockCaptureSession *)mockSession {
  return [[CameraPlugin alloc] initWithRegistry:[[MockFlutterTextureRegistry alloc] init]
      messenger:[[MockFlutterBinaryMessenger alloc] init]
      globalAPI:[[MockGlobalEventApi alloc] init]
      deviceDiscoverer:[[MockCameraDeviceDiscoverer alloc] init]
      deviceFactory:^NSObject<FLTCaptureDevice> *(NSString *name) {
        return [[MockCaptureDevice alloc] init];
      }
      captureSessionFactory:^NSObject<FLTCaptureSession> *_Nonnull {
        return mockSession;
      }
      captureDeviceInputFactory:[[MockCaptureDeviceInputFactory alloc] init]];
}

- (void)testCreate_ShouldCallResultOnMainThread {
  MockCaptureSession *avCaptureSessionMock = [[MockCaptureSession alloc] init];
  avCaptureSessionMock.canSetSessionPreset = YES;

  CameraPlugin *camera = [self createCameraPluginWithSession:avCaptureSessionMock];

  XCTestExpectation *expectation = [self expectationWithDescription:@"Result finished"];

  // Set up method call
  __block NSNumber *resultValue;
  [camera createCameraOnSessionQueueWithName:@"acamera"
                                    settings:[FCPPlatformMediaSettings
                                                 makeWithResolutionPreset:
                                                     FCPPlatformResolutionPresetMedium
                                                          framesPerSecond:nil
                                                             videoBitrate:nil
                                                             audioBitrate:nil
                                                              enableAudio:YES]
                                  completion:^(NSNumber *_Nullable result,
                                               FlutterError *_Nullable error) {
                                    resultValue = result;
                                    [expectation fulfill];
                                  }];
  [self waitForExpectationsWithTimeout:30 handler:nil];

  // Verify the result
  XCTAssertNotNil(resultValue);
}

- (void)testDisposeShouldDeallocCamera {
  MockCaptureSession *avCaptureSessionMock = [[MockCaptureSession alloc] init];
  avCaptureSessionMock.canSetSessionPreset = YES;

  CameraPlugin *camera = [self createCameraPluginWithSession:avCaptureSessionMock];

  XCTestExpectation *createExpectation =
      [self expectationWithDescription:@"create's result block must be called"];
  [camera createCameraOnSessionQueueWithName:@"acamera"
                                    settings:[FCPPlatformMediaSettings
                                                 makeWithResolutionPreset:
                                                     FCPPlatformResolutionPresetMedium
                                                          framesPerSecond:nil
                                                             videoBitrate:nil
                                                             audioBitrate:nil
                                                              enableAudio:YES]
                                  completion:^(NSNumber *_Nullable result,
                                               FlutterError *_Nullable error) {
                                    [createExpectation fulfill];
                                  }];
  [self waitForExpectationsWithTimeout:30 handler:nil];
  XCTAssertNotNil(camera.camera);

  XCTestExpectation *disposeExpectation =
      [self expectationWithDescription:@"dispose's result block must be called"];
  [camera disposeCamera:0
             completion:^(FlutterError *_Nullable error) {
               [disposeExpectation fulfill];
             }];
  [self waitForExpectationsWithTimeout:30 handler:nil];
  XCTAssertNil(camera.camera, @"camera should be deallocated after dispose");
}

@end
