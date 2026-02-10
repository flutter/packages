// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import google_maps_flutter_ios;
@import XCTest;
@import GoogleMaps;

#import "PartiallyMockedMapView.h"

@interface FGMConversionUtilsTests : XCTestCase
@end

@implementation FGMConversionUtilsTests

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

- (void)testColorFromPlatformColor {
  double platformRed = 1 / 255.0;
  double platformGreen = 2 / 255.0;
  double platformBlue = 3 / 255.0;
  double platformAlpha = 4 / 255.0;
  UIColor *color = FGMGetColorForPigeonColor([FGMPlatformColor makeWithRed:platformRed
                                                                     green:platformGreen
                                                                      blue:platformBlue
                                                                     alpha:platformAlpha]);
  CGFloat red, green, blue, alpha;
  BOOL success = [color getRed:&red green:&green blue:&blue alpha:&alpha];
  XCTAssertTrue(success);
  const CGFloat accuracy = 0.0001;
  XCTAssertEqualWithAccuracy(red, platformRed, accuracy);
  XCTAssertEqualWithAccuracy(green, platformGreen, accuracy);
  XCTAssertEqualWithAccuracy(blue, platformBlue, accuracy);
  XCTAssertEqualWithAccuracy(alpha, platformAlpha, accuracy);
}

- (void)testPlatformColorFromColor {
  double red = 1 / 255.0;
  double green = 2 / 255.0;
  double blue = 3 / 255.0;
  double alpha = 4 / 255.0;
  UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
  FGMPlatformColor *platformColor = FGMGetPigeonColorForColor(color);
  const CGFloat accuracy = 0.0001;
  XCTAssertEqualWithAccuracy(red, platformColor.red, accuracy);
  XCTAssertEqualWithAccuracy(green, platformColor.green, accuracy);
  XCTAssertEqualWithAccuracy(blue, platformColor.blue, accuracy);
  XCTAssertEqualWithAccuracy(alpha, platformColor.alpha, accuracy);
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
  // GMSCameraUpdate is not inspectable, so this test just ensures that the codepath
  // doesn't throw. FGMGetCameraUpdateForPigeonCameraUpdate is simple enough that
  // injecting a wrapper would not meaningfully improve test coverage, since the non-test
  // implementation would be about as complex as the conversion function itself.
}

- (void)testCameraUpdateFromNewLatLong {
  const CGFloat lat = 1;
  const CGFloat lng = 2;
  FGMPlatformCameraUpdateNewLatLng *platformUpdate = [FGMPlatformCameraUpdateNewLatLng
      makeWithLatLng:[FGMPlatformLatLng makeWithLatitude:lat longitude:lng]];

  FGMGetCameraUpdateForPigeonCameraUpdate(
      [FGMPlatformCameraUpdate makeWithCameraUpdate:platformUpdate]);
  // GMSCameraUpdate is not inspectable, so this test just ensures that the codepath
  // doesn't throw. FGMGetCameraUpdateForPigeonCameraUpdate is simple enough that
  // injecting a wrapper would not meaningfully improve test coverage, since the non-test
  // implementation would be about as complex as the conversion function itself.
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
  FGMGetCameraUpdateForPigeonCameraUpdate(
      [FGMPlatformCameraUpdate makeWithCameraUpdate:platformUpdate]);
  // GMSCameraUpdate is not inspectable, so this test just ensures that the codepath
  // doesn't throw. FGMGetCameraUpdateForPigeonCameraUpdate is simple enough that
  // injecting a wrapper would not meaningfully improve test coverage, since the non-test
  // implementation would be about as complex as the conversion function itself.
}

- (void)testCameraUpdateFromNewLatLngZoom {
  const CGFloat lat = 1;
  const CGFloat lng = 2;
  const CGFloat zoom = 3;
  FGMPlatformCameraUpdateNewLatLngZoom *platformUpdate = [FGMPlatformCameraUpdateNewLatLngZoom
      makeWithLatLng:[FGMPlatformLatLng makeWithLatitude:lat longitude:lng]
                zoom:zoom];

  FGMGetCameraUpdateForPigeonCameraUpdate(
      [FGMPlatformCameraUpdate makeWithCameraUpdate:platformUpdate]);
  // GMSCameraUpdate is not inspectable, so this test just ensures that the codepath
  // doesn't throw. FGMGetCameraUpdateForPigeonCameraUpdate is simple enough that
  // injecting a wrapper would not meaningfully improve test coverage, since the non-test
  // implementation would be about as complex as the conversion function itself.
}

- (void)testCameraUpdateFromScrollBy {
  const CGFloat x = 1;
  const CGFloat y = 2;
  FGMPlatformCameraUpdateScrollBy *platformUpdate = [FGMPlatformCameraUpdateScrollBy makeWithDx:x
                                                                                             dy:y];

  FGMGetCameraUpdateForPigeonCameraUpdate(
      [FGMPlatformCameraUpdate makeWithCameraUpdate:platformUpdate]);
  // GMSCameraUpdate is not inspectable, so this test just ensures that the codepath
  // doesn't throw. FGMGetCameraUpdateForPigeonCameraUpdate is simple enough that
  // injecting a wrapper would not meaningfully improve test coverage, since the non-test
  // implementation would be about as complex as the conversion function itself.
}

