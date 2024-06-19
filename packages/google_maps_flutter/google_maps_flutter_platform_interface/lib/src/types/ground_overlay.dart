// Copyright 2024 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

import 'package:flutter/foundation.dart' show immutable;

import 'types.dart';

/// Uniquely identifies a [GroundOverlay] among [GoogleMap] ground overlays.
@immutable
class GroundOverlayId extends MapsObjectId<GroundOverlay> {
  /// Creates an immutable identifier for a [GroundOverlay].
  const GroundOverlayId(super.value);
}

/// Ground overlays are image overlays that are tied to latitude/longitude coordinates.
///
/// They move when you drag or zoom the map.
///
/// A ground overlay is an image that is fixed to a map. Unlike markers,
/// ground overlays are oriented against the Earth's surface rather than the screen,
/// so rotating, tilting or zooming the map will change the orientation of the image.
/// Ground overlays are useful when you wish to fix a single image at one area on the map.
/// If you want to add extensive imagery that covers a large portion of the map,
/// you should consider a Tile overlay.
@immutable
class GroundOverlay implements MapsObject<GroundOverlay> {
  /// Creates an immutable representation of a [GroundOverlay] to draw on [GoogleMap].
  /// The following ground overlay positioning is allowed by the Google Maps Api
  /// 1. Using [height], [width] and [LatLng]
  /// 2. Using [width] and [LatLng]
  /// 3. Using [LatLngBounds]
  const GroundOverlay._({
    required this.groundOverlayId,
    this.clickable = false,
    this.position,
    this.zIndex = 0,
    this.onTap,
    this.visible = true,
    this.bitmap,
    this.width,
    this.height,
    this.bearing = 0.0,
    this.anchor = Offset.zero,
    this.opacity = 1.0,
    this.bounds,
  })  : assert(
            (height != null &&
                    width != null &&
                    position != null &&
                    bounds == null) ||
                (height == null &&
                    width == null &&
                    position == null &&
                    bounds != null) ||
                (height == null &&
                    width != null &&
                    position != null &&
                    bounds == null) ||
                (height == null &&
                    width == null &&
                    position == null &&
                    bounds == null),
            'Only one of the three types of positioning is allowed, please refer '
            'to the https://developers.google.com/maps/documentation/android-sdk/groundoverlay#add_an_overlay'),
        assert(0.0 <= opacity && opacity <= 1.0);

  /// Creates an immutable representation of a [GroundOverlay] to draw on [GoogleMap]
  /// using [LatLng] and [width]
  const GroundOverlay.fromPosition({
    required this.groundOverlayId,
    required LatLng this.position,
    required double this.width,
    this.clickable = false,
    this.zIndex = 0,
    this.onTap,
    this.visible = true,
    this.bitmap,
    this.height,
    this.bearing = 0.0,
    this.anchor = Offset.zero,
    this.opacity = 1.0,
  })  : bounds = null,
        assert(0.0 <= opacity && opacity <= 1.0);

  /// Creates an immutable representation of a [GroundOverlay] to draw on [GoogleMap]
  /// using [LatLngBounds]
  const GroundOverlay.fromBounds(
    this.bounds, {
    required this.groundOverlayId,
    this.anchor = Offset.zero,
    this.bearing = 0.0,
    this.bitmap,
    this.clickable = false,
    this.onTap,
    this.opacity = 1.0,
    this.visible = true,
    this.zIndex = 0,
  })  : assert(0.0 <= opacity && opacity <= 1.0),
        position = null,
        height = null,
        width = null;

  /// Uniquely identifies a [GroundOverlay].
  final GroundOverlayId groundOverlayId;

  @override
  GroundOverlayId get mapsId => groundOverlayId;

  /// Specifies whether the [GroundOverlay] is clickable.
  ///
  /// If this is false, [onTap] callback will not be triggered.
  final bool clickable;

  /// Geographical location of the center of the ground overlay.
  final LatLng? position;

  /// True if the ground overlay is visible.
  final bool visible;

  /// Specifies the ground overlay's zIndex, i.e., the order in which it will be drawn.
  ///
  /// Overlays are drawn in order of z-index, so that lower values means drawn
  /// earlier, and thus appearing to be closer to the surface of the Earth.
  final int zIndex;

