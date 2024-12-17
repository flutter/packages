// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import google_maps_flutter_ios;
@import google_maps_flutter_ios.Test;
@import XCTest;
@import GoogleMaps;

#import <OCMock/OCMock.h>
#import <google_maps_flutter_ios/GoogleMapPolylineController_Test.h>
#import <google_maps_flutter_ios/messages.g.h>
#import "PartiallyMockedMapView.h"

@interface GoogleMapsPolylinesControllerTests : XCTestCase
@end

@implementation GoogleMapsPolylinesControllerTests

/// Returns GoogleMapPolylineController object instantiated with a mocked map instance
///
///  @return An object of FLTGoogleMapPolylineController
- (FLTGoogleMapPolylineController *)polylineControllerWithMockedMap {
  FGMPlatformPolyline *polyline = [FGMPlatformPolyline
      makeWithPolylineId:@"polyline_id_0"
       consumesTapEvents:NO
                   color:0
                geodesic:NO
               jointType:FGMPlatformJointTypeRound
                patterns:@[]
                  points:@[
                    [FGMPlatformLatLng makeWithLatitude:52.4816 longitude:-3.1791],
                    [FGMPlatformLatLng makeWithLatitude:54.043 longitude:-2.9925],
                    [FGMPlatformLatLng makeWithLatitude:54.1396 longitude:-4.2739],
                    [FGMPlatformLatLng makeWithLatitude:53.4153 longitude:-4.0829],
                  ]
                 visible:NO
                   width:1
                  zIndex:0];

  CGRect frame = CGRectMake(0, 0, 100, 100);
  GMSCameraPosition *camera = [[GMSCameraPosition alloc] initWithLatitude:0 longitude:0 zoom:0];

  GMSMapViewOptions *mapViewOptions = [[GMSMapViewOptions alloc] init];
  mapViewOptions.frame = frame;
  mapViewOptions.camera = camera;

  PartiallyMockedMapView *mapView = [[PartiallyMockedMapView alloc] initWithOptions:mapViewOptions];

  GMSMutablePath *path = FGMGetPathFromPoints(FGMGetPointsForPigeonLatLngs(polyline.points));

  FLTGoogleMapPolylineController *polylineControllerWithMockedMap =
      [[FLTGoogleMapPolylineController alloc] initWithPath:path
                                                identifier:polyline.polylineId
                                                   mapView:mapView];

  return polylineControllerWithMockedMap;
}

- (void)testSetPatterns {
  NSArray<GMSStrokeStyle *> *styles = @[
    [GMSStrokeStyle solidColor:UIColor.clearColor], [GMSStrokeStyle solidColor:UIColor.redColor]
  ];

  NSArray<NSNumber *> *lengths = @[ @10, @10 ];

  FLTGoogleMapPolylineController *polylineController = [self polylineControllerWithMockedMap];

  XCTAssertNil(polylineController.polyline.spans);

  [polylineController setPattern:styles lengths:lengths];

  // `GMSStyleSpan` doesn't implement `isEqual` so cannot be compared by value at present.
  XCTAssertNotNil(polylineController.polyline.spans);
}

@end
