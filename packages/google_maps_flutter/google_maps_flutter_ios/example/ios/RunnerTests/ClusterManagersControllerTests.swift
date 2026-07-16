// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest
import GoogleMaps
import Flutter
@testable import google_maps_flutter_ios

class ClusterManagersControllerTests: XCTestCase {

  func testClustering() {
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
    XCTAssertNotNil(clusterManager, "Cluster Manager should not be nil")

    // Add markers
    let markerId1 = "m1"
    let markerId2 = "m2"

    let zeroPoint = FGMPlatformPoint.makeWith(x:0, y: 0)
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
    // Note: Swift bridging of clustersWithIdentifier:error:
    var error: FlutterError? = nil
    if let clusters1 = clusterManagersController.clusters(withIdentifier: clusterManagerId, error: &error) {
      XCTAssertNil(error, "Error should be nil")
      var found = false
      for cluster in clusters1 {
        let cmId = cluster.clusterManagerId
        XCTAssertNotNil(cmId, "Cluster Manager Identifier should not be nil")
        if cmId == clusterManagerId {
          let markerIds = cluster.markerIds
          XCTAssertEqual(markerIds.count, 2, "Cluster should contain two markers")
          XCTAssertTrue(markerIds.contains(markerId1), "Cluster should contain markerId1")
          XCTAssertTrue(markerIds.contains(markerId2), "Cluster should contain markerId2")
          found = true
          break
        }
      }
      XCTAssertTrue(found)
    } else {
      XCTFail("Clusters should not be nil, error: \(String(describing: error))")
    }

    markersController.removeMarkers(withIdentifiers: [markerId2])

    // Verify that the marker2 is removed from the clusterManager
    error = nil
    if let clusters2 = clusterManagersController.clusters(withIdentifier: clusterManagerId, error: &error) {
      XCTAssertNil(error, "Error should be nil")
      var found = false
      for cluster in clusters2 {
        let cmId = cluster.clusterManagerId
        XCTAssertNotNil(cmId, "Cluster Manager ID should not be nil")
        if cmId == clusterManagerId {
          let markerIds = cluster.markerIds
          XCTAssertEqual(markerIds.count, 1, "Cluster should contain one marker")
          XCTAssertTrue(markerIds.contains(markerId1), "Cluster should contain markerId1")
          found = true
          break
        }
      }
      XCTAssertTrue(found)
    } else {
      XCTFail("Clusters should not be nil, error: \(String(describing: error))")
    }

    markersController.removeMarkers(withIdentifiers: [markerId1])

    // Verify that all markers are removed from clusterManager
    error = nil
    if let clusters3 = clusterManagersController.clusters(withIdentifier: clusterManagerId, error: &error) {
      XCTAssertNil(error, "Error should be nil")
      XCTAssertEqual(clusters3.count, 0, "Cluster Manager should not contain any clusters")
    } else {
      XCTFail("Clusters should not be nil, error: \(String(describing: error))")
    }

    // Remove cluster manager
    clusterManagersController.removeClusterManagers(withIdentifiers: [clusterManagerId])

    // Verify that the cluster manager is removed
    clusterManager = clusterManagersController.clusterManager(withIdentifier: clusterManagerId)
    XCTAssertNil(clusterManager, "Cluster Manager should be nil")
  }
}
