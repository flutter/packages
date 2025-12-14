// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import google_maps_flutter_ios;
@import google_maps_flutter_ios.Test;
@import XCTest;
@import GoogleMaps;

#import "PartiallyMockedMapView.h"

/// A GMSCircle that ensures that property updates are made before the map is set.
@interface PropertyOrderValidatingCircle : GMSCircle {
}
@property(nonatomic) BOOL hasSetMap;
@end

@interface GoogleMapsCircleControllerTests : XCTestCase
@end

@implementation GoogleMapsCircleControllerTests

- (void)testUpdateCircleSetsVisibilityLast {
  PropertyOrderValidatingCircle *circle = [[PropertyOrderValidatingCircle alloc] init];
  [FLTGoogleMapCircleController
            updateCircle:circle
      fromPlatformCircle:[FGMPlatformCircle
                             makeWithConsumeTapEvents:NO
                                            fillColor:[FGMPlatformColor makeWithRed:0
                                                                              green:0
                                                                               blue:0
                                                                              alpha:0]
                                          strokeColor:[FGMPlatformColor makeWithRed:0
                                                                              green:0
                                                                               blue:0
                                                                              alpha:0]
                                              visible:YES
                                          strokeWidth:0
                                               zIndex:0
                                               center:[FGMPlatformLatLng makeWithLatitude:0
                                                                                longitude:0]
                                               radius:10
                                             circleId:@"circle"]
             withMapView:[GoogleMapsCircleControllerTests mapView]];
  XCTAssertTrue(circle.hasSetMap);
}

/// Returns a simple map view to add map objects to.
+ (GMSMapView *)mapView {
  GMSMapViewOptions *mapViewOptions = [[GMSMapViewOptions alloc] init];
  mapViewOptions.frame = CGRectMake(0, 0, 100, 100);
  mapViewOptions.camera = [[GMSCameraPosition alloc] initWithLatitude:0 longitude:0 zoom:0];
  return [[PartiallyMockedMapView alloc] initWithOptions:mapViewOptions];
}

@end

@implementation PropertyOrderValidatingCircle
- (void)setPosition:(CLLocationCoordinate2D)position {
  XCTAssertFalse(self.hasSetMap, @"Property set after map was set.");
  super.position = position;
}

- (void)setRadius:(CLLocationDistance)radius {
  XCTAssertFalse(self.hasSetMap, @"Property set after map was set.");
  super.radius = radius;
}

- (void)setStrokeWidth:(CGFloat)strokeWidth {
  XCTAssertFalse(self.hasSetMap, @"Property set after map was set.");
  super.strokeWidth = strokeWidth;
}

- (void)setStrokeColor:(UIColor *)strokeColor {
  XCTAssertFalse(self.hasSetMap, @"Property set after map was set.");
  super.strokeColor = strokeColor;
}

- (void)setFillColor:(UIColor *)fillColor {
  XCTAssertFalse(self.hasSetMap, @"Property set after map was set.");
  super.fillColor = fillColor;
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

- (void)setMap:(GMSMapView *)map {
  // Don't actually set the map, since that requires more test setup.
  if (map) {
    self.hasSetMap = YES;
  }
}
@end
