// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import GoogleMaps
import GoogleMapsUtils

/// Protocol for CATransaction to allow mocking in tests.
protocol MapAnimationCATransactionProtocol {
  func begin()
  func commit()
  func setAnimationDuration(_ duration: CFTimeInterval)
}

/// Non-test implementation of MapAnimationCATransactionProtocol.
class DefaultMapAnimationCATransaction: MapAnimationCATransactionProtocol {
  func begin() {
    CATransaction.begin()
  }

  func commit() {
    CATransaction.commit()
  }

  func setAnimationDuration(_ duration: CFTimeInterval) {
    CATransaction.setAnimationDuration(duration)
  }
}

/// Non-test implementation of AssetProvider, wrapping a Flutter plugin registrar.
class DefaultAssetProvider: AssetProvider {
  weak var registrar: FlutterPluginRegistrar?

  init(registrar: FlutterPluginRegistrar) {
    self.registrar = registrar
  }

  func lookupKey(forAsset asset: String) -> String? {
    return registrar?.lookupKey(forAsset: asset)
  }

  func lookupKey(forAsset asset: String, fromPackage package: String) -> String? {
    return registrar?.lookupKey(forAsset: asset, fromPackage: package)
  }

  func imageNamed(_ name: String) -> UIImage? {
    return UIImage(named: name)
  }
}

/// Non-test implementation of MapEventDelegate, wrapping a MapsCallbackApi instance.
class DefaultMapEventHandler: MapEventDelegate {
  let callbackHandler: MapsCallbackApi

  init(callbackHandler: MapsCallbackApi) {
    self.callbackHandler = callbackHandler
  }

  func didStartCameraMove() {
    callbackHandler.didStartCameraMove { _ in }
  }

  func didMoveCamera(to cameraPosition: PlatformCameraPosition) {
    callbackHandler.didMoveCamera(to: cameraPosition) { _ in }
  }

  func didIdleCamera() {
    callbackHandler.didIdleCamera { _ in }
  }

  func didTap(at position: PlatformLatLng) {
    callbackHandler.didTap(at: position) { _ in }
  }

  func didLongPress(at position: PlatformLatLng) {
    callbackHandler.didLongPress(at: position) { _ in }
  }

  func didTapMarker(withIdentifier markerId: String) {
    callbackHandler.didTapMarker(withIdentifier: markerId) { _ in }
  }

  func didStartDragForMarker(
    withIdentifier markerId: String, at position: PlatformLatLng
  ) {
    callbackHandler.didStartDragForMarker(withIdentifier: markerId, at: position) { _ in }
  }

  func didDragMarker(withIdentifier markerId: String, at position: PlatformLatLng) {
    callbackHandler.didDragMarker(withIdentifier: markerId, at: position) { _ in }
  }

  func didEndDragForMarker(withIdentifier markerId: String, at position: PlatformLatLng) {
    callbackHandler.didEndDragForMarker(withIdentifier: markerId, at: position) { _ in }
  }

  func didTapInfoWindowOfMarker(withIdentifier markerId: String) {
    callbackHandler.didTapInfoWindowOfMarker(withIdentifier: markerId) { _ in }
  }

  func didTapCircle(withIdentifier circleId: String) {
    callbackHandler.didTapCircle(withIdentifier: circleId) { _ in }
  }

  func didTapCluster(_ cluster: PlatformCluster) {
    callbackHandler.didTapCluster(cluster) { _ in }
  }

  func didTapPolygon(withIdentifier polygonId: String) {
    callbackHandler.didTapPolygon(withIdentifier: polygonId) { _ in }
  }

  func didTapPolyline(withIdentifier polylineId: String) {
    callbackHandler.didTapPolyline(withIdentifier: polylineId) { _ in }
  }

  func didTapGroundOverlay(withIdentifier groundOverlayId: String) {
    callbackHandler.didTapGroundOverlay(withIdentifier: groundOverlayId) { _ in }
  }
}

