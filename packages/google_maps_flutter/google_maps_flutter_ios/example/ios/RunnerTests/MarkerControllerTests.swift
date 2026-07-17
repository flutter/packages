// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest
import GoogleMaps
@testable import google_maps_flutter_ios

class MarkerControllerTests: XCTestCase {

  /// Returns a simple map view for use with marker controllers.
  static func mapView() -> GMSMapView {
    let mapViewOptions = GMSMapViewOptions()
    mapViewOptions.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
    mapViewOptions.camera = GMSCameraPosition(latitude: 0, longitude: 0, zoom: 0)
    return PartiallyMockedMapView(options: mapViewOptions)
  }

  /// Returns a FGMMarkersController instance instantiated with the given map view.
  ///
  /// The mapView should outlive the controller, as the controller keeps a weak reference to it.
  func markersController(
    withMapView mapView: GMSMapView,
    eventDelegate: NSObject & FGMMapEventDelegate
  ) -> FGMMarkersController {
    return FGMMarkersController(
      mapView: mapView,
      eventDelegate: eventDelegate,
      clusterManagersController: nil,
      assetProvider: TestAssetProvider(),
      markerType: .marker
    )
  }

  func placeholderBitmap() -> FGMPlatformBitmap {
    return FGMPlatformBitmap.make(withBitmap: FGMPlatformBitmapDefaultMarker.make(withHue: 0))
  }

  func testSetsMarkerNumericProperties() throws {
    let mapView = MarkerControllerTests.mapView()
    let eventHandler = TestMapEventHandler()
    let controller = markersController(withMapView: mapView, eventDelegate: eventHandler)

    let markerIdentifier = "marker"
    let anchorX = 3.14
    let anchorY = 2.718
    let alpha = 0.4
    let rotation = 90.0
    let zIndex = 3
    let latitude = 10.0
    let longitude = 20.0
    controller.add([
      FGMPlatformMarker.make(
        withAlpha: alpha,
        anchor: FGMPlatformPoint.makeWith(x: anchorX, y: anchorY),
        consumeTapEvents: true,
        draggable: true,
        flat: true,
        icon: placeholderBitmap(),
        infoWindow: FGMPlatformInfoWindow.make(
          withTitle: "info title",
          snippet: "info snippet",
          anchor: FGMPlatformPoint.makeWith(x: 0, y: 0)
        ),
        position: FGMPlatformLatLng.make(withLatitude: latitude, longitude: longitude),
        rotation: rotation,
        visible: true,
        zIndex: zIndex,
        markerId: markerIdentifier,
        clusterManagerId: nil,
        collisionBehavior: nil
      )
    ])

    guard let markerController = controller.markerIdentifierToController[markerIdentifier] as? FGMMarkerController else {
      XCTFail("Controller not found for \(markerIdentifier)")
      return
    }
    let marker = try XCTUnwrap(markerController.marker)

    let delta = 0.0001
    XCTAssertEqual(Double(marker.opacity), alpha, accuracy: delta)
    XCTAssertEqual(marker.rotation, rotation, accuracy: delta)
    XCTAssertEqual(Double(marker.zIndex), Double(zIndex), accuracy: delta)
    XCTAssertEqual(Double(marker.groundAnchor.x), anchorX, accuracy: delta)
    XCTAssertEqual(Double(marker.groundAnchor.y), anchorY, accuracy: delta)
    XCTAssertEqual(marker.position.latitude, latitude, accuracy: delta)
    XCTAssertEqual(marker.position.longitude, longitude, accuracy: delta)
  }

  func testSetsDraggable() throws {
    let mapView = MarkerControllerTests.mapView()
    let eventHandler = TestMapEventHandler()
    let controller = markersController(withMapView: mapView, eventDelegate: eventHandler)

    let markerIdentifier = "marker"
    controller.add([
      FGMPlatformMarker.make(
        withAlpha: 1.0,
        anchor: FGMPlatformPoint.makeWith(x: 0, y: 0),
        consumeTapEvents: false,
        draggable: true,
        flat: false,
        icon: placeholderBitmap(),
        infoWindow: FGMPlatformInfoWindow.make(
          withTitle: "info title",
          snippet: "info snippet",
          anchor: FGMPlatformPoint.makeWith(x: 0, y: 0)
        ),
        position: FGMPlatformLatLng.make(withLatitude: 0.0, longitude: 0.0),
        rotation: 0,
        visible: false,
        zIndex: 0,
        markerId: markerIdentifier,
        clusterManagerId: nil,
        collisionBehavior: nil
      )
    ])

    guard let markerController = controller.markerIdentifierToController[markerIdentifier] as? FGMMarkerController else {
      XCTFail("Controller not found for \(markerIdentifier)")
      return
    }
    let marker = try XCTUnwrap(markerController.marker)

    XCTAssertTrue(marker.isDraggable)
  }

