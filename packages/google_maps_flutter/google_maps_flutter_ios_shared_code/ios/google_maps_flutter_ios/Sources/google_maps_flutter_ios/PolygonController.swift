// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import GoogleMaps

#if canImport(google_maps_flutter_ios_objc)
  import google_maps_flutter_ios_objc
#endif

/// Defines polygon controllable by Flutter.
class PolygonController: NSObject {
  let polygon: GMSPolygon
  private weak var mapView: GMSMapView?

  init(identifier: String, mapView: GMSMapView) {
    self.polygon = GMSPolygon()
    self.mapView = mapView
    self.polygon.userData = [identifier]
    super.init()
  }

  func removePolygon() {
    polygon.map = nil
  }

  /// Updates the controller's polygon with the properties from a FGMPlatformPolygon.
  ///
  /// Setting the polygon to visible will set its map to the controller's mapView.
  func update(from platformPolygon: FGMPlatformPolygon) {
    if let mapView = mapView {
      PolygonController.update(polygon, from: platformPolygon, with: mapView)
    }
  }

  /// Updates the given GMSPolygon with the properties from a FGMPlatformPolygon.
  ///
  /// Setting the polygon to visible will set its map to the given mapView.
  static func update(
    _ polygon: GMSPolygon, from platformPolygon: FGMPlatformPolygon, with mapView: GMSMapView
  ) {
    polygon.isTappable = platformPolygon.consumesTapEvents
    polygon.zIndex = Int32(platformPolygon.zIndex)
    polygon.path = FGMGetPathFromPoints(FGMGetPointsForPigeonLatLngs(platformPolygon.points))
    polygon.holes = FGMGetHolesForPigeonLatLngArrays(platformPolygon.holes).map {
      FGMGetPathFromPoints($0)
    }
    polygon.fillColor = FGMGetColorForPigeonColor(platformPolygon.fillColor)
    polygon.strokeColor = FGMGetColorForPigeonColor(platformPolygon.strokeColor)
    polygon.strokeWidth = CGFloat(platformPolygon.strokeWidth)

    // This must be done last, to avoid visual flickers of default property values.
    polygon.map = platformPolygon.visible ? mapView : nil
  }
}

class PolygonsController: NSObject {
  private var polygonIdentifierToController: [String: PolygonController] = [:]
  private weak var eventDelegate: FGMMapEventDelegate?
  private weak var mapView: GMSMapView?

  init(mapView: GMSMapView, eventDelegate: FGMMapEventDelegate) {
    self.mapView = mapView
    self.eventDelegate = eventDelegate
    super.init()
  }

  func add(_ polygons: [FGMPlatformPolygon]) {
    guard let mapView = mapView else { return }
    for polygon in polygons {
      let identifier = polygon.polygonId
      let controller = PolygonController(identifier: identifier, mapView: mapView)
      // TODO(stuarmorgan): Consider updating the flow here to do the update from within
      // the initialiazer, as in CircleController.
      controller.update(from: polygon)
      polygonIdentifierToController[identifier] = controller
    }
  }

  func change(_ polygons: [FGMPlatformPolygon]) {
    for polygon in polygons {
      let identifier = polygon.polygonId
      polygonIdentifierToController[identifier]?.update(from: polygon)
    }
  }

  func removePolygon(withIdentifiers identifiers: [String]) {
    for identifier in identifiers {
      if let controller = polygonIdentifierToController[identifier] {
        controller.removePolygon()
        polygonIdentifierToController.removeValue(forKey: identifier)
      }
    }
  }

  func didTapPolygon(withIdentifier identifier: String) {
    if hasPolygon(withIdentifier: identifier) {
      eventDelegate?.didTapPolygon(withIdentifier: identifier)
    }
  }

  func hasPolygon(withIdentifier identifier: String) -> Bool {
    return polygonIdentifierToController[identifier] != nil
  }
}
