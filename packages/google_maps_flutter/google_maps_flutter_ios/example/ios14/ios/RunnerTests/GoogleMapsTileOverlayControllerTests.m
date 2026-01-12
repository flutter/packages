// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import google_maps_flutter_ios;
@import google_maps_flutter_ios.Test;
@import XCTest;
@import GoogleMaps;

#import "PartiallyMockedMapView.h"

/// A GMSTileOverlay that ensures that property updates are made before the map is set.
@interface PropertyOrderValidatingTileLayer : GMSTileLayer
@property(nonatomic) BOOL hasSetMap;
@end

@interface GoogleMapsTileOverlayControllerTests : XCTestCase
@end

@implementation GoogleMapsTileOverlayControllerTests

- (void)testUpdateTileOverlaySetsVisibilityLast {
  PropertyOrderValidatingTileLayer *tileLayer = [[PropertyOrderValidatingTileLayer alloc] init];
  [FLTGoogleMapTileOverlayController
              updateTileLayer:tileLayer
      fromPlatformTileOverlay:[FGMPlatformTileOverlay makeWithTileOverlayId:@"overlay"
                                                                     fadeIn:NO
                                                               transparency:0.5
                                                                     zIndex:0
                                                                    visible:YES
                                                                   tileSize:1]
                  withMapView:[GoogleMapsTileOverlayControllerTests mapView]];
  XCTAssertTrue(tileLayer.hasSetMap);
}

/// Returns a simple map view to add map objects to.
+ (GMSMapView *)mapView {
  GMSMapViewOptions *mapViewOptions = [[GMSMapViewOptions alloc] init];
  mapViewOptions.frame = CGRectMake(0, 0, 100, 100);
  mapViewOptions.camera = [[GMSCameraPosition alloc] initWithLatitude:0 longitude:0 zoom:0];
  return [[PartiallyMockedMapView alloc] initWithOptions:mapViewOptions];
}

@end

@implementation PropertyOrderValidatingTileLayer

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
