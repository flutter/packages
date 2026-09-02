// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import GoogleMaps
import UIKit

/// Defines marker controllable by Flutter.
class MarkerController: NSObject {
  let marker: GMSMarker
  private weak var mapView: GMSMapView?
  private(set) var consumeTapEvents: Bool = false
  var clusterManagerIdentifier: String?
  let markerIdentifier: String

  init(marker: GMSMarker, markerIdentifier: String, mapView: GMSMapView) {
    self.marker = marker
    self.markerIdentifier = markerIdentifier
    self.mapView = mapView
    super.init()
  }

  func showInfoWindow() {
    mapView?.selectedMarker = marker
  }

  func hideInfoWindow() {
    if mapView?.selectedMarker == marker {
      mapView?.selectedMarker = nil
    }
  }

  func isInfoWindowShown() -> Bool {
    return mapView?.selectedMarker == marker
  }

  func removeMarker() {
    marker.map = nil
  }

  /// Updates the controller's marker with the properties from a PlatformMarker.
  ///
  /// Setting the marker to visible will set its map to the controller's mapView.
  func update(
    from platformMarker: PlatformMarker,
    assetProvider: AssetProvider,
    screenScale: CGFloat
  ) {
    clusterManagerIdentifier = platformMarker.clusterManagerId
    consumeTapEvents = platformMarker.consumeTapEvents

    setIdentifiersToMarkerUserData(
      markerIdentifier: markerIdentifier,
      clusterManagerIdentifier: clusterManagerIdentifier,
      marker: marker
    )

    let useOpacityForVisibility = clusterManagerIdentifier != nil
    MarkerController.update(
      marker,
      from: platformMarker,
      mapView: mapView,
      assetProvider: assetProvider,
      screenScale: screenScale,
      usingOpacityForVisibility: useOpacityForVisibility
    )
  }

  /// Updates the given GMSMarker with the properties from a PlatformMarker.
  ///
  /// Setting the marker to visible will set its map to the given mapView.
  static func update(
    _ marker: GMSMarker,
    from platformMarker: PlatformMarker,
    mapView: GMSMapView?,
    assetProvider: AssetProvider,
    screenScale: CGFloat,
    usingOpacityForVisibility useOpacityForVisibility: Bool
  ) {
    marker.groundAnchor = platformMarker.anchor.toCGPoint()
    marker.isDraggable = platformMarker.draggable
    marker.icon = platformMarker.icon.createIcon(
      assetProvider: assetProvider,
      screenScale: screenScale
    )
    marker.isFlat = platformMarker.flat
    marker.position = platformMarker.position.toCLLocationCoordinate2D()
    marker.rotation = platformMarker.rotation
    marker.zIndex = Int32(platformMarker.zIndex)
    let infoWindow = platformMarker.infoWindow
    marker.infoWindowAnchor = infoWindow.anchor.toCGPoint()
    if let title = infoWindow.title {
      marker.title = title
      marker.snippet = infoWindow.snippet
    }

    if let advancedMarker = marker as? GMSAdvancedMarker,
      let collisionBehaviorValue = platformMarker.collisionBehavior
    {
      advancedMarker.collisionBehavior = collisionBehaviorValue.gmsCollisionBehavior
    }

    // This must be done last, to avoid visual flickers of default property values.
    if useOpacityForVisibility {
      marker.opacity = platformMarker.visible ? Float(platformMarker.alpha) : 0.0
    } else {
      marker.opacity = Float(platformMarker.alpha)
      marker.map = platformMarker.visible ? mapView : nil
    }
  }
}

/// Controller of multiple markers on the map.
class MarkersController: NSObject {
  private(set) var markerIdentifierToController: [String: MarkerController] = [:]
  private weak var eventDelegate: MapEventDelegate?
  private weak var clusterManagersController: ClusterManagersController?
  private let assetProvider: AssetProvider
  private weak var mapView: GMSMapView?
  private let markerType: PlatformMarkerType

  init(
    mapView: GMSMapView,
    eventDelegate: MapEventDelegate,
    clusterManagersController: ClusterManagersController?,
    assetProvider: AssetProvider,
    markerType: PlatformMarkerType
  ) {
    self.mapView = mapView
    self.eventDelegate = eventDelegate
    self.clusterManagersController = clusterManagersController
    self.assetProvider = assetProvider
    self.markerType = markerType
    super.init()
  }

  func add(_ markersToAdd: [PlatformMarker]) {
    for marker in markersToAdd {
      addMarker(marker)
    }
  }

  private func addMarker(_ markerToAdd: PlatformMarker) {
    guard let mapView = mapView else { return }
    let position = markerToAdd.position.toCLLocationCoordinate2D()
    let markerIdentifier = markerToAdd.markerId
    let clusterManagerIdentifier = markerToAdd.clusterManagerId

    let marker =
      (markerType == .advancedMarker)
      ? GMSAdvancedMarker(position: position)
      : GMSMarker(position: position)

    let controller = MarkerController(
      marker: marker,
      markerIdentifier: markerIdentifier,
      mapView: mapView
    )
    controller.update(
      from: markerToAdd,
      assetProvider: assetProvider,
      screenScale: getScreenScale()
    )

    if let clusterManagerIdentifier = clusterManagerIdentifier {
      let clusterManager = clusterManagersController?.clusterManager(
        withIdentifier: clusterManagerIdentifier)
      clusterManager?.add(marker)
    }
    markerIdentifierToController[markerIdentifier] = controller
  }

