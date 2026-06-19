// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import google_maps_flutter_ios_sdk10;
@import GoogleMaps;
@import QuartzCore;
@import XCTest;

#import "TestUtils/PartiallyMockedMapView.h"
#import "TestUtils/TestAssetProvider.h"
#import "TestUtils/TestMapEventHandler.h"

/// A GMSAdvancedMarker that ensures that property updates are made before the map is set.
@interface PropertyOrderValidatingAdvancedMarker : GMSAdvancedMarker {
}
@property(nonatomic) BOOL hasSetMap;
@end

/// A GMSMarker that records whether animated property updates disable implicit animations.
@interface MarkerUpdateAnimationValidatingMarker : GMSMarker {
}
@property(nonatomic) BOOL hasSetPosition;
@property(nonatomic) BOOL hasSetRotation;
@property(nonatomic) BOOL wereActionsDisabledWhenSettingPosition;
@property(nonatomic) BOOL wereActionsDisabledWhenSettingRotation;
@end

@interface MarkerControllerTests : XCTestCase
@end

@implementation MarkerControllerTests

/// Returns a simple map view for use with marker controllers.
+ (GMSMapView *)mapView {
  GMSMapViewOptions *mapViewOptions = [[GMSMapViewOptions alloc] init];
  mapViewOptions.frame = CGRectMake(0, 0, 100, 100);
  mapViewOptions.camera = [[GMSCameraPosition alloc] initWithLatitude:0 longitude:0 zoom:0];
  return [[PartiallyMockedMapView alloc] initWithOptions:mapViewOptions];
}

/// Returns a FGMMarkersController instance instantiated with the given map view.
///
/// The mapView should outlive the controller, as the controller keeps a weak reference to it.
- (FGMMarkersController *)markersControllerWithMapView:(GMSMapView *)mapView
                                         eventDelegate:
                                             (NSObject<FGMMapEventDelegate> *)eventDelegate {
  return [[FGMMarkersController alloc] initWithMapView:mapView
                                         eventDelegate:eventDelegate
                             clusterManagersController:nil
                                         assetProvider:[[TestAssetProvider alloc] init]
                                            markerType:FGMPlatformMarkerTypeMarker];
}

- (FGMPlatformBitmap *)placeholderBitmap {
  return [FGMPlatformBitmap makeWithBitmap:[FGMPlatformBitmapDefaultMarker makeWithHue:@0]];
}

- (FGMPlatformMarker *)platformMarkerWithCollisionBehavior:
    (FGMPlatformMarkerCollisionBehaviorBox *)collisionBehavior {
  return [FGMPlatformMarker
          makeWithAlpha:1.0
                 anchor:[FGMPlatformPoint makeWithX:0 y:0]
       consumeTapEvents:YES
              draggable:YES
                   flat:YES
                   icon:[self placeholderBitmap]
             infoWindow:[FGMPlatformInfoWindow makeWithTitle:@"info title"
                                                     snippet:@"info snippet"
                                                      anchor:[FGMPlatformPoint makeWithX:0 y:0]]
               position:[FGMPlatformLatLng makeWithLatitude:0 longitude:0]
               rotation:0
                visible:YES
                 zIndex:0
               markerId:@"marker"
       clusterManagerId:nil
      collisionBehavior:collisionBehavior];
}

- (FGMPlatformMarkerUpdateAnimationConfiguration *)
    markerUpdateAnimationConfigurationWithPositionAnimationsEnabled:(BOOL)positionAnimationsEnabled
                                          rotationAnimationsEnabled:
                                              (BOOL)rotationAnimationsEnabled {
  return [FGMPlatformMarkerUpdateAnimationConfiguration
      makeWithPositionAnimationsEnabled:positionAnimationsEnabled
              rotationAnimationsEnabled:rotationAnimationsEnabled];
}

