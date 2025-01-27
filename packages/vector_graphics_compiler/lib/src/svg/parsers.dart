// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math';

import '../geometry/matrix.dart';
import '../geometry/path.dart';
import 'node.dart';
import 'numbers.dart';

const String _transformCommandAtom = r' *,?([^(]+)\(([^)]*)\)';
final RegExp _transformValidator = RegExp('^($_transformCommandAtom)*\$');
final RegExp _transformCommand = RegExp(_transformCommandAtom);

typedef _MatrixParser = AffineMatrix Function(
    List<double> params, AffineMatrix current);

const Map<String, _MatrixParser> _matrixParsers = <String, _MatrixParser>{
  'matrix': _parseSvgMatrix,
  'translate': _parseSvgTranslate,
  'scale': _parseSvgScale,
  'rotate': _parseSvgRotate,
  'skewX': _parseSvgSkewX,
  'skewY': _parseSvgSkewY,
};

List<double> _parseTransformParams(String params) {
  final List<double> result = <double>[];
  String current = '';
  for (int i = 0; i < params.length; i += 1) {
    final String char = params[i];
    final bool isSeparator = char == ' ' || char == '-' || char == ',';
    final bool isExponent = i > 0 && params[i - 1].toLowerCase() == 'e';
    if (isSeparator && !isExponent) {
      if (current != '') {
        result.add(parseDouble(current)!);
      }
      if (char == '-') {
        current = '-';
      } else {
        current = '';
      }
    } else {
      if (char == '.') {
        if (current.contains('.')) {
          result.add(parseDouble(current)!);
          current = '';
        }
      }
      current += char;
    }
  }
  if (current.isNotEmpty) {
    result.add(parseDouble(current)!);
  }
  return result;
}

/// Parses a SVG transform attribute into a [AffineMatrix].
AffineMatrix? parseTransform(String? transform) {
  if (transform == null || transform == '') {
    return null;
  }

  if (!_transformValidator.hasMatch(transform)) {
    throw StateError('illegal or unsupported transform: $transform');
  }
  final Iterable<Match> matches =
      _transformCommand.allMatches(transform).toList().reversed;
  AffineMatrix result = AffineMatrix.identity;
  for (final Match m in matches) {
    final String command = m.group(1)!.trim();
    final List<double> params = _parseTransformParams(m.group(2)!.trim());

    final _MatrixParser? transformer = _matrixParsers[command];
    if (transformer == null) {
      throw StateError('Unsupported transform: $command');
    }

    result = transformer(params, result);
  }
  return result;
}

AffineMatrix _parseSvgMatrix(List<double> params, AffineMatrix current) {
  assert(params.isNotEmpty);
  assert(params.length == 6);
  final double a = params[0];
  final double b = params[1];
  final double c = params[2];
  final double d = params[3];
  final double e = params[4];
  final double f = params[5];

  return AffineMatrix(a, b, c, d, e, f).multiplied(current);
}

AffineMatrix _parseSvgSkewX(List<double> params, AffineMatrix current) {
  assert(params.isNotEmpty);
  return AffineMatrix(1.0, 0.0, tan(params.first), 1.0, 0.0, 0.0)
      .multiplied(current);
}

AffineMatrix _parseSvgSkewY(List<double> params, AffineMatrix current) {
  assert(params.isNotEmpty);
  return AffineMatrix(1.0, tan(params.first), 0.0, 1.0, 0.0, 0.0)
      .multiplied(current);
}

AffineMatrix _parseSvgTranslate(List<double> params, AffineMatrix current) {
  assert(params.isNotEmpty);
  assert(params.length <= 2);
  final double y = params.length < 2 ? 0.0 : params[1];
  return AffineMatrix(1.0, 0.0, 0.0, 1.0, params.first, y).multiplied(current);
}

AffineMatrix _parseSvgScale(List<double> params, AffineMatrix current) {
  assert(params.isNotEmpty);
  assert(params.length <= 2);
  final double x = params[0];
  final double y = params.length < 2 ? x : params[1];
  return AffineMatrix(x, 0.0, 0.0, y, 0.0, 0.0).multiplied(current);
}

AffineMatrix _parseSvgRotate(List<double> params, AffineMatrix current) {
  assert(params.length <= 3);
  final double a = radians(params[0]);

  final AffineMatrix rotate = AffineMatrix.identity.rotated(a);

  if (params.length > 1) {
    final double x = params[1];
    final double y = params.length == 3 ? params[2] : x;
    return AffineMatrix(1.0, 0.0, 0.0, 1.0, x, y)
        .multiplied(rotate)
        .translated(-x, -y)
        .multiplied(current);
  } else {
    return rotate.multiplied(current);
  }
}

/// Parses a `fill-rule` attribute.
PathFillType? parseRawFillRule(String? rawFillRule) {
  if (rawFillRule == 'inherit' || rawFillRule == null) {
    return null;
  }

  return rawFillRule != 'evenodd' ? PathFillType.nonZero : PathFillType.evenOdd;
}

/// Parses strings in the form of '1.0' or '100%'.
double parseDecimalOrPercentage(String val, {double multiplier = 1.0}) {
  if (isPercentage(val)) {
    return parsePercentage(val, multiplier: multiplier);
  } else {
    return parseDouble(val)!;
  }
}

/// Parses values in the form of '100%'.
double parsePercentage(String val, {double multiplier = 1.0}) {
  return parseDouble(val.substring(0, val.length - 1))! / 100 * multiplier;
}

/// Whether a string should be treated as a percentage (i.e. if it ends with a `'%'`).
bool isPercentage(String? val) => val?.endsWith('%') ?? false;

/// Parses value from the form '25%', 0.25 or 25.0 as a double.
/// Note: Percentage or decimals will be multiplied by the total
/// view box size, where as doubles will be returned as is.
double? parsePatternUnitToDouble(String rawValue, String mode,
    {ViewportNode? viewBox}) {
  double? value;
  double? viewBoxValue;
  if (viewBox != null) {
    if (mode == 'width') {
      viewBoxValue = viewBox.width;
    } else if (mode == 'height') {
      viewBoxValue = viewBox.height;
    }
  }

  if (rawValue.contains('%')) {
    value = ((double.parse(rawValue.substring(0, rawValue.length - 1))) / 100) *
        viewBoxValue!;
  } else if (rawValue.startsWith('0.')) {
    value = (double.parse(rawValue)) * viewBoxValue!;
  } else if (rawValue.isNotEmpty) {
    value = double.parse(rawValue);
  }
  return value;
}
