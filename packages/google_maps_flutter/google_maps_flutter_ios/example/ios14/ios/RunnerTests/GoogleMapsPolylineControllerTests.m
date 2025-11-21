// Copyright 2013 The Flutter Authors
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

/// A GMSPolyline that ensures that property updates are made before the map is set.
@interface PropertyOrderValidatingPolyline : GMSPolyline {
}
@property(nonatomic) BOOL hasSetMap;
@end

@interface GoogleMapsPolylineControllerTests : XCTestCase
@end

@implementation GoogleMapsPolylineControllerTests

/// Returns GoogleMapPolylineController object instantiated with a mocked map instance
///
///  @return An object of FLTGoogleMapPolylineController
- (FLTGoogleMapPolylineController *)polylineControllerWithMockedMap {
  FGMPlatformPolyline *polyline = [FGMPlatformPolyline
      makeWithPolylineId:@"polyline_id_0"
       consumesTapEvents:NO
                   color:[FGMPlatformColor makeWithRed:0 green:0 blue:0 alpha:0]
                geodesic:NO
               jointType:FGMPlatformJointTypeRound
                patterns:@[]
                  points:[GoogleMapsPolylineControllerTests polylinePoints]
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

- (void)testPatternsSetSpans {
  FLTGoogleMapPolylineController *polylineController = [self polylineControllerWithMockedMap];

  XCTAssertNil(polylineController.polyline.spans);

  [polylineController
      updateFromPlatformPolyline:[FGMPlatformPolyline
                                     makeWithPolylineId:@"polyline_id_0"
                                      consumesTapEvents:NO
                                                  color:[FGMPlatformColor makeWithRed:0
                                                                                green:0
                                                                                 blue:0
                                                                                alpha:0]
                                               geodesic:NO
                                              jointType:FGMPlatformJointTypeRound
                                               patterns:@[
                                                 [FGMPlatformPatternItem
                                                     makeWithType:FGMPlatformPatternItemTypeDot
                                                           length:@(10)],
                                                 [FGMPlatformPatternItem
                                                     makeWithType:FGMPlatformPatternItemTypeDash
                                                           length:@(10)]
                                               ]
                                                 points:[GoogleMapsPolylineControllerTests
                                                            polylinePoints]
                                                visible:YES
                                                  width:1
                                                 zIndex:0]];

  // `GMSStyleSpan` doesn't implement `isEqual` so cannot be compared by value at present.
  XCTAssertNotNil(polylineController.polyline.spans);
}

- (void)testUpdatePolylineSetsVisibilityLast {
  PropertyOrderValidatingPolyline *polyline = [[PropertyOrderValidatingPolyline alloc] init];
  [FLTGoogleMapPolylineController
            updatePolyline:polyline
      fromPlatformPolyline:[FGMPlatformPolyline
                               makeWithPolylineId:@"polyline"
                                consumesTapEvents:NO
                                            color:[FGMPlatformColor makeWithRed:0
                                                                          green:0
                                                                           blue:0
                                                                          alpha:0]
                                         geodesic:NO
                                        jointType:FGMPlatformJointTypeRound
                                         patterns:@[]
                                           points:[GoogleMapsPolylineControllerTests polylinePoints]
                                          visible:YES
                                            width:1
                                           zIndex:0]
               withMapView:[GoogleMapsPolylineControllerTests mapView]];
  XCTAssertTrue(polyline.hasSetMap);
}

/// Returns a simple map view to add map objects to.
+ (GMSMapView *)mapView {
  GMSMapViewOptions *mapViewOptions = [[GMSMapViewOptions alloc] init];
  mapViewOptions.frame = CGRectMake(0, 0, 100, 100);
  mapViewOptions.camera = [[GMSCameraPosition alloc] initWithLatitude:0 longitude:0 zoom:0];
  return [[PartiallyMockedMapView alloc] initWithOptions:mapViewOptions];
}

/// Returns a set of points to use for tests that need a valid but arbitrary line.
+ (NSArray<FGMPlatformLatLng *> *)polylinePoints {
  return @[
    [FGMPlatformLatLng makeWithLatitude:52.4816 longitude:-3.1791],
    [FGMPlatformLatLng makeWithLatitude:54.043 longitude:-2.9925],
    [FGMPlatformLatLng makeWithLatitude:54.1396 longitude:-4.2739],
    [FGMPlatformLatLng makeWithLatitude:53.4153 longitude:-4.0829],
  ];
}

@end

@implementation PropertyOrderValidatingPolyline

- (void)setPath:(GMSPath *)path {
  XCTAssertFalse(self.hasSetMap, @"Property set after map was set.");
  super.path = path;
}

- (void)setStrokeWidth:(CGFloat)strokeWidth {
  XCTAssertFalse(self.hasSetMap, @"Property set after map was set.");
  super.strokeWidth = strokeWidth;
}

- (void)setStrokeColor:(UIColor *)strokeColor {
  XCTAssertFalse(self.hasSetMap, @"Property set after map was set.");
  super.strokeColor = strokeColor;
}

- (void)setGeodesic:(BOOL)geodesic {
  XCTAssertFalse(self.hasSetMap, @"Property set after map was set.");
  super.geodesic = geodesic;
}

- (void)setTitle:(NSString *)title {
  XCTAssertFalse(self.hasSetMap, @"Property set after map was set.");
  super.title = title;
}

- (void)setTappable:(BOOL)tappable {
  XCTAssertFalse(self.hasSetMap, @"Property set after map was set.");
  super.tappable = tappable;
}

- (void)setZIndex:(int)zIndex {
  XCTAssertFalse(self.hasSetMap, @"Property set after map was set.");
  super.zIndex = zIndex;
}

- (void)setUserData:(id)userData {
  XCTAssertFalse(self.hasSetMap, @"Property set after map was set.");
  super.userData = userData;
}

- (void)setMap:(GMSMapView *)map {
  // Don't actually set the map, since that requires more test setup.
  if (map) {
    self.hasSetMap = YES;
  }
}
@end
