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

  /// Converts a CGPoint from its Pigeon equivalent.
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

  /// Creates a CLLocationCoordinate2D from its Pigeon representation.
  func toCLCoordinate() -> CLLocationCoordinate2D {
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

  /// Creates a GMSCoordinateBounds from its Pigeon representation.
  func toGMSBounds() -> GMSCoordinateBounds {
    return GMSCoordinateBounds(
      coordinate: northeast.toCLCoordinate(),
      coordinate: southwest.toCLCoordinate()
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

  /// Creates a GMSCameraPosition from its Pigeon representation.
  func toGMSCameraPosition() -> GMSCameraPosition {
    return GMSCameraPosition(
      target: target.toCLCoordinate(),
      zoom: Float(zoom),
      bearing: bearing,
      viewingAngle: tilt
    )
  }
}

/// Creates a CLLocation array from its Pigeon equivalent.
func makePoints(from pigeonPoints: [FGMPlatformLatLng]) -> [CLLocation] {
  return pigeonPoints.map { CLLocation(latitude: $0.latitude, longitude: $0.longitude) }
}

/// Creates a CLLocation array array, representing a set of holes, from its Pigeon equivalent.
func makeHoles(from pigeonHolePoints: [[FGMPlatformLatLng]]) -> [[CLLocation]] {
  return pigeonHolePoints.map { makePoints(from: $0) }
}

/// Creates a GMSMutablePath from points.
func makePath(from points: [CLLocation]) -> GMSMutablePath {
  let path = GMSMutablePath()
  for location in points {
    path.add(location.coordinate)
  }
  return path
}

/// Creates a GMSMapViewType from its Pigeon representation.
func mapViewType(from type: FGMPlatformMapType) -> GMSMapViewType {
  switch type {
  case .none:
    return .none
  case .normal:
    return .normal
  case .satellite:
    return .satellite
  case .terrain:
    return .terrain
  case .hybrid:
    return .hybrid
  @unknown default:
    return .normal
  }
}

/// Creates a GMSCollisionBehavior from its Pigeon representation.
func collisionBehavior(from collisionBehavior: FGMPlatformMarkerCollisionBehavior)
  -> GMSCollisionBehavior
{
  switch collisionBehavior {
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
        bounds: FGMPlatformLatLngBounds.make(
          withNortheast: FGMPlatformLatLng.make(
            withLatitude: bounds.northEast.latitude,
            longitude: bounds.northEast.longitude
          ),
          southwest: FGMPlatformLatLng.make(
            withLatitude: bounds.southWest.latitude,
            longitude: bounds.southWest.longitude
          )
        ),
        anchor: FGMPlatformPoint.makeWith(x: groundOverlay.anchor.x, y: groundOverlay.anchor.y),
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
        position: FGMPlatformLatLng.make(
          withLatitude: groundOverlay.position.latitude,
          longitude: groundOverlay.position.longitude
        ),
        bounds: nil,
        anchor: FGMPlatformPoint.makeWith(x: groundOverlay.anchor.x, y: groundOverlay.anchor.y),
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

  /// Creates a GMUGradient from its Pigeon representation.
  func toGMUGradient() -> GMUGradient {
    let colors = colors.map { $0.toUIColor() }
    return GMUGradient(
      colors: colors,
      startPoints: startPoints,
      colorMapSize: UInt(colorMapSize)
    )
  }
}

/// Creates a GMUWeightedLatLng array from its Pigeon equivalent.
func makeWeightedData(from weightedLatLngs: [FGMPlatformWeightedLatLng]) -> [GMUWeightedLatLng] {
  return weightedLatLngs.map {
    GMUWeightedLatLng(
      coordinate: $0.point.toCLCoordinate(),
      intensity: Float($0.weight)
    )
  }
}

/// Converts a GMUWeightedLatLng array to its Pigeon equivalent.
func makePigeonWeightedData(from weightedLatLngs: [GMUWeightedLatLng])
  -> [FGMPlatformWeightedLatLng]
{
  return weightedLatLngs.map {
    let point = GMSMapPoint(x: $0.point().x, y: $0.point().y)
    return FGMPlatformWeightedLatLng.make(
      withPoint: FGMPlatformLatLng.make(from: GMSUnproject(point)),
      weight: Double($0.intensity)
    )
  }
}

extension FGMPlatformCameraUpdate {
  /// Creates a GMSCameraUpdate from its Pigeon equivalent.
  static func make(from cameraUpdate: FGMPlatformCameraUpdate) -> GMSCameraUpdate? {
    // See note in messages.dart for why this is so loosely typed.
    let update = cameraUpdate.cameraUpdate
    if let newCameraPosition = update as? FGMPlatformCameraUpdateNewCameraPosition {
      return GMSCameraUpdate.setCamera(newCameraPosition.cameraPosition.toGMSCameraPosition())
    } else if let newLatLng = update as? FGMPlatformCameraUpdateNewLatLng {
      return GMSCameraUpdate.setTarget(newLatLng.latLng.toCLCoordinate())
    } else if let newLatLngBounds = update as? FGMPlatformCameraUpdateNewLatLngBounds {
      return GMSCameraUpdate.fit(
        newLatLngBounds.bounds.toGMSBounds(),
        withPadding: CGFloat(newLatLngBounds.padding)
      )
    } else if let newLatLngZoom = update as? FGMPlatformCameraUpdateNewLatLngZoom {
      return GMSCameraUpdate.setTarget(
        newLatLngZoom.latLng.toCLCoordinate(),
        zoom: Float(newLatLngZoom.zoom)
      )
    } else if let scrollBy = update as? FGMPlatformCameraUpdateScrollBy {
      return GMSCameraUpdate.scrollBy(x: scrollBy.dx, y: scrollBy.dy)
    } else if let zoomBy = update as? FGMPlatformCameraUpdateZoomBy {
      if let focus = zoomBy.focus {
        return GMSCameraUpdate.zoom(by: Float(zoomBy.amount), at: focus.toCGPoint())
      } else {
        return GMSCameraUpdate.zoom(by: Float(zoomBy.amount))
      }
    } else if let zoom = update as? FGMPlatformCameraUpdateZoom {
      return zoom.out ? GMSCameraUpdate.zoomOut() : GMSCameraUpdate.zoomIn()
    } else if let zoomTo = update as? FGMPlatformCameraUpdateZoomTo {
      return GMSCameraUpdate.zoom(to: Float(zoomTo.zoom))
    }
    return nil
  }
}

extension FGMPlatformColor {
  /// Creates a UIColor from its Pigeon representation.
  func toUIColor() -> UIColor {
    return UIColor(red: red, green: green, blue: blue, alpha: alpha)
  }

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
}

/// Creates an array of GMSStrokeStyles using the given patterns and stroke color.
func makeStrokeStyles(
  from patterns: [FGMPlatformPatternItem], strokeColor: UIColor
) -> [GMSStrokeStyle] {
  return patterns.map { pattern in
    let color = pattern.type == .gap ? UIColor.clear : strokeColor
    return GMSStrokeStyle.solidColor(color)
  }
}

/// Creates an array of span lengths using the given patterns.
func makeSpanLengths(from patterns: [FGMPlatformPatternItem]) -> [NSNumber] {
  return patterns.map { $0.length ?? 0 }
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

    let markerIds = cluster.items.filter { $0 is GMSMarker }.compactMap {
      markerIdentifierFromMarker($0 as! GMSMarker)
    }

    return FGMPlatformCluster.make(
      withClusterManagerId: clusterManagerIdentifier,
      position: FGMPlatformLatLng.make(from: cluster.position),
      bounds: FGMPlatformLatLngBounds.make(from: bounds),
      markerIds: markerIds
    )
  }
}
