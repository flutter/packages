// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

@testable import google_maps_flutter_ios_sdk10

/// Fake implementation of MapEventDelegate for unit tests.
class TestMapEventHandler: MapEventDelegate {
  func didStartCameraMove() async throws {}

  func didMoveCamera(to cameraPositionArg: PlatformCameraPosition) async throws {}

  func didIdleCamera() async throws {}

  func didTap(at positionArg: PlatformLatLng) async throws {}

  func didLongPress(at positionArg: PlatformLatLng) async throws {}

  func didTapMarker(withIdentifier markerIdArg: String) async throws {}

  func didStartDragForMarker(
    withIdentifier markerIdArg: String,
    at positionArg: PlatformLatLng
  ) async throws {}

  func didDragMarker(
    withIdentifier markerIdArg: String,
    at positionArg: PlatformLatLng
  ) async throws {}

  func didEndDragForMarker(
    withIdentifier markerIdArg: String,
    at positionArg: PlatformLatLng
  ) async throws {}

  func didTapInfoWindowOfMarker(withIdentifier markerIdArg: String) async throws {}

  func didTapCircle(withIdentifier circleIdArg: String) async throws {}

  func didTapCluster(_ clusterArg: PlatformCluster) async throws {}

  func didTapPolygon(withIdentifier polygonIdArg: String) async throws {}

  func didTapPolyline(withIdentifier polylineIdArg: String) async throws {}

  func didTapGroundOverlay(withIdentifier groundOverlayIdArg: String) async throws {}

  func tile(
    withOverlayIdentifier tileOverlayIdArg: String,
    location locationArg: PlatformPoint,
    zoom zoomArg: Int64
  ) async throws -> PlatformTile {
    return PlatformTile(width: 0, height: 0)
  }
}
