// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of '../google_maps_flutter_web.dart';

/// The `MarkerController` class wraps a [gmaps.AdvancedMarkerElement]
/// or [gmaps.Marker], how it handles events, and its associated (optional)
/// [gmaps.InfoWindow] widget.
class MarkerController<T, O> {
  /// Creates a `MarkerController`, which wraps a [gmaps.AdvancedMarkerElement]
  /// or [gmaps.Marker] object, its `onTap`/`onDrag` behavior, and its
  /// associated [gmaps.InfoWindow].
  MarkerController({
    required T marker,
    gmaps.InfoWindow? infoWindow,
    bool consumeTapEvents = false,
    LatLngCallback? onDragStart,
    LatLngCallback? onDrag,
    LatLngCallback? onDragEnd,
    VoidCallback? onTap,
    ClusterManagerId? clusterManagerId,
  })  : _marker = marker,
        _infoWindow = infoWindow,
        _consumeTapEvents = consumeTapEvents,
        _clusterManagerId = clusterManagerId {
    _doOnMarkerType(
      marker: marker,
      legacy: (gmaps.Marker marker) {
        _initializeMarkerListener(
          marker: marker,
          onDragStart: onDragStart,
          onDrag: onDrag,
          onDragEnd: onDragEnd,
          onTap: onTap,
        );
      },
      advanced: (gmaps.AdvancedMarkerElement marker) {
        _initializeAdvancedMarkerElementListener(
          marker: marker,
          onDragStart: onDragStart,
          onDrag: onDrag,
          onDragEnd: onDragEnd,
          onTap: onTap,
        );
      },
    );
  }

  T? _marker;

  final bool _consumeTapEvents;

  final ClusterManagerId? _clusterManagerId;

  final gmaps.InfoWindow? _infoWindow;

  bool _infoWindowShown = false;

  /// Returns `true` if this Controller will use its own `onTap` handler to consume events.
  bool get consumeTapEvents => _consumeTapEvents;

  /// Returns `true` if the [gmaps.InfoWindow] associated to this marker is being shown.
  bool get infoWindowShown => _infoWindowShown;

  /// Returns [ClusterManagerId] if marker belongs to cluster.
  ClusterManagerId? get clusterManagerId => _clusterManagerId;

  /// Returns the marker associated to this controller.
  T? get marker => _marker;

  /// Returns the [gmaps.InfoWindow] associated to the marker.
  @visibleForTesting
  gmaps.InfoWindow? get infoWindow => _infoWindow;

  /// Updates the options of the wrapped marker object.
  ///
  /// This cannot be called after [remove].
  void update(
    O options, {
    HTMLElement? newInfoWindowContent,
  }) {
    assert(_marker != null, 'Cannot `update` Marker after calling `remove`.');

    _doOnMarkerType(
      marker: _marker,
      legacy: (gmaps.Marker marker) {
        marker.options = options as gmaps.MarkerOptions;
      },
      advanced: (gmaps.AdvancedMarkerElement marker) {
        options as gmaps.AdvancedMarkerElementOptions;
        final gmaps.AdvancedMarkerElement marker =
            _marker! as gmaps.AdvancedMarkerElement;
        marker.collisionBehavior = options.collisionBehavior;
        marker.content = options.content;
        marker.gmpClickable = options.gmpClickable;
        marker.gmpDraggable = options.gmpDraggable;
        marker.position = options.position;
        marker.title = options.title ?? '';
        marker.zIndex = options.zIndex;
      },
    );

    if (_infoWindow != null && newInfoWindowContent != null) {
      _infoWindow.content = newInfoWindowContent;
    }
  }

  /// Disposes of the currently wrapped marker object.
  void remove() {
    if (_marker != null) {
      _infoWindowShown = false;

      _doOnMarkerType(
        marker: marker,
        legacy: (gmaps.Marker marker) => marker.map = null,
        advanced: (gmaps.AdvancedMarkerElement marker) {
          marker.remove();
          marker.map = null;
        },
      );

      _marker = null;
    }
  }

  /// Hide the associated [gmaps.InfoWindow].
  ///
  /// This cannot be called after [remove].
  void hideInfoWindow() {
    assert(_marker != null, 'Cannot `hideInfoWindow` on a `remove`d Marker.');
    if (_infoWindow != null) {
      _infoWindow.close();
      _infoWindowShown = false;
    }
  }

