// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import google_maps_flutter_ios;
@import google_maps_flutter_ios.Test;
@import XCTest;
@import GoogleMaps;

#import <OCMock/OCMock.h>
#import <google_maps_flutter_ios/FGMGroundOverlayController_Test.h>
#import <google_maps_flutter_ios/messages.g.h>
#import "PartiallyMockedMapView.h"

@interface GoogleMapsGroundOverlayControllerTests : XCTestCase
@end

@implementation GoogleMapsGroundOverlayControllerTests

/// Returns GoogleMapGroundOverlayController object instantiated with position and a mocked map
/// instance.
///
/// @return An object of FLTGoogleMapGroundOverlayController
+ (FGMGroundOverlayController *)groundOverlayControllerWithPositionWithMockedMap {
  NSString *imagePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"widegamut"
                                                                         ofType:@"png"
                                                                    inDirectory:@"assets"];
  UIImage *wideGamutImage = [UIImage imageWithContentsOfFile:imagePath];
  GMSGroundOverlay *groundOverlay =
      [GMSGroundOverlay groundOverlayWithPosition:CLLocationCoordinate2DMake(52.4816, 3.1791)
                                             icon:wideGamutImage
                                        zoomLevel:14.0];

  GMSCameraPosition *camera = [[GMSCameraPosition alloc] initWithLatitude:0 longitude:0 zoom:0];
  CGRect frame = CGRectMake(0, 0, 100, 100);
  GMSMapViewOptions *mapViewOptions = [[GMSMapViewOptions alloc] init];
  mapViewOptions.frame = frame;
  mapViewOptions.camera = camera;

  PartiallyMockedMapView *mapView = [[PartiallyMockedMapView alloc] initWithOptions:mapViewOptions];

  return [[FGMGroundOverlayController alloc] initWithGroundOverlay:groundOverlay
                                                        identifier:@"id_1"
                                                           mapView:mapView
                                               isCreatedWithBounds:NO];
}

/// Returns GoogleMapGroundOverlayController object instantiated with bounds and a mocked map
/// instance.
///
/// @return An object of FLTGoogleMapGroundOverlayController
+ (FGMGroundOverlayController *)groundOverlayControllerWithBoundsWithMockedMap {
  NSString *imagePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"widegamut"
                                                                         ofType:@"png"
                                                                    inDirectory:@"assets"];
  UIImage *wideGamutImage = [UIImage imageWithContentsOfFile:imagePath];
  GMSGroundOverlay *groundOverlay = [GMSGroundOverlay
      groundOverlayWithBounds:[[GMSCoordinateBounds alloc]
                                  initWithCoordinate:CLLocationCoordinate2DMake(10, 20)
                                          coordinate:CLLocationCoordinate2DMake(30, 40)]
                         icon:wideGamutImage];

  GMSCameraPosition *camera = [[GMSCameraPosition alloc] initWithLatitude:0 longitude:0 zoom:0];
  CGRect frame = CGRectMake(0, 0, 100, 100);
  GMSMapViewOptions *mapViewOptions = [[GMSMapViewOptions alloc] init];
  mapViewOptions.frame = frame;
  mapViewOptions.camera = camera;

  PartiallyMockedMapView *mapView = [[PartiallyMockedMapView alloc] initWithOptions:mapViewOptions];

  return [[FGMGroundOverlayController alloc] initWithGroundOverlay:groundOverlay
                                                        identifier:@"id_1"
                                                           mapView:mapView
                                               isCreatedWithBounds:YES];
}

