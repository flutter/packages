// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#if canImport(google_maps_flutter_ios_sdk10_objc)
  import google_maps_flutter_ios_sdk10_objc
#endif

/// Converts a GMUCluster to its Pigeon representation.
func pigeonCluster(for cluster: GMUCluster, clusterManagerIdentifier: String) -> FGMPlatformCluster
{
  var bounds = GMSCoordinateBounds()
  for item in cluster.items {
    bounds = bounds.includingCoordinate(item.position)
  }

  let markerIds = cluster.items.filter { $0 is GMSMarker }.compactMap {
    markerIdentifierFromMarker($0 as! GMSMarker)
  }

  return FGMPlatformCluster.make(
    withClusterManagerId: clusterManagerIdentifier,
    position: FGMGetPigeonLatLngForCoordinate(cluster.position),
    bounds: FGMGetPigeonLatLngBoundsForCoordinateBounds(bounds),
    markerIds: markerIds
  )
}
