// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import google_maps_flutter_ios;
@import google_maps_flutter_ios.Test;
@import XCTest;
@import MapKit;
@import GoogleMaps;

#import <OCMock/OCMock.h>
#import "PartiallyMockedCircle.h"
#import "PartiallyMockedMapView.h"
#import "PartiallyMockedMarker.h"
#import "PartiallyMockedPolygon.h"
#import "PartiallyMockedPolyline.h"
#import "PartiallyMockedTileLayer.h"

@interface GoogleMapsCallOrderTests : XCTestCase
@end

@interface FLTGoogleMapMarkerController (Tests)
- (void)interpretMarkerOptions:(NSDictionary *)data
                     registrar:(NSObject<FlutterPluginRegistrar> *)registrar
                   screenScale:(CGFloat)screenScale;
@end

@interface FLTGoogleMapPolygonController (Tests)
- (void)interpretPolygonOptions:(NSDictionary *)data
                      registrar:(NSObject<FlutterPluginRegistrar> *)registrar;
@end

@interface FLTGoogleMapPolylineController (Tests)
- (void)interpretPolylineOptions:(NSDictionary *)data
                       registrar:(NSObject<FlutterPluginRegistrar> *)registrar;
@end

@interface FLTGoogleMapCircleController (Tests)
- (void)interpretCircleOptions:(NSDictionary *)data;
@end

@interface FLTGoogleMapTileOverlayController (Tests)
- (void)interpretTileOverlayOptions:(NSDictionary *)data;
@end

@implementation GoogleMapsCallOrderTests

- (void)testMarker {
  PartiallyMockedMarker *marker =
      [PartiallyMockedMarker markerWithPosition:CLLocationCoordinate2DMake(0, 0)];

  NSDictionary *assetData =
      @{@"assetName" : @"fakeImageNameKey", @"bitmapScaling" : @"auto", @"imagePixelRatio" : @1};
  NSArray *iconData = @[ @"asset", assetData ];
  NSDictionary *options = @{
    @"alpha" : @1,
    @"anchor" : @[ @0.5, @1 ],
    @"draggable" : @0,
    @"icon" : iconData,
    @"flat" : @0,
    @"infoWindow" : @{
      @"title" : @"TestTitle",
      @"snippet" : @"TestSnippet",
      @"infoWindowAnchor" : @[ @0, @0 ],
    },
    @"position" : @[ @0, @0 ],
    @"rotation" : @0,
    @"zIndex" : @0,
    @"visible" : @1,
  };

  CGRect frame = CGRectMake(0, 0, 100, 100);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
  // TODO(stuartmorgan): Switch to initWithOptions: once we can guarantee we will be using SDK 8.3+.
  // That API was only added in 8.3, and Cocoapod caches on some machines may not be up-to-date
  // enough to resolve to that yet even when targeting iOS 14+.
  PartiallyMockedMapView *mapView = [[PartiallyMockedMapView alloc]
      initWithFrame:frame
             camera:[[GMSCameraPosition alloc] initWithLatitude:0 longitude:0 zoom:0]];
#pragma clang diagnostic pop

  NSString *identifier = @"TestMarker";
  FLTGoogleMapMarkerController *controller =
      [[FLTGoogleMapMarkerController alloc] initWithMarker:marker
                                                identifier:identifier
                                                   mapView:mapView];
  id registrar = OCMProtocolMock(@protocol(FlutterPluginRegistrar));
  CGFloat screenScale = mapView.traitCollection.displayScale;
  [controller interpretMarkerOptions:options registrar:registrar screenScale:screenScale];

  XCTAssert(marker.isOrderCorrect);
}

- (void)testPolygon {
  GMSMutablePath *path = [GMSMutablePath path];
  [path addCoordinate:CLLocationCoordinate2DMake(0, 0)];
  [path addCoordinate:CLLocationCoordinate2DMake(1, 0)];
  [path addCoordinate:CLLocationCoordinate2DMake(1, 1)];

  PartiallyMockedPolygon *polygon = [PartiallyMockedPolygon polygonWithPath:path];

  NSDictionary *options = @{
    @"consumeTapEvents" : @0,
    @"zIndex" : @0,
    @"points" : @[ @[ @0, @0 ], @[ @1, @0 ], @[ @1, @1 ] ],
    @"holes" : @[],
    @"fillColor" : @0x000000,
    @"strokeColor" : @0x000000,
    @"strokeWidth" : @1,
    @"visible" : @1,
  };

  CGRect frame = CGRectMake(0, 0, 100, 100);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
  // TODO(stuartmorgan): Switch to initWithOptions: once we can guarantee we will be using SDK 8.3+.
  // That API was only added in 8.3, and Cocoapod caches on some machines may not be up-to-date
  // enough to resolve to that yet even when targeting iOS 14+.
  PartiallyMockedMapView *mapView = [[PartiallyMockedMapView alloc]
      initWithFrame:frame
             camera:[[GMSCameraPosition alloc] initWithLatitude:0 longitude:0 zoom:0]];
#pragma clang diagnostic pop

  NSString *identifier = @"TestPolygon";
  FLTGoogleMapPolygonController *controller =
      [[FLTGoogleMapPolygonController alloc] initWithPolygon:polygon
                                                  identifier:identifier
                                                     mapView:mapView];
  id registrar = OCMProtocolMock(@protocol(FlutterPluginRegistrar));
  [controller interpretPolygonOptions:options registrar:registrar];

  XCTAssert(polygon.isOrderCorrect);
}

