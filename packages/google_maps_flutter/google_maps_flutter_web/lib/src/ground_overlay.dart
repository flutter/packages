// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of '../google_maps_flutter_web.dart';

/// This wraps a [GroundOverlay] in a [gmaps.MapType].
class GroundOverlayController {
  /// Creates a [GroundOverlayController] that wraps a
  /// [gmaps.GroundOverlay] object.
  GroundOverlayController({
    required gmaps.GroundOverlay groundOverlay,
    required VoidCallback onTap,
  }) : _groundOverlay = groundOverlay {
    groundOverlay.onClick.listen((gmaps.MapMouseEvent event) {
      onTap.call();
    });
  }

  /// The [GroundOverlay] providing data for this controller.
  gmaps.GroundOverlay? get groundOverlay => _groundOverlay;
  gmaps.GroundOverlay? _groundOverlay;

  /// Removes the [GroundOverlay] from the map.
  void remove() {
    if (_groundOverlay != null) {
      _groundOverlay!.map = null;
      _groundOverlay = null;
    }
  }
}
