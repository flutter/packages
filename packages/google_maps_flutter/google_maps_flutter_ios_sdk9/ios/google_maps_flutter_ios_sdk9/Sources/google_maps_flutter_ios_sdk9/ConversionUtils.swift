// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import GoogleMaps
import GoogleMapsUtils

#if canImport(google_maps_flutter_ios_sdk9_objc)
  import google_maps_flutter_ios_sdk9_objc
#endif

/// Converts a CGPoint from its Pigeon equivalent.
func point(from point: FGMPlatformPoint) -> CGPoint {
  return CGPoint(x: point.x, y: point.y)
}

/// Converts a CGPoint to its Pigeon equivalent.
func pigeonPoint(from point: CGPoint) -> FGMPlatformPoint {
  return FGMPlatformPoint.makeWith(x: point.x, y: point.y)
}

/// Creates a CLLocationCoordinate2D from its Pigeon representation.
func coordinate(from latLng: FGMPlatformLatLng) -> CLLocationCoordinate2D {
  return CLLocationCoordinate2D(latitude: latLng.latitude, longitude: latLng.longitude)
}

/// Converts a CLLocationCoordinate2D to its Pigeon representation.
func pigeonLatLng(from coordinate: CLLocationCoordinate2D) -> FGMPlatformLatLng {
  return FGMPlatformLatLng.make(withLatitude: coordinate.latitude, longitude: coordinate.longitude)
}

/// Creates a GMSCoordinateBounds from its Pigeon representation.
func coordinateBounds(from bounds: FGMPlatformLatLngBounds) -> GMSCoordinateBounds {
  return GMSCoordinateBounds(
    coordinate: coordinate(from: bounds.northeast),
    coordinate: coordinate(from: bounds.southwest)
  )
}

/// Converts a GMSCoordinateBounds to its Pigeon representation.
func pigeonLatLngBounds(from bounds: GMSCoordinateBounds) -> FGMPlatformLatLngBounds {
  return FGMPlatformLatLngBounds.make(
    withNortheast: pigeonLatLng(from: bounds.northEast),
    southwest: pigeonLatLng(from: bounds.southWest)
  )
}

/// Converts a GMSCameraPosition to its Pigeon representation.
func pigeonCameraPosition(from position: GMSCameraPosition) -> FGMPlatformCameraPosition {
  return FGMPlatformCameraPosition.make(
    withBearing: position.bearing,
    target: pigeonLatLng(from: position.target),
    tilt: position.viewingAngle,
    zoom: position.zoom
  )
}

/// Creates a GMSCameraPosition from its Pigeon representation.
func cameraPosition(from position: FGMPlatformCameraPosition) -> GMSCameraPosition {
  return GMSCameraPosition(
    target: coordinate(from: position.target),
    zoom: position.zoom,
    bearing: position.bearing,
    viewingAngle: position.tilt
  )
}

/// Creates a CLLocation array from its Pigeon equivalent.
func points(from pigeonPoints: [FGMPlatformLatLng]) -> [CLLocation] {
  return pigeonPoints.map { CLLocation(latitude: $0.latitude, longitude: $0.longitude) }
}

/// Creates a CLLocation array array, representing a set of holes, from its Pigeon equivalent.
func holes(from pigeonHolePoints: [[FGMPlatformLatLng]]) -> [[CLLocation]] {
  return pigeonHolePoints.map { points(from: $0) }
}