- (void)updateAnimationValidatingMarker:(MarkerUpdateAnimationValidatingMarker *)marker
     markerUpdateAnimationConfiguration:
         (FGMPlatformMarkerUpdateAnimationConfiguration *)markerUpdateAnimationConfiguration {
  [FGMMarkerController updateMarker:marker
                      fromPlatformMarker:[self platformMarkerWithCollisionBehavior:nil]
                             withMapView:[MarkerControllerTests mapView]
                           assetProvider:[[TestAssetProvider alloc] init]
                             screenScale:1
      markerUpdateAnimationConfiguration:markerUpdateAnimationConfiguration
               usingOpacityForVisibility:NO];
}

- (void)updateAnimationValidatingMarker:(MarkerUpdateAnimationValidatingMarker *)marker
              positionAnimationsEnabled:(BOOL)positionAnimationsEnabled
              rotationAnimationsEnabled:(BOOL)rotationAnimationsEnabled {
  [self updateAnimationValidatingMarker:marker
      markerUpdateAnimationConfiguration:
          [self markerUpdateAnimationConfigurationWithPositionAnimationsEnabled:
                    positionAnimationsEnabled
                                                      rotationAnimationsEnabled:
                                                          rotationAnimationsEnabled]];
}

- (void)testSetsMarkerNumericProperties {
  GMSMapView *mapView = [MarkerControllerTests mapView];
  TestMapEventHandler *eventHandler = [[TestMapEventHandler alloc] init];
  FGMMarkersController *controller = [self markersControllerWithMapView:mapView
                                                          eventDelegate:eventHandler];

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
                              clusterManagerId:nil
                             collisionBehavior:nil] ]];

  FGMMarkerController *markerController = controller.markerIdentifierToController[markerIdentifier];
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
  GMSMapView *mapView = [MarkerControllerTests mapView];
  TestMapEventHandler *eventHandler = [[TestMapEventHandler alloc] init];
  FGMMarkersController *controller = [self markersControllerWithMapView:mapView
                                                          eventDelegate:eventHandler];

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
                                      position:[FGMPlatformLatLng makeWithLatitude:0.0
                                                                         longitude:0.0]
                                      rotation:0
                                       visible:NO
                                        zIndex:0
                                      markerId:markerIdentifier
                              clusterManagerId:nil
                             collisionBehavior:nil] ]];

  FGMMarkerController *markerController = controller.markerIdentifierToController[markerIdentifier];
  GMSMarker *marker = markerController.marker;

  XCTAssertTrue(marker.draggable);
}

// Boolean properties are tested individually to ensure they aren't accidentally cross-assigned from
// another property.
- (void)testSetsFlat {
  GMSMapView *mapView = [MarkerControllerTests mapView];
  TestMapEventHandler *eventHandler = [[TestMapEventHandler alloc] init];
  FGMMarkersController *controller = [self markersControllerWithMapView:mapView
                                                          eventDelegate:eventHandler];

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
                                      position:[FGMPlatformLatLng makeWithLatitude:0.0
                                                                         longitude:0.0]
                                      rotation:0
                                       visible:NO
                                        zIndex:0
                                      markerId:markerIdentifier
                              clusterManagerId:nil
                             collisionBehavior:nil] ]];

  FGMMarkerController *markerController = controller.markerIdentifierToController[markerIdentifier];
  GMSMarker *marker = markerController.marker;

  XCTAssertTrue(marker.flat);
}

// Boolean properties are tested individually to ensure they aren't accidentally cross-assigned from
// another property.
- (void)testSetsVisible {
  GMSMapView *mapView = [MarkerControllerTests mapView];
  TestMapEventHandler *eventHandler = [[TestMapEventHandler alloc] init];
  FGMMarkersController *controller = [self markersControllerWithMapView:mapView
                                                          eventDelegate:eventHandler];

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
                                      position:[FGMPlatformLatLng makeWithLatitude:0.0
                                                                         longitude:0.0]
                                      rotation:0
                                       visible:YES
                                        zIndex:0
                                      markerId:markerIdentifier
                              clusterManagerId:nil
                             collisionBehavior:nil] ]];

  FGMMarkerController *markerController = controller.markerIdentifierToController[markerIdentifier];
  GMSMarker *marker = markerController.marker;

  // Visibility is controlled by being set to a map.
  XCTAssertNotNil(marker.map);
}

