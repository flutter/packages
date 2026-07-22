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

  func didMoveCameraToPosition(_ cameraPosition: FGMPlatformCameraPosition) {
    callbackHandler.didMoveCameraToPosition(cameraPosition) { _ in }
  }

  func didIdleCamera() {
    callbackHandler.didIdleCamera { _ in }
  }

  func didTapAtPosition(_ position: FGMPlatformLatLng) {
    callbackHandler.didTapAtPosition(position) { _ in }
  }

  func didLongPressAtPosition(_ position: FGMPlatformLatLng) {
    callbackHandler.didLongPressAtPosition(position) { _ in }
  }

  func didTapMarkerWithIdentifier(_ markerId: String) {
    callbackHandler.didTapMarkerWithIdentifier(markerId) { _ in }
  }

  func didStartDragForMarkerWithIdentifier(_ markerId: String, atPosition position: FGMPlatformLatLng) {
    callbackHandler.didStartDragForMarkerWithIdentifier(markerId, atPosition: position) { _ in }
  }

  func didDragMarkerWithIdentifier(_ markerId: String, atPosition position: FGMPlatformLatLng) {
    callbackHandler.didDragMarkerWithIdentifier(markerId, atPosition: position) { _ in }
  }

  func didEndDragForMarkerWithIdentifier(_ markerId: String, atPosition position: FGMPlatformLatLng) {
    callbackHandler.didEndDragForMarkerWithIdentifier(markerId, atPosition: position) { _ in }
  }

  func didTapInfoWindowOfMarkerWithIdentifier(_ markerId: String) {
    callbackHandler.didTapInfoWindowOfMarkerWithIdentifier(markerId) { _ in }
  }

  func didTapCircleWithIdentifier(_ circleId: String) {
    callbackHandler.didTapCircleWithIdentifier(circleId) { _ in }
  }

  func didTapCluster(_ cluster: FGMPlatformCluster) {
    callbackHandler.didTapCluster(cluster) { _ in }
  }

  func didTapPolygonWithIdentifier(_ polygonId: String) {
    callbackHandler.didTapPolygonWithIdentifier(polygonId) { _ in }
  }

  func didTapPolylineWithIdentifier(_ polylineId: String) {
    callbackHandler.didTapPolylineWithIdentifier(polylineId) { _ in }
  }

  func didTapGroundOverlayWithIdentifier(_ groundOverlayId: String) {
    callbackHandler.didTapGroundOverlayWithIdentifier(groundOverlayId) { _ in }
  }
}

public class GoogleMapController: NSObject, GMSMapViewDelegate, FlutterPlatformView, FGMTileProviderDelegate {
  /// The Google Maps SDK map view managed by this controller.
  private(set) var mapView: GMSMapView
  /// The Pigeon callback API implementation, used to send events to the Dart side.
  var dartCallbackHandler: FGMMapsCallbackApi?
  /// The map SDK event handler, which routes events to the Dart callback handler.
  var mapEventHandler: DefaultMapEventHandler?
  // The main Pigeon API implementation, separate to avoid lifetime extension.
  var callHandler: MapCallHandler!
  // The inspector API implementation, separate to avoid lifetime extension.
  var inspector: MapInspector!
  /// Whether to send notifications about camera position changes to Dart.
  var trackCameraPosition = false

  /// Sub-controllers for managing individual map features.
  var clusterManagersController: FGMClusterManagersController?
  var markersController: FGMMarkersController?
  var polygonsController: FGMPolygonsController?
  var polylinesController: FGMPolylinesController?
  var circlesController: FGMCirclesController?
  var heatmapsController: FGMHeatmapsController?
  var tileOverlaysController: FGMTileOverlaysController?
  var groundOverlaysController: FGMGroundOverlaysController?

  // The resulting error message, if any, from the last attempt to set the map style.
  // This is used to provide access to errors after the fact, since the map style is generally set at
  // creation time and there's no mechanism to return non-fatal error details during platform view
  // initialization.
  var styleError: String?