/// Creates a GMSMutablePath from points.
func path(from points: [CLLocation]) -> GMSMutablePath {
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
func collisionBehavior(from collisionBehavior: FGMPlatformMarkerCollisionBehavior) -> GMSCollisionBehavior {
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

/// Converts a GMSGroundOverlay to its Pigeon representation.
func pigeonGroundOverlay(
  from groundOverlay: GMSGroundOverlay,
  overlayId: String,
  isCreatedWithBounds: Bool,
  zoomLevel: NSNumber?
) -> FGMPlatformGroundOverlay {
  let placeholderImage = FGMPlatformBitmap.make(
    withBitmap: FGMPlatformBitmapDefaultMarker.make(withHue: 0))
  if isCreatedWithBounds {
    return FGMPlatformGroundOverlay.make(
      withGroundOverlayId: overlayId,
      image: placeholderImage,
      position: nil,
      bounds: FGMPlatformLatLngBounds.make(
        withNortheast: FGMPlatformLatLng.make(
          withLatitude: groundOverlay.bounds.northEast.latitude,
          longitude: groundOverlay.bounds.northEast.longitude
        ),
        southwest: FGMPlatformLatLng.make(
          withLatitude: groundOverlay.bounds.southWest.latitude,
          longitude: groundOverlay.bounds.southWest.longitude
        )
      ),
      anchor: FGMPlatformPoint.makeWith(x: groundOverlay.anchor.x, y: groundOverlay.anchor.y),
      transparency: 1.0 - Double(groundOverlay.opacity),
      bearing: groundOverlay.bearing,
      zIndex: Double(groundOverlay.zIndex),
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
      zIndex: Double(groundOverlay.zIndex),
      visible: groundOverlay.map != nil,
      clickable: groundOverlay.isTappable,
      zoomLevel: zoomLevel
    )
  }
}

/// Creates a GMUGradient from its Pigeon representation.
func gradient(from heatmapGradient: FGMPlatformHeatmapGradient) -> GMUGradient {
  let colors = heatmapGradient.colors.map { color(from: $0) }
  return GMUGradient(
    colors: colors,
    startPoints: heatmapGradient.startPoints,
    colorMapSize: heatmapGradient.colorMapSize
  )
}

/// Converts a GMUGradient to its Pigeon representation.
func pigeonHeatmapGradient(from gradient: GMUGradient) -> FGMPlatformHeatmapGradient {
  let colors = gradient.colors.map { pigeonColor(from: $0) }
  return FGMPlatformHeatmapGradient.make(
    withColors: colors,
    startPoints: gradient.startPoints,
    colorMapSize: gradient.mapSize
  )
}

/// Creates a GMUWeightedLatLng array from its Pigeon equivalent.
func weightedData(from weightedLatLngs: [FGMPlatformWeightedLatLng]) -> [GMUWeightedLatLng] {
  return weightedLatLngs.map {
    GMUWeightedLatLng(
      coordinate: coordinate(from: $0.point),
      intensity: Float($0.weight)
    )
  }
}

/// Converts a GMUWeightedLatLng array to its Pigeon equivalent.
func pigeonWeightedData(from weightedLatLngs: [GMUWeightedLatLng]) -> [FGMPlatformWeightedLatLng] {
  return weightedLatLngs.map {
    let point = GMSMapPoint(x: $0.point.x, y: $0.point.y)
    return FGMPlatformWeightedLatLng.make(
      withPoint: pigeonLatLng(from: GMSUnproject(point)),
      weight: Double($0.intensity)
    )
  }
}

/// Creates a GMSCameraUpdate from its Pigeon equivalent.
func cameraUpdate(from cameraUpdate: FGMPlatformCameraUpdate) -> GMSCameraUpdate? {
  // See note in messages.dart for why this is so loosely typed.
  let update = cameraUpdate.cameraUpdate
  if let newCameraPosition = update as? FGMPlatformCameraUpdateNewCameraPosition {
    return GMSCameraUpdate.setCamera(cameraPosition(from: newCameraPosition.cameraPosition))
  } else if let newLatLng = update as? FGMPlatformCameraUpdateNewLatLng {
    return GMSCameraUpdate.setTarget(coordinate(from: newLatLng.latLng))
  } else if let newLatLngBounds = update as? FGMPlatformCameraUpdateNewLatLngBounds {
    return GMSCameraUpdate.fit(
      coordinateBounds(from: newLatLngBounds.bounds),
      withPadding: CGFloat(newLatLngBounds.padding)
    )
  } else if let newLatLngZoom = update as? FGMPlatformCameraUpdateNewLatLngZoom {
    return GMSCameraUpdate.setTarget(
      coordinate(from: newLatLngZoom.latLng),
      zoom: Float(newLatLngZoom.zoom)
    )
  } else if let scrollBy = update as? FGMPlatformCameraUpdateScrollBy {
    return GMSCameraUpdate.scrollBy(x: scrollBy.dx, y: scrollBy.dy)
  } else if let zoomBy = update as? FGMPlatformCameraUpdateZoomBy {
    if let focus = zoomBy.focus {
      return GMSCameraUpdate.zoom(by: Float(zoomBy.amount), at: point(from: focus))
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

/// Creates a UIColor from its Pigeon representation.
func color(from color: FGMPlatformColor) -> UIColor {
  return UIColor(red: color.red, green: color.green, blue: color.blue, alpha: color.alpha)
}

/// Converts a UIColor to its Pigeon representation.
func pigeonColor(from color: UIColor) -> FGMPlatformColor {
  var red: CGFloat = 0
  var green: CGFloat = 0
  var blue: CGFloat = 0
  var alpha: CGFloat = 0
  color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
  return FGMPlatformColor.make(
    withRed: Double(red), green: Double(green), blue: Double(blue), alpha: Double(alpha))
}

/// Creates an array of GMSStrokeStyles using the given patterns and stroke color.
func strokeStyles(
  from patterns: [FGMPlatformPatternItem], strokeColor: UIColor
) -> [GMSStrokeStyle] {
  return patterns.map { pattern in
    let color = pattern.type == .gap ? UIColor.clear : strokeColor
    return GMSStrokeStyle.solidColor(color)
  }
}

/// Creates an array of span lengths using the given patterns.
func spanLengths(from patterns: [FGMPlatformPatternItem]) -> [NSNumber] {
  return patterns.map { $0.length ?? 0 }
}

/// Converts a GMUCluster to its Pigeon representation.
func pigeonCluster(
  for cluster: GMUCluster,
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
    position: pigeonLatLng(from: cluster.position),
    bounds: pigeonLatLngBounds(from: bounds),
    markerIds: markerIds
  )
}
