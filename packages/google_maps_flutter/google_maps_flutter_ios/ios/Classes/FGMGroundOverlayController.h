// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <GoogleMaps/GoogleMaps.h>

#import "messages.g.h"

/// Controller of a single ground overlay  on the map.
@interface FGMGroundOverlayController : NSObject

/// The ground overlay this controller handles.
@property(strong, nonatomic) GMSGroundOverlay *_Nonnull groundOverlay;

/// Whether ground overlay is created with bounds or position.
@property(nonatomic, assign) BOOL isCreatedWithBounds;

/// Zoom level when ground overlay is initialized with position.
@property(nonatomic, strong, nullable) NSNumber *zoomLevel;

/// Initializes an instance of this class with a GMSGroundOverlay, a map view, and identifier.
- (instancetype _Nullable)initWithGroundOverlay:(GMSGroundOverlay *_Nonnull)groundOverlay
                                     identifier:(NSString *_Nonnull)identifier
                                        mapView:(GMSMapView *_Nonnull)mapView
                            isCreatedWithBounds:(BOOL)isCreatedWithBounds;

/// Removes this ground overlay from the map.
- (void)removeGroundOverlay;
@end

/// Controller of multiple ground overlays on the map.
@interface FLTGroundOverlaysController : NSObject

/// Initializes the controller with a GMSMapView, callback handler and registrar.
- (instancetype _Nullable)initWithMapView:(GMSMapView *_Nonnull)mapView
                          callbackHandler:(FGMMapsCallbackApi *_Nonnull)callbackHandler
                                registrar:(NSObject<FlutterPluginRegistrar> *_Nonnull)registrar;

/// Adds ground overlays to the map.
- (void)addGroundOverlays:(NSArray<FGMPlatformGroundOverlay *> *_Nonnull)groundOverlaysToAdd;

/// Updates ground overlays on the map.
- (void)changeGroundOverlays:(NSArray<FGMPlatformGroundOverlay *> *_Nonnull)groundOverlaysToChange;

/// Removes ground overlays from the map.
- (void)removeGroundOverlaysWithIdentifiers:(NSArray<NSString *> *_Nonnull)identifiers;

/// Called when a ground overlay is tapped on the map.
- (void)didTapGroundOverlayWithIdentifier:(NSString *_Nonnull)identifier;

/// Returns true if a ground overlay with the given identifier exists on the map.
- (bool)hasGroundOverlaysWithIdentifier:(NSString *_Nonnull)identifier;

/// Returns FGMPlatformGroundOverlay for identifier.
- (nullable FGMPlatformGroundOverlay *)groundOverlayWithIdentifier:(NSString *_Nonnull)identifier;
@end
