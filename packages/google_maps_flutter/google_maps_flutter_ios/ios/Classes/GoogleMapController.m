// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "GoogleMapController.h"
#import "FLTGoogleMapJSONConversions.h"
#import "FLTGoogleMapTileOverlayController.h"
#import "messages.g.h"

#pragma mark - Conversion of JSON-like values sent via platform channels. Forward declarations.

@interface FLTGoogleMapFactory ()

@property(weak, nonatomic) NSObject<FlutterPluginRegistrar> *registrar;
@property(strong, nonatomic, readonly) id<NSObject> sharedMapServices;

@end

@implementation FLTGoogleMapFactory

@synthesize sharedMapServices = _sharedMapServices;

- (instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  self = [super init];
  if (self) {
    _registrar = registrar;
  }
  return self;
}

- (NSObject<FlutterMessageCodec> *)createArgsCodec {
  return [FlutterStandardMessageCodec sharedInstance];
}

- (NSObject<FlutterPlatformView> *)createWithFrame:(CGRect)frame
                                    viewIdentifier:(int64_t)viewId
                                         arguments:(id _Nullable)args {
  // Precache shared map services, if needed.
  // Retain the shared map services singleton, don't use the result for anything.
  (void)[self sharedMapServices];

  return [[FLTGoogleMapController alloc] initWithFrame:frame
                                        viewIdentifier:viewId
                                             arguments:args
                                             registrar:self.registrar];
}

- (id<NSObject>)sharedMapServices {
  if (_sharedMapServices == nil) {
    // Calling this prepares GMSServices on a background thread controlled
    // by the GoogleMaps framework.
    // Retain the singleton to cache the initialization work across all map views.
    _sharedMapServices = [GMSServices sharedServices];
  }
  return _sharedMapServices;
}

@end

#pragma mark -

/// Implementation of the Pigeon maps API.
///
/// This is a separate object from the maps controller because the Pigeon API registration keeps a
/// strong reference to the implementor, but as the FlutterPlatformView, the lifetime of the
/// FLTGoogleMapController instance is what needs to trigger Pigeon unregistration, so can't be
/// the target of the registration.
@interface FGMMapCallHandler : NSObject <FGMMapsApi>
- (instancetype)initWithMapController:(nonnull FLTGoogleMapController *)controller
                            messenger:(NSObject<FlutterBinaryMessenger> *)messenger
                         pigeonSuffix:(NSString *)suffix;
@end

/// Private declarations.
// This is separate in case the above is made public in the future (e.g., for unit testing).
@interface FGMMapCallHandler ()
/// The map controller this inspector corresponds to.
@property(nonatomic, weak) FLTGoogleMapController *controller;
/// The messenger this instance was registered with by Pigeon.
@property(nonatomic, copy) NSObject<FlutterBinaryMessenger> *messenger;
/// The suffix this instance was registered under with Pigeon.
@property(nonatomic, copy) NSString *pigeonSuffix;
@end

#pragma mark -

/// Implementation of the Pigeon maps inspector API.
///
/// This is a separate object from the maps controller because the Pigeon API registration keeps a
/// strong reference to the implementor, but as the FlutterPlatformView, the lifetime of the
/// FLTGoogleMapController instance is what needs to trigger Pigeon unregistration, so can't be
/// the target of the registration.
@interface FGMMapInspector : NSObject <FGMMapsInspectorApi>
- (instancetype)initWithMapController:(nonnull FLTGoogleMapController *)controller
                            messenger:(NSObject<FlutterBinaryMessenger> *)messenger
                         pigeonSuffix:(NSString *)suffix;
@end

/// Private declarations.
// This is separate in case the above is made public in the future (e.g., for unit testing).
@interface FGMMapInspector ()
/// The map controller this inspector corresponds to.
@property(nonatomic, weak) FLTGoogleMapController *controller;
/// The messenger this instance was registered with by Pigeon.
@property(nonatomic, copy) NSObject<FlutterBinaryMessenger> *messenger;
/// The suffix this instance was registered under with Pigeon.
@property(nonatomic, copy) NSString *pigeonSuffix;
@end

