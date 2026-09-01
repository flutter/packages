// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import GoogleMaps
import GoogleMapsUtils

#if canImport(google_maps_flutter_ios_sdk9_objc)
  import google_maps_flutter_ios_sdk9_objc
#endif

extension FGMPlatformPoint {
  /// Converts a CGPoint to its Pigeon equivalent.
  static func make(from point: CGPoint) -> FGMPlatformPoint {
    return FGMPlatformPoint.makeWith(x: point.x, y: point.y)
  }

  /// Returns the equivalent CGPoint.
  func toCGPoint() -> CGPoint {
    return CGPoint(x: x, y: y)
  }
}

extension FGMPlatformLatLng {
  /// Converts a CLLocationCoordinate2D to its Pigeon representation.
  static func make(from coordinate: CLLocationCoordinate2D) -> FGMPlatformLatLng {
    return FGMPlatformLatLng.make(
      withLatitude: coordinate.latitude, longitude: coordinate.longitude)
  }

  /// Returns the equivalent CLLocationCoordinate2D.
  func toCLLocationCoordinate2D() -> CLLocationCoordinate2D {
    return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
  }
}

extension FGMPlatformLatLngBounds {
  /// Converts a GMSCoordinateBounds to its Pigeon representation.
  static func make(from bounds: GMSCoordinateBounds) -> FGMPlatformLatLngBounds {
    return FGMPlatformLatLngBounds.make(
      withNortheast: FGMPlatformLatLng.make(from: bounds.northEast),
      southwest: FGMPlatformLatLng.make(from: bounds.southWest)
    )
  }

  /// Returns the equivalent GMSCoordinateBounds.
  func toGMSCoordinateBounds() -> GMSCoordinateBounds {
    return GMSCoordinateBounds(
      coordinate: northeast.toCLLocationCoordinate2D(),
      coordinate: southwest.toCLLocationCoordinate2D()
    )
  }
}

extension FGMPlatformCameraPosition {
  /// Converts a GMSCameraPosition to its Pigeon representation.
  static func make(from position: GMSCameraPosition) -> FGMPlatformCameraPosition {
    return FGMPlatformCameraPosition.make(
      withBearing: position.bearing,
      target: FGMPlatformLatLng.make(from: position.target),
      tilt: position.viewingAngle,
      zoom: Double(position.zoom)
    )
  }

  /// Returns the equivalent GMSCameraPosition.
  func toGMSCameraPosition() -> GMSCameraPosition {
    return GMSCameraPosition(
      target: target.toCLLocationCoordinate2D(),
      zoom: Float(zoom),
      bearing: bearing,
      viewingAngle: tilt
    )
  }
}

/// Creates a GMSMutablePath from points.
func makePath(from points: [CLLocationCoordinate2D]) -> GMSMutablePath {
  let path = GMSMutablePath()
  for location in points {
    path.add(location)
  }
  return path
}

extension FGMPlatformMapType {
  /// The corresponding GMSMapViewType.
  var gmsMapViewType: GMSMapViewType {
    switch self {
    case .none: return .none
    case .normal: return .normal
    case .satellite: return .satellite
    case .terrain: return .terrain
    case .hybrid: return .hybrid
    @unknown default: return .normal
    }
  }
}

extension FGMPlatformMarkerCollisionBehavior {
  /// The corresponding GMSCollisionBehavior.
  var gmsCollisionBehavior: GMSCollisionBehavior {
    switch self {
    case .requiredDisplay:
      return .required
    case .optionalAndHidesLowerPriority:
      return .optionalAndHidesLowerPriority
    case .requiredAndHidesOptional:
      return .requiredAndHidesOptional
    @unknown default:
      return .required
    }
  }
}

extension FGMPlatformGroundOverlay {
  /// Converts a GMSGroundOverlay to its Pigeon representation.
  static func make(
    from groundOverlay: GMSGroundOverlay,
    overlayId: String,
    isCreatedWithBounds: Bool,
    zoomLevel: NSNumber?
  ) -> FGMPlatformGroundOverlay {
    let placeholderImage = FGMPlatformBitmap.make(
      withBitmap: FGMPlatformBitmapDefaultMarker.make(withHue: 0))
    if isCreatedWithBounds, let bounds = groundOverlay.bounds {
      return FGMPlatformGroundOverlay.make(
        withGroundOverlayId: overlayId,
        image: placeholderImage,
        position: nil,
        bounds: FGMPlatformLatLngBounds.make(from: bounds),
        anchor: FGMPlatformPoint.make(from: groundOverlay.anchor),
        transparency: 1.0 - Double(groundOverlay.opacity),
        bearing: groundOverlay.bearing,
        zIndex: Int(groundOverlay.zIndex),
        visible: groundOverlay.map != nil,
        clickable: groundOverlay.isTappable,
        zoomLevel: zoomLevel
      )
    } else {
      return FGMPlatformGroundOverlay.make(
        withGroundOverlayId: overlayId,
        image: placeholderImage,
        position: FGMPlatformLatLng.make(from: groundOverlay.position),
        bounds: nil,
        anchor: FGMPlatformPoint.make(from: groundOverlay.anchor),
        transparency: 1.0 - Double(groundOverlay.opacity),
        bearing: groundOverlay.bearing,
        zIndex: Int(groundOverlay.zIndex),
        visible: groundOverlay.map != nil,
        clickable: groundOverlay.isTappable,
        zoomLevel: zoomLevel
      )
    }
  }
}

