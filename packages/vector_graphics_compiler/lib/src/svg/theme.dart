// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:meta/meta.dart';

import '../paint.dart';

/// A theme used when decoding an SVG picture.
@immutable
class SvgTheme {
  /// Instantiates an SVG theme with the [currentColor]
  /// and [fontSize].
  ///
  /// Defaults the [fontSize] to 14.
  const SvgTheme({
    this.currentColor = Color.opaqueBlack,
    this.fontSize = 14,
    double? xHeight,
  }) : xHeight = xHeight ?? fontSize / 2;

  /// The default color applied to SVG elements that inherit the color property.
  /// See: https://developer.mozilla.org/en-US/docs/Web/CSS/color_value#currentcolor_keyword
  final Color currentColor;

  /// The font size used when calculating em units of SVG elements.
  /// See: https://www.w3.org/TR/SVG11/coords.html#Units
  final double fontSize;

  /// The x-height (corpus size) of the font used when calculating ex units of SVG elements.
  /// Defaults to [fontSize] / 2 if not provided.
  /// See: https://www.w3.org/TR/SVG11/coords.html#Units, https://en.wikipedia.org/wiki/X-height
  final double xHeight;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }

    return other is SvgTheme &&
        currentColor == other.currentColor &&
        fontSize == other.fontSize &&
        xHeight == other.xHeight;
  }

  @override
  int get hashCode => Object.hash(currentColor, fontSize, xHeight);

  @override
  String toString() =>
      'SvgTheme(currentColor: $currentColor, fontSize: $fontSize, xHeight: $xHeight)';
}
