// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import GoogleMapsUtils;

#import "GoogleMapController.h"
#import "GoogleMapController_Test.h"

#import "FGMGroundOverlayController.h"
#import "FGMMarkerUserData.h"
#import "FLTGoogleMapHeatmapController.h"
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
  return FGMGetMessagesCodec();
}

- (NSObject<FlutterPlatformView> *)createWithFrame:(CGRect)frame
                                    viewIdentifier:(int64_t)viewId
                                         arguments:(id _Nullable)args {
  // Precache shared map services, if needed.
  // Retain the shared map services singleton, don't use the result for anything.
  (void)[self sharedMapServices];

  return [[FLTGoogleMapController alloc] initWithFrame:frame
                                        viewIdentifier:viewId
                                    creationParameters:args
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

/// Private declarations of the FGMMapCallHandler.
@interface FGMMapCallHandler ()
- (instancetype)initWithMapController:(nonnull FLTGoogleMapController *)controller
                            messenger:(NSObject<FlutterBinaryMessenger> *)messenger
                         pigeonSuffix:(NSString *)suffix;

/// The map controller this inspector corresponds to.
@property(nonatomic, weak) FLTGoogleMapController *controller;
/// The messenger this instance was registered with by Pigeon.
@property(nonatomic, copy) NSObject<FlutterBinaryMessenger> *messenger;
/// The suffix this instance was registered under with Pigeon.
@property(nonatomic, copy) NSString *pigeonSuffix;
@end

#pragma mark -

/// Private declarations of the FGMMapInspector.
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
@property(nonatomic, strong) FGMMapsCallbackApi *dartCallbackHandler;
@property(nonatomic, assign) BOOL trackCameraPosition;
@property(nonatomic, weak) NSObject<FlutterPluginRegistrar> *registrar;
@property(nonatomic, strong) FGMClusterManagersController *clusterManagersController;
@property(nonatomic, strong) FLTMarkersController *markersController;
@property(nonatomic, strong) FLTPolygonsController *polygonsController;
@property(nonatomic, strong) FLTPolylinesController *polylinesController;
@property(nonatomic, strong) FLTCirclesController *circlesController;

// The controller that handles heatmaps
@property(nonatomic, strong) FLTHeatmapsController *heatmapsController;
@property(nonatomic, strong) FLTTileOverlaysController *tileOverlaysController;
@property(nonatomic, strong) FLTGroundOverlaysController *groundOverlaysController;
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
           creationParameters:(FGMPlatformMapViewCreationParams *)creationParameters
                    registrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  GMSCameraPosition *camera =
      FGMGetCameraPositionForPigeonCameraPosition(creationParameters.initialCameraPosition);

  GMSMapViewOptions *options = [[GMSMapViewOptions alloc] init];
  options.frame = frame;
  options.camera = camera;
  NSString *cloudMapId = creationParameters.mapConfiguration.cloudMapId;
  if (cloudMapId) {
    options.mapID = [GMSMapID mapIDWithIdentifier:cloudMapId];
  }

  GMSMapView *mapView = [[GMSMapView alloc] initWithOptions:options];

  return [self initWithMapView:mapView
                viewIdentifier:viewId
            creationParameters:creationParameters
                     registrar:registrar];
}

- (instancetype)initWithMapView:(GMSMapView *_Nonnull)mapView
                 viewIdentifier:(int64_t)viewId
             creationParameters:(FGMPlatformMapViewCreationParams *)creationParameters
                      registrar:(NSObject<FlutterPluginRegistrar> *_Nonnull)registrar {
  if (self = [super init]) {
    _mapView = mapView;

    _mapView.accessibilityElementsHidden = NO;
    // TODO(cyanglaz): avoid sending message to self in the middle of the init method.
    // https://github.com/flutter/flutter/issues/104121
    [self interpretMapConfiguration:creationParameters.mapConfiguration];
    NSString *pigeonSuffix = [NSString stringWithFormat:@"%lld", viewId];
    _dartCallbackHandler = [[FGMMapsCallbackApi alloc] initWithBinaryMessenger:registrar.messenger
                                                          messageChannelSuffix:pigeonSuffix];
    _mapView.delegate = self;
    _mapView.paddingAdjustmentBehavior = kGMSMapViewPaddingAdjustmentBehaviorNever;
    _registrar = registrar;
    _clusterManagersController =
        [[FGMClusterManagersController alloc] initWithMapView:_mapView
                                              callbackHandler:_dartCallbackHandler];
    _markersController = [[FLTMarkersController alloc] initWithMapView:_mapView
                                                       callbackHandler:_dartCallbackHandler
                                             clusterManagersController:_clusterManagersController
                                                             registrar:registrar];
    _polygonsController = [[FLTPolygonsController alloc] initWithMapView:_mapView
                                                         callbackHandler:_dartCallbackHandler
                                                               registrar:registrar];
    _polylinesController = [[FLTPolylinesController alloc] initWithMapView:_mapView
                                                           callbackHandler:_dartCallbackHandler
                                                                 registrar:registrar];
    _circlesController = [[FLTCirclesController alloc] initWithMapView:_mapView
                                                       callbackHandler:_dartCallbackHandler
                                                             registrar:registrar];
    _heatmapsController = [[FLTHeatmapsController alloc] initWithMapView:_mapView];
    _tileOverlaysController =
        [[FLTTileOverlaysController alloc] initWithMapView:_mapView
                                           callbackHandler:_dartCallbackHandler
                                                 registrar:registrar];
    _groundOverlaysController =
        [[FLTGroundOverlaysController alloc] initWithMapView:_mapView
                                             callbackHandler:_dartCallbackHandler
                                                   registrar:registrar];
    [_clusterManagersController addClusterManagers:creationParameters.initialClusterManagers];
    [_markersController addMarkers:creationParameters.initialMarkers];
    [_polygonsController addPolygons:creationParameters.initialPolygons];
    [_polylinesController addPolylines:creationParameters.initialPolylines];
    [_circlesController addCircles:creationParameters.initialCircles];
    [_heatmapsController addHeatmaps:creationParameters.initialHeatmaps];
    [_tileOverlaysController addTileOverlays:creationParameters.initialTileOverlays];
    [_groundOverlaysController addGroundOverlays:creationParameters.initialGroundOverlays];

    // Invoke clustering after markers are added.
    [_clusterManagersController invokeClusteringForEachClusterManager];

    [_mapView addObserver:self forKeyPath:@"frame" options:0 context:nil];

    _callHandler = [[FGMMapCallHandler alloc] initWithMapController:self
                                                          messenger:registrar.messenger
                                                       pigeonSuffix:pigeonSuffix];
    SetUpFGMMapsApiWithSuffix(registrar.messenger, _callHandler, pigeonSuffix);
    _inspector = [[FGMMapInspector alloc] initWithMapController:self
                                                      messenger:registrar.messenger
                                                   pigeonSuffix:pigeonSuffix];
    SetUpFGMMapsInspectorApiWithSuffix(registrar.messenger, _inspector, pigeonSuffix);
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
  [self.dartCallbackHandler didStartCameraMoveWithCompletion:^(FlutterError *_Nullable _){
  }];
}

- (void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position {
  if (self.trackCameraPosition) {
    [self.dartCallbackHandler
        didMoveCameraToPosition:FGMGetPigeonCameraPositionForPosition(position)
                     completion:^(FlutterError *_Nullable _){
                     }];
  }
}

- (void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position {
  [self.dartCallbackHandler didIdleCameraWithCompletion:^(FlutterError *_Nullable _){
  }];
}

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
  if ([marker.userData isKindOfClass:[GMUStaticCluster class]]) {
    GMUStaticCluster *cluster = marker.userData;
    [self.clusterManagersController didTapCluster:cluster];
    // When NO is returned, the map will focus on the cluster.
    return NO;
  }
  return
      [self.markersController didTapMarkerWithIdentifier:FGMGetMarkerIdentifierFromMarker(marker)];
}

- (void)mapView:(GMSMapView *)mapView didEndDraggingMarker:(GMSMarker *)marker {
  [self.markersController
      didEndDraggingMarkerWithIdentifier:FGMGetMarkerIdentifierFromMarker(marker)
                                location:marker.position];
}

- (void)mapView:(GMSMapView *)mapView didBeginDraggingMarker:(GMSMarker *)marker {
  [self.markersController
      didStartDraggingMarkerWithIdentifier:FGMGetMarkerIdentifierFromMarker(marker)
                                  location:marker.position];
}

- (void)mapView:(GMSMapView *)mapView didDragMarker:(GMSMarker *)marker {
  [self.markersController didDragMarkerWithIdentifier:FGMGetMarkerIdentifierFromMarker(marker)
                                             location:marker.position];
}

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker {
  [self.markersController
      didTapInfoWindowOfMarkerWithIdentifier:FGMGetMarkerIdentifierFromMarker(marker)];
}
- (void)mapView:(GMSMapView *)mapView didTapOverlay:(GMSOverlay *)overlay {
  NSString *overlayId = overlay.userData[0];
  if ([self.polylinesController hasPolylineWithIdentifier:overlayId]) {
    [self.polylinesController didTapPolylineWithIdentifier:overlayId];
  } else if ([self.polygonsController hasPolygonWithIdentifier:overlayId]) {
    [self.polygonsController didTapPolygonWithIdentifier:overlayId];
  } else if ([self.circlesController hasCircleWithIdentifier:overlayId]) {
    [self.circlesController didTapCircleWithIdentifier:overlayId];
  } else if ([self.groundOverlaysController hasGroundOverlaysWithIdentifier:overlayId]) {
    [self.groundOverlaysController didTapGroundOverlayWithIdentifier:overlayId];
  }
}

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
  [self.dartCallbackHandler didTapAtPosition:FGMGetPigeonLatLngForCoordinate(coordinate)
                                  completion:^(FlutterError *_Nullable _){
                                  }];
}

- (void)mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate {
  [self.dartCallbackHandler didLongPressAtPosition:FGMGetPigeonLatLngForCoordinate(coordinate)
                                        completion:^(FlutterError *_Nullable _){
                                        }];
}

- (void)interpretMapConfiguration:(FGMPlatformMapConfiguration *)config {
  FGMPlatformCameraTargetBounds *cameraTargetBounds = config.cameraTargetBounds;
  if (cameraTargetBounds) {
    [self setCameraTargetBounds:cameraTargetBounds.bounds
                                    ? FGMGetCoordinateBoundsForPigeonLatLngBounds(
                                          cameraTargetBounds.bounds)
                                    : nil];
  }
  NSNumber *compassEnabled = config.compassEnabled;
  if (compassEnabled != nil) {
    [self setCompassEnabled:compassEnabled.boolValue];
  }
  NSNumber *indoorEnabled = config.indoorViewEnabled;
  if (indoorEnabled != nil) {
    [self setIndoorEnabled:indoorEnabled.boolValue];
  }
  NSNumber *trafficEnabled = config.trafficEnabled;
  if (trafficEnabled != nil) {
    [self setTrafficEnabled:trafficEnabled.boolValue];
  }
  NSNumber *buildingsEnabled = config.buildingsEnabled;
  if (buildingsEnabled != nil) {
    [self setBuildingsEnabled:buildingsEnabled.boolValue];
  }
  FGMPlatformMapTypeBox *mapType = config.mapType;
  if (mapType) {
    [self setMapType:FGMGetMapViewTypeForPigeonMapType(mapType.value)];
  }
  FGMPlatformZoomRange *zoomData = config.minMaxZoomPreference;
  if (zoomData) {
    float minZoom = zoomData.min != nil ? zoomData.min.floatValue : kGMSMinZoomLevel;
    float maxZoom = zoomData.max != nil ? zoomData.max.floatValue : kGMSMaxZoomLevel;
    [self setMinZoom:minZoom maxZoom:maxZoom];
  }
  FGMPlatformEdgeInsets *padding = config.padding;
  if (padding) {
    [self setPaddingTop:padding.top left:padding.left bottom:padding.bottom right:padding.right];
  }

  NSNumber *rotateGesturesEnabled = config.rotateGesturesEnabled;
  if (rotateGesturesEnabled != nil) {
    [self setRotateGesturesEnabled:rotateGesturesEnabled.boolValue];
  }
  NSNumber *scrollGesturesEnabled = config.scrollGesturesEnabled;
  if (scrollGesturesEnabled != nil) {
    [self setScrollGesturesEnabled:scrollGesturesEnabled.boolValue];
  }
  NSNumber *tiltGesturesEnabled = config.tiltGesturesEnabled;
  if (tiltGesturesEnabled != nil) {
    [self setTiltGesturesEnabled:tiltGesturesEnabled.boolValue];
  }
  NSNumber *trackCameraPosition = config.trackCameraPosition;
  if (trackCameraPosition != nil) {
    [self setTrackCameraPosition:trackCameraPosition.boolValue];
  }
  NSNumber *zoomGesturesEnabled = config.zoomGesturesEnabled;
  if (zoomGesturesEnabled != nil) {
    [self setZoomGesturesEnabled:zoomGesturesEnabled.boolValue];
  }
  NSNumber *myLocationEnabled = config.myLocationEnabled;
  if (myLocationEnabled != nil) {
    [self setMyLocationEnabled:myLocationEnabled.boolValue];
  }
  NSNumber *myLocationButtonEnabled = config.myLocationButtonEnabled;
  if (myLocationButtonEnabled != nil) {
    [self setMyLocationButtonEnabled:myLocationButtonEnabled.boolValue];
  }
  NSString *style = config.style;
  if (style) {
    [self setMapStyle:style];
  }
}

@end

#pragma mark -

/// Private declarations of the FGMMapCallHandler.
@implementation FGMMapCallHandler

- (instancetype)initWithMapController:(nonnull FLTGoogleMapController *)controller
                            messenger:(NSObject<FlutterBinaryMessenger> *)messenger
                         pigeonSuffix:(NSString *)suffix {
  self = [super init];
  if (self) {
    _controller = controller;
    _messenger = messenger;
    _pigeonSuffix = suffix;
    _transactionWrapper = [[FGMCATransactionWrapper alloc] init];
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

- (void)updateHeatmapsByAdding:(nonnull NSArray<FGMPlatformHeatmap *> *)toAdd
                      changing:(nonnull NSArray<FGMPlatformHeatmap *> *)toChange
                      removing:(nonnull NSArray<NSString *> *)idsToRemove
                         error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  [self.controller.heatmapsController addHeatmaps:toAdd];
  [self.controller.heatmapsController changeHeatmaps:toChange];
  [self.controller.heatmapsController removeHeatmapsWithIdentifiers:idsToRemove];
}

- (void)updateWithMapConfiguration:(nonnull FGMPlatformMapConfiguration *)configuration
                             error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  [self.controller interpretMapConfiguration:configuration];
}

- (void)updateMarkersByAdding:(nonnull NSArray<FGMPlatformMarker *> *)toAdd
                     changing:(nonnull NSArray<FGMPlatformMarker *> *)toChange
                     removing:(nonnull NSArray<NSString *> *)idsToRemove
                        error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  [self.controller.markersController addMarkers:toAdd];
  [self.controller.markersController changeMarkers:toChange];
  [self.controller.markersController removeMarkersWithIdentifiers:idsToRemove];

  // Invoke clustering after markers are added.
  [self.controller.clusterManagersController invokeClusteringForEachClusterManager];
}

- (void)updateClusterManagersByAdding:(nonnull NSArray<FGMPlatformClusterManager *> *)toAdd
                             removing:(nonnull NSArray<NSString *> *)idsToRemove
                                error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  [self.controller.clusterManagersController addClusterManagers:toAdd];
  [self.controller.clusterManagersController removeClusterManagersWithIdentifiers:idsToRemove];
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

- (void)updateGroundOverlaysByAdding:(nonnull NSArray<FGMPlatformGroundOverlay *> *)toAdd
                            changing:(nonnull NSArray<FGMPlatformGroundOverlay *> *)toChange
                            removing:(nonnull NSArray<NSString *> *)idsToRemove
                               error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  [self.controller.groundOverlaysController addGroundOverlays:toAdd];
  [self.controller.groundOverlaysController changeGroundOverlays:toChange];
  [self.controller.groundOverlaysController removeGroundOverlaysWithIdentifiers:idsToRemove];
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
  GMSCameraUpdate *update = FGMGetCameraUpdateForPigeonCameraUpdate(cameraUpdate);
  if (!update) {
    *error = [FlutterError errorWithCode:@"Invalid update"
                                 message:@"Unrecognized camera update"
                                 details:nil];
    return;
  }
  [self.controller.mapView moveCamera:update];
}

