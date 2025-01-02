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
  NSArray<FGMPlatformLatLng *> *latlongs = @[
    [FGMPlatformLatLng makeWithLatitude:1 longitude:2], [FGMPlatformLatLng makeWithLatitude:3
                                                                                  longitude:4]
  ];
  NSArray<CLLocation *> *locations = FGMGetPointsForPigeonLatLngs(latlongs);
  XCTAssertEqual(locations.count, 2);
  XCTAssertEqual(locations[0].coordinate.latitude, 1);
  XCTAssertEqual(locations[0].coordinate.longitude, 2);
  XCTAssertEqual(locations[1].coordinate.latitude, 3);
  XCTAssertEqual(locations[1].coordinate.longitude, 4);
}

- (void)testHolesFromPointsArray {
  NSArray<NSArray<FGMPlatformLatLng *> *> *pointsArray = @[
    @[
      [FGMPlatformLatLng makeWithLatitude:1 longitude:2], [FGMPlatformLatLng makeWithLatitude:3
                                                                                    longitude:4]
    ],
    @[
      [FGMPlatformLatLng makeWithLatitude:5 longitude:6], [FGMPlatformLatLng makeWithLatitude:7
                                                                                    longitude:8]
    ]
  ];
  NSArray<NSArray<CLLocation *> *> *holes = FGMGetHolesForPigeonLatLngArrays(pointsArray);
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
  FGMPlatformLatLngBounds *pigeonBounds = [FGMPlatformLatLngBounds
      makeWithNortheast:[FGMPlatformLatLng makeWithLatitude:3 longitude:4]
              southwest:[FGMPlatformLatLng makeWithLatitude:1 longitude:2]];

  GMSCoordinateBounds *bounds = FGMGetCoordinateBoundsForPigeonLatLngBounds(pigeonBounds);

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

- (void)testCameraUpdateFromNewCameraPosition {
  id classMockCameraUpdate = OCMClassMock([GMSCameraUpdate class]);
  FGMPlatformCameraUpdateNewCameraPosition *newPositionUpdate =
      [FGMPlatformCameraUpdateNewCameraPosition
          makeWithCameraPosition:[FGMPlatformCameraPosition
                                     makeWithBearing:4
                                              target:[FGMPlatformLatLng makeWithLatitude:1
                                                                               longitude:2]
                                                tilt:5
                                                zoom:3]];
  FGMGetCameraUpdateForPigeonCameraUpdate(
      [FGMPlatformCameraUpdate makeWithCameraUpdate:newPositionUpdate]);
  [[classMockCameraUpdate expect]
      setCamera:FGMGetCameraPositionForPigeonCameraPosition(newPositionUpdate.cameraPosition)];
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
- (void)skip_testCameraUpdateFromNewLatLong {
  const CGFloat lat = 1;
  const CGFloat lng = 2;
  FGMPlatformCameraUpdateNewLatLng *platformUpdate = [FGMPlatformCameraUpdateNewLatLng
      makeWithLatLng:[FGMPlatformLatLng makeWithLatitude:lat longitude:lng]];

  GMSCameraUpdate *update = FGMGetCameraUpdateForPigeonCameraUpdate(
      [FGMPlatformCameraUpdate makeWithCameraUpdate:platformUpdate]);

  GMSMapViewOptions *options = [[GMSMapViewOptions alloc] init];
  options.frame = CGRectZero;
  options.camera = [GMSCameraPosition cameraWithTarget:CLLocationCoordinate2DMake(5, 6) zoom:1];
  GMSMapView *mapView = [[GMSMapView alloc] initWithOptions:options];
  [mapView moveCamera:update];
  const CGFloat accuracy = 0.001;
  XCTAssertEqualWithAccuracy(mapView.camera.target.latitude, lat,
                             accuracy);  // mapView.camera.target.latitude is still 5.
  XCTAssertEqualWithAccuracy(mapView.camera.target.longitude, lng,
                             accuracy);  // mapView.camera.target.longitude is still 6.
}

- (void)testCameraUpdateFromNewLatLngBounds {
  FGMPlatformLatLngBounds *pigeonBounds = [FGMPlatformLatLngBounds
      makeWithNortheast:[FGMPlatformLatLng makeWithLatitude:1 longitude:2]
              southwest:[FGMPlatformLatLng makeWithLatitude:3 longitude:4]];
  GMSCoordinateBounds *bounds = FGMGetCoordinateBoundsForPigeonLatLngBounds(pigeonBounds);

  const CGFloat padding = 20;
  FGMPlatformCameraUpdateNewLatLngBounds *platformUpdate = [FGMPlatformCameraUpdateNewLatLngBounds
      makeWithBounds:FGMGetPigeonLatLngBoundsForCoordinateBounds(bounds)
             padding:padding];
  id classMockCameraUpdate = OCMClassMock([GMSCameraUpdate class]);
  FGMGetCameraUpdateForPigeonCameraUpdate(
      [FGMPlatformCameraUpdate makeWithCameraUpdate:platformUpdate]);

  [[classMockCameraUpdate expect] fitBounds:bounds withPadding:padding];
  [classMockCameraUpdate stopMocking];
}

- (void)testCameraUpdateFromNewLatLngZoom {
  const CGFloat lat = 1;
  const CGFloat lng = 2;
  const CGFloat zoom = 3;
  FGMPlatformCameraUpdateNewLatLngZoom *platformUpdate = [FGMPlatformCameraUpdateNewLatLngZoom
      makeWithLatLng:[FGMPlatformLatLng makeWithLatitude:lat longitude:lng]
                zoom:zoom];

  id classMockCameraUpdate = OCMClassMock([GMSCameraUpdate class]);
  FGMGetCameraUpdateForPigeonCameraUpdate(
      [FGMPlatformCameraUpdate makeWithCameraUpdate:platformUpdate]);

  [[classMockCameraUpdate expect] setTarget:CLLocationCoordinate2DMake(lat, lng) zoom:zoom];
  [classMockCameraUpdate stopMocking];
}

- (void)testCameraUpdateFromScrollBy {
  const CGFloat x = 1;
  const CGFloat y = 2;
  FGMPlatformCameraUpdateScrollBy *platformUpdate = [FGMPlatformCameraUpdateScrollBy makeWithDx:x
                                                                                             dy:y];

  id classMockCameraUpdate = OCMClassMock([GMSCameraUpdate class]);
  FGMGetCameraUpdateForPigeonCameraUpdate(
      [FGMPlatformCameraUpdate makeWithCameraUpdate:platformUpdate]);

  [[classMockCameraUpdate expect] scrollByX:x Y:y];
  [classMockCameraUpdate stopMocking];
}

- (void)testCameraUpdateFromZoomBy {
  const CGFloat zoom = 1;
  FGMPlatformCameraUpdateZoomBy *platformUpdateNoPoint =
      [FGMPlatformCameraUpdateZoomBy makeWithAmount:zoom focus:nil];

  id classMockCameraUpdate = OCMClassMock([GMSCameraUpdate class]);
  FGMGetCameraUpdateForPigeonCameraUpdate(
      [FGMPlatformCameraUpdate makeWithCameraUpdate:platformUpdateNoPoint]);

  [[classMockCameraUpdate expect] zoomBy:zoom];

  const CGFloat x = 2;
  const CGFloat y = 3;
  FGMPlatformCameraUpdateZoomBy *platformUpdate =
      [FGMPlatformCameraUpdateZoomBy makeWithAmount:zoom focus:[FGMPlatformPoint makeWithX:x y:y]];

  FGMGetCameraUpdateForPigeonCameraUpdate(
      [FGMPlatformCameraUpdate makeWithCameraUpdate:platformUpdate]);

  [[classMockCameraUpdate expect] zoomBy:zoom atPoint:CGPointMake(x, y)];
  [classMockCameraUpdate stopMocking];
}

- (void)testCameraUpdateFromZoomIn {
  FGMPlatformCameraUpdateZoom *platformUpdate = [FGMPlatformCameraUpdateZoom makeWithOut:NO];

  id classMockCameraUpdate = OCMClassMock([GMSCameraUpdate class]);
  FGMGetCameraUpdateForPigeonCameraUpdate(
      [FGMPlatformCameraUpdate makeWithCameraUpdate:platformUpdate]);

  [[classMockCameraUpdate expect] zoomIn];
  [classMockCameraUpdate stopMocking];
}

- (void)testCameraUpdateFromZoomOut {
  FGMPlatformCameraUpdateZoom *platformUpdate = [FGMPlatformCameraUpdateZoom makeWithOut:YES];

  id classMockCameraUpdate = OCMClassMock([GMSCameraUpdate class]);
  FGMGetCameraUpdateForPigeonCameraUpdate(
      [FGMPlatformCameraUpdate makeWithCameraUpdate:platformUpdate]);

  [[classMockCameraUpdate expect] zoomOut];
  [classMockCameraUpdate stopMocking];
}

- (void)testCameraUpdateFromZoomTo {
  const CGFloat zoom = 1;
  FGMPlatformCameraUpdateZoomTo *platformUpdate = [FGMPlatformCameraUpdateZoomTo makeWithZoom:zoom];

  id classMockCameraUpdate = OCMClassMock([GMSCameraUpdate class]);
  FGMGetCameraUpdateForPigeonCameraUpdate(
      [FGMPlatformCameraUpdate makeWithCameraUpdate:platformUpdate]);

  [[classMockCameraUpdate expect] zoomTo:zoom];
  [classMockCameraUpdate stopMocking];
}

- (void)testStrokeStylesFromPatterns {
  NSArray<FGMPlatformPatternItem *> *patterns = @[
    [FGMPlatformPatternItem makeWithType:FGMPlatformPatternItemTypeGap length:@(1)],
    [FGMPlatformPatternItem makeWithType:FGMPlatformPatternItemTypeDash length:@(1)]
  ];
  UIColor *strokeColor = UIColor.redColor;

  NSArray<GMSStrokeStyle *> *patternStrokeStyle =
      FGMGetStrokeStylesFromPatterns(patterns, strokeColor);

  XCTAssertEqual(patternStrokeStyle.count, 2);

  // None of the parameters of `patternStrokeStyle` is observable, so we limit to testing
  // the length of this output array.
}

- (void)testLengthsFromPatterns {
  const CGFloat gapLength = 10;
  const CGFloat dashLength = 6.4;
  NSArray<FGMPlatformPatternItem *> *patterns = @[
    [FGMPlatformPatternItem makeWithType:FGMPlatformPatternItemTypeGap length:@(gapLength)],
    [FGMPlatformPatternItem makeWithType:FGMPlatformPatternItemTypeDash length:@(dashLength)]
  ];

  NSArray<NSNumber *> *spanLengths = FGMGetSpanLengthsFromPatterns(patterns);

  XCTAssertEqual(spanLengths.count, 2);

  NSNumber *firstSpanLength = spanLengths[0];
  NSNumber *secondSpanLength = spanLengths[1];

  XCTAssertEqual(firstSpanLength.doubleValue, gapLength);
  XCTAssertEqual(secondSpanLength.doubleValue, dashLength);
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
