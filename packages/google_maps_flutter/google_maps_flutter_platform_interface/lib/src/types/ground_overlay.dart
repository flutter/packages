// Copyright 2013 The Flutter Authors. All rights reserved.
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

/// Ground overlay to be drawn on the map.
///
/// A ground overlay is an image that is fixed to a map. Unlike markers, ground
/// overlays are oriented against the Earth's surface rather than the screen,
/// so rotating, tilting, or zooming the map will change the orientation of the
/// image. Ground overlays are useful for fixing a single image at one area on
/// the map. For adding extensive imagery that covers a large portion of the
/// map, a [TileOverlay] should be considered.
///
/// Because the overlay is automatically scaled to fit either a specified
/// [bounds] or a [position] (combined with [width], [height], and [zoomLevel]),
/// the [image].bitmapScaling must be set to [MapBitmapScaling.none].
///
/// Sizing and positioning can be defined in the following ways:
/// - Using [bounds] for exact corners in [LatLngBounds].
///   Recommended for precise placement.
/// - Using [position] with [width] and [height] in meters. If [height]
///   is omitted, the image aspect ratio is preserved.
/// - Using [position] with [zoomLevel] to scale the image according to
///   a chosen zoom level.
///
/// The [anchor] parameter defines the anchor’s relative location within the
/// overlay. For example, an anchor of (0.5, 0.5) corresponds to the image’s
/// center. When [position] is used, the overlay shifts so that this anchor
/// aligns with the given position. When [bounds] is used, the anchor specifies
/// the internal anchor position inside the bounds. If [bearing] is set, the
/// image rotates around this anchor.
///
/// Platform behavior for sizing can vary, and not all sizing or positioning
/// options may be supported equally across all platforms. Combining both
/// [width] and [zoomLevel] can help achieve the desired effect across
/// platforms. Using [bounds] is the most reliable way to position a ground
/// overlay precisely.
///
/// Use either [GroundOverlay.fromBounds] or [GroundOverlay.fromPosition] to
/// create a ground overlay.
///
/// Example of [GroundOverlay.fromBounds] method:
/// ```dart
/// GroundOverlay.bounds(
///   groundOverlayId: const GroundOverlayId('overlay_id'),
///   image: await AssetMapBitmap.create(
///     createLocalImageConfiguration(context),
///     'assets/images/ground_overlay.png',
///     bitmapScaling: MapBitmapScaling.none,
///   ),
///   bounds: LatLngBounds(
///     southwest: LatLng(37.42, -122.08),
///     northeast: LatLng(37.43, -122.09),
///   ),
/// );
/// ```
///
/// Example of [GroundOverlay.fromPosition] method:
/// ```dart
/// GroundOverlay.position(
///   groundOverlayId: const GroundOverlayId('overlay_id'),
///   image: await AssetMapBitmap.create(
///     createLocalImageConfiguration(context),
///     'assets/images/ground_overlay.png',
///     bitmapScaling: MapBitmapScaling.none,
///   ),
///   position: LatLng(37.42, -122.08),
///   width: 100,
///   height: 100,
///   zoomLevel: 14,
/// );
/// ```
@immutable
class GroundOverlay implements MapsObject<GroundOverlay> {
  /// Creates an immutable representation of a [GroundOverlay] to
  /// draw on [GoogleMap].
  GroundOverlay._({
    required this.groundOverlayId,
    required this.image,
    this.position,
    this.bounds,
    this.width,
    this.height,
    this.anchor = const Offset(0.5, 0.5),
    this.transparency = 0.0,
    this.bearing = 0.0,
    this.zIndex = 0,
    this.visible = true,
    this.clickable = true,
    this.onTap,
    this.zoomLevel,
  })  : assert(transparency >= 0.0 && transparency <= 1.0),
        assert(bearing >= 0.0 && bearing <= 360.0),
        assert((position == null) != (bounds == null),
            'Either position or bounds must be given, but not both'),
        assert(position == null || (width == null || width > 0),
            'Width must be null or greater than 0 when position is used'),
        assert(position == null || (height == null || height > 0),
            'Height must be null or greater than 0 when position is used'),
        assert(image.bitmapScaling == MapBitmapScaling.none,
            'The provided image must have its bitmapScaling property set to MapBitmapScaling.none.');