  // Boolean properties are tested individually to ensure they aren't accidentally cross-assigned from
  // another property.
  func testSetsFlat() throws {
    let mapView = MarkerControllerTests.mapView()
    let eventHandler = TestMapEventHandler()
    let controller = markersController(withMapView: mapView, eventDelegate: eventHandler)

    let markerIdentifier = "marker"
    controller.add([
      FGMPlatformMarker.make(
        withAlpha: 1.0,
        anchor: FGMPlatformPoint.makeWith(x: 0, y: 0),
        consumeTapEvents: false,
        draggable: false,
        flat: true,
        icon: placeholderBitmap(),
        infoWindow: FGMPlatformInfoWindow.make(
          withTitle: "info title",
          snippet: "info snippet",
          anchor: FGMPlatformPoint.makeWith(x: 0, y: 0)
        ),
        position: FGMPlatformLatLng.make(withLatitude: 0.0, longitude: 0.0),
        rotation: 0,
        visible: false,
        zIndex: 0,
        markerId: markerIdentifier,
        clusterManagerId: nil,
        collisionBehavior: nil
      )
    ])

    guard let markerController = controller.markerIdentifierToController[markerIdentifier] as? FGMMarkerController else {
      XCTFail("Controller not found for \(markerIdentifier)")
      return
    }
    let marker = try XCTUnwrap(markerController.marker)

    XCTAssertTrue(marker.isFlat)
  }

  // Boolean properties are tested individually to ensure they aren't accidentally cross-assigned from
  // another property.
  func testSetsVisible() throws {
    let mapView = MarkerControllerTests.mapView()
    let eventHandler = TestMapEventHandler()
    let controller = markersController(withMapView: mapView, eventDelegate: eventHandler)

    let markerIdentifier = "marker"
    controller.add([
      FGMPlatformMarker.make(
        withAlpha: 1.0,
        anchor: FGMPlatformPoint.makeWith(x: 0, y: 0),
        consumeTapEvents: false,
        draggable: false,
        flat: false,
        icon: placeholderBitmap(),
        infoWindow: FGMPlatformInfoWindow.make(
          withTitle: "info title",
          snippet: "info snippet",
          anchor: FGMPlatformPoint.makeWith(x: 0, y: 0)
        ),
        position: FGMPlatformLatLng.make(withLatitude: 0.0, longitude: 0.0),
        rotation: 0,
        visible: true,
        zIndex: 0,
        markerId: markerIdentifier,
        clusterManagerId: nil,
        collisionBehavior: nil
      )
    ])

    guard let markerController = controller.markerIdentifierToController[markerIdentifier] as? FGMMarkerController else {
      XCTFail("Controller not found for \(markerIdentifier)")
      return
    }
    let marker = try XCTUnwrap(markerController.marker)

    // Visibility is controlled by being set to a map.
    XCTAssertNotNil(marker.map)
  }

  func testSetsMarkerInfoWindowProperties() throws {
    let mapView = MarkerControllerTests.mapView()
    let eventHandler = TestMapEventHandler()
    let controller = markersController(withMapView: mapView, eventDelegate: eventHandler)

    let markerIdentifier = "marker"
    let title = "info title"
    let snippet = "info snippet"
    let anchorX = 3.14
    let anchorY = 2.718
    controller.add([
      FGMPlatformMarker.make(
        withAlpha: 1.0,
        anchor: FGMPlatformPoint.makeWith(x: 0, y: 0),
        consumeTapEvents: true,
        draggable: true,
        flat: true,
        icon: placeholderBitmap(),
        infoWindow: FGMPlatformInfoWindow.make(
          withTitle: title,
          snippet: snippet,
          anchor: FGMPlatformPoint.makeWith(x: anchorX, y: anchorY)
        ),
        position: FGMPlatformLatLng.make(withLatitude: 0, longitude: 0),
        rotation: 0,
        visible: true,
        zIndex: 0,
        markerId: markerIdentifier,
        clusterManagerId: nil,
        collisionBehavior: nil
      )
    ])

    guard let markerController = controller.markerIdentifierToController[markerIdentifier] as? FGMMarkerController else {
      XCTFail("Controller not found for \(markerIdentifier)")
      return
    }
    let marker = try XCTUnwrap(markerController.marker)

    let delta = 0.0001
    XCTAssertEqual(Double(marker.infoWindowAnchor.x), anchorX, accuracy: delta)
    XCTAssertEqual(Double(marker.infoWindowAnchor.y), anchorY, accuracy: delta)
    XCTAssertEqual(marker.title, title)
    XCTAssertEqual(marker.snippet, snippet)
  }

