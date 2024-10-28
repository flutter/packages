// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import google_maps_flutter_ios;
@import google_maps_flutter_ios.Test;
@import XCTest;
@import GoogleMaps;

#import <OCMock/OCMock.h>
#import "PartiallyMockedMapView.h"

@interface FLTGoogleMapJSONConversionsTests : XCTestCase
@end

@implementation FLTGoogleMapJSONConversionsTests

- (void)testGetValueOrNilWithValue {
  NSString *key = @"key";
  NSString *value = @"value";
  NSDictionary<NSString *, id> *dict = @{key : value};

  XCTAssertEqual(FGMGetValueOrNilFromDict(dict, key), value);
}

- (void)testGetValueOrNilWithNoEntry {
  NSString *key = @"key";
  NSDictionary<NSString *, id> *dict = @{};

  XCTAssertNil(FGMGetValueOrNilFromDict(dict, key));
}

- (void)testGetValueOrNilWithNSNull {
  NSString *key = @"key";
  NSDictionary<NSString *, id> *dict = @{key : [NSNull null]};

  XCTAssertNil(FGMGetValueOrNilFromDict(dict, key));
}

- (void)testLocationFromLatLong {
  NSArray<NSNumber *> *latlong = @[ @1, @2 ];
  CLLocationCoordinate2D location = [FLTGoogleMapJSONConversions locationFromLatLong:latlong];
  XCTAssertEqual(location.latitude, 1);
  XCTAssertEqual(location.longitude, 2);
}

- (void)testPointFromArray {
  NSArray<NSNumber *> *array = @[ @1, @2 ];
  CGPoint point = [FLTGoogleMapJSONConversions pointFromArray:array];
  XCTAssertEqual(point.x, 1);
  XCTAssertEqual(point.y, 2);
}

- (void)testArrayFromLocation {
  CLLocationCoordinate2D location = CLLocationCoordinate2DMake(1, 2);
  NSArray<NSNumber *> *array = [FLTGoogleMapJSONConversions arrayFromLocation:location];
  XCTAssertEqual([array[0] integerValue], 1);
  XCTAssertEqual([array[1] integerValue], 2);
}

- (void)testColorFromRGBA {
  NSNumber *rgba = @(0x01020304);
  UIColor *color = [FLTGoogleMapJSONConversions colorFromRGBA:rgba];
  CGFloat red, green, blue, alpha;
  BOOL success = [color getRed:&red green:&green blue:&blue alpha:&alpha];
  XCTAssertTrue(success);
  const CGFloat accuracy = 0.0001;
  XCTAssertEqualWithAccuracy(red, 2 / 255.0, accuracy);
  XCTAssertEqualWithAccuracy(green, 3 / 255.0, accuracy);
  XCTAssertEqualWithAccuracy(blue, 4 / 255.0, accuracy);
  XCTAssertEqualWithAccuracy(alpha, 1 / 255.0, accuracy);
}

- (void)testPointsFromLatLongs {
  NSArray<NSArray *> *latlongs = @[ @[ @1, @2 ], @[ @(3), @(4) ] ];
  NSArray<CLLocation *> *locations = [FLTGoogleMapJSONConversions pointsFromLatLongs:latlongs];
  XCTAssertEqual(locations.count, 2);
  XCTAssertEqual(locations[0].coordinate.latitude, 1);
  XCTAssertEqual(locations[0].coordinate.longitude, 2);
  XCTAssertEqual(locations[1].coordinate.latitude, 3);
  XCTAssertEqual(locations[1].coordinate.longitude, 4);
}

- (void)testHolesFromPointsArray {
  NSArray<NSArray *> *pointsArray =
      @[ @[ @[ @1, @2 ], @[ @(3), @(4) ] ], @[ @[ @(5), @(6) ], @[ @(7), @(8) ] ] ];
  NSArray<NSArray<CLLocation *> *> *holes =
      [FLTGoogleMapJSONConversions holesFromPointsArray:pointsArray];
  XCTAssertEqual(holes.count, 2);
  XCTAssertEqual(holes[0][0].coordinate.latitude, 1);
  XCTAssertEqual(holes[0][0].coordinate.longitude, 2);
  XCTAssertEqual(holes[0][1].coordinate.latitude, 3);
  XCTAssertEqual(holes[0][1].coordinate.longitude, 4);
  XCTAssertEqual(holes[1][0].coordinate.latitude, 5);
  XCTAssertEqual(holes[1][0].coordinate.longitude, 6);
  XCTAssertEqual(holes[1][1].coordinate.latitude, 7);
  XCTAssertEqual(holes[1][1].coordinate.longitude, 8);
}