- (void)testSetsMarkerInfoWindowProperties {
  GMSMapView *mapView = [MarkerControllerTests mapView];
  TestMapEventHandler *eventHandler = [[TestMapEventHandler alloc] init];
  FGMMarkersController *controller = [self markersControllerWithMapView:mapView
                                                          eventDelegate:eventHandler];

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
                      clusterManagerId:nil
                     collisionBehavior:nil] ]];

  FGMMarkerController *markerController = controller.markerIdentifierToController[markerIdentifier];
  GMSMarker *marker = markerController.marker;

  const double delta = 0.0001;
  XCTAssertEqualWithAccuracy(marker.infoWindowAnchor.x, anchorX, delta);
  XCTAssertEqualWithAccuracy(marker.infoWindowAnchor.y, anchorY, delta);
  XCTAssertEqual(marker.title, title);
  XCTAssertEqual(marker.snippet, snippet);
}

- (void)testUpdateMarkerSetsVisibilityLast {
  PropertyOrderValidatingAdvancedMarker *marker =
      [[PropertyOrderValidatingAdvancedMarker alloc] init];
  FGMPlatformMarkerCollisionBehaviorBox *collisionBehavior =
      [[FGMPlatformMarkerCollisionBehaviorBox alloc]
          initWithValue:FGMPlatformMarkerCollisionBehaviorRequiredAndHidesOptional];
  [FGMMarkerController updateMarker:marker
                      fromPlatformMarker:[self
                                             platformMarkerWithCollisionBehavior:collisionBehavior]
                             withMapView:[MarkerControllerTests mapView]
                           assetProvider:[[TestAssetProvider alloc] init]
                             screenScale:1
      markerUpdateAnimationConfiguration:
          [self markerUpdateAnimationConfigurationWithPositionAnimationsEnabled:YES
                                                      rotationAnimationsEnabled:YES]
               usingOpacityForVisibility:NO];
  XCTAssertTrue(marker.hasSetMap);
}

- (void)testUpdateMarkerDoesNotDisablePositionOrRotationAnimationByDefault {
  MarkerUpdateAnimationValidatingMarker *marker =
      [[MarkerUpdateAnimationValidatingMarker alloc] init];
  [self updateAnimationValidatingMarker:marker
              positionAnimationsEnabled:YES
              rotationAnimationsEnabled:YES];

  XCTAssertTrue(marker.hasSetPosition);
  XCTAssertTrue(marker.hasSetRotation);
  XCTAssertFalse(marker.wereActionsDisabledWhenSettingPosition,
                 @"Position animation should be enabled by default.");
  XCTAssertFalse(marker.wereActionsDisabledWhenSettingRotation,
                 @"Rotation animation should be enabled by default.");
}

- (void)testUpdateMarkerDoesNotDisablePositionOrRotationAnimationWithNilConfiguration {
  MarkerUpdateAnimationValidatingMarker *marker =
      [[MarkerUpdateAnimationValidatingMarker alloc] init];
  [self updateAnimationValidatingMarker:marker markerUpdateAnimationConfiguration:nil];

  XCTAssertTrue(marker.hasSetPosition);
  XCTAssertTrue(marker.hasSetRotation);
  XCTAssertFalse(marker.wereActionsDisabledWhenSettingPosition,
                 @"Nil animation configuration should leave position animation enabled.");
  XCTAssertFalse(marker.wereActionsDisabledWhenSettingRotation,
                 @"Nil animation configuration should leave rotation animation enabled.");
}