#pragma mark -

@interface FLTGoogleMapController ()

@property(nonatomic, strong) GMSMapView *mapView;
@property(nonatomic, strong) FlutterMethodChannel *channel;
@property(nonatomic, assign) BOOL trackCameraPosition;
@property(nonatomic, weak) NSObject<FlutterPluginRegistrar> *registrar;
@property(nonatomic, strong) FLTMarkersController *markersController;
@property(nonatomic, strong) FLTPolygonsController *polygonsController;
@property(nonatomic, strong) FLTPolylinesController *polylinesController;
@property(nonatomic, strong) FLTCirclesController *circlesController;
@property(nonatomic, strong) FLTTileOverlaysController *tileOverlaysController;
// The resulting error message, if any, from the last attempt to set the map style.
// This is used to provide access to errors after the fact, since the map style is generally set at
// creation time and there's no mechanism to return non-fatal error details during platform view
// initialization.
@property(nonatomic, copy) NSString *styleError;
// The main Pigeon API implementation, separate to avoid lifetime extension.
@property(nonatomic, strong) FGMMapCallHandler *callHandler;
// The inspector API implementation, separate to avoid lifetime extension.
@property(nonatomic, strong) FGMMapInspector *inspector;

@end

@implementation FLTGoogleMapController

- (instancetype)initWithFrame:(CGRect)frame
               viewIdentifier:(int64_t)viewId
                    arguments:(id _Nullable)args
                    registrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  GMSCameraPosition *camera =
      [FLTGoogleMapJSONConversions cameraPostionFromDictionary:args[@"initialCameraPosition"]];

  GMSMapViewOptions *options = [[GMSMapViewOptions alloc] init];
  options.frame = frame;
  options.camera = camera;
  NSString *cloudMapId = args[@"options"][@"cloudMapId"];
  if (cloudMapId) {
    options.mapID = [GMSMapID mapIDWithIdentifier:cloudMapId];
  }

  GMSMapView *mapView = [[GMSMapView alloc] initWithOptions:options];

  return [self initWithMapView:mapView viewIdentifier:viewId arguments:args registrar:registrar];
}

- (instancetype)initWithMapView:(GMSMapView *_Nonnull)mapView
                 viewIdentifier:(int64_t)viewId
                      arguments:(id _Nullable)args
                      registrar:(NSObject<FlutterPluginRegistrar> *_Nonnull)registrar {
  if (self = [super init]) {
    _mapView = mapView;

    _mapView.accessibilityElementsHidden = NO;
    // TODO(cyanglaz): avoid sending message to self in the middle of the init method.
    // https://github.com/flutter/flutter/issues/104121
    [self interpretMapOptions:args[@"options"]];
    NSString *channelName =
        [NSString stringWithFormat:@"plugins.flutter.dev/google_maps_ios_%lld", viewId];
    _channel = [FlutterMethodChannel methodChannelWithName:channelName
                                           binaryMessenger:registrar.messenger];
    _mapView.delegate = self;
    _mapView.paddingAdjustmentBehavior = kGMSMapViewPaddingAdjustmentBehaviorNever;
    _registrar = registrar;
    _markersController = [[FLTMarkersController alloc] initWithMethodChannel:_channel
                                                                     mapView:_mapView
                                                                   registrar:registrar];
    _polygonsController = [[FLTPolygonsController alloc] init:_channel
                                                      mapView:_mapView
                                                    registrar:registrar];
    _polylinesController = [[FLTPolylinesController alloc] init:_channel
                                                        mapView:_mapView
                                                      registrar:registrar];
    _circlesController = [[FLTCirclesController alloc] init:_channel
                                                    mapView:_mapView
                                                  registrar:registrar];
    _tileOverlaysController = [[FLTTileOverlaysController alloc] init:_channel
                                                              mapView:_mapView
                                                            registrar:registrar];
    id markersToAdd = args[@"markersToAdd"];
    if ([markersToAdd isKindOfClass:[NSArray class]]) {
      [_markersController addJSONMarkers:markersToAdd];
    }
    id polygonsToAdd = args[@"polygonsToAdd"];
    if ([polygonsToAdd isKindOfClass:[NSArray class]]) {
      [_polygonsController addJSONPolygons:polygonsToAdd];
    }
    id polylinesToAdd = args[@"polylinesToAdd"];
    if ([polylinesToAdd isKindOfClass:[NSArray class]]) {
      [_polylinesController addJSONPolylines:polylinesToAdd];
    }
    id circlesToAdd = args[@"circlesToAdd"];
    if ([circlesToAdd isKindOfClass:[NSArray class]]) {
      [_circlesController addJSONCircles:circlesToAdd];
    }
    id tileOverlaysToAdd = args[@"tileOverlaysToAdd"];
    if ([tileOverlaysToAdd isKindOfClass:[NSArray class]]) {
      [_tileOverlaysController addJSONTileOverlays:tileOverlaysToAdd];
    }

    [_mapView addObserver:self forKeyPath:@"frame" options:0 context:nil];

    NSString *suffix = [NSString stringWithFormat:@"%lld", viewId];
    _callHandler = [[FGMMapCallHandler alloc] initWithMapController:self
                                                          messenger:registrar.messenger
                                                       pigeonSuffix:suffix];
    SetUpFGMMapsApiWithSuffix(registrar.messenger, _callHandler, suffix);
    _inspector = [[FGMMapInspector alloc] initWithMapController:self
                                                      messenger:registrar.messenger
                                                   pigeonSuffix:suffix];
    SetUpFGMMapsInspectorApiWithSuffix(registrar.messenger, _inspector, suffix);
  }
  return self;
}

