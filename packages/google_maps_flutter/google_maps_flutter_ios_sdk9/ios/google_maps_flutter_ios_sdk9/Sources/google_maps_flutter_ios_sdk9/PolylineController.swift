// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import GoogleMaps
import google_maps_flutter_ios_sdk9_objc

/// Defines polyline controllable by Flutter.
class PolylineController: NSObject {
  private(set) var polyline: GMSPolyline
  private weak var mapView: GMSMapView?

  init(path: GMSMutablePath, identifier: String, mapView: GMSMapView) {
    self.polyline = GMSPolyline(path: path)
    self.mapView = mapView
    self.polyline.userData = [identifier]
    super.init()
  }

  func removePolyline() {
    polyline.map = nil
  }

  /// Updates the controller's polyline with the properties from a FGMPlatformPolyline.
  ///
  /// Setting the polyline to visible will set its map to the controller's mapView.
  func update(from platformPolyline: FGMPlatformPolyline) {
    if let mapView = mapView {
      PolylineController.update(polyline, from: platformPolyline, with: mapView)
    }
  }

  /// Updates the given GMSPolyline with the properties from a FGMPlatformPolyline.
  ///
  /// Setting the polyline to visible will set its map to the given mapView.
  static func update(
    _ polyline: GMSPolyline, from platformPolyline: FGMPlatformPolyline, with mapView: GMSMapView
  ) {
    polyline.isTappable = platformPolyline.consumesTapEvents
    polyline.zIndex = Int32(platformPolyline.zIndex)
    let path = FGMGetPathFromPoints(FGMGetPointsForPigeonLatLngs(platformPolyline.points))
    polyline.path = path
    let strokeColor = FGMGetColorForPigeonColor(platformPolyline.color)
    polyline.strokeColor = strokeColor
    polyline.strokeWidth = CGFloat(platformPolyline.width)
    polyline.geodesic = platformPolyline.geodesic
    polyline.spans = GMSStyleSpans(
      path,
      FGMGetStrokeStylesFromPatterns(platformPolyline.patterns, strokeColor),
      FGMGetSpanLengthsFromPatterns(platformPolyline.patterns),
      .rhumb
    )

    // This must be done last, to avoid visual flickers of default property values.
    polyline.map = platformPolyline.visible ? mapView : nil
  }
}

class PolylinesController: NSObject {
  private var polylineIdentifierToController: [String: PolylineController] = [:]
  private weak var eventDelegate: FGMMapEventDelegate?
  private weak var mapView: GMSMapView?

  init(mapView: GMSMapView, eventDelegate: FGMMapEventDelegate) {
    self.mapView = mapView
    self.eventDelegate = eventDelegate
    super.init()
  }

  func add(_ polylines: [FGMPlatformPolyline]) {
    guard let mapView = mapView else { return }
    for polyline in polylines {
      let path = FGMGetPathFromPoints(FGMGetPointsForPigeonLatLngs(polyline.points))
      let identifier = polyline.polylineId
      let controller = PolylineController(path: path, identifier: identifier, mapView: mapView)
      controller.update(from: polyline)
      polylineIdentifierToController[identifier] = controller
    }
  }

  func change(_ polylines: [FGMPlatformPolyline]) {
    for polyline in polylines {
      let identifier = polyline.polylineId
      polylineIdentifierToController[identifier]?.update(from: polyline)
    }
  }

  func removePolyline(withIdentifiers identifiers: [String]) {
    for identifier in identifiers {
      if let controller = polylineIdentifierToController[identifier] {
        controller.removePolyline()
        polylineIdentifierToController.removeValue(forKey: identifier)
      }
    }
  }

  func didTapPolyline(withIdentifier identifier: String) {
    if hasPolyline(withIdentifier: identifier) {
      eventDelegate?.didTapPolyline(withIdentifier: identifier)
    }
  }

  func hasPolyline(withIdentifier identifier: String) -> Bool {
    return polylineIdentifierToController[identifier] != nil
  }
}
