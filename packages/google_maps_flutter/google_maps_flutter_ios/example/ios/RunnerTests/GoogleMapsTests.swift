// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest
import GoogleMaps
import Flutter
@testable import google_maps_flutter_ios

class MockCATransaction: NSObject, FGMCATransactionProtocol {
  var beginCalled = false
  var commitCalled = false
  var animationDuration: CFTimeInterval = 0.0

  func begin() {
    beginCalled = true
  }

  func commit() {
    commitCalled = true
  }

  func setAnimationDuration(_ duration: CFTimeInterval) {
    animationDuration = duration
  }
}

// No-op implementation of FlutterBinaryMessenger.
class StubBinaryMessenger: NSObject, FlutterBinaryMessenger {
  func send(onChannel channel: String, message: Data?) {}
  func send(onChannel channel: String, message: Data?, binaryReply reply: FlutterBinaryReply?) {}
  func cleanUpConnection(_ connection: FlutterBinaryMessengerConnection) {}
  func setMessageHandlerOnChannel(_ channel: String, binaryMessageHandler handler: FlutterBinaryMessageHandler?) -> FlutterBinaryMessengerConnection {
    return 0
  }
}

class StubPluginRegistrar: NSObject, FlutterPluginRegistrar {
  var viewController: UIViewController? { nil }
  func publish(_ value: NSObject) {}
  func addMethodCallDelegate(_ delegate: any FlutterPlugin, channel: FlutterMethodChannel) {}
  func addApplicationDelegate(_ delegate: any FlutterPlugin) {}
  func addSceneDelegate(_ delegate: any FlutterSceneLifeCycleDelegate) {}
  func lookupKey(forAsset asset: String) -> String { "" }
  func lookupKey(forAsset asset: String, fromPackage package: String) -> String { "" }
  func valuePublished(byPlugin pluginKey: String) -> NSObject? { nil }
  func messenger() -> any FlutterBinaryMessenger { StubBinaryMessenger() }
  func textures() -> any FlutterTextureRegistry { fatalError() }
  func register(_ factory: any FlutterPlatformViewFactory, withId factoryId: String) {}
  func register(_ factory: any FlutterPlatformViewFactory, withId factoryId: String, gestureRecognizersBlockingPolicy: FlutterPlatformViewGestureRecognizersBlockingPolicy) {}
}

class GoogleMapsTests: XCTestCase {

  func testPlugin() {
    let plugin = FGMGoogleMapsPlugin()
    XCTAssertNotNil(plugin)
  }

  func testFrameObserver() {
    let frame = CGRect(x: 0, y: 0, width: 100, height: 100)
    let options = GMSMapViewOptions()
    options.frame = frame
    options.camera = GMSCameraPosition(latitude: 0, longitude: 0, zoom: 0)
    let mapView = PartiallyMockedMapView(options: options)
    let controller = FGMGoogleMapController(
      mapView: mapView,
      viewIdentifier: 0,
      creationParameters: emptyCreationParameters(),
      assetProvider: TestAssetProvider(),
      binaryMessenger: StubBinaryMessenger()
    )

    for _ in 0..<10 {
      _ = controller.view()
    }
    XCTAssertEqual(mapView.frameObserverCount, 1)

    mapView.frame = frame
    XCTAssertEqual(mapView.frameObserverCount, 0)
  }

  func testMapsServiceSync() {
    // The API requires a registrar, but this test doesn't actually use it, so just pass in a
    // dummy object rather than set up a full mock.
    let registrar = StubPluginRegistrar()
    let factory1 = FGMGoogleMapFactory(registrar: registrar)
    XCTAssertNotNil(factory1.sharedMapServices)
    let factory2 = FGMGoogleMapFactory(registrar: registrar)
    // Test pointer equality, should be same retained singleton +[GMSServices sharedServices] object.
    XCTAssertEqual(factory1.sharedMapServices as? NSObject, factory2.sharedMapServices as? NSObject)
  }

  func testHandleResultTileDownsamplesWideGamutImages() throws {
    let controller = FGMTileProviderController()

    let bundle = Bundle(for: type(of: self))
    let imagePath = try XCTUnwrap(bundle.path(forResource: "widegamut", ofType: "png", inDirectory: "assets"))
    let wideGamutImage = try XCTUnwrap(UIImage(contentsOfFile: imagePath))

    let downsampledImage = try XCTUnwrap(controller.handleResultTile(wideGamutImage))

    let imageRef = try XCTUnwrap(downsampledImage.cgImage)
    let bitsPerComponent = imageRef.bitsPerComponent

    // non wide gamut images use 8 bit format
    XCTAssertEqual(bitsPerComponent, 8)
    XCTAssertEqual(imageRef.alphaInfo, .premultipliedLast)
  }

