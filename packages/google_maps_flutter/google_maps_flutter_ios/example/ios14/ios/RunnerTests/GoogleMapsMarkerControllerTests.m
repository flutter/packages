// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import google_maps_flutter_ios;
@import google_maps_flutter_ios.Test;
@import XCTest;
@import GoogleMaps;

#import <OCMock/OCMock.h>
#import <google_maps_flutter_ios/messages.g.h>
#import "PartiallyMockedMapView.h"

@interface GoogleMapsMarkerControllerTests : XCTestCase
@end

@implementation GoogleMapsMarkerControllerTests

/// Returns a mocked map view for use with marker controllers.
- (GMSMapView *)mockedMapView {
  GMSMapViewOptions *mapViewOptions = [[GMSMapViewOptions alloc] init];
  mapViewOptions.frame = CGRectMake(0, 0, 100, 100);
  mapViewOptions.camera = [[GMSCameraPosition alloc] initWithLatitude:0 longitude:0 zoom:0];
  return [[PartiallyMockedMapView alloc] initWithOptions:mapViewOptions];
}

/// Returns a FLTMarkersController instance instantiated with the given map view.
///
/// The mapView should outlive the controller, as the controller keeps a weak reference to it.
- (FLTMarkersController *)markersControllerWithMapView:(GMSMapView *)mapView {
  NSObject<FlutterPluginRegistrar> *mockRegistrar =
      OCMStrictProtocolMock(@protocol(FlutterPluginRegistrar));
  return [[FLTMarkersController alloc] initWithMapView:mapView
                                       callbackHandler:[[FGMMapsCallbackApi alloc] init]
                             clusterManagersController:nil
                                             registrar:mockRegistrar];
}

- (FGMPlatformBitmap *)placeholderBitmap {
  return [FGMPlatformBitmap makeWithBitmap:[FGMPlatformBitmapDefaultMarker makeWithHue:@0]];
}

- (void)testSetsMarkerNumericProperties {
  GMSMapView *mapView = [self mockedMapView];
  FLTMarkersController *controller = [self markersControllerWithMapView:mapView];

  NSString *markerIdentifier = @"marker";
  double anchorX = 3.14;
  double anchorY = 2.718;
  double alpha = 0.4;
  double rotation = 90.0;
  double zIndex = 3.0;
  double latitutde = 10.0;
  double longitude = 20.0;
  [controller addMarkers:@[ [FGMPlatformMarker
                                makeWithAlpha:alpha
                                       anchor:[FGMPlatformPoint makeWithX:anchorX y:anchorY]
                             consumeTapEvents:YES
                                    draggable:YES
                                         flat:YES
                                         icon:[self placeholderBitmap]
                                   infoWindow:[FGMPlatformInfoWindow
                                                  makeWithTitle:@"info title"
                                                        snippet:@"info snippet"
                                                         anchor:[FGMPlatformPoint makeWithX:0 y:0]]
                                     position:[FGMPlatformLatLng makeWithLatitude:latitutde
                                                                        longitude:longitude]
                                     rotation:rotation
                                      visible:YES
                                       zIndex:zIndex
                                     markerId:markerIdentifier
                             clusterManagerId:nil] ]];

  FLTGoogleMapMarkerController *markerController =
      controller.markerIdentifierToController[markerIdentifier];
  GMSMarker *marker = markerController.marker;

  const double delta = 0.0001;
  XCTAssertEqualWithAccuracy(marker.opacity, alpha, delta);
  XCTAssertEqualWithAccuracy(marker.rotation, rotation, delta);
  XCTAssertEqualWithAccuracy(marker.zIndex, zIndex, delta);
  XCTAssertEqualWithAccuracy(marker.groundAnchor.x, anchorX, delta);
  XCTAssertEqualWithAccuracy(marker.groundAnchor.y, anchorY, delta);
  XCTAssertEqualWithAccuracy(marker.position.latitude, latitutde, delta);
  XCTAssertEqualWithAccuracy(marker.position.longitude, longitude, delta);
}

// Boolean properties are tested individually to ensure they aren't accidentally cross-assigned from
// another property.
- (void)testSetsDraggable {
  GMSMapView *mapView = [self mockedMapView];
  FLTMarkersController *controller = [self markersControllerWithMapView:mapView];

  NSString *markerIdentifier = @"marker";
  [controller addMarkers:@[ [FGMPlatformMarker
                                makeWithAlpha:1.0
                                       anchor:[FGMPlatformPoint makeWithX:0 y:0]
                             consumeTapEvents:NO
                                    draggable:YES
                                         flat:NO
                                         icon:[self placeholderBitmap]
                                   infoWindow:[FGMPlatformInfoWindow
                                                  makeWithTitle:@"info title"
                                                        snippet:@"info snippet"
                                                         anchor:[FGMPlatformPoint makeWithX:0 y:0]]
                                     position:[FGMPlatformLatLng makeWithLatitude:0.0 longitude:0.0]
                                     rotation:0
                                      visible:NO
                                       zIndex:0
                                     markerId:markerIdentifier
                             clusterManagerId:nil] ]];

  FLTGoogleMapMarkerController *markerController =
      controller.markerIdentifierToController[markerIdentifier];
  GMSMarker *marker = markerController.marker;

  XCTAssertTrue(marker.draggable);
}

