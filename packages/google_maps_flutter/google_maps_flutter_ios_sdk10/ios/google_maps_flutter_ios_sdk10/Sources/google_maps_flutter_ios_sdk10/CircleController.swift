// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import GoogleMaps

#if canImport(google_maps_flutter_ios_sdk10_objc)
  import google_maps_flutter_ios_sdk10_objc
#endif

/// Defines circle controllable by Flutter.
class CircleController: NSObject {
  let circle: GMSCircle
  private weak var mapView: GMSMapView?

  init(circle: FGMPlatformCircle, mapView: GMSMapView) {
    self.circle = GMSCircle()
    self.mapView = mapView
    self.circle.userData = [circle.circleId]
    super.init()
    CircleController.update(self.circle, from: circle, with: mapView)
  }

  func removeCircle() {
    circle.map = nil
  }

  /// Updates the controller's circle with the properties from a FGMPlatformCircle.
  ///
  /// Setting the circle to visible will set its map to the given mapView.
  func update(from platformCircle: FGMPlatformCircle) {
    if let mapView = mapView {
      CircleController.update(circle, from: platformCircle, with: mapView)
    }
  }

  /// Updates the given GMSCircle with the properties from a FGMPlatformCircle.
  ///
  /// Setting the circle to visible will set its map to the given mapView.
  static func update(
    _ circle: GMSCircle, from platformCircle: FGMPlatformCircle, with mapView: GMSMapView
  ) {
    circle.isTappable = platformCircle.consumeTapEvents
    circle.zIndex = Int32(platformCircle.zIndex)
    circle.position = FGMGetCoordinateForPigeonLatLng(platformCircle.center)
    circle.radius = platformCircle.radius
    circle.strokeColor = FGMGetColorForPigeonColor(platformCircle.strokeColor)
    circle.strokeWidth = CGFloat(platformCircle.strokeWidth)
    circle.fillColor = FGMGetColorForPigeonColor(platformCircle.fillColor)

    // This must be done last, to avoid visual flickers of default property values.
    circle.map = platformCircle.visible ? mapView : nil
  }
}

class CirclesController: NSObject {
  private weak var eventDelegate: FGMMapEventDelegate?
  private weak var mapView: GMSMapView?
  private var circleIdToController: [String: CircleController] = [:]

  init(mapView: GMSMapView, eventDelegate: FGMMapEventDelegate) {
    self.mapView = mapView
    self.eventDelegate = eventDelegate
    super.init()
  }

  func add(_ circles: [FGMPlatformCircle]) {
    guard let mapView = mapView else { return }
    for circle in circles {
      circleIdToController[circle.circleId] = CircleController(circle: circle, mapView: mapView)
    }
  }

  func change(_ circles: [FGMPlatformCircle]) {
    for circle in circles {
      circleIdToController[circle.circleId]?.update(from: circle)
    }
  }

  func removeCircles(withIdentifiers identifiers: [String]) {
    for identifier in identifiers {
      if let controller = circleIdToController[identifier] {
        controller.removeCircle()
        circleIdToController.removeValue(forKey: identifier)
      }
    }
  }

  func hasCircle(withIdentifier identifier: String) -> Bool {
    return circleIdToController[identifier] != nil
  }

  func didTapCircle(withIdentifier identifier: String) {
    if hasCircle(withIdentifier: identifier) {
      eventDelegate?.didTapCircle(withIdentifier: identifier)
    }
  }
}