- (void)animateCameraWithUpdate:(nonnull FGMPlatformCameraUpdate *)cameraUpdate
                       duration:(nullable NSNumber *)durationMilliseconds
                          error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  GMSCameraUpdate *update = FGMGetCameraUpdateForPigeonCameraUpdate(cameraUpdate);
  if (!update) {
    *error = [FlutterError errorWithCode:@"Invalid update"
                                 message:@"Unrecognized camera update"
                                 details:nil];
    return;
  }
  FGMCATransactionWrapper *transaction =
      durationMilliseconds != nil ? self.transactionWrapper : nil;
  [transaction begin];
  [transaction setAnimationDuration:[durationMilliseconds doubleValue] / 1000];
  [self.controller.mapView animateWithCameraUpdate:update];
  [transaction commit];
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

/// Private declarations of the FGMMapInspector.
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
    tileOverlayWithIdentifier:(nonnull NSString *)tileOverlayId
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

- (nullable FGMPlatformHeatmap *)
    heatmapWithIdentifier:(nonnull NSString *)heatmapId
                    error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  NSDictionary<NSString *, id> *heatmapInfo =
      [self.controller.heatmapsController heatmapInfoWithIdentifier:heatmapId];
  if (!heatmapInfo) {
    return nil;
  }
  return [FGMPlatformHeatmap makeWithJson:heatmapInfo];
}

- (nullable NSArray<FGMPlatformCluster *> *)
    clustersWithIdentifier:(NSString *)clusterManagerId
                     error:(FlutterError *_Nullable *_Nonnull)error {
  return [self.controller.clusterManagersController clustersWithIdentifier:clusterManagerId
                                                                     error:error];
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
  return [FGMPlatformZoomRange makeWithMin:@(self.controller.mapView.minZoom)
                                       max:@(self.controller.mapView.maxZoom)];
}

- (nullable FGMPlatformGroundOverlay *)
    groundOverlayWithIdentifier:(NSString *)groundOverlayId
                          error:(FlutterError *_Nullable __autoreleasing *)error {
  return [self.controller.groundOverlaysController groundOverlayWithIdentifier:groundOverlayId];
}

- (nullable FGMPlatformCameraPosition *)cameraPosition:
    (FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  return FGMGetPigeonCameraPositionForPosition(self.controller.mapView.camera);
}

@end
