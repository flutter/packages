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
  OCMStub([wideAngleCamera deviceType]).andReturn(AVCaptureDeviceTypeBuiltInWideAngleCamera);
  OCMStub([wideAngleCamera position]).andReturn(AVCaptureDevicePositionBack);
  
  AVCaptureDevice *frontFacingCamera = OCMClassMock([AVCaptureDevice class]);
  OCMStub([frontFacingCamera uniqueID]).andReturn(@"1");
  OCMStub([frontFacingCamera deviceType]).andReturn(AVCaptureDeviceTypeBuiltInWideAngleCamera);
  OCMStub([frontFacingCamera position]).andReturn(AVCaptureDevicePositionFront);
  
  AVCaptureDevice *telephotoCamera = OCMClassMock([AVCaptureDevice class]);
  OCMStub([telephotoCamera uniqueID]).andReturn(@"2");
  OCMStub([telephotoCamera deviceType]).andReturn(AVCaptureDeviceTypeBuiltInTelephotoCamera);
  OCMStub([telephotoCamera position]).andReturn(AVCaptureDevicePositionBack);
  
  AVCaptureDevice *trueDepthCamera = OCMClassMock([AVCaptureDevice class]);
  OCMStub([trueDepthCamera uniqueID]).andReturn(@"3");
  OCMStub([trueDepthCamera deviceType]).andReturn(AVCaptureDeviceTypeBuiltInTrueDepthCamera);
  OCMStub([trueDepthCamera position]).andReturn(AVCaptureDevicePositionFront);
  
  AVCaptureDevice *dualCamera = OCMClassMock([AVCaptureDevice class]);
  OCMStub([dualCamera uniqueID]).andReturn(@"4");
  OCMStub([dualCamera deviceType]).andReturn(AVCaptureDeviceTypeBuiltInDualCamera);
  OCMStub([dualCamera position]).andReturn(AVCaptureDevicePositionBack);
  
  // iPhone 13 Cameras:
  AVCaptureDevice *ultraWideCamera = OCMClassMock([AVCaptureDevice class]);
  OCMStub([ultraWideCamera uniqueID]).andReturn(@"5");
  if (@available(iOS 13.0, *)) {
    OCMStub([ultraWideCamera deviceType]).andReturn(AVCaptureDeviceTypeBuiltInUltraWideCamera);
  }
  OCMStub([ultraWideCamera position]).andReturn(AVCaptureDevicePositionBack);
  
  AVCaptureDevice *dualWideCamera = OCMClassMock([AVCaptureDevice class]);
  OCMStub([dualWideCamera uniqueID]).andReturn(@"6");
  if (@available(iOS 13.0, *)) {
    OCMStub([dualWideCamera deviceType]).andReturn(AVCaptureDeviceTypeBuiltInDualWideCamera);
  }
  OCMStub([dualWideCamera position]).andReturn(AVCaptureDevicePositionBack);
  
  AVCaptureDevice *tripleCamera = OCMClassMock([AVCaptureDevice class]);
  OCMStub([tripleCamera uniqueID]).andReturn(@"7");
  if (@available(iOS 13.0, *)) {
    OCMStub([tripleCamera deviceType]).andReturn(AVCaptureDeviceTypeBuiltInTripleCamera);
  }
  OCMStub([tripleCamera position]).andReturn(AVCaptureDevicePositionBack);
    
  // iPhone 15.4 Cameras:
  AVCaptureDevice *liDARDepthCamera = OCMClassMock([AVCaptureDevice class]);
  OCMStub([liDARDepthCamera uniqueID]).andReturn(@"8");
  if (@available(iOS 15.4, *)) {
    OCMStub([liDARDepthCamera deviceType]).andReturn(AVCaptureDeviceTypeBuiltInLiDARDepthCamera);
  }
  OCMStub([liDARDepthCamera position]).andReturn(AVCaptureDevicePositionBack);

  // iPhone 17 Cameras:
  AVCaptureDevice *externalCamera = OCMClassMock([AVCaptureDevice class]);
  OCMStub([externalCamera uniqueID]).andReturn(@"9");
  if (@available(iOS 17.0, *)) {
    OCMStub([externalCamera deviceType]).andReturn(AVCaptureDeviceTypeExternal);
  }
  OCMStub([externalCamera position]).andReturn(AVCaptureDevicePositionBack);

  AVCaptureDevice *continuityCamera = OCMClassMock([AVCaptureDevice class]);
  OCMStub([continuityCamera uniqueID]).andReturn(@"10");
  if (@available(iOS 17.0, *)) {
    OCMStub([continuityCamera deviceType]).andReturn(AVCaptureDeviceTypeContinuityCamera);
  }
  OCMStub([continuityCamera position]).andReturn(AVCaptureDevicePositionBack);

  NSMutableArray *requiredTypes = [NSMutableArray new];
  if (@available(iOS 17.0, *)) {
      [requiredTypes addObjectsFromArray:
          @[ AVCaptureDeviceTypeBuiltInWideAngleCamera,
             AVCaptureDeviceTypeBuiltInTelephotoCamera,
             AVCaptureDeviceTypeBuiltInUltraWideCamera,
             AVCaptureDeviceTypeExternal, 
             AVCaptureDeviceTypeBuiltInDualCamera,
             AVCaptureDeviceTypeBuiltInTrueDepthCamera,
             AVCaptureDeviceTypeBuiltInDualWideCamera,
             AVCaptureDeviceTypeBuiltInTripleCamera,
             AVCaptureDeviceTypeBuiltInLiDARDepthCamera,
             AVCaptureDeviceTypeContinuityCamera ]];
  } else if (@available(iOS 15.4, *)) {
      [requiredTypes addObjectsFromArray:
          @[ AVCaptureDeviceTypeBuiltInWideAngleCamera,
             AVCaptureDeviceTypeBuiltInTelephotoCamera,
             AVCaptureDeviceTypeBuiltInUltraWideCamera,
             AVCaptureDeviceTypeBuiltInDualCamera,
             AVCaptureDeviceTypeBuiltInTrueDepthCamera,
             AVCaptureDeviceTypeBuiltInDualWideCamera,
             AVCaptureDeviceTypeBuiltInTripleCamera,
             AVCaptureDeviceTypeBuiltInLiDARDepthCamera ]];
  } else if (@available(iOS 13.0, *)) {
      [requiredTypes addObjectsFromArray:
          @[ AVCaptureDeviceTypeBuiltInWideAngleCamera,
             AVCaptureDeviceTypeBuiltInTelephotoCamera,
             AVCaptureDeviceTypeBuiltInUltraWideCamera,
             AVCaptureDeviceTypeBuiltInDualCamera,
             AVCaptureDeviceTypeBuiltInTrueDepthCamera,
             AVCaptureDeviceTypeBuiltInDualWideCamera,
             AVCaptureDeviceTypeBuiltInTripleCamera ]];
  } else {
      [requiredTypes addObjectsFromArray:
          @[ AVCaptureDeviceTypeBuiltInWideAngleCamera,
             AVCaptureDeviceTypeBuiltInTelephotoCamera,
             AVCaptureDeviceTypeBuiltInDualCamera,
             AVCaptureDeviceTypeBuiltInTrueDepthCamera ]];
  }

  id discoverySessionMock = OCMClassMock([AVCaptureDeviceDiscoverySession class]);
  OCMStub([discoverySessionMock discoverySessionWithDeviceTypes:requiredTypes
                                                      mediaType:AVMediaTypeVideo
                                                       position:AVCaptureDevicePositionUnspecified])
      .andReturn(discoverySessionMock);

  NSMutableArray *cameras =
      [@[ wideAngleCamera, frontFacingCamera, telephotoCamera, dualCamera, trueDepthCamera ] mutableCopy];
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
                                                              arguments:@{@"physicalCameras" : @TRUE, @"logicalCameras" : @TRUE}];

  [camera handleMethodCallAsync:call result:resultObject];

  // Verify the result
  NSDictionary *dictionaryResult = (NSDictionary *)resultObject.receivedResult;
  if (@available(iOS 17.0, *)) {
    XCTAssertTrue([dictionaryResult count] == 11);
  } else if (@available(iOS 15.4, *)) {
    XCTAssertTrue([dictionaryResult count] == 9);
  } else if (@available(iOS 13.0, *)) {
    XCTAssertTrue([dictionaryResult count] == 8);
  } else {
    XCTAssertTrue([dictionaryResult count] == 5);
  }
}
- (void)testAvailableCamerasShouldReturnOneCameraOnSingleCameraIPhone {
  CameraPlugin *camera = [[CameraPlugin alloc] initWithRegistry:nil messenger:nil];
  XCTestExpectation *expectation =
      [[XCTestExpectation alloc] initWithDescription:@"Result finished"];

  // iPhone 8 Cameras:
  AVCaptureDevice *wideAngleCamera = OCMClassMock([AVCaptureDevice class]);
  OCMStub([wideAngleCamera uniqueID]).andReturn(@"0");
  OCMStub([wideAngleCamera deviceType]).andReturn(AVCaptureDeviceTypeBuiltInWideAngleCamera);
  OCMStub([wideAngleCamera position]).andReturn(AVCaptureDevicePositionBack);

  AVCaptureDevice *frontFacingCamera = OCMClassMock([AVCaptureDevice class]);
  OCMStub([frontFacingCamera uniqueID]).andReturn(@"1");
  OCMStub([frontFacingCamera deviceType]).andReturn(AVCaptureDeviceTypeBuiltInWideAngleCamera);
  OCMStub([frontFacingCamera position]).andReturn(AVCaptureDevicePositionFront);

  NSMutableArray *requiredTypes = [NSMutableArray new];
  if (@available(iOS 17.0, *)) {
      [requiredTypes addObjectsFromArray:
          @[ AVCaptureDeviceTypeBuiltInWideAngleCamera,
             AVCaptureDeviceTypeBuiltInTelephotoCamera,
             AVCaptureDeviceTypeBuiltInUltraWideCamera,
             AVCaptureDeviceTypeExternal ]];
  } else if (@available(iOS 13.0, *)) {
      [requiredTypes addObjectsFromArray:
          @[ AVCaptureDeviceTypeBuiltInWideAngleCamera,
             AVCaptureDeviceTypeBuiltInTelephotoCamera,
             AVCaptureDeviceTypeBuiltInUltraWideCamera ]];
  } else {
      [requiredTypes addObjectsFromArray:
          @[ AVCaptureDeviceTypeBuiltInWideAngleCamera,
             AVCaptureDeviceTypeBuiltInTelephotoCamera ]];
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
                                                              arguments:@{@"physicalCameras" : @TRUE, @"logicalCameras" : @FALSE}];

  [camera handleMethodCallAsync:call result:resultObject];

  // Verify the result
  NSDictionary *dictionaryResult = (NSDictionary *)resultObject.receivedResult;
  XCTAssertTrue([dictionaryResult count] == 2);
}
- (void)testAvailableCamerasShouldReturnOnlyPhysicalDevices {
  CameraPlugin *camera = [[CameraPlugin alloc] initWithRegistry:nil messenger:nil];
  XCTestExpectation *expectation =
      [[XCTestExpectation alloc] initWithDescription:@"Result finished"];

  AVCaptureDevice *wideAngleCamera = OCMClassMock([AVCaptureDevice class]);
  OCMStub([wideAngleCamera uniqueID]).andReturn(@"0");
  OCMStub([wideAngleCamera position]).andReturn(AVCaptureDevicePositionBack);

  AVCaptureDevice *frontFacingCamera = OCMClassMock([AVCaptureDevice class]);
  OCMStub([frontFacingCamera uniqueID]).andReturn(@"1");
  OCMStub([frontFacingCamera position]).andReturn(AVCaptureDevicePositionFront);
    
  AVCaptureDevice *ultraWideCamera = OCMClassMock([AVCaptureDevice class]);
  OCMStub([ultraWideCamera uniqueID]).andReturn(@"2");
  if (@available(iOS 13.0, *)) {
    OCMStub([ultraWideCamera deviceType]).andReturn(AVCaptureDeviceTypeBuiltInUltraWideCamera);
  }
  OCMStub([ultraWideCamera position]).andReturn(AVCaptureDevicePositionBack);
    
  AVCaptureDevice *externalCamera = OCMClassMock([AVCaptureDevice class]);
  OCMStub([externalCamera uniqueID]).andReturn(@"3");
  if (@available(iOS 17.0, *)) {
    OCMStub([externalCamera deviceType]).andReturn(AVCaptureDeviceTypeExternal);
  }
  OCMStub([externalCamera position]).andReturn(AVCaptureDevicePositionBack);

  NSMutableArray *requiredTypes = [NSMutableArray new];
  if (@available(iOS 17.0, *)) {
      [requiredTypes addObjectsFromArray:
          @[ AVCaptureDeviceTypeBuiltInWideAngleCamera,
             AVCaptureDeviceTypeBuiltInTelephotoCamera,
             AVCaptureDeviceTypeBuiltInUltraWideCamera,
             AVCaptureDeviceTypeExternal ]];
  } else if (@available(iOS 13.0, *)) {
      [requiredTypes addObjectsFromArray:
          @[ AVCaptureDeviceTypeBuiltInWideAngleCamera,
             AVCaptureDeviceTypeBuiltInTelephotoCamera,
             AVCaptureDeviceTypeBuiltInUltraWideCamera ]];
  } else {
      [requiredTypes addObjectsFromArray:
          @[ AVCaptureDeviceTypeBuiltInWideAngleCamera,
             AVCaptureDeviceTypeBuiltInTelephotoCamera ]];
  }

  id discoverySessionMock = OCMClassMock([AVCaptureDeviceDiscoverySession class]);
  OCMStub([discoverySessionMock discoverySessionWithDeviceTypes:requiredTypes
                                                      mediaType:AVMediaTypeVideo
                                                       position:AVCaptureDevicePositionUnspecified])
      .andReturn(discoverySessionMock);

  NSMutableArray *cameras =
      [@[ wideAngleCamera, frontFacingCamera ] mutableCopy];
  if (@available(iOS 13.0, *)) {
    [cameras addObjectsFromArray: @[ ultraWideCamera ]];
  }
  if (@available(iOS 17.0, *)) {
    [cameras addObjectsFromArray: @[ externalCamera ]];
  }
  OCMStub([discoverySessionMock devices]).andReturn([NSArray arrayWithArray:cameras]);

  MockFLTThreadSafeFlutterResult *resultObject =
      [[MockFLTThreadSafeFlutterResult alloc] initWithExpectation:expectation];

  // Set up method call
  FlutterMethodCall *call = [FlutterMethodCall methodCallWithMethodName:@"availableCameras"
                                                              arguments:@{@"physicalCameras" : @TRUE, @"logicalCameras" : @FALSE}];

  [camera handleMethodCallAsync:call result:resultObject];

  // Verify the result
  NSDictionary *dictionaryResult = (NSDictionary *)resultObject.receivedResult;
  if (@available(iOS 17.0, *)) {
    XCTAssertTrue([dictionaryResult count] == 4);
  } else if (@available(iOS 13.0, *)) {
    XCTAssertTrue([dictionaryResult count] == 3);
  } else {
    XCTAssertTrue([dictionaryResult count] == 2);
  }
}
- (void)testAvailableCamerasShouldReturnOnlyLogicalDevices {
  CameraPlugin *camera = [[CameraPlugin alloc] initWithRegistry:nil messenger:nil];
  XCTestExpectation *expectation =
      [[XCTestExpectation alloc] initWithDescription:@"Result finished"];
  
  AVCaptureDevice *trueDepthCamera = OCMClassMock([AVCaptureDevice class]);
  OCMStub([trueDepthCamera uniqueID]).andReturn(@"0");
  OCMStub([trueDepthCamera deviceType]).andReturn(AVCaptureDeviceTypeBuiltInTrueDepthCamera);
  OCMStub([trueDepthCamera position]).andReturn(AVCaptureDevicePositionFront);
  
  AVCaptureDevice *dualCamera = OCMClassMock([AVCaptureDevice class]);
  OCMStub([dualCamera uniqueID]).andReturn(@"1");
  OCMStub([dualCamera deviceType]).andReturn(AVCaptureDeviceTypeBuiltInDualCamera);
  OCMStub([dualCamera position]).andReturn(AVCaptureDevicePositionBack);
  
  // iPhone 13 Cameras:
  AVCaptureDevice *dualWideCamera = OCMClassMock([AVCaptureDevice class]);
  OCMStub([dualWideCamera uniqueID]).andReturn(@"2");
  if (@available(iOS 13.0, *)) {
    OCMStub([dualWideCamera deviceType]).andReturn(AVCaptureDeviceTypeBuiltInDualWideCamera);
  }
  OCMStub([dualWideCamera position]).andReturn(AVCaptureDevicePositionBack);
  
  AVCaptureDevice *tripleCamera = OCMClassMock([AVCaptureDevice class]);
  OCMStub([tripleCamera uniqueID]).andReturn(@"3");
  if (@available(iOS 13.0, *)) {
    OCMStub([tripleCamera deviceType]).andReturn(AVCaptureDeviceTypeBuiltInTripleCamera);
  }
  OCMStub([tripleCamera position]).andReturn(AVCaptureDevicePositionBack);
    
  // iPhone 15.4 Cameras:
  AVCaptureDevice *liDARDepthCamera = OCMClassMock([AVCaptureDevice class]);
  OCMStub([liDARDepthCamera uniqueID]).andReturn(@"4");
  if (@available(iOS 15.4, *)) {
    OCMStub([liDARDepthCamera deviceType]).andReturn(AVCaptureDeviceTypeBuiltInLiDARDepthCamera);
  }
  OCMStub([liDARDepthCamera position]).andReturn(AVCaptureDevicePositionBack);

  // iPhone 17 Cameras:
  AVCaptureDevice *continuityCamera = OCMClassMock([AVCaptureDevice class]);
  OCMStub([continuityCamera uniqueID]).andReturn(@"5");
  if (@available(iOS 17.0, *)) {
    OCMStub([continuityCamera deviceType]).andReturn(AVCaptureDeviceTypeContinuityCamera);
  }
  OCMStub([continuityCamera position]).andReturn(AVCaptureDevicePositionBack);

  NSMutableArray *requiredTypes = [NSMutableArray new];
  if (@available(iOS 17.0, *)) {
      [requiredTypes addObjectsFromArray:
          @[ AVCaptureDeviceTypeBuiltInDualCamera,
             AVCaptureDeviceTypeBuiltInTrueDepthCamera,
             AVCaptureDeviceTypeBuiltInDualWideCamera,
             AVCaptureDeviceTypeBuiltInTripleCamera,
             AVCaptureDeviceTypeBuiltInLiDARDepthCamera,
             AVCaptureDeviceTypeContinuityCamera ]];
  } else if (@available(iOS 15.4, *)) {
      [requiredTypes addObjectsFromArray:
          @[ AVCaptureDeviceTypeBuiltInDualCamera,
             AVCaptureDeviceTypeBuiltInTrueDepthCamera,
             AVCaptureDeviceTypeBuiltInDualWideCamera,
             AVCaptureDeviceTypeBuiltInTripleCamera,
             AVCaptureDeviceTypeBuiltInLiDARDepthCamera ]];
  } else if (@available(iOS 13.0, *)) {
      [requiredTypes addObjectsFromArray:
          @[ AVCaptureDeviceTypeBuiltInDualCamera,
             AVCaptureDeviceTypeBuiltInTrueDepthCamera,
             AVCaptureDeviceTypeBuiltInDualWideCamera,
             AVCaptureDeviceTypeBuiltInTripleCamera ]];
  } else {
      [requiredTypes addObjectsFromArray:
          @[ AVCaptureDeviceTypeBuiltInDualCamera,
             AVCaptureDeviceTypeBuiltInTrueDepthCamera ]];
  }

  id discoverySessionMock = OCMClassMock([AVCaptureDeviceDiscoverySession class]);
  OCMStub([discoverySessionMock discoverySessionWithDeviceTypes:requiredTypes
                                                      mediaType:AVMediaTypeVideo
                                                       position:AVCaptureDevicePositionUnspecified])
      .andReturn(discoverySessionMock);

  NSMutableArray *cameras =
      [@[ trueDepthCamera, dualCamera ] mutableCopy];
  if (@available(iOS 13.0, *)) {
    [cameras addObjectsFromArray: @[ dualWideCamera, tripleCamera ]];
  }
  if (@available(iOS 15.4, *)) {
    [cameras addObjectsFromArray: @[ liDARDepthCamera ]];
  }
  if (@available(iOS 17.0, *)) {
    [cameras addObjectsFromArray: @[ continuityCamera ]];
  }
  OCMStub([discoverySessionMock devices]).andReturn([NSArray arrayWithArray:cameras]);

  MockFLTThreadSafeFlutterResult *resultObject =
      [[MockFLTThreadSafeFlutterResult alloc] initWithExpectation:expectation];

  // Set up method call
  FlutterMethodCall *call = [FlutterMethodCall methodCallWithMethodName:@"availableCameras"
                                                              arguments:@{@"physicalCameras" : @FALSE, @"logicalCameras" : @TRUE}];

  [camera handleMethodCallAsync:call result:resultObject];

  // Verify the result
  NSDictionary *dictionaryResult = (NSDictionary *)resultObject.receivedResult;
  if (@available(iOS 17.0, *)) {
    XCTAssertTrue([dictionaryResult count] == 6);
  } else if (@available(iOS 15.4, *)) {
    XCTAssertTrue([dictionaryResult count] == 5);
  } else if (@available(iOS 13.0, *)) {
    XCTAssertTrue([dictionaryResult count] == 4);
  } else {
    XCTAssertTrue([dictionaryResult count] == 2);
  }
}

@end
