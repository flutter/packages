// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest
import GoogleMaps
@testable import google_maps_flutter_ios

/// A GMSPolyline that ensures that property updates are made before the map is set.
class PropertyOrderValidatingPolyline: GMSPolyline {
  var hasSetMap = false

  override var path: GMSPath? {
    get { super.path }
    set {
      XCTAssertFalse(hasSetMap, "Property set after map was set.")
      super.path = newValue
    }
  }

  override var strokeWidth: CGFloat {
    get { super.strokeWidth }
    set {
      XCTAssertFalse(hasSetMap, "Property set after map was set.")
      super.strokeWidth = newValue
    }
  }

  override var strokeColor: UIColor {
    get { super.strokeColor }
    set {
      XCTAssertFalse(hasSetMap, "Property set after map was set.")
      super.strokeColor = newValue
    }
  }

  override var geodesic: Bool {
    get { super.geodesic }
    set {
      XCTAssertFalse(hasSetMap, "Property set after map was set.")
      super.geodesic = newValue
    }
  }

  override var title: String? {
    get { super.title }
    set {
      XCTAssertFalse(hasSetMap, "Property set after map was set.")
      super.title = newValue
    }
  }

  override var isTappable: Bool {
    get { super.isTappable }
    set {
      XCTAssertFalse(hasSetMap, "Property set after map was set.")
      super.isTappable = newValue
    }
  }

  override var zIndex: Int32 {
    get { super.zIndex }
    set {
      XCTAssertFalse(hasSetMap, "Property set after map was set.")
      super.zIndex = newValue
    }
  }

  override var userData: Any? {
    get { super.userData }
    set {
      XCTAssertFalse(hasSetMap, "Property set after map was set.")
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

class PolylineControllerTests: XCTestCase {

  /// Returns GoogleMapPolylineController object instantiated with a mocked map instance
  ///
  ///  @return An object of FGMPolylineController
  func polylineControllerWithMockedMap() -> FGMPolylineController {
    let polyline = FGMPlatformPolyline.make(
      withPolylineId: "polyline_id_0",
      consumesTapEvents: false,
      color: FGMPlatformColor.make(withRed: 0, green: 0, blue: 0, alpha: 0),
      geodesic: false,
      jointType: .round,
      patterns: [],
      points: PolylineControllerTests.polylinePoints(),
      visible: false,
      width: 1,
      zIndex: 0
    )

    let frame = CGRect(x: 0, y: 0, width: 100, height: 100)
    let camera = GMSCameraPosition(latitude: 0, longitude: 0, zoom: 0)

    let mapViewOptions = GMSMapViewOptions()
    mapViewOptions.frame = frame
    mapViewOptions.camera = camera

    let mapView = PartiallyMockedMapView(options: mapViewOptions)

    let path = FGMGetPathFromPoints(FGMGetPointsForPigeonLatLngs(polyline.points))

    let polylineControllerWithMockedMap = FGMPolylineController(
      path: path,
      identifier: polyline.polylineId,
      mapView: mapView
    )

    return polylineControllerWithMockedMap!
  }

  func testPatternsSetSpans() {
    let polylineController = polylineControllerWithMockedMap()

    XCTAssertNil(polylineController.polyline.spans)

    polylineController.update(
      from: FGMPlatformPolyline.make(
        withPolylineId: "polyline_id_0",
        consumesTapEvents: false,
        color: FGMPlatformColor.make(withRed: 0, green: 0, blue: 0, alpha: 0),
        geodesic: false,
        jointType: .round,
        patterns: [
          FGMPlatformPatternItem.make(with: .dot, length: 10),
          FGMPlatformPatternItem.make(with: .dash, length: 10),
        ],
        points: PolylineControllerTests.polylinePoints(),
        visible: true,
        width: 1,
        zIndex: 0
      )
    )

    // `GMSStyleSpan` doesn't implement `isEqual` so cannot be compared by value at present.
    XCTAssertNotNil(polylineController.polyline.spans)
  }

  func testUpdatePolylineSetsVisibilityLast() {
    let polyline = PropertyOrderValidatingPolyline()
    FGMPolylineController.update(
      polyline,
      from: FGMPlatformPolyline.make(
        withPolylineId: "polyline",
        consumesTapEvents: false,
        color: FGMPlatformColor.make(withRed: 0, green: 0, blue: 0, alpha: 0),
        geodesic: false,
        jointType: .round,
        patterns: [],
        points: PolylineControllerTests.polylinePoints(),
        visible: true,
        width: 1,
        zIndex: 0
      ),
      with: PolylineControllerTests.mapView()
    )
    XCTAssertTrue(polyline.hasSetMap)
  }

  /// Returns a simple map view to add map objects to.
  static func mapView() -> GMSMapView {
    let mapViewOptions = GMSMapViewOptions()
    mapViewOptions.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
    mapViewOptions.camera = GMSCameraPosition(latitude: 0, longitude: 0, zoom: 0)
    return PartiallyMockedMapView(options: mapViewOptions)
  }

  /// Returns a set of points to use for tests that need a valid but arbitrary line.
  static func polylinePoints() -> [FGMPlatformLatLng] {
    return [
      FGMPlatformLatLng.make(withLatitude: 52.4816, longitude: -3.1791),
      FGMPlatformLatLng.make(withLatitude: 54.043, longitude: -2.9925),
      FGMPlatformLatLng.make(withLatitude: 54.1396, longitude: -4.2739),
      FGMPlatformLatLng.make(withLatitude: 53.4153, longitude: -4.0829),
    ]
  }
}