- (void)dealloc {
  // Unregister the API implementations so that they can be released; the registration created an
  // owning reference.
  SetUpFGMMapsApiWithSuffix(_callHandler.messenger, nil, _callHandler.pigeonSuffix);
  SetUpFGMMapsInspectorApiWithSuffix(_inspector.messenger, nil, _inspector.pigeonSuffix);
}

- (UIView *)view {
  return self.mapView;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
  if (object == self.mapView && [keyPath isEqualToString:@"frame"]) {
    CGRect bounds = self.mapView.bounds;
    if (CGRectEqualToRect(bounds, CGRectZero)) {
      // The workaround is to fix an issue that the camera location is not current when
      // the size of the map is zero at initialization.
      // So We only care about the size of the `self.mapView`, ignore the frame changes when the
      // size is zero.
      return;
    }
    // We only observe the frame for initial setup.
    [self.mapView removeObserver:self forKeyPath:@"frame"];
    [self.mapView moveCamera:[GMSCameraUpdate setCamera:self.mapView.camera]];
  } else {
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
  }
}

- (void)showAtOrigin:(CGPoint)origin {
  CGRect frame = {origin, self.mapView.frame.size};
  self.mapView.frame = frame;
  self.mapView.hidden = NO;
}

- (void)hide {
  self.mapView.hidden = YES;
}

- (GMSCameraPosition *)cameraPosition {
  if (self.trackCameraPosition) {
    return self.mapView.camera;
  } else {
    return nil;
  }
}

- (void)setCamera:(GMSCameraPosition *)camera {
  self.mapView.camera = camera;
}

- (void)setCameraTargetBounds:(GMSCoordinateBounds *)bounds {
  self.mapView.cameraTargetBounds = bounds;
}

- (void)setCompassEnabled:(BOOL)enabled {
  self.mapView.settings.compassButton = enabled;
}

- (void)setIndoorEnabled:(BOOL)enabled {
  self.mapView.indoorEnabled = enabled;
}

- (void)setTrafficEnabled:(BOOL)enabled {
  self.mapView.trafficEnabled = enabled;
}

- (void)setBuildingsEnabled:(BOOL)enabled {
  self.mapView.buildingsEnabled = enabled;
}

- (void)setMapType:(GMSMapViewType)mapType {
  self.mapView.mapType = mapType;
}