- (void)testGetPigeonCameraPositionForPosition {
  GMSCameraPosition *position =
      [[GMSCameraPosition alloc] initWithTarget:CLLocationCoordinate2DMake(1, 2)
                                           zoom:2.0
                                        bearing:3.0
                                   viewingAngle:75.0];
  FGMPlatformCameraPosition *pigeonPosition = FGMGetPigeonCameraPositionForPosition(position);
  XCTAssertEqualWithAccuracy(pigeonPosition.target.latitude, position.target.latitude, DBL_EPSILON);
  XCTAssertEqualWithAccuracy(pigeonPosition.target.longitude, position.target.longitude,
                             DBL_EPSILON);
  XCTAssertEqualWithAccuracy(pigeonPosition.zoom, position.zoom, DBL_EPSILON);
  XCTAssertEqualWithAccuracy(pigeonPosition.bearing, position.bearing, DBL_EPSILON);
  XCTAssertEqualWithAccuracy(pigeonPosition.tilt, position.viewingAngle, DBL_EPSILON);
}

- (void)testPigeonPointForGCPoint {
  CGPoint point = CGPointMake(10, 20);
  FGMPlatformPoint *pigeonPoint = FGMGetPigeonPointForCGPoint(point);
  XCTAssertEqualWithAccuracy(pigeonPoint.x, point.x, DBL_EPSILON);
  XCTAssertEqualWithAccuracy(pigeonPoint.y, point.y, DBL_EPSILON);
}

- (void)testPigeonLatLngBoundsForCoordinateBounds {
  GMSCoordinateBounds *bounds =
      [[GMSCoordinateBounds alloc] initWithCoordinate:CLLocationCoordinate2DMake(10, 20)
                                           coordinate:CLLocationCoordinate2DMake(30, 40)];
  FGMPlatformLatLngBounds *pigeonBounds = FGMGetPigeonLatLngBoundsForCoordinateBounds(bounds);
  XCTAssertEqualWithAccuracy(pigeonBounds.southwest.latitude, bounds.southWest.latitude,
                             DBL_EPSILON);
  XCTAssertEqualWithAccuracy(pigeonBounds.southwest.longitude, bounds.southWest.longitude,
                             DBL_EPSILON);
  XCTAssertEqualWithAccuracy(pigeonBounds.northeast.latitude, bounds.northEast.latitude,
                             DBL_EPSILON);
  XCTAssertEqualWithAccuracy(pigeonBounds.northeast.longitude, bounds.northEast.longitude,
                             DBL_EPSILON);
}

- (void)testCameraPostionFromDictionary {
  XCTAssertNil([FLTGoogleMapJSONConversions cameraPostionFromDictionary:nil]);

  NSDictionary *channelValue =
      @{@"target" : @[ @1, @2 ], @"zoom" : @3, @"bearing" : @4, @"tilt" : @5};

  GMSCameraPosition *cameraPosition =
      [FLTGoogleMapJSONConversions cameraPostionFromDictionary:channelValue];

  const CGFloat accuracy = 0.001;
  XCTAssertEqualWithAccuracy(cameraPosition.target.latitude, 1, accuracy);
  XCTAssertEqualWithAccuracy(cameraPosition.target.longitude, 2, accuracy);
  XCTAssertEqualWithAccuracy(cameraPosition.zoom, 3, accuracy);
  XCTAssertEqualWithAccuracy(cameraPosition.bearing, 4, accuracy);
  XCTAssertEqualWithAccuracy(cameraPosition.viewingAngle, 5, accuracy);
}

