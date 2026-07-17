// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest
import GoogleMaps
@testable import google_maps_flutter_ios

class ConversionUtilsTests: XCTestCase {

  func testColorFromPlatformColor() {
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
    XCTAssertTrue(success)
    let accuracy: Double = 0.0001
    XCTAssertEqual(red, platformRed, accuracy: accuracy)
    XCTAssertEqual(green, platformGreen, accuracy: accuracy)
    XCTAssertEqual(blue, platformBlue, accuracy: accuracy)
    XCTAssertEqual(alpha, platformAlpha, accuracy: accuracy)
  }

  func testPlatformColorFromColor() {
    let red: Double = 1 / 255.0
    let green: Double = 2 / 255.0
    let blue: Double = 3 / 255.0
    let alpha: Double = 4 / 255.0
    let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
    let platformColor = FGMGetPigeonColorForColor(color)
    let accuracy: Double = 0.0001
    XCTAssertEqual(red, platformColor.red, accuracy: accuracy)
    XCTAssertEqual(green, platformColor.green, accuracy: accuracy)
    XCTAssertEqual(blue, platformColor.blue, accuracy: accuracy)
    XCTAssertEqual(alpha, platformColor.alpha, accuracy: accuracy)
  }

  func testPointsFromLatLongs() {
    let latlongs = [
      FGMPlatformLatLng.make(withLatitude: 1, longitude: 2),
      FGMPlatformLatLng.make(withLatitude: 3, longitude: 4),
    ]
    let locations = FGMGetPointsForPigeonLatLngs(latlongs)
    XCTAssertEqual(locations.count, 2)
    XCTAssertEqual(locations[0].coordinate.latitude, 1)
    XCTAssertEqual(locations[0].coordinate.longitude, 2)
    XCTAssertEqual(locations[1].coordinate.latitude, 3)
    XCTAssertEqual(locations[1].coordinate.longitude, 4)
  }

  func testHolesFromPointsArray() {
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
    XCTAssertEqual(holes.count, 2)
    XCTAssertEqual(holes[0][0].coordinate.latitude, 1)
    XCTAssertEqual(holes[0][0].coordinate.longitude, 2)
    XCTAssertEqual(holes[0][1].coordinate.latitude, 3)
    XCTAssertEqual(holes[0][1].coordinate.longitude, 4)
    XCTAssertEqual(holes[1][0].coordinate.latitude, 5)
    XCTAssertEqual(holes[1][0].coordinate.longitude, 6)
    XCTAssertEqual(holes[1][1].coordinate.latitude, 7)
    XCTAssertEqual(holes[1][1].coordinate.longitude, 8)
  }

  func testGetPigeonCameraPositionForPosition() {
    let position = GMSCameraPosition(
      target: CLLocationCoordinate2D(latitude: 1, longitude: 2),
      zoom: 2.0,
      bearing: 3.0,
      viewingAngle: 75.0
    )
    let pigeonPosition = FGMGetPigeonCameraPositionForPosition(position)
    XCTAssertEqual(pigeonPosition.target.latitude, position.target.latitude, accuracy: Double.ulpOfOne)
    XCTAssertEqual(pigeonPosition.target.longitude, position.target.longitude, accuracy: Double.ulpOfOne)
    XCTAssertEqual(Float(pigeonPosition.zoom), position.zoom, accuracy: Float.ulpOfOne)
    XCTAssertEqual(pigeonPosition.bearing, position.bearing, accuracy: Double.ulpOfOne)
    XCTAssertEqual(pigeonPosition.tilt, position.viewingAngle, accuracy: Double.ulpOfOne)
  }

  func testPigeonPointForGCPoint() {
    let point = CGPoint(x: 10, y: 20)
    let pigeonPoint = FGMGetPigeonPointForCGPoint(point)
    XCTAssertEqual(pigeonPoint.x, point.x, accuracy: Double.ulpOfOne)
    XCTAssertEqual(pigeonPoint.y, point.y, accuracy: Double.ulpOfOne)
  }

