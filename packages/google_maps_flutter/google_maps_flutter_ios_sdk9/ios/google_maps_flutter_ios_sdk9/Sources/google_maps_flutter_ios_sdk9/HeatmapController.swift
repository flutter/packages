// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import GoogleMaps
import GoogleMapsUtils

/// Controller of a single Heatmap on the map.
class HeatmapController {
  let heatmapTileLayer: GMUHeatmapTileLayer
  private weak var mapView: GMSMapView?

  init(heatmap: PlatformHeatmap, tileLayer: GMUHeatmapTileLayer, mapView: GMSMapView) {
    self.heatmapTileLayer = tileLayer
    self.mapView = mapView
    HeatmapController.update(tileLayer, from: heatmap, mapView: mapView)
  }

  func removeHeatmap() {
    heatmapTileLayer.map = nil
  }

  func clearTileCache() {
    heatmapTileLayer.clearTileCache()
  }

  func update(from platformHeatmap: PlatformHeatmap) {
    if let mapView = mapView {
      HeatmapController.update(heatmapTileLayer, from: platformHeatmap, mapView: mapView)
    }
  }

  /// Updates the underlying GMUHeatmapTileLayer with the properties from the given platform heatmap.
  ///
  /// Setting the heatmap to visible will set its map to the given mapView.
  static func update(
    _ heatmapTileLayer: GMUHeatmapTileLayer,
    from platformHeatmap: PlatformHeatmap,
    mapView: GMSMapView
  ) {
    heatmapTileLayer.weightedData = platformHeatmap.data.map({ $0.toGMUWeightedLatLng() })
    if let gradient = platformHeatmap.gradient {
      heatmapTileLayer.gradient = gradient.toGMUGradient()
    }
    heatmapTileLayer.opacity = Float(platformHeatmap.opacity)
    heatmapTileLayer.radius = UInt(platformHeatmap.radius)
    heatmapTileLayer.minimumZoomIntensity = UInt(platformHeatmap.minimumZoomIntensity)
    heatmapTileLayer.maximumZoomIntensity = UInt(platformHeatmap.maximumZoomIntensity)

    // The map must be set each time for options to update.
    // This must be done last, to avoid visual flickers of default property values.
    heatmapTileLayer.map = mapView
  }
}

/// Controller of multiple Heatmaps on the map.
class HeatmapsController {
  private var heatmapIdToController: [String: HeatmapController] = [:]
  private weak var mapView: GMSMapView?

  init(mapView: GMSMapView) {
    self.mapView = mapView
  }

  func add(_ heatmapsToAdd: [PlatformHeatmap]) {
    guard let mapView = mapView else { return }
    for heatmap in heatmapsToAdd {
      let heatmapTileLayer = GMUHeatmapTileLayer()
      let controller = HeatmapController(
        heatmap: heatmap,
        tileLayer: heatmapTileLayer,
        mapView: mapView
      )
      heatmapIdToController[heatmap.heatmapId] = controller
    }
  }

  func change(_ heatmapsToChange: [PlatformHeatmap]) {
    for heatmap in heatmapsToChange {
      if let controller = heatmapIdToController[heatmap.heatmapId] {
        controller.update(from: heatmap)
        controller.clearTileCache()
      }
    }
  }

  func removeHeatmaps(withIdentifiers identifiers: [String]) {
    for heatmapId in identifiers {
      if let controller = heatmapIdToController[heatmapId] {
        controller.removeHeatmap()
        heatmapIdToController.removeValue(forKey: heatmapId)
      }
    }
  }

  func hasHeatmap(withIdentifier identifier: String) -> Bool {
    return heatmapIdToController[identifier] != nil
  }

  func heatmap(withIdentifier identifier: String) -> PlatformHeatmap? {
    guard let controller = heatmapIdToController[identifier] else { return nil }
    let heatmap = controller.heatmapTileLayer
    return PlatformHeatmap(
      heatmapId: identifier,
      data: heatmap.weightedData.map { PlatformWeightedLatLng.make(from: $0) },
      gradient: PlatformHeatmapGradient.make(from: heatmap.gradient),
      opacity: Double(heatmap.opacity),
      radius: Int64(heatmap.radius),
      minimumZoomIntensity: Int64(heatmap.minimumZoomIntensity),
      maximumZoomIntensity: Int64(heatmap.maximumZoomIntensity)
    )
  }
}