- (void)testCameraUpdateFromZoomBy {
  const CGFloat zoom = 1;
  FGMPlatformCameraUpdateZoomBy *platformUpdateNoPoint =
      [FGMPlatformCameraUpdateZoomBy makeWithAmount:zoom focus:nil];

  FGMGetCameraUpdateForPigeonCameraUpdate(
      [FGMPlatformCameraUpdate makeWithCameraUpdate:platformUpdateNoPoint]);
  // GMSCameraUpdate is not inspectable, so this test just ensures that the codepath
  // doesn't throw. FGMGetCameraUpdateForPigeonCameraUpdate is simple enough that
  // injecting a wrapper would not meaningfully improve test coverage, since the non-test
  // implementation would be about as complex as the conversion function itself.
}

- (void)testCameraUpdateFromZoomByWithFocus {
  const CGFloat zoom = 1;
  const CGFloat x = 2;
  const CGFloat y = 3;
  FGMPlatformCameraUpdateZoomBy *platformUpdate =
      [FGMPlatformCameraUpdateZoomBy makeWithAmount:zoom focus:[FGMPlatformPoint makeWithX:x y:y]];

  FGMGetCameraUpdateForPigeonCameraUpdate(
      [FGMPlatformCameraUpdate makeWithCameraUpdate:platformUpdate]);
  // GMSCameraUpdate is not inspectable, so this test just ensures that the codepath
  // doesn't throw. FGMGetCameraUpdateForPigeonCameraUpdate is simple enough that
  // injecting a wrapper would not meaningfully improve test coverage, since the non-test
  // implementation would be about as complex as the conversion function itself.
}

- (void)testCameraUpdateFromZoomIn {
  FGMPlatformCameraUpdateZoom *platformUpdate = [FGMPlatformCameraUpdateZoom makeWithOut:NO];

  FGMGetCameraUpdateForPigeonCameraUpdate(
      [FGMPlatformCameraUpdate makeWithCameraUpdate:platformUpdate]);
  // GMSCameraUpdate is not inspectable, so this test just ensures that the codepath
  // doesn't throw. FGMGetCameraUpdateForPigeonCameraUpdate is simple enough that
  // injecting a wrapper would not meaningfully improve test coverage, since the non-test
  // implementation would be about as complex as the conversion function itself.
}

- (void)testCameraUpdateFromZoomOut {
  FGMPlatformCameraUpdateZoom *platformUpdate = [FGMPlatformCameraUpdateZoom makeWithOut:YES];

  FGMGetCameraUpdateForPigeonCameraUpdate(
      [FGMPlatformCameraUpdate makeWithCameraUpdate:platformUpdate]);
  // GMSCameraUpdate is not inspectable, so this test just ensures that the codepath
  // doesn't throw. FGMGetCameraUpdateForPigeonCameraUpdate is simple enough that
  // injecting a wrapper would not meaningfully improve test coverage, since the non-test
  // implementation would be about as complex as the conversion function itself.
}

- (void)testCameraUpdateFromZoomTo {
  const CGFloat zoom = 1;
  FGMPlatformCameraUpdateZoomTo *platformUpdate = [FGMPlatformCameraUpdateZoomTo makeWithZoom:zoom];

  FGMGetCameraUpdateForPigeonCameraUpdate(
      [FGMPlatformCameraUpdate makeWithCameraUpdate:platformUpdate]);
  // GMSCameraUpdate is not inspectable, so this test just ensures that the codepath
  // doesn't throw. FGMGetCameraUpdateForPigeonCameraUpdate is simple enough that
  // injecting a wrapper would not meaningfully improve test coverage, since the non-test
  // implementation would be about as complex as the conversion function itself.
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

- (void)testWeightedDataFromPlatformWeightedData {
  CGFloat intensity1 = 3.0;
  CGFloat intensity2 = 6.0;
  NSArray<FGMPlatformWeightedLatLng *> *data = @[
    [FGMPlatformWeightedLatLng makeWithPoint:[FGMPlatformLatLng makeWithLatitude:10 longitude:20]
                                      weight:intensity1],
    [FGMPlatformWeightedLatLng makeWithPoint:[FGMPlatformLatLng makeWithLatitude:30 longitude:40]
                                      weight:intensity2],
  ];

  NSArray<GMUWeightedLatLng *> *weightedData = FGMGetWeightedDataForPigeonWeightedData(data);
  XCTAssertEqual([weightedData[0] intensity], intensity1);
  XCTAssertEqual([weightedData[1] intensity], intensity2);
}

- (void)testGradientFromPlatformGradient {
  CGFloat startPoint = 0.6;
  CGFloat platformRed = 0.1;
  CGFloat platformGreen = 0.2;
  CGFloat platformBlue = 0.3;
  CGFloat platformAlpha = 0.4;
  NSInteger colorMapSize = 200;
  FGMPlatformHeatmapGradient *platformGradient =
      [FGMPlatformHeatmapGradient makeWithColors:@[ [FGMPlatformColor makeWithRed:platformRed
                                                                            green:platformGreen
                                                                             blue:platformBlue
                                                                            alpha:platformAlpha] ]
                                     startPoints:@[ @(startPoint) ]
                                    colorMapSize:colorMapSize];

  GMUGradient *gradient = FGMGetGradientForPigeonHeatmapGradient(platformGradient);
  CGFloat red, green, blue, alpha;
  [[gradient colors][0] getRed:&red green:&green blue:&blue alpha:&alpha];
  const CGFloat accuracy = 0.001;
  XCTAssertEqualWithAccuracy(red, platformRed, accuracy);
  XCTAssertEqualWithAccuracy(green, platformGreen, accuracy);
  XCTAssertEqualWithAccuracy(blue, platformBlue, accuracy);
  XCTAssertEqualWithAccuracy(alpha, platformAlpha, accuracy);
  XCTAssertEqualWithAccuracy([[gradient startPoints][0] doubleValue], startPoint, accuracy);
  XCTAssertEqual([gradient mapSize], colorMapSize);
}

@end
