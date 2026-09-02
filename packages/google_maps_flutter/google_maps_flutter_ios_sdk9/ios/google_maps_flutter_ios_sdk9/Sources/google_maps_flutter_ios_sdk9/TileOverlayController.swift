// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import GoogleMaps
import UIKit

/// Protocol for requesting tiles from the Dart side.
// TODO(stuartmorgan): Adjust this to match the Swift API once the Pigeon
// generation is switched to Swift.
protocol TileProviderDelegate: AnyObject {
  func tile(
    withOverlayIdentifier tileOverlayId: String,
    location: PlatformPoint,
    zoom: Int64,
    completion: @escaping (Result<PlatformTile, PigeonError>) -> Void
  )
}

/// Controller of a single tile overlay on the map.
class TileOverlayController {
  let layer: GMSTileLayer
  private weak var mapView: GMSMapView?

  init(tileOverlay: PlatformTileOverlay, tileLayer: GMSTileLayer, mapView: GMSMapView) {
    self.layer = tileLayer
    self.mapView = mapView
    TileOverlayController.update(tileLayer, from: tileOverlay, with: mapView)
  }

  func removeTileOverlay() {
    layer.map = nil
  }

  func clearTileCache() {
    layer.clearTileCache()
  }

  /// Updates the controller's tile overlay with the properties from a PlatformTileOverlay.
  ///
  /// Setting the tile overlay to visible will set its map to the controller's mapView.
  func update(from overlay: PlatformTileOverlay) {
    if let mapView = mapView {
      TileOverlayController.update(layer, from: overlay, with: mapView)
    }
  }

  /// Updates the given GMSTileLayer with the properties from a PlatformTileOverlay.
  ///
  /// Setting the tile overlay to visible will set its map to the given mapView.
  static func update(
    _ tileLayer: GMSTileLayer,
    from platformOverlay: PlatformTileOverlay,
    with mapView: GMSMapView
  ) {
    tileLayer.opacity = Float(1.0 - platformOverlay.transparency)
    tileLayer.zIndex = Int32(platformOverlay.zIndex)
    tileLayer.fadeIn = platformOverlay.fadeIn
    tileLayer.tileSize = Int(platformOverlay.tileSize)

    // This must be done last, to avoid visual flickers of default property values.
    tileLayer.map = platformOverlay.visible ? mapView : nil
  }
}

/// Custom tile layer that requests tiles through a TileProviderDelegate.
class TileProviderController: GMSTileLayer {
  let tileOverlayIdentifier: String
  private weak var tileProviderDelegate: TileProviderDelegate?

  init(
    tileOverlayIdentifier: String,
    tileProvider: TileProviderDelegate
  ) {
    self.tileOverlayIdentifier = tileOverlayIdentifier
    self.tileProviderDelegate = tileProvider
    super.init()
  }

  func handleResultTile(_ tile: UIImage?) -> UIImage? {
    guard let tile = tile, let imageRef = tile.cgImage else {
      return tile
    }
    let bitmapInfo = imageRef.bitmapInfo
    let isFloat = bitmapInfo.contains(.floatComponents)
    let bitsPerComponent = imageRef.bitsPerComponent

    // Engine uses f16 pixel format for wide gamut images.
    // If it is wide gamut, we want to downsample it.
    if isFloat && bitsPerComponent == 16 {
      let colorSpace = CGColorSpaceCreateDeviceRGB()
      if let context = CGContext(
        data: nil,
        width: Int(tile.size.width),
        height: Int(tile.size.height),
        bitsPerComponent: 8,
        bytesPerRow: 0,
        space: colorSpace,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
      ) {
        context.draw(imageRef, in: CGRect(origin: .zero, size: tile.size))
        if let image = context.makeImage() {
          return UIImage(cgImage: image)
        }
      }
    }
    return tile
  }

  override func requestTileFor(x: UInt, y: UInt, zoom: UInt, receiver: any GMSTileReceiver) {
    DispatchQueue.main.async { [weak self] in
      guard let self = self, let tileProviderDelegate = self.tileProviderDelegate else {
        receiver.receiveTileWith(x: x, y: y, zoom: zoom, image: kGMSTileLayerNoTile)
        return
      }
      tileProviderDelegate.tile(
        withOverlayIdentifier: self.tileOverlayIdentifier,
        location: PlatformPoint(x: Double(x), y: Double(y)),
        zoom: Int64(zoom)
      ) { [weak self] result in
        guard let self = self else {
          receiver.receiveTileWith(x: x, y: y, zoom: zoom, image: kGMSTileLayerNoTile)
          return
        }
        var tileImage = kGMSTileLayerNoTile
        switch result {
        case .success(let tile):
          if let data = tile.data?.data {
            tileImage = self.handleResultTile(UIImage(data: data)) ?? kGMSTileLayerNoTile
          }
        case .failure(let error):
          NSLog(
            "Can't get tile: errorCode = \(error.code), errorMessage = \(error.message ?? "nil"), details = \(error.details ?? "nil")"
          )
        }
        receiver.receiveTileWith(x: x, y: y, zoom: zoom, image: tileImage)
      }
    }
  }
}

/// Controller of multiple tile overlays on the map.
class TileOverlaysController {
  private var tileOverlayIdentifierToController: [String: TileOverlayController] = [:]
  private weak var tileProviderDelegate: TileProviderDelegate?
  private weak var mapView: GMSMapView?

  init(mapView: GMSMapView, tileProvider: TileProviderDelegate) {
    self.mapView = mapView
    self.tileProviderDelegate = tileProvider
  }

  func add(_ tileOverlaysToAdd: [PlatformTileOverlay]) {
    guard let mapView = mapView, let tileProviderDelegate = tileProviderDelegate else { return }
    for tileOverlay in tileOverlaysToAdd {
      let identifier = tileOverlay.tileOverlayId
      let tileProvider = TileProviderController(
        tileOverlayIdentifier: identifier,
        tileProvider: tileProviderDelegate
      )
      let controller = TileOverlayController(
        tileOverlay: tileOverlay,
        tileLayer: tileProvider,
        mapView: mapView
      )
      tileOverlayIdentifierToController[identifier] = controller
    }
  }

  func change(_ tileOverlaysToChange: [PlatformTileOverlay]) {
    for tileOverlay in tileOverlaysToChange {
      let identifier = tileOverlay.tileOverlayId
      tileOverlayIdentifierToController[identifier]?.update(from: tileOverlay)
    }
  }

  func removeTileOverlay(withIdentifiers identifiers: [String]) {
    for identifier in identifiers {
      if let controller = tileOverlayIdentifierToController[identifier] {
        controller.removeTileOverlay()
        tileOverlayIdentifierToController.removeValue(forKey: identifier)
      }
    }
  }

  func clearTileCache(withIdentifier identifier: String) {
    tileOverlayIdentifierToController[identifier]?.clearTileCache()
  }

  func tileOverlay(withIdentifier identifier: String) -> TileOverlayController? {
    return tileOverlayIdentifierToController[identifier]
  }
}
