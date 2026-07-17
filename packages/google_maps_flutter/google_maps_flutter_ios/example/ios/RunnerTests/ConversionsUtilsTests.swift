// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import GoogleMaps
import Testing

@testable import google_maps_flutter_ios

@MainActor struct ConversionUtilsTests {

  @Test func colorFromPlatformColor() {
    let platformRed: Double = 1 / 255.0
    let platformGreen: Double = 2 / 255.0
    let platformBlue: Double = 3 / 255.0
    let platformAlpha: Double = 4 / 255.0
    let color = FGMGetColorForPigeonColor(
      FGMPlatformColor.make(
        withRed: platformRed,
        green: platformGreen,
        blue: platformBlue,
        alpha: platformAlpha
      )
    )
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    let success = color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    #expect(success)
    let accuracy: Double = 0.0001
    #expect(abs(Double(red) - platformRed) <= accuracy)
    #expect(abs(Double(green) - platformGreen) <= accuracy)
    #expect(abs(Double(blue) - platformBlue) <= accuracy)
    #expect(abs(Double(alpha) - platformAlpha) <= accuracy)
  }

  @Test func platformColorFromColor() {
    let red: Double = 1 / 255.0
    let green: Double = 2 / 255.0
    let blue: Double = 3 / 255.0
    let alpha: Double = 4 / 255.0
    let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
    let platformColor = FGMGetPigeonColorForColor(color)
    let accuracy: Double = 0.0001
    #expect(abs(red - platformColor.red) <= accuracy)
    #expect(abs(green - platformColor.green) <= accuracy)
    #expect(abs(blue - platformColor.blue) <= accuracy)
    #expect(abs(alpha - platformColor.alpha) <= accuracy)
  }

  @Test func pointsFromLatLongs() {
    let latlongs = [
      FGMPlatformLatLng.make(withLatitude: 1, longitude: 2),
      FGMPlatformLatLng.make(withLatitude: 3, longitude: 4),
    ]
    let locations = FGMGetPointsForPigeonLatLngs(latlongs)
    #expect(locations.count == 2)
    #expect(locations[0].coordinate.latitude == 1)
    #expect(locations[0].coordinate.longitude == 2)
    #expect(locations[1].coordinate.latitude == 3)
    #expect(locations[1].coordinate.longitude == 4)
  }

  @Test func holesFromPointsArray() {
    let pointsArray = [
      [
        FGMPlatformLatLng.make(withLatitude: 1, longitude: 2),
        FGMPlatformLatLng.make(withLatitude: 3, longitude: 4),
      ],
      [
        FGMPlatformLatLng.make(withLatitude: 5, longitude: 6),
        FGMPlatformLatLng.make(withLatitude: 7, longitude: 8),
      ],
    ]
    let holes = FGMGetHolesForPigeonLatLngArrays(pointsArray)
    #expect(holes.count == 2)
    #expect(holes[0][0].coordinate.latitude == 1)
    #expect(holes[0][0].coordinate.longitude == 2)
    #expect(holes[0][1].coordinate.latitude == 3)
    #expect(holes[0][1].coordinate.longitude == 4)
    #expect(holes[1][0].coordinate.latitude == 5)
    #expect(holes[1][0].coordinate.longitude == 6)
    #expect(holes[1][1].coordinate.latitude == 7)
    #expect(holes[1][1].coordinate.longitude == 8)
  }

  @Test func getPigeonCameraPositionForPosition() {
    let position = GMSCameraPosition(
      target: CLLocationCoordinate2D(latitude: 1, longitude: 2),
      zoom: 2.0,
      bearing: 3.0,
      viewingAngle: 75.0
    )
    let pigeonPosition = FGMGetPigeonCameraPositionForPosition(position)
    #expect(abs(pigeonPosition.target.latitude - position.target.latitude) <= Double.ulpOfOne)
    #expect(abs(pigeonPosition.target.longitude - position.target.longitude) <= Double.ulpOfOne)
    #expect(abs(Float(pigeonPosition.zoom) - position.zoom) <= Float.ulpOfOne)
    #expect(abs(pigeonPosition.bearing - position.bearing) <= Double.ulpOfOne)
    #expect(abs(pigeonPosition.tilt - position.viewingAngle) <= Double.ulpOfOne)
  }

  @Test func pigeonPointForGCPoint() {
    let point = CGPoint(x: 10, y: 20)
    let pigeonPoint = FGMGetPigeonPointForCGPoint(point)
    #expect(abs(pigeonPoint.x - Double(point.x)) <= Double.ulpOfOne)
    #expect(abs(pigeonPoint.y - Double(point.y)) <= Double.ulpOfOne)
  }