  /// Callbacks to receive tap events for ground overlay placed on this map.
  final VoidCallback? onTap;

  /// A description of the bitmap used to draw the ground overlay image.
  final BitmapDescriptor? bitmap;

  /// Width of the ground overlay in meters
  final double? width;

  /// Height of the ground overlay in meters
  final double? height;

  /// The bearing of the ground overlay in degrees clockwise from north.
  ///
  /// The center of the rotation will be the image's anchor.
  /// This is optional and the default bearing is 0.
  final double bearing;

  /// The anchor aligns with the ground overlay's location.
  ///
  /// The anchor point is specified in 2D continuous space where (0,0), (1,0), (0,1) and (1,1)
  /// denote the top-left, top-right, bottom-left and bottom-right corners respectively.
  /// Default anchor is (0.5, 0.5).
  final Offset anchor;

  /// The transparency of the ground overlay. The default transparency is 0 (opaque).
  final double opacity;

  /// A latitude/longitude alignment of the ground overlay.
  final LatLngBounds? bounds;

  /// Creates a new [GroundOverlay] object whose values are the same as this instance,
  /// unless overwritten by the specified parameters.
  GroundOverlay copyWith({
    BitmapDescriptor? bitmapParam,
    Offset? anchorParam,
    int? zIndexParam,
    bool? visibleParam,
    bool? clickableParam,
    double? widthParam,
    double? heightParam,
    double? bearingParam,
    LatLng? positionParam,
    LatLngBounds? boundsParam,
    VoidCallback? onTapParam,
    double? opacityParam,
  }) {
    return GroundOverlay._(
      groundOverlayId: groundOverlayId,
      clickable: clickableParam ?? clickable,
      bitmap: bitmapParam ?? bitmap,
      opacity: opacityParam ?? opacity,
      position: positionParam ?? position,
      visible: visibleParam ?? visible,
      bearing: bearingParam ?? bearing,
      anchor: anchorParam ?? anchor,
      height: heightParam ?? height,
      zIndex: zIndexParam ?? zIndex,
      width: widthParam ?? width,
      onTap: onTapParam ?? onTap,
      bounds: boundsParam ?? bounds,
    );
  }

  /// Creates a new [GroundOverlay] object whose values are the same as this instance.
  @override
  GroundOverlay clone() => copyWith();

  /// Converts this object to something serializable in JSON.
  @override
  Object toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};

    void addIfPresent(String fieldName, dynamic value) {
      if (value != null) {
        json[fieldName] = value;
      }
    }

    addIfPresent('groundOverlayId', groundOverlayId.value);
    addIfPresent('clickable', clickable);
    addIfPresent('transparency', 1 - opacity);
    addIfPresent('bearing', bearing);
    addIfPresent('visible', visible);
    addIfPresent('zIndex', zIndex);
    addIfPresent('height', height);
    addIfPresent('anchor', _offsetToJson(anchor));
    addIfPresent('bounds', bounds?.toJson());
    addIfPresent('bitmap', bitmap?.toJson());
    addIfPresent('width', width);
    if (position != null) {
      json['position'] = _positionToJson();
    }
    return json;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    if (other.runtimeType != runtimeType) {
      return false;
    }

    if (other is! GroundOverlay) {
      return false;
    }

    final GroundOverlay typedOther = other;

    return groundOverlayId == typedOther.groundOverlayId &&
        bitmap == typedOther.bitmap &&
        clickable == typedOther.clickable &&
        opacity == typedOther.opacity &&
        position == typedOther.position &&
        bearing == typedOther.bearing &&
        visible == typedOther.visible &&
        height == typedOther.height &&
        zIndex == typedOther.zIndex &&
        bounds == typedOther.bounds &&
        anchor == typedOther.anchor &&
        width == typedOther.width &&
        onTap == typedOther.onTap;
  }

  @override
  int get hashCode => groundOverlayId.hashCode;

  dynamic _positionToJson() => position?.toJson();

  dynamic _offsetToJson(Offset offset) {
    return <dynamic>[offset.dx, offset.dy];
  }
}
