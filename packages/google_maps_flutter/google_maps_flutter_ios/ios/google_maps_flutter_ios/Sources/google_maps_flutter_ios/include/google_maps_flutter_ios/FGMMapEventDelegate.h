// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Foundation;

#import "google_maps_flutter_pigeon_messages.g.h"

NS_ASSUME_NONNULL_BEGIN

/// Delegate for map event notifications.
@protocol FGMMapEventDelegate <NSObject>

/// Called when the map camera starts moving.
- (void)didStartCameraMove;

/// Called when the map camera moves.
- (void)didMoveCameraToPosition:(FGMPlatformCameraPosition *)cameraPosition;

/// Called when the map camera stops moving.
- (void)didIdleCamera;

/// Called when the map, not a specifc map object, is tapped.
- (void)didTapAtPosition:(FGMPlatformLatLng *)position;

/// Called when the map, not a specifc map object, is long pressed.
- (void)didLongPressAtPosition:(FGMPlatformLatLng *)position;

/// Called when a marker is tapped.
- (void)didTapMarkerWithIdentifier:(NSString *)markerId;

/// Called when a marker drag starts.
- (void)didStartDragForMarkerWithIdentifier:(NSString *)markerId
                                 atPosition:(FGMPlatformLatLng *)position;

/// Called when a marker drag updates.
- (void)didDragMarkerWithIdentifier:(NSString *)markerId atPosition:(FGMPlatformLatLng *)position;

/// Called when a marker drag ends.
- (void)didEndDragForMarkerWithIdentifier:(NSString *)markerId
                               atPosition:(FGMPlatformLatLng *)position;

/// Called when a marker's info window is tapped.
- (void)didTapInfoWindowOfMarkerWithIdentifier:(NSString *)markerId;

/// Called when a circle is tapped.
- (void)didTapCircleWithIdentifier:(NSString *)circleId;

/// Called when a marker cluster is tapped.
- (void)didTapCluster:(FGMPlatformCluster *)cluster;

/// Called when a polygon is tapped.
- (void)didTapPolygonWithIdentifier:(NSString *)polygonId;

/// Called when a polyline is tapped.
- (void)didTapPolylineWithIdentifier:(NSString *)polylineId;

/// Called when a ground overlay is tapped.
- (void)didTapGroundOverlayWithIdentifier:(NSString *)groundOverlayId;

@end

NS_ASSUME_NONNULL_END
