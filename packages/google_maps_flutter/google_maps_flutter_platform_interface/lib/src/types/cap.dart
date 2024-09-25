// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart' show immutable;

import 'types.dart';

/// Enumeration of possible types of caps.
enum CapType {
  /// Cap that is squared off exactly at the start or end vertex of a [Polyline]
  /// with solid stroke pattern, equivalent to having no additional cap beyond
  /// the start or end vertex.
  butt('buttCap'),
  /// Cap that is a semicircle with radius equal to half the stroke width,
  /// centered at the start or end vertex of a [Polyline] with solid stroke
  /// pattern.
  round('roundCap'),
  /// Cap that is squared off after extending half the stroke width beyond the
  /// start or end vertex of a [Polyline] with solid stroke pattern.
  square('squareCap'),
  /// CustomCap with a bitmap overlay centered at the start or
  /// end vertex of a [Polyline], orientated according to the direction of the line's
  /// first or last edge and scaled with respect to the line's stroke width.
  custom('customCap');

  const CapType(this.name);

  /// Serialized String value of a cap type.
  final String name;
}

/// Cap that can be applied at the start or end vertex of a [Polyline].
@immutable
class Cap {
  const Cap._(this._type);

  /// Cap that is squared off exactly at the start or end vertex of a [Polyline]
  /// with solid stroke pattern, equivalent to having no additional cap beyond
  /// the start or end vertex.
  ///
  /// This is the default cap type at start and end vertices of Polylines with
  /// solid stroke pattern.
  static const Cap buttCap = Cap._(CapType.butt);

  /// Cap that is a semicircle with radius equal to half the stroke width,
  /// centered at the start or end vertex of a [Polyline] with solid stroke
  /// pattern.
  static const Cap roundCap = Cap._(CapType.round);

  /// Cap that is squared off after extending half the stroke width beyond the
  /// start or end vertex of a [Polyline] with solid stroke pattern.
  static const Cap squareCap = Cap._(CapType.square);

  /// Constructs a new CustomCap with a bitmap overlay centered at the start or
  /// end vertex of a [Polyline], orientated according to the direction of the line's
  /// first or last edge and scaled with respect to the line's stroke width.
  ///
  /// CustomCap can be applied to [Polyline] with any stroke pattern.
  ///
  /// [bitmapDescriptor] must not be null.
  ///
  /// [refWidth] is the reference stroke width (in pixels) - the stroke width for which
  /// the cap bitmap at its native dimension is designed. Must be positive. Default value
  /// is 10 pixels.
  static Cap customCapFromBitmap(
    BitmapDescriptor bitmapDescriptor, {
    double refWidth = 10,
  }) {
    assert(refWidth > 0.0);
    return CustomCap(bitmapDescriptor, refWidth);
  }

  final CapType _type;

  /// Converts this object to something serializable in JSON.
  Object toJson() => <Object>[_type.name];
}

/// CustomCap with a bitmap overlay centered at the start or
/// end vertex of a [Polyline], orientated according to the direction of the line's
/// first or last edge and scaled with respect to the line's stroke width.
class CustomCap extends Cap {
  /// [bitmapDescriptor] must not be null.
  ///
  /// [refWidth] is the reference stroke width (in pixels) - the stroke width for which
  /// the cap bitmap at its native dimension is designed. Must be positive. Default value
  /// is 10 pixels.
  const CustomCap(this.bitmapDescriptor, [this.refWidth = 10]) : super._(CapType.custom);

  /// Bitmap overlay centered at the start or end vertex of a [Polyline].
  final BitmapDescriptor bitmapDescriptor;

  /// Reference stroke width in pixels.
  final double refWidth;

  @override
  Object toJson() => <Object>[CapType.custom.name, bitmapDescriptor.toJson(), refWidth];
}
