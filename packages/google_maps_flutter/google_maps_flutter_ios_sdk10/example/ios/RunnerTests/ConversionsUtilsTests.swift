// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import GoogleMaps
import Testing
import google_maps_flutter_ios_sdk10_objc

@testable import google_maps_flutter_ios_sdk10

@MainActor struct ConversionUtilsTests {

  @Test func colorFromPlatformColor() {
    let platformRed: CGFloat = 1 / 255.0
    let platformGreen: CGFloat = 2 / 255.0
    let platformBlue: CGFloat = 3 / 255.0
    let platformAlpha: CGFloat = 4 / 255.0
    let color = FGMPlatformColor.make(
      withRed: platformRed,
      green: platformGreen,
      blue: platformBlue,
      alpha: platformAlpha
    ).toUIColor()
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    let success = color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    #expect(success)
    #expect(abs(red - platformRed) <= CGFloat.ulpOfOne)
    #expect(abs(green - platformGreen) <= CGFloat.ulpOfOne)
    #expect(abs(blue - platformBlue) <= CGFloat.ulpOfOne)
    #expect(abs(alpha - platformAlpha) <= CGFloat.ulpOfOne)
  }

  @Test func platformColorFromColor() {
    let red: CGFloat = 1 / 255.0
    let green: CGFloat = 2 / 255.0
    let blue: CGFloat = 3 / 255.0
    let alpha: CGFloat = 4 / 255.0
    let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
    let platformColor = FGMPlatformColor.make(from: color)
    #expect(abs(red - platformColor.red) <= CGFloat.ulpOfOne)
    #expect(abs(green - platformColor.green) <= CGFloat.ulpOfOne)
    #expect(abs(blue - platformColor.blue) <= CGFloat.ulpOfOne)
    #expect(abs(alpha - platformColor.alpha) <= CGFloat.ulpOfOne)
  }

  @Test func pointFromLatLong() {
    let latlong = FGMPlatformLatLng.make(withLatitude: 1, longitude: 2)
    let location = latlong.toCLLocationCoordinate2D()
    #expect(location.latitude == 1)
    #expect(location.longitude == 2)
  }

  @Test func getPigeonCameraPositionForPosition() {
    let position = GMSCameraPosition(
      target: CLLocationCoordinate2D(latitude: 1, longitude: 2),
      zoom: 2.0,
      bearing: 3.0,
      viewingAngle: 75.0
    )
    let pigeonPosition = FGMPlatformCameraPosition.make(from: position)
    #expect(abs(pigeonPosition.target.latitude - position.target.latitude) <= Double.ulpOfOne)
    #expect(abs(pigeonPosition.target.longitude - position.target.longitude) <= Double.ulpOfOne)
    #expect(abs(Float(pigeonPosition.zoom) - position.zoom) <= Float.ulpOfOne)
    #expect(abs(pigeonPosition.bearing - position.bearing) <= Double.ulpOfOne)
    #expect(abs(pigeonPosition.tilt - position.viewingAngle) <= Double.ulpOfOne)
  }

  @Test func pigeonPointForGCPoint() {
    let point = CGPoint(x: 10, y: 20)
    let pigeonPoint = FGMPlatformPoint.make(from: point)
    #expect(abs(pigeonPoint.x - Double(point.x)) <= Double.ulpOfOne)
    #expect(abs(pigeonPoint.y - Double(point.y)) <= Double.ulpOfOne)
  }

  @Test func pigeonLatLngBoundsForCoordinateBounds() {
    let bounds = GMSCoordinateBounds(
      coordinate: CLLocationCoordinate2D(latitude: 10, longitude: 20),
      coordinate: CLLocationCoordinate2D(latitude: 30, longitude: 40)
    )
    let pigeonBounds = FGMPlatformLatLngBounds.make(from: bounds)
    #expect(abs(pigeonBounds.southwest.latitude - bounds.southWest.latitude) <= Double.ulpOfOne)
    #expect(abs(pigeonBounds.southwest.longitude - bounds.southWest.longitude) <= Double.ulpOfOne)
    #expect(abs(pigeonBounds.northeast.latitude - bounds.northEast.latitude) <= Double.ulpOfOne)
    #expect(abs(pigeonBounds.northeast.longitude - bounds.northEast.longitude) <= Double.ulpOfOne)
  }

