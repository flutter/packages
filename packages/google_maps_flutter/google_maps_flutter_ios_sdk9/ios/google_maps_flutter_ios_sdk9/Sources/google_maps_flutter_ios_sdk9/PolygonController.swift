// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import GoogleMaps
import google_maps_flutter_ios_sdk9_objc

private func pathHoles(from locationHoles: [[CLLocation]]) -> [GMSMutablePath] {
  return locationHoles.map { FGMGetPathFromPoints($0) }
}

/// Defines polygon controllable by Flutter.
class PolygonController: NSObject {
  private(set) var polygon: GMSPolygon
  private weak var mapView: GMSMapView?

  init(path: GMSMutablePath, identifier: String, mapView: GMSMapView) {
    self.polygon = GMSPolygon(path: path)
    self.mapView = mapView
    self.polygon.userData = [identifier]
    super.init()
  }

  func removePolygon() {
    polygon.map = nil
  }

  func update(from platformPolygon: FGMPlatformPolygon) {
    if let mapView = mapView {
      PolygonController.update(polygon, from: platformPolygon, with: mapView)
    }
  }

  /// Updates the underlying GMSPolygon with the properties from the given FGMPlatformPolygon.
  ///
  /// Setting the polygon to visible will set its map to the given mapView.
  static func update(
    _ polygon: GMSPolygon, from platformPolygon: FGMPlatformPolygon, with mapView: GMSMapView
  ) {
    polygon.isTappable = platformPolygon.consumesTapEvents
    polygon.zIndex = Int32(platformPolygon.zIndex)
    polygon.path = FGMGetPathFromPoints(FGMGetPointsForPigeonLatLngs(platformPolygon.points))
    polygon.holes = pathHoles(from: FGMGetHolesForPigeonLatLngArrays(platformPolygon.holes))
    polygon.fillColor = FGMGetColorForPigeonColor(platformPolygon.fillColor)
    polygon.strokeColor = FGMGetColorForPigeonColor(platformPolygon.strokeColor)
    polygon.strokeWidth = CGFloat(platformPolygon.strokeWidth)

    // This must be done last, to avoid visual flickers of default property values.
    polygon.map = platformPolygon.visible ? mapView : nil
  }
}

class PolygonsController: NSObject {
  private var polygonIdentifierToController: [String: PolygonController]
  private weak var eventDelegate: FGMMapEventDelegate?
  private weak var mapView: GMSMapView?

  init(mapView: GMSMapView, eventDelegate: FGMMapEventDelegate) {
    self.mapView = mapView
    self.eventDelegate = eventDelegate
    self.polygonIdentifierToController = [:]
    super.init()
  }

  func add(_ polygons: [FGMPlatformPolygon]) {
    guard let mapView = mapView else { return }
    for polygon in polygons {
      let path = FGMGetPathFromPoints(FGMGetPointsForPigeonLatLngs(polygon.points))
      let identifier = polygon.polygonId
      let controller = PolygonController(path: path, identifier: identifier, mapView: mapView)
      controller.update(from: polygon)
      polygonIdentifierToController[identifier] = controller
    }
  }

  func change(_ polygons: [FGMPlatformPolygon]) {
    for polygon in polygons {
      let identifier = polygon.polygonId
      if let controller = polygonIdentifierToController[identifier] {
        controller.update(from: polygon)
      }
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
