// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

@testable import google_maps_flutter_ios_sdk9

/// Fake implementation of MapEventDelegate for unit tests.
class TestMapEventHandler: MapEventDelegate {
  func didStartCameraMove() {}

  func didMoveCamera(to cameraPosition: PlatformCameraPosition) {}

  func didIdleCamera() {}

  func didTap(at position: PlatformLatLng) {}

  func didLongPress(at position: PlatformLatLng) {}

  func didTapMarker(withIdentifier markerId: String) {}

  func didStartDragForMarker(
    withIdentifier markerId: String, at position: PlatformLatLng
  ) {}

  func didDragMarker(withIdentifier markerId: String, at position: PlatformLatLng) {}

  func didEndDragForMarker(withIdentifier markerId: String, at position: PlatformLatLng) {}

  func didTapInfoWindowOfMarker(withIdentifier markerId: String) {}

  func didTapCircle(withIdentifier circleId: String) {}

  func didTapCluster(_ cluster: PlatformCluster) {}

  func didTapPolygon(withIdentifier polygonId: String) {}

  func didTapPolyline(withIdentifier polylineId: String) {}

  func didTapGroundOverlay(withIdentifier groundOverlayId: String) {}
}
