// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "GoogleMapMarkerController.h"

#import "FGMImageUtils.h"
#import "FGMMarkerUserData.h"
#import "FLTGoogleMapJSONConversions.h"

@interface FLTGoogleMapMarkerController ()

@property(strong, nonatomic, readwrite) GMSMarker *marker;
@property(weak, nonatomic) GMSMapView *mapView;
@property(assign, nonatomic, readwrite) BOOL consumeTapEvents;
/// The unique identifier for the cluster manager.
@property(copy, nonatomic, nullable) NSString *clusterManagerIdentifier;
/// The unique identifier for the marker.
@property(copy, nonatomic) NSString *markerIdentifier;

@end

@implementation FLTGoogleMapMarkerController

- (instancetype)initWithMarker:(GMSMarker *)marker
              markerIdentifier:(NSString *)markerIdentifier
                       mapView:(GMSMapView *)mapView {
  self = [super init];
  if (self) {
    _marker = marker;
    _markerIdentifier = [markerIdentifier copy];
    _mapView = mapView;
  }
  return self;
}

- (void)setClusterManagerIdentifier:(nullable NSString *)clusterManagerIdentifier {
  _clusterManagerIdentifier = clusterManagerIdentifier;
}

- (void)showInfoWindow {
  self.mapView.selectedMarker = self.marker;
}

- (void)hideInfoWindow {
  if (self.mapView.selectedMarker == self.marker) {
    self.mapView.selectedMarker = nil;
  }
}

- (BOOL)isInfoWindowShown {
  return self.mapView.selectedMarker == self.marker;
}

- (void)removeMarker {
  self.marker.map = nil;
}

- (void)setAlpha:(float)alpha {
  self.marker.opacity = alpha;
}

- (void)setAnchor:(CGPoint)anchor {
  self.marker.groundAnchor = anchor;
}

- (void)setDraggable:(BOOL)draggable {
  self.marker.draggable = draggable;
}

- (void)setFlat:(BOOL)flat {
  self.marker.flat = flat;
}

- (void)setIcon:(UIImage *)icon {
  self.marker.icon = icon;
}

- (void)setInfoWindowAnchor:(CGPoint)anchor {
  self.marker.infoWindowAnchor = anchor;
}

- (void)setInfoWindowTitle:(NSString *)title snippet:(NSString *)snippet {
  self.marker.title = title;
  self.marker.snippet = snippet;
}

- (void)setPosition:(CLLocationCoordinate2D)position {
  self.marker.position = position;
}

- (void)setRotation:(CLLocationDegrees)rotation {
  self.marker.rotation = rotation;
}

- (void)setVisible:(BOOL)visible {
  // If marker belongs the cluster manager, visibility need to be controlled with the opacity
  // as the cluster manager controls when marker is on the map and when not.
  // Alpha value for marker must always be interpreted before visibility value.
  if (self.clusterManagerIdentifier) {
    self.marker.opacity = visible ? self.marker.opacity : 0.0f;
  } else {
    self.marker.map = visible ? self.mapView : nil;
  }
}

- (void)setZIndex:(int)zIndex {
  self.marker.zIndex = zIndex;
}

- (void)updateFromPlatformMarker:(FGMPlatformMarker *)platformMarker
                       registrar:(NSObject<FlutterPluginRegistrar> *)registrar
                     screenScale:(CGFloat)screenScale {
  [self setClusterManagerIdentifier:platformMarker.clusterManagerId];
  [self setAlpha:platformMarker.alpha];
  [self setAnchor:FGMGetCGPointForPigeonPoint(platformMarker.anchor)];
  [self setDraggable:platformMarker.draggable];
  UIImage *image = FGMIconFromBitmap(platformMarker.icon, registrar, screenScale);
  [self setIcon:image];
  [self setFlat:platformMarker.flat];
  [self setConsumeTapEvents:platformMarker.consumeTapEvents];
  [self setPosition:FGMGetCoordinateForPigeonLatLng(platformMarker.position)];
  [self setRotation:platformMarker.rotation];
  [self setZIndex:platformMarker.zIndex];
  FGMPlatformInfoWindow *infoWindow = platformMarker.infoWindow;
  [self setInfoWindowAnchor:FGMGetCGPointForPigeonPoint(infoWindow.anchor)];
  if (infoWindow.title) {
    [self setInfoWindowTitle:infoWindow.title snippet:infoWindow.snippet];
  }

  // Set the marker's user data with current identifiers.
  FGMSetIdentifiersToMarkerUserData(self.markerIdentifier, self.clusterManagerIdentifier,
                                    self.marker);

  // Ensure setVisible is called last as it adds the marker to the map,
  // and must be done after all other parameters are set.
  [self setVisible:platformMarker.visible];
}

