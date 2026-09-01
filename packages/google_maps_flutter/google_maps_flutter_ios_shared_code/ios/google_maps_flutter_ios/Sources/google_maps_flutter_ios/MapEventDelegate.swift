// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#if canImport(google_maps_flutter_ios_objc)
  import google_maps_flutter_ios_objc
#endif

/// Delegate for map event notifications.
///
/// This is abstraction of the map event portions of FGMMapsCallbackApi, to
/// avoid coupling all the individual controllers to the Pigeon implementation
/// of event handling, and to allow for mocks/fakes in unit tests.
protocol MapEventDelegate: AnyObject {
  /// Called when the map camera starts moving.
  func didStartCameraMove()

  /// Called when the map camera moves.
  func didMoveCamera(to cameraPosition: FGMPlatformCameraPosition)

  /// Called when the map camera stops moving.
  func didIdleCamera()

  /// Called when the map, not a specifc map object, is tapped.
  func didTap(at position: FGMPlatformLatLng)

  /// Called when the map, not a specifc map object, is long pressed.
  func didLongPress(at position: FGMPlatformLatLng)

  /// Called when a marker is tapped.
  func didTapMarker(withIdentifier markerId: String)

  /// Called when a marker drag starts.
  func didStartDragForMarker(withIdentifier markerId: String, at position: FGMPlatformLatLng)

  /// Called when a marker drag updates.
  func didDragMarker(withIdentifier markerId: String, at position: FGMPlatformLatLng)

  /// Called when a marker drag ends.
  func didEndDragForMarker(withIdentifier markerId: String, at position: FGMPlatformLatLng)

  /// Called when a marker's info window is tapped.
  func didTapInfoWindowOfMarker(withIdentifier markerId: String)

  /// Called when a circle is tapped.
  func didTapCircle(withIdentifier circleId: String)

  /// Called when a marker cluster is tapped.
  func didTapCluster(_ cluster: FGMPlatformCluster)

  /// Called when a polygon is tapped.
  func didTapPolygon(withIdentifier polygonId: String)

  /// Called when a polyline is tapped.
  func didTapPolyline(withIdentifier polylineId: String)

  /// Called when a ground overlay is tapped.
  func didTapGroundOverlay(withIdentifier groundOverlayId: String)
}