public class GoogleMapController: NSObject, GMSMapViewDelegate, FlutterPlatformView {
  /// The Google Maps SDK map view managed by this controller.
  let mapView: GMSMapView
  /// The Pigeon callback API implementation, used to send events to the Dart side.
  let dartCallbackHandler: MapsCallbackApi
  /// The map SDK event handler, which routes events to the Dart callback handler.
  let mapEventHandler: DefaultMapEventHandler
  /// The main Pigeon API implementation, separate to avoid lifetime extension.
  let callHandler: MapCallHandler
  /// The inspector API implementation, separate to avoid lifetime extension.
  let inspector: MapInspector
  /// A shim to pass tile requests to `dartCallbackHandler`. This is a separate object to avoid init ordering issues.
  private let tileProvider: ConcreteTileProvider
  /// Whether to send notifications about camera position changes to Dart.
  var trackCameraPosition = false

  /// Sub-controllers for managing individual map features.
  let clusterManagersController: ClusterManagersController
  let markersController: MarkersController
  let polygonsController: PolygonsController
  let polylinesController: PolylinesController
  let circlesController: CirclesController
  let heatmapsController: HeatmapsController
  let tileOverlaysController: TileOverlaysController
  let groundOverlaysController: GroundOverlaysController

  // The resulting error message, if any, from the last attempt to set the map style.
  // This is used to provide access to errors after the fact, since the map style is generally set at
  // creation time and there's no mechanism to return non-fatal error details during platform view
  // initialization.
  var styleError: String?
  /// Whether there is an observer registered for the "frame" key path on `mapView`. Used to ensure
  /// that the observer is removed before the controller is deallocated.
  private var isObservingFrame = false

  convenience init(
    frame: CGRect,
    viewIdentifier viewId: Int64,
    creationParameters: PlatformMapViewCreationParams,
    registrar: FlutterPluginRegistrar
  ) {
    let camera = creationParameters.initialCameraPosition.toGMSCameraPosition()

    let options = GMSMapViewOptions()
    options.frame = frame
    options.camera = camera
    if let mapId = creationParameters.mapConfiguration.mapId, !mapId.isEmpty {
      options.mapID = GMSMapID(identifier: mapId)
    }

    self.init(
      mapView: GMSMapView(options: options),
      viewIdentifier: viewId,
      creationParameters: creationParameters,
      assetProvider: DefaultAssetProvider(registrar: registrar),
      binaryMessenger: registrar.messenger()
    )
  }