- (void)setMinZoom:(float)minZoom maxZoom:(float)maxZoom {
  [self.mapView setMinZoom:minZoom maxZoom:maxZoom];
}

- (void)setPaddingTop:(float)top left:(float)left bottom:(float)bottom right:(float)right {
  self.mapView.padding = UIEdgeInsetsMake(top, left, bottom, right);
}

- (void)setRotateGesturesEnabled:(BOOL)enabled {
  self.mapView.settings.rotateGestures = enabled;
}

- (void)setScrollGesturesEnabled:(BOOL)enabled {
  self.mapView.settings.scrollGestures = enabled;
}

- (void)setTiltGesturesEnabled:(BOOL)enabled {
  self.mapView.settings.tiltGestures = enabled;
}

- (void)setTrackCameraPosition:(BOOL)enabled {
  _trackCameraPosition = enabled;
}

- (void)setZoomGesturesEnabled:(BOOL)enabled {
  self.mapView.settings.zoomGestures = enabled;
}

- (void)setMyLocationEnabled:(BOOL)enabled {
  self.mapView.myLocationEnabled = enabled;
}

- (void)setMyLocationButtonEnabled:(BOOL)enabled {
  self.mapView.settings.myLocationButton = enabled;
}

/// Sets the map style, returing any error string as well as storing that error in `mapStyle` for
/// later access.
- (NSString *)setMapStyle:(NSString *)mapStyle {
  NSString *errorString = nil;
  if (mapStyle.length == 0) {
    self.mapView.mapStyle = nil;
  } else {
    NSError *error;
    GMSMapStyle *style = [GMSMapStyle styleWithJSONString:mapStyle error:&error];
    if (style) {
      self.mapView.mapStyle = style;
    } else {
      errorString = [error localizedDescription];
    }
  }
  self.styleError = errorString;
  return errorString;
}

#pragma mark - GMSMapViewDelegate methods

- (void)mapView:(GMSMapView *)mapView willMove:(BOOL)gesture {
  [self.channel invokeMethod:@"camera#onMoveStarted" arguments:@{@"isGesture" : @(gesture)}];
}

- (void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position {
  if (self.trackCameraPosition) {
    [self.channel invokeMethod:@"camera#onMove"
                     arguments:@{
                       @"position" : [FLTGoogleMapJSONConversions dictionaryFromPosition:position]
                     }];
  }
}

- (void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position {
  [self.channel invokeMethod:@"camera#onIdle" arguments:@{}];
}

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
  NSString *markerId = marker.userData[0];
  return [self.markersController didTapMarkerWithIdentifier:markerId];
}

- (void)mapView:(GMSMapView *)mapView didEndDraggingMarker:(GMSMarker *)marker {
  NSString *markerId = marker.userData[0];
  [self.markersController didEndDraggingMarkerWithIdentifier:markerId location:marker.position];
}

- (void)mapView:(GMSMapView *)mapView didBeginDraggingMarker:(GMSMarker *)marker {
  NSString *markerId = marker.userData[0];
  [self.markersController didStartDraggingMarkerWithIdentifier:markerId location:marker.position];
}

- (void)mapView:(GMSMapView *)mapView didDragMarker:(GMSMarker *)marker {
  NSString *markerId = marker.userData[0];
  [self.markersController didDragMarkerWithIdentifier:markerId location:marker.position];
}

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker {
  NSString *markerId = marker.userData[0];
  [self.markersController didTapInfoWindowOfMarkerWithIdentifier:markerId];
}
- (void)mapView:(GMSMapView *)mapView didTapOverlay:(GMSOverlay *)overlay {
  NSString *overlayId = overlay.userData[0];
  if ([self.polylinesController hasPolylineWithIdentifier:overlayId]) {
    [self.polylinesController didTapPolylineWithIdentifier:overlayId];
  } else if ([self.polygonsController hasPolygonWithIdentifier:overlayId]) {
    [self.polygonsController didTapPolygonWithIdentifier:overlayId];
  } else if ([self.circlesController hasCircleWithIdentifier:overlayId]) {
    [self.circlesController didTapCircleWithIdentifier:overlayId];
  }
}

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
  [self.channel
      invokeMethod:@"map#onTap"
         arguments:@{@"position" : [FLTGoogleMapJSONConversions arrayFromLocation:coordinate]}];
}

