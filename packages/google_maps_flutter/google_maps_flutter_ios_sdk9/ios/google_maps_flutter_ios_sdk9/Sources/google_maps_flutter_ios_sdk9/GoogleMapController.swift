// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import GoogleMaps
import GoogleMapsUtils
import google_maps_flutter_ios_sdk9_objc

/// Non-test implementation of FGMAssetProvider, wrapping a Flutter plugin registrar.
class DefaultAssetProvider: NSObject, FGMAssetProvider {
  weak var registrar: FlutterPluginRegistrar?

  init(registrar: FlutterPluginRegistrar) {
    self.registrar = registrar
    super.init()
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

/// Non-test implementation of FGMMapEventDelegate, wrapping a FGMMapsCallbackApi instance.
class DefaultMapEventHandler: NSObject, FGMMapEventDelegate {
  let callbackHandler: FGMMapsCallbackApi

  init(callbackHandler: FGMMapsCallbackApi) {
    self.callbackHandler = callbackHandler
    super.init()
  }

  func didStartCameraMove() {
    callbackHandler.didStartCameraMove { _ in }
  }

  func didMoveCamera(to cameraPosition: FGMPlatformCameraPosition) {
    callbackHandler.didMoveCamera(to: cameraPosition) { _ in }
  }

  func didIdleCamera() {
    callbackHandler.didIdleCamera { _ in }
  }

  func didTap(atPosition position: FGMPlatformLatLng) {
    callbackHandler.didTap(atPosition: position) { _ in }
  }

  func didLongPress(atPosition position: FGMPlatformLatLng) {
    callbackHandler.didLongPress(atPosition: position) { _ in }
  }

  func didTapMarker(withIdentifier markerId: String) {
    callbackHandler.didTapMarker(withIdentifier: markerId) { _ in }
  }

  func didStartDragForMarker(
    withIdentifier markerId: String, atPosition position: FGMPlatformLatLng
  ) {
    callbackHandler.didStartDragForMarker(withIdentifier: markerId, atPosition: position) { _ in }
  }

  func didDragMarker(withIdentifier markerId: String, atPosition position: FGMPlatformLatLng) {
    callbackHandler.didDragMarker(withIdentifier: markerId, atPosition: position) { _ in }
  }

  func didEndDragForMarker(withIdentifier markerId: String, atPosition position: FGMPlatformLatLng)
  {
    callbackHandler.didEndDragForMarker(withIdentifier: markerId, atPosition: position) { _ in }
  }

  func didTapInfoWindowOfMarker(withIdentifier markerId: String) {
    callbackHandler.didTapInfoWindowOfMarker(withIdentifier: markerId) { _ in }
  }

  func didTapCircle(withIdentifier circleId: String) {
    callbackHandler.didTapCircle(withIdentifier: circleId) { _ in }
  }

  func didTap(_ cluster: FGMPlatformCluster) {
    callbackHandler.didTap(cluster) { _ in }
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

public class GoogleMapController: NSObject, GMSMapViewDelegate, FlutterPlatformView,
  FGMTileProviderDelegate
{
  /// The Google Maps SDK map view managed by this controller.
  private(set) var mapView: GMSMapView
  /// The Pigeon callback API implementation, used to send events to the Dart side.
  var dartCallbackHandler: FGMMapsCallbackApi
  /// The map SDK event handler, which routes events to the Dart callback handler.
  var mapEventHandler: DefaultMapEventHandler
  // The main Pigeon API implementation, separate to avoid lifetime extension.
  var callHandler: MapCallHandler
  // The inspector API implementation, separate to avoid lifetime extension.
  var inspector: MapInspector
  /// Whether to send notifications about camera position changes to Dart.
  var trackCameraPosition = false

  /// Sub-controllers for managing individual map features.
  var clusterManagersController: FGMClusterManagersController
  var markersController: FGMMarkersController
  var polygonsController: FGMPolygonsController
  var polylinesController: FGMPolylinesController
  var circlesController: FGMCirclesController
  var heatmapsController: FGMHeatmapsController
  var tileOverlaysController: FGMTileOverlaysController
  var groundOverlaysController: FGMGroundOverlaysController

  // The resulting error message, if any, from the last attempt to set the map style.
  // This is used to provide access to errors after the fact, since the map style is generally set at
  // creation time and there's no mechanism to return non-fatal error details during platform view
  // initialization.
  var styleError: String?

  public convenience init(
    frame: CGRect,
    viewIdentifier viewId: Int64,
    creationParameters: FGMPlatformMapViewCreationParams,
    registrar: FlutterPluginRegistrar
  ) {
    let camera = FGMGetCameraPositionForPigeonCameraPosition(
      creationParameters.initialCameraPosition)

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

  public init(
    mapView: GMSMapView,
    viewIdentifier viewId: Int64,
    creationParameters: FGMPlatformMapViewCreationParams,
    assetProvider: FGMAssetProvider,
    binaryMessenger: FlutterBinaryMessenger
  ) {

    self.mapView = mapView

    mapView.accessibilityElementsHidden = false
    // TODO(stuartmorgan): avoid calling a state-mutating method in the middle of the init method.
    // https://github.com/flutter/flutter/issues/104121
    interpretMapConfiguration(creationParameters.mapConfiguration)
    let pigeonSuffix = String(format: "%lld", viewId)
    let dartCallbackHandler = FGMMapsCallbackApi(
      binaryMessenger: binaryMessenger,
      messageChannelSuffix: pigeonSuffix
    )
    self.dartCallbackHandler = dartCallbackHandler

    let mapEventHandler = DefaultMapEventHandler(callbackHandler: dartCallbackHandler)
    self.mapEventHandler = mapEventHandler

    let markerType = creationParameters.mapConfiguration.markerType
    mapView.delegate = self
    mapView.paddingAdjustmentBehavior = .never

    let clusterManagersController = FGMClusterManagersController(
      mapView: mapView,
      eventDelegate: mapEventHandler
    )
    self.clusterManagersController = clusterManagersController
    self.markersController = FGMMarkersController(
      mapView: mapView,
      eventDelegate: mapEventHandler,
      clusterManagersController: clusterManagersController,
      assetProvider: assetProvider,
      markerType: markerType
    )
    self.polygonsController = FGMPolygonsController(
      mapView: mapView,
      eventDelegate: mapEventHandler
    )
    self.polylinesController = FGMPolylinesController(
      mapView: mapView,
      eventDelegate: mapEventHandler
    )
    self.circlesController = FGMCirclesController(
      mapView: mapView,
      eventDelegate: mapEventHandler
    )
    self.heatmapsController = FGMHeatmapsController(mapView: mapView)
    self.tileOverlaysController = FGMTileOverlaysController(
      mapView: mapView,
      tileProvider: self
    )
    self.groundOverlaysController = FGMGroundOverlaysController(
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

    // Invoke clustering after markers are added.
    clusterManagersController.invokeClusteringForEachClusterManager()

    mapView.addObserver(self, forKeyPath: "frame", options: [], context: nil)

    let callHandler = MapCallHandler(
      mapController: self,
      messenger: binaryMessenger,
      pigeonSuffix: pigeonSuffix
    )
    self.callHandler = callHandler
    SetUpFGMMapsApiWithSuffix(binaryMessenger, callHandler, pigeonSuffix)

    let inspector = MapInspector(
      mapController: self,
      messenger: binaryMessenger,
      pigeonSuffix: pigeonSuffix
    )
    self.inspector = inspector
    SetUpFGMMapsInspectorApiWithSuffix(binaryMessenger, inspector, pigeonSuffix)

    super.init()
  }

  deinit {
    SetUpFGMMapsApiWithSuffix(callHandler.messenger, nil, callHandler.pigeonSuffix)
    SetUpFGMMapsInspectorApiWithSuffix(inspector.messenger, nil, inspector.pigeonSuffix)
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

  func setCameraTargetBounds(_ bounds: GMSCoordinateBounds?) {
    mapView.cameraTargetBounds = bounds
  }

  func setCompassEnabled(_ enabled: Bool) {
    mapView.settings.compassButton = enabled
  }

  func setIndoorEnabled(_ enabled: Bool) {
    mapView.isIndoorEnabled = enabled
  }

  func setTrafficEnabled(_ enabled: Bool) {
    mapView.isTrafficEnabled = enabled
  }

  func setBuildingsEnabled(_ enabled: Bool) {
    mapView.isBuildingsEnabled = enabled
  }

  func setMapType(_ mapType: GMSMapViewType) {
    mapView.mapType = mapType
  }

  func setMinZoom(_ minZoom: Float, maxZoom: Float) {
    mapView.setMinZoom(minZoom, maxZoom: maxZoom)
  }

  func setPadding(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) {
    mapView.padding = UIEdgeInsets(
      top: top,
      left: left,
      bottom: bottom,
      right: right
    )
  }

  func setRotateGesturesEnabled(_ enabled: Bool) {
    mapView.settings.rotateGestures = enabled
  }

  func setScrollGesturesEnabled(_ enabled: Bool) {
    mapView.settings.scrollGestures = enabled
  }

  func setTiltGesturesEnabled(_ enabled: Bool) {
    mapView.settings.tiltGestures = enabled
  }

  func setTrackCameraPosition(_ enabled: Bool) {
    trackCameraPosition = enabled
  }

  func setZoomGesturesEnabled(_ enabled: Bool) {
    mapView.settings.zoomGestures = enabled
  }

  func setMyLocationEnabled(_ enabled: Bool) {
    mapView.isMyLocationEnabled = enabled
  }

  func setMyLocationButtonEnabled(_ enabled: Bool) {
    mapView.settings.myLocationButton = enabled
  }

  /// Sets the map style, returning any error string as well as storing that error in `styleError` for
  /// later access.
  func setMapStyle(_ mapStyle: String) -> String? {
    var errorString: String? = nil
    if mapStyle.isEmpty {
      mapView.mapStyle = nil
    } else {
      do {
        mapView.mapStyle = try GMSMapStyle(jsonString: mapStyle)
      } catch let error {
        errorString = error.localizedDescription
      }
    }
    styleError = errorString
    return errorString
  }

  // MARK: - GMSMapViewDelegate methods

  public func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
    mapEventHandler.didStartCameraMove()
  }

  public func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
    if trackCameraPosition {
      mapEventHandler.didMoveCamera(to: FGMGetPigeonCameraPositionForPosition(position))
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
    if let markerId = FGMGetMarkerIdentifierFromMarker(marker) {
      return markersController.didTapMarker(withIdentifier: markerId)
    }
    return false
  }

  public func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker) {
    if let markerId = FGMGetMarkerIdentifierFromMarker(marker) {
      markersController.didEndDraggingMarker(withIdentifier: markerId, location: marker.position)
    }
  }

  public func mapView(_ mapView: GMSMapView, didBeginDragging marker: GMSMarker) {
    if let markerId = FGMGetMarkerIdentifierFromMarker(marker) {
      markersController.didStartDraggingMarker(withIdentifier: markerId, location: marker.position)
    }
  }

  public func mapView(_ mapView: GMSMapView, didDrag marker: GMSMarker) {
    if let markerId = FGMGetMarkerIdentifierFromMarker(marker) {
      markersController.didDragMarker(withIdentifier: markerId, location: marker.position)
    }
  }

  public func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
    if let markerId = FGMGetMarkerIdentifierFromMarker(marker) {
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
    mapEventHandler.didTap(atPosition: FGMGetPigeonLatLngForCoordinate(coordinate))
  }

  public func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
    mapEventHandler.didLongPress(atPosition: FGMGetPigeonLatLngForCoordinate(coordinate))
  }

  func interpretMapConfiguration(_ config: FGMPlatformMapConfiguration) {
    if let cameraTargetBounds = config.cameraTargetBounds {
      if let bounds = cameraTargetBounds.bounds {
        setCameraTargetBounds(FGMGetCoordinateBoundsForPigeonLatLngBounds(bounds))
      } else {
        setCameraTargetBounds(nil)
      }
    }
    if let compassEnabled = config.compassEnabled {
      setCompassEnabled(compassEnabled.boolValue)
    }
    if let indoorEnabled = config.indoorViewEnabled {
      setIndoorEnabled(indoorEnabled.boolValue)
    }
    if let trafficEnabled = config.trafficEnabled {
      setTrafficEnabled(trafficEnabled.boolValue)
    }
    if let buildingsEnabled = config.buildingsEnabled {
      setBuildingsEnabled(buildingsEnabled.boolValue)
    }
    if let mapType = config.mapType {
      setMapType(FGMGetMapViewTypeForPigeonMapType(mapType.value))
    }
    if let zoomData = config.minMaxZoomPreference {
      let minZoom = zoomData.min?.floatValue ?? kGMSMinZoomLevel
      let maxZoom = zoomData.max?.floatValue ?? kGMSMaxZoomLevel
      setMinZoom(minZoom, maxZoom: maxZoom)
    }
    if let padding = config.padding {
      setPadding(
        top: CGFloat(padding.top),
        left: CGFloat(padding.left),
        bottom: CGFloat(padding.bottom),
        right: CGFloat(padding.right)
      )
    }
    if let rotateGesturesEnabled = config.rotateGesturesEnabled {
      setRotateGesturesEnabled(rotateGesturesEnabled.boolValue)
    }
    if let scrollGesturesEnabled = config.scrollGesturesEnabled {
      setScrollGesturesEnabled(scrollGesturesEnabled.boolValue)
    }
    if let tiltGesturesEnabled = config.tiltGesturesEnabled {
      setTiltGesturesEnabled(tiltGesturesEnabled.boolValue)
    }
    if let trackCameraPosition = config.trackCameraPosition {
      setTrackCameraPosition(trackCameraPosition.boolValue)
    }
    if let zoomGesturesEnabled = config.zoomGesturesEnabled {
      setZoomGesturesEnabled(zoomGesturesEnabled.boolValue)
    }
    if let myLocationEnabled = config.myLocationEnabled {
      setMyLocationEnabled(myLocationEnabled.boolValue)
    }
    if let myLocationButtonEnabled = config.myLocationButtonEnabled {
      setMyLocationButtonEnabled(myLocationButtonEnabled.boolValue)
    }
    if let style = config.style {
      _ = setMapStyle(style)
    }
  }

  // MARK: - FGMTileProviderDelegate

  public func tile(
    withOverlayIdentifier tileOverlayId: String,
    location: FGMPlatformPoint,
    zoom: Int,
    completion: @escaping (FGMPlatformTile?, FlutterError?) -> Void
  ) {
    dartCallbackHandler.tile(
      withOverlayIdentifier: tileOverlayId,
      location: location,
      zoom: zoom,
      completion: completion
    )
  }
}

class MapCallHandler: NSObject, FGMMapsApi {
  weak var controller: GoogleMapController?
  let messenger: FlutterBinaryMessenger
  let pigeonSuffix: String
  var transactionWrapper: FGMCATransactionProtocol

  init(
    mapController controller: GoogleMapController,
    messenger: FlutterBinaryMessenger,
    pigeonSuffix suffix: String
  ) {
    self.controller = controller
    self.messenger = messenger
    self.pigeonSuffix = suffix
    self.transactionWrapper = FGMCATransactionWrapper()
    super.init()
  }

  func waitForMapWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
    // No-op; this call just ensures synchronization with the platform thread.
  }

  func updateCircles(
    byAdding toAdd: [FGMPlatformCircle], changing toChange: [FGMPlatformCircle],
    removing idsToRemove: [String], error: AutoreleasingUnsafeMutablePointer<FlutterError?>
  ) {
    controller?.circlesController.add(toAdd)
    controller?.circlesController.change(toChange)
    controller?.circlesController.removeCircles(withIdentifiers: idsToRemove)
  }

  func updateHeatmaps(
    byAdding toAdd: [FGMPlatformHeatmap], changing toChange: [FGMPlatformHeatmap],
    removing idsToRemove: [String], error: AutoreleasingUnsafeMutablePointer<FlutterError?>
  ) {
    controller?.heatmapsController.add(toAdd)
    controller?.heatmapsController.change(toChange)
    controller?.heatmapsController.removeHeatmaps(withIdentifiers: idsToRemove)
  }

  func update(
    with configuration: FGMPlatformMapConfiguration,
    error: AutoreleasingUnsafeMutablePointer<FlutterError?>
  ) {
    controller?.interpretMapConfiguration(configuration)
  }

  func updateMarkers(
    byAdding toAdd: [FGMPlatformMarker], changing toChange: [FGMPlatformMarker],
    removing idsToRemove: [String], error: AutoreleasingUnsafeMutablePointer<FlutterError?>
  ) {
    controller?.markersController.add(toAdd)
    controller?.markersController.change(toChange)
    controller?.markersController.removeMarkers(withIdentifiers: idsToRemove)
    controller?.clusterManagersController.invokeClusteringForEachClusterManager()
  }

  func updateClusterManagers(
    byAdding toAdd: [FGMPlatformClusterManager], removing idsToRemove: [String],
    error: AutoreleasingUnsafeMutablePointer<FlutterError?>
  ) {
    controller?.clusterManagersController.add(toAdd)
    controller?.clusterManagersController.removeClusterManagers(withIdentifiers: idsToRemove)
  }

  func updatePolygons(
    byAdding toAdd: [FGMPlatformPolygon], changing toChange: [FGMPlatformPolygon],
    removing idsToRemove: [String], error: AutoreleasingUnsafeMutablePointer<FlutterError?>
  ) {
    controller?.polygonsController.add(toAdd)
    controller?.polygonsController.change(toChange)
    controller?.polygonsController.removePolygon(withIdentifiers: idsToRemove)
  }

  func updatePolylines(
    byAdding toAdd: [FGMPlatformPolyline], changing toChange: [FGMPlatformPolyline],
    removing idsToRemove: [String], error: AutoreleasingUnsafeMutablePointer<FlutterError?>
  ) {
    controller?.polylinesController.add(toAdd)
    controller?.polylinesController.change(toChange)
    controller?.polylinesController.removePolyline(withIdentifiers: idsToRemove)
  }

  func updateTileOverlays(
    byAdding toAdd: [FGMPlatformTileOverlay], changing toChange: [FGMPlatformTileOverlay],
    removing idsToRemove: [String], error: AutoreleasingUnsafeMutablePointer<FlutterError?>
  ) {
    controller?.tileOverlaysController.add(toAdd)
    controller?.tileOverlaysController.change(toChange)
    controller?.tileOverlaysController.removeTileOverlay(withIdentifiers: idsToRemove)
  }

  func updateGroundOverlays(
    byAdding toAdd: [FGMPlatformGroundOverlay], changing toChange: [FGMPlatformGroundOverlay],
    removing idsToRemove: [String], error: AutoreleasingUnsafeMutablePointer<FlutterError?>
  ) {
    controller?.groundOverlaysController.add(toAdd)
    controller?.groundOverlaysController.change(toChange)
    controller?.groundOverlaysController.removeGroundOverlays(withIdentifiers: idsToRemove)
  }

  func latLng(
    forScreenCoordinate screenCoordinate: FGMPlatformPoint,
    error: AutoreleasingUnsafeMutablePointer<FlutterError?>
  ) -> FGMPlatformLatLng? {
    guard let mapView = controller?.mapView else {
      error.pointee = FlutterError(
        code: "GoogleMap uninitialized",
        message: "getLatLng called prior to map initialization",
        details: nil
      )
      return nil
    }
    let point = FGMGetCGPointForPigeonPoint(screenCoordinate)
    let latlng = mapView.projection.coordinate(for: point)
    return FGMGetPigeonLatLngForCoordinate(latlng)
  }

  func screenCoordinates(
    for latLng: FGMPlatformLatLng, error: AutoreleasingUnsafeMutablePointer<FlutterError?>
  ) -> FGMPlatformPoint? {
    guard let mapView = controller?.mapView else {
      error.pointee = FlutterError(
        code: "GoogleMap uninitialized",
        message: "getScreenCoordinate called prior to map initialization",
        details: nil
      )
      return nil
    }
    let location = FGMGetCoordinateForPigeonLatLng(latLng)
    let point = mapView.projection.point(for: location)
    return FGMGetPigeonPointForCGPoint(point)
  }

  func visibleMapRegion(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>)
    -> FGMPlatformLatLngBounds?
  {
    guard let mapView = controller?.mapView else {
      error.pointee = FlutterError(
        code: "GoogleMap uninitialized",
        message: "getVisibleRegion called prior to map initialization",
        details: nil
      )
      return nil
    }
    let visibleRegion = mapView.projection.visibleRegion()
    let bounds = GMSCoordinateBounds(region: visibleRegion)
    return FGMGetPigeonLatLngBoundsForCoordinateBounds(bounds)
  }

  func moveCamera(
    with cameraUpdate: FGMPlatformCameraUpdate,
    error: AutoreleasingUnsafeMutablePointer<FlutterError?>
  ) {
    guard let update = FGMGetCameraUpdateForPigeonCameraUpdate(cameraUpdate) else {
      error.pointee = FlutterError(
        code: "Invalid update",
        message: "Unrecognized camera update",
        details: nil
      )
      return
    }
    controller?.mapView.moveCamera(update)
  }

  func animateCamera(
    with cameraUpdate: FGMPlatformCameraUpdate, duration durationMilliseconds: NSNumber?,
    error: AutoreleasingUnsafeMutablePointer<FlutterError?>
  ) {
    guard let update = FGMGetCameraUpdateForPigeonCameraUpdate(cameraUpdate) else {
      error.pointee = FlutterError(
        code: "Invalid update",
        message: "Unrecognized camera update",
        details: nil
      )
      return
    }
    let transaction = durationMilliseconds != nil ? transactionWrapper : nil
    transaction?.begin()
    if let duration = durationMilliseconds {
      transaction?.setAnimationDuration(duration.doubleValue / 1000.0)
    }
    controller?.mapView.animate(with: update)
    transaction?.commit()
  }

  func currentZoomLevel(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> NSNumber? {
    guard let mapView = controller?.mapView else {
      return nil
    }
    return NSNumber(value: mapView.camera.zoom)
  }

  func showInfoWindowForMarker(
    withIdentifier markerId: String, error: AutoreleasingUnsafeMutablePointer<FlutterError?>
  ) {
    controller?.markersController.showMarkerInfoWindow(withIdentifier: markerId, error: error)
  }

  func hideInfoWindowForMarker(
    withIdentifier markerId: String, error: AutoreleasingUnsafeMutablePointer<FlutterError?>
  ) {
    controller?.markersController.hideMarkerInfoWindow(withIdentifier: markerId, error: error)
  }

  func isShowingInfoWindowForMarker(
    withIdentifier markerId: String, error: AutoreleasingUnsafeMutablePointer<FlutterError?>
  ) -> NSNumber? {
    return controller?.markersController.isInfoWindowShownForMarker(
      withIdentifier: markerId, error: error)
  }

  func setStyle(_ style: String, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> String?
  {
    return controller?.setMapStyle(style)
  }

  func lastStyleError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> String? {
    return controller?.styleError
  }

  func clearTileCacheForOverlay(
    withIdentifier tileOverlayId: String, error: AutoreleasingUnsafeMutablePointer<FlutterError?>
  ) {
    controller?.tileOverlaysController.clearTileCache(withIdentifier: tileOverlayId)
  }

  func takeSnapshotWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>)
    -> FlutterStandardTypedData?
  {
    guard let mapView = controller?.mapView else {
      error.pointee = FlutterError(
        code: "GoogleMap uninitialized",
        message: "takeSnapshot called prior to map initialization",
        details: nil
      )
      return nil
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

  func isAdvancedMarkersAvailable(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>)
    -> NSNumber?
  {
    guard let mapView = controller?.mapView else {
      return false
    }
    let advancedMarkerFlag =
      mapView.mapCapabilities.rawValue & GMSMapCapabilityFlags.advancedMarkers.rawValue
    return NSNumber(value: advancedMarkerFlag != 0)
  }
}

class MapInspector: NSObject, FGMMapsInspectorApi {
  weak var controller: GoogleMapController?
  let messenger: FlutterBinaryMessenger
  let pigeonSuffix: String

  init(
    mapController controller: GoogleMapController,
    messenger: FlutterBinaryMessenger,
    pigeonSuffix suffix: String
  ) {
    self.controller = controller
    self.messenger = messenger
    self.pigeonSuffix = suffix
    super.init()
  }

  func areBuildingsEnabledWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>)
    -> NSNumber?
  {
    guard let mapView = controller?.mapView else {
      return nil
    }
    return NSNumber(value: mapView.isBuildingsEnabled)
  }

  func areRotateGesturesEnabledWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>)
    -> NSNumber?
  {
    guard let mapView = controller?.mapView else {
      return nil
    }
    return NSNumber(value: mapView.settings.rotateGestures)
  }

  func areScrollGesturesEnabledWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>)
    -> NSNumber?
  {
    guard let mapView = controller?.mapView else {
      return nil
    }
    return NSNumber(value: mapView.settings.scrollGestures)
  }

  func areTiltGesturesEnabledWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>)
    -> NSNumber?
  {
    guard let mapView = controller?.mapView else {
      return nil
    }
    return NSNumber(value: mapView.settings.tiltGestures)
  }

  func areZoomGesturesEnabledWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>)
    -> NSNumber?
  {
    guard let mapView = controller?.mapView else {
      return nil
    }
    return NSNumber(value: mapView.settings.zoomGestures)
  }

  func tileOverlay(
    withIdentifier tileOverlayId: String, error: AutoreleasingUnsafeMutablePointer<FlutterError?>
  ) -> FGMPlatformTileLayer? {
    guard let controller = controller,
      let layer = controller.tileOverlaysController.tileOverlay(withIdentifier: tileOverlayId)?
        .layer
    else {
      return nil
    }
    return FGMPlatformTileLayer.make(
      withVisible: layer.map != nil,
      fadeIn: layer.fadeIn,
      opacity: Double(layer.opacity),
      zIndex: Int(layer.zIndex)
    )
  }

  func heatmap(
    withIdentifier heatmapId: String, error: AutoreleasingUnsafeMutablePointer<FlutterError?>
  ) -> FGMPlatformHeatmap? {
    return controller?.heatmapsController.heatmap(withIdentifier: heatmapId)
  }

  func clusters(
    withIdentifier clusterManagerId: String, error: AutoreleasingUnsafeMutablePointer<FlutterError?>
  ) -> [FGMPlatformCluster]? {
    return controller?.clusterManagersController.clusters(
      withIdentifier: clusterManagerId, error: error)
  }

  func isCompassEnabledWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>)
    -> NSNumber?
  {
    guard let mapView = controller?.mapView else {
      return nil
    }
    return NSNumber(value: mapView.settings.compassButton)
  }

  func isMyLocationButtonEnabledWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>)
    -> NSNumber?
  {
    guard let mapView = controller?.mapView else {
      return nil
    }
    return NSNumber(value: mapView.settings.myLocationButton)
  }

  func isTrafficEnabledWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>)
    -> NSNumber?
  {
    guard let mapView = controller?.mapView else {
      return nil
    }
    return NSNumber(value: mapView.isTrafficEnabled)
  }

  func zoomRange(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> FGMPlatformZoomRange?
  {
    guard let mapView = controller?.mapView else {
      return nil
    }
    return FGMPlatformZoomRange.make(
      withMin: NSNumber(value: mapView.minZoom),
      max: NSNumber(value: mapView.maxZoom)
    )
  }

  func groundOverlay(
    withIdentifier groundOverlayId: String, error: AutoreleasingUnsafeMutablePointer<FlutterError?>
  ) -> FGMPlatformGroundOverlay? {
    return controller?.groundOverlaysController.groundOverlay(withIdentifier: groundOverlayId)
  }

  func cameraPosition(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>)
    -> FGMPlatformCameraPosition?
  {
    guard let mapView = controller?.mapView else {
      return nil
    }
    return FGMGetPigeonCameraPositionForPosition(mapView.camera)
  }
}