  init(
    mapView: GMSMapView,
    viewIdentifier viewId: Int64,
    creationParameters: PlatformMapViewCreationParams,
    assetProvider: AssetProvider,
    binaryMessenger: FlutterBinaryMessenger
  ) {
    self.mapView = mapView
    mapView.accessibilityElementsHidden = false
    mapView.paddingAdjustmentBehavior = .never
    // The code below must be kept in sync with `interpretMapConfiguration`. The small amount of
    // duplication here is to avoid having to defer all map view configuration until after the
    // sub-controllers are given the map view.
    let (styleUpdateAttempted, errorString) = GoogleMapController.updateMapView(
      mapView, fromConfiguration: creationParameters.mapConfiguration)
    if styleUpdateAttempted {
      styleError = errorString
    }
    if let trackCameraPosition = creationParameters.mapConfiguration.trackCameraPosition {
      self.trackCameraPosition = trackCameraPosition
    }
    // End duplicate code.

    let pigeonSuffix = String(format: "%lld", viewId)
    dartCallbackHandler = MapsCallbackApi(
      binaryMessenger: binaryMessenger,
      messageChannelSuffix: pigeonSuffix
    )

    mapEventHandler = DefaultMapEventHandler(callbackHandler: dartCallbackHandler)

    let markerType = creationParameters.mapConfiguration.markerType

    clusterManagersController = ClusterManagersController(
      mapView: mapView,
      eventDelegate: mapEventHandler
    )
    markersController = MarkersController(
      mapView: mapView,
      eventDelegate: mapEventHandler,
      clusterManagersController: clusterManagersController,
      assetProvider: assetProvider,
      markerType: markerType
    )
    polygonsController = PolygonsController(
      mapView: mapView,
      eventDelegate: mapEventHandler
    )
    polylinesController = PolylinesController(
      mapView: mapView,
      eventDelegate: mapEventHandler
    )
    circlesController = CirclesController(
      mapView: mapView,
      eventDelegate: mapEventHandler
    )
    heatmapsController = HeatmapsController(mapView: mapView)
    tileProvider = ConcreteTileProvider(dartCallbackHandler: dartCallbackHandler)
    tileOverlaysController = TileOverlaysController(
      mapView: mapView,
      tileProvider: tileProvider
    )
    groundOverlaysController = GroundOverlaysController(
      mapView: mapView,
      eventDelegate: mapEventHandler,
      assetProvider: assetProvider
    )

    clusterManagersController.add(creationParameters.initialClusterManagers)
    markersController.add(creationParameters.initialMarkers)
    polygonsController.add(creationParameters.initialPolygons)
    polylinesController.add(creationParameters.initialPolylines)
    circlesController.add(creationParameters.initialCircles)
    heatmapsController.add(creationParameters.initialHeatmaps)
    tileOverlaysController.add(creationParameters.initialTileOverlays)
    groundOverlaysController.add(creationParameters.initialGroundOverlays)

    callHandler = MapCallHandler(
      messenger: binaryMessenger,
      pigeonSuffix: pigeonSuffix
    )
    inspector = MapInspector(
      messenger: binaryMessenger,
      pigeonSuffix: pigeonSuffix
    )

    super.init()

    callHandler.controller = self
    MapsApiSetup.setUp(
      binaryMessenger: binaryMessenger,
      api: callHandler,
      messageChannelSuffix: pigeonSuffix
    )
    inspector.controller = self
    MapsInspectorApiSetup.setUp(
      binaryMessenger: binaryMessenger,
      api: inspector,
      messageChannelSuffix: pigeonSuffix
    )

    mapView.delegate = self
    isObservingFrame = true
    mapView.addObserver(self, forKeyPath: "frame", options: [], context: nil)

    // Invoke clustering after everything is configured.
    clusterManagersController.invokeClusteringForEachClusterManager()
  }

  deinit {
    if isObservingFrame {
      mapView.removeObserver(self, forKeyPath: "frame")
    }
    MapsApiSetup.setUp(
      binaryMessenger: callHandler.messenger,
      api: nil,
      messageChannelSuffix: callHandler.pigeonSuffix
    )
    MapsInspectorApiSetup.setUp(
      binaryMessenger: inspector.messenger,
      api: nil,
      messageChannelSuffix: inspector.pigeonSuffix)
  }

  public func view() -> UIView {
    return mapView
  }

  override public func observeValue(
    forKeyPath keyPath: String?,
    of object: Any?,
    change: [NSKeyValueChangeKey: Any]?,
    context: UnsafeMutableRawPointer?
  ) {
    if let keyPath = keyPath,
      let gmsMapView = object as? GMSMapView,
      gmsMapView == mapView,
      keyPath == "frame"
    {
      let bounds = mapView.bounds
      if bounds.equalTo(.zero) {
        // The workaround is to fix an issue that the camera location is not current when
        // the size of the map is zero at initialization.
        // So We only care about the size of the `self.mapView`, ignore the frame changes when the
        // size is zero.
        return
      }
      // We only observe the frame for initial setup.
      isObservingFrame = false
      mapView.removeObserver(self, forKeyPath: "frame")
      mapView.moveCamera(GMSCameraUpdate.setCamera(mapView.camera))
    } else {
      super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }
  }

