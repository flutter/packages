// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of google_maps_flutter_web;

/// This wraps a [TileOverlay] in a [gmaps.MapType].
class TileOverlayController {
  /// Creates a `TileOverlayController` that wraps a [TileOverlay] object and its corresponding [gmaps.MapType].
  TileOverlayController({
    required TileOverlay tileOverlay,
  }) {
    update(tileOverlay);
  }

  /// The size in pixels of the (square) tiles passed to the Maps SDK.
  ///
  /// Even though the web supports any size, and rectangular tiles, for
  /// for consistency with mobile, this is not configurable on the web.
  /// (Both Android and iOS prefer square 256px tiles @ 1x DPI)
  ///
  /// For higher DPI screens, the Tile that is actually returned can be larger
  /// than 256px square.
  static const int logicalTileSize = 256;

  /// Updates the [gmaps.MapType] and cached properties with an updated
  /// [TileOverlay].
  void update(TileOverlay tileOverlay) {
    _tileOverlay = tileOverlay;
    _gmMapType = gmaps.MapType()
      ..tileSize = gmaps.Size(logicalTileSize, logicalTileSize)
      ..getTile = _getTile;
  }

  /// Renders a Tile for gmaps; delegating to the configured [TileProvider].
  HtmlElement? _getTile(
    gmaps.Point? tileCoord,
    num? zoom,
    Document? ownerDocument,
  ) {
    if (_tileOverlay.tileProvider == null) {
      return null;
    }

    final ImageElement img =
        ownerDocument!.createElement('img') as ImageElement;
    img.width = img.height = logicalTileSize;
    img.hidden = true;
    img.setAttribute('decoding', 'async');

    _tileOverlay.tileProvider!
        .getTile(tileCoord!.x!.toInt(), tileCoord.y!.toInt(), zoom?.toInt())
        .then((Tile tile) {
      if (tile.data == null) {
        return;
      }
      // Using img lets us take advantage of native decoding.
      final String src = Url.createObjectUrl(Blob(<Object?>[tile.data]));
      img.src = src;
      img.addEventListener('load', (_) {
        img.hidden = false;
        Url.revokeObjectUrl(src);
      });
    });

    return img;
  }

  /// The [gmaps.MapType] produced by this controller.
  gmaps.MapType get gmMapType => _gmMapType;
  late gmaps.MapType _gmMapType;

  /// The [TileOverlay] providing data for this controller.
  TileOverlay get tileOverlay => _tileOverlay;
  late TileOverlay _tileOverlay;
}