- (void)mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate {
  [self.channel
      invokeMethod:@"map#onLongPress"
         arguments:@{@"position" : [FLTGoogleMapJSONConversions arrayFromLocation:coordinate]}];
}

- (void)interpretMapOptions:(NSDictionary *)data {
  NSArray *cameraTargetBounds = FGMGetValueOrNilFromDict(data, @"cameraTargetBounds");
  if (cameraTargetBounds) {
    [self
        setCameraTargetBounds:cameraTargetBounds.count > 0 && cameraTargetBounds[0] != [NSNull null]
                                  ? [FLTGoogleMapJSONConversions
                                        coordinateBoundsFromLatLongs:cameraTargetBounds.firstObject]
                                  : nil];
  }
  NSNumber *compassEnabled = FGMGetValueOrNilFromDict(data, @"compassEnabled");
  if (compassEnabled) {
    [self setCompassEnabled:[compassEnabled boolValue]];
  }
  id indoorEnabled = FGMGetValueOrNilFromDict(data, @"indoorEnabled");
  if (indoorEnabled) {
    [self setIndoorEnabled:[indoorEnabled boolValue]];
  }
  id trafficEnabled = FGMGetValueOrNilFromDict(data, @"trafficEnabled");
  if (trafficEnabled) {
    [self setTrafficEnabled:[trafficEnabled boolValue]];
  }
  id buildingsEnabled = FGMGetValueOrNilFromDict(data, @"buildingsEnabled");
  if (buildingsEnabled) {
    [self setBuildingsEnabled:[buildingsEnabled boolValue]];
  }
  id mapType = FGMGetValueOrNilFromDict(data, @"mapType");
  if (mapType) {
    [self setMapType:[FLTGoogleMapJSONConversions mapViewTypeFromTypeValue:mapType]];
  }
  NSArray *zoomData = FGMGetValueOrNilFromDict(data, @"minMaxZoomPreference");
  if (zoomData) {
    float minZoom = (zoomData[0] == [NSNull null]) ? kGMSMinZoomLevel : [zoomData[0] floatValue];
    float maxZoom = (zoomData[1] == [NSNull null]) ? kGMSMaxZoomLevel : [zoomData[1] floatValue];
    [self setMinZoom:minZoom maxZoom:maxZoom];
  }
  NSArray *paddingData = FGMGetValueOrNilFromDict(data, @"padding");
  if (paddingData) {
    float top = (paddingData[0] == [NSNull null]) ? 0 : [paddingData[0] floatValue];
    float left = (paddingData[1] == [NSNull null]) ? 0 : [paddingData[1] floatValue];
    float bottom = (paddingData[2] == [NSNull null]) ? 0 : [paddingData[2] floatValue];
    float right = (paddingData[3] == [NSNull null]) ? 0 : [paddingData[3] floatValue];
    [self setPaddingTop:top left:left bottom:bottom right:right];
  }

  NSNumber *rotateGesturesEnabled = FGMGetValueOrNilFromDict(data, @"rotateGesturesEnabled");
  if (rotateGesturesEnabled) {
    [self setRotateGesturesEnabled:[rotateGesturesEnabled boolValue]];
  }
  NSNumber *scrollGesturesEnabled = FGMGetValueOrNilFromDict(data, @"scrollGesturesEnabled");
  if (scrollGesturesEnabled) {
    [self setScrollGesturesEnabled:[scrollGesturesEnabled boolValue]];
  }
  NSNumber *tiltGesturesEnabled = FGMGetValueOrNilFromDict(data, @"tiltGesturesEnabled");
  if (tiltGesturesEnabled) {
    [self setTiltGesturesEnabled:[tiltGesturesEnabled boolValue]];
  }
  NSNumber *trackCameraPosition = FGMGetValueOrNilFromDict(data, @"trackCameraPosition");
  if (trackCameraPosition) {
    [self setTrackCameraPosition:[trackCameraPosition boolValue]];
  }
  NSNumber *zoomGesturesEnabled = FGMGetValueOrNilFromDict(data, @"zoomGesturesEnabled");
  if (zoomGesturesEnabled) {
    [self setZoomGesturesEnabled:[zoomGesturesEnabled boolValue]];
  }
  NSNumber *myLocationEnabled = FGMGetValueOrNilFromDict(data, @"myLocationEnabled");
  if (myLocationEnabled) {
    [self setMyLocationEnabled:[myLocationEnabled boolValue]];
  }
  NSNumber *myLocationButtonEnabled = FGMGetValueOrNilFromDict(data, @"myLocationButtonEnabled");
  if (myLocationButtonEnabled) {
    [self setMyLocationButtonEnabled:[myLocationButtonEnabled boolValue]];
  }
  NSString *style = FGMGetValueOrNilFromDict(data, @"style");
  if (style) {
    [self setMapStyle:style];
  }
}