  public func showAtOrigin(_ origin: CGPoint) {
    mapView.frame = CGRect(origin: origin, size: mapView.frame.size)
    mapView.isHidden = false
  }

  public func hide() {
    mapView.isHidden = true
  }

  public func cameraPosition() -> GMSCameraPosition? {
    return trackCameraPosition ? mapView.camera : nil
  }

  func setCamera(_ camera: GMSCameraPosition) {
    mapView.camera = camera
  }

  /// Sets the map style, returning any error string as well as storing that error in `styleError` for
  /// later access.
  func setMapStyle(_ mapStyle: String) -> String? {
    let (style, errorString) = GoogleMapController.parseMapStyle(mapStyle)
    if errorString == nil {
      mapView.mapStyle = style
    }
    styleError = errorString
    return errorString
  }

  /// Attempts to construct a GMSMapStyle from a JSON style string, returning the style, as well as
  /// an error string if it the style could not be created.
  ///
  /// - If the String? value is non-nil, that description of the error should be stored in
  ///   `styleError` by the caller for later access, and the style should be set on the map.
  /// - If the String? value is nil, the style should be set on the map. The style may be nil if
  ///   the input string is empty, which is how the platform channel expresses clearing the style.
  static func parseMapStyle(_ jsonStyle: String) -> (GMSMapStyle?, String?) {
    if jsonStyle.isEmpty {
      return (nil, nil)
    }
    do {
      let style = try GMSMapStyle(jsonString: jsonStyle)
      return (style, nil)
    } catch let error {
      return (nil, error.localizedDescription)
    }
  }

  // MARK: - GMSMapViewDelegate methods