  public init(
    frame: CGRect,
    viewIdentifier viewId: Int64,
    creationParameters: FGMPlatformMapViewCreationParams,
    registrar: FlutterPluginRegistrar
  ) {
    let camera = FGMGetCameraPositionForPigeonCameraPosition(creationParameters.initialCameraPosition)

    let options = GMSMapViewOptions()
    options.frame = frame
    options.camera = camera
    if let mapId = creationParameters.mapConfiguration.mapId, !mapId.isEmpty {
      options.mapID = GMSMapID(identifier: mapId)
    }

    let mapView = GMSMapView(options: options)
    self.mapView = mapView

    super.init()

    setup(
      viewId: viewId,
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

    super.init()

    setup(
      viewId: viewId,
      creationParameters: creationParameters,
      assetProvider: assetProvider,
      binaryMessenger: binaryMessenger
    )
  }

  private func setup(
    viewId: Int64,
    creationParameters: FGMPlatformMapViewCreationParams,
    assetProvider: FGMAssetProvider,
    binaryMessenger: FlutterBinaryMessenger
  ) {
    mapView.accessibilityElementsHidden = false
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

    if let initialClusterManagers = creationParameters.initialClusterManagers {
      clusterManagersController.addClusterManagers(initialClusterManagers)
    }
    if let initialMarkers = creationParameters.initialMarkers {
      markersController?.addMarkers(initialMarkers)
    }
    if let initialPolygons = creationParameters.initialPolygons {
      polygonsController?.addPolygons(initialPolygons)
    }
    if let initialPolylines = creationParameters.initialPolylines {
      polylinesController?.addPolylines(initialPolylines)
    }
    if let initialCircles = creationParameters.initialCircles {
      circlesController?.addCircles(initialCircles)
    }
    if let initialHeatmaps = creationParameters.initialHeatmaps {
      heatmapsController?.addHeatmaps(initialHeatmaps)
    }
    if let initialTileOverlays = creationParameters.initialTileOverlays {
      tileOverlaysController?.addTileOverlays(initialTileOverlays)
    }
    if let initialGroundOverlays = creationParameters.initialGroundOverlays {
      groundOverlaysController?.addGroundOverlays(initialGroundOverlays)
    }

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
  }

  deinit {
    if let callHandler = callHandler {
      SetUpFGMMapsApiWithSuffix(callHandler.messenger, nil, callHandler.pigeonSuffix)
    }
    if let inspector = inspector {
      SetUpFGMMapsInspectorApiWithSuffix(inspector.messenger, nil, inspector.pigeonSuffix)
    }
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

  func setPaddingTop(_ top: Float, left: Float, bottom: Float, right: Float) {
    mapView.padding = UIEdgeInsets(
      top: CGFloat(top),
      left: CGFloat(left),
      bottom: CGFloat(bottom),
      right: CGFloat(right)
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
  func setMapStyle(_ mapStyle: String?) -> String? {
    var errorString: String? = nil
    if let mapStyle = mapStyle, !mapStyle.isEmpty {
      do {
        let style = try GMSMapStyle(jsonString: mapStyle)
        mapView.mapStyle = style
      } catch {
        errorString = error.localizedDescription
      }
    } else {
      mapView.mapStyle = nil
    }
    self.styleError = errorString
    return errorString
  }

  // MARK: - GMSMapViewDelegate methods

  public func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
    mapEventHandler?.didStartCameraMove()
  }

  public func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
    if trackCameraPosition {
      if let pigeonPos = FGMGetPigeonCameraPositionForPosition(position) {
        mapEventHandler?.didMoveCameraToPosition(pigeonPos)
      }
    }
  }

  public func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
    mapEventHandler?.didIdleCamera()
  }

  public func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
    if let cluster = marker.userData as? GMUStaticCluster {
      clusterManagersController?.didTapCluster(cluster)
      return false
    }
    if let markerId = FGMGetMarkerIdentifierFromMarker(marker) {
      return markersController?.didTapMarkerWithIdentifier(markerId) ?? false
    }
    return false
  }

