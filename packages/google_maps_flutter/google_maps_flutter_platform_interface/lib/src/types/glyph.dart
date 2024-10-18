// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Color;

import '../../google_maps_flutter_platform_interface.dart';

/// Defines a glyph (the element at the center of an [AdvancedMarker] icon).
/// Default glyph is a circle but can be configured to have a different color,
/// some text or bitmap
@immutable
class Glyph {
  /// Create a glyph with a circle of the specified [color]
  factory Glyph.color(Color color) {
    return Glyph._(color: color);
  }

  /// Create a glyph with a bitmap image
  factory Glyph.bitmap(BitmapDescriptor bitmapDescriptor) {
    return Glyph._(bitmapDescriptor: bitmapDescriptor);
  }

  /// Create a glyph with a [text] of the specified [textColor]
  factory Glyph.text(String text, {Color? textColor}) {
    return Glyph._(
      text: text,
      textColor: textColor,
    );
  }
  const Glyph._({
    this.text,
    this.textColor,
    this.bitmapDescriptor,
    this.color,
  });

  /// Text to be displayed in the glyph
  final String? text;

  /// Color of the text
  final Color? textColor;

  /// Bitmap image to be displayed in center of the glyph
  final BitmapDescriptor? bitmapDescriptor;

  /// Color of the default glyph (circle)
  final Color? color;
}