  public func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
    mapEventHandler.didStartCameraMove()
  }

  public func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
    if trackCameraPosition {
      mapEventHandler.didMoveCamera(to: PlatformCameraPosition.make(from: position))
    }
  }

  public func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
    mapEventHandler.didIdleCamera()
  }

  public func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
    if let cluster = marker.userData as? GMUStaticCluster {
      clusterManagersController.didTap(cluster)
      return false
    }
    if let markerId = markerIdentifierFromMarker(marker) {
      return markersController.didTapMarker(withIdentifier: markerId)
    }
    return false
  }

  public func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker) {
    if let markerId = markerIdentifierFromMarker(marker) {
      markersController.didEndDraggingMarker(withIdentifier: markerId, location: marker.position)
    }
  }

  public func mapView(_ mapView: GMSMapView, didBeginDragging marker: GMSMarker) {
    if let markerId = markerIdentifierFromMarker(marker) {
      markersController.didStartDraggingMarker(withIdentifier: markerId, location: marker.position)
    }
  }

  public func mapView(_ mapView: GMSMapView, didDrag marker: GMSMarker) {
    if let markerId = markerIdentifierFromMarker(marker) {
      markersController.didDragMarker(withIdentifier: markerId, location: marker.position)
    }
  }

  public func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
    if let markerId = markerIdentifierFromMarker(marker) {
      markersController.didTapInfoWindowOfMarker(withIdentifier: markerId)
    }
  }

  public func mapView(_ mapView: GMSMapView, didTap overlay: GMSOverlay) {
    guard let userDataArray = overlay.userData as? [Any],
      let overlayId = userDataArray.first as? String
    else {
      return
    }
    if polylinesController.hasPolyline(withIdentifier: overlayId) == true {
      polylinesController.didTapPolyline(withIdentifier: overlayId)
    } else if polygonsController.hasPolygon(withIdentifier: overlayId) == true {
      polygonsController.didTapPolygon(withIdentifier: overlayId)
    } else if circlesController.hasCircle(withIdentifier: overlayId) == true {
      circlesController.didTapCircle(withIdentifier: overlayId)
    } else if groundOverlaysController.hasGroundOverlays(withIdentifier: overlayId) == true {
      groundOverlaysController.didTapGroundOverlay(withIdentifier: overlayId)
    }
  }

  public func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
    mapEventHandler.didTap(at: PlatformLatLng.make(from: coordinate))
  }

  public func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
    mapEventHandler.didLongPress(at: PlatformLatLng.make(from: coordinate))
  }

  func interpretMapConfiguration(_ config: PlatformMapConfiguration) {
    // Any changes here must also be made to the `init` method above. See the comment there for
    // details.
    let (styleUpdateAttempted, errorString) = GoogleMapController.updateMapView(
      mapView, fromConfiguration: config)
    if styleUpdateAttempted {
      styleError = errorString
    }
    if let trackCameraPosition = config.trackCameraPosition {
      self.trackCameraPosition = trackCameraPosition
    }
  }

  /// Updates the given map view with new configuration options.
  ///
  /// Returns a boolean indicating whether a style update was attempted, and an error string
  /// describing any error interpreting the style in `config`. If the boolean is true, the error
  /// string should be stored in `styleError` for later access.
  static func updateMapView(
    _ mapView: GMSMapView, fromConfiguration config: PlatformMapConfiguration
  ) -> (Bool, String?) {
    if let cameraTargetBounds = config.cameraTargetBounds {
      if let bounds = cameraTargetBounds.bounds {
        mapView.cameraTargetBounds = bounds.toGMSCoordinateBounds()
      } else {
        mapView.cameraTargetBounds = nil
      }
    }
    if let compassEnabled = config.compassEnabled {
      mapView.settings.compassButton = compassEnabled
    }
    if let indoorEnabled = config.indoorViewEnabled {
      mapView.isIndoorEnabled = indoorEnabled
    }
    if let trafficEnabled = config.trafficEnabled {
      mapView.isTrafficEnabled = trafficEnabled
    }
    if let buildingsEnabled = config.buildingsEnabled {
      mapView.isBuildingsEnabled = buildingsEnabled
    }
    if let mapType = config.mapType {
      mapView.mapType = mapType.gmsMapViewType
    }
    if let zoomData = config.minMaxZoomPreference {
      let minZoom = zoomData.min.map({ Float($0) }) ?? kGMSMinZoomLevel
      let maxZoom = zoomData.max.map({ Float($0) }) ?? kGMSMaxZoomLevel
      mapView.setMinZoom(minZoom, maxZoom: maxZoom)
    }
    if let padding = config.padding {
      mapView.padding = UIEdgeInsets(
        top: CGFloat(padding.top),
        left: CGFloat(padding.left),
        bottom: CGFloat(padding.bottom),
        right: CGFloat(padding.right)
      )
    }
    if let rotateGesturesEnabled = config.rotateGesturesEnabled {
      mapView.settings.rotateGestures = rotateGesturesEnabled
    }
    if let scrollGesturesEnabled = config.scrollGesturesEnabled {
      mapView.settings.scrollGestures = scrollGesturesEnabled
    }
    if let tiltGesturesEnabled = config.tiltGesturesEnabled {
      mapView.settings.tiltGestures = tiltGesturesEnabled
    }
    if let zoomGesturesEnabled = config.zoomGesturesEnabled {
      mapView.settings.zoomGestures = zoomGesturesEnabled
    }
    if let myLocationEnabled = config.myLocationEnabled {
      mapView.isMyLocationEnabled = myLocationEnabled
    }
    if let myLocationButtonEnabled = config.myLocationButtonEnabled {
      mapView.settings.myLocationButton = myLocationButtonEnabled
    }
    if let mapStyle = config.style {
      let (style, errorString) = GoogleMapController.parseMapStyle(mapStyle)
      if errorString == nil {
        mapView.mapStyle = style
      }
      return (true, errorString)
    }
    return (false, nil)
  }
}

// TODO(stuartmorgan): Remove this in favor of an extension to add TileProviderDelegate to
// the Pigeon Flutter API object once this plugin has switched to Swift Pigeon generation
// (adjusting the protocol to match the Swift version of the signature).
private class ConcreteTileProvider: NSObject, TileProviderDelegate {
  let handler: MapsCallbackApi

