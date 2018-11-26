import 'dart:math';
import 'dart:ui';

import 'package:flutter_svg/src/vector_drawable.dart';
import 'package:vector_math/vector_math_64.dart';

final Map<String, double> _kTextSizeMap = <String, double>{
  'xx-small': 10 * window.devicePixelRatio,
  'x-small': 12 * window.devicePixelRatio,
  'small': 14 * window.devicePixelRatio,
  'medium': 18 * window.devicePixelRatio,
  'large': 22 * window.devicePixelRatio,
  'x-large': 26 * window.devicePixelRatio,
  'xx-large': 32 * window.devicePixelRatio,
};

double parseFontSize(String raw, {double parentValue}) {
  if (raw == null || raw == '') {
    return null;
  }

  double ret = double.tryParse(raw);
  if (ret != null) {
    return ret;
  }

  raw = raw.toLowerCase().trim();
  ret = _kTextSizeMap[raw];
  if (ret != null) {
    return ret;
  }

  if (raw == 'larger') {
    if (parentValue == null) {
      return _kTextSizeMap['large'];
    }
    return parentValue * 1.2;
  }

  if (raw == 'smaller') {
    if (parentValue == null) {
      return _kTextSizeMap['small'];
    }
    return parentValue / 1.2;
  }

  throw StateError('Could not parse font-size: $raw');
}

DrawableTextAnchorPosition parseTextAnchor(String raw) {
  switch (raw) {
    case 'inherit':
      return null;
    case 'middle':
      return DrawableTextAnchorPosition.middle;
    case 'end':
      return DrawableTextAnchorPosition.end;
    case 'start':
    default:
      return DrawableTextAnchorPosition.start;
  }
}

const String _transformCommandAtom = ' *([^(]+)\\(([^)]*)\\)';
final RegExp _transformValidator = RegExp('^($_transformCommandAtom)*\$');
final RegExp _transformCommand = RegExp(_transformCommandAtom);

typedef MatrixParser = Matrix4 Function(String paramsStr, Matrix4 current);

const Map<String, MatrixParser> _matrixParsers = <String, MatrixParser>{
  'matrix': _parseSvgMatrix,
  'translate': _parseSvgTranslate,
  'scale': _parseSvgScale,
  'rotate': _parseSvgRotate,
  'skewX': _parseSvgSkewX,
  'skewY': _parseSvgSkewY,
};

/// Parses a SVG transform attribute into a [Matrix4].
///
/// Based on work in the "vi-tool" by @amirh, but extended to support additional
/// transforms and use a Matrix4 rather than Matrix3 for the affine matrices.
Matrix4 parseTransform(String transform) {
  if (transform == null || transform == '') {
    return null;
  }

  if (!_transformValidator.hasMatch(transform))
    throw StateError('illegal or unsupported transform: $transform');
  final Iterable<Match> matches =
      _transformCommand.allMatches(transform).toList().reversed;
  Matrix4 result = Matrix4.identity();
  for (Match m in matches) {
    final String command = m.group(1);
    final String params = m.group(2);

    final MatrixParser transformer = _matrixParsers[command];
    if (transformer == null) {
      throw StateError('Unsupported transform: $command');
    }

    result = transformer(params, result);
  }
  return result;
}

final RegExp _valueSeparator = RegExp('( *, *| +)');

Matrix4 _parseSvgMatrix(String paramsStr, Matrix4 current) {
  final List<String> params = paramsStr.split(_valueSeparator);
  assert(params.isNotEmpty);
  assert(params.length == 6);
  final double a = double.parse(params[0]);
  final double b = double.parse(params[1]);
  final double c = double.parse(params[2]);
  final double d = double.parse(params[3]);
  final double e = double.parse(params[4]);
  final double f = double.parse(params[5]);

  return affineMatrix(a, b, c, d, e, f).multiplied(current);
}

Matrix4 _parseSvgSkewX(String paramsStr, Matrix4 current) {
  final double x = double.parse(paramsStr);
  return affineMatrix(1.0, 0.0, tan(x), 1.0, 0.0, 0.0).multiplied(current);
}

Matrix4 _parseSvgSkewY(String paramsStr, Matrix4 current) {
  final double y = double.parse(paramsStr);
  return affineMatrix(1.0, tan(y), 0.0, 1.0, 0.0, 0.0).multiplied(current);
}

Matrix4 _parseSvgTranslate(String paramsStr, Matrix4 current) {
  final List<String> params = paramsStr.split(_valueSeparator);
  assert(params.isNotEmpty);
  assert(params.length <= 2);
  final double x = double.parse(params[0]);
  final double y = params.length < 2 ? x : double.parse(params[1]);
  return affineMatrix(1.0, 0.0, 0.0, 1.0, x, y).multiplied(current);
}

Matrix4 _parseSvgScale(String paramsStr, Matrix4 current) {
  final List<String> params = paramsStr.split(_valueSeparator);
  assert(params.isNotEmpty);
  assert(params.length <= 2);
  final double x = double.parse(params[0]);
  final double y = params.length < 2 ? x : double.parse(params[1]);
  return affineMatrix(x, 0.0, 0.0, y, 0.0, 0.0).multiplied(current);
}

Matrix4 _parseSvgRotate(String paramsStr, Matrix4 current) {
  final List<String> params = paramsStr.split(_valueSeparator);
  assert(params.length <= 3);
  final double a = radians(double.parse(params[0]));

  final Matrix4 rotate =
      affineMatrix(cos(a), sin(a), -sin(a), cos(a), 0.0, 0.0);

  if (params.length > 1) {
    final double x = double.parse(params[1]);
    final double y = params.length == 3 ? double.parse(params[2]) : x;
    return affineMatrix(1.0, 0.0, 0.0, 1.0, x, y)
        .multiplied(current)
        .multiplied(rotate)
        .multiplied(affineMatrix(1.0, 0.0, 0.0, 1.0, -x, -y));
  } else {
    return rotate.multiplied(current);
  }
}

Matrix4 affineMatrix(
    double a, double b, double c, double d, double e, double f) {
  return Matrix4(
      a, b, 0.0, 0.0, c, d, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, e, f, 0.0, 1.0);
}

PathFillType parseRawFillRule(String rawFillRule) {
  if (rawFillRule == 'inherit' || rawFillRule == null) {
    return null;
  }

  return rawFillRule != 'evenodd' ? PathFillType.nonZero : PathFillType.evenOdd;
}
