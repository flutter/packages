// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera_avfoundation;
#if __has_include(<camera_avfoundation/camera_avfoundation-umbrella.h>)
@import camera_avfoundation.Test;
#endif
@import XCTest;

#import "MockCameraDeviceDiscoverer.h"
#import "MockCaptureDevice.h"
#import "MockCaptureSession.h"
#import "MockFlutterBinaryMessenger.h"
#import "MockFlutterTextureRegistry.h"
#import "MockGlobalEventApi.h"

@interface CameraCaptureSessionQueueRaceConditionTests : XCTestCase
@end

@implementation CameraCaptureSessionQueueRaceConditionTests

- (CameraPlugin *)createCameraPlugin {
  MockCaptureDevice *captureDevice = [[MockCaptureDevice alloc] init];

  return [[CameraPlugin alloc] initWithRegistry:[[MockFlutterTextureRegistry alloc] init]
      messenger:[[MockFlutterBinaryMessenger alloc] init]
      globalAPI:[[MockGlobalEventApi alloc] init]
      deviceDiscoverer:[[MockCameraDeviceDiscoverer alloc] init]
      deviceFactory:^NSObject<FLTCaptureDevice> *(NSString *name) {
        return captureDevice;
      }
      captureSessionFactory:^NSObject<FLTCaptureSession> * {
        return [[MockCaptureSession alloc] init];
      }
      captureDeviceInputFactory:[[MockCaptureDeviceInputFactory alloc] init]];
}

- (void)testFixForCaptureSessionQueueNullPointerCrashDueToRaceCondition {
  CameraPlugin *cameraPlugin = [self createCameraPlugin];

  XCTestExpectation *disposeExpectation =
      [self expectationWithDescription:@"dispose's result block must be called"];
  XCTestExpectation *createExpectation =
      [self expectationWithDescription:@"create's result block must be called"];
  // Mimic a dispose call followed by a create call, which can be triggered by slightly dragging the
  // home bar, causing the app to be inactive, and immediately regain active.
  [cameraPlugin disposeCamera:0
                   completion:^(FlutterError *_Nullable error) {
                     [disposeExpectation fulfill];
                   }];
  [cameraPlugin createCameraOnSessionQueueWithName:@"acamera"
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
  // `captureSessionQueue` must not be nil after `create` call. Otherwise a nil
  // `captureSessionQueue` passed into `AVCaptureVideoDataOutput::setSampleBufferDelegate:queue:`
  // API will cause a crash.
  XCTAssertNotNil(cameraPlugin.captureSessionQueue,
                  @"captureSessionQueue must not be nil after create method. ");
}

@end
