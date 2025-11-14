// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import google_maps_flutter_ios;
@import google_maps_flutter_ios.Test;
@import XCTest;
@import GoogleMaps;

#import <OCMock/OCMock.h>
#import <google_maps_flutter_ios/messages.g.h>

#import "PartiallyMockedMapView.h"

/// A GMSMarker that ensures that property updates are made before the map is set.
@interface PropertyOrderValidatingMarker : GMSMarker {
}
@property(nonatomic) BOOL hasSetMap;
@end

@interface GoogleMapsMarkerControllerTests : XCTestCase
@end

@implementation GoogleMapsMarkerControllerTests

/// Returns a simple map view for use with marker controllers.
+ (GMSMapView *)mapView {
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
  GMSMapView *mapView = [GoogleMapsMarkerControllerTests mapView];
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
  GMSMapView *mapView = [GoogleMapsMarkerControllerTests mapView];
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
  GMSMapView *mapView = [GoogleMapsMarkerControllerTests mapView];
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
  GMSMapView *mapView = [GoogleMapsMarkerControllerTests mapView];
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
  GMSMapView *mapView = [GoogleMapsMarkerControllerTests mapView];
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

- (void)testUpdateMarkerSetsVisibilityLast {
  PropertyOrderValidatingMarker *marker = [[PropertyOrderValidatingMarker alloc] init];
  [FLTGoogleMapMarkerController
                   updateMarker:marker
             fromPlatformMarker:[FGMPlatformMarker
                                       makeWithAlpha:1.0
                                              anchor:[FGMPlatformPoint makeWithX:0 y:0]
                                    consumeTapEvents:YES
                                           draggable:YES
                                                flat:YES
                                                icon:[self placeholderBitmap]
                                          infoWindow:[FGMPlatformInfoWindow
                                                         makeWithTitle:@"info title"
                                                               snippet:@"info snippet"
                                                                anchor:[FGMPlatformPoint
                                                                           makeWithX:0
                                                                                   y:0]]
                                            position:[FGMPlatformLatLng makeWithLatitude:0
                                                                               longitude:0]
                                            rotation:0
                                             visible:YES
                                              zIndex:0
                                            markerId:@"marker"
                                    clusterManagerId:nil]
                    withMapView:[GoogleMapsMarkerControllerTests mapView]
                      registrar:nil
                    screenScale:1
      usingOpacityForVisibility:NO];
  XCTAssertTrue(marker.hasSetMap);
}

@end

@implementation PropertyOrderValidatingMarker

- (void)setPosition:(CLLocationCoordinate2D)position {
  XCTAssertFalse(self.hasSetMap, @"Property set after map was set.");
  super.position = position;
}

- (void)setSnippet:(NSString *)snippet {
  XCTAssertFalse(self.hasSetMap, @"Property set after map was set.");
  super.snippet = snippet;
}

- (void)setIcon:(UIImage *)icon {
  XCTAssertFalse(self.hasSetMap, @"Property set after map was set.");
  super.icon = icon;
}

- (void)setIconView:(UIView *)iconView {
  XCTAssertFalse(self.hasSetMap, @"Property set after map was set.");
  super.iconView = iconView;
}

- (void)setTracksViewChanges:(BOOL)tracksViewChanges {
  XCTAssertFalse(self.hasSetMap, @"Property set after map was set.");
  super.tracksViewChanges = tracksViewChanges;
}

- (void)setTracksInfoWindowChanges:(BOOL)tracksInfoWindowChanges {
  XCTAssertFalse(self.hasSetMap, @"Property set after map was set.");
  super.tracksInfoWindowChanges = tracksInfoWindowChanges;
}

- (void)setGroundAnchor:(CGPoint)groundAnchor {
  XCTAssertFalse(self.hasSetMap, @"Property set after map was set.");
  super.groundAnchor = groundAnchor;
}

- (void)setInfoWindowAnchor:(CGPoint)infoWindowAnchor {
  XCTAssertFalse(self.hasSetMap, @"Property set after map was set.");
  super.infoWindowAnchor = infoWindowAnchor;
}

- (void)setAppearAnimation:(GMSMarkerAnimation)appearAnimation {
  XCTAssertFalse(self.hasSetMap, @"Property set after map was set.");
  super.appearAnimation = appearAnimation;
}

- (void)setDraggable:(BOOL)draggable {
  XCTAssertFalse(self.hasSetMap, @"Property set after map was set.");
  super.draggable = draggable;
}

- (void)setFlat:(BOOL)flat {
  XCTAssertFalse(self.hasSetMap, @"Property set after map was set.");
  super.flat = flat;
}

- (void)setRotation:(CLLocationDegrees)rotation {
  XCTAssertFalse(self.hasSetMap, @"Property set after map was set.");
  super.rotation = rotation;
}

- (void)setOpacity:(float)opacity {
  XCTAssertFalse(self.hasSetMap, @"Property set after map was set.");
  super.opacity = opacity;
}

- (void)setPanoramaView:(GMSPanoramaView *)panoramaView {
  XCTAssertFalse(self.hasSetMap, @"Property set after map was set.");
  super.panoramaView = panoramaView;
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