  /// Show the associated [gmaps.InfoWindow].
  ///
  /// This cannot be called after [remove].
  void showInfoWindow() {
    assert(_marker != null, 'Cannot `showInfoWindow` on a `remove`d Marker.');
    if (_infoWindow != null) {
      _doOnMarkerType(
        marker: _marker,
        legacy: (gmaps.Marker marker) {
          _infoWindow.open(marker.map, marker);
        },
        advanced: (gmaps.AdvancedMarkerElement marker) {
          _infoWindow.open(marker.map, marker);
        },
      );

      _infoWindowShown = true;
    }
  }

  void _initializeMarkerListener({
    required gmaps.Marker marker,
    required LatLngCallback? onDragStart,
    required LatLngCallback? onDrag,
    required LatLngCallback? onDragEnd,
    required VoidCallback? onTap,
  }) {
    if (onTap != null) {
      marker.onClick.listen((gmaps.MapMouseEvent event) {
        onTap.call();
      });
    }
    if (onDragStart != null) {
      marker.onDragstart.listen((gmaps.MapMouseEvent event) {
        marker.position = event.latLng;
        onDragStart.call(event.latLng ?? _nullGmapsLatLng);
      });
    }
    if (onDrag != null) {
      marker.onDrag.listen((gmaps.MapMouseEvent event) {
        marker.position = event.latLng;
        onDrag.call(event.latLng ?? _nullGmapsLatLng);
      });
    }
    if (onDragEnd != null) {
      marker.onDragend.listen((gmaps.MapMouseEvent event) {
        marker.position = event.latLng;
        onDragEnd.call(event.latLng ?? _nullGmapsLatLng);
      });
    }
  }

  void _initializeAdvancedMarkerElementListener({
    required gmaps.AdvancedMarkerElement marker,
    required LatLngCallback? onDragStart,
    required LatLngCallback? onDrag,
    required LatLngCallback? onDragEnd,
    required VoidCallback? onTap,
  }) {
    if (onTap != null) {
      marker.onClick.listen((gmaps.MapMouseEvent event) {
        onTap.call();
      });
    }
    if (onDragStart != null) {
      marker.onDragstart.listen((gmaps.MapMouseEvent event) {
        marker.position = event.latLng;
        onDragStart.call(event.latLng ?? _nullGmapsLatLng);
      });
    }
    if (onDrag != null) {
      marker.onDrag.listen((gmaps.MapMouseEvent event) {
        marker.position = event.latLng;
        onDrag.call(event.latLng ?? _nullGmapsLatLng);
      });
    }
    if (onDragEnd != null) {
      marker.onDragend.listen((gmaps.MapMouseEvent event) {
        marker.position = event.latLng;
        onDragEnd.call(event.latLng ?? _nullGmapsLatLng);
      });
    }
  }
}

/// Check marker type and call [legacy] or [advanced]
void _doOnMarkerType({
  required dynamic marker,
  required void Function(gmaps.Marker marker) legacy,
  required void Function(gmaps.AdvancedMarkerElement marker) advanced,
}) {
  final JSObject object = marker as JSObject;
  if (object.isA<gmaps.Marker>()) {
    legacy(marker as gmaps.Marker);
  } else if (object.isA<gmaps.AdvancedMarkerElement>()) {
    advanced(marker as gmaps.AdvancedMarkerElement);
  } else {
    throw ArgumentError(
      'Must be either a gmaps.Marker or a gmaps.AdvancedMarkerElement',
    );
  }
}

/// Check [marker] type and return result of [legacy] or [advanced] function
R getOnMarkerType<R>({
  required dynamic marker,
  required R Function(gmaps.Marker marker) legacy,
  required R Function(gmaps.AdvancedMarkerElement marker) advanced,
}) {
  final JSObject object = marker as JSObject;
  if (object.isA<gmaps.Marker>()) {
    return legacy(marker as gmaps.Marker);
  } else if (object.isA<gmaps.AdvancedMarkerElement>()) {
    return advanced(marker as gmaps.AdvancedMarkerElement);
  } else {
    throw ArgumentError(
      'Must be either a gmaps.Marker or a gmaps.AdvancedMarkerElement',
    );
  }
}
