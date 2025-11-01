// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import google_maps_flutter_ios;
@import google_maps_flutter_ios.Test;
@import XCTest;
@import GoogleMaps;
@import GoogleMapsUtils;

#import "PartiallyMockedMapView.h"

@interface PropertyOrderValidatingHeatmap : GMUHeatmapTileLayer {
}
@property(nonatomic) BOOL hasSetMap;
@end

@interface GoogleMapsHeatmapControllerTests : XCTestCase
@end

@implementation GoogleMapsHeatmapControllerTests

- (void)testUpdateHeatmapSetsVisibilityLast {
  PropertyOrderValidatingHeatmap *heatmap = [[PropertyOrderValidatingHeatmap alloc] init];
  [FLTGoogleMapHeatmapController
      updateHeatmap:heatmap
        fromOptions:@{
          @"data" : @[ @[ @[ @(5), @(5) ], @(0.5) ], @[ @[ @(10), @(10) ], @(0.75) ] ],
          @"gradient" : @{
            @"colors" : @[ @(0), @(1) ],
            @"startPoints" : @[ @(0), @(1) ],
            @"colorMapSize" : @(256),
          },
          @"opacity" : @(0.5),
          @"radius" : @(1),
          @"minimumZoomIntensity" : @(1),
          @"maximumZoomIntensity" : @(2),
        }
        withMapView:[GoogleMapsHeatmapControllerTests mapView]];
  XCTAssertTrue(heatmap.hasSetMap);
}

/// Returns a simple map view to add map objects to.
+ (GMSMapView *)mapView {
  GMSMapViewOptions *mapViewOptions = [[GMSMapViewOptions alloc] init];
  mapViewOptions.frame = CGRectMake(0, 0, 100, 100);
  mapViewOptions.camera = [[GMSCameraPosition alloc] initWithLatitude:0 longitude:0 zoom:0];
  return [[PartiallyMockedMapView alloc] initWithOptions:mapViewOptions];
}

@end

@implementation PropertyOrderValidatingHeatmap

- (void)setWeightedData:(NSArray<GMUWeightedLatLng *> *)weightedData {
  XCTAssertFalse(self.hasSetMap, @"Property set after map was set.");
  super.weightedData = weightedData;
}

- (void)setRadius:(NSUInteger)radius {
  XCTAssertFalse(self.hasSetMap, @"Property set after map was set.");
  super.radius = radius;
}

- (void)setGradient:(GMUGradient *)gradient {
  XCTAssertFalse(self.hasSetMap, @"Property set after map was set.");
  super.gradient = gradient;
}

- (void)setMinimumZoomIntensity:(NSUInteger)minimumZoomIntensity {
  XCTAssertFalse(self.hasSetMap, @"Property set after map was set.");
  super.minimumZoomIntensity = minimumZoomIntensity;
}

- (void)setMaximumZoomIntensity:(NSUInteger)maximumZoomIntensity {
  XCTAssertFalse(self.hasSetMap, @"Property set after map was set.");
  super.maximumZoomIntensity = maximumZoomIntensity;
}

- (void)setZIndex:(int)zIndex {
  XCTAssertFalse(self.hasSetMap, @"Property set after map was set.");
  super.zIndex = zIndex;
}

- (void)setTileSize:(NSInteger)tileSize {
  XCTAssertFalse(self.hasSetMap, @"Property set after map was set.");
  super.tileSize = tileSize;
}

- (void)setOpacity:(float)opacity {
  XCTAssertFalse(self.hasSetMap, @"Property set after map was set.");
  super.opacity = opacity;
}

- (void)setFadeIn:(BOOL)fadeIn {
  XCTAssertFalse(self.hasSetMap, @"Property set after map was set.");
  super.fadeIn = fadeIn;
}

- (void)setMap:(GMSMapView *)map {
  // Don't actually set the map, since that requires more test setup.
  if (map) {
    self.hasSetMap = YES;
  }
}
@end
