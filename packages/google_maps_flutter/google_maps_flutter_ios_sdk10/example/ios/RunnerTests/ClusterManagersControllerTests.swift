// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import GoogleMaps
import Testing

@testable import google_maps_flutter_ios_sdk10

@MainActor struct ClusterManagersControllerTests {

  @Test func clustering() throws {
    let frame = CGRect(x: 0, y: 0, width: 100, height: 100)

    let mapViewOptions = GMSMapViewOptions()
    mapViewOptions.frame = frame
    mapViewOptions.camera = GMSCameraPosition(latitude: 0, longitude: 0, zoom: 0)

    let mapView = PartiallyMockedMapView(options: mapViewOptions)
    let eventHandler = TestMapEventHandler()

    let clusterManagersController = FGMClusterManagersController(
      mapView: mapView,
      eventDelegate: eventHandler
    )

    let markersController = FGMMarkersController(
      mapView: mapView,
      eventDelegate: eventHandler,
      clusterManagersController: clusterManagersController,
      assetProvider: TestAssetProvider(),
      markerType: .marker
    )

    // Add cluster managers.
    let clusterManagerId = "cm"
    let clusterManagerToAdd = FGMPlatformClusterManager.make(withIdentifier: clusterManagerId)
    clusterManagersController.add([clusterManagerToAdd])

    // Verify that cluster managers are available
    var clusterManager = clusterManagersController.clusterManager(withIdentifier: clusterManagerId)
    #expect(clusterManager != nil)

    // Add markers
    let markerId1 = "m1"
    let markerId2 = "m2"

    let zeroPoint = FGMPlatformPoint.makeWith(x: 0, y: 0)
    let zeroLatLng = FGMPlatformLatLng.make(withLatitude: 0, longitude: 0)
    let bitmap = FGMPlatformBitmap.make(
      withBitmap: FGMPlatformBitmapDefaultMarker.make(withHue: 0)
    )
    let infoWindow = FGMPlatformInfoWindow.make(
      withTitle: "Info",
      snippet: nil,
      anchor: zeroPoint
    )
    let marker1 = FGMPlatformMarker.make(
      withAlpha: 1,
      anchor: zeroPoint,
      consumeTapEvents: false,
      draggable: false,
      flat: false,
      icon: bitmap,
      infoWindow: infoWindow,
      position: zeroLatLng,
      rotation: 0,
      visible: true,
      zIndex: 1,
      markerId: markerId1,
      clusterManagerId: clusterManagerId,
      collisionBehavior: nil
    )
    let marker2 = FGMPlatformMarker.make(
      withAlpha: 1,
      anchor: zeroPoint,
      consumeTapEvents: false,
      draggable: false,
      flat: false,
      icon: bitmap,
      infoWindow: infoWindow,
      position: zeroLatLng,
      rotation: 0,
      visible: true,
      zIndex: 1,
      markerId: markerId2,
      clusterManagerId: clusterManagerId,
      collisionBehavior: nil
    )

    markersController.add([marker1, marker2])

    // Invoke clustering
    clusterManagersController.invokeClusteringForEachClusterManager()

    // Verify that the markers were added to the cluster manager
    var error: FlutterError? = nil
    let clusters1 = try #require(
      clusterManagersController.clusters(withIdentifier: clusterManagerId, error: &error)
    )
    #expect(error == nil)
    let targetCluster = try #require(
      clusters1.first(where: { $0.clusterManagerId == clusterManagerId })
    )
    #expect(targetCluster.markerIds.count == 2)
    #expect(targetCluster.markerIds.contains(markerId1))
    #expect(targetCluster.markerIds.contains(markerId2))

    markersController.removeMarkers(withIdentifiers: [markerId2])

    // Verify that the marker2 is removed from the clusterManager
    error = nil
    let clusters2 = try #require(
      clusterManagersController.clusters(withIdentifier: clusterManagerId, error: &error)
    )
    #expect(error == nil)
    let targetCluster2 = try #require(
      clusters2.first(where: { $0.clusterManagerId == clusterManagerId })
    )
    #expect(targetCluster2.markerIds.count == 1)
    #expect(targetCluster2.markerIds.contains(markerId1))

    markersController.removeMarkers(withIdentifiers: [markerId1])

    // Verify that all markers are removed from clusterManager
    error = nil
    let clusters3 = try #require(
      clusterManagersController.clusters(withIdentifier: clusterManagerId, error: &error)
    )
    #expect(error == nil)
    #expect(clusters3.count == 0)

    // Remove cluster manager
    clusterManagersController.removeClusterManagers(withIdentifiers: [clusterManagerId])

    // Verify that the cluster manager is removed
    clusterManager = clusterManagersController.clusterManager(withIdentifier: clusterManagerId)
    #expect(clusterManager == nil)
  }
}
