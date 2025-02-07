// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera_avfoundation;
#if __has_include(<camera_avfoundation/camera_avfoundation-umbrella.h>)
@import camera_avfoundation.Test;
#endif
@import XCTest;
@import AVFoundation;
#import <OCMock/OCMock.h>

#import "MockFlutterBinaryMessenger.h"
#import "MockFlutterTextureRegistry.h"

@interface CameraMethodChannelTests : XCTestCase
@end

@implementation CameraMethodChannelTests

- (CameraPlugin *)createCameraPlugin {
  return [[CameraPlugin alloc] initWithRegistry:[[MockFlutterTextureRegistry alloc] init]
                                      messenger:[[MockFlutterBinaryMessenger alloc] init]];
}

- (void)testCreate_ShouldCallResultOnMainThread {
  CameraPlugin *camera = [self createCameraPlugin];

  XCTestExpectation *expectation = [self expectationWithDescription:@"Result finished"];

  // Set up mocks for initWithCameraName method
  id avCaptureDeviceInputMock = OCMClassMock([AVCaptureDeviceInput class]);
  OCMStub([avCaptureDeviceInputMock deviceInputWithDevice:[OCMArg any] error:[OCMArg anyObjectRef]])
      .andReturn([AVCaptureInput alloc]);

  id avCaptureSessionMock = OCMClassMock([AVCaptureSession class]);
  OCMStub([avCaptureSessionMock alloc]).andReturn(avCaptureSessionMock);
  OCMStub([avCaptureSessionMock canSetSessionPreset:[OCMArg any]]).andReturn(YES);

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
  CameraPlugin *camera = [self createCameraPlugin];

  id avCaptureDeviceInputMock = OCMClassMock([AVCaptureDeviceInput class]);
  OCMStub([avCaptureDeviceInputMock deviceInputWithDevice:[OCMArg any] error:[OCMArg anyObjectRef]])
      .andReturn([AVCaptureInput alloc]);

  id avCaptureSessionMock = OCMClassMock([AVCaptureSession class]);
  OCMStub([avCaptureSessionMock alloc]).andReturn(avCaptureSessionMock);
  OCMStub([avCaptureSessionMock canSetSessionPreset:[OCMArg any]]).andReturn(YES);

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
