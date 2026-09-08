// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import GoogleMaps
import Testing

@testable import google_maps_flutter_ios

@MainActor struct PolygonControllerTests {

  @Test func updatePolygonSetsVisibilityLast() {
    let polygon = PropertyOrderValidatingPolygon()
    FGMPolygonController.update(
      polygon,
      from: FGMPlatformPolygon.make(
        withPolygonId: "polygon",
        consumesTapEvents: false,
        fill: FGMPlatformColor.make(withRed: 0, green: 0, blue: 0, alpha: 0),
        geodesic: false,
        points: [],
        holes: [],
        visible: true,
        stroke: FGMPlatformColor.make(withRed: 0, green: 0, blue: 0, alpha: 0),
        strokeWidth: 0,
        zIndex: 0
      ),
      with: PolygonControllerTests.mapView()
    )
    #expect(polygon.hasSetMap)
  }

  /// Returns a simple map view to add map objects to.
  static func mapView() -> GMSMapView {
    let mapViewOptions = GMSMapViewOptions()
    mapViewOptions.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
    mapViewOptions.camera = GMSCameraPosition(latitude: 0, longitude: 0, zoom: 0)
    return PartiallyMockedMapView(options: mapViewOptions)
  }
}

/// A GMSPolygon that ensures that property updates are made before the map is set.
class PropertyOrderValidatingPolygon: GMSPolygon {
  var hasSetMap = false

  override var path: GMSPath? {
    get { super.path }
    set {
      #expect(!hasSetMap, "Property set after map was set.")
      super.path = newValue
    }
  }

  override var holes: [GMSPath]? {
    get { super.holes }
    set {
      #expect(!hasSetMap, "Property set after map was set.")
      super.holes = newValue
    }
  }

  override var strokeWidth: CGFloat {
    get { super.strokeWidth }
    set {
      #expect(!hasSetMap, "Property set after map was set.")
      super.strokeWidth = newValue
    }
  }

  override var strokeColor: UIColor? {
    get { super.strokeColor }
    set {
      #expect(!hasSetMap, "Property set after map was set.")
      super.strokeColor = newValue
    }
  }

  override var fillColor: UIColor? {
    get { super.fillColor }
    set {
      #expect(!hasSetMap, "Property set after map was set.")
      super.fillColor = newValue
    }
  }

  override var geodesic: Bool {
    get { super.geodesic }
    set {
      #expect(!hasSetMap, "Property set after map was set.")
      super.geodesic = newValue
    }
  }

  override var title: String? {
    get { super.title }
    set {
      #expect(!hasSetMap, "Property set after map was set.")
      super.title = newValue
    }
  }

  override var isTappable: Bool {
    get { super.isTappable }
    set {
      #expect(!hasSetMap, "Property set after map was set.")
      super.isTappable = newValue
    }
  }

  override var zIndex: Int32 {
    get { super.zIndex }
    set {
      #expect(!hasSetMap, "Property set after map was set.")
      super.zIndex = newValue
    }
  }

  override var userData: Any? {
    get { super.userData }
    set {
      #expect(!hasSetMap, "Property set after map was set.")
      super.userData = newValue
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