- (void)testGetCameraPostionForPigeonCameraPosition {
  FGMPlatformCameraPosition *pigeonCameraPosition = [FGMPlatformCameraPosition
      makeWithBearing:1.0
               target:[FGMPlatformLatLng makeWithLatitude:2.0 longitude:3.0]
                 tilt:4.0
                 zoom:5.0];

  GMSCameraPosition *cameraPosition =
      FGMGetCameraPositionForPigeonCameraPosition(pigeonCameraPosition);

  XCTAssertEqualWithAccuracy(cameraPosition.target.latitude, pigeonCameraPosition.target.latitude,
                             DBL_EPSILON);
  XCTAssertEqualWithAccuracy(cameraPosition.target.longitude, pigeonCameraPosition.target.longitude,
                             DBL_EPSILON);
  XCTAssertEqualWithAccuracy(cameraPosition.zoom, pigeonCameraPosition.zoom, DBL_EPSILON);
  XCTAssertEqualWithAccuracy(cameraPosition.bearing, pigeonCameraPosition.bearing, DBL_EPSILON);
  XCTAssertEqualWithAccuracy(cameraPosition.viewingAngle, pigeonCameraPosition.tilt, DBL_EPSILON);
}

- (void)testCGPointForPigeonPoint {
  FGMPlatformPoint *pigeonPoint = [FGMPlatformPoint makeWithX:1.0 y:2.0];

  CGPoint point = FGMGetCGPointForPigeonPoint(pigeonPoint);

  XCTAssertEqualWithAccuracy(pigeonPoint.x, point.x, DBL_EPSILON);
  XCTAssertEqualWithAccuracy(pigeonPoint.y, point.y, DBL_EPSILON);
}

- (void)testCoordinateBoundsFromLatLongs {
  NSArray<NSNumber *> *latlong1 = @[ @1, @2 ];
  NSArray<NSNumber *> *latlong2 = @[ @(3), @(4) ];

  GMSCoordinateBounds *bounds =
      [FLTGoogleMapJSONConversions coordinateBoundsFromLatLongs:@[ latlong1, latlong2 ]];

  const CGFloat accuracy = 0.001;
  XCTAssertEqualWithAccuracy(bounds.southWest.latitude, 1, accuracy);
  XCTAssertEqualWithAccuracy(bounds.southWest.longitude, 2, accuracy);
  XCTAssertEqualWithAccuracy(bounds.northEast.latitude, 3, accuracy);
  XCTAssertEqualWithAccuracy(bounds.northEast.longitude, 4, accuracy);
}

- (void)testMapViewTypeFromPigeonType {
  XCTAssertEqual(kGMSTypeNormal, FGMGetMapViewTypeForPigeonMapType(FGMPlatformMapTypeNormal));
  XCTAssertEqual(kGMSTypeSatellite, FGMGetMapViewTypeForPigeonMapType(FGMPlatformMapTypeSatellite));
  XCTAssertEqual(kGMSTypeTerrain, FGMGetMapViewTypeForPigeonMapType(FGMPlatformMapTypeTerrain));
  XCTAssertEqual(kGMSTypeHybrid, FGMGetMapViewTypeForPigeonMapType(FGMPlatformMapTypeHybrid));
  XCTAssertEqual(kGMSTypeNone, FGMGetMapViewTypeForPigeonMapType(FGMPlatformMapTypeNone));
}

- (void)testCameraUpdateFromArrayNewCameraPosition {
  NSArray *channelValue = @[
    @"newCameraPosition", @{@"target" : @[ @1, @2 ], @"zoom" : @3, @"bearing" : @4, @"tilt" : @5}
  ];
  id classMockCameraUpdate = OCMClassMock([GMSCameraUpdate class]);
  [FLTGoogleMapJSONConversions cameraUpdateFromArray:channelValue];
  [[classMockCameraUpdate expect]
      setCamera:[FLTGoogleMapJSONConversions cameraPostionFromDictionary:channelValue[1]]];
  [classMockCameraUpdate stopMocking];
}

