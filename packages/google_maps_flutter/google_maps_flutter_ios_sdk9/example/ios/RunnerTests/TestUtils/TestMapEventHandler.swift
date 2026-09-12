// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

@testable import google_maps_flutter_ios_sdk9

/// Fake implementation of MapEventDelegate for unit tests.
class TestMapEventHandler: MapEventDelegate {
  func didStartCameraMove(completion: @escaping (Result<Void, PigeonError>) -> Void) {}

  func didMoveCamera(
    to cameraPositionArg: PlatformCameraPosition,
    completion:
      @escaping (
        Result<Void, PigeonError>
      ) -> Void
  ) {}

  func didIdleCamera(completion: @escaping (Result<Void, PigeonError>) -> Void) {}

  func didTap(
    at positionArg: PlatformLatLng,
    completion:
      @escaping (
        Result<Void, PigeonError>
      ) -> Void
  ) {}

  func didLongPress(
    at positionArg: PlatformLatLng,
    completion:
      @escaping (
        Result<Void, PigeonError>
      ) -> Void
  ) {}

  func didTapMarker(
    withIdentifier markerIdArg: String,
    completion: @escaping (Result<Void, PigeonError>) -> Void
  ) {}

  func didStartDragForMarker(
    withIdentifier markerIdArg: String,
    at positionArg: PlatformLatLng,
    completion: @escaping (Result<Void, PigeonError>) -> Void
  ) {}

  func didDragMarker(
    withIdentifier markerIdArg: String,
    at positionArg: PlatformLatLng,
    completion: @escaping (Result<Void, PigeonError>) -> Void
  ) {}

  func didEndDragForMarker(
    withIdentifier markerIdArg: String,
    at positionArg: PlatformLatLng,
    completion:
      @escaping (
        Result<Void, PigeonError>
      ) -> Void
  ) {}

  func didTapInfoWindowOfMarker(
    withIdentifier markerIdArg: String,
    completion:
      @escaping (
        Result<Void, PigeonError>
      ) -> Void
  ) {}

  func didTapCircle(
    withIdentifier circleIdArg: String,
    completion: @escaping (Result<Void, PigeonError>) -> Void
  ) {}

  func didTapCluster(
    _ clusterArg: PlatformCluster,
    completion:
      @escaping (
        Result<Void, PigeonError>
      ) -> Void
  ) {}

  func didTapPolygon(
    withIdentifier polygonIdArg: String,
    completion:
      @escaping (
        Result<Void, PigeonError>
      ) -> Void
  ) {}

  func didTapPolyline(
    withIdentifier polylineIdArg: String,
    completion: @escaping (Result<Void, PigeonError>) -> Void
  ) {}

  func didTapGroundOverlay(
    withIdentifier groundOverlayIdArg: String,
    completion:
      @escaping (
        Result<Void, PigeonError>
      ) -> Void
  ) {}

  func tile(
    withOverlayIdentifier tileOverlayIdArg: String,
    location locationArg: PlatformPoint,
    zoom zoomArg: Int64,
    completion:
      @escaping (
        Result<PlatformTile, PigeonError>
      ) -> Void
  ) {}
}