@end

@interface FLTMarkersController ()

@property(strong, nonatomic, readwrite) NSMutableDictionary *markerIdentifierToController;
@property(strong, nonatomic) FGMMapsCallbackApi *callbackHandler;
/// Controller for adding/removing/fetching cluster managers
@property(weak, nonatomic, nullable) FGMClusterManagersController *clusterManagersController;
@property(weak, nonatomic) NSObject<FlutterPluginRegistrar> *registrar;
@property(weak, nonatomic) GMSMapView *mapView;

@end

@implementation FLTMarkersController

- (instancetype)initWithMapView:(GMSMapView *)mapView
                callbackHandler:(FGMMapsCallbackApi *)callbackHandler
      clusterManagersController:(nullable FGMClusterManagersController *)clusterManagersController
                      registrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  self = [super init];
  if (self) {
    _callbackHandler = callbackHandler;
    _mapView = mapView;
    _clusterManagersController = clusterManagersController;
    _markerIdentifierToController = [[NSMutableDictionary alloc] init];
    _registrar = registrar;
  }
  return self;
}

- (void)addMarkers:(NSArray<FGMPlatformMarker *> *)markersToAdd {
  for (FGMPlatformMarker *marker in markersToAdd) {
    [self addMarker:marker];
  }
}

- (void)addMarker:(FGMPlatformMarker *)markerToAdd {
  CLLocationCoordinate2D position = FGMGetCoordinateForPigeonLatLng(markerToAdd.position);
  NSString *markerIdentifier = markerToAdd.markerId;
  NSString *clusterManagerIdentifier = markerToAdd.clusterManagerId;
  GMSMarker *marker = [GMSMarker markerWithPosition:position];
  FLTGoogleMapMarkerController *controller =
      [[FLTGoogleMapMarkerController alloc] initWithMarker:marker
                                          markerIdentifier:markerIdentifier
                                                   mapView:self.mapView];
  [controller updateFromPlatformMarker:markerToAdd
                             registrar:self.registrar
                           screenScale:[self getScreenScale]];
  if (clusterManagerIdentifier) {
    GMUClusterManager *clusterManager =
        [_clusterManagersController clusterManagerWithIdentifier:clusterManagerIdentifier];
    if ([marker conformsToProtocol:@protocol(GMUClusterItem)]) {
      [clusterManager addItem:(id<GMUClusterItem>)marker];
    }
  }
  self.markerIdentifierToController[markerIdentifier] = controller;
}

- (void)changeMarkers:(NSArray<FGMPlatformMarker *> *)markersToChange {
  for (FGMPlatformMarker *marker in markersToChange) {
    [self changeMarker:marker];
  }
}

- (void)changeMarker:(FGMPlatformMarker *)markerToChange {
  NSString *markerIdentifier = markerToChange.markerId;

  FLTGoogleMapMarkerController *controller = self.markerIdentifierToController[markerIdentifier];
  if (!controller) {
    return;
  }

  NSString *clusterManagerIdentifier = markerToChange.clusterManagerId;
  NSString *previousClusterManagerIdentifier = [controller clusterManagerIdentifier];
  [controller updateFromPlatformMarker:markerToChange
                             registrar:self.registrar
                           screenScale:[self getScreenScale]];

  if ([controller.marker conformsToProtocol:@protocol(GMUClusterItem)]) {
    if (previousClusterManagerIdentifier &&
        ![clusterManagerIdentifier isEqualToString:previousClusterManagerIdentifier]) {
      // Remove marker from previous cluster manager if its cluster manager identifier is removed or
      // changed.
      GMUClusterManager *clusterManager = [_clusterManagersController
          clusterManagerWithIdentifier:previousClusterManagerIdentifier];
      [clusterManager removeItem:(id<GMUClusterItem>)controller.marker];
    }

    if (clusterManagerIdentifier &&
        ![previousClusterManagerIdentifier isEqualToString:clusterManagerIdentifier]) {
      // Add marker to cluster manager if its cluster manager identifier has changed.
      GMUClusterManager *clusterManager =
          [_clusterManagersController clusterManagerWithIdentifier:clusterManagerIdentifier];
      [clusterManager addItem:(id<GMUClusterItem>)controller.marker];
    }
  }
}

- (void)removeMarkersWithIdentifiers:(NSArray<NSString *> *)identifiers {
  for (NSString *identifier in identifiers) {
    [self removeMarker:identifier];
  }
}

