// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import GoogleMaps
import Testing

@testable import google_maps_flutter_ios_sdk9

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
  func setMessageHandlerOnChannel(
    _ channel: String, binaryMessageHandler handler: FlutterBinaryMessageHandler?
  ) -> FlutterBinaryMessengerConnection {
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
  func register(
    _ factory: any FlutterPlatformViewFactory, withId factoryId: String,
    gestureRecognizersBlockingPolicy: FlutterPlatformViewGestureRecognizersBlockingPolicy
  ) {}
}

@MainActor struct GoogleMapsTests {

  @Test func plugin() {
    // Verify that creating an actual plugin instance succeeds.
    let _ = GoogleMapsPlugin()
  }

  @Test func frameObserver() {
    let frame = CGRect(x: 0, y: 0, width: 100, height: 100)
    let options = GMSMapViewOptions()
    options.frame = frame
    options.camera = GMSCameraPosition(latitude: 0, longitude: 0, zoom: 0)
    let mapView = PartiallyMockedMapView(options: options)
    let controller = GoogleMapController(
      mapView: mapView,
      viewIdentifier: 0,
      creationParameters: emptyCreationParameters(),
      assetProvider: TestAssetProvider(),
      binaryMessenger: StubBinaryMessenger()
    )

    for _ in 0..<10 {
      _ = controller.view()
    }
    #expect(mapView.frameObserverCount == 1)

    mapView.frame = frame
    #expect(mapView.frameObserverCount == 0)
  }

  @Test func handleResultTileDownsamplesWideGamutImages() throws {
    let controller = FGMTileProviderController()

    let bundle = Bundle(for: MockCATransaction.self)
    let imagePath = try #require(
      bundle.path(forResource: "widegamut", ofType: "png", inDirectory: "assets"))
    let wideGamutImage = try #require(UIImage(contentsOfFile: imagePath))

    let downsampledImage = try #require(controller.handleResultTile(wideGamutImage))

    let imageRef = try #require(downsampledImage.cgImage)
    let bitsPerComponent = imageRef.bitsPerComponent

    // non wide gamut images use 8 bit format
    #expect(bitsPerComponent == 8)
    #expect(imageRef.alphaInfo == .premultipliedLast)
  }

  @Test func animateCameraWithUpdate() throws {
    let frame = CGRect(x: 0, y: 0, width: 100, height: 100)
    let mapViewOptions = GMSMapViewOptions()
    mapViewOptions.frame = frame

    // Init camera with zero zoom.
    mapViewOptions.camera = GMSCameraPosition(latitude: 0, longitude: 0, zoom: 0)

    let mapView = PartiallyMockedMapView(options: mapViewOptions)

    let controller = GoogleMapController(
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

    controller.callHandler.animateCamera(with: cameraUpdate, duration: nil, error: &error)
    #expect(error == nil)
    #expect(mapView.didAnimateCamera)
    #expect(!mockTransactionWrapper.beginCalled)
    #expect(!mockTransactionWrapper.commitCalled)
  }

  @Test func animateCameraWithUpdateAndDuration() throws {
    let frame = CGRect(x: 0, y: 0, width: 100, height: 100)
    let mapViewOptions = GMSMapViewOptions()
    mapViewOptions.frame = frame

    // Init camera with zero zoom.
    mapViewOptions.camera = GMSCameraPosition(latitude: 0, longitude: 0, zoom: 0)

    let mapView = PartiallyMockedMapView(options: mapViewOptions)

    let controller = GoogleMapController(
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
    #expect(error == nil)
    #expect(mapView.didAnimateCamera)
    #expect(mockTransactionWrapper.beginCalled)
    #expect(mockTransactionWrapper.commitCalled)
    #expect(mockTransactionWrapper.animationDuration == durationMilliseconds.doubleValue / 1000)
  }

  @Test func inspectorAPICameraPosition() throws {
    let frame = CGRect(x: 0, y: 0, width: 100, height: 100)
    let mapViewOptions = GMSMapViewOptions()
    mapViewOptions.frame = frame

    // Init camera with specific position.
    let initialCameraPosition = GMSCameraPosition(latitude: 37.7749, longitude: -122.4194, zoom: 10)
    mapViewOptions.camera = initialCameraPosition

    let mapView = PartiallyMockedMapView(options: mapViewOptions)

    let binaryMessenger = StubBinaryMessenger()
    let controller = GoogleMapController(
      mapView: mapView,
      viewIdentifier: 0,
      creationParameters: emptyCreationParameters(),
      assetProvider: TestAssetProvider(),
      binaryMessenger: binaryMessenger
    )

    let inspector = MapInspector(messenger: binaryMessenger, pigeonSuffix: "0")
    inspector.controller = controller

    var error: FlutterError? = nil
    let cameraPosition = try #require(inspector.cameraPosition(&error))
    #expect(error == nil)

    #expect(cameraPosition.target.latitude == initialCameraPosition.target.latitude)
    #expect(cameraPosition.target.longitude == initialCameraPosition.target.longitude)
    #expect(Double(cameraPosition.zoom) == Double(initialCameraPosition.zoom))
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

  @Test func frameObserverRemovedOnDeinitIfNeverFired() {
    let options = GMSMapViewOptions()
    options.frame = .zero
    options.camera = GMSCameraPosition(latitude: 0, longitude: 0, zoom: 0)
    let mapView = PartiallyMockedMapView(options: options)

    var controller: GoogleMapController? = GoogleMapController(
      mapView: mapView,
      viewIdentifier: 0,
      creationParameters: emptyCreationParameters(),
      assetProvider: TestAssetProvider(),
      binaryMessenger: StubBinaryMessenger()
    )

    #expect(mapView.frameObserverCount == 1)

    // Deallocate the controller
    controller = nil

    #expect(mapView.frameObserverCount == 0)
  }

  @Test func styleErrorPersistsAcrossConfigUpdates() {
    let mapView = PartiallyMockedMapView(options: GMSMapViewOptions())
    let controller = GoogleMapController(
      mapView: mapView,
      viewIdentifier: 0,
      creationParameters: emptyCreationParameters(),
      assetProvider: TestAssetProvider(),
      binaryMessenger: StubBinaryMessenger()
    )

    // Set an invalid style to trigger an error
    _ = controller.setMapStyle("invalid json")
    #expect(controller.styleError != nil)

    // Update config without style
    let config = FGMPlatformMapConfiguration.make(
      withCompassEnabled: true,
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
    )
    controller.interpretMapConfiguration(config)

    // The style error should still be present
    #expect(controller.styleError != nil)
  }
}