  init(dartCallbackHandler: MapsCallbackApi) {
    handler = dartCallbackHandler
  }

  public func tile(
    withOverlayIdentifier tileOverlayId: String,
    location: PlatformPoint,
    zoom: Int64,
    completion: @escaping (Result<PlatformTile, PigeonError>) -> Void
  ) {
    handler.tile(
      withOverlayIdentifier: tileOverlayId,
      location: location,
      zoom: zoom,
      completion: completion
    )
  }
}

class MapCallHandler: NSObject, MapsApi {
  weak var controller: GoogleMapController?
  let messenger: FlutterBinaryMessenger
  let pigeonSuffix: String
  var transactionWrapper: MapAnimationCATransactionProtocol

  init(
    messenger: FlutterBinaryMessenger,
    pigeonSuffix suffix: String
  ) {
    self.messenger = messenger
    self.pigeonSuffix = suffix
    self.transactionWrapper = DefaultMapAnimationCATransaction()
    super.init()
  }

  func waitForMap() {
    // No-op; this call just ensures synchronization with the platform thread.
  }

  func updateCircles(
    adding toAdd: [PlatformCircle],
    changing toChange: [PlatformCircle],
    removing idsToRemove: [String]
  ) {
    controller?.circlesController.add(toAdd)
    controller?.circlesController.change(toChange)
    controller?.circlesController.removeCircles(withIdentifiers: idsToRemove)
  }

  func updateHeatmaps(
    adding toAdd: [PlatformHeatmap],
    changing toChange: [PlatformHeatmap],
    removing idsToRemove: [String]
  ) {
    controller?.heatmapsController.add(toAdd)
    controller?.heatmapsController.change(toChange)
    controller?.heatmapsController.removeHeatmaps(withIdentifiers: idsToRemove)
  }

  func updateWithMapConfiguration(_ configuration: PlatformMapConfiguration) {
    controller?.interpretMapConfiguration(configuration)
  }

  func updateMarkers(
    adding toAdd: [PlatformMarker],
    changing toChange: [PlatformMarker],
    removing idsToRemove: [String]
  ) {
    controller?.markersController.add(toAdd)
    controller?.markersController.change(toChange)
    controller?.markersController.removeMarkers(withIdentifiers: idsToRemove)
    // Invoke clustering after markers are added.
    controller?.clusterManagersController.invokeClusteringForEachClusterManager()
  }

  func updateClusterManagers(
    adding toAdd: [PlatformClusterManager],
    removing idsToRemove: [String]
  ) {
    controller?.clusterManagersController.add(toAdd)
    controller?.clusterManagersController.removeClusterManagers(withIdentifiers: idsToRemove)
  }

  func updatePolygons(
    adding toAdd: [PlatformPolygon],
    changing toChange: [PlatformPolygon],
    removing idsToRemove: [String]
  ) {
    controller?.polygonsController.add(toAdd)
    controller?.polygonsController.change(toChange)
    controller?.polygonsController.removePolygon(withIdentifiers: idsToRemove)
  }

  func updatePolylines(
    adding toAdd: [PlatformPolyline],
    changing toChange: [PlatformPolyline],
    removing idsToRemove: [String]
  ) {
    controller?.polylinesController.add(toAdd)
    controller?.polylinesController.change(toChange)
    controller?.polylinesController.removePolyline(withIdentifiers: idsToRemove)
  }

  func updateTileOverlays(
    adding toAdd: [PlatformTileOverlay],
    changing toChange: [PlatformTileOverlay],
    removing idsToRemove: [String]
  ) {
    controller?.tileOverlaysController.add(toAdd)
    controller?.tileOverlaysController.change(toChange)
    controller?.tileOverlaysController.removeTileOverlay(withIdentifiers: idsToRemove)
  }

