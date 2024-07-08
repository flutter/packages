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

@interface AvailableCamerasTest : XCTestCase
@end

@implementation AvailableCamerasTest

- (void)testAvailableCamerasShouldReturnAllCamerasOnMultiCameraIPhone {
  CameraPlugin *camera = [[CameraPlugin alloc] initWithRegistry:nil messenger:nil];
  XCTestExpectation *expectation = [self expectationWithDescription:@"Result finished"];

  // iPhone 13 Cameras:
  AVCaptureDevice *wideAngleCamera = OCMClassMock([AVCaptureDevice class]);
  OCMStub([wideAngleCamera uniqueID]).andReturn(@"0");
  OCMStub([wideAngleCamera position]).andReturn(AVCaptureDevicePositionBack);

  AVCaptureDevice *frontFacingCamera = OCMClassMock([AVCaptureDevice class]);
  OCMStub([frontFacingCamera uniqueID]).andReturn(@"1");
  OCMStub([frontFacingCamera position]).andReturn(AVCaptureDevicePositionFront);

  AVCaptureDevice *ultraWideCamera = OCMClassMock([AVCaptureDevice class]);
  OCMStub([ultraWideCamera uniqueID]).andReturn(@"2");
  OCMStub([ultraWideCamera position]).andReturn(AVCaptureDevicePositionBack);

  AVCaptureDevice *telephotoCamera = OCMClassMock([AVCaptureDevice class]);
  OCMStub([telephotoCamera uniqueID]).andReturn(@"3");
  OCMStub([telephotoCamera position]).andReturn(AVCaptureDevicePositionBack);

  NSMutableArray *requiredTypes =
      [@[ AVCaptureDeviceTypeBuiltInWideAngleCamera, AVCaptureDeviceTypeBuiltInTelephotoCamera ]
          mutableCopy];
  if (@available(iOS 13.0, *)) {
    [requiredTypes addObject:AVCaptureDeviceTypeBuiltInUltraWideCamera];
  }

  id discoverySessionMock = OCMClassMock([AVCaptureDeviceDiscoverySession class]);
  OCMStub([discoverySessionMock discoverySessionWithDeviceTypes:requiredTypes
                                                      mediaType:AVMediaTypeVideo
                                                       position:AVCaptureDevicePositionUnspecified])
      .andReturn(discoverySessionMock);

  NSMutableArray *cameras = [NSMutableArray array];
  [cameras addObjectsFromArray:@[ wideAngleCamera, frontFacingCamera, telephotoCamera ]];
  if (@available(iOS 13.0, *)) {
    [cameras addObject:ultraWideCamera];
  }
  OCMStub([discoverySessionMock devices]).andReturn([NSArray arrayWithArray:cameras]);

  __block NSArray<FCPPlatformCameraDescription *> *resultValue;
  [camera
      availableCamerasWithCompletion:^(NSArray<FCPPlatformCameraDescription *> *_Nullable result,
                                       FlutterError *_Nullable error) {
        XCTAssertNil(error);
        resultValue = result;
        [expectation fulfill];
      }];
  [self waitForExpectationsWithTimeout:30 handler:nil];

  // Verify the result
  if (@available(iOS 13.0, *)) {
    XCTAssertEqual(resultValue.count, 4);
  } else {
    XCTAssertEqual(resultValue.count, 3);
  }
}
- (void)testAvailableCamerasShouldReturnOneCameraOnSingleCameraIPhone {
  CameraPlugin *camera = [[CameraPlugin alloc] initWithRegistry:nil messenger:nil];
  XCTestExpectation *expectation = [self expectationWithDescription:@"Result finished"];

  // iPhone 8 Cameras:
  AVCaptureDevice *wideAngleCamera = OCMClassMock([AVCaptureDevice class]);
  OCMStub([wideAngleCamera uniqueID]).andReturn(@"0");
  OCMStub([wideAngleCamera position]).andReturn(AVCaptureDevicePositionBack);

  AVCaptureDevice *frontFacingCamera = OCMClassMock([AVCaptureDevice class]);
  OCMStub([frontFacingCamera uniqueID]).andReturn(@"1");
  OCMStub([frontFacingCamera position]).andReturn(AVCaptureDevicePositionFront);

  NSMutableArray *requiredTypes =
      [@[ AVCaptureDeviceTypeBuiltInWideAngleCamera, AVCaptureDeviceTypeBuiltInTelephotoCamera ]
          mutableCopy];
  if (@available(iOS 13.0, *)) {
    [requiredTypes addObject:AVCaptureDeviceTypeBuiltInUltraWideCamera];
  }

  id discoverySessionMock = OCMClassMock([AVCaptureDeviceDiscoverySession class]);
  OCMStub([discoverySessionMock discoverySessionWithDeviceTypes:requiredTypes
                                                      mediaType:AVMediaTypeVideo
                                                       position:AVCaptureDevicePositionUnspecified])
      .andReturn(discoverySessionMock);

  NSMutableArray *cameras = [NSMutableArray array];
  [cameras addObjectsFromArray:@[ wideAngleCamera, frontFacingCamera ]];
  OCMStub([discoverySessionMock devices]).andReturn([NSArray arrayWithArray:cameras]);

  __block NSArray<FCPPlatformCameraDescription *> *resultValue;
  [camera
      availableCamerasWithCompletion:^(NSArray<FCPPlatformCameraDescription *> *_Nullable result,
                                       FlutterError *_Nullable error) {
        XCTAssertNil(error);
        resultValue = result;
        [expectation fulfill];
      }];
  [self waitForExpectationsWithTimeout:30 handler:nil];

  // Verify the result
  XCTAssertEqual(resultValue.count, 2);
  ;
}

@end
