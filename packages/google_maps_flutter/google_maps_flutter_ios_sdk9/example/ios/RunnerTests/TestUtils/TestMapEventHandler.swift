// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import google_maps_flutter_ios_sdk9

/// Fake implementation of FGMMapEventDelegate for unit tests.
class TestMapEventHandler: NSObject, FGMMapEventDelegate {
  func didStartCameraMove() {}

  func didMoveCamera(to cameraPosition: FGMPlatformCameraPosition) {}

  func didIdleCamera() {}

  func didTap(atPosition position: FGMPlatformLatLng) {}

  func didLongPress(atPosition position: FGMPlatformLatLng) {}

  func didTapMarker(withIdentifier markerId: String) {}

  func didStartDragForMarker(
    withIdentifier markerId: String, atPosition position: FGMPlatformLatLng
  ) {}

  func didDragMarker(withIdentifier markerId: String, atPosition position: FGMPlatformLatLng) {}

  func didEndDragForMarker(withIdentifier markerId: String, atPosition position: FGMPlatformLatLng)
  {}

  func didTapInfoWindowOfMarker(withIdentifier markerId: String) {}

  func didTapCircle(withIdentifier circleId: String) {}

  func didTap(_ cluster: FGMPlatformCluster) {}

  func didTapPolygon(withIdentifier polygonId: String) {}

  func didTapPolyline(withIdentifier polylineId: String) {}

  func didTapGroundOverlay(withIdentifier groundOverlayId: String) {}
}