  func updateGroundOverlays(
    adding toAdd: [PlatformGroundOverlay],
    changing toChange: [PlatformGroundOverlay],
    removing idsToRemove: [String]
  ) {
    controller?.groundOverlaysController.add(toAdd)
    controller?.groundOverlaysController.change(toChange)
    controller?.groundOverlaysController.removeGroundOverlays(withIdentifiers: idsToRemove)
  }

  func latLng(for screenCoordinate: PlatformPoint) throws -> PlatformLatLng {
    guard let mapView = controller?.mapView else {
      throw PigeonError(
        code: "GoogleMap uninitialized",
        message: "getLatLng called prior to map initialization",
        details: nil
      )
    }
    let point = screenCoordinate.toCGPoint()
    let latlng = mapView.projection.coordinate(for: point)
    return PlatformLatLng.make(from: latlng)
  }

  func screenCoordinates(for latLng: PlatformLatLng) throws -> PlatformPoint {
    guard let mapView = controller?.mapView else {
      throw PigeonError(
        code: "GoogleMap uninitialized",
        message: "getScreenCoordinate called prior to map initialization",
        details: nil
      )
    }
    let location = latLng.toCLLocationCoordinate2D()
    let point = mapView.projection.point(for: location)
    return PlatformPoint.make(from: point)
  }

  func visibleMapRegion() throws -> PlatformLatLngBounds {
    guard let mapView = controller?.mapView else {
      throw PigeonError(
        code: "GoogleMap uninitialized",
        message: "getVisibleRegion called prior to map initialization",
        details: nil
      )
    }
    let visibleRegion = mapView.projection.visibleRegion()
    let bounds = GMSCoordinateBounds(region: visibleRegion)
    return PlatformLatLngBounds.make(from: bounds)
  }

  func moveCamera(_ cameraUpdate: PlatformCameraUpdate) throws {
    guard let update = cameraUpdate.toGMSCameraUpdate() else {
      throw PigeonError(
        code: "Invalid update",
        message: "Unrecognized camera update",
        details: nil
      )
    }
    controller?.mapView.moveCamera(update)
  }

  func animateCamera(
    _ cameraUpdate: PlatformCameraUpdate,
    duration durationMilliseconds: Int64?
  ) throws {
    guard let update = cameraUpdate.toGMSCameraUpdate() else {
      throw PigeonError(
        code: "Invalid update",
        message: "Unrecognized camera update",
        details: nil
      )
    }
    let transaction = durationMilliseconds != nil ? transactionWrapper : nil
    transaction?.begin()
    if let duration = durationMilliseconds {
      transaction?.setAnimationDuration(Double(duration) / 1000.0)
    }
    controller?.mapView.animate(with: update)
    transaction?.commit()
  }

  func zoomLevel() throws -> Double {
    guard let mapView = controller?.mapView else {
      throw PigeonError(
        code: "GoogleMap uninitialized",
        message: "getZoomLevel called prior to map initialization",
        details: nil
      )
    }
    return Double(mapView.camera.zoom)
  }

  func showInfoWindowForMarker(withIdentifier markerId: String) throws {
    try controller?.markersController.showMarkerInfoWindow(withIdentifier: markerId)
  }

  func hideInfoWindowForMarker(withIdentifier markerId: String) throws {
    try controller?.markersController.hideMarkerInfoWindow(withIdentifier: markerId)
  }

  func isShowingInfoWindowForMarker(withIdentifier markerId: String) throws -> Bool {
    return try controller?.markersController.isInfoWindowShownForMarker(withIdentifier: markerId)
      ?? false
  }

  func setStyle(_ style: String) -> String? {
    return controller?.setMapStyle(style)
  }

  func lastStyleError() -> String? {
    return controller?.styleError
  }

  func clearTileCacheForOverlay(withIdentifier tileOverlayId: String) {
    controller?.tileOverlaysController.clearTileCache(withIdentifier: tileOverlayId)
  }