// TODO(cyanglaz): Fix the test for cameraUpdateFromArray with the "NewLatlng" key.
// 2 approaches have been tried and neither worked for the tests.
//
// 1. Use OCMock to vefiry that [GMSCameraUpdate setTarget:] is triggered with the correct value.
// This class method conflicts with certain category method in OCMock, causing OCMock not able to
// disambigious them.
//
// 2. Directly verify the GMSCameraUpdate object returned by the method.
// The GMSCameraUpdate object returned from the method doesn't have any accessors to the "target"
// property. It can be used to update the "camera" property in GMSMapView. However, [GMSMapView
// moveCamera:] doesn't update the camera immediately. Thus the GMSCameraUpdate object cannot be
// verified.
//
// The code in below test uses the 2nd approach.
- (void)skip_testCameraUpdateFromArrayNewLatLong {
  NSArray *channelValue = @[ @"newLatLng", @[ @1, @2 ] ];

  GMSCameraUpdate *update = [FLTGoogleMapJSONConversions cameraUpdateFromArray:channelValue];

  GMSMapViewOptions *options = [[GMSMapViewOptions alloc] init];
  options.frame = CGRectZero;
  options.camera = [GMSCameraPosition cameraWithTarget:CLLocationCoordinate2DMake(5, 6) zoom:1];
  GMSMapView *mapView = [[GMSMapView alloc] initWithOptions:options];
  [mapView moveCamera:update];
  const CGFloat accuracy = 0.001;
  XCTAssertEqualWithAccuracy(mapView.camera.target.latitude, 1,
                             accuracy);  // mapView.camera.target.latitude is still 5.
  XCTAssertEqualWithAccuracy(mapView.camera.target.longitude, 2,
                             accuracy);  // mapView.camera.target.longitude is still 6.
}

- (void)testCameraUpdateFromArrayNewLatLngBounds {
  NSArray<NSNumber *> *latlong1 = @[ @1, @2 ];
  NSArray<NSNumber *> *latlong2 = @[ @(3), @(4) ];
  GMSCoordinateBounds *bounds =
      [FLTGoogleMapJSONConversions coordinateBoundsFromLatLongs:@[ latlong1, latlong2 ]];

  NSArray *channelValue = @[ @"newLatLngBounds", @[ latlong1, latlong2 ], @20 ];
  id classMockCameraUpdate = OCMClassMock([GMSCameraUpdate class]);
  [FLTGoogleMapJSONConversions cameraUpdateFromArray:channelValue];

  [[classMockCameraUpdate expect] fitBounds:bounds withPadding:20];
  [classMockCameraUpdate stopMocking];
}

- (void)testCameraUpdateFromArrayNewLatLngZoom {
  NSArray *channelValue = @[ @"newLatLngZoom", @[ @1, @2 ], @3 ];

  id classMockCameraUpdate = OCMClassMock([GMSCameraUpdate class]);
  [FLTGoogleMapJSONConversions cameraUpdateFromArray:channelValue];

  [[classMockCameraUpdate expect] setTarget:CLLocationCoordinate2DMake(1, 2) zoom:3];
  [classMockCameraUpdate stopMocking];
}

- (void)testCameraUpdateFromArrayScrollBy {
  NSArray *channelValue = @[ @"scrollBy", @1, @2 ];

  id classMockCameraUpdate = OCMClassMock([GMSCameraUpdate class]);
  [FLTGoogleMapJSONConversions cameraUpdateFromArray:channelValue];

  [[classMockCameraUpdate expect] scrollByX:1 Y:2];
  [classMockCameraUpdate stopMocking];
}

- (void)testCameraUpdateFromArrayZoomBy {
  NSArray *channelValueNoPoint = @[ @"zoomBy", @1 ];

  id classMockCameraUpdate = OCMClassMock([GMSCameraUpdate class]);
  [FLTGoogleMapJSONConversions cameraUpdateFromArray:channelValueNoPoint];

  [[classMockCameraUpdate expect] zoomBy:1];

  NSArray *channelValueWithPoint = @[ @"zoomBy", @1, @[ @2, @3 ] ];

  [FLTGoogleMapJSONConversions cameraUpdateFromArray:channelValueWithPoint];

  [[classMockCameraUpdate expect] zoomBy:1 atPoint:CGPointMake(2, 3)];
  [classMockCameraUpdate stopMocking];
}

