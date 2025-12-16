// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import google_maps_flutter_ios;
@import google_maps_flutter_ios.Test;
@import XCTest;
@import GoogleMaps;

/// A GMSPolygon that ensures that property updates are made before the map is set.
@interface PropertyOrderValidatingPolygon : GMSPolygon {
}
@property(nonatomic) BOOL hasSetMap;
@end

@interface GoogleMapsPolygonControllerTests : XCTestCase
@end

@implementation GoogleMapsPolygonControllerTests

- (void)testUpdatePolygonSetsVisibilityLast {
  PropertyOrderValidatingPolygon *polygon = [[PropertyOrderValidatingPolygon alloc] init];
  [FLTGoogleMapPolygonController
            updatePolygon:polygon
      fromPlatformPolygon:[FGMPlatformPolygon
                              makeWithConsumeTapEvents:NO
                                             fillColor:[FGMPlatformColor makeWithRed:0
                                                                               green:0
                                                                                blue:0
                                                                               alpha:0]
                                              geodesic:NO
                                                 holes:@[]
                                           strokeColor:[FGMPlatformColor makeWithRed:0
                                                                               green:0
                                                                                blue:0
                                                                               alpha:0]
                                           strokeWidth:0
                                               visible:YES
                                                zIndex:0
                                                points:@[]
                                             polygonId:@"polygon"]
              withMapView:[GoogleMapsPolygonControllerTests mapView]];
  XCTAssertTrue(polygon.hasSetMap);
}

/// Returns a simple map view to add map objects to.
+ (GMSMapView *)mapView {
  GMSMapViewOptions *mapViewOptions = [[GMSMapViewOptions alloc] init];
  mapViewOptions.frame = CGRectMake(0, 0, 100, 100);
  mapViewOptions.camera = [[GMSCameraPosition alloc] initWithLatitude:0 longitude:0 zoom:0];
  return [[PartiallyMockedMapView alloc] initWithOptions:mapViewOptions];
}

@end

@implementation PropertyOrderValidatingPolygon
- (void)setPath:(GMSPath *)path {
  XCTAssertFalse(self.hasSetMap, @"Property set after map was set.");
  super.path = path;
}

- (void)setHoles:(NSArray<GMSPath *> *)holes {
  XCTAssertFalse(self.hasSetMap, @"Property set after map was set.");
  super.holes = holes;
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