  /// Creates a [GroundOverlay] fitted to the specified [bounds] with the
  /// provided [image].
  ///
  /// Example:
  /// ```dart
  /// GroundOverlay.fromBounds(
  ///   groundOverlayId: const GroundOverlayId('overlay_id'),
  ///   image: await AssetMapBitmap.create(
  ///     createLocalImageConfiguration(context),
  ///     'assets/images/ground_overlay.png',
  ///     bitmapScaling: MapBitmapScaling.none,
  ///   ),
  ///   bounds: LatLngBounds(
  ///     southwest: LatLng(37.42, -122.08),
  ///     northeast: LatLng(37.43, -122.09),
  ///   ),
  /// );
  factory GroundOverlay.fromBounds({
    required GroundOverlayId groundOverlayId,
    required MapBitmap image,
    required LatLngBounds bounds,
    Offset anchor = const Offset(0.5, 0.5),
    double bearing = 0.0,
    double transparency = 0.0,
    int zIndex = 0,
    bool visible = true,
    bool clickable = true,
    VoidCallback? onTap,
  }) {
    return GroundOverlay._(
      groundOverlayId: groundOverlayId,
      image: image,
      bounds: bounds,
      anchor: anchor,
      bearing: bearing,
      transparency: transparency,
      zIndex: zIndex,
      visible: visible,
      clickable: clickable,
      onTap: onTap,
    );
  }

  /// Creates a [GroundOverlay] to given [position] with the given [image].
  ///
  /// Example:
  /// ```dart
  /// GroundOverlay.fromPosition(
  ///   groundOverlayId: const GroundOverlayId('overlay_id'),
  ///   image: await AssetMapBitmap.create(
  ///     createLocalImageConfiguration(context),
  ///     'assets/images/ground_overlay.png',
  ///     bitmapScaling: MapBitmapScaling.none,
  ///   ),
  ///   position: LatLng(37.42, -122.08),
  ///   width: 100,
  ///   height: 100,
  ///   zoomLevel: 14,
  /// );
  /// ```
  factory GroundOverlay.fromPosition({
    required GroundOverlayId groundOverlayId,
    required MapBitmap image,
    required LatLng position,
    double? width,
    double? height,
    Offset anchor = const Offset(0.5, 0.5),
    double bearing = 0.0,
    double transparency = 0.0,
    int zIndex = 0,
    bool visible = true,
    bool clickable = true,
    VoidCallback? onTap,
    double? zoomLevel,
  }) {
    return GroundOverlay._(
      groundOverlayId: groundOverlayId,
      image: image,
      position: position,
      width: width,
      height: height,
      anchor: anchor,
      bearing: bearing,
      transparency: transparency,
      zIndex: zIndex,
      visible: visible,
      clickable: clickable,
      onTap: onTap,
      zoomLevel: zoomLevel,
    );
  }

  /// Uniquely identifies a [GroundOverlay].
  final GroundOverlayId groundOverlayId;

  @override
  GroundOverlayId get mapsId => groundOverlayId;

  /// A description of the bitmap used to draw the ground overlay.
  ///
  /// To create ground overlay from assets, use [AssetMapBitmap],
  /// [AssetMapBitmap.create] or [BitmapDescriptor.asset].
  ///
  /// To create ground overlay from raw PNG data use [BytesMapBitmap]
  /// or [BitmapDescriptor.bytes].
  ///
  /// [MapBitmap.bitmapScaling] must be set to [MapBitmapScaling.none].
  final MapBitmap image;

  /// Geographical location to which the anchor will be fixed.
  ///
  /// The relative location of the [position] on the overlay can be changed
  /// with the [anchor] parameter, which is by default (0.5, 0.5) meaning that
  /// the [position] is in the middle of the overlay image.
  final LatLng? position;

  /// Width of the ground overlay in meters.
  ///
  /// This parameter is only available with [position].
  final double? width;

  /// Height of the ground overlay in meters.
  ///
  /// This parameter is only available with [position]. If not provided,
  /// the image aspect ratio is automatically preserved.
  final double? height;