  func testPigeonLatLngBoundsForCoordinateBounds() {
    let bounds = GMSCoordinateBounds(
      coordinate: CLLocationCoordinate2D(latitude: 10, longitude: 20),
      coordinate: CLLocationCoordinate2D(latitude: 30, longitude: 40)
    )
    let pigeonBounds = FGMGetPigeonLatLngBoundsForCoordinateBounds(bounds)
    XCTAssertEqual(
      pigeonBounds.southwest.latitude,
      bounds.southWest.latitude,
      accuracy: Double.ulpOfOne
    )
    XCTAssertEqual(
      pigeonBounds.southwest.longitude,
      bounds.southWest.longitude,
      accuracy: Double.ulpOfOne
    )
    XCTAssertEqual(
      pigeonBounds.northeast.latitude,
      bounds.northEast.latitude,
      accuracy: Double.ulpOfOne
    )
    XCTAssertEqual(
      pigeonBounds.northeast.longitude,
      bounds.northEast.longitude,
      accuracy: Double.ulpOfOne
    )
  }

  func testGetCameraPostionForPigeonCameraPosition() {
    let pigeonCameraPosition = FGMPlatformCameraPosition.make(
      withBearing: 1.0,
      target: FGMPlatformLatLng.make(withLatitude: 2.0, longitude: 3.0),
      tilt: 4.0,
      zoom: 5.0
    )

    let cameraPosition = FGMGetCameraPositionForPigeonCameraPosition(pigeonCameraPosition)

    XCTAssertEqual(
      cameraPosition.target.latitude,
      pigeonCameraPosition.target.latitude,
      accuracy: Double.ulpOfOne
    )
    XCTAssertEqual(
      cameraPosition.target.longitude,
      pigeonCameraPosition.target.longitude,
      accuracy: Double.ulpOfOne
    )
    XCTAssertEqual(Double(cameraPosition.zoom), pigeonCameraPosition.zoom, accuracy: Double.ulpOfOne)
    XCTAssertEqual(cameraPosition.bearing, pigeonCameraPosition.bearing, accuracy: Double.ulpOfOne)
    XCTAssertEqual(cameraPosition.viewingAngle, pigeonCameraPosition.tilt, accuracy: Double.ulpOfOne)
  }

  func testCGPointForPigeonPoint() {
    let pigeonPoint = FGMPlatformPoint.makeWith(x: 1.0, y: 2.0)

    let point = FGMGetCGPointForPigeonPoint(pigeonPoint)

    XCTAssertEqual(pigeonPoint.x, Double(point.x), accuracy: Double.ulpOfOne)
    XCTAssertEqual(pigeonPoint.y, Double(point.y), accuracy: Double.ulpOfOne)
  }

  func testCoordinateBoundsFromLatLongs() {
    let pigeonBounds = FGMPlatformLatLngBounds.make(
      withNortheast: FGMPlatformLatLng.make(withLatitude: 3, longitude: 4),
      southwest: FGMPlatformLatLng.make(withLatitude: 1, longitude: 2)
    )

    let bounds = FGMGetCoordinateBoundsForPigeonLatLngBounds(pigeonBounds)

    let accuracy: Double = 0.001
    XCTAssertEqual(bounds.southWest.latitude, 1, accuracy: accuracy)
    XCTAssertEqual(bounds.southWest.longitude, 2, accuracy: accuracy)
    XCTAssertEqual(bounds.northEast.latitude, 3, accuracy: accuracy)
    XCTAssertEqual(bounds.northEast.longitude, 4, accuracy: accuracy)
  }

  func testMapViewTypeFromPigeonType() {
    XCTAssertEqual(GMSMapViewType.normal, FGMGetMapViewTypeForPigeonMapType(.normal))
    XCTAssertEqual(GMSMapViewType.satellite, FGMGetMapViewTypeForPigeonMapType(.satellite))
    XCTAssertEqual(GMSMapViewType.terrain, FGMGetMapViewTypeForPigeonMapType(.terrain))
    XCTAssertEqual(GMSMapViewType.hybrid, FGMGetMapViewTypeForPigeonMapType(.hybrid))
    XCTAssertEqual(GMSMapViewType.none, FGMGetMapViewTypeForPigeonMapType(.none))
  }

