// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of '../google_maps_flutter_web.dart';

/// The `PolylineController` class wraps a [gmaps.Polyline] and its `onTap` behavior.
class PolylineController {
  /// Creates a `PolylineController` that wraps a [gmaps.Polyline] object and its `onTap` behavior.
  PolylineController({
    required gmaps.Polyline polyline,
    bool consumeTapEvents = false,
    VoidCallback? onTap,
    void Function(List<gmaps.LatLng> path)? onEdited,
  }) : _polyline = polyline,
       _consumeTapEvents = consumeTapEvents,
       _onEdited = onEdited {
    if (onTap != null) {
      _subscriptions.add(
        polyline.onClick.listen((gmaps.PolyMouseEvent event) {
          onTap.call();
        }),
      );
    }
    _listenToPathEdits();
  }

  gmaps.Polyline? _polyline;

  final bool _consumeTapEvents;

  final void Function(List<gmaps.LatLng> path)? _onEdited;

  final List<StreamSubscription<dynamic>> _subscriptions = <StreamSubscription<dynamic>>[];

  // Subscriptions to the path's edit events. Recreated whenever the underlying
  // path is replaced (e.g. after [update]).
  final List<StreamSubscription<dynamic>> _editSubscriptions = <StreamSubscription<dynamic>>[];

  /// Returns the wrapped [gmaps.Polyline]. Only used for testing.
  @visibleForTesting
  gmaps.Polyline? get line => _polyline;

  /// Returns `true` if this Controller will use its own `onTap` handler to consume events.
  bool get consumeTapEvents => _consumeTapEvents;

  List<gmaps.LatLng> _readPath(gmaps.Polyline polyline) {
    final gmaps.MVCArray<gmaps.LatLng> path = polyline.path;
    final points = <gmaps.LatLng>[];
    for (var i = 0; i < path.length.toInt(); i++) {
      points.add(path.getAt(i));
    }
    return points;
  }

  // (Re)subscribes to the wrapped polyline's path edit events.
  //
  // Setting options on a [gmaps.Polyline] replaces its path, so this must run
  // again after every [update] to keep listening to the current path. The edit
  // listeners are always attached; [emitCurrentPath] only propagates events
  // while the polyline is editable, so programmatic updates to a non-editable
  // polyline are ignored.
  void _listenToPathEdits() {
    for (final StreamSubscription<dynamic> sub in _editSubscriptions) {
      sub.cancel();
    }
    _editSubscriptions.clear();

    final gmaps.Polyline? polyline = _polyline;
    if (_onEdited == null || polyline == null) {
      return;
    }

    void emitCurrentPath() {
      final editable = polyline.get('editable') as JSBoolean?;
      if (editable == null || !editable.toDart) {
        return;
      }
      _onEdited(_readPath(polyline));
    }

    _editSubscriptions.add(polyline.path.onSetAt.listen((_) => emitCurrentPath()));
    _editSubscriptions.add(polyline.path.onInsertAt.listen((_) => emitCurrentPath()));
    _editSubscriptions.add(polyline.path.onRemoveAt.listen((_) => emitCurrentPath()));
  }

  /// Updates the options of the wrapped [gmaps.Polyline] object.
  ///
  /// This cannot be called after [remove].
  void update(gmaps.PolylineOptions options) {
    assert(_polyline != null, 'Cannot `update` Polyline after calling `remove`.');
    _polyline!.options = options;
    // Setting options replaces the native path, so re-subscribe to the new one.
    _listenToPathEdits();
  }

  /// Disposes of the currently wrapped [gmaps.Polyline].
  void remove() {
    if (_polyline != null) {
      _polyline!.visible = false;
      _polyline!.map = null;
      _polyline = null;
      for (final StreamSubscription<dynamic> sub in _subscriptions) {
        sub.cancel();
      }
      _subscriptions.clear();
      for (final StreamSubscription<dynamic> sub in _editSubscriptions) {
        sub.cancel();
      }
      _editSubscriptions.clear();
    }
  }
}
