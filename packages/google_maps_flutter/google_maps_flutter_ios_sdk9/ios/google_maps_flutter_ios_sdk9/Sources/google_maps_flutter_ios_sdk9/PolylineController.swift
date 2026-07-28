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

  func update(from platformPolyline: FGMPlatformPolyline) {
    if let mapView = mapView {
      PolylineController.update(polyline, from: platformPolyline, with: mapView)
    }
  }

  /// Updates the underlying GMSPolyline with the properties from the given FGMPlatformPolyline.
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
    polyline.isGeodesic = platformPolyline.geodesic
    if let patterns = platformPolyline.patterns {
      polyline.spans = GMSStyleSpans(
        path,
        FGMGetStrokeStylesFromPatterns(patterns, strokeColor),
        FGMGetSpanLengthsFromPatterns(patterns),
        .rhumb
      )
    } else {
      polyline.spans = nil
    }

    // This must be done last, to avoid visual flickers of default property values.
    polyline.map = platformPolyline.visible ? mapView : nil
  }
}

class PolylinesController: NSObject {
  private var polylineIdentifierToController: [String: PolylineController]
  private weak var eventDelegate: FGMMapEventDelegate?
  private weak var mapView: GMSMapView?

  init(mapView: GMSMapView, eventDelegate: FGMMapEventDelegate) {
    self.mapView = mapView
    self.eventDelegate = eventDelegate
    self.polylineIdentifierToController = [:]
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
      if let controller = polylineIdentifierToController[identifier] {
        controller.update(from: polyline)
      }
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
