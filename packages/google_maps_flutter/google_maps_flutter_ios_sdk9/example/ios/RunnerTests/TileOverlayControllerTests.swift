// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import GoogleMaps
import Testing

@testable import google_maps_flutter_ios_sdk9

@MainActor struct TileOverlayControllerTests {

  @Test func updateTileOverlaySetsVisibilityLast() {
    let tileLayer = PropertyOrderValidatingTileLayer()
    FGMTileOverlayController.update(
      tileLayer,
      from: FGMPlatformTileOverlay.make(
        withTileOverlayId: "overlay",
        fadeIn: false,
        transparency: 0.5,
        zIndex: 0,
        visible: true,
        tileSize: 1
      ),
      with: TileOverlayControllerTests.mapView()
    )
    #expect(tileLayer.hasSetMap)
  }

  /// Returns a simple map view to add map objects to.
  static func mapView() -> GMSMapView {
    let mapViewOptions = GMSMapViewOptions()
    mapViewOptions.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
    mapViewOptions.camera = GMSCameraPosition(latitude: 0, longitude: 0, zoom: 0)
    return PartiallyMockedMapView(options: mapViewOptions)
  }
}

/// A GMSTileOverlay that ensures that property updates are made before the map is set.
class PropertyOrderValidatingTileLayer: GMSTileLayer {
  var hasSetMap = false

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