  /// Bounds which will contain the image.
  ///
  /// If [bounds] is specified, [position] must be null.
  final LatLngBounds? bounds;

  /// The [anchor] in normalized coordinates specifying the anchor point of the
  /// overlay.
  ///
  /// When [position] is used, the overlay shifts so that this anchor aligns
  /// with the given position. If [bounds] is specified, the anchor is the
  /// internal anchor position inside the bounds.
  ///
  /// * An anchor of (0.0, 0.0) is the top-left corner.
  /// * An anchor of (1.0, 1.0) is the bottom-right corner.
  ///
  /// Defaults to `Offset(0.5, 0.5)`, i.e., the center of the image.
  /// If [bearing] is set, the image rotates around this anchor.
  final Offset? anchor;

  /// The amount that the image should be rotated in a clockwise direction.
  ///
  /// The center of the rotation will be the image's [anchor].
  /// The default bearing is 0, i.e., the image is aligned so that up is north.
  final double bearing;

  /// The transparency of the ground overlay.
  ///
  /// Defaults to 0 (opaque).
  final double transparency;

  /// The ground overlay's zIndex.
  ///
  /// It sets the order in which it will be drawn where overlays with larger
  /// values are drawn above those with lower values.
  ///
  /// Defaults to 0.
  final int zIndex;

  /// Whether the ground overlay is visible (true) or hidden (false).
  ///
  /// Defaults to true.
  final bool visible;

  /// Controls if click events are handled for this ground overlay.
  ///
  /// Defaults to true.
  final bool clickable;

  /// Callbacks to receive tap events for ground overlay placed on this map.
  final VoidCallback? onTap;

  /// The map zoom level used when setting a ground overlay with a [position].
  ///
  /// This parameter determines how the [GroundOverlay.image] is rendered on the
  /// map when using [GroundOverlay.position]. The image is scaled as if its
  /// actual size corresponds to the camera pixels at the specified `zoomLevel`.
  /// Usage of this parameter can differ between platforms.
  final double? zoomLevel;

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
    addIfPresent('image', image.toJson());
    addIfPresent('position', position?.toJson());
    addIfPresent('bounds', bounds?.toJson());
    addIfPresent('width', width);
    addIfPresent('height', height);
    addIfPresent(
        'anchor', anchor != null ? <Object>[anchor!.dx, anchor!.dy] : null);
    addIfPresent('bearing', bearing);
    addIfPresent('transparency', transparency);
    addIfPresent('zIndex', zIndex);
    addIfPresent('visible', visible);
    addIfPresent('clickable', clickable);
    addIfPresent('zoomLevel', zoomLevel);

    return json;
  }

  /// Creates a new [GroundOverlay] object whose values are the same as this
  /// instance, unless overwritten by the specified parameters.
  GroundOverlay copyWith({
    double? bearingParam,
    double? transparencyParam,
    int? zIndexParam,
    bool? visibleParam,
    bool? clickableParam,
    VoidCallback? onTapParam,
  }) {
    return GroundOverlay._(
      groundOverlayId: groundOverlayId,
      bearing: bearingParam ?? bearing,
      transparency: transparencyParam ?? transparency,
      zIndex: zIndexParam ?? zIndex,
      visible: visibleParam ?? visible,
      clickable: clickableParam ?? clickable,
      onTap: onTapParam ?? onTap,
      image: image,
      position: position,
      bounds: bounds,
      width: width,
      height: height,
      anchor: anchor,
      zoomLevel: zoomLevel,
    );
  }

  @override
  GroundOverlay clone() => copyWith();

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is GroundOverlay &&
        groundOverlayId == other.groundOverlayId &&
        image == other.image &&
        position == other.position &&
        bounds == other.bounds &&
        width == other.width &&
        height == other.height &&
        anchor == other.anchor &&
        bearing == other.bearing &&
        transparency == other.transparency &&
        zIndex == other.zIndex &&
        visible == other.visible &&
        clickable == other.clickable &&
        zoomLevel == other.zoomLevel;
  }

  @override
  int get hashCode => Object.hash(
        groundOverlayId,
        image,
        position,
        bounds,
        width,
        height,
        anchor,
        bearing,
        transparency,
        zIndex,
        visible,
        clickable,
        zoomLevel,
      );
}