extension FGMPlatformHeatmapGradient {
  /// Converts a GMUGradient to its Pigeon representation.
  static func make(from gradient: GMUGradient) -> FGMPlatformHeatmapGradient {
    let colors = gradient.colors.map { FGMPlatformColor.make(from: $0) }
    return FGMPlatformHeatmapGradient.make(
      with: colors,
      startPoints: gradient.startPoints,
      colorMapSize: Int(gradient.mapSize)
    )
  }

  /// Returns the equivalent GMUGradient.
  func toGMUGradient() -> GMUGradient {
    let colors = colors.map { $0.toUIColor() }
    return GMUGradient(
      colors: colors,
      startPoints: startPoints,
      colorMapSize: UInt(colorMapSize)
    )
  }
}

extension FGMPlatformWeightedLatLng {
  /// Converts a GMUWeightedLatLng to its Pigeon representation.
  static func make(from weightedLatLng: GMUWeightedLatLng) -> FGMPlatformWeightedLatLng {
    let point = GMSMapPoint(x: weightedLatLng.point().x, y: weightedLatLng.point().y)
    return FGMPlatformWeightedLatLng.make(
      withPoint: FGMPlatformLatLng.make(from: GMSUnproject(point)),
      weight: Double(weightedLatLng.intensity)
    )
  }

  /// Returns the equivalent GMUWeightedLatLng.
  func toGMUWeightedLatLng() -> GMUWeightedLatLng {
    return GMUWeightedLatLng(coordinate: point.toCLLocationCoordinate2D(), intensity: Float(weight))
  }
}

extension FGMPlatformCameraUpdate {
  /// Creates a GMSCameraUpdate from its Pigeon equivalent.
  func toGMSCameraUpdate() -> GMSCameraUpdate? {
    // See note in messages.dart for why this is so loosely typed.
    switch cameraUpdate {
    case let newCameraPosition as FGMPlatformCameraUpdateNewCameraPosition:
      return GMSCameraUpdate.setCamera(newCameraPosition.cameraPosition.toGMSCameraPosition())
    case let newLatLng as FGMPlatformCameraUpdateNewLatLng:
      return GMSCameraUpdate.setTarget(newLatLng.latLng.toCLLocationCoordinate2D())
    case let newLatLngBounds as FGMPlatformCameraUpdateNewLatLngBounds:
      return GMSCameraUpdate.fit(
        newLatLngBounds.bounds.toGMSCoordinateBounds(),
        withPadding: CGFloat(newLatLngBounds.padding)
      )
    case let newLatLngZoom as FGMPlatformCameraUpdateNewLatLngZoom:
      return GMSCameraUpdate.setTarget(
        newLatLngZoom.latLng.toCLLocationCoordinate2D(),
        zoom: Float(newLatLngZoom.zoom)
      )
    case let scrollBy as FGMPlatformCameraUpdateScrollBy:
      return GMSCameraUpdate.scrollBy(x: scrollBy.dx, y: scrollBy.dy)
    case let zoomBy as FGMPlatformCameraUpdateZoomBy:
      if let focus = zoomBy.focus {
        return GMSCameraUpdate.zoom(by: Float(zoomBy.amount), at: focus.toCGPoint())
      } else {
        return GMSCameraUpdate.zoom(by: Float(zoomBy.amount))
      }
    case let zoom as FGMPlatformCameraUpdateZoom:
      return zoom.out ? GMSCameraUpdate.zoomOut() : GMSCameraUpdate.zoomIn()
    case let zoomTo as FGMPlatformCameraUpdateZoomTo:
      return GMSCameraUpdate.zoom(to: Float(zoomTo.zoom))
    default:
      return nil
    }
  }
}

extension FGMPlatformColor {
  /// Converts a UIColor to its Pigeon representation.
  static func make(from color: UIColor) -> FGMPlatformColor {
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    return FGMPlatformColor.make(
      withRed: Double(red), green: Double(green), blue: Double(blue), alpha: Double(alpha))
  }

  /// Returns the equivalent UIColor.
  func toUIColor() -> UIColor {
    return UIColor(red: red, green: green, blue: blue, alpha: alpha)
  }
}

extension FGMPlatformPatternItem {
  /// The GMSStrokeStyle expression of this pattern, using the given stroke color.
  func gmsStrokeStyle(strokeColor: UIColor) -> GMSStrokeStyle {
    let color = type == .gap ? UIColor.clear : strokeColor
    return GMSStrokeStyle.solidColor(color)
  }

  /// The span length for this pattern, in the form expected by GMSStyleSpans.
  func gmsStyleSpanLength() -> NSNumber {
    return length ?? 0
  }
}

extension FGMPlatformCluster {
  /// Converts a GMUCluster to its Pigeon representation.
  static func make(
    from cluster: GMUCluster,
    clusterManagerIdentifier: String
  ) -> FGMPlatformCluster {
    var bounds = GMSCoordinateBounds()
    for item in cluster.items {
      bounds = bounds.includingCoordinate(item.position)
    }

    let markerIds = cluster.items.compactMap { $0 as? GMSMarker }.compactMap {
      markerIdentifierFromMarker($0)
    }

    return FGMPlatformCluster.make(
      withClusterManagerId: clusterManagerIdentifier,
      position: FGMPlatformLatLng.make(from: cluster.position),
      bounds: FGMPlatformLatLngBounds.make(from: bounds),
      markerIds: markerIds
    )
  }
}