  @Test func getCameraPostionForPigeonCameraPosition() {
    let pigeonCameraPosition = FGMPlatformCameraPosition.make(
      withBearing: 1.0,
      target: FGMPlatformLatLng.make(withLatitude: 2.0, longitude: 3.0),
      tilt: 4.0,
      zoom: 5.0
    )

    let cameraPosition = pigeonCameraPosition.toGMSCameraPosition()

    #expect(
      abs(cameraPosition.target.latitude - pigeonCameraPosition.target.latitude) <= Double.ulpOfOne)
    #expect(
      abs(cameraPosition.target.longitude - pigeonCameraPosition.target.longitude)
        <= Double.ulpOfOne)
    #expect(abs(Double(cameraPosition.zoom) - pigeonCameraPosition.zoom) <= Double.ulpOfOne)
    #expect(abs(cameraPosition.bearing - pigeonCameraPosition.bearing) <= Double.ulpOfOne)
    #expect(abs(cameraPosition.viewingAngle - pigeonCameraPosition.tilt) <= Double.ulpOfOne)
  }

  @Test func cgPointForPigeonPoint() {
    let pigeonPoint = FGMPlatformPoint.makeWith(x: 1.0, y: 2.0)

    let point = pigeonPoint.toCGPoint()

    #expect(abs(pigeonPoint.x - Double(point.x)) <= Double.ulpOfOne)
    #expect(abs(pigeonPoint.y - Double(point.y)) <= Double.ulpOfOne)
  }

  @Test func coordinateBoundsFromLatLongs() {
    let pigeonBounds = FGMPlatformLatLngBounds.make(
      withNortheast: FGMPlatformLatLng.make(withLatitude: 3, longitude: 4),
      southwest: FGMPlatformLatLng.make(withLatitude: 1, longitude: 2)
    )

    let bounds = pigeonBounds.toGMSCoordinateBounds()

    let accuracy: Double = 0.001
    #expect(abs(bounds.southWest.latitude - 1) <= accuracy)
    #expect(abs(bounds.southWest.longitude - 2) <= accuracy)
    #expect(abs(bounds.northEast.latitude - 3) <= accuracy)
    #expect(abs(bounds.northEast.longitude - 4) <= accuracy)
  }

  @Test func mapViewTypeFromPigeonType() {
    #expect(GMSMapViewType.normal == FGMPlatformMapType.normal.gmsMapViewType)
    #expect(GMSMapViewType.satellite == FGMPlatformMapType.satellite.gmsMapViewType)
    #expect(GMSMapViewType.terrain == FGMPlatformMapType.terrain.gmsMapViewType)
    #expect(GMSMapViewType.hybrid == FGMPlatformMapType.hybrid.gmsMapViewType)
    #expect(GMSMapViewType.none == FGMPlatformMapType.none.gmsMapViewType)
  }

  @Test func cameraUpdateFromNewCameraPosition() {
    let newPositionUpdate = FGMPlatformCameraUpdateNewCameraPosition.make(
      with: FGMPlatformCameraPosition.make(
        withBearing: 4,
        target: FGMPlatformLatLng.make(withLatitude: 1, longitude: 2),
        tilt: 5,
        zoom: 3
      )
    )
    _ = FGMPlatformCameraUpdate.make(withCameraUpdate: newPositionUpdate).toGMSCameraUpdate()
    // GMSCameraUpdate is not inspectable, so this test just ensures that the codepath
    // doesn't throw. FGMGetCameraUpdateForPigeonCameraUpdate is simple enough that
    // injecting a wrapper would not meaningfully improve test coverage, since the non-test
    // implementation would be about as complex as the conversion function itself.
  }

  @Test func cameraUpdateFromNewLatLong() {
    let lat: Double = 1
    let lng: Double = 2
    let platformUpdate = FGMPlatformCameraUpdateNewLatLng.make(
      with: FGMPlatformLatLng.make(withLatitude: lat, longitude: lng)
    )

    _ = FGMPlatformCameraUpdate.make(withCameraUpdate: platformUpdate).toGMSCameraUpdate()
    // GMSCameraUpdate is not inspectable, so this test just ensures that the codepath
    // doesn't throw. FGMGetCameraUpdateForPigeonCameraUpdate is simple enough that
    // injecting a wrapper would not meaningfully improve test coverage, since the non-test
    // implementation would be about as complex as the conversion function itself.
  }

  @Test func cameraUpdateFromNewLatLngBounds() {
    let pigeonBounds = FGMPlatformLatLngBounds.make(
      withNortheast: FGMPlatformLatLng.make(withLatitude: 1, longitude: 2),
      southwest: FGMPlatformLatLng.make(withLatitude: 3, longitude: 4)
    )
    let bounds = pigeonBounds.toGMSCoordinateBounds()

    let padding: Double = 20
    let platformUpdate = FGMPlatformCameraUpdateNewLatLngBounds.make(
      with: FGMPlatformLatLngBounds.make(from: bounds),
      padding: padding
    )
    _ = FGMPlatformCameraUpdate.make(withCameraUpdate: platformUpdate).toGMSCameraUpdate()
    // GMSCameraUpdate is not inspectable, so this test just ensures that the codepath
    // doesn't throw. FGMGetCameraUpdateForPigeonCameraUpdate is simple enough that
    // injecting a wrapper would not meaningfully improve test coverage, since the non-test
    // implementation would be about as complex as the conversion function itself.
  }

  @Test func cameraUpdateFromNewLatLngZoom() {
    let lat: Double = 1
    let lng: Double = 2
    let zoom: Double = 3
    let platformUpdate = FGMPlatformCameraUpdateNewLatLngZoom.make(
      with: FGMPlatformLatLng.make(withLatitude: lat, longitude: lng),
      zoom: zoom
    )

    _ = FGMPlatformCameraUpdate.make(withCameraUpdate: platformUpdate).toGMSCameraUpdate()
    // GMSCameraUpdate is not inspectable, so this test just ensures that the codepath
    // doesn't throw. FGMGetCameraUpdateForPigeonCameraUpdate is simple enough that
    // injecting a wrapper would not meaningfully improve test coverage, since the non-test
    // implementation would be about as complex as the conversion function itself.
  }

  @Test func cameraUpdateFromScrollBy() {
    let x: Double = 1
    let y: Double = 2
    let platformUpdate = FGMPlatformCameraUpdateScrollBy.make(withDx: x, dy: y)

    _ = FGMPlatformCameraUpdate.make(withCameraUpdate: platformUpdate).toGMSCameraUpdate()
    // GMSCameraUpdate is not inspectable, so this test just ensures that the codepath
    // doesn't throw. FGMGetCameraUpdateForPigeonCameraUpdate is simple enough that
    // injecting a wrapper would not meaningfully improve test coverage, since the non-test
    // implementation would be about as complex as the conversion function itself.
  }

  @Test func cameraUpdateFromZoomBy() {
    let zoom: Double = 1
    let platformUpdateNoPoint = FGMPlatformCameraUpdateZoomBy.make(withAmount: zoom, focus: nil)

    _ = FGMPlatformCameraUpdate.make(withCameraUpdate: platformUpdateNoPoint).toGMSCameraUpdate()
    // GMSCameraUpdate is not inspectable, so this test just ensures that the codepath
    // doesn't throw. FGMGetCameraUpdateForPigeonCameraUpdate is simple enough that
    // injecting a wrapper would not meaningfully improve test coverage, since the non-test
    // implementation would be about as complex as the conversion function itself.
  }

  @Test func cameraUpdateFromZoomByWithFocus() {
    let zoom: Double = 1
    let x: Double = 2
    let y: Double = 3
    let platformUpdate = FGMPlatformCameraUpdateZoomBy.make(
      withAmount: zoom,
      focus: FGMPlatformPoint.makeWith(x: x, y: y)
    )

    _ = FGMPlatformCameraUpdate.make(withCameraUpdate: platformUpdate).toGMSCameraUpdate()
    // GMSCameraUpdate is not inspectable, so this test just ensures that the codepath
    // doesn't throw. FGMGetCameraUpdateForPigeonCameraUpdate is simple enough that
    // injecting a wrapper would not meaningfully improve test coverage, since the non-test
    // implementation would be about as complex as the conversion function itself.
  }

  @Test func cameraUpdateFromZoomIn() {
    let platformUpdate = FGMPlatformCameraUpdateZoom.make(withOut: false)

    _ = FGMPlatformCameraUpdate.make(withCameraUpdate: platformUpdate).toGMSCameraUpdate()
    // GMSCameraUpdate is not inspectable, so this test just ensures that the codepath
    // doesn't throw. FGMGetCameraUpdateForPigeonCameraUpdate is simple enough that
    // injecting a wrapper would not meaningfully improve test coverage, since the non-test
    // implementation would be about as complex as the conversion function itself.
  }

  @Test func cameraUpdateFromZoomOut() {
    let platformUpdate = FGMPlatformCameraUpdateZoom.make(withOut: true)

    _ = FGMPlatformCameraUpdate.make(withCameraUpdate: platformUpdate).toGMSCameraUpdate()
    // GMSCameraUpdate is not inspectable, so this test just ensures that the codepath
    // doesn't throw. FGMGetCameraUpdateForPigeonCameraUpdate is simple enough that
    // injecting a wrapper would not meaningfully improve test coverage, since the non-test
    // implementation would be about as complex as the conversion function itself.
  }

  @Test func cameraUpdateFromZoomTo() {
    let zoom: Double = 1
    let platformUpdate = FGMPlatformCameraUpdateZoomTo.make(withZoom: zoom)

    _ = FGMPlatformCameraUpdate.make(withCameraUpdate: platformUpdate).toGMSCameraUpdate()
    // GMSCameraUpdate is not inspectable, so this test just ensures that the codepath
    // doesn't throw. FGMGetCameraUpdateForPigeonCameraUpdate is simple enough that
    // injecting a wrapper would not meaningfully improve test coverage, since the non-test
    // implementation would be about as complex as the conversion function itself.
  }

  @Test func strokeStyleFromPattern() {
    let pattern = FGMPlatformPatternItem.make(with: .dash, length: 1)
    let strokeColor = UIColor.red

    _ = pattern.gmsStrokeStyle(strokeColor: strokeColor)
    // GMSStrokeStyle is not inspectable, so this test just ensures that the codepath
    // doesn't throw.
  }

  @Test func nonNullLengthFromPatternItem() {
    let length: Double = 6.4
    let pattern = FGMPlatformPatternItem.make(with: .gap, length: length as NSNumber)

    let spanLength = pattern.gmsStyleSpanLength()

    #expect(spanLength.doubleValue == length)
  }

  @Test func nullLengthFromPatternItem() {
    let pattern = FGMPlatformPatternItem.make(with: .dot, length: nil)

    let spanLength = pattern.gmsStyleSpanLength()

    #expect(spanLength.doubleValue == 0)
  }

  @Test func weightedLatLngFromPlatformWeightedLatLng() {
    let intensity: Double = 3.0
    let data = FGMPlatformWeightedLatLng.make(
      withPoint: FGMPlatformLatLng.make(withLatitude: 10, longitude: 20),
      weight: intensity
    )

    let weightedData = data.toGMUWeightedLatLng()
    #expect(Double(weightedData.intensity) == intensity)
  }

  @Test func gradientFromPlatformGradient() {
    let startPoint: Double = 0.6
    let platformRed: Double = 0.1
    let platformGreen: Double = 0.2
    let platformBlue: Double = 0.3
    let platformAlpha: Double = 0.4
    let colorMapSize: Int = 200
    let platformGradient = FGMPlatformHeatmapGradient.make(
      with: [
        FGMPlatformColor.make(
          withRed: platformRed,
          green: platformGreen,
          blue: platformBlue,
          alpha: platformAlpha
        )
      ],
      startPoints: [startPoint as NSNumber],
      colorMapSize: colorMapSize
    )

    let gradient = platformGradient.toGMUGradient()
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    gradient.colors[0].getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    #expect(abs(red - platformRed) <= CGFloat.ulpOfOne)
    #expect(abs(green - platformGreen) <= CGFloat.ulpOfOne)
    #expect(abs(blue - platformBlue) <= CGFloat.ulpOfOne)
    #expect(abs(alpha - platformAlpha) <= CGFloat.ulpOfOne)
    #expect(abs(gradient.startPoints[0].doubleValue - startPoint) <= Double.ulpOfOne)
    #expect(gradient.mapSize == UInt(colorMapSize))
  }
}
