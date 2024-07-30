// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "GoogleMapMarkerController.h"
#import "FLTGoogleMapJSONConversions.h"
#import "GoogleMapMarkerIconCache.h"

@interface FLTGoogleMapMarkerController ()

@property(strong, nonatomic) GMSMarker *marker;
@property(weak, nonatomic) GMSMapView *mapView;
@property(assign, nonatomic, readwrite) BOOL consumeTapEvents;

@end

@implementation FLTGoogleMapMarkerController

- (instancetype)initWithPosition:(CLLocationCoordinate2D)position
                      identifier:(NSString *)identifier
                         mapView:(GMSMapView *)mapView {
  self = [super init];
  if (self) {
    _marker = [GMSMarker markerWithPosition:position];
    _mapView = mapView;
    _marker.userData = @[ identifier ];
  }
  return self;
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
  if (self.marker.opacity != alpha) {
    self.marker.opacity = alpha;
  }
}

- (void)setAnchor:(CGPoint)anchor {
  if (self.marker.groundAnchor.x != anchor.x || self.marker.groundAnchor.y != anchor.y) {
    self.marker.groundAnchor = anchor;
  }
}

- (void)setDraggable:(BOOL)draggable {
  if (self.marker.draggable != draggable) {
    self.marker.draggable = draggable;
  }
}

- (void)setFlat:(BOOL)flat {
  if (self.marker.flat != flat) {
    self.marker.flat = flat;
  }
}

- (void)setIcon:(UIImage *)icon {
  self.marker.icon = icon;
}

- (void)setInfoWindowAnchor:(CGPoint)anchor {
  if (self.marker.infoWindowAnchor.x != anchor.x || self.marker.infoWindowAnchor.y != anchor.y) {
    self.marker.infoWindowAnchor = anchor;
  }
}

- (void)setInfoWindowTitle:(NSString *)title snippet:(NSString *)snippet {
  if (self.marker.title != title) {
    self.marker.title = title;
  }
  if (self.marker.snippet != snippet) {
    self.marker.snippet = snippet;
  }
}

- (void)setPosition:(CLLocationCoordinate2D)position {
  if (self.marker.position.latitude != position.latitude ||
      self.marker.position.longitude != position.longitude) {
    self.marker.position = position;
  }
}

- (void)setRotation:(CLLocationDegrees)rotation {
  if (self.marker.rotation != rotation) {
    self.marker.rotation = rotation;
  }
}

- (void)setVisible:(BOOL)visible {
  if ((self.marker.map != nil) != visible) {
    self.marker.map = visible ? self.mapView : nil;
  }
}

- (void)setZIndex:(int)zIndex {
  if (self.marker.zIndex != zIndex) {
    self.marker.zIndex = zIndex;
  }
}

- (void)interpretMarkerOptions:(NSDictionary *)data
                     iconCache:(GoogleMapMarkerIconCache *)iconCache {
  NSNumber *alpha = FGMGetValueOrNilFromDict(data, @"alpha");
  if (alpha) {
    [self setAlpha:[alpha floatValue]];
  }
  NSArray *anchor = FGMGetValueOrNilFromDict(data, @"anchor");
  if (anchor) {
    [self setAnchor:[FLTGoogleMapJSONConversions pointFromArray:anchor]];
  }
  NSNumber *draggable = FGMGetValueOrNilFromDict(data, @"draggable");
  if (draggable) {
    [self setDraggable:[draggable boolValue]];
  }

  NSArray *icon = FGMGetValueOrNilFromDict(data, @"icon");
  if (icon) {
    UIImage *image = [iconCache getImage:icon];
    [self setIcon:image];
  }

  NSNumber *flat = FGMGetValueOrNilFromDict(data, @"flat");
  if (flat) {
    [self setFlat:[flat boolValue]];
  }
  NSNumber *consumeTapEvents = FGMGetValueOrNilFromDict(data, @"consumeTapEvents");
  if (consumeTapEvents) {
    [self setConsumeTapEvents:[consumeTapEvents boolValue]];
  }
  [self interpretInfoWindow:data];
  NSArray *position = FGMGetValueOrNilFromDict(data, @"position");
  if (position) {
    [self setPosition:[FLTGoogleMapJSONConversions locationFromLatLong:position]];
  }
  NSNumber *rotation = FGMGetValueOrNilFromDict(data, @"rotation");
  if (rotation) {
    [self setRotation:[rotation doubleValue]];
  }
  NSNumber *visible = FGMGetValueOrNilFromDict(data, @"visible");
  if (visible) {
    [self setVisible:[visible boolValue]];
  }
  NSNumber *zIndex = FGMGetValueOrNilFromDict(data, @"zIndex");
  if (zIndex) {
    [self setZIndex:[zIndex intValue]];
  }
}

