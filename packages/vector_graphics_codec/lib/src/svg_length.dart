// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

final RegExp _length = RegExp(r'^([+-]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?)(%|[a-zA-Z]*)$');

/// Resolves an SVG/CSS length in user units, using 96 CSS pixels per inch.
///
/// Percentages require [percentageRef]. Font-relative lengths use the caller's
/// font metrics; [rootFontSize] defaults to [fontSize]. This does not parse
/// primitive parameters such as feOffset's dx/dy, which must be unitless.
double parseSvgLength(
  String value, {
  double fontSize = 14,
  double? xHeight,
  double? rootFontSize,
  double? percentageRef,
}) {
  final RegExpMatch? match = _length.firstMatch(value.trim());
  if (match == null) {
    throw FormatException('Invalid SVG length: $value');
  }
  final double factor = switch (match[2]!.toLowerCase()) {
    '' || 'px' => 1,
    'in' => 96,
    'cm' => 96 / 2.54,
    'mm' => 96 / 25.4,
    'q' => 96 / 101.6,
    'pt' => 96 / 72,
    'pc' => 16,
    'em' => fontSize,
    'ex' => xHeight ?? fontSize / 2,
    'rem' => rootFontSize ?? fontSize,
    '%' when percentageRef != null => percentageRef / 100,
    '%' => throw FormatException('SVG percentage requires a reference dimension: $value'),
    _ => throw FormatException('Unsupported SVG length unit: $value'),
  };
  final double result = double.parse(match[1]!) * factor;
  if (!result.isFinite) {
    throw FormatException('SVG length must be finite: $value');
  }
  return result;
}