  func change(_ markersToChange: [PlatformMarker]) {
    for marker in markersToChange {
      changeMarker(marker)
    }
  }

  private func changeMarker(_ markerToChange: PlatformMarker) {
    let markerIdentifier = markerToChange.markerId
    guard let controller = markerIdentifierToController[markerIdentifier] else { return }

    let clusterManagerIdentifier = markerToChange.clusterManagerId
    let previousClusterManagerIdentifier = controller.clusterManagerIdentifier
    controller.update(
      from: markerToChange,
      assetProvider: assetProvider,
      screenScale: getScreenScale()
    )

    if let previousId = previousClusterManagerIdentifier, previousId != clusterManagerIdentifier {
      let clusterManager = clusterManagersController?.clusterManager(withIdentifier: previousId)
      clusterManager?.remove(controller.marker)
    }
    if let newId = clusterManagerIdentifier, newId != previousClusterManagerIdentifier {
      let clusterManager = clusterManagersController?.clusterManager(withIdentifier: newId)
      clusterManager?.add(controller.marker)
    }
  }

  func removeMarkers(withIdentifiers identifiers: [String]) {
    for identifier in identifiers {
      removeMarker(identifier)
    }
  }

  private func removeMarker(_ identifier: String) {
    guard let controller = markerIdentifierToController[identifier] else { return }
    if let clusterManagerIdentifier = controller.clusterManagerIdentifier {
      let clusterManager = clusterManagersController?.clusterManager(
        withIdentifier: clusterManagerIdentifier)
      clusterManager?.remove(controller.marker)
    } else {
      controller.removeMarker()
    }
    markerIdentifierToController.removeValue(forKey: identifier)
  }

  func didTapMarker(withIdentifier identifier: String) -> Bool {
    guard let controller = markerIdentifierToController[identifier] else { return false }
    eventDelegate?.didTapMarker(withIdentifier: identifier)
    return controller.consumeTapEvents
  }

  func didStartDraggingMarker(withIdentifier identifier: String, location: CLLocationCoordinate2D) {
    guard markerIdentifierToController[identifier] != nil else { return }
    eventDelegate?.didStartDragForMarker(
      withIdentifier: identifier,
      at: PlatformLatLng.make(from: location)
    )
  }

  func didDragMarker(withIdentifier identifier: String, location: CLLocationCoordinate2D) {
    guard markerIdentifierToController[identifier] != nil else { return }
    eventDelegate?.didDragMarker(
      withIdentifier: identifier,
      at: PlatformLatLng.make(from: location)
    )
  }

  func didEndDraggingMarker(withIdentifier identifier: String, location: CLLocationCoordinate2D) {
    guard markerIdentifierToController[identifier] != nil else { return }
    eventDelegate?.didEndDragForMarker(
      withIdentifier: identifier,
      at: PlatformLatLng.make(from: location)
    )
  }

  func didTapInfoWindowOfMarker(withIdentifier identifier: String) {
    if markerIdentifierToController[identifier] != nil {
      eventDelegate?.didTapInfoWindowOfMarker(withIdentifier: identifier)
    }
  }

  func showMarkerInfoWindow(withIdentifier identifier: String) throws {
    guard let controller = markerIdentifierToController[identifier] else {
      throw PigeonError(
        code: "Invalid markerId",
        message: "showInfoWindow called with invalid markerId",
        details: nil
      )
    }
    controller.showInfoWindow()
  }

  func hideMarkerInfoWindow(withIdentifier identifier: String) throws {
    guard let controller = markerIdentifierToController[identifier] else {
      throw PigeonError(
        code: "Invalid markerId",
        message: "hideInfoWindow called with invalid markerId",
        details: nil
      )
    }
    controller.hideInfoWindow()
  }

  func isInfoWindowShownForMarker(withIdentifier identifier: String) throws -> Bool {
    guard let controller = markerIdentifierToController[identifier] else {
      throw PigeonError(
        code: "Invalid markerId",
        message: "isInfoWindowShown called with invalid markerId",
        details: nil
      )
    }
    return controller.isInfoWindowShown()
  }

  func getScreenScale() -> CGFloat {
    // TODO(jokerttu): This method is called on marker creation, which, for initial markers, is done
    // before the view is added to the view hierarchy. This means that the traitCollection values may
    // not be matching the right display where the map is finally shown. The solution should be
    // revisited after the proper way to fetch the display scale is resolved for platform views. This
    // should be done under the context of the following issue:
    // https://github.com/flutter/flutter/issues/125496.
    return mapView?.traitCollection.displayScale ?? 1.0
  }
}