  @Test func pigeonLatLngBoundsForCoordinateBounds() {
    let bounds = GMSCoordinateBounds(
      coordinate: CLLocationCoordinate2D(latitude: 10, longitude: 20),
      coordinate: CLLocationCoordinate2D(latitude: 30, longitude: 40)
    )
    let pigeonBounds = FGMGetPigeonLatLngBoundsForCoordinateBounds(bounds)
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

    let cameraPosition = FGMGetCameraPositionForPigeonCameraPosition(pigeonCameraPosition)

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

    let point = FGMGetCGPointForPigeonPoint(pigeonPoint)

    #expect(abs(pigeonPoint.x - Double(point.x)) <= Double.ulpOfOne)
    #expect(abs(pigeonPoint.y - Double(point.y)) <= Double.ulpOfOne)
  }

  @Test func coordinateBoundsFromLatLongs() {
    let pigeonBounds = FGMPlatformLatLngBounds.make(
      withNortheast: FGMPlatformLatLng.make(withLatitude: 3, longitude: 4),
      southwest: FGMPlatformLatLng.make(withLatitude: 1, longitude: 2)
    )

    let bounds = FGMGetCoordinateBoundsForPigeonLatLngBounds(pigeonBounds)

    let accuracy: Double = 0.001
    #expect(abs(bounds.southWest.latitude - 1) <= accuracy)
    #expect(abs(bounds.southWest.longitude - 2) <= accuracy)
    #expect(abs(bounds.northEast.latitude - 3) <= accuracy)
    #expect(abs(bounds.northEast.longitude - 4) <= accuracy)
  }

  @Test func mapViewTypeFromPigeonType() {
    #expect(GMSMapViewType.normal == FGMGetMapViewTypeForPigeonMapType(.normal))
    #expect(GMSMapViewType.satellite == FGMGetMapViewTypeForPigeonMapType(.satellite))
    #expect(GMSMapViewType.terrain == FGMGetMapViewTypeForPigeonMapType(.terrain))
    #expect(GMSMapViewType.hybrid == FGMGetMapViewTypeForPigeonMapType(.hybrid))
    #expect(GMSMapViewType.none == FGMGetMapViewTypeForPigeonMapType(.none))
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
    _ = FGMGetCameraUpdateForPigeonCameraUpdate(
      FGMPlatformCameraUpdate.make(withCameraUpdate: newPositionUpdate)
    )
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

    _ = FGMGetCameraUpdateForPigeonCameraUpdate(
      FGMPlatformCameraUpdate.make(withCameraUpdate: platformUpdate)
    )
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
    let bounds = FGMGetCoordinateBoundsForPigeonLatLngBounds(pigeonBounds)

    let padding: Double = 20
    let platformUpdate = FGMPlatformCameraUpdateNewLatLngBounds.make(
      with: FGMGetPigeonLatLngBoundsForCoordinateBounds(bounds),
      padding: padding
    )
    _ = FGMGetCameraUpdateForPigeonCameraUpdate(
      FGMPlatformCameraUpdate.make(withCameraUpdate: platformUpdate)
    )
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

    _ = FGMGetCameraUpdateForPigeonCameraUpdate(
      FGMPlatformCameraUpdate.make(withCameraUpdate: platformUpdate)
    )
    // GMSCameraUpdate is not inspectable, so this test just ensures that the codepath
    // doesn't throw. FGMGetCameraUpdateForPigeonCameraUpdate is simple enough that
    // injecting a wrapper would not meaningfully improve test coverage, since the non-test
    // implementation would be about as complex as the conversion function itself.
  }

  @Test func cameraUpdateFromScrollBy() {
    let x: Double = 1
    let y: Double = 2
    let platformUpdate = FGMPlatformCameraUpdateScrollBy.make(withDx: x, dy: y)

    _ = FGMGetCameraUpdateForPigeonCameraUpdate(
      FGMPlatformCameraUpdate.make(withCameraUpdate: platformUpdate)
    )
    // GMSCameraUpdate is not inspectable, so this test just ensures that the codepath
    // doesn't throw. FGMGetCameraUpdateForPigeonCameraUpdate is simple enough that
    // injecting a wrapper would not meaningfully improve test coverage, since the non-test
    // implementation would be about as complex as the conversion function itself.
  }

  @Test func cameraUpdateFromZoomBy() {
    let zoom: Double = 1
    let platformUpdateNoPoint = FGMPlatformCameraUpdateZoomBy.make(withAmount: zoom, focus: nil)

    _ = FGMGetCameraUpdateForPigeonCameraUpdate(
      FGMPlatformCameraUpdate.make(withCameraUpdate: platformUpdateNoPoint)
    )
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

    _ = FGMGetCameraUpdateForPigeonCameraUpdate(
      FGMPlatformCameraUpdate.make(withCameraUpdate: platformUpdate)
    )
    // GMSCameraUpdate is not inspectable, so this test just ensures that the codepath
    // doesn't throw. FGMGetCameraUpdateForPigeonCameraUpdate is simple enough that
    // injecting a wrapper would not meaningfully improve test coverage, since the non-test
    // implementation would be about as complex as the conversion function itself.
  }

