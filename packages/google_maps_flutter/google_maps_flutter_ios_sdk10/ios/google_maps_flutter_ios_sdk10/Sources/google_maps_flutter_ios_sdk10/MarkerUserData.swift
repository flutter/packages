// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import GoogleMaps

/// Defines user data object for markers.
class MarkerUserData: NSObject {
  /// The identifier of the marker.
  var markerIdentifier: String

  /// The identifier of the cluster manager.
  /// This property is set only if the marker is managed by a cluster manager.
  var clusterManagerIdentifier: String?

  init(markerIdentifier: String, clusterManagerIdentifier: String?) {
    self.markerIdentifier = markerIdentifier
    self.clusterManagerIdentifier = clusterManagerIdentifier
    super.init()
  }
}

/// Associates a marker identifier and optionally a cluster manager identifier with a marker's user
/// data.
func setIdentifiersToMarkerUserData(
  markerIdentifier: String,
  clusterManagerIdentifier: String?,
  marker: GMSMarker
) {
  marker.userData = MarkerUserData(
    markerIdentifier: markerIdentifier,
    clusterManagerIdentifier: clusterManagerIdentifier
  )
}

/// Get the marker identifier from marker's user data.
///
/// - Returns: The marker identifier if found; otherwise, nil.
func markerIdentifierFromMarker(_ marker: GMSMarker) -> String? {
  return (marker.userData as? MarkerUserData)?.markerIdentifier
}

/// Get the cluster manager identifier from marker's user data.
///
/// - Returns: The cluster manager identifier if found; otherwise, nil.
func clusterManagerIdentifierFromMarker(_ marker: GMSMarker) -> String? {
  return (marker.userData as? MarkerUserData)?.clusterManagerIdentifier
}