  public func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker) {
    if let markerId = FGMGetMarkerIdentifierFromMarker(marker) {
      markersController?.didEndDraggingMarkerWithIdentifier(markerId, location: marker.position)
    }
  }

  public func mapView(_ mapView: GMSMapView, didBeginDragging marker: GMSMarker) {
    if let markerId = FGMGetMarkerIdentifierFromMarker(marker) {
      markersController?.didStartDraggingMarkerWithIdentifier(markerId, location: marker.position)
    }
  }

  public func mapView(_ mapView: GMSMapView, didDrag marker: GMSMarker) {
    if let markerId = FGMGetMarkerIdentifierFromMarker(marker) {
      markersController?.didDragMarkerWithIdentifier(markerId, location: marker.position)
    }
  }

  public func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
    if let markerId = FGMGetMarkerIdentifierFromMarker(marker) {
      markersController?.didTapInfoWindowOfMarkerWithIdentifier(markerId)
    }
  }

  public func mapView(_ mapView: GMSMapView, didTap overlay: GMSOverlay) {
    guard let userDataArray = overlay.userData as? [Any],
      let overlayId = userDataArray.first as? String
    else {
      return
    }
    if polylinesController?.hasPolylineWithIdentifier(overlayId) == true {
      polylinesController?.didTapPolylineWithIdentifier(overlayId)
    } else if polygonsController?.hasPolygonWithIdentifier(overlayId) == true {
      polygonsController?.didTapPolygonWithIdentifier(overlayId)
    } else if circlesController?.hasCircleWithIdentifier(overlayId) == true {
      circlesController?.didTapCircleWithIdentifier(overlayId)
    } else if groundOverlaysController?.hasGroundOverlaysWithIdentifier(overlayId) == true {
      groundOverlaysController?.didTapGroundOverlayWithIdentifier(overlayId)
    }
  }

  public func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
    if let pigeonLatLng = FGMGetPigeonLatLngForCoordinate(coordinate) {
      mapEventHandler?.didTapAtPosition(pigeonLatLng)
    }
  }

  public func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
    if let pigeonLatLng = FGMGetPigeonLatLngForCoordinate(coordinate) {
      mapEventHandler?.didLongPressAtPosition(pigeonLatLng)
    }
  }

  func interpretMapConfiguration(_ config: FGMPlatformMapConfiguration) {
    if let cameraTargetBounds = config.cameraTargetBounds {
      setCameraTargetBounds(
        cameraTargetBounds.bounds != nil
          ? FGMGetCoordinateBoundsForPigeonLatLngBounds(cameraTargetBounds.bounds!)
          : nil
      )
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
      let minZoom = zoomData.min != nil ? zoomData.min!.floatValue : kGMSMinZoomLevel
      let maxZoom = zoomData.max != nil ? zoomData.max!.floatValue : kGMSMaxZoomLevel
      setMinZoom(minZoom, maxZoom: maxZoom)
    }
    if let padding = config.padding {
      setPaddingTop(
        Float(padding.top),
        left: Float(padding.left),
        bottom: Float(padding.bottom),
        right: Float(padding.right)
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
    dartCallbackHandler?.tile(
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

  func waitForMap() throws {
    // No-op; this call just ensures synchronization with the platform thread.
  }

  func updateCirclesByAdding(
    _ toAdd: [FGMPlatformCircle],
    changing toChange: [FGMPlatformCircle],
    removing idsToRemove: [String]
  ) throws {
    controller?.circlesController?.addCircles(toAdd)
    controller?.circlesController?.changeCircles(toChange)
    controller?.circlesController?.removeCirclesWithIdentifiers(idsToRemove)
  }

  func updateHeatmapsByAdding(
    _ toAdd: [FGMPlatformHeatmap],
    changing toChange: [FGMPlatformHeatmap],
    removing idsToRemove: [String]
  ) throws {
    controller?.heatmapsController?.addHeatmaps(toAdd)
    controller?.heatmapsController?.changeHeatmaps(toChange)
    controller?.heatmapsController?.removeHeatmapsWithIdentifiers(idsToRemove)
  }

  func updateWithMapConfiguration(_ configuration: FGMPlatformMapConfiguration) throws {
    controller?.interpretMapConfiguration(configuration)
  }

  func updateMarkersByAdding(
    _ toAdd: [FGMPlatformMarker],
    changing toChange: [FGMPlatformMarker],
    removing idsToRemove: [String]
  ) throws {
    controller?.markersController?.addMarkers(toAdd)
    controller?.markersController?.changeMarkers(toChange)
    controller?.markersController?.removeMarkersWithIdentifiers(idsToRemove)
    controller?.clusterManagersController?.invokeClusteringForEachClusterManager()
  }

  func updateClusterManagersByAdding(
    _ toAdd: [FGMPlatformClusterManager],
    removing idsToRemove: [String]
  ) throws {
    controller?.clusterManagersController?.addClusterManagers(toAdd)
    controller?.clusterManagersController?.removeClusterManagersWithIdentifiers(idsToRemove)
  }

  func updatePolygonsByAdding(
    _ toAdd: [FGMPlatformPolygon],
    changing toChange: [FGMPlatformPolygon],
    removing idsToRemove: [String]
  ) throws {
    controller?.polygonsController?.addPolygons(toAdd)
    controller?.polygonsController?.changePolygons(toChange)
    controller?.polygonsController?.removePolygonWithIdentifiers(idsToRemove)
  }

  func updatePolylinesByAdding(
    _ toAdd: [FGMPlatformPolyline],
    changing toChange: [FGMPlatformPolyline],
    removing idsToRemove: [String]
  ) throws {
    controller?.polylinesController?.addPolylines(toAdd)
    controller?.polylinesController?.changePolylines(toChange)
    controller?.polylinesController?.removePolylineWithIdentifiers(idsToRemove)
  }

  func updateTileOverlaysByAdding(
    _ toAdd: [FGMPlatformTileOverlay],
    changing toChange: [FGMPlatformTileOverlay],
    removing idsToRemove: [String]
  ) throws {
    controller?.tileOverlaysController?.addTileOverlays(toAdd)
    controller?.tileOverlaysController?.changeTileOverlays(toChange)
    controller?.tileOverlaysController?.removeTileOverlayWithIdentifiers(idsToRemove)
  }

  func updateGroundOverlaysByAdding(
    _ toAdd: [FGMPlatformGroundOverlay],
    changing toChange: [FGMPlatformGroundOverlay],
    removing idsToRemove: [String]
  ) throws {
    controller?.groundOverlaysController?.addGroundOverlays(toAdd)
    controller?.groundOverlaysController?.changeGroundOverlays(toChange)
    controller?.groundOverlaysController?.removeGroundOverlaysWithIdentifiers(idsToRemove)
  }

  func latLng(forScreenCoordinate screenCoordinate: FGMPlatformPoint) throws -> FGMPlatformLatLng? {
    guard let mapView = controller?.mapView else {
      throw FlutterError(
        code: "GoogleMap uninitialized",
        message: "getLatLng called prior to map initialization",
        details: nil
      )
    }
    let point = FGMGetCGPointForPigeonPoint(screenCoordinate)
    let latlng = mapView.projection.coordinate(for: point)
    return FGMGetPigeonLatLngForCoordinate(latlng)
  }

  func screenCoordinates(forLatLng latLng: FGMPlatformLatLng) throws -> FGMPlatformPoint? {
    guard let mapView = controller?.mapView else {
      throw FlutterError(
        code: "GoogleMap uninitialized",
        message: "getScreenCoordinate called prior to map initialization",
        details: nil
      )
    }
    let location = FGMGetCoordinateForPigeonLatLng(latLng)
    let point = mapView.projection.point(for: location)
    return FGMGetPigeonPointForCGPoint(point)
  }

  func visibleMapRegion() throws -> FGMPlatformLatLngBounds? {
    guard let mapView = controller?.mapView else {
      throw FlutterError(
        code: "GoogleMap uninitialized",
        message: "getVisibleRegion called prior to map initialization",
        details: nil
      )
    }
    let visibleRegion = mapView.projection.visibleRegion()
    let bounds = GMSCoordinateBounds(region: visibleRegion)
    return FGMGetPigeonLatLngBoundsForCoordinateBounds(bounds)
  }

  func moveCameraWithUpdate(_ cameraUpdate: FGMPlatformCameraUpdate) throws {
    guard let update = FGMGetCameraUpdateForPigeonCameraUpdate(cameraUpdate) else {
      throw FlutterError(
        code: "Invalid update",
        message: "Unrecognized camera update",
        details: nil
      )
    }
    controller?.mapView.moveCamera(update)
  }

  func animateCameraWithUpdate(
    _ cameraUpdate: FGMPlatformCameraUpdate,
    duration durationMilliseconds: NSNumber?
  ) throws {
    guard let update = FGMGetCameraUpdateForPigeonCameraUpdate(cameraUpdate) else {
      throw FlutterError(
        code: "Invalid update",
        message: "Unrecognized camera update",
        details: nil
      )
    }
    let transaction = durationMilliseconds != nil ? transactionWrapper : nil
    transaction?.begin()
    if let duration = durationMilliseconds {
      transaction?.setAnimationDuration(duration.doubleValue / 1000.0)
    }
    controller?.mapView.animate(with: update)
    transaction?.commit()
  }

  func currentZoomLevel() throws -> NSNumber? {
    guard let mapView = controller?.mapView else {
      return nil
    }
    return NSNumber(value: mapView.camera.zoom)
  }

  func showInfoWindowForMarker(withIdentifier markerId: String) throws {
    try controller?.markersController?.showMarkerInfoWindowWithIdentifier(markerId)
  }

  func hideInfoWindowForMarker(withIdentifier markerId: String) throws {
    try controller?.markersController?.hideMarkerInfoWindowWithIdentifier(markerId)
  }

  func isShowingInfoWindowForMarker(withIdentifier markerId: String) throws -> NSNumber? {
    return try controller?.markersController?.isInfoWindowShownForMarkerWithIdentifier(markerId)
  }

  func setStyle(_ style: String) throws -> String? {
    return controller?.setMapStyle(style)
  }

  func lastStyleError() throws -> String? {
    return controller?.styleError
  }

  func clearTileCacheForOverlay(withIdentifier tileOverlayId: String) throws {
    controller?.tileOverlaysController?.clearTileCacheWithIdentifier(tileOverlayId)
  }

  func takeSnapshot() throws -> FlutterStandardTypedData? {
    guard let mapView = controller?.mapView else {
      throw FlutterError(
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

  func isAdvancedMarkersAvailable() throws -> NSNumber? {
    guard let mapView = controller?.mapView else {
      return false
    }
    let advancedMarkerFlag = mapView.mapCapabilities.rawValue & GMSMapCapabilityFlags.advancedMarkers.rawValue
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

  func areBuildingsEnabled() throws -> NSNumber? {
    guard let mapView = controller?.mapView else {
      return nil
    }
    return NSNumber(value: mapView.isBuildingsEnabled)
  }

  func areRotateGesturesEnabled() throws -> NSNumber? {
    guard let mapView = controller?.mapView else {
      return nil
    }
    return NSNumber(value: mapView.settings.rotateGestures)
  }

  func areScrollGesturesEnabled() throws -> NSNumber? {
    guard let mapView = controller?.mapView else {
      return nil
    }
    return NSNumber(value: mapView.settings.scrollGestures)
  }

  func areTiltGesturesEnabled() throws -> NSNumber? {
    guard let mapView = controller?.mapView else {
      return nil
    }
    return NSNumber(value: mapView.settings.tiltGestures)
  }

  func areZoomGesturesEnabled() throws -> NSNumber? {
    guard let mapView = controller?.mapView else {
      return nil
    }
    return NSNumber(value: mapView.settings.zoomGestures)
  }

  func tileOverlay(withIdentifier tileOverlayId: String) throws -> FGMPlatformTileLayer? {
    guard let controller = controller,
      let layer = controller.tileOverlaysController?.tileOverlay(withIdentifier: tileOverlayId)?.layer
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

  func heatmap(withIdentifier heatmapId: String) throws -> FGMPlatformHeatmap? {
    return controller?.heatmapsController?.heatmap(withIdentifier: heatmapId)
  }

  func clusters(withIdentifier clusterManagerId: String) throws -> [FGMPlatformCluster]? {
    return try controller?.clusterManagersController?.clustersWithIdentifier(clusterManagerId)
  }

  func isCompassEnabled() throws -> NSNumber? {
    guard let mapView = controller?.mapView else {
      return nil
    }
    return NSNumber(value: mapView.settings.compassButton)
  }

  func isMyLocationButtonEnabled() throws -> NSNumber? {
    guard let mapView = controller?.mapView else {
      return nil
    }
    return NSNumber(value: mapView.settings.myLocationButton)
  }

  func isTrafficEnabled() throws -> NSNumber? {
    guard let mapView = controller?.mapView else {
      return nil
    }
    return NSNumber(value: mapView.isTrafficEnabled)
  }

  func zoomRange() throws -> FGMPlatformZoomRange? {
    guard let mapView = controller?.mapView else {
      return nil
    }
    return FGMPlatformZoomRange.make(
      withMin: NSNumber(value: mapView.minZoom),
      max: NSNumber(value: mapView.maxZoom)
    )
  }

  func groundOverlay(withIdentifier groundOverlayId: String) throws -> FGMPlatformGroundOverlay? {
    return controller?.groundOverlaysController?.groundOverlay(withIdentifier: groundOverlayId)
  }

  func cameraPosition() throws -> FGMPlatformCameraPosition? {
    guard let mapView = controller?.mapView else {
      return nil
    }
    return FGMGetPigeonCameraPositionForPosition(mapView.camera)
  }
}