- (void)testUpdatingGroundOverlayWithPosition {
  FGMGroundOverlayController *groundOverlayController =
      [GoogleMapsGroundOverlayControllerTests groundOverlayControllerWithPositionWithMockedMap];

  FGMPlatformLatLng *position = [FGMPlatformLatLng makeWithLatitude:52.4816 longitude:3.1791];

  FGMPlatformBitmap *bitmap =
      [FGMPlatformBitmap makeWithBitmap:[FGMPlatformBitmapDefaultMarker makeWithHue:0]];
  NSObject<FlutterPluginRegistrar> *mockRegistrar =
      OCMStrictProtocolMock(@protocol(FlutterPluginRegistrar));

  FGMPlatformGroundOverlay *platformGroundOverlay =
      [FGMPlatformGroundOverlay makeWithGroundOverlayId:@"id_1"
                                                  image:bitmap
                                               position:position
                                                 bounds:nil
                                                 anchor:[FGMPlatformPoint makeWithX:0.5 y:0.5]
                                           transparency:0.5
                                                bearing:65.0
                                                 zIndex:2.0
                                                visible:true
                                              clickable:true
                                              zoomLevel:@14.0];

  [groundOverlayController updateFromPlatformGroundOverlay:platformGroundOverlay
                                                 registrar:mockRegistrar
                                               screenScale:1.0];

  XCTAssertNotNil(groundOverlayController.groundOverlay.icon);
  XCTAssertEqualWithAccuracy(groundOverlayController.groundOverlay.position.latitude,
                             position.latitude, DBL_EPSILON);
  XCTAssertEqualWithAccuracy(groundOverlayController.groundOverlay.position.longitude,
                             position.longitude, DBL_EPSILON);
  XCTAssertEqual(groundOverlayController.groundOverlay.opacity, platformGroundOverlay.transparency);
  XCTAssertEqual(groundOverlayController.groundOverlay.bearing, platformGroundOverlay.bearing);
  XCTAssertEqualWithAccuracy(groundOverlayController.groundOverlay.anchor.x, 0.5, DBL_EPSILON);
  XCTAssertEqualWithAccuracy(groundOverlayController.groundOverlay.anchor.y, 0.5, DBL_EPSILON);
  XCTAssertEqual(groundOverlayController.groundOverlay.zIndex, platformGroundOverlay.zIndex);

  FGMPlatformGroundOverlay *convertedPlatformGroundOverlay =
      FGMGetPigeonGroundOverlay(groundOverlayController.groundOverlay, @"id_1", NO, @14.0);
  XCTAssertEqualObjects(convertedPlatformGroundOverlay.groundOverlayId, @"id_1");
  XCTAssertEqualWithAccuracy(convertedPlatformGroundOverlay.position.latitude, position.latitude,
                             DBL_EPSILON);
  XCTAssertEqualWithAccuracy(convertedPlatformGroundOverlay.position.longitude, position.longitude,
                             DBL_EPSILON);
  XCTAssertEqual(convertedPlatformGroundOverlay.zoomLevel.doubleValue, 14.0);
  XCTAssertEqual(convertedPlatformGroundOverlay.transparency, platformGroundOverlay.transparency);
  XCTAssertEqual(convertedPlatformGroundOverlay.bearing, platformGroundOverlay.bearing);
  XCTAssertEqualWithAccuracy(convertedPlatformGroundOverlay.anchor.x, 0.5, DBL_EPSILON);
  XCTAssertEqualWithAccuracy(convertedPlatformGroundOverlay.anchor.y, 0.5, DBL_EPSILON);
  XCTAssertEqual(convertedPlatformGroundOverlay.zIndex, platformGroundOverlay.zIndex);
}

