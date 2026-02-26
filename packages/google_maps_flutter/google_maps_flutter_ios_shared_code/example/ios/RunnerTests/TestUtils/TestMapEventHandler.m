// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "TestMapEventHandler.h"

@implementation TestMapEventHandler

- (void)didStartCameraMove {
}

- (void)didMoveCameraToPosition:(FGMPlatformCameraPosition *)cameraPosition {
}

- (void)didIdleCamera {
}

- (void)didTapAtPosition:(FGMPlatformLatLng *)position {
}

- (void)didLongPressAtPosition:(FGMPlatformLatLng *)position {
}

- (void)didTapMarkerWithIdentifier:(NSString *)markerId {
}

- (void)didStartDragForMarkerWithIdentifier:(NSString *)markerId
                                 atPosition:(FGMPlatformLatLng *)position {
}

- (void)didDragMarkerWithIdentifier:(NSString *)markerId atPosition:(FGMPlatformLatLng *)position {
}

- (void)didEndDragForMarkerWithIdentifier:(NSString *)markerId
                               atPosition:(FGMPlatformLatLng *)position {
}

- (void)didTapInfoWindowOfMarkerWithIdentifier:(NSString *)markerId {
}

- (void)didTapCircleWithIdentifier:(NSString *)circleId {
}

- (void)didTapCluster:(FGMPlatformCluster *)cluster {
}

- (void)didTapPolygonWithIdentifier:(NSString *)polygonId {
}

- (void)didTapPolylineWithIdentifier:(NSString *)polylineId {
}

- (void)didTapGroundOverlayWithIdentifier:(NSString *)groundOverlayId {
}

@end
