import 'dart:ui';
import 'dart:typed_data';
import 'dart:math';

import 'package:vector_math/vector_math_64.dart';

Rect parseViewBox(String viewbox) {
  if (viewbox == null || viewbox == '') {
    return Rect.zero;
  }

  final parts = viewbox.split(' ');
  return new Rect.fromLTWH(double.parse(parts[0]), double.parse(parts[1]),
      double.parse(parts[2]), double.parse(parts[3]));
}

Color parseColor(String colorString) {
  if (colorString == null || colorString.length == 0) {
    return const Color.fromARGB(255, 0, 0, 0);
  }
  if (colorString[0] == '#') {
    if (colorString.length == 4) {
      final r = colorString[1];
      final g = colorString[2];
      final b = colorString[3];
      colorString = '#$r$r$g$g$b$b';
    }
    int color = int.parse(colorString.substring(1),
        radix: 16, onError: (source) => null);

    if (colorString.length == 7) {
      return new Color(color |= 0x00000000ff000000);
    }

    if (colorString.length == 9) {
      return new Color(color);
    }
  }

  throw new ArgumentError.value(
      colorString, "colorString", "Unknown color $colorString");
}

// TODO: is this better off using custom parsing logic vs regex?
final _spaceOrCommaRegEx = new RegExp(' |,');
Float32List parsePoints(String points) {
  if (points == null || points.length == 0) {
    return null;
  }

  return new Float32List.fromList(points
      .trim()
      .split(_spaceOrCommaRegEx)
      .map((pt) => double.parse(pt))
      .toList());
}

const String _transformCommandAtom = ' *([^(]+)\\(([^)]*)\\)';
final RegExp _transformValidator = new RegExp('^($_transformCommandAtom)*\$');
final RegExp _transformCommand = new RegExp(_transformCommandAtom);

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

    if (command == 'translate') {
      result = _parseSvgTranslate(params).multiplied(result);
      continue;
    }
    if (command == 'scale') {
      result = _parseSvgScale(params).multiplied(result);
      continue;
    }
    if (command == 'rotate') {
      result = _parseSvgRotate(params).multiplied(result);
      continue;
    }
    throw new Exception('unimplemented transform: $command');
  }
  return result;
}

final RegExp _valueSeparator = new RegExp('( *, *| +)');

Matrix4 _parseSvgTranslate(String paramsStr) {
  final List<String> params = paramsStr.split(_valueSeparator);
  assert(params.isNotEmpty);
  assert(params.length <= 2);
  final double x = double.parse(params[0]);
  final double y = params.length < 2 ? x : double.parse(params[1]);
  return _matrix(1.0, 0.0, 0.0, 1.0, x, y);
}

Matrix4 _parseSvgScale(String paramsStr) {
  final List<String> params = paramsStr.split(_valueSeparator);
  assert(params.isNotEmpty);
  assert(params.length <= 2);
  final double x = double.parse(params[0]);
  final double y = params.length < 2 ? x : double.parse(params[1]);
  return _matrix(x, 0.0, 0.0, y, 0.0, 0.0);
}

Matrix4 _parseSvgRotate(String paramsStr) {
  final List<String> params = paramsStr.split(_valueSeparator);
  assert(params.length == 1);
  final double a = radians(double.parse(params[0]));
  return _matrix(cos(a), sin(a), -sin(a), cos(a), 0.0, 0.0);
}

Matrix4 _matrix(double a, double b, double c, double d, double e, double f) {
  return new Matrix4(
      a, b, 0.0, 0.0, c, d, 0.0, 0.0, e, f, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0);
}
