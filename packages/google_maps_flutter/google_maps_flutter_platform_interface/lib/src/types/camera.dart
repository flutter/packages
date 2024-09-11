// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' show Offset;

import 'package:flutter/foundation.dart';

import 'types.dart';

/// The position of the map "camera", the view point from which the world is shown in the map view.
///
/// Aggregates the camera's [target] geographical location, its [zoom] level,
/// [tilt] angle, and [bearing].
@immutable
class CameraPosition {
  /// Creates a immutable representation of the [GoogleMap] camera.
  ///
  /// [AssertionError] is thrown if [bearing], [target], [tilt], or [zoom] are
  /// null.
  const CameraPosition({
    this.bearing = 0.0,
    required this.target,
    this.tilt = 0.0,
    this.zoom = 0.0,
  });

  /// The camera's bearing in degrees, measured clockwise from north.
  ///
  /// A bearing of 0.0, the default, means the camera points north.
  /// A bearing of 90.0 means the camera points east.
  final double bearing;

  /// The geographical location that the camera is pointing at.
  final LatLng target;

  /// The angle, in degrees, of the camera angle from the nadir.
  ///
  /// A tilt of 0.0, the default and minimum supported value, means the camera
  /// is directly facing the Earth.
  ///
  /// The maximum tilt value depends on the current zoom level. Values beyond
  /// the supported range are allowed, but on applying them to a map they will
  /// be silently clamped to the supported range.
  final double tilt;

  /// The zoom level of the camera.
  ///
  /// A zoom of 0.0, the default, means the screen width of the world is 256.
  /// Adding 1.0 to the zoom level doubles the screen width of the map. So at
  /// zoom level 3.0, the screen width of the world is 2³x256=2048.
  ///
  /// Larger zoom levels thus means the camera is placed closer to the surface
  /// of the Earth, revealing more detail in a narrower geographical region.
  ///
  /// The supported zoom level range depends on the map data and device. Values
  /// beyond the supported range are allowed, but on applying them to a map they
  /// will be silently clamped to the supported range.
  final double zoom;

  /// Serializes [CameraPosition].
  ///
  /// Mainly for internal use when calling [CameraUpdate.newCameraPosition].
  Object toMap() => <String, Object>{
        'bearing': bearing,
        'target': target.toJson(),
        'tilt': tilt,
        'zoom': zoom,
      };

  /// Deserializes [CameraPosition] from a map.
  ///
  /// Mainly for internal use.
  static CameraPosition? fromMap(Object? json) {
    if (json == null || json is! Map<dynamic, dynamic>) {
      return null;
    }
    final LatLng? target = LatLng.fromJson(json['target']);
    if (target == null) {
      return null;
    }
    return CameraPosition(
      bearing: json['bearing'] as double,
      target: target,
      tilt: json['tilt'] as double,
      zoom: json['zoom'] as double,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (runtimeType != other.runtimeType) {
      return false;
    }
    return other is CameraPosition &&
        bearing == other.bearing &&
        target == other.target &&
        tilt == other.tilt &&
        zoom == other.zoom;
  }

  @override
  int get hashCode => Object.hash(bearing, target, tilt, zoom);

  @override
  String toString() =>
      'CameraPosition(bearing: $bearing, target: $target, tilt: $tilt, zoom: $zoom)';
}

/// Indicates which type of camera update this instance represents.
enum CameraUpdateType {
  /// New position for camera
  newCameraPosition,

  /// New coordinates for camera
  newLatLng,

  /// New coordinates bounding box
  newLatLngBounds,

  /// New coordinate with zoom level
  newLatLngZoom,

  /// Move by a scroll delta
  scrollBy,

  /// Zoom by a relative change
  zoomBy,

  /// Zoom to an absolute level
  zoomTo,

  /// Zoom in
  zoomIn,

  /// Zoom out
  zoomOut,
}

/// Defines a camera move, supporting absolute moves as well as moves relative
/// the current position.
abstract class CameraUpdate {
  const CameraUpdate._(this.updateType);

  /// Indicates which type of camera update this instance represents.
  final CameraUpdateType updateType;

  /// Returns a camera update that moves the camera to the specified position.
  static CameraUpdate newCameraPosition(CameraPosition cameraPosition) {
    return CameraUpdateNewCameraPosition(cameraPosition);
  }

  /// Returns a camera update that moves the camera target to the specified
  /// geographical location.
  static CameraUpdate newLatLng(LatLng latLng) {
    return CameraUpdateNewLatLng(latLng);
  }

  /// Returns a camera update that transforms the camera so that the specified
  /// geographical bounding box is centered in the map view at the greatest
  /// possible zoom level. A non-zero [padding] insets the bounding box from the
  /// map view's edges. The camera's new tilt and bearing will both be 0.0.
  static CameraUpdate newLatLngBounds(LatLngBounds bounds, double padding) {
    return CameraUpdateNewLatLngBounds(bounds, padding);
  }

  /// Returns a camera update that moves the camera target to the specified
  /// geographical location and zoom level.
  static CameraUpdate newLatLngZoom(LatLng latLng, double zoom) {
    return CameraUpdateNewLatLngZoom(latLng, zoom);
  }

