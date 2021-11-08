import 'dart:ui';

import 'package:meta/meta.dart';

/// A theme used when decoding an SVG picture.
@immutable
class SvgTheme {
  /// Instantiates an SVG theme with the [currentColor].
  const SvgTheme({
    this.currentColor,
  });

  /// The default color applied to SVG elements that inherit the color property.
  /// See: https://developer.mozilla.org/en-US/docs/Web/CSS/color_value#currentcolor_keyword
  final Color? currentColor;

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is SvgTheme && currentColor == other.currentColor;
  }

  @override
  int get hashCode => currentColor.hashCode;
}
