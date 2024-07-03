// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart' show VoidCallback, immutable;
import 'package:flutter/material.dart' show Offset;

import 'types.dart';

/// Uniquely identifies a [GroundOverlay] among [GoogleMap] ground overlays.
///
/// This does not have to be globally unique, only unique among the list.
@immutable
class GroundOverlayId extends MapsObjectId<GroundOverlay> {
  /// Creates an immutable identifier for a [GroundOverlay].
  const GroundOverlayId(super.value);
}

/// Draws a Ground Overlay through geographical locations on the map.
@immutable
class GroundOverlay implements MapsObject<GroundOverlay> {
  /// Creates an immutable representation of a [GroundOverlay] to draw on [GoogleMap].
  /// The following ground overlay positioning is allowed by the Google Maps API
  /// 1. Using [height], [width] and [LatLng]
  /// 2. Using [width], [width]
  /// 3. Using [LatLngBounds]
  ///
  /// [GroundOverlay] with [position] does not render on iOS.
  const GroundOverlay({
    required this.groundOverlayId,
    this.consumeTapEvents = false,
    this.position,
    this.zIndex = 0,
    this.onTap,
    this.visible = true,
    this.icon,
    this.bounds,
    this.width,
    this.height,
    this.bearing = 0.0,
    this.anchor = const Offset(0.5, 0.5),
    this.opacity = 1.0,
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
  /// using [LatLngBounds]
  const GroundOverlay.fromBounds(
    this.bounds, {
    required this.groundOverlayId,
    this.consumeTapEvents = false,
    this.zIndex = 0,
    this.onTap,
    this.visible = true,
    this.icon,
    this.bearing = 0.0,
    this.anchor = const Offset(0.5, 0.5),
    this.opacity = 1.0,
  })  : assert(0.0 <= opacity && opacity <= 1.0),
        position = null,
        height = null,
        width = null;

  /// Uniquely identifies a [GroundOverlay].
  final GroundOverlayId groundOverlayId;

  @override
  GroundOverlayId get mapsId => groundOverlayId;

  /// True if the [GroundOverlay] consumes tap events.
  /// If this is false, [onTap] callback will not be triggered.
  final bool consumeTapEvents;

  /// Geographical position of the center of the ground overlay.
  final LatLng? position;

  /// Geographical bounds for the ground overlay.
  final LatLngBounds? bounds;

  /// True if the ground overlay is visible.
  final bool visible;

  /// The z-index of the ground overlay, used to determine relative drawing order of
  /// map overlays.
  ///
  /// Overlays are drawn in order of z-index, so that lower values means drawn
  /// earlier, and thus appearing to be closer to the surface of the Earth.
  final int zIndex;

  /// Callbacks to receive tap events for ground overlay placed on this map.
  final VoidCallback? onTap;

  /// A description of the bitmap used to draw the ground overlay icon.
  ///
  /// To create ground overlay icon from assets, use [AssetMapBitmap],
  /// [AssetMapBitmap.create] or [BitmapDescriptor.asset].
  ///
  /// To create ground overlay icon from raw PNG data use [BytesMapBitmap]
  /// or [BitmapDescriptor.bytes].
  final BitmapDescriptor? icon;

  /// Width of the ground overlay in meters
  final double? width;

  /// Height of the ground overlay in meters
  final double? height;

  /// The amount that the image should be rotated in a clockwise direction.
  /// The center of the rotation will be the image's anchor.
  /// This is optional and the default bearing is 0, i.e., the image
  /// is aligned so that up is north.
  final double bearing;

  /// The anchor is, by default, 50% from the top of the image and 50% from the left of the image.
  final Offset anchor;

  /// The opacity of the marker, between 0.0 and 1.0 inclusive.
  ///
  /// 0.0 means fully transparent, 1.0 means fully opaque.
  final double opacity;

  /// Creates a new [GroundOverlay] object whose values are the same as this instance,
  /// unless overwritten by the specified parameters.
  GroundOverlay copyWith({
    BitmapDescriptor? iconParam,
    Offset? anchorParam,
    int? zIndexParam,
    bool? visibleParam,
    bool? consumeTapEventsParam,
    double? widthParam,
    double? heightParam,
    double? bearingParam,
    LatLng? positionParam,
    LatLngBounds? boundsParam,
    VoidCallback? onTapParam,
    double? opacityParam,
  }) {
    return GroundOverlay(
        groundOverlayId: groundOverlayId,
        consumeTapEvents: consumeTapEventsParam ?? consumeTapEvents,
        icon: iconParam ?? icon,
        opacity: opacityParam ?? opacity,
        position: positionParam ?? position,
        visible: visibleParam ?? visible,
        bearing: bearingParam ?? bearing,
        anchor: anchorParam ?? anchor,
        height: heightParam ?? height,
        bounds: boundsParam ?? bounds,
        zIndex: zIndexParam ?? zIndex,
        width: widthParam ?? width,
        onTap: onTapParam ?? onTap);
  }

  /// Creates a new [GroundOverlay] object whose values are the same as this instance.
  @override
  GroundOverlay clone() => copyWith();

  /// Converts this object to something serializable in JSON.
  @override
  Object toJson() {
    final Map<String, Object> json = <String, Object>{};

    void addIfPresent(String fieldName, Object? value) {
      if (value != null) {
        json[fieldName] = value;
      }
    }

    addIfPresent('groundOverlayId', groundOverlayId.value);
    addIfPresent('consumeTapEvents', consumeTapEvents);
    addIfPresent('transparency', 1 - opacity);
    addIfPresent('bearing', bearing);
    addIfPresent('visible', visible);
    addIfPresent('zIndex', zIndex);
    addIfPresent('height', height);
    addIfPresent('anchor', _offsetToJson(anchor));
    addIfPresent('bounds', bounds?.toJson());
    addIfPresent('icon', icon?.toJson());
    addIfPresent('width', width);
    if (position != null) {
      json['position'] = _positionToJson()!;
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
    return other is GroundOverlay &&
        groundOverlayId == other.groundOverlayId &&
        icon == other.icon &&
        consumeTapEvents == other.consumeTapEvents &&
        opacity == other.opacity &&
        position == other.position &&
        bearing == other.bearing &&
        visible == other.visible &&
        height == other.height &&
        zIndex == other.zIndex &&
        bounds == other.bounds &&
        anchor == other.anchor &&
        width == other.width &&
        onTap == other.onTap;
  }

  @override
  int get hashCode => groundOverlayId.hashCode;

  Object? _positionToJson() => position?.toJson();

  dynamic _offsetToJson(Offset? offset) {
    if (offset == null) {
      return null;
    }
    return <dynamic>[offset.dx, offset.dy];
  }
}
