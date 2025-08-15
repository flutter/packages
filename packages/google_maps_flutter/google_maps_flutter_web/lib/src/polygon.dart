// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of '../google_maps_flutter_web.dart';

/// The `PolygonController` class wraps a [gmaps.Polygon] and its `onTap` behavior.
class PolygonController {
  /// Creates a `PolygonController` that wraps a [gmaps.Polygon] object and its `onTap` behavior.
  PolygonController({
    required gmaps.Polygon polygon,
    bool consumeTapEvents = false,
    VoidCallback? onTap,
  })  : _polygon = polygon,
        _consumeTapEvents = consumeTapEvents {
    if (onTap != null) {
      polygon.onClick.listen((gmaps.PolyMouseEvent event) {
        onTap.call();
      });
    }
  }

  gmaps.Polygon? _polygon;

  final bool _consumeTapEvents;

  /// Returns the wrapped [gmaps.Polygon]. Only used for testing.
  @visibleForTesting
  gmaps.Polygon? get polygon => _polygon;

  /// Returns `true` if this Controller will use its own `onTap` handler to consume events.
  bool get consumeTapEvents => _consumeTapEvents;

  /// Updates the options of the wrapped [gmaps.Polygon] object.
  ///
  /// This cannot be called after [remove].
  void update(gmaps.PolygonOptions options) {
    assert(_polygon != null, 'Cannot `update` Polygon after calling `remove`.');
    _polygon!.options = options;
  }

  /// Disposes of the currently wrapped [gmaps.Polygon].
  void remove() {
    if (_polygon != null) {
      _polygon!.visible = false;
      _polygon!.map = null;
      _polygon = null;
    }
  }
}