  func testCameraUpdateFromNewCameraPosition() {
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

  func testCameraUpdateFromNewLatLong() {
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

  func testCameraUpdateFromNewLatLngBounds() {
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

  func testCameraUpdateFromNewLatLngZoom() {
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

  func testCameraUpdateFromScrollBy() {
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

  func testCameraUpdateFromZoomBy() {
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

  func testCameraUpdateFromZoomByWithFocus() {
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

  func testCameraUpdateFromZoomIn() {
    let platformUpdate = FGMPlatformCameraUpdateZoom.make(withOut: false)

    _ = FGMGetCameraUpdateForPigeonCameraUpdate(
      FGMPlatformCameraUpdate.make(withCameraUpdate: platformUpdate)
    )
    // GMSCameraUpdate is not inspectable, so this test just ensures that the codepath
    // doesn't throw. FGMGetCameraUpdateForPigeonCameraUpdate is simple enough that
    // injecting a wrapper would not meaningfully improve test coverage, since the non-test
    // implementation would be about as complex as the conversion function itself.
  }

  func testCameraUpdateFromZoomOut() {
    let platformUpdate = FGMPlatformCameraUpdateZoom.make(withOut: true)

    _ = FGMGetCameraUpdateForPigeonCameraUpdate(
      FGMPlatformCameraUpdate.make(withCameraUpdate: platformUpdate)
    )
    // GMSCameraUpdate is not inspectable, so this test just ensures that the codepath
    // doesn't throw. FGMGetCameraUpdateForPigeonCameraUpdate is simple enough that
    // injecting a wrapper would not meaningfully improve test coverage, since the non-test
    // implementation would be about as complex as the conversion function itself.
  }

  func testCameraUpdateFromZoomTo() {
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

  func testStrokeStylesFromPatterns() {
    let patterns = [
      FGMPlatformPatternItem.make(with: .gap, length: 1),
      FGMPlatformPatternItem.make(with: .dash, length: 1),
    ]
    let strokeColor = UIColor.red

    let patternStrokeStyle = FGMGetStrokeStylesFromPatterns(patterns, strokeColor)

    XCTAssertEqual(patternStrokeStyle.count, 2)
    // None of the parameters of `patternStrokeStyle` is observable, so we limit to testing
    // the length of this output array.
  }

  func testLengthsFromPatterns() {
    let gapLength: Double = 10
    let dashLength: Double = 6.4
    let patterns = [
      FGMPlatformPatternItem.make(with: .gap, length: gapLength as NSNumber),
      FGMPlatformPatternItem.make(with: .dash, length: dashLength as NSNumber),
    ]

    let spanLengths = FGMGetSpanLengthsFromPatterns(patterns)

    XCTAssertEqual(spanLengths.count, 2)

    let firstSpanLength = spanLengths[0]
    let secondSpanLength = spanLengths[1]

    XCTAssertEqual(firstSpanLength.doubleValue, gapLength)
    XCTAssertEqual(secondSpanLength.doubleValue, dashLength)
  }

  func testWeightedDataFromPlatformWeightedData() {
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
    XCTAssertEqual(Double(weightedData[0].intensity), intensity1)
    XCTAssertEqual(Double(weightedData[1].intensity), intensity2)
  }

  func testGradientFromPlatformGradient() {
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
    XCTAssertEqual(red, CGFloat(platformRed), accuracy: accuracy)
    XCTAssertEqual(green, CGFloat(platformGreen), accuracy: accuracy)
    XCTAssertEqual(blue, CGFloat(platformBlue), accuracy: accuracy)
    XCTAssertEqual(alpha, CGFloat(platformAlpha), accuracy: accuracy)
    XCTAssertEqual(gradient.startPoints[0].doubleValue, startPoint, accuracy: accuracy)
    XCTAssertEqual(gradient.mapSize, UInt(colorMapSize))
  }
}