- (void)removeMarker:(NSString *)identifier {
  FLTGoogleMapMarkerController *controller = self.markerIdentifierToController[identifier];
  if (!controller) {
    return;
  }
  NSString *clusterManagerIdentifier = [controller clusterManagerIdentifier];
  if (clusterManagerIdentifier) {
    GMUClusterManager *clusterManager =
        [_clusterManagersController clusterManagerWithIdentifier:clusterManagerIdentifier];
    [clusterManager removeItem:(id<GMUClusterItem>)controller.marker];
  } else {
    [controller removeMarker];
  }
  [self.markerIdentifierToController removeObjectForKey:identifier];
}

- (BOOL)didTapMarkerWithIdentifier:(NSString *)identifier {
  if (!identifier) {
    return NO;
  }
  FLTGoogleMapMarkerController *controller = self.markerIdentifierToController[identifier];
  if (!controller) {
    return NO;
  }
  [self.callbackHandler didTapMarkerWithIdentifier:identifier
                                        completion:^(FlutterError *_Nullable _){
                                        }];
  return controller.consumeTapEvents;
}

- (void)didStartDraggingMarkerWithIdentifier:(NSString *)identifier
                                    location:(CLLocationCoordinate2D)location {
  if (!identifier) {
    return;
  }
  FLTGoogleMapMarkerController *controller = self.markerIdentifierToController[identifier];
  if (!controller) {
    return;
  }
  [self.callbackHandler
      didStartDragForMarkerWithIdentifier:identifier
                               atPosition:FGMGetPigeonLatLngForCoordinate(location)
                               completion:^(FlutterError *_Nullable _){
                               }];
}

- (void)didDragMarkerWithIdentifier:(NSString *)identifier
                           location:(CLLocationCoordinate2D)location {
  if (!identifier) {
    return;
  }
  FLTGoogleMapMarkerController *controller = self.markerIdentifierToController[identifier];
  if (!controller) {
    return;
  }
  [self.callbackHandler didDragMarkerWithIdentifier:identifier
                                         atPosition:FGMGetPigeonLatLngForCoordinate(location)
                                         completion:^(FlutterError *_Nullable _){
                                         }];
}

- (void)didEndDraggingMarkerWithIdentifier:(NSString *)identifier
                                  location:(CLLocationCoordinate2D)location {
  FLTGoogleMapMarkerController *controller = self.markerIdentifierToController[identifier];
  if (!controller) {
    return;
  }
  [self.callbackHandler didEndDragForMarkerWithIdentifier:identifier
                                               atPosition:FGMGetPigeonLatLngForCoordinate(location)
                                               completion:^(FlutterError *_Nullable _){
                                               }];
}

- (void)didTapInfoWindowOfMarkerWithIdentifier:(NSString *)identifier {
  if (identifier && self.markerIdentifierToController[identifier]) {
    [self.callbackHandler didTapInfoWindowOfMarkerWithIdentifier:identifier
                                                      completion:^(FlutterError *_Nullable _){
                                                      }];
  }
}

- (void)showMarkerInfoWindowWithIdentifier:(NSString *)identifier
                                     error:
                                         (FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  FLTGoogleMapMarkerController *controller = self.markerIdentifierToController[identifier];
  if (controller) {
    [controller showInfoWindow];
  } else {
    *error = [FlutterError errorWithCode:@"Invalid markerId"
                                 message:@"showInfoWindow called with invalid markerId"
                                 details:nil];
  }
}

- (void)hideMarkerInfoWindowWithIdentifier:(NSString *)identifier
                                     error:
                                         (FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  FLTGoogleMapMarkerController *controller = self.markerIdentifierToController[identifier];
  if (controller) {
    [controller hideInfoWindow];
  } else {
    *error = [FlutterError errorWithCode:@"Invalid markerId"
                                 message:@"hideInfoWindow called with invalid markerId"
                                 details:nil];
  }
}

- (nullable NSNumber *)
    isInfoWindowShownForMarkerWithIdentifier:(NSString *)identifier
                                       error:(FlutterError *_Nullable __autoreleasing *_Nonnull)
                                                 error {
  FLTGoogleMapMarkerController *controller = self.markerIdentifierToController[identifier];
  if (controller) {
    return @([controller isInfoWindowShown]);
  } else {
    *error = [FlutterError errorWithCode:@"Invalid markerId"
                                 message:@"isInfoWindowShown called with invalid markerId"
                                 details:nil];
    return nil;
  }
}

- (CGFloat)getScreenScale {
  // TODO(jokerttu): This method is called on marker creation, which, for initial markers, is done
  // before the view is added to the view hierarchy. This means that the traitCollection values may
  // not be matching the right display where the map is finally shown. The solution should be
  // revisited after the proper way to fetch the display scale is resolved for platform views. This
  // should be done under the context of the following issue:
  // https://github.com/flutter/flutter/issues/125496.
  return self.mapView.traitCollection.displayScale;
}

@end