// Boolean properties are tested individually to ensure they aren't accidentally cross-assigned from
// another property.
- (void)testSetsFlat {
  GMSMapView *mapView = [self mockedMapView];
  FLTMarkersController *controller = [self markersControllerWithMapView:mapView];

  NSString *markerIdentifier = @"marker";
  [controller addMarkers:@[ [FGMPlatformMarker
                                makeWithAlpha:1.0
                                       anchor:[FGMPlatformPoint makeWithX:0 y:0]
                             consumeTapEvents:NO
                                    draggable:NO
                                         flat:YES
                                         icon:[self placeholderBitmap]
                                   infoWindow:[FGMPlatformInfoWindow
                                                  makeWithTitle:@"info title"
                                                        snippet:@"info snippet"
                                                         anchor:[FGMPlatformPoint makeWithX:0 y:0]]
                                     position:[FGMPlatformLatLng makeWithLatitude:0.0 longitude:0.0]
                                     rotation:0
                                      visible:NO
                                       zIndex:0
                                     markerId:markerIdentifier
                             clusterManagerId:nil] ]];

  FLTGoogleMapMarkerController *markerController =
      controller.markerIdentifierToController[markerIdentifier];
  GMSMarker *marker = markerController.marker;

  XCTAssertTrue(marker.flat);
}

// Boolean properties are tested individually to ensure they aren't accidentally cross-assigned from
// another property.
- (void)testSetsVisible {
  GMSMapView *mapView = [self mockedMapView];
  FLTMarkersController *controller = [self markersControllerWithMapView:mapView];

  NSString *markerIdentifier = @"marker";
  [controller addMarkers:@[ [FGMPlatformMarker
                                makeWithAlpha:1.0
                                       anchor:[FGMPlatformPoint makeWithX:0 y:0]
                             consumeTapEvents:NO
                                    draggable:NO
                                         flat:NO
                                         icon:[self placeholderBitmap]
                                   infoWindow:[FGMPlatformInfoWindow
                                                  makeWithTitle:@"info title"
                                                        snippet:@"info snippet"
                                                         anchor:[FGMPlatformPoint makeWithX:0 y:0]]
                                     position:[FGMPlatformLatLng makeWithLatitude:0.0 longitude:0.0]
                                     rotation:0
                                      visible:YES
                                       zIndex:0
                                     markerId:markerIdentifier
                             clusterManagerId:nil] ]];

  FLTGoogleMapMarkerController *markerController =
      controller.markerIdentifierToController[markerIdentifier];
  GMSMarker *marker = markerController.marker;

  // Visibility is controlled by being set to a map.
  XCTAssertNotNil(marker.map);
}

- (void)testSetsMarkerInfoWindowProperties {
  GMSMapView *mapView = [self mockedMapView];
  FLTMarkersController *controller = [self markersControllerWithMapView:mapView];

  NSString *markerIdentifier = @"marker";
  NSString *title = @"info title";
  NSString *snippet = @"info snippet";
  double anchorX = 3.14;
  double anchorY = 2.718;
  [controller
      addMarkers:@[ [FGMPlatformMarker
                        makeWithAlpha:1.0
                               anchor:[FGMPlatformPoint makeWithX:0 y:0]
                     consumeTapEvents:YES
                            draggable:YES
                                 flat:YES
                                 icon:[self placeholderBitmap]
                           infoWindow:[FGMPlatformInfoWindow
                                          makeWithTitle:title
                                                snippet:snippet
                                                 anchor:[FGMPlatformPoint makeWithX:anchorX
                                                                                  y:anchorY]]
                             position:[FGMPlatformLatLng makeWithLatitude:0 longitude:0]
                             rotation:0
                              visible:YES
                               zIndex:0
                             markerId:markerIdentifier
                     clusterManagerId:nil] ]];

  FLTGoogleMapMarkerController *markerController =
      controller.markerIdentifierToController[markerIdentifier];
  GMSMarker *marker = markerController.marker;

  const double delta = 0.0001;
  XCTAssertEqualWithAccuracy(marker.infoWindowAnchor.x, anchorX, delta);
  XCTAssertEqualWithAccuracy(marker.infoWindowAnchor.y, anchorY, delta);
  XCTAssertEqual(marker.title, title);
  XCTAssertEqual(marker.snippet, snippet);
}

@end