  /// Returns a camera update that moves the camera target the specified screen
  /// distance.
  ///
  /// For a camera with bearing 0.0 (pointing north), scrolling by 50,75 moves
  /// the camera's target to a geographical location that is 50 to the east and
  /// 75 to the south of the current location, measured in screen coordinates.
  static CameraUpdate scrollBy(double dx, double dy) {
    return CameraUpdateScrollBy(dx, dy);
  }

  /// Returns a camera update that modifies the camera zoom level by the
  /// specified amount. The optional [focus] is a screen point whose underlying
  /// geographical location should be invariant, if possible, by the movement.
  static CameraUpdate zoomBy(double amount, [Offset? focus]) {
    return CameraUpdateZoomBy(amount, focus);
  }

  /// Returns a camera update that zooms the camera in, bringing the camera
  /// closer to the surface of the Earth.
  ///
  /// Equivalent to the result of calling `zoomBy(1.0)`.
  static CameraUpdate zoomIn() {
    return const CameraUpdateZoomIn();
  }

  /// Returns a camera update that zooms the camera out, bringing the camera
  /// further away from the surface of the Earth.
  ///
  /// Equivalent to the result of calling `zoomBy(-1.0)`.
  static CameraUpdate zoomOut() {
    return const CameraUpdateZoomOut();
  }

  /// Returns a camera update that sets the camera zoom level.
  static CameraUpdate zoomTo(double zoom) {
    return CameraUpdateZoomTo(zoom);
  }

  /// Converts this object to something serializable in JSON.
  Object toJson();
}

/// Defines a camera move to a new position.
class CameraUpdateNewCameraPosition extends CameraUpdate {
  /// Creates a camera move.
  const CameraUpdateNewCameraPosition(this.cameraPosition)
      : super._(CameraUpdateType.newCameraPosition);

  /// The new camera position.
  final CameraPosition cameraPosition;
  @override
  Object toJson() => <Object>['newCameraPosition', cameraPosition.toMap()];
}

/// Defines a camera move to a latitude and longitude.
class CameraUpdateNewLatLng extends CameraUpdate {
  /// Creates a camera move to latitude and longitude.
  const CameraUpdateNewLatLng(this.latLng)
      : super._(CameraUpdateType.newLatLng);

  /// New latitude and longitude of the camera..
  final LatLng latLng;
  @override
  Object toJson() => <Object>['newLatLng', latLng.toJson()];
}

/// Defines a camera move to a new bounding latitude and longitude range.
class CameraUpdateNewLatLngBounds extends CameraUpdate {
  /// Creates a camera move to a bounding range.
  const CameraUpdateNewLatLngBounds(this.bounds, this.padding)
      : super._(CameraUpdateType.newLatLngBounds);

  /// The northeast and southwest bounding coordinates.
  final LatLngBounds bounds;

  /// The amount of padding by which the view is inset.
  final double padding;
  @override
  Object toJson() => <Object>['newLatLngBounds', bounds.toJson(), padding];
}

/// Defines a camera move to new coordinates with a zoom level.
class CameraUpdateNewLatLngZoom extends CameraUpdate {
  /// Creates a camera move with coordinates and zoom level.
  const CameraUpdateNewLatLngZoom(this.latLng, this.zoom)
      : super._(CameraUpdateType.newLatLngZoom);

  /// New coordinates of the camera.
  final LatLng latLng;

  /// New zoom level of the camera.
  final double zoom;
  @override
  Object toJson() => <Object>['newLatLngZoom', latLng.toJson(), zoom];
}

/// Defines a camera scroll by a certain delta.
class CameraUpdateScrollBy extends CameraUpdate {
  /// Creates a camera scroll.
  const CameraUpdateScrollBy(this.dx, this.dy)
      : super._(CameraUpdateType.scrollBy);

  /// Scroll delta x.
  final double dx;

  /// Scroll delta y.
  final double dy;
  @override
  Object toJson() => <Object>['scrollBy', dx, dy];
}

/// Defines a relative camera zoom.
class CameraUpdateZoomBy extends CameraUpdate {
  /// Creates a relative camera zoom.
  const CameraUpdateZoomBy(this.amount, [this.focus])
      : super._(CameraUpdateType.zoomBy);

  /// Change in camera zoom amount.
  final double amount;

  /// Optional point around which the zoom is focused.
  final Offset? focus;
  @override
  Object toJson() => (focus == null)
      ? <Object>['zoomBy', amount]
      : <Object>[
          'zoomBy',
          amount,
          <double>[focus!.dx, focus!.dy]
        ];
}

/// Defines a camera zoom in.
class CameraUpdateZoomIn extends CameraUpdate {
  /// Zooms in the camera.
  const CameraUpdateZoomIn() : super._(CameraUpdateType.zoomIn);
  @override
  Object toJson() => <Object>['zoomIn'];
}

/// Defines a camera zoom out.
class CameraUpdateZoomOut extends CameraUpdate {
  /// Zooms out the camera.
  const CameraUpdateZoomOut() : super._(CameraUpdateType.zoomOut);
  @override
  Object toJson() => <Object>['zoomOut'];
}

/// Defines a camera zoom to an absolute zoom.
class CameraUpdateZoomTo extends CameraUpdate {
  /// Creates a zoom to an absolute zoom level.
  const CameraUpdateZoomTo(this.zoom) : super._(CameraUpdateType.zoomTo);

  /// New zoom level of the camera.
  final double zoom;
  @override
  Object toJson() => <Object>['zoomTo', zoom];
}