@end

#pragma mark -

@implementation FGMMapCallHandler

- (instancetype)initWithMapController:(nonnull FLTGoogleMapController *)controller
                            messenger:(NSObject<FlutterBinaryMessenger> *)messenger
                         pigeonSuffix:(NSString *)suffix {
  self = [super init];
  if (self) {
    _controller = controller;
    _messenger = messenger;
    _pigeonSuffix = suffix;
  }
  return self;
}

- (void)waitForMapWithError:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  // No-op; this call just ensures synchronization with the platform thread.
}

- (void)updateCirclesByAdding:(nonnull NSArray<FGMPlatformCircle *> *)toAdd
                     changing:(nonnull NSArray<FGMPlatformCircle *> *)toChange
                     removing:(nonnull NSArray<NSString *> *)idsToRemove
                        error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  [self.controller.circlesController addCircles:toAdd];
  [self.controller.circlesController changeCircles:toChange];
  [self.controller.circlesController removeCirclesWithIdentifiers:idsToRemove];
}

- (void)updateWithMapConfiguration:(nonnull FGMPlatformMapConfiguration *)configuration
                             error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  [self.controller interpretMapOptions:configuration.json];
}

- (void)updateMarkersByAdding:(nonnull NSArray<FGMPlatformMarker *> *)toAdd
                     changing:(nonnull NSArray<FGMPlatformMarker *> *)toChange
                     removing:(nonnull NSArray<NSString *> *)idsToRemove
                        error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  [self.controller.markersController addMarkers:toAdd];
  [self.controller.markersController changeMarkers:toChange];
  [self.controller.markersController removeMarkersWithIdentifiers:idsToRemove];
}

- (void)updatePolygonsByAdding:(nonnull NSArray<FGMPlatformPolygon *> *)toAdd
                      changing:(nonnull NSArray<FGMPlatformPolygon *> *)toChange
                      removing:(nonnull NSArray<NSString *> *)idsToRemove
                         error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  [self.controller.polygonsController addPolygons:toAdd];
  [self.controller.polygonsController changePolygons:toChange];
  [self.controller.polygonsController removePolygonWithIdentifiers:idsToRemove];
}

- (void)updatePolylinesByAdding:(nonnull NSArray<FGMPlatformPolyline *> *)toAdd
                       changing:(nonnull NSArray<FGMPlatformPolyline *> *)toChange
                       removing:(nonnull NSArray<NSString *> *)idsToRemove
                          error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  [self.controller.polylinesController addPolylines:toAdd];
  [self.controller.polylinesController changePolylines:toChange];
  [self.controller.polylinesController removePolylineWithIdentifiers:idsToRemove];
}

