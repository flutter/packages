import 'dart:ui';
import 'dart:math';

import 'package:vector_math/vector_math_64.dart';

const String _transformCommandAtom = ' *([^(]+)\\(([^)]*)\\)';
final RegExp _transformValidator = new RegExp('^($_transformCommandAtom)*\$');
final RegExp _transformCommand = new RegExp(_transformCommandAtom);

typedef Matrix4 MatrixParser(String paramsStr, Matrix4 current);

const Map<String, MatrixParser> _matrixParsers = const {
  'matrix': _parseSvgMatrix,
  'translate': _parseSvgTranslate,
  'scale': _parseSvgScale,
  'rotate': _parseSvgRotate,
  'skewX': _parseSvgSkewX,
  'skewY': _parseSvgSkewY,
};

Matrix4 parseTransform(String transform) {
  if (transform == null) {
    return null;
  }

  if (!_transformValidator.hasMatch(transform))
    throw new Exception('illegal or unsupported transform: $transform');
  final Iterable<Match> matches =
      _transformCommand.allMatches(transform).toList().reversed;
  Matrix4 result = new Matrix4.identity();
  for (Match m in matches) {
    final String command = m.group(1);
    final String params = m.group(2);

    final transformer = _matrixParsers[command];
    if (transformer == null) {
      throw new FormatException('Unsupported transform: $command');
    }

    result = transformer(params, result);
  }
  return result;
}

final RegExp _valueSeparator = new RegExp('( *, *| +)');

Matrix4 _parseSvgMatrix(String paramsStr, Matrix4 current) {
  final params = paramsStr.split(_valueSeparator);
  assert(params.isNotEmpty);
  assert(params.length == 6);
  final a = double.parse(params[0]);
  final b = double.parse(params[1]);
  final c = double.parse(params[2]);
  final d = double.parse(params[3]);
  final e = double.parse(params[4]);
  final f = double.parse(params[5]);

  return _matrix(a, b, c, d, e, f).multiplied(current);
}

Matrix4 _parseSvgSkewX(String paramsStr, Matrix4 current) {
  final x = double.parse(paramsStr);
  return _matrix(1.0, tan(x), 0.0, 0.0, 1.0, 0.0).multiplied(current);
}

Matrix4 _parseSvgSkewY(String paramsStr, Matrix4 current) {
  final y = double.parse(paramsStr);
  return _matrix(1.0, 0.0, 0.0, tan(y), 1.0, 0.0).multiplied(current);
}

Matrix4 _parseSvgTranslate(String paramsStr, Matrix4 current) {
  final List<String> params = paramsStr.split(_valueSeparator);
  assert(params.isNotEmpty);
  assert(params.length <= 2);
  final double x = double.parse(params[0]);
  final double y = params.length < 2 ? x : double.parse(params[1]);
  return _matrix(1.0, 0.0, 0.0, 1.0, x, y).multiplied(current);
}

Matrix4 _parseSvgScale(String paramsStr, Matrix4 current) {
  final List<String> params = paramsStr.split(_valueSeparator);
  assert(params.isNotEmpty);
  assert(params.length <= 2);
  final double x = double.parse(params[0]);
  final double y = params.length < 2 ? x : double.parse(params[1]);
  return _matrix(x, 0.0, 0.0, y, 0.0, 0.0).multiplied(current);
}

Matrix4 _parseSvgRotate(String paramsStr, Matrix4 current) {
  final List<String> params = paramsStr.split(_valueSeparator);
  assert(params.length <= 3);
  final double a = radians(double.parse(params[0]));

  final rotate = _matrix(cos(a), sin(a), -sin(a), cos(a), 0.0, 0.0);

  if (params.length > 1) {
    final double x = double.parse(params[1]);
    final double y = params.length == 3 ? double.parse(params[2]) : x;
    return _matrix(1.0, 0.0, 0.0, 1.0, x, y)
        .multiplied(current)
        .multiplied(rotate)
        .multiplied(_matrix(1.0, 0.0, 0.0, 1.0, -x, -y));
  } else {
    return rotate.multiplied(current);
  }
}

Matrix4 _matrix(double a, double b, double c, double d, double e, double f) {
  return new Matrix4(
      a, b, 0.0, 0.0, c, d, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, e, f, 0.0, 1.0);
}
