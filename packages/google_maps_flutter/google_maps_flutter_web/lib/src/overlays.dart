// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of '../google_maps_flutter_web.dart';

/// This class manages all the [TileOverlayController]s associated to a [GoogleMapController].
class TileOverlaysController extends GeometryController {
  final Map<TileOverlayId, TileOverlayController> _tileOverlays =
      <TileOverlayId, TileOverlayController>{};
  final List<TileOverlayController> _visibleTileOverlays =
      <TileOverlayController>[];

  // Inserts `tileOverlayController` into the list of visible overlays, and the current [googleMap].
  //
  // After insertion, the arrays stay sorted by ascending z-index.
  void _insertZSorted(TileOverlayController tileOverlayController) {
    final int index = _visibleTileOverlays.lowerBoundBy<num>(
        tileOverlayController,
        (TileOverlayController c) => c.tileOverlay.zIndex);

    googleMap.overlayMapTypes!.insertAt(index, tileOverlayController.gmMapType);
    _visibleTileOverlays.insert(index, tileOverlayController);
  }

  // Removes `tileOverlayController` from the list of visible overlays.
  void _remove(TileOverlayController tileOverlayController) {
    final int index = _visibleTileOverlays.indexOf(tileOverlayController);
    if (index < 0) {
      return;
    }

    googleMap.overlayMapTypes!.removeAt(index);
    _visibleTileOverlays.removeAt(index);
  }

  /// Adds new [TileOverlay]s to this controller.
  ///
  /// Wraps the [TileOverlay]s in corresponding [TileOverlayController]s.
  void addTileOverlays(Set<TileOverlay> tileOverlaysToAdd) {
    tileOverlaysToAdd.forEach(_addTileOverlay);
  }

  void _addTileOverlay(TileOverlay tileOverlay) {
    final TileOverlayController controller = TileOverlayController(
      tileOverlay: tileOverlay,
    );
    _tileOverlays[tileOverlay.tileOverlayId] = controller;

    if (tileOverlay.visible) {
      _insertZSorted(controller);
    }
  }

  /// Updates [TileOverlay]s with new options.
  void changeTileOverlays(Set<TileOverlay> tileOverlays) {
    tileOverlays.forEach(_changeTileOverlay);
  }

  void _changeTileOverlay(TileOverlay tileOverlay) {
    final TileOverlayController controller =
        _tileOverlays[tileOverlay.tileOverlayId]!;

    final bool wasVisible = controller.tileOverlay.visible;
    final bool isVisible = tileOverlay.visible;

    controller.update(tileOverlay);

    if (wasVisible) {
      _remove(controller);
    }
    if (isVisible) {
      _insertZSorted(controller);
    }
  }

  /// Removes the tile overlays associated with the given [TileOverlayId]s.
  void removeTileOverlays(Set<TileOverlayId> tileOverlayIds) {
    tileOverlayIds.forEach(_removeTileOverlay);
  }

  void _removeTileOverlay(TileOverlayId tileOverlayId) {
    final TileOverlayController? controller =
        _tileOverlays.remove(tileOverlayId);
    if (controller != null) {
      _remove(controller);
    }
  }

  /// Invalidates the tile overlay associated with the given [TileOverlayId].
  void clearTileCache(TileOverlayId tileOverlayId) {
    final TileOverlayController? controller = _tileOverlays[tileOverlayId];
    if (controller != null && controller.tileOverlay.visible) {
      final int i = _visibleTileOverlays.indexOf(controller);
      // This causes the map to reload the overlay.
      googleMap.overlayMapTypes!.setAt(i, controller.gmMapType);
    }
  }
}
