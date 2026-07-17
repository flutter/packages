// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import GoogleMaps
import Testing

@testable import google_maps_flutter_ios

@MainActor struct GroundOverlayControllerTests {

  /// Returns a GroundOverlayController object instantiated with position and a mocked map
  /// instance.
  static func groundOverlayControllerWithPositionWithMockedMap() throws
    -> FGMGroundOverlayController
  {
    let bundle = Bundle(for: PropertyOrderValidatingGroundOverlay.self)
    let imagePath = try #require(
      bundle.path(forResource: "widegamut", ofType: "png", inDirectory: "assets"))
    let wideGamutImage = try #require(UIImage(contentsOfFile: imagePath))
    let groundOverlay = GMSGroundOverlay(
      position: CLLocationCoordinate2D(latitude: 52.4816, longitude: 3.1791),
      icon: wideGamutImage,
      zoomLevel: 14.0
    )

    let mapView = GroundOverlayControllerTests.mapView()

    return FGMGroundOverlayController(
      groundOverlay: groundOverlay,
      identifier: "id_1",
      mapView: mapView,
      isCreatedWithBounds: false
    )
  }

  /// Returns a GroundOverlayController object instantiated with bounds and a mocked map
  /// instance.
  static func groundOverlayControllerWithBoundsWithMockedMap() throws -> FGMGroundOverlayController
  {
    let bundle = Bundle(for: PropertyOrderValidatingGroundOverlay.self)
    let imagePath = try #require(
      bundle.path(forResource: "widegamut", ofType: "png", inDirectory: "assets"))
    let wideGamutImage = try #require(UIImage(contentsOfFile: imagePath))
    let groundOverlay = GMSGroundOverlay(
      bounds: GMSCoordinateBounds(
        coordinate: CLLocationCoordinate2D(latitude: 10, longitude: 20),
        coordinate: CLLocationCoordinate2D(latitude: 30, longitude: 40)
      ),
      icon: wideGamutImage
    )

    let mapView = GroundOverlayControllerTests.mapView()

    return FGMGroundOverlayController(
      groundOverlay: groundOverlay,
      identifier: "id_1",
      mapView: mapView,
      isCreatedWithBounds: true
    )
  }

  @Test func updatingGroundOverlayWithPosition() throws {
    let groundOverlayController =
      try GroundOverlayControllerTests.groundOverlayControllerWithPositionWithMockedMap()

    let position = FGMPlatformLatLng.make(withLatitude: 52.4816, longitude: 3.1791)

    let bitmap = FGMPlatformBitmap.make(
      withBitmap: FGMPlatformBitmapDefaultMarker.make(withHue: 0)
    )

    let platformGroundOverlay = FGMPlatformGroundOverlay.make(
      withGroundOverlayId: "id_1",
      image: bitmap,
      position: position,
      bounds: nil,
      anchor: FGMPlatformPoint.makeWith(x: 0.5, y: 0.5),
      transparency: 0.5,
      bearing: 65.0,
      zIndex: 2,
      visible: true,
      clickable: true,
      zoomLevel: 14.0
    )

    groundOverlayController.update(
      from: platformGroundOverlay,
      assetProvider: TestAssetProvider(),
      screenScale: 1.0
    )

    #expect(groundOverlayController.groundOverlay.icon != nil)
    #expect(
      abs(groundOverlayController.groundOverlay.position.latitude - position.latitude)
        <= Double.ulpOfOne)
    #expect(
      abs(groundOverlayController.groundOverlay.position.longitude - position.longitude)
        <= Double.ulpOfOne)
    #expect(
      Double(groundOverlayController.groundOverlay.opacity) == platformGroundOverlay.transparency)
    #expect(groundOverlayController.groundOverlay.bearing == platformGroundOverlay.bearing)
    #expect(abs(groundOverlayController.groundOverlay.anchor.x - 0.5) <= Double.ulpOfOne)
    #expect(abs(groundOverlayController.groundOverlay.anchor.y - 0.5) <= Double.ulpOfOne)
    #expect(groundOverlayController.groundOverlay.zIndex == Int32(platformGroundOverlay.zIndex))

    let convertedPlatformGroundOverlay = try #require(
      FGMGetPigeonGroundOverlay(groundOverlayController.groundOverlay, "id_1", false, 14.0)
    )
    #expect(convertedPlatformGroundOverlay.groundOverlayId == "id_1")
    #expect(
      abs(convertedPlatformGroundOverlay.position!.latitude - position.latitude) <= Double.ulpOfOne)
    #expect(
      abs(convertedPlatformGroundOverlay.position!.longitude - position.longitude)
        <= Double.ulpOfOne)
    #expect(convertedPlatformGroundOverlay.zoomLevel!.doubleValue == 14.0)
    #expect(convertedPlatformGroundOverlay.transparency == platformGroundOverlay.transparency)
    #expect(convertedPlatformGroundOverlay.bearing == platformGroundOverlay.bearing)
    #expect(abs(convertedPlatformGroundOverlay.anchor!.x - 0.5) <= Double.ulpOfOne)
    #expect(abs(convertedPlatformGroundOverlay.anchor!.y - 0.5) <= Double.ulpOfOne)
    #expect(convertedPlatformGroundOverlay.zIndex == platformGroundOverlay.zIndex)
  }

  @Test func updatingGroundOverlayWithBounds() throws {
    let groundOverlayController =
      try GroundOverlayControllerTests.groundOverlayControllerWithBoundsWithMockedMap()

    let bounds = FGMPlatformLatLngBounds.make(
      withNortheast: FGMPlatformLatLng.make(withLatitude: 54.4816, longitude: 5.1791),
      southwest: FGMPlatformLatLng.make(withLatitude: 52.4816, longitude: 3.1791)
    )

    let bitmap = FGMPlatformBitmap.make(
      withBitmap: FGMPlatformBitmapDefaultMarker.make(withHue: 0)
    )

    let platformGroundOverlay = FGMPlatformGroundOverlay.make(
      withGroundOverlayId: "id_1",
      image: bitmap,
      position: nil,
      bounds: bounds,
      anchor: FGMPlatformPoint.makeWith(x: 0.5, y: 0.5),
      transparency: 0.5,
      bearing: 65.0,
      zIndex: 2,
      visible: true,
      clickable: true,
      zoomLevel: nil
    )

    groundOverlayController.update(
      from: platformGroundOverlay,
      assetProvider: TestAssetProvider(),
      screenScale: 1.0
    )

    #expect(groundOverlayController.groundOverlay.icon != nil)
    let overlayBounds = try #require(groundOverlayController.groundOverlay.bounds)
    #expect(abs(overlayBounds.northEast.latitude - bounds.northeast.latitude) <= Double.ulpOfOne)
    #expect(abs(overlayBounds.northEast.longitude - bounds.northeast.longitude) <= Double.ulpOfOne)
    #expect(abs(overlayBounds.southWest.latitude - bounds.southwest.latitude) <= Double.ulpOfOne)
    #expect(abs(overlayBounds.southWest.longitude - bounds.southwest.longitude) <= Double.ulpOfOne)
    #expect(
      Double(groundOverlayController.groundOverlay.opacity) == platformGroundOverlay.transparency)
    #expect(groundOverlayController.groundOverlay.bearing == platformGroundOverlay.bearing)
    #expect(abs(groundOverlayController.groundOverlay.anchor.x - 0.5) <= Double.ulpOfOne)
    #expect(abs(groundOverlayController.groundOverlay.anchor.y - 0.5) <= Double.ulpOfOne)
    #expect(groundOverlayController.groundOverlay.zIndex == Int32(platformGroundOverlay.zIndex))

    let convertedPlatformGroundOverlay = try #require(
      FGMGetPigeonGroundOverlay(groundOverlayController.groundOverlay, "id_1", true, nil)
    )
    #expect(convertedPlatformGroundOverlay.groundOverlayId == "id_1")
    #expect(
      abs(convertedPlatformGroundOverlay.bounds!.northeast.latitude - bounds.northeast.latitude)
        <= Double.ulpOfOne)
    #expect(
      abs(convertedPlatformGroundOverlay.bounds!.northeast.longitude - bounds.northeast.longitude)
        <= Double.ulpOfOne)
    #expect(
      abs(convertedPlatformGroundOverlay.bounds!.southwest.latitude - bounds.southwest.latitude)
        <= Double.ulpOfOne)
    #expect(
      abs(convertedPlatformGroundOverlay.bounds!.southwest.longitude - bounds.southwest.longitude)
        <= Double.ulpOfOne)
    #expect(convertedPlatformGroundOverlay.transparency == platformGroundOverlay.transparency)
    #expect(convertedPlatformGroundOverlay.bearing == platformGroundOverlay.bearing)
    #expect(abs(convertedPlatformGroundOverlay.anchor!.x - 0.5) <= Double.ulpOfOne)
    #expect(abs(convertedPlatformGroundOverlay.anchor!.y - 0.5) <= Double.ulpOfOne)
    #expect(convertedPlatformGroundOverlay.zIndex == platformGroundOverlay.zIndex)
  }

  @Test func updateGroundOverlaySetsVisibilityLast() {
    let groundOverlay = PropertyOrderValidatingGroundOverlay()
    FGMGroundOverlayController.update(
      groundOverlay,
      from: FGMPlatformGroundOverlay.make(
        withGroundOverlayId: "groundOverlay",
        image: FGMPlatformBitmap.make(
          withBitmap: FGMPlatformBitmapDefaultMarker.make(withHue: 0)
        ),
        position: FGMPlatformLatLng.make(withLatitude: 0, longitude: 0),
        bounds: FGMPlatformLatLngBounds.make(
          withNortheast: FGMPlatformLatLng.make(withLatitude: 54.4816, longitude: 5.1791),
          southwest: FGMPlatformLatLng.make(withLatitude: 52.4816, longitude: 3.1791)
        ),
        anchor: FGMPlatformPoint.makeWith(x: 0.5, y: 0.5),
        transparency: 0.5,
        bearing: 65.0,
        zIndex: 2,
        visible: true,
        clickable: true,
        zoomLevel: nil
      ),
      with: GroundOverlayControllerTests.mapView(),
      assetProvider: TestAssetProvider(),
      screenScale: 1.0,
      usingBounds: true
    )
    #expect(groundOverlay.hasSetMap)
  }

  @Test func assetProviderIsRetained() {
    var groundOverlayController: FGMGroundOverlaysController?
    weak var weakAssetProvider: TestAssetProvider?
    autoreleasepool {
      let assetProvider = TestAssetProvider()
      weakAssetProvider = assetProvider
      groundOverlayController = FGMGroundOverlaysController(
        mapView: GroundOverlayControllerTests.mapView(),
        eventDelegate: TestMapEventHandler(),
        assetProvider: assetProvider
      )
    }
    #expect(groundOverlayController != nil)
    #expect(weakAssetProvider != nil)
  }

  /// Returns a simple map view to add map objects to.
  static func mapView() -> GMSMapView {
    let mapViewOptions = GMSMapViewOptions()
    mapViewOptions.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
    mapViewOptions.camera = GMSCameraPosition(latitude: 0, longitude: 0, zoom: 0)
    return PartiallyMockedMapView(options: mapViewOptions)
  }
}

/// A GMSGroundOverlay that ensures that property updates are made before the map is set.
class PropertyOrderValidatingGroundOverlay: GMSGroundOverlay {
  var hasSetMap = false

  override var position: CLLocationCoordinate2D {
    get { super.position }
    set {
      #expect(!hasSetMap, "Property set after map was set.")
      super.position = newValue
    }
  }

  override var anchor: CGPoint {
    get { super.anchor }
    set {
      #expect(!hasSetMap, "Property set after map was set.")
      super.anchor = newValue
    }
  }

  override var icon: UIImage? {
    get { super.icon }
    set {
      #expect(!hasSetMap, "Property set after map was set.")
      super.icon = newValue
    }
  }

  override var opacity: Float {
    get { super.opacity }
    set {
      #expect(!hasSetMap, "Property set after map was set.")
      super.opacity = newValue
    }
  }

  override var bearing: CLLocationDirection {
    get { super.bearing }
    set {
      #expect(!hasSetMap, "Property set after map was set.")
      super.bearing = newValue
    }
  }

  override var bounds: GMSCoordinateBounds? {
    get { super.bounds }
    set {
      #expect(!hasSetMap, "Property set after map was set.")
      super.bounds = newValue
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
