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

@interface AvailableCamerasTest : XCTestCase

@end

@implementation AvailableCamerasTest

- (CameraPlugin *)createCameraPluginWithDeviceDiscoverer:
    (MockCameraDeviceDiscoverer *)deviceDiscoverer {
  return [[CameraPlugin alloc] initWithRegistry:[[MockFlutterTextureRegistry alloc] init]
      messenger:[[MockFlutterBinaryMessenger alloc] init]
      globalAPI:[[MockGlobalEventApi alloc] init]
      deviceDiscoverer:deviceDiscoverer
      deviceFactory:^NSObject<FLTCaptureDevice> *(NSString *name) {
        return [[MockCaptureDevice alloc] init];
      }
      captureSessionFactory:^NSObject<FLTCaptureSession> * {
        return [[MockCaptureSession alloc] init];
      }
      captureDeviceInputFactory:[[MockCaptureDeviceInputFactory alloc] init]];
}

- (void)testAvailableCamerasShouldReturnAllCamerasOnMultiCameraIPhone {
  MockCameraDeviceDiscoverer *mockDeviceDiscoverer = [[MockCameraDeviceDiscoverer alloc] init];
  CameraPlugin *cameraPlugin = [self createCameraPluginWithDeviceDiscoverer:mockDeviceDiscoverer];

  XCTestExpectation *expectation = [self expectationWithDescription:@"Result finished"];

  // iPhone 13 Cameras:
  MockCaptureDevice *wideAngleCamera = [[MockCaptureDevice alloc] init];
  wideAngleCamera.uniqueID = @"0";
  wideAngleCamera.position = AVCaptureDevicePositionBack;

  MockCaptureDevice *frontFacingCamera = [[MockCaptureDevice alloc] init];
  frontFacingCamera.uniqueID = @"1";
  frontFacingCamera.position = AVCaptureDevicePositionFront;

  MockCaptureDevice *ultraWideCamera = [[MockCaptureDevice alloc] init];
  ultraWideCamera.uniqueID = @"2";
  ultraWideCamera.position = AVCaptureDevicePositionBack;

  MockCaptureDevice *telephotoCamera = [[MockCaptureDevice alloc] init];
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

  mockDeviceDiscoverer.discoverySessionStub = ^NSArray<NSObject<FLTCaptureDevice> *> *_Nullable(
      NSArray<AVCaptureDeviceType> *_Nonnull deviceTypes, AVMediaType _Nonnull mediaType,
      AVCaptureDevicePosition position) {
    XCTAssertEqualObjects(deviceTypes, requiredTypes);
    XCTAssertEqual(mediaType, AVMediaTypeVideo);
    XCTAssertEqual(position, AVCaptureDevicePositionUnspecified);
    return cameras;
  };

  __block NSArray<FCPPlatformCameraDescription *> *resultValue;
  [cameraPlugin
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
  MockCameraDeviceDiscoverer *mockDeviceDiscoverer = [[MockCameraDeviceDiscoverer alloc] init];
  CameraPlugin *cameraPlugin = [self createCameraPluginWithDeviceDiscoverer:mockDeviceDiscoverer];

  XCTestExpectation *expectation = [self expectationWithDescription:@"Result finished"];

  // iPhone 8 Cameras:
  MockCaptureDevice *wideAngleCamera = [[MockCaptureDevice alloc] init];
  wideAngleCamera.uniqueID = @"0";
  wideAngleCamera.position = AVCaptureDevicePositionBack;

  MockCaptureDevice *frontFacingCamera = [[MockCaptureDevice alloc] init];
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

  mockDeviceDiscoverer.discoverySessionStub = ^NSArray<NSObject<FLTCaptureDevice> *> *_Nullable(
      NSArray<AVCaptureDeviceType> *_Nonnull deviceTypes, AVMediaType _Nonnull mediaType,
      AVCaptureDevicePosition position) {
    XCTAssertEqualObjects(deviceTypes, requiredTypes);
    XCTAssertEqual(mediaType, AVMediaTypeVideo);
    XCTAssertEqual(position, AVCaptureDevicePositionUnspecified);
    return cameras;
  };

  __block NSArray<FCPPlatformCameraDescription *> *resultValue;
  [cameraPlugin
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