  @Test func cameraUpdateFromZoomIn() {
    let platformUpdate = FGMPlatformCameraUpdateZoom.make(withOut: false)

    _ = FGMGetCameraUpdateForPigeonCameraUpdate(
      FGMPlatformCameraUpdate.make(withCameraUpdate: platformUpdate)
    )
    // GMSCameraUpdate is not inspectable, so this test just ensures that the codepath
    // doesn't throw. FGMGetCameraUpdateForPigeonCameraUpdate is simple enough that
    // injecting a wrapper would not meaningfully improve test coverage, since the non-test
    // implementation would be about as complex as the conversion function itself.
  }

  @Test func cameraUpdateFromZoomOut() {
    let platformUpdate = FGMPlatformCameraUpdateZoom.make(withOut: true)

    _ = FGMGetCameraUpdateForPigeonCameraUpdate(
      FGMPlatformCameraUpdate.make(withCameraUpdate: platformUpdate)
    )
    // GMSCameraUpdate is not inspectable, so this test just ensures that the codepath
    // doesn't throw. FGMGetCameraUpdateForPigeonCameraUpdate is simple enough that
    // injecting a wrapper would not meaningfully improve test coverage, since the non-test
    // implementation would be about as complex as the conversion function itself.
  }

  @Test func cameraUpdateFromZoomTo() {
    let zoom: Double = 1
    let platformUpdate = FGMPlatformCameraUpdateZoomTo.make(withZoom: zoom)

    _ = FGMGetCameraUpdateForPigeonCameraUpdate(
      FGMPlatformCameraUpdate.make(withCameraUpdate: platformUpdate)
    )
    // GMSCameraUpdate is not inspectable, so this test just ensures that the codepath
    // doesn't throw. FGMGetCameraUpdateForPigeonCameraUpdate is simple enough that
    // injecting a wrapper would not meaningfully improve test coverage, since the non-test
    // implementation would be about as complex as the conversion function itself.
  }

  @Test func strokeStylesFromPatterns() {
    let patterns = [
      FGMPlatformPatternItem.make(with: .gap, length: 1),
      FGMPlatformPatternItem.make(with: .dash, length: 1),
    ]
    let strokeColor = UIColor.red

    let patternStrokeStyle = FGMGetStrokeStylesFromPatterns(patterns, strokeColor)

    #expect(patternStrokeStyle.count == 2)
    // None of the parameters of `patternStrokeStyle` is observable, so we limit to testing
    // the length of this output array.
  }

  @Test func lengthsFromPatterns() {
    let gapLength: Double = 10
    let dashLength: Double = 6.4
    let patterns = [
      FGMPlatformPatternItem.make(with: .gap, length: gapLength as NSNumber),
      FGMPlatformPatternItem.make(with: .dash, length: dashLength as NSNumber),
    ]

    let spanLengths = FGMGetSpanLengthsFromPatterns(patterns)

    #expect(spanLengths.count == 2)

    let firstSpanLength = spanLengths[0]
    let secondSpanLength = spanLengths[1]

    #expect(firstSpanLength.doubleValue == gapLength)
    #expect(secondSpanLength.doubleValue == dashLength)
  }

  @Test func weightedDataFromPlatformWeightedData() {
    let intensity1: Double = 3.0
    let intensity2: Double = 6.0
    let data = [
      FGMPlatformWeightedLatLng.make(
        withPoint: FGMPlatformLatLng.make(withLatitude: 10, longitude: 20),
        weight: intensity1
      ),
      FGMPlatformWeightedLatLng.make(
        withPoint: FGMPlatformLatLng.make(withLatitude: 30, longitude: 40),
        weight: intensity2
      ),
    ]

    let weightedData = FGMGetWeightedDataForPigeonWeightedData(data)
    #expect(Double(weightedData[0].intensity) == intensity1)
    #expect(Double(weightedData[1].intensity) == intensity2)
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

    let gradient = FGMGetGradientForPigeonHeatmapGradient(platformGradient)
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    gradient.colors[0].getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    let accuracy: Double = 0.001
    #expect(abs(Double(red) - platformRed) <= accuracy)
    #expect(abs(Double(green) - platformGreen) <= accuracy)
    #expect(abs(Double(blue) - platformBlue) <= accuracy)
    #expect(abs(Double(alpha) - platformAlpha) <= accuracy)
    #expect(abs(gradient.startPoints[0].doubleValue - startPoint) <= accuracy)
    #expect(gradient.mapSize == UInt(colorMapSize))
  }
}
