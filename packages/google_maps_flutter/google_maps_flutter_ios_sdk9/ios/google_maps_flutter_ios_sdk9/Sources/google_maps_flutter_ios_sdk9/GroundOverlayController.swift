// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import GoogleMaps
import UIKit
import google_maps_flutter_ios_sdk9_objc

/// Controller of a single ground overlay on the map.
class GroundOverlayController: NSObject {
  let groundOverlay: GMSGroundOverlay
  private weak var mapView: GMSMapView?
  let createdWithBounds: Bool
  var zoomLevel: NSNumber?

  init(
    groundOverlay: GMSGroundOverlay, identifier: String, mapView: GMSMapView,
    isCreatedWithBounds: Bool
  ) {
    self.groundOverlay = groundOverlay
    self.mapView = mapView
    self.groundOverlay.userData = [identifier]
    self.createdWithBounds = isCreatedWithBounds
    super.init()
  }

  func removeGroundOverlay() {
    groundOverlay.map = nil
  }

  func update(
    from platformGroundOverlay: FGMPlatformGroundOverlay, assetProvider: FGMAssetProvider,
    screenScale: CGFloat
  ) {
    if let mapView = mapView {
      GroundOverlayController.update(
        groundOverlay,
        from: platformGroundOverlay,
        with: mapView,
        assetProvider: assetProvider,
        screenScale: screenScale,
        usingBounds: createdWithBounds
      )
    }
  }

  static func update(
    _ groundOverlay: GMSGroundOverlay,
    from platformGroundOverlay: FGMPlatformGroundOverlay,
    with mapView: GMSMapView,
    assetProvider: FGMAssetProvider,
    screenScale: CGFloat,
    usingBounds useBounds: Bool
  ) {
    groundOverlay.isTappable = platformGroundOverlay.clickable
    groundOverlay.zIndex = Int32(platformGroundOverlay.zIndex)
    groundOverlay.anchor = CGPoint(
      x: platformGroundOverlay.anchor.x, y: platformGroundOverlay.anchor.y)
    let image = FGMIconFromBitmap(platformGroundOverlay.image, assetProvider, screenScale)
    groundOverlay.icon = image
    groundOverlay.bearing = platformGroundOverlay.bearing
    groundOverlay.opacity = 1.0 - platformGroundOverlay.transparency
    if useBounds {
      if let bounds = platformGroundOverlay.bounds {
        groundOverlay.bounds = GMSCoordinateBounds(
          coordinate: CLLocationCoordinate2D(
            latitude: bounds.northeast.latitude,
            longitude: bounds.northeast.longitude
          ),
          coordinate: CLLocationCoordinate2D(
            latitude: bounds.southwest.latitude,
            longitude: bounds.southwest.longitude
          )
        )
      }
    } else {
      if let position = platformGroundOverlay.position {
        groundOverlay.position = CLLocationCoordinate2D(
          latitude: position.latitude,
          longitude: position.longitude
        )
      }
    }

    // This must be done last, to avoid visual flickers of default property values.
    groundOverlay.map = platformGroundOverlay.visible ? mapView : nil
  }
}

/// Controller of multiple ground overlays on the map.
class GroundOverlaysController: NSObject {
  private var groundOverlayControllerByIdentifier: [String: GroundOverlayController] = [:]
  private weak var eventDelegate: FGMMapEventDelegate?
  private var assetProvider: FGMAssetProvider
  private weak var mapView: GMSMapView?

  init(mapView: GMSMapView, eventDelegate: FGMMapEventDelegate, assetProvider: FGMAssetProvider) {
    self.mapView = mapView
    self.eventDelegate = eventDelegate
    self.assetProvider = assetProvider
    super.init()
  }

  func add(_ groundOverlaysToAdd: [FGMPlatformGroundOverlay]) {
    guard let mapView = mapView else { return }
    let screenScale = getScreenScale()
    for groundOverlay in groundOverlaysToAdd {
      let identifier = groundOverlay.groundOverlayId
      let gmsOverlay: GMSGroundOverlay
      var isCreatedWithBounds = false
      if groundOverlay.position == nil {
        isCreatedWithBounds = true
        guard let bounds = groundOverlay.bounds else {
          fatalError("If ground overlay is initialized without position, bounds are required")
        }
        let boundsObj = GMSCoordinateBounds(
          coordinate: CLLocationCoordinate2D(
            latitude: bounds.northeast.latitude,
            longitude: bounds.northeast.longitude
          ),
          coordinate: CLLocationCoordinate2D(
            latitude: bounds.southwest.latitude,
            longitude: bounds.southwest.longitude
          )
        )
        let iconImage = FGMIconFromBitmap(groundOverlay.image, assetProvider, screenScale)
        gmsOverlay = GMSGroundOverlay(bounds: boundsObj, icon: iconImage)
      } else {
        guard let zoomLevel = groundOverlay.zoomLevel else {
          fatalError("If ground overlay is initialized with position, zoomLevel is required")
        }
        let position = CLLocationCoordinate2D(
          latitude: groundOverlay.position.latitude,
          longitude: groundOverlay.position.longitude
        )
        let iconImage = FGMIconFromBitmap(groundOverlay.image, assetProvider, screenScale)
        gmsOverlay = GMSGroundOverlay(
          position: position,
          icon: iconImage,
          zoomLevel: CGFloat(zoomLevel.doubleValue)
        )
      }
      let controller = GroundOverlayController(
        groundOverlay: gmsOverlay,
        identifier: identifier,
        mapView: mapView,
        isCreatedWithBounds: isCreatedWithBounds
      )
      controller.zoomLevel = groundOverlay.zoomLevel
      controller.update(
        from: groundOverlay,
        assetProvider: assetProvider,
        screenScale: screenScale
      )
      groundOverlayControllerByIdentifier[identifier] = controller
    }
  }

  func change(_ groundOverlaysToChange: [FGMPlatformGroundOverlay]) {
    let screenScale = getScreenScale()
    for groundOverlay in groundOverlaysToChange {
      let identifier = groundOverlay.groundOverlayId
      groundOverlayControllerByIdentifier[identifier]?.update(
        from: groundOverlay,
        assetProvider: assetProvider,
        screenScale: screenScale
      )
    }
  }

  func removeGroundOverlays(withIdentifiers identifiers: [String]) {
    for identifier in identifiers {
      if let controller = groundOverlayControllerByIdentifier[identifier] {
        controller.removeGroundOverlay()
        groundOverlayControllerByIdentifier.removeValue(forKey: identifier)
      }
    }
  }

  func didTapGroundOverlay(withIdentifier identifier: String) {
    if hasGroundOverlays(withIdentifier: identifier) {
      eventDelegate?.didTapGroundOverlay(withIdentifier: identifier)
    }
  }

  func hasGroundOverlays(withIdentifier identifier: String) -> Bool {
    return groundOverlayControllerByIdentifier[identifier] != nil
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

  func groundOverlay(withIdentifier identifier: String) -> FGMPlatformGroundOverlay? {
    guard let controller = groundOverlayControllerByIdentifier[identifier] else {
      return nil
    }
    return FGMGetPigeonGroundOverlay(
      controller.groundOverlay,
      identifier,
      controller.createdWithBounds,
      controller.zoomLevel
    )
  }
}
