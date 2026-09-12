// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import GoogleMaps
import GoogleMapsUtils

extension PlatformPoint {
  /// Converts a CGPoint to its Pigeon equivalent.
  static func make(from point: CGPoint) -> PlatformPoint {
    return PlatformPoint(x: point.x, y: point.y)
  }

  /// Returns the equivalent CGPoint.
  func toCGPoint() -> CGPoint {
    return CGPoint(x: x, y: y)
  }
}

extension PlatformLatLng {
  /// Converts a CLLocationCoordinate2D to its Pigeon representation.
  static func make(from coordinate: CLLocationCoordinate2D) -> PlatformLatLng {
    return PlatformLatLng(latitude: coordinate.latitude, longitude: coordinate.longitude)
  }

  /// Returns the equivalent CLLocationCoordinate2D.
  func toCLLocationCoordinate2D() -> CLLocationCoordinate2D {
    return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
  }
}

extension PlatformLatLngBounds {
  /// Converts a GMSCoordinateBounds to its Pigeon representation.
  static func make(from bounds: GMSCoordinateBounds) -> PlatformLatLngBounds {
    return PlatformLatLngBounds(
      northeast: PlatformLatLng.make(from: bounds.northEast),
      southwest: PlatformLatLng.make(from: bounds.southWest)
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

extension PlatformCameraPosition {
  /// Converts a GMSCameraPosition to its Pigeon representation.
  static func make(from position: GMSCameraPosition) -> PlatformCameraPosition {
    return PlatformCameraPosition(
      bearing: position.bearing,
      target: PlatformLatLng.make(from: position.target),
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

extension PlatformMapType {
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

extension PlatformMarkerCollisionBehavior {
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

extension PlatformGroundOverlay {
  /// Converts a GMSGroundOverlay to its Pigeon representation.
  static func make(
    from groundOverlay: GMSGroundOverlay,
    overlayId: String,
    isCreatedWithBounds: Bool,
    zoomLevel: Double?
  ) -> PlatformGroundOverlay {
    let placeholderImage = PlatformBitmapDefaultMarker(hue: nil)
    if isCreatedWithBounds, let bounds = groundOverlay.bounds {
      return PlatformGroundOverlay(
        groundOverlayId: overlayId,
        image: placeholderImage,
        position: nil,
        bounds: PlatformLatLngBounds.make(from: bounds),
        anchor: PlatformPoint.make(from: groundOverlay.anchor),
        transparency: 1.0 - Double(groundOverlay.opacity),
        bearing: groundOverlay.bearing,
        zIndex: Int64(groundOverlay.zIndex),
        visible: groundOverlay.map != nil,
        clickable: groundOverlay.isTappable,
        zoomLevel: zoomLevel
      )
    } else {
      return PlatformGroundOverlay(
        groundOverlayId: overlayId,
        image: placeholderImage,
        position: PlatformLatLng.make(from: groundOverlay.position),
        bounds: nil,
        anchor: PlatformPoint.make(from: groundOverlay.anchor),
        transparency: 1.0 - Double(groundOverlay.opacity),
        bearing: groundOverlay.bearing,
        zIndex: Int64(groundOverlay.zIndex),
        visible: groundOverlay.map != nil,
        clickable: groundOverlay.isTappable,
        zoomLevel: zoomLevel
      )
    }
  }
}

extension PlatformHeatmapGradient {
  /// Converts a GMUGradient to its Pigeon representation.
  static func make(from gradient: GMUGradient) -> PlatformHeatmapGradient {
    let colors = gradient.colors.map { PlatformColor.make(from: $0) }
    return PlatformHeatmapGradient(
      colors: colors,
      startPoints: gradient.startPoints.map({ $0.doubleValue }),
      colorMapSize: Int64(gradient.mapSize)
    )
  }

  /// Returns the equivalent GMUGradient.
  func toGMUGradient() -> GMUGradient {
    let colors = colors.map { $0.toUIColor() }
    return GMUGradient(
      colors: colors,
      startPoints: startPoints.map({ $0 as NSNumber }),
      colorMapSize: UInt(colorMapSize)
    )
  }
}

extension PlatformWeightedLatLng {
  /// Converts a GMUWeightedLatLng to its Pigeon representation.
  static func make(from weightedLatLng: GMUWeightedLatLng) -> PlatformWeightedLatLng {
    let point = GMSMapPoint(x: weightedLatLng.point().x, y: weightedLatLng.point().y)
    return PlatformWeightedLatLng(
      point: PlatformLatLng.make(from: GMSUnproject(point)),
      weight: Double(weightedLatLng.intensity)
    )
  }

  /// Returns the equivalent GMUWeightedLatLng.
  func toGMUWeightedLatLng() -> GMUWeightedLatLng {
    return GMUWeightedLatLng(coordinate: point.toCLLocationCoordinate2D(), intensity: Float(weight))
  }
}

extension PlatformCameraUpdate {
  /// Creates a GMSCameraUpdate from its Pigeon equivalent.
  func toGMSCameraUpdate() -> GMSCameraUpdate? {
    switch self {
    case let newCameraPosition as PlatformCameraUpdateNewCameraPosition:
      return GMSCameraUpdate.setCamera(newCameraPosition.cameraPosition.toGMSCameraPosition())
    case let newLatLng as PlatformCameraUpdateNewLatLng:
      return GMSCameraUpdate.setTarget(newLatLng.latLng.toCLLocationCoordinate2D())
    case let newLatLngBounds as PlatformCameraUpdateNewLatLngBounds:
      return GMSCameraUpdate.fit(
        newLatLngBounds.bounds.toGMSCoordinateBounds(),
        withPadding: CGFloat(newLatLngBounds.padding)
      )
    case let newLatLngZoom as PlatformCameraUpdateNewLatLngZoom:
      return GMSCameraUpdate.setTarget(
        newLatLngZoom.latLng.toCLLocationCoordinate2D(),
        zoom: Float(newLatLngZoom.zoom)
      )
    case let scrollBy as PlatformCameraUpdateScrollBy:
      return GMSCameraUpdate.scrollBy(x: scrollBy.dx, y: scrollBy.dy)
    case let zoomBy as PlatformCameraUpdateZoomBy:
      if let focus = zoomBy.focus {
        return GMSCameraUpdate.zoom(by: Float(zoomBy.amount), at: focus.toCGPoint())
      } else {
        return GMSCameraUpdate.zoom(by: Float(zoomBy.amount))
      }
    case let zoom as PlatformCameraUpdateZoom:
      return zoom.out ? GMSCameraUpdate.zoomOut() : GMSCameraUpdate.zoomIn()
    case let zoomTo as PlatformCameraUpdateZoomTo:
      return GMSCameraUpdate.zoom(to: Float(zoomTo.zoom))
    default:
      return nil
    }
  }
}

extension PlatformColor {
  /// Converts a UIColor to its Pigeon representation.
  static func make(from color: UIColor) -> PlatformColor {
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    return PlatformColor(
      red: Double(red), green: Double(green), blue: Double(blue), alpha: Double(alpha))
  }

  /// Returns the equivalent UIColor.
  func toUIColor() -> UIColor {
    return UIColor(red: red, green: green, blue: blue, alpha: alpha)
  }
}

extension PlatformPatternItem {
  /// The GMSStrokeStyle expression of this pattern, using the given stroke color.
  func gmsStrokeStyle(strokeColor: UIColor) -> GMSStrokeStyle {
    let color = type == .gap ? UIColor.clear : strokeColor
    return GMSStrokeStyle.solidColor(color)
  }

  /// The span length for this pattern, in the form expected by GMSStyleSpans.
  func gmsStyleSpanLength() -> NSNumber {
    return (length ?? 0) as NSNumber
  }
}

extension PlatformCluster {
  /// Converts a GMUCluster to its Pigeon representation.
  static func make(
    from cluster: GMUCluster,
    clusterManagerIdentifier: String
  ) -> PlatformCluster {
    var bounds = GMSCoordinateBounds()
    for item in cluster.items {
      bounds = bounds.includingCoordinate(item.position)
    }

    let markerIds = cluster.items.compactMap { $0 as? GMSMarker }.compactMap {
      markerIdentifierFromMarker($0)
    }

    return PlatformCluster(
      clusterManagerId: clusterManagerIdentifier,
      position: PlatformLatLng.make(from: cluster.position),
      bounds: PlatformLatLngBounds.make(from: bounds),
      markerIds: markerIds
    )
  }
}