  func testAnimateCameraWithUpdate() throws {
    let frame = CGRect(x: 0, y: 0, width: 100, height: 100)
    let mapViewOptions = GMSMapViewOptions()
    mapViewOptions.frame = frame

    // Init camera with zero zoom.
    mapViewOptions.camera = GMSCameraPosition(latitude: 0, longitude: 0, zoom: 0)

    let mapView = PartiallyMockedMapView(options: mapViewOptions)

    let controller = FGMGoogleMapController(
      mapView: mapView,
      viewIdentifier: 0,
      creationParameters: emptyCreationParameters(),
      assetProvider: TestAssetProvider(),
      binaryMessenger: StubBinaryMessenger()
    )

    let mockTransactionWrapper = MockCATransaction()
    controller.callHandler.transactionWrapper = mockTransactionWrapper

    let zoomTo = FGMPlatformCameraUpdateNewCameraPosition.make(
      with: FGMPlatformCameraPosition.make(
        withBearing: 0.0,
        target: FGMPlatformLatLng.make(withLatitude: 0.0, longitude: 0.0),
        tilt: 0.0,
        zoom: 10.0
      )
    )
    let cameraUpdate = FGMPlatformCameraUpdate.make(withCameraUpdate: zoomTo)
    var error: FlutterError? = nil

    controller.callHandler.animateCamera(with: cameraUpdate, duration: nil, error: &error)
    XCTAssertNil(error)
    XCTAssertTrue(mapView.didAnimateCamera)
    XCTAssertFalse(mockTransactionWrapper.beginCalled)
    XCTAssertFalse(mockTransactionWrapper.commitCalled)
  }

  func testAnimateCameraWithUpdateAndDuration() throws {
    let frame = CGRect(x: 0, y: 0, width: 100, height: 100)
    let mapViewOptions = GMSMapViewOptions()
    mapViewOptions.frame = frame

    // Init camera with zero zoom.
    mapViewOptions.camera = GMSCameraPosition(latitude: 0, longitude: 0, zoom: 0)

    let mapView = PartiallyMockedMapView(options: mapViewOptions)

    let controller = FGMGoogleMapController(
      mapView: mapView,
      viewIdentifier: 0,
      creationParameters: emptyCreationParameters(),
      assetProvider: TestAssetProvider(),
      binaryMessenger: StubBinaryMessenger()
    )

    let mockTransactionWrapper = MockCATransaction()
    controller.callHandler.transactionWrapper = mockTransactionWrapper

    let zoomTo = FGMPlatformCameraUpdateZoomTo.make(withZoom: 10.0)
    let cameraUpdate = FGMPlatformCameraUpdate.make(withCameraUpdate: zoomTo)
    var error: FlutterError? = nil

    let durationMilliseconds: NSNumber = 100
    controller.callHandler.animateCamera(
      with: cameraUpdate,
      duration: durationMilliseconds,
      error: &error
    )
    XCTAssertNil(error)
    XCTAssertTrue(mapView.didAnimateCamera)
    XCTAssertTrue(mockTransactionWrapper.beginCalled)
    XCTAssertTrue(mockTransactionWrapper.commitCalled)
    XCTAssertEqual(mockTransactionWrapper.animationDuration, durationMilliseconds.doubleValue / 1000)
  }

  func testInspectorAPICameraPosition() throws {
    let frame = CGRect(x: 0, y: 0, width: 100, height: 100)
    let mapViewOptions = GMSMapViewOptions()
    mapViewOptions.frame = frame

    // Init camera with specific position.
    let initialCameraPosition = GMSCameraPosition(latitude: 37.7749, longitude: -122.4194, zoom: 10)
    mapViewOptions.camera = initialCameraPosition

    let mapView = PartiallyMockedMapView(options: mapViewOptions)

    let binaryMessenger = StubBinaryMessenger()
    let controller = FGMGoogleMapController(
      mapView: mapView,
      viewIdentifier: 0,
      creationParameters: emptyCreationParameters(),
      assetProvider: TestAssetProvider(),
      binaryMessenger: binaryMessenger
    )

    let inspector = FGMMapInspector(
      mapController: controller,
      messenger: binaryMessenger,
      pigeonSuffix: "0"
    )

    var error: FlutterError? = nil
    let cameraPosition = try XCTUnwrap(inspector.cameraPosition(&error))
    XCTAssertNil(error)

    XCTAssertEqual(cameraPosition.target.latitude, initialCameraPosition.target.latitude)
    XCTAssertEqual(cameraPosition.target.longitude, initialCameraPosition.target.longitude)
    XCTAssertEqual(Double(cameraPosition.zoom), Double(initialCameraPosition.zoom))
  }

  /// Creates an empty creation parameters object for tests where the values don't matter, just that
  /// there's a valid object to pass in.
  private func emptyCreationParameters() -> FGMPlatformMapViewCreationParams {
    return FGMPlatformMapViewCreationParams.make(
      withInitialCameraPosition: FGMPlatformCameraPosition.make(
        withBearing: 0.0,
        target: FGMPlatformLatLng.make(withLatitude: 0.0, longitude: 0.0),
        tilt: 0.0,
        zoom: 0.0
      ),
      mapConfiguration: FGMPlatformMapConfiguration.make(
        withCompassEnabled: nil,
        cameraTargetBounds: nil,
        mapType: nil,
        minMaxZoomPreference: nil,
        rotateGesturesEnabled: nil,
        scrollGesturesEnabled: nil,
        tiltGesturesEnabled: nil,
        trackCameraPosition: nil,
        zoomGesturesEnabled: nil,
        myLocationEnabled: nil,
        myLocationButtonEnabled: nil,
        padding: nil,
        indoorViewEnabled: nil,
        trafficEnabled: nil,
        buildingsEnabled: nil,
        markerType: .marker,
        mapId: nil,
        style: nil
      ),
      initialCircles: [],
      initialMarkers: [],
      initialPolygons: [],
      initialPolylines: [],
      initialHeatmaps: [],
      initialTileOverlays: [],
      initialClusterManagers: [],
      initialGroundOverlays: []
    )
  }
}