  func testUpdateMarkerSetsVisibilityLast() {
    let marker = PropertyOrderValidatingAdvancedMarker()
    let collisionBehavior = FGMPlatformMarkerCollisionBehaviorBox(
      value: .requiredAndHidesOptional
    )
    FGMMarkerController.update(
      marker,
      from: FGMPlatformMarker.make(
        withAlpha: 1.0,
        anchor: FGMPlatformPoint.makeWith(x: 0, y: 0),
        consumeTapEvents: true,
        draggable: true,
        flat: true,
        icon: placeholderBitmap(),
        infoWindow: FGMPlatformInfoWindow.make(
          withTitle: "info title",
          snippet: "info snippet",
          anchor: FGMPlatformPoint.makeWith(x: 0, y: 0)
        ),
        position: FGMPlatformLatLng.make(withLatitude: 0, longitude: 0),
        rotation: 0,
        visible: true,
        zIndex: 0,
        markerId: "marker",
        clusterManagerId: nil,
        collisionBehavior: collisionBehavior
      ),
      with: MarkerControllerTests.mapView(),
      assetProvider: TestAssetProvider(),
      screenScale: 1,
      usingOpacityForVisibility: false
    )
    XCTAssertTrue(marker.hasSetMap)
  }

  func testAssetProviderIsRetained() {
    var markerController: FGMMarkersController?
    weak var weakAssetProvider: TestAssetProvider?
    autoreleasepool {
      let assetProvider = TestAssetProvider()
      weakAssetProvider = assetProvider

      markerController = FGMMarkersController(
        mapView: MarkerControllerTests.mapView(),
        eventDelegate: TestMapEventHandler(),
        clusterManagersController: nil,
        assetProvider: assetProvider,
        markerType: .marker
      )
    }
    XCTAssertNotNil(markerController)
    XCTAssertNotNil(weakAssetProvider, "AssetProvider should be retained by the marker controller")
  }
}

/// A GMSAdvancedMarker that ensures that property updates are made before the map is set.
class PropertyOrderValidatingAdvancedMarker: GMSAdvancedMarker {
  var hasSetMap = false

  override var position: CLLocationCoordinate2D {
    get { super.position }
    set {
      XCTAssertFalse(hasSetMap, "Property set after map was set.")
      super.position = newValue
    }
  }

  override var snippet: String? {
    get { super.snippet }
    set {
      XCTAssertFalse(hasSetMap, "Property set after map was set.")
      super.snippet = newValue
    }
  }

  override var icon: UIImage? {
    get { super.icon }
    set {
      XCTAssertFalse(hasSetMap, "Property set after map was set.")
      super.icon = newValue
    }
  }

  override var iconView: UIView? {
    get { super.iconView }
    set {
      XCTAssertFalse(hasSetMap, "Property set after map was set.")
      super.iconView = newValue
    }
  }

  override var tracksViewChanges: Bool {
    get { super.tracksViewChanges }
    set {
      XCTAssertFalse(hasSetMap, "Property set after map was set.")
      super.tracksViewChanges = newValue
    }
  }

  override var tracksInfoWindowChanges: Bool {
    get { super.tracksInfoWindowChanges }
    set {
      XCTAssertFalse(hasSetMap, "Property set after map was set.")
      super.tracksInfoWindowChanges = newValue
    }
  }

  override var groundAnchor: CGPoint {
    get { super.groundAnchor }
    set {
      XCTAssertFalse(hasSetMap, "Property set after map was set.")
      super.groundAnchor = newValue
    }
  }

  override var infoWindowAnchor: CGPoint {
    get { super.infoWindowAnchor }
    set {
      XCTAssertFalse(hasSetMap, "Property set after map was set.")
      super.infoWindowAnchor = newValue
    }
  }

  override var appearAnimation: GMSMarkerAnimation {
    get { super.appearAnimation }
    set {
      XCTAssertFalse(hasSetMap, "Property set after map was set.")
      super.appearAnimation = newValue
    }
  }

  override var isDraggable: Bool {
    get { super.isDraggable }
    set {
      XCTAssertFalse(hasSetMap, "Property set after map was set.")
      super.isDraggable = newValue
    }
  }

  override var isFlat: Bool {
    get { super.isFlat }
    set {
      XCTAssertFalse(hasSetMap, "Property set after map was set.")
      super.isFlat = newValue
    }
  }

  override var rotation: CLLocationDegrees {
    get { super.rotation }
    set {
      XCTAssertFalse(hasSetMap, "Property set after map was set.")
      super.rotation = newValue
    }
  }

  override var opacity: Float {
    get { super.opacity }
    set {
      XCTAssertFalse(hasSetMap, "Property set after map was set.")
      super.opacity = newValue
    }
  }

  override var panoramaView: GMSPanoramaView? {
    get { super.panoramaView }
    set {
      XCTAssertFalse(hasSetMap, "Property set after map was set.")
      super.panoramaView = newValue
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

  override var collisionBehavior: GMSCollisionBehavior {
    get { super.collisionBehavior }
    set {
      XCTAssertFalse(hasSetMap, "Property set after map was set.")
      super.collisionBehavior = newValue
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