- (void)interpretInfoWindow:(NSDictionary *)data {
  NSDictionary *infoWindow = FGMGetValueOrNilFromDict(data, @"infoWindow");
  if (infoWindow) {
    NSString *title = FGMGetValueOrNilFromDict(infoWindow, @"title");
    NSString *snippet = FGMGetValueOrNilFromDict(infoWindow, @"snippet");
    if (title) {
      [self setInfoWindowTitle:title snippet:snippet];
    }
    NSArray *infoWindowAnchor = infoWindow[@"infoWindowAnchor"];
    if (infoWindowAnchor) {
      [self setInfoWindowAnchor:[FLTGoogleMapJSONConversions pointFromArray:infoWindowAnchor]];
    }
  }
}

@end

@interface FLTMarkersController ()

@property(strong, nonatomic) NSMutableDictionary *markerIdentifierToController;
@property(strong, nonatomic) FGMMapsCallbackApi *callbackHandler;
@property(weak, nonatomic) NSObject<FlutterPluginRegistrar> *registrar;
@property(weak, nonatomic) GMSMapView *mapView;
@end

@implementation FLTMarkersController

- (instancetype)initWithMapView:(GMSMapView *)mapView
                callbackHandler:(FGMMapsCallbackApi *)callbackHandler
                      registrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  self = [super init];
  if (self) {
    _callbackHandler = callbackHandler;
    _mapView = mapView;
    _markerIdentifierToController = [[NSMutableDictionary alloc] init];
    _registrar = registrar;
  }
  return self;
}

- (void)addJSONMarkers:(NSArray<NSDictionary<NSString *, id> *> *)markersToAdd {
  CGFloat screenScale = [self getScreenScale];

  GoogleMapMarkerIconCache *iconCache =
      [[GoogleMapMarkerIconCache alloc] initWithRegistrar:self.registrar screenScale:screenScale];
  for (NSDictionary<NSString *, id> *marker in markersToAdd) {
    CLLocationCoordinate2D position = [FLTMarkersController getPosition:marker];
    NSString *identifier = marker[@"markerId"];
    FLTGoogleMapMarkerController *controller =
        [[FLTGoogleMapMarkerController alloc] initWithPosition:position
                                                    identifier:identifier
                                                       mapView:self.mapView];

    [controller interpretMarkerOptions:marker iconCache:iconCache];

    self.markerIdentifierToController[identifier] = controller;
  }
}

- (void)addMarkers:(NSArray<FGMPlatformMarker *> *)markersToAdd {
  CGFloat screenScale = [self getScreenScale];
  GoogleMapMarkerIconCache *iconCache =
      [[GoogleMapMarkerIconCache alloc] initWithRegistrar:self.registrar screenScale:screenScale];

  for (FGMPlatformMarker *marker in markersToAdd) {
    CLLocationCoordinate2D position = [FLTMarkersController getPosition:marker.json];
    NSString *identifier = marker.json[@"markerId"];

    FLTGoogleMapMarkerController *controller =
        [[FLTGoogleMapMarkerController alloc] initWithPosition:position
                                                    identifier:identifier
                                                       mapView:self.mapView];

    [controller interpretMarkerOptions:marker.json iconCache:iconCache];

    self.markerIdentifierToController[identifier] = controller;
  }
}

- (void)changeMarkers:(NSArray<FGMPlatformMarker *> *)markersToChange {
  CGFloat screenScale = [self getScreenScale];

  GoogleMapMarkerIconCache *iconCache =
      [[GoogleMapMarkerIconCache alloc] initWithRegistrar:self.registrar screenScale:screenScale];

  for (FGMPlatformMarker *marker in markersToChange) {
    NSString *identifier = marker.json[@"markerId"];
    FLTGoogleMapMarkerController *controller = self.markerIdentifierToController[identifier];
    [controller interpretMarkerOptions:marker.json iconCache:iconCache];
  }
}

- (void)removeMarkersWithIdentifiers:(NSArray<NSString *> *)identifiers {
  for (NSString *identifier in identifiers) {
    FLTGoogleMapMarkerController *controller = self.markerIdentifierToController[identifier];
    if (!controller) {
      continue;
    }
    [controller removeMarker];
    [self.markerIdentifierToController removeObjectForKey:identifier];
  }
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

+ (CLLocationCoordinate2D)getPosition:(NSDictionary *)marker {
  NSArray *position = marker[@"position"];
  return [FLTGoogleMapJSONConversions locationFromLatLong:position];
}

@end
