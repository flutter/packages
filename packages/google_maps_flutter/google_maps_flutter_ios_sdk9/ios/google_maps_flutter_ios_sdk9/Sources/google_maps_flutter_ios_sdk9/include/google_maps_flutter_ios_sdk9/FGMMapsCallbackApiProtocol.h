// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Foundation;

#import "google_maps_flutter_pigeon_messages.g.h"

NS_ASSUME_NONNULL_BEGIN

/// Protocol for FGMMapsCallbackApi to allow mocking in tests.
///
/// This is a one-to-one abstraction of the Pigeon-generated API, so that unit tests can inject a
/// fake in place of the real implementation rather than asserting on Pigeon channel internals.
@protocol FGMMapsCallbackApiProtocol <NSObject>

/// Called when the map camera starts moving.
- (void)didStartCameraMoveWithCompletion:(void (^)(FlutterError *_Nullable))completion;

/// Called when the map camera moves.
- (void)didMoveCameraToPosition:(FGMPlatformCameraPosition *)cameraPosition
                     completion:(void (^)(FlutterError *_Nullable))completion;

/// Called when the map camera stops moving.
- (void)didIdleCameraWithCompletion:(void (^)(FlutterError *_Nullable))completion;

/// Called when the map, not a specifc map object, is tapped.
- (void)didTapAtPosition:(FGMPlatformLatLng *)position
              completion:(void (^)(FlutterError *_Nullable))completion;

/// Called when the map, not a specifc map object, is long pressed.
- (void)didLongPressAtPosition:(FGMPlatformLatLng *)position
                    completion:(void (^)(FlutterError *_Nullable))completion;

/// Called when a marker is tapped.
- (void)didTapMarkerWithIdentifier:(NSString *)markerId
                        completion:(void (^)(FlutterError *_Nullable))completion;

/// Called when a marker drag starts.
- (void)didStartDragForMarkerWithIdentifier:(NSString *)markerId
                                 atPosition:(FGMPlatformLatLng *)position
                                 completion:(void (^)(FlutterError *_Nullable))completion;

/// Called when a marker drag updates.
- (void)didDragMarkerWithIdentifier:(NSString *)markerId
                         atPosition:(FGMPlatformLatLng *)position
                         completion:(void (^)(FlutterError *_Nullable))completion;

/// Called when a marker drag ends.
- (void)didEndDragForMarkerWithIdentifier:(NSString *)markerId
                               atPosition:(FGMPlatformLatLng *)position
                               completion:(void (^)(FlutterError *_Nullable))completion;

/// Called when a marker's info window is tapped.
- (void)didTapInfoWindowOfMarkerWithIdentifier:(NSString *)markerId
                                    completion:(void (^)(FlutterError *_Nullable))completion;

/// Called when a circle is tapped.
- (void)didTapCircleWithIdentifier:(NSString *)circleId
                        completion:(void (^)(FlutterError *_Nullable))completion;

/// Called when a point of interest is tapped.
- (void)didTapPointOfInterestWithPlaceIdentifier:(NSString *)placeIdentifier
                                      completion:(void (^)(FlutterError *_Nullable))completion;

/// Called when a marker cluster is tapped.
- (void)didTapCluster:(FGMPlatformCluster *)cluster
           completion:(void (^)(FlutterError *_Nullable))completion;

/// Called when a polygon is tapped.
- (void)didTapPolygonWithIdentifier:(NSString *)polygonId
                         completion:(void (^)(FlutterError *_Nullable))completion;

/// Called when a polyline is tapped.
- (void)didTapPolylineWithIdentifier:(NSString *)polylineId
                          completion:(void (^)(FlutterError *_Nullable))completion;

/// Called when a ground overlay is tapped.
- (void)didTapGroundOverlayWithIdentifier:(NSString *)groundOverlayId
                               completion:(void (^)(FlutterError *_Nullable))completion;

/// Called to get data for a map tile.
- (void)tileWithOverlayIdentifier:(NSString *)tileOverlayId
                         location:(FGMPlatformPoint *)location
                             zoom:(NSInteger)zoom
                       completion:(void (^)(FGMPlatformTile *_Nullable,
                                            FlutterError *_Nullable))completion;

@end

NS_ASSUME_NONNULL_END