  func takeSnapshot() throws -> FlutterStandardTypedData? {
    guard let mapView = controller?.mapView else {
      throw PigeonError(
        code: "GoogleMap uninitialized",
        message: "takeSnapshot called prior to map initialization",
        details: nil
      )
    }
    let renderer = UIGraphicsImageRenderer(size: mapView.bounds.size)
    let image = renderer.image { context in
      mapView.drawHierarchy(in: mapView.bounds, afterScreenUpdates: true)
    }
    if let imageData = image.pngData() {
      return FlutterStandardTypedData(bytes: imageData)
    }
    return nil
  }

  func isAdvancedMarkersAvailable() -> Bool {
    return controller?.mapView.mapCapabilities.contains(.advancedMarkers) ?? false
  }
}

class MapInspector: NSObject, MapsInspectorApi {
  weak var controller: GoogleMapController?
  let messenger: FlutterBinaryMessenger
  let pigeonSuffix: String

  init(
    messenger: FlutterBinaryMessenger,
    pigeonSuffix suffix: String
  ) {
    self.messenger = messenger
    self.pigeonSuffix = suffix
    super.init()
  }

  func areBuildingsEnabled() -> Bool {
    return controller?.mapView.isBuildingsEnabled ?? false
  }

  func areRotateGesturesEnabled() -> Bool {
    return controller?.mapView.settings.rotateGestures ?? false
  }

  func areScrollGesturesEnabled() -> Bool {
    return controller?.mapView.settings.scrollGestures ?? false
  }

  func areTiltGesturesEnabled() -> Bool {
    return controller?.mapView.settings.tiltGestures ?? false
  }

  func areZoomGesturesEnabled() -> Bool {
    return controller?.mapView.settings.zoomGestures ?? false
  }

  func isCompassEnabled() -> Bool {
    return controller?.mapView.settings.compassButton ?? false
  }

  func isMyLocationButtonEnabled() -> Bool {
    return controller?.mapView.settings.myLocationButton ?? false
  }

  func isTrafficEnabled() -> Bool {
    return controller?.mapView.isTrafficEnabled ?? false
  }

  func tileOverlay(withIdentifier tileOverlayId: String) -> PlatformTileLayer? {
    guard let controller = controller,
      let layer = controller.tileOverlaysController.tileOverlay(withIdentifier: tileOverlayId)?
        .layer
    else {
      return nil
    }
    return PlatformTileLayer(
      visible: layer.map != nil,
      fadeIn: layer.fadeIn,
      opacity: Double(layer.opacity),
      zIndex: Int64(layer.zIndex)
    )
  }

  func heatmap(withIdentifier heatmapId: String) -> PlatformHeatmap? {
    return controller?.heatmapsController.heatmap(withIdentifier: heatmapId)
  }

  func clusters(withIdentifier clusterManagerId: String) throws -> [PlatformCluster] {
    return try controller?.clusterManagersController.clusters(withIdentifier: clusterManagerId)
      ?? []
  }

  func zoomRange() throws -> PlatformZoomRange {
    guard let mapView = controller?.mapView else {
      throw PigeonError(
        code: "GoogleMap uninitialized",
        message: "zoomRange called prior to map initialization",
        details: nil
      )
    }
    return PlatformZoomRange(min: Double(mapView.minZoom), max: Double(mapView.maxZoom))
  }

  func groundOverlay(withIdentifier groundOverlayId: String) -> PlatformGroundOverlay? {
    return controller?.groundOverlaysController.groundOverlay(withIdentifier: groundOverlayId)
  }

  func cameraPosition() throws -> PlatformCameraPosition {
    guard let mapView = controller?.mapView else {
      throw PigeonError(
        code: "GoogleMap uninitialized",
        message: "cameraPosition called prior to map initialization",
        details: nil
      )
    }
    return PlatformCameraPosition.make(from: mapView.camera)
  }
}
