// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import GoogleMaps
import google_maps_flutter_ios_sdk9_objc

/// A controller that manages all of the cluster managers on a map.
class ClusterManagersController: NSObject {
  private var clusterManagerIdentifierToManagers: [String: GMUClusterManager] = [:]
  private weak var eventDelegate: FGMMapEventDelegate?
  private weak var mapView: GMSMapView?

  init(mapView: GMSMapView, eventDelegate: FGMMapEventDelegate) {
    self.mapView = mapView
    self.eventDelegate = eventDelegate
    super.init()
  }

  func addClusterManagers(_ clusterManagersToAdd: [FGMPlatformClusterManager]) {
    for clusterManager in clusterManagersToAdd {
      let identifier = clusterManager.identifier
      addClusterManager(identifier)
    }
  }

  func addClusterManager(_ identifier: String) {
    let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
    let iconGenerator = GMUDefaultClusterIconGenerator()
    guard let mapView = mapView else { return }
    let renderer = GMUDefaultClusterRenderer(mapView: mapView, clusterIconGenerator: iconGenerator)
    clusterManagerIdentifierToManagers[identifier] = GMUClusterManager(
      map: mapView,
      algorithm: algorithm,
      renderer: renderer
    )
  }

  func removeClusterManagers(withIdentifiers identifiers: [String]) {
    for identifier in identifiers {
      if let clusterManager = clusterManagerIdentifierToManagers[identifier] {
        clusterManager.clearItems()
        clusterManagerIdentifierToManagers.removeValue(forKey: identifier)
      }
    }
  }

  func clusterManager(withIdentifier identifier: String) -> GMUClusterManager? {
    return clusterManagerIdentifierToManagers[identifier]
  }

  func invokeClusteringForEachClusterManager() {
    for clusterManager in clusterManagerIdentifierToManagers.values {
      clusterManager.cluster()
    }
  }

  func clusters(
    withIdentifier identifier: String,
    error: AutoreleasingUnsafeMutablePointer<FlutterError?>
  ) -> [FGMPlatformCluster]? {
    guard let clusterManager = clusterManagerIdentifierToManagers[identifier] else {
      error.pointee = FlutterError(
        code: "Invalid clusterManagerId",
        message: "getClusters called with invalid clusterManagerId",
        details: "clusterManagerId was: '\(identifier)'"
      )
      return nil
    }

    // Ref:
    // https://github.com/googlemaps/google-maps-ios-utils/blob/0e7ed81f1bbd9d29e4529c40ae39b0791b0a0eb8/src/Clustering/GMUClusterManager.m#L94.
    guard let mapView = mapView else { return [] }
    let integralZoom = UInt(floorf(Float(mapView.camera.zoom) + 0.5))
    guard let clusters = clusterManager.algorithm.clusters(atZoom: integralZoom) as? [GMUCluster] else {
      return []
    }
    return clusters.map { FGMGetPigeonCluster($0, identifier) }
  }

  func didTapCluster(_ cluster: GMUStaticCluster) {
    guard let clusterManagerId = clusterManagerIdentifier(for: cluster) else { return }
    let platformCluster = FGMGetPigeonCluster(cluster, clusterManagerId)
    eventDelegate?.didTapCluster(platformCluster)
  }

  // MARK: - Private methods

  /// Returns the cluster manager identifier for given cluster.
  ///
  /// - Returns: The cluster manager identifier if found; otherwise, nil.
  private func clusterManagerIdentifier(for cluster: GMUStaticCluster) -> String? {
    if let firstMarker = cluster.items.first as? GMSMarker {
      return clusterManagerIdentifierFromMarker(firstMarker)
    }
    return nil
  }
}