- (void)testUpdatingGroundOverlayWithBounds {
  FGMGroundOverlayController *groundOverlayController =
      [GoogleMapsGroundOverlayControllerTests groundOverlayControllerWithBoundsWithMockedMap];

  FGMPlatformLatLngBounds *bounds = [FGMPlatformLatLngBounds
      makeWithNortheast:[FGMPlatformLatLng makeWithLatitude:54.4816 longitude:5.1791]
              southwest:[FGMPlatformLatLng makeWithLatitude:52.4816 longitude:3.1791]];

  FGMPlatformBitmap *bitmap =
      [FGMPlatformBitmap makeWithBitmap:[FGMPlatformBitmapDefaultMarker makeWithHue:0]];
  NSObject<FlutterPluginRegistrar> *mockRegistrar =
      OCMStrictProtocolMock(@protocol(FlutterPluginRegistrar));

  FGMPlatformGroundOverlay *platformGroundOverlay =
      [FGMPlatformGroundOverlay makeWithGroundOverlayId:@"id_1"
                                                  image:bitmap
                                               position:nil
                                                 bounds:bounds
                                                 anchor:[FGMPlatformPoint makeWithX:0.5 y:0.5]
                                           transparency:0.5
                                                bearing:65.0
                                                 zIndex:2.0
                                                visible:true
                                              clickable:true
                                              zoomLevel:nil];

  [groundOverlayController updateFromPlatformGroundOverlay:platformGroundOverlay
                                                 registrar:mockRegistrar
                                               screenScale:1.0];

  XCTAssertNotNil(groundOverlayController.groundOverlay.icon);
  XCTAssertEqualWithAccuracy(groundOverlayController.groundOverlay.bounds.northEast.latitude,
                             bounds.northeast.latitude, DBL_EPSILON);
  XCTAssertEqualWithAccuracy(groundOverlayController.groundOverlay.bounds.northEast.longitude,
                             bounds.northeast.longitude, DBL_EPSILON);
  XCTAssertEqualWithAccuracy(groundOverlayController.groundOverlay.bounds.southWest.latitude,
                             bounds.southwest.latitude, DBL_EPSILON);
  XCTAssertEqualWithAccuracy(groundOverlayController.groundOverlay.bounds.southWest.longitude,
                             bounds.southwest.longitude, DBL_EPSILON);
  XCTAssertEqual(groundOverlayController.groundOverlay.opacity, platformGroundOverlay.transparency);
  XCTAssertEqual(groundOverlayController.groundOverlay.bearing, platformGroundOverlay.bearing);
  XCTAssertEqualWithAccuracy(groundOverlayController.groundOverlay.anchor.x, 0.5, DBL_EPSILON);
  XCTAssertEqualWithAccuracy(groundOverlayController.groundOverlay.anchor.y, 0.5, DBL_EPSILON);
  XCTAssertEqual(groundOverlayController.groundOverlay.zIndex, platformGroundOverlay.zIndex);

  FGMPlatformGroundOverlay *convertedPlatformGroundOverlay =
      FGMGetPigeonGroundOverlay(groundOverlayController.groundOverlay, @"id_1", YES, nil);
  XCTAssertEqualObjects(convertedPlatformGroundOverlay.groundOverlayId, @"id_1");
  XCTAssertEqualWithAccuracy(convertedPlatformGroundOverlay.bounds.northeast.latitude,
                             bounds.northeast.latitude, DBL_EPSILON);
  XCTAssertEqualWithAccuracy(convertedPlatformGroundOverlay.bounds.northeast.longitude,
                             bounds.northeast.longitude, DBL_EPSILON);
  XCTAssertEqualWithAccuracy(convertedPlatformGroundOverlay.bounds.southwest.latitude,
                             bounds.southwest.latitude, DBL_EPSILON);
  XCTAssertEqualWithAccuracy(convertedPlatformGroundOverlay.bounds.southwest.longitude,
                             bounds.southwest.longitude, DBL_EPSILON);
  XCTAssertEqual(convertedPlatformGroundOverlay.transparency, platformGroundOverlay.transparency);
  XCTAssertEqual(convertedPlatformGroundOverlay.bearing, platformGroundOverlay.bearing);
  XCTAssertEqualWithAccuracy(convertedPlatformGroundOverlay.anchor.x, 0.5, DBL_EPSILON);
  XCTAssertEqualWithAccuracy(convertedPlatformGroundOverlay.anchor.y, 0.5, DBL_EPSILON);
  XCTAssertEqual(convertedPlatformGroundOverlay.zIndex, platformGroundOverlay.zIndex);
}

@end