- (void)testPolyline {
  GMSMutablePath *path = [GMSMutablePath path];
  [path addCoordinate:CLLocationCoordinate2DMake(0, 0)];
  [path addCoordinate:CLLocationCoordinate2DMake(1, 0)];
  [path addCoordinate:CLLocationCoordinate2DMake(1, 1)];

  PartiallyMockedPolyline *polyline = [PartiallyMockedPolyline polylineWithPath:path];

  NSDictionary *options = @{
    @"consumeTapEvents" : @0,
    @"zIndex" : @0,
    @"points" : @[ @[ @0, @0 ], @[ @1, @0 ], @[ @1, @1 ] ],
    @"color" : @0x000000,
    @"width" : @1,
    @"geodesic" : @0,
    @"pattern" : @[ @[ @"dot", @1 ], @[ @"gap", @1 ] ],
    @"visible" : @1,
  };

  CGRect frame = CGRectMake(0, 0, 100, 100);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
  // TODO(stuartmorgan): Switch to initWithOptions: once we can guarantee we will be using SDK 8.3+.
  // That API was only added in 8.3, and Cocoapod caches on some machines may not be up-to-date
  // enough to resolve to that yet even when targeting iOS 14+.
  PartiallyMockedMapView *mapView = [[PartiallyMockedMapView alloc]
      initWithFrame:frame
             camera:[[GMSCameraPosition alloc] initWithLatitude:0 longitude:0 zoom:0]];
#pragma clang diagnostic pop

  NSString *identifier = @"TestPolyline";
  FLTGoogleMapPolylineController *controller =
      [[FLTGoogleMapPolylineController alloc] initWithPolyline:polyline
                                                    identifier:identifier
                                                       mapView:mapView];
  id registrar = OCMProtocolMock(@protocol(FlutterPluginRegistrar));
  [controller interpretPolylineOptions:options registrar:registrar];

  XCTAssert(polyline.isOrderCorrect);
}

- (void)testCircle {
  PartiallyMockedCircle *circle =
      [PartiallyMockedCircle circleWithPosition:CLLocationCoordinate2DMake(0, 0) radius:1.0];

  NSDictionary *options = @{
    @"consumeTapEvents" : @0,
    @"zIndex" : @0,
    @"center" : @[ @0, @0 ],
    @"radius" : @0,
    @"strokeColor" : @0x000000,
    @"strokeWidth" : @1,
    @"fillColor" : @0x000000,
    @"visible" : @1,
  };

  CGRect frame = CGRectMake(0, 0, 100, 100);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
  // TODO(stuartmorgan): Switch to initWithOptions: once we can guarantee we will be using SDK 8.3+.
  // That API was only added in 8.3, and Cocoapod caches on some machines may not be up-to-date
  // enough to resolve to that yet even when targeting iOS 14+.
  PartiallyMockedMapView *mapView = [[PartiallyMockedMapView alloc]
      initWithFrame:frame
             camera:[[GMSCameraPosition alloc] initWithLatitude:0 longitude:0 zoom:0]];
#pragma clang diagnostic pop

  NSString *identifier = @"TestCircle";
  FLTGoogleMapCircleController *controller =
      [[FLTGoogleMapCircleController alloc] initWithCircle:circle
                                                  circleId:identifier
                                                   mapView:mapView
                                                   options:options];
  [controller interpretCircleOptions:options];

  XCTAssert(circle.isOrderCorrect);
}

- (void)testTileOverlay {
  PartiallyMockedTileLayer *tileLayer = [PartiallyMockedTileLayer alloc];

  NSDictionary *options = @{
    @"transparency" : @0,
    @"zIndex" : @0,
    @"fadeIn" : @0,
    @"tileSize" : @256,
    @"visible" : @1,
  };

  CGRect frame = CGRectMake(0, 0, 100, 100);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
  // TODO(stuartmorgan): Switch to initWithOptions: once we can guarantee we will be using SDK 8.3+.
  // That API was only added in 8.3, and Cocoapod caches on some machines may not be up-to-date
  // enough to resolve to that yet even when targeting iOS 14+.
  PartiallyMockedMapView *mapView = [[PartiallyMockedMapView alloc]
      initWithFrame:frame
             camera:[[GMSCameraPosition alloc] initWithLatitude:0 longitude:0 zoom:0]];
#pragma clang diagnostic pop

  FLTGoogleMapTileOverlayController *controller =
      [[FLTGoogleMapTileOverlayController alloc] initWithTileLayer:tileLayer
                                                           mapView:mapView
                                                           options:options];

  [controller interpretTileOverlayOptions:options];

  XCTAssert(tileLayer.isOrderCorrect);
}

@end
