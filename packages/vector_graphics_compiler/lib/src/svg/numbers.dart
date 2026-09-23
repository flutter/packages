// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:vector_graphics_codec/vector_graphics_codec.dart';

import 'theme.dart';

/// Absolute font-size keywords shared by text and filter length resolution.
const Map<String, double> svgFontSizes = <String, double>{
  'xx-small': 10,
  'x-small': 12,
  'small': 14,
  'medium': 18,
  'large': 22,
  'x-large': 26,
  'xx-large': 32,
};

/// Parses a [rawDouble] `String` to a `double`.
///
/// The [rawDouble] might include a unit (`px`, `pt`, `em`, `ex`, `rem`, or `%`)
/// which is stripped off when parsed to a `double`.
///
/// Passing `null` will return `null`.
double? parseDouble(String? rawDouble, {bool tryParse = false}) {
  assert(tryParse != null); // ignore: unnecessary_null_comparison
  if (rawDouble == null) {
    return null;
  }

  rawDouble = rawDouble
      .replaceFirst('rem', '')
      .replaceFirst('em', '')
      .replaceFirst('ex', '')
      .replaceFirst('px', '')
      .replaceFirst('pt', '')
      .replaceFirst('%', '')
      .trim();

  if (tryParse) {
    return double.tryParse(rawDouble);
  }
  return double.parse(rawDouble);
}

/// Convert [degrees] to radians.
double radians(double degrees) => degrees * math.pi / 180;

/// The number of pixels per CSS inch.
const int kCssPixelsPerInch = 96;

/// The number of points per CSS inch.
const int kCssPointsPerInch = 72;

/// The multiplicand to convert from CSS points to pixels.
const double kPointsToPixelFactor = kCssPixelsPerInch / kCssPointsPerInch;

/// Parses a `rawDouble` `String` to a `double`
/// taking into account absolute and relative units
/// (`px`, `em` or `ex`).
///
/// Passing an `em` value will calculate the result
/// relative to the provided [fontSize]:
/// 1 em = 1 * `fontSize`.
///
/// Passing an `ex` value will calculate the result
/// relative to the provided [xHeight]:
/// 1 ex = 1 * `xHeight`.
///
/// Passing a `%` value will calculate the result
/// relative to the provided [percentageRef]:
/// 50% with percentageRef=100 = 50.
///
/// The `rawDouble` might include a unit which is
/// stripped off when parsed to a `double`.
///
/// Passing `null` will return `null`.
double? parseDoubleWithUnits(
  String? rawDouble, {
  bool tryParse = false,
  required SvgTheme theme,
  double? percentageRef,
}) {
  if (rawDouble == null) {
    return null;
  }
  try {
    return parseSvgLength(
      rawDouble,
      fontSize: theme.fontSize,
      xHeight: theme.xHeight,
      percentageRef: percentageRef,
    );
  } on FormatException {
    if (tryParse) {
      return null;
    }
    rethrow;
  }
}
