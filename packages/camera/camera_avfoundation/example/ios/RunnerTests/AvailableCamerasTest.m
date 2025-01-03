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
#import "MockCaptureDeviceController.h"

@interface AvailableCamerasTest : XCTestCase
@property(nonatomic, strong) MockCameraDeviceDiscoverer *mockDeviceDiscoverer;
@property(nonatomic, strong) CameraPlugin *cameraPlugin;
@end

@implementation AvailableCamerasTest

- (void)setUp {
  [super setUp];

  self.mockDeviceDiscoverer = [[MockCameraDeviceDiscoverer alloc] init];
  self.cameraPlugin = [[CameraPlugin alloc] initWithRegistry:nil
                                                   messenger:nil
                                                   globalAPI:nil
                                            deviceDiscoverer:_mockDeviceDiscoverer];
}

- (void)testAvailableCamerasShouldReturnAllCamerasOnMultiCameraIPhone {
  XCTestExpectation *expectation = [self expectationWithDescription:@"Result finished"];

  // iPhone 13 Cameras:
  MockCaptureDeviceController *wideAngleCamera = [[MockCaptureDeviceController alloc] init];
  wideAngleCamera.uniqueID = @"0";
  wideAngleCamera.position = AVCaptureDevicePositionBack;

  MockCaptureDeviceController *frontFacingCamera = [[MockCaptureDeviceController alloc] init];
  frontFacingCamera.uniqueID = @"1";
  frontFacingCamera.position = AVCaptureDevicePositionFront;

  MockCaptureDeviceController *ultraWideCamera = [[MockCaptureDeviceController alloc] init];
  ultraWideCamera.uniqueID = @"2";
  ultraWideCamera.position = AVCaptureDevicePositionBack;

  MockCaptureDeviceController *telephotoCamera = [[MockCaptureDeviceController alloc] init];
  telephotoCamera.uniqueID = @"3";
  telephotoCamera.position = AVCaptureDevicePositionBack;

  NSMutableArray *requiredTypes =
      [@[ AVCaptureDeviceTypeBuiltInWideAngleCamera, AVCaptureDeviceTypeBuiltInTelephotoCamera ]
          mutableCopy];
  if (@available(iOS 13.0, *)) {
    [requiredTypes addObject:AVCaptureDeviceTypeBuiltInUltraWideCamera];
  }

  NSMutableArray *cameras = [NSMutableArray array];
  [cameras addObjectsFromArray:@[ wideAngleCamera, frontFacingCamera, telephotoCamera ]];
  if (@available(iOS 13.0, *)) {
    [cameras addObject:ultraWideCamera];
  }

  _mockDeviceDiscoverer.discoverySessionStub = ^NSArray<id<FLTCaptureDeviceControlling>> *_Nullable(
      NSArray<AVCaptureDeviceType> *_Nonnull deviceTypes, AVMediaType _Nonnull mediaType,
      AVCaptureDevicePosition position) {
    XCTAssertEqualObjects(deviceTypes, requiredTypes);
    XCTAssertEqual(mediaType, AVMediaTypeVideo);
    XCTAssertEqual(position, AVCaptureDevicePositionUnspecified);
    return cameras;
  };

  __block NSArray<FCPPlatformCameraDescription *> *resultValue;
  [_cameraPlugin
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
  XCTestExpectation *expectation = [self expectationWithDescription:@"Result finished"];

  // iPhone 8 Cameras:
  MockCaptureDeviceController *wideAngleCamera = [[MockCaptureDeviceController alloc] init];
  wideAngleCamera.uniqueID = @"0";
  wideAngleCamera.position = AVCaptureDevicePositionBack;

  MockCaptureDeviceController *frontFacingCamera = [[MockCaptureDeviceController alloc] init];
  frontFacingCamera.uniqueID = @"1";
  frontFacingCamera.position = AVCaptureDevicePositionFront;

  NSMutableArray *requiredTypes =
      [@[ AVCaptureDeviceTypeBuiltInWideAngleCamera, AVCaptureDeviceTypeBuiltInTelephotoCamera ]
          mutableCopy];
  if (@available(iOS 13.0, *)) {
    [requiredTypes addObject:AVCaptureDeviceTypeBuiltInUltraWideCamera];
  }

  NSMutableArray *cameras = [NSMutableArray array];
  [cameras addObjectsFromArray:@[ wideAngleCamera, frontFacingCamera ]];

  _mockDeviceDiscoverer.discoverySessionStub = ^NSArray<id<FLTCaptureDeviceControlling>> *_Nullable(
      NSArray<AVCaptureDeviceType> *_Nonnull deviceTypes, AVMediaType _Nonnull mediaType,
      AVCaptureDevicePosition position) {
    XCTAssertEqualObjects(deviceTypes, requiredTypes);
    XCTAssertEqual(mediaType, AVMediaTypeVideo);
    XCTAssertEqual(position, AVCaptureDevicePositionUnspecified);
    return cameras;
  };

  __block NSArray<FCPPlatformCameraDescription *> *resultValue;
  [_cameraPlugin
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
