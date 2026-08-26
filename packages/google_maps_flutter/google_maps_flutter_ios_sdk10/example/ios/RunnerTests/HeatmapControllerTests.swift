// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import GoogleMaps
import GoogleMapsUtils
import Testing

@testable import google_maps_flutter_ios_sdk10

@MainActor struct HeatmapControllerTests {

  @Test func updateHeatmapSetsVisibilityLast() {
    let heatmap = PropertyOrderValidatingHeatmap()
    let gradient = FGMPlatformHeatmapGradient.make(
      with: [
        FGMPlatformColor.make(withRed: 0, green: 0, blue: 0, alpha: 0),
        FGMPlatformColor.make(withRed: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
      ],
      startPoints: [0 as NSNumber, 1 as NSNumber],
      colorMapSize: 256
    )
    FGMHeatmapController.updateHeatmap(
      heatmap,
      from: FGMPlatformHeatmap.make(
        withHeatmapId: "heatmap",
        data: [
          FGMPlatformWeightedLatLng.make(
            withPoint: FGMPlatformLatLng.make(withLatitude: 5.0, longitude: 5.0),
            weight: 0.5
          ),
          FGMPlatformWeightedLatLng.make(
            withPoint: FGMPlatformLatLng.make(withLatitude: 10.0, longitude: 10.0),
            weight: 0.75
          ),
        ],
        gradient: gradient,
        opacity: 0.5,
        radius: 1,
        minimumZoomIntensity: 1,
        maximumZoomIntensity: 2
      ),
      with: HeatmapControllerTests.mapView()
    )
    #expect(heatmap.hasSetMap)
  }

  /// Returns a simple map view to add map objects to.
  static func mapView() -> GMSMapView {
    let mapViewOptions = GMSMapViewOptions()
    mapViewOptions.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
    mapViewOptions.camera = GMSCameraPosition(latitude: 0, longitude: 0, zoom: 0)
    return PartiallyMockedMapView(options: mapViewOptions)
  }
}

/// A GMUHeatmapTileLayer that ensures that property updates are made before the map is set.
class PropertyOrderValidatingHeatmap: GMUHeatmapTileLayer {
  var hasSetMap = false

  override var weightedData: [GMUWeightedLatLng] {
    get { super.weightedData }
    set {
      #expect(!hasSetMap, "Property set after map was set.")
      super.weightedData = newValue
    }
  }

  override var radius: UInt {
    get { super.radius }
    set {
      #expect(!hasSetMap, "Property set after map was set.")
      super.radius = newValue
    }
  }

  override var gradient: GMUGradient {
    get { super.gradient }
    set {
      #expect(!hasSetMap, "Property set after map was set.")
      super.gradient = newValue
    }
  }

  override var minimumZoomIntensity: UInt {
    get { super.minimumZoomIntensity }
    set {
      #expect(!hasSetMap, "Property set after map was set.")
      super.minimumZoomIntensity = newValue
    }
  }

  override var maximumZoomIntensity: UInt {
    get { super.maximumZoomIntensity }
    set {
      #expect(!hasSetMap, "Property set after map was set.")
      super.maximumZoomIntensity = newValue
    }
  }

  override var zIndex: Int32 {
    get { super.zIndex }
    set {
      #expect(!hasSetMap, "Property set after map was set.")
      super.zIndex = newValue
    }
  }

  override var tileSize: Int {
    get { super.tileSize }
    set {
      #expect(!hasSetMap, "Property set after map was set.")
      super.tileSize = newValue
    }
  }

  override var opacity: Float {
    get { super.opacity }
    set {
      #expect(!hasSetMap, "Property set after map was set.")
      super.opacity = newValue
    }
  }

  override var fadeIn: Bool {
    get { super.fadeIn }
    set {
      #expect(!hasSetMap, "Property set after map was set.")
      super.fadeIn = newValue
    }
  }

  override var map: GMSMapView? {
    get { super.map }
    set {
      // Don't actually set the map, since that requires more test setup.
      if newValue != nil {
        hasSetMap = true
      }
    }
  }
}