- (void)testCameraUpdateFromArrayZoomIn {
  NSArray *channelValueNoPoint = @[ @"zoomIn" ];

  id classMockCameraUpdate = OCMClassMock([GMSCameraUpdate class]);
  [FLTGoogleMapJSONConversions cameraUpdateFromArray:channelValueNoPoint];

  [[classMockCameraUpdate expect] zoomIn];
  [classMockCameraUpdate stopMocking];
}

- (void)testCameraUpdateFromArrayZoomOut {
  NSArray *channelValueNoPoint = @[ @"zoomOut" ];

  id classMockCameraUpdate = OCMClassMock([GMSCameraUpdate class]);
  [FLTGoogleMapJSONConversions cameraUpdateFromArray:channelValueNoPoint];

  [[classMockCameraUpdate expect] zoomOut];
  [classMockCameraUpdate stopMocking];
}

- (void)testCameraUpdateFromArrayZoomTo {
  NSArray *channelValueNoPoint = @[ @"zoomTo", @1 ];

  id classMockCameraUpdate = OCMClassMock([GMSCameraUpdate class]);
  [FLTGoogleMapJSONConversions cameraUpdateFromArray:channelValueNoPoint];

  [[classMockCameraUpdate expect] zoomTo:1];
  [classMockCameraUpdate stopMocking];
}

- (void)testLengthsFromPatterns {
  NSArray<NSArray<id> *> *patterns = @[ @[ @"gap", @10 ], @[ @"dash", @6.4 ] ];

  NSArray<NSNumber *> *spanLengths = [FLTGoogleMapJSONConversions spanLengthsFromPatterns:patterns];

  XCTAssertEqual([spanLengths count], 2);

  NSNumber *firstSpanLength = spanLengths[0];
  NSNumber *secondSpanLength = spanLengths[1];

  XCTAssertEqual(firstSpanLength.doubleValue, 10);
  XCTAssertEqual(secondSpanLength.doubleValue, 6.4);
}

- (void)testWeightedLatLngFromArray {
  NSArray *weightedLatLng = @[ @[ @1, @2 ], @3 ];

  GMUWeightedLatLng *weightedLocation =
      [FLTGoogleMapJSONConversions weightedLatLngFromArray:weightedLatLng];

  // The location gets projected to different values
  XCTAssertEqual([weightedLocation intensity], 3);
}

- (void)testWeightedLatLngFromArrayThrowsForInvalidInput {
  NSArray *weightedLatLng = @[];

  XCTAssertThrows([FLTGoogleMapJSONConversions weightedLatLngFromArray:weightedLatLng]);
}

- (void)testWeightedDataFromArray {
  NSNumber *intensity1 = @3;
  NSNumber *intensity2 = @6;
  NSArray *data = @[ @[ @[ @1, @2 ], intensity1 ], @[ @[ @4, @5 ], intensity2 ] ];

  NSArray<GMUWeightedLatLng *> *weightedData =
      [FLTGoogleMapJSONConversions weightedDataFromArray:data];
  XCTAssertEqual([weightedData[0] intensity], [intensity1 floatValue]);
  XCTAssertEqual([weightedData[1] intensity], [intensity2 floatValue]);
}

- (void)testGradientFromDictionary {
  NSNumber *startPoint = @0.6;
  NSNumber *colorMapSize = @200;
  NSDictionary *gradientData = @{
    @"colors" : @[
      // Color.fromARGB(255, 0, 255, 255)
      @4278255615,
    ],
    @"startPoints" : @[ startPoint ],
    @"colorMapSize" : colorMapSize,
  };

  GMUGradient *gradient = [FLTGoogleMapJSONConversions gradientFromDictionary:gradientData];
  CGFloat red, green, blue, alpha;
  [[gradient colors][0] getRed:&red green:&green blue:&blue alpha:&alpha];
  XCTAssertEqual(red, 0);
  XCTAssertEqual(green, 1);
  XCTAssertEqual(blue, 1);
  XCTAssertEqual(alpha, 1);
  XCTAssertEqualWithAccuracy([[gradient startPoints][0] doubleValue], [startPoint doubleValue], 0);
  XCTAssertEqual([gradient mapSize], [colorMapSize intValue]);
}

@end