- (void)updateTileOverlaysByAdding:(nonnull NSArray<FGMPlatformTileOverlay *> *)toAdd
                          changing:(nonnull NSArray<FGMPlatformTileOverlay *> *)toChange
                          removing:(nonnull NSArray<NSString *> *)idsToRemove
                             error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  [self.controller.tileOverlaysController addTileOverlays:toAdd];
  [self.controller.tileOverlaysController changeTileOverlays:toChange];
  [self.controller.tileOverlaysController removeTileOverlayWithIdentifiers:idsToRemove];
}

- (nullable FGMPlatformLatLng *)
    latLngForScreenCoordinate:(nonnull FGMPlatformPoint *)screenCoordinate
                        error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  if (!self.controller.mapView) {
    *error = [FlutterError errorWithCode:@"GoogleMap uninitialized"
                                 message:@"getLatLng called prior to map initialization"
                                 details:nil];
    return nil;
  }
  CGPoint point = FGMGetCGPointForPigeonPoint(screenCoordinate);
  CLLocationCoordinate2D latlng = [self.controller.mapView.projection coordinateForPoint:point];
  return FGMGetPigeonLatLngForCoordinate(latlng);
}

- (nullable FGMPlatformPoint *)
    screenCoordinatesForLatLng:(nonnull FGMPlatformLatLng *)latLng
                         error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  if (!self.controller.mapView) {
    *error = [FlutterError errorWithCode:@"GoogleMap uninitialized"
                                 message:@"getScreenCoordinate called prior to map initialization"
                                 details:nil];
    return nil;
  }
  CLLocationCoordinate2D location = FGMGetCoordinateForPigeonLatLng(latLng);
  CGPoint point = [self.controller.mapView.projection pointForCoordinate:location];
  return FGMGetPigeonPointForCGPoint(point);
}

- (nullable FGMPlatformLatLngBounds *)visibleMapRegion:
    (FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  if (!self.controller.mapView) {
    *error = [FlutterError errorWithCode:@"GoogleMap uninitialized"
                                 message:@"getVisibleRegion called prior to map initialization"
                                 details:nil];
    return nil;
  }
  GMSVisibleRegion visibleRegion = self.controller.mapView.projection.visibleRegion;
  GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithRegion:visibleRegion];
  return FGMGetPigeonLatLngBoundsForCoordinateBounds(bounds);
}

- (void)moveCameraWithUpdate:(nonnull FGMPlatformCameraUpdate *)cameraUpdate
                       error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  GMSCameraUpdate *update = [FLTGoogleMapJSONConversions cameraUpdateFromArray:cameraUpdate.json];
  if (!update) {
    *error = [FlutterError errorWithCode:@"Invalid update"
                                 message:@"Unrecognized camera update"
                                 details:cameraUpdate.json];
    return;
  }
  [self.controller.mapView moveCamera:update];
}

- (void)animateCameraWithUpdate:(nonnull FGMPlatformCameraUpdate *)cameraUpdate
                          error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  GMSCameraUpdate *update = [FLTGoogleMapJSONConversions cameraUpdateFromArray:cameraUpdate.json];
  if (!update) {
    *error = [FlutterError errorWithCode:@"Invalid update"
                                 message:@"Unrecognized camera update"
                                 details:cameraUpdate.json];
    return;
  }
  [self.controller.mapView animateWithCameraUpdate:update];
}

- (nullable NSNumber *)currentZoomLevel:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  return @(self.controller.mapView.camera.zoom);
}

- (void)showInfoWindowForMarkerWithIdentifier:(nonnull NSString *)markerId
                                        error:(FlutterError *_Nullable __autoreleasing *_Nonnull)
                                                  error {
  [self.controller.markersController showMarkerInfoWindowWithIdentifier:markerId error:error];
}

- (void)hideInfoWindowForMarkerWithIdentifier:(nonnull NSString *)markerId
                                        error:(FlutterError *_Nullable __autoreleasing *_Nonnull)
                                                  error {
  [self.controller.markersController hideMarkerInfoWindowWithIdentifier:markerId error:error];
}

- (nullable NSNumber *)
    isShowingInfoWindowForMarkerWithIdentifier:(nonnull NSString *)markerId
                                         error:(FlutterError *_Nullable __autoreleasing *_Nonnull)
                                                   error {
  return [self.controller.markersController isInfoWindowShownForMarkerWithIdentifier:markerId
                                                                               error:error];
}