- (void)testUpdateMarkerDisablesPositionAndRotationAnimation {
  MarkerUpdateAnimationValidatingMarker *marker =
      [[MarkerUpdateAnimationValidatingMarker alloc] init];
  [self updateAnimationValidatingMarker:marker
              positionAnimationsEnabled:NO
              rotationAnimationsEnabled:NO];

  XCTAssertTrue(marker.hasSetPosition);
  XCTAssertTrue(marker.hasSetRotation);
  XCTAssertTrue(marker.wereActionsDisabledWhenSettingPosition,
                @"Position animation should be disabled.");
  XCTAssertTrue(marker.wereActionsDisabledWhenSettingRotation,
                @"Rotation animation should be disabled.");
}

- (void)testUpdateMarkerDisablesOnlyPositionAnimation {
  MarkerUpdateAnimationValidatingMarker *marker =
      [[MarkerUpdateAnimationValidatingMarker alloc] init];
  [self updateAnimationValidatingMarker:marker
              positionAnimationsEnabled:NO
              rotationAnimationsEnabled:YES];

  XCTAssertTrue(marker.hasSetPosition);
  XCTAssertTrue(marker.hasSetRotation);
  XCTAssertTrue(marker.wereActionsDisabledWhenSettingPosition,
                @"Position animation should be disabled.");
  XCTAssertFalse(marker.wereActionsDisabledWhenSettingRotation,
                 @"Rotation animation should be enabled.");
}

- (void)testUpdateMarkerDisablesOnlyRotationAnimation {
  MarkerUpdateAnimationValidatingMarker *marker =
      [[MarkerUpdateAnimationValidatingMarker alloc] init];
  [self updateAnimationValidatingMarker:marker
              positionAnimationsEnabled:YES
              rotationAnimationsEnabled:NO];

  XCTAssertTrue(marker.hasSetPosition);
  XCTAssertTrue(marker.hasSetRotation);
  XCTAssertFalse(marker.wereActionsDisabledWhenSettingPosition,
                 @"Position animation should be enabled.");
  XCTAssertTrue(marker.wereActionsDisabledWhenSettingRotation,
                @"Rotation animation should be disabled.");
}

- (void)testAssetProviderIsRetained {
  FGMMarkersController *markerController;
  __weak TestAssetProvider *weakAssetProvider;
  @autoreleasepool {
    TestAssetProvider *assetProvider = [[TestAssetProvider alloc] init];
    weakAssetProvider = assetProvider;

    markerController =
        [[FGMMarkersController alloc] initWithMapView:[MarkerControllerTests mapView]
                                        eventDelegate:[[TestMapEventHandler alloc] init]
                            clusterManagersController:nil
                                        assetProvider:assetProvider
                                           markerType:FGMPlatformMarkerTypeMarker];
  }
  XCTAssertNotNil(markerController);
  XCTAssertNotNil(weakAssetProvider, @"AssetProvider should be retained by the marker controller");
}

@end

@implementation MarkerUpdateAnimationValidatingMarker

- (void)setPosition:(CLLocationCoordinate2D)position {
  self.wereActionsDisabledWhenSettingPosition = [CATransaction disableActions];
  self.hasSetPosition = YES;
  super.position = position;
}

- (void)setRotation:(CLLocationDegrees)rotation {
  self.wereActionsDisabledWhenSettingRotation = [CATransaction disableActions];
  self.hasSetRotation = YES;
  super.rotation = rotation;
}

@end

@implementation PropertyOrderValidatingAdvancedMarker

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

- (void)setCollisionBehavior:(GMSCollisionBehavior)collisionBehavior {
  XCTAssertFalse(self.hasSetMap, @"Property set after map was set.");
  super.collisionBehavior = collisionBehavior;
}

- (void)setMap:(GMSMapView *)map {
  // Don't actually set the map, since that requires more test setup.
  if (map) {
    self.hasSetMap = YES;
  }
}
@end
