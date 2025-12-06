// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'theme.dart';

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
  var unit = 1.0;

  // Handle percentage values first.
  // Check inline to avoid circular import with parsers.dart.
  final bool isPercent = rawDouble?.endsWith('%') ?? false;
  if (isPercent) {
    if (percentageRef == null || percentageRef.isInfinite) {
      // If no reference dimension is available, treat as 0.
      // This maintains backwards compatibility for cases where
      // percentages can't be resolved.
      if (tryParse) {
        return null;
      }
      throw FormatException(
        'Percentage value "$rawDouble" requires a reference dimension '
        '(viewport width/height) but none was available.',
      );
    }
    final double? value = parseDouble(rawDouble, tryParse: tryParse);
    return value != null ? (value / 100) * percentageRef : null;
  }

  // 1 rem unit is equal to the root font size.
  // 1 em unit is equal to the current font size.
  // 1 ex unit is equal to the current x-height.
  if (rawDouble?.contains('pt') ?? false) {
    unit = kPointsToPixelFactor;
  } else if (rawDouble?.contains('rem') ?? false) {
    unit = theme.fontSize;
  } else if (rawDouble?.contains('em') ?? false) {
    unit = theme.fontSize;
  } else if (rawDouble?.contains('ex') ?? false) {
    unit = theme.xHeight;
  }
  final double? value = parseDouble(rawDouble, tryParse: tryParse);

  return value != null ? value * unit : null;
}