- (nullable NSString *)setStyle:(nonnull NSString *)style
                          error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  return [self.controller setMapStyle:style];
}

- (nullable NSString *)lastStyleError:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  return self.controller.styleError;
}

- (void)clearTileCacheForOverlayWithIdentifier:(nonnull NSString *)tileOverlayId
                                         error:(FlutterError *_Nullable __autoreleasing *_Nonnull)
                                                   error {
  [self.controller.tileOverlaysController clearTileCacheWithIdentifier:tileOverlayId];
}

- (nullable FlutterStandardTypedData *)takeSnapshotWithError:
    (FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  GMSMapView *mapView = self.controller.mapView;
  if (!mapView) {
    *error = [FlutterError errorWithCode:@"GoogleMap uninitialized"
                                 message:@"takeSnapshot called prior to map initialization"
                                 details:nil];
    return nil;
  }
  UIGraphicsImageRenderer *renderer =
      [[UIGraphicsImageRenderer alloc] initWithSize:mapView.bounds.size];
  // For some unknown reason mapView.layer::renderInContext API returns a blank image on iOS 17.
  // So we have to use drawViewHierarchyInRect API.
  UIImage *image = [renderer imageWithActions:^(UIGraphicsImageRendererContext *context) {
    [mapView drawViewHierarchyInRect:mapView.bounds afterScreenUpdates:YES];
  }];
  NSData *imageData = UIImagePNGRepresentation(image);
  return imageData ? [FlutterStandardTypedData typedDataWithBytes:imageData] : nil;
}

@end

#pragma mark -

@implementation FGMMapInspector

- (instancetype)initWithMapController:(nonnull FLTGoogleMapController *)controller
                            messenger:(NSObject<FlutterBinaryMessenger> *)messenger
                         pigeonSuffix:(NSString *)suffix {
  self = [super init];
  if (self) {
    _controller = controller;
    _messenger = messenger;
    _pigeonSuffix = suffix;
  }
  return self;
}

- (nullable NSNumber *)areBuildingsEnabledWithError:
    (FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  return @(self.controller.mapView.buildingsEnabled);
}

- (nullable NSNumber *)areRotateGesturesEnabledWithError:
    (FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  return @(self.controller.mapView.settings.rotateGestures);
}

- (nullable NSNumber *)areScrollGesturesEnabledWithError:
    (FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  return @(self.controller.mapView.settings.scrollGestures);
}

- (nullable NSNumber *)areTiltGesturesEnabledWithError:
    (FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  return @(self.controller.mapView.settings.tiltGestures);
}

- (nullable NSNumber *)areZoomGesturesEnabledWithError:
    (FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  return @(self.controller.mapView.settings.zoomGestures);
}

- (nullable FGMPlatformTileLayer *)
    getInfoForTileOverlayWithIdentifier:(nonnull NSString *)tileOverlayId
                                  error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  GMSTileLayer *layer =
      [self.controller.tileOverlaysController tileOverlayWithIdentifier:tileOverlayId].layer;
  if (!layer) {
    return nil;
  }
  return [FGMPlatformTileLayer makeWithVisible:(layer.map != nil)
                                        fadeIn:layer.fadeIn
                                       opacity:layer.opacity
                                        zIndex:layer.zIndex];
}

- (nullable NSNumber *)isCompassEnabledWithError:
    (FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  return @(self.controller.mapView.settings.compassButton);
}

- (nullable NSNumber *)isMyLocationButtonEnabledWithError:
    (FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  return @(self.controller.mapView.settings.myLocationButton);
}

- (nullable NSNumber *)isTrafficEnabledWithError:
    (FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  return @(self.controller.mapView.trafficEnabled);
}

- (nullable FGMPlatformZoomRange *)zoomRange:
    (FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  return [FGMPlatformZoomRange makeWithMin:self.controller.mapView.minZoom
                                       max:self.controller.mapView.maxZoom];
}

@end
