// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera_avfoundation;
@import camera_avfoundation.Test;
@import XCTest;
@import AVFoundation;
#import <OCMock/OCMock.h>
#import "MockFLTThreadSafeFlutterResult.h"

@interface AvailableCamerasTest : XCTestCase
@end

@implementation AvailableCamerasTest

- (void)testAvailableCamerasShouldReturnAllCamerasOnMultiCameraIPhone {
  CameraPlugin *camera = [[CameraPlugin alloc] initWithRegistry:nil messenger:nil];
  XCTestExpectation *expectation =
      [[XCTestExpectation alloc] initWithDescription:@"Result finished"];

  AVCaptureDevice *wideAngleCamera = OCMClassMock([AVCaptureDevice class]);
  OCMStub([wideAngleCamera uniqueID]).andReturn(@"0");
  OCMStub([wideAngleCamera position]).andReturn(AVCaptureDevicePositionBack);

  AVCaptureDevice *frontFacingCamera = OCMClassMock([AVCaptureDevice class]);
  OCMStub([frontFacingCamera uniqueID]).andReturn(@"1");
  OCMStub([frontFacingCamera position]).andReturn(AVCaptureDevicePositionFront);

  AVCaptureDevice *telephotoCamera = OCMClassMock([AVCaptureDevice class]);
  OCMStub([telephotoCamera uniqueID]).andReturn(@"2");
  OCMStub([telephotoCamera position]).andReturn(AVCaptureDevicePositionBack);

  AVCaptureDevice *trueDepthCamera = OCMClassMock([AVCaptureDevice class]);
  OCMStub([trueDepthCamera uniqueID]).andReturn(@"3");
  OCMStub([trueDepthCamera position]).andReturn(AVCaptureDevicePositionFront);

  // iPhone 13 Cameras:
  AVCaptureDevice *ultraWideCamera = OCMClassMock([AVCaptureDevice class]);
  OCMStub([ultraWideCamera uniqueID]).andReturn(@"4");
  OCMStub([ultraWideCamera position]).andReturn(AVCaptureDevicePositionBack);

  AVCaptureDevice *dualWideCamera = OCMClassMock([AVCaptureDevice class]);
  OCMStub([dualWideCamera uniqueID]).andReturn(@"5");
  OCMStub([dualWideCamera position]).andReturn(AVCaptureDevicePositionBack);

  AVCaptureDevice *tripleCamera = OCMClassMock([AVCaptureDevice class]);
  OCMStub([tripleCamera uniqueID]).andReturn(@"6");
  OCMStub([tripleCamera position]).andReturn(AVCaptureDevicePositionBack);

  // iPhone 15.4 Cameras:
  AVCaptureDevice *liDARDepthCamera = OCMClassMock([AVCaptureDevice class]);
  OCMStub([liDARDepthCamera uniqueID]).andReturn(@"7");
  OCMStub([liDARDepthCamera position]).andReturn(AVCaptureDevicePositionBack);

  // iPhone 17 Cameras:
  AVCaptureDevice *externalCamera = OCMClassMock([AVCaptureDevice class]);
  OCMStub([externalCamera uniqueID]).andReturn(@"8");
  OCMStub([externalCamera position]).andReturn(AVCaptureDevicePositionBack);

  AVCaptureDevice *continuityCamera = OCMClassMock([AVCaptureDevice class]);
  OCMStub([continuityCamera uniqueID]).andReturn(@"9");
  OCMStub([continuityCamera position]).andReturn(AVCaptureDevicePositionBack);

  NSMutableArray *requiredTypes =
      [@[ AVCaptureDeviceTypeBuiltInWideAngleCamera,
          AVCaptureDeviceTypeBuiltInTelephotoCamera,
          AVCaptureDeviceTypeBuiltInDualCamera,
          AVCaptureDeviceTypeBuiltInTrueDepthCamera ]
          mutableCopy];
  if (@available(iOS 13.0, *)) {
    [requiredTypes addObjectsFromArray:
        @[ AVCaptureDeviceTypeBuiltInUltraWideCamera,
           AVCaptureDeviceTypeBuiltInDualWideCamera,
           AVCaptureDeviceTypeBuiltInTripleCamera ]];
  }
  if (@available(iOS 15.4, *)) {
    [requiredTypes addObject:AVCaptureDeviceTypeBuiltInLiDARDepthCamera];
  }
  if (@available(iOS 17.0, *)) {
    [requiredTypes addObjectsFromArray:
        @[ AVCaptureDeviceTypeExternal,
           AVCaptureDeviceTypeContinuityCamera ]];
  }

  id discoverySessionMock = OCMClassMock([AVCaptureDeviceDiscoverySession class]);
  OCMStub([discoverySessionMock discoverySessionWithDeviceTypes:requiredTypes
                                                      mediaType:AVMediaTypeVideo
                                                       position:AVCaptureDevicePositionUnspecified])
      .andReturn(discoverySessionMock);

  NSMutableArray *cameras =
      [@[ wideAngleCamera, frontFacingCamera, telephotoCamera, trueDepthCamera ] mutableCopy];
  if (@available(iOS 13.0, *)) {
    [cameras addObjectsFromArray: @[ ultraWideCamera, dualWideCamera, tripleCamera ]];
  }
  if (@available(iOS 15.4, *)) {
    [cameras addObject:liDARDepthCamera];
  }
  if (@available(iOS 17.0, *)) {
    [cameras addObjectsFromArray: @[ externalCamera, continuityCamera ]];
  }

  OCMStub([discoverySessionMock devices]).andReturn([NSArray arrayWithArray:cameras]);

  MockFLTThreadSafeFlutterResult *resultObject =
      [[MockFLTThreadSafeFlutterResult alloc] initWithExpectation:expectation];

  // Set up method call
  FlutterMethodCall *call = [FlutterMethodCall methodCallWithMethodName:@"availableCameras"
                                                              arguments:nil];

  [camera handleMethodCallAsync:call result:resultObject];

  // Verify the result
  NSDictionary *dictionaryResult = (NSDictionary *)resultObject.receivedResult;
  if (@available(iOS 17.0, *)) {
    XCTAssertTrue([dictionaryResult count] == 10);
  } else if (@available(iOS 15.4, *)) {
    XCTAssertTrue([dictionaryResult count] == 8);
  } else if (@available(iOS 13.0, *)) {
    XCTAssertTrue([dictionaryResult count] == 7);
  } else {
    XCTAssertTrue([dictionaryResult count] == 4);
  }
}
- (void)testAvailableCamerasShouldReturnOneCameraOnSingleCameraIPhone {
  CameraPlugin *camera = [[CameraPlugin alloc] initWithRegistry:nil messenger:nil];
  XCTestExpectation *expectation =
      [[XCTestExpectation alloc] initWithDescription:@"Result finished"];

  // iPhone 8 Cameras:
  AVCaptureDevice *wideAngleCamera = OCMClassMock([AVCaptureDevice class]);
  OCMStub([wideAngleCamera uniqueID]).andReturn(@"0");
  OCMStub([wideAngleCamera position]).andReturn(AVCaptureDevicePositionBack);

  AVCaptureDevice *frontFacingCamera = OCMClassMock([AVCaptureDevice class]);
  OCMStub([frontFacingCamera uniqueID]).andReturn(@"1");
  OCMStub([frontFacingCamera position]).andReturn(AVCaptureDevicePositionFront);

  NSMutableArray *requiredTypes =
      [@[ AVCaptureDeviceTypeBuiltInWideAngleCamera,
          AVCaptureDeviceTypeBuiltInTelephotoCamera,
          AVCaptureDeviceTypeBuiltInDualCamera,
          AVCaptureDeviceTypeBuiltInTrueDepthCamera ]
          mutableCopy];
  if (@available(iOS 13.0, *)) {
    [requiredTypes addObjectsFromArray:
        @[ AVCaptureDeviceTypeBuiltInUltraWideCamera,
           AVCaptureDeviceTypeBuiltInDualWideCamera,
           AVCaptureDeviceTypeBuiltInTripleCamera ]];
  }
  if (@available(iOS 15.4, *)) {
    [requiredTypes addObject:AVCaptureDeviceTypeBuiltInLiDARDepthCamera];
  }
  if (@available(iOS 17.0, *)) {
    [requiredTypes addObjectsFromArray:
        @[ AVCaptureDeviceTypeExternal,
           AVCaptureDeviceTypeContinuityCamera ]];
  }

  id discoverySessionMock = OCMClassMock([AVCaptureDeviceDiscoverySession class]);
  OCMStub([discoverySessionMock discoverySessionWithDeviceTypes:requiredTypes
                                                      mediaType:AVMediaTypeVideo
                                                       position:AVCaptureDevicePositionUnspecified])
      .andReturn(discoverySessionMock);

  NSMutableArray *cameras = [@[ wideAngleCamera, frontFacingCamera ] mutableCopy];
  OCMStub([discoverySessionMock devices]).andReturn([NSArray arrayWithArray:cameras]);

  MockFLTThreadSafeFlutterResult *resultObject =
      [[MockFLTThreadSafeFlutterResult alloc] initWithExpectation:expectation];

  // Set up method call
  FlutterMethodCall *call = [FlutterMethodCall methodCallWithMethodName:@"availableCameras"
                                                              arguments:nil];

  [camera handleMethodCallAsync:call result:resultObject];

  // Verify the result
  NSDictionary *dictionaryResult = (NSDictionary *)resultObject.receivedResult;
  XCTAssertTrue([dictionaryResult count] == 2);
}

@end
