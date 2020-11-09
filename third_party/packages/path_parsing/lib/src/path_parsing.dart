// This code has been "translated" largely from the Chromium/blink source
// for SVG path parsing.
// The following files can be cross referenced to the classes and methods here:
//   * https://github.com/chromium/chromium/blob/master/third_party/blink/renderer/core/svg/svg_parser_utilities.cc
//   * https://github.com/chromium/chromium/blob/master/third_party/blink/renderer/core/svg/svg_parser_utilities.h
//   * https://github.com/chromium/chromium/blob/master/third_party/blink/renderer/core/svg/svg_path_string_source.cc
//   * https://github.com/chromium/chromium/blob/master/third_party/blink/renderer/core/svg/svg_path_string_source.h
//   * https://github.com/chromium/chromium/blob/master/third_party/blink/renderer/core/svg/svg_path_parser.cc
//   * https://github.com/chromium/chromium/blob/master/third_party/blink/renderer/core/svg/svg_path_parser.h
//   * https://github.com/chromium/chromium/blob/master/third_party/blink/renderer/core/html/parser/html_parser_idioms.h (IsHTMLSpace)
//   * https://github.com/chromium/chromium/blob/master/third_party/blink/renderer/core/svg/svg_path_parser_test.cc

import 'dart:math' as math show sqrt, max, pi, tan, sin, cos, pow, atan2;

import 'package:meta/meta.dart';
import 'package:vector_math/vector_math.dart' show Matrix4;

import './path_segment_type.dart';

/// Parse `svg`, emitting the segment data to `path`.
void writeSvgPathDataToPath(String? svg, PathProxy path) {
  if (svg == null || svg == '') {
    return;
  }

  final SvgPathStringSource parser = SvgPathStringSource(svg);
  final SvgPathNormalizer normalizer = SvgPathNormalizer();
  for (PathSegmentData seg in parser.parseSegments()) {
    normalizer.emitSegment(seg, path);
  }
}

/// A receiver for normalized [PathSegmentData].
abstract class PathProxy {
  void moveTo(double x, double y);
  void lineTo(double x, double y);
  void cubicTo(
    double x1,
    double y1,
    double x2,
    double y2,
    double x3,
    double y3,
  );
  void close();
}

/// Provides a minimal implementation of a [Point] or [Offset].
// Takes care of a few things Point doesn't, without requiring Flutter as dependency
@immutable
class _PathOffset {
  const _PathOffset(this.dx, this.dy)
      : assert(dx != null), // ignore: unnecessary_null_comparison
        assert(dy != null); // ignore: unnecessary_null_comparison

  static _PathOffset get zero => const _PathOffset(0.0, 0.0);
  final double dx;
  final double dy;

  double get direction => math.atan2(dy, dx);

  _PathOffset translate(double translateX, double translateY) =>
      _PathOffset(dx + translateX, dy + translateY);

  _PathOffset operator +(_PathOffset other) =>
      _PathOffset(dx + other.dx, dy + other.dy);
  _PathOffset operator -(_PathOffset other) =>
      _PathOffset(dx - other.dx, dy - other.dy);

  _PathOffset operator *(double operand) =>
      _PathOffset(dx * operand, dy * operand);

  @override
  String toString() => 'PathOffset{$dx,$dy}';

  @override
  bool operator ==(Object other) {
    return other is _PathOffset && other.dx == dx && other.dy == dy;
  }

  // TODO(dnfield): Use a real hashing function - but this should at least be better than the default.
  @override
  int get hashCode => (((17 * 23) ^ dx.hashCode) * 23) ^ dy.hashCode;
}

const double _twoPiFloat = math.pi * 2.0;
const double _piOverTwoFloat = math.pi / 2.0;

class SvgPathStringSource {
  SvgPathStringSource(String string)
      : assert(string != null), // ignore: unnecessary_null_comparison
        _previousCommand = SvgPathSegType.unknown,
        _codePoints = string.codeUnits,
        _idx = 0 {
    _skipOptionalSvgSpaces();
  }

  SvgPathSegType _previousCommand;
  final List<int> _codePoints;
  int _idx;

  bool _isHtmlSpace(int character) {
    // Histogram from Apple's page load test combined with some ad hoc browsing
    // some other test suites.
    //
    //     82%: 216330 non-space characters, all > U+0020
    //     11%:  30017 plain space characters, U+0020
    //      5%:  12099 newline characters, U+000A
    //      2%:   5346 tab characters, U+0009
    //
    // No other characters seen. No U+000C or U+000D, and no other control
    // characters. Accordingly, we check for non-spaces first, then space, then
    // newline, then tab, then the other characters.

    return character <= AsciiConstants.space &&
        (character == AsciiConstants.space ||
            character == AsciiConstants.slashN ||
            character == AsciiConstants.slashT ||
            character == AsciiConstants.slashR ||
            character == AsciiConstants.slashF);
  }

  bool _skipOptionalSvgSpaces() {
    while (_idx < _codePoints.length && _isHtmlSpace(_codePoints[_idx])) {
      _idx++;
    }
    return _idx < _codePoints.length;
  }

  bool _skipOptionalSvgSpacesOrDelimiter(
      [int delimiter = AsciiConstants.comma]) {
    if (_idx < _codePoints.length &&
        !_isHtmlSpace(_codePoints[_idx]) &&
        _codePoints[_idx] != delimiter) {
      return false;
    }
    if (_skipOptionalSvgSpaces()) {
      if (_idx < _codePoints.length && _codePoints[_idx] == delimiter) {
        _idx++;
        _skipOptionalSvgSpaces();
      }
    }
    return _idx < _codePoints.length;
  }

  bool _isNumberStart(int lookahead) {
    return (lookahead >= AsciiConstants.number0 &&
            lookahead <= AsciiConstants.number9) ||
        lookahead == AsciiConstants.plus ||
        lookahead == AsciiConstants.minus ||
        lookahead == AsciiConstants.period;
  }

  SvgPathSegType _maybeImplicitCommand(
    int lookahead,
    SvgPathSegType nextCommand,
  ) {
    // Check if the current lookahead may start a number - in which case it
    // could be the start of an implicit command. The 'close' command does not
    // have any parameters though and hence can't have an implicit
    // 'continuation'.
    if (!_isNumberStart(lookahead) || _previousCommand == SvgPathSegType.close)
      return nextCommand;
    // Implicit continuations of moveto command translate to linetos.
    if (_previousCommand == SvgPathSegType.moveToAbs) {
      return SvgPathSegType.lineToAbs;
    }
    if (_previousCommand == SvgPathSegType.moveToRel) {
      return SvgPathSegType.lineToRel;
    }
    return _previousCommand;
  }

  bool _isValidRange(double x) {
    return x >= -double.maxFinite && x <= double.maxFinite;
  }

  bool _isValidExponent(double x) {
    return x >= -37 && x <= 38;
  }

  // We use this generic parseNumber function to allow the Path parsing code to
  // work at a higher precision internally, without any unnecessary runtime cost
  // or code complexity.
  double _parseNumber() {
    _skipOptionalSvgSpaces();

    // read the sign
    int sign = 1;
    final int end = _codePoints.length;
    if (_idx < end && _codePoints[_idx] == AsciiConstants.plus)
      _idx++;
    else if (_idx < end && _codePoints[_idx] == AsciiConstants.minus) {
      _idx++;
      sign = -1;
    }

    if (_idx == end ||
        ((_codePoints[_idx] < AsciiConstants.number0 ||
                _codePoints[_idx] > AsciiConstants.number9) &&
            _codePoints[_idx] != AsciiConstants.period))
      // The first character of a number must be one of [0-9+-.]
      throw StateError('First character of a number must be one of [0-9+-.]');

    // read the integer part, build right-to-left
    final int digitsStart = _idx;
    while (_idx < end &&
        _codePoints[_idx] >= AsciiConstants.number0 &&
        _codePoints[_idx] <= AsciiConstants.number9)
      ++_idx; // Advance to first non-digit.

    double integer = 0.0;
    if (_idx != digitsStart) {
      int ptrScanIntPart = _idx - 1;
      int multiplier = 1;
      while (ptrScanIntPart >= digitsStart) {
        integer += multiplier *
            (_codePoints[ptrScanIntPart--] - AsciiConstants.number0);

        multiplier *= 10;
      }
      // Bail out early if this overflows.
      if (!_isValidRange(integer)) {
        throw StateError('Numeric overflow');
      }
    }

    double decimal = 0.0;
    if (_idx < end && _codePoints[_idx] == AsciiConstants.period) {
      // read the decimals
      _idx++;

      // There must be a least one digit following the .
      if (_idx >= end ||
          _codePoints[_idx] < AsciiConstants.number0 ||
          _codePoints[_idx] > AsciiConstants.number9)
        throw StateError('There must be at least one digit following the .');

      double frac = 1.0;
      while (_idx < end &&
          _codePoints[_idx] >= AsciiConstants.number0 &&
          _codePoints[_idx] <= AsciiConstants.number9) {
        frac *= 0.1;
        decimal += (_codePoints[_idx++] - AsciiConstants.number0) * frac;
      }
    }

    // When we get here we should have consumed either a digit for the integer
    // part or a fractional part (with at least one digit after the '.'.)
    assert(digitsStart != _idx);

    double number = integer + decimal;
    number *= sign;

    // read the exponent part
    if (_idx + 1 < end &&
        (_codePoints[_idx] == AsciiConstants.lowerE ||
            _codePoints[_idx] == AsciiConstants.upperE) &&
        (_codePoints[_idx + 1] != AsciiConstants.lowerX &&
            _codePoints[_idx + 1] != AsciiConstants.lowerM)) {
      _idx++;

      // read the sign of the exponent
      bool exponentIsNegative = false;
      if (_codePoints[_idx] == AsciiConstants.plus)
        _idx++;
      else if (_codePoints[_idx] == AsciiConstants.minus) {
        _idx++;
        exponentIsNegative = true;
      }

      // There must be an exponent
      if (_idx >= end ||
          _codePoints[_idx] < AsciiConstants.number0 ||
          _codePoints[_idx] > AsciiConstants.number9)
        throw StateError('Missing exponent');

      double exponent = 0.0;
      while (_idx < end &&
          _codePoints[_idx] >= AsciiConstants.number0 &&
          _codePoints[_idx] <= AsciiConstants.number9) {
        exponent *= 10.0;
        exponent += _codePoints[_idx] - AsciiConstants.number0;
        _idx++;
      }
      if (exponentIsNegative) {
        exponent = -exponent;
      }
      // Make sure exponent is valid.
      if (!_isValidExponent(exponent)) {
        throw StateError('Invalid exponent $exponent');
      }
      if (exponent != 0) {
        number *= math.pow(10.0, exponent);
      }
    }

    // Don't return Infinity() or NaN().
    if (!_isValidRange(number)) {
      throw StateError('Numeric overflow');
    }

    // if (mode & kAllowTrailingWhitespace)
    _skipOptionalSvgSpacesOrDelimiter();

    return number;
  }

  bool _parseArcFlag() {
    if (!hasMoreData) {
      throw StateError('Expected more data');
    }
    final int flagChar = _codePoints[_idx];
    _idx++;
    _skipOptionalSvgSpacesOrDelimiter();

    if (flagChar == AsciiConstants.number0)
      return false;
    else if (flagChar == AsciiConstants.number1)
      return true;
    else
      throw StateError('Invalid flag value');
  }

  bool get hasMoreData => _idx < _codePoints.length;

  Iterable<PathSegmentData> parseSegments() sync* {
    while (hasMoreData) {
      yield parseSegment();
    }
  }

  PathSegmentData parseSegment() {
    assert(hasMoreData);
    final PathSegmentData segment = PathSegmentData();
    final int lookahead = _codePoints[_idx];
    SvgPathSegType command = AsciiConstants.mapLetterToSegmentType(lookahead);
    if (_previousCommand == SvgPathSegType.unknown) {
      // First command has to be a moveto.
      if (command != SvgPathSegType.moveToRel &&
          command != SvgPathSegType.moveToAbs) {
        throw StateError('Expected to find moveTo command');
      }
      // Consume command letter.
      _idx++;
    } else if (command == SvgPathSegType.unknown) {
      // Possibly an implicit command.
      assert(_previousCommand != SvgPathSegType.unknown);
      command = _maybeImplicitCommand(lookahead, command);
      if (command == SvgPathSegType.unknown) {
        throw StateError('Expected a path command');
      }
    } else {
      // Valid explicit command.
      _idx++;
    }

    segment.command = _previousCommand = command;

    switch (segment.command) {
      case SvgPathSegType.cubicToRel:
      case SvgPathSegType.cubicToAbs:
        segment.point1 = _PathOffset(_parseNumber(), _parseNumber());
        continue cubic_smooth;
      case SvgPathSegType.smoothCubicToRel:
      cubic_smooth:
      case SvgPathSegType.smoothCubicToAbs:
        segment.point2 = _PathOffset(_parseNumber(), _parseNumber());
        continue quad_smooth;
      case SvgPathSegType.moveToRel:
      case SvgPathSegType.moveToAbs:
      case SvgPathSegType.lineToRel:
      case SvgPathSegType.lineToAbs:
      case SvgPathSegType.smoothQuadToRel:
      quad_smooth:
      case SvgPathSegType.smoothQuadToAbs:
        segment.targetPoint = _PathOffset(_parseNumber(), _parseNumber());
        break;
      case SvgPathSegType.lineToHorizontalRel:
      case SvgPathSegType.lineToHorizontalAbs:
        segment.targetPoint =
            _PathOffset(_parseNumber(), segment.targetPoint.dy);
        break;
      case SvgPathSegType.lineToVerticalRel:
      case SvgPathSegType.lineToVerticalAbs:
        segment.targetPoint =
            _PathOffset(segment.targetPoint.dx, _parseNumber());
        break;
      case SvgPathSegType.close:
        _skipOptionalSvgSpaces();
        break;
      case SvgPathSegType.quadToRel:
      case SvgPathSegType.quadToAbs:
        segment.point1 = _PathOffset(_parseNumber(), _parseNumber());
        segment.targetPoint = _PathOffset(_parseNumber(), _parseNumber());
        break;
      case SvgPathSegType.arcToRel:
      case SvgPathSegType.arcToAbs:
        segment.point1 = _PathOffset(_parseNumber(), _parseNumber());
        segment.arcAngle = _parseNumber();
        segment.arcLarge = _parseArcFlag();
        segment.arcSweep = _parseArcFlag();
        segment.targetPoint = _PathOffset(_parseNumber(), _parseNumber());
        break;
      case SvgPathSegType.unknown:
        throw StateError('Unknown segment command');
    }

    return segment;
  }
}

class OffsetHelper {
  static _PathOffset reflectedPoint(
      _PathOffset reflectedIn, _PathOffset pointToReflect) {
    return _PathOffset(2 * reflectedIn.dx - pointToReflect.dx,
        2 * reflectedIn.dy - pointToReflect.dy);
  }

  static const double _kOneOverThree = 1.0 / 3.0;

  /// Blend the points with a ratio (1/3):(2/3).
  static _PathOffset blendPoints(_PathOffset p1, _PathOffset p2) {
    return _PathOffset((p1.dx + 2 * p2.dx) * _kOneOverThree,
        (p1.dy + 2 * p2.dy) * _kOneOverThree);
  }
}

bool isCubicCommand(SvgPathSegType command) {
  return command == SvgPathSegType.cubicToAbs ||
      command == SvgPathSegType.cubicToRel ||
      command == SvgPathSegType.smoothCubicToAbs ||
      command == SvgPathSegType.smoothCubicToRel;
}

bool isQuadraticCommand(SvgPathSegType command) {
  return command == SvgPathSegType.quadToAbs ||
      command == SvgPathSegType.quadToRel ||
      command == SvgPathSegType.smoothQuadToAbs ||
      command == SvgPathSegType.smoothQuadToRel;
}

// TODO(dnfield): This can probably be cleaned up a bit.  Some of this was designed in such a way to pack data/optimize for C++
// There are probably better/clearer ways to do it for Dart.
class PathSegmentData {
  PathSegmentData()
      : command = SvgPathSegType.unknown,
        arcSweep = false,
        arcLarge = false;

  _PathOffset get arcRadii => point1;

  double get arcAngle => point2.dx;
  set arcAngle(double angle) => point2 = _PathOffset(angle, point2.dy);

  double get r1 => arcRadii.dx;
  double get r2 => arcRadii.dy;

  bool get largeArcFlag => arcLarge;
  bool get sweepFlag => arcSweep;

  double get x => targetPoint.dx;
  double get y => targetPoint.dy;

  double get x1 => point1.dx;
  double get y1 => point1.dy;

  double get x2 => point2.dx;
  double get y2 => point2.dy;

  SvgPathSegType command;
  _PathOffset targetPoint = _PathOffset.zero;
  _PathOffset point1 = _PathOffset.zero;
  _PathOffset point2 = _PathOffset.zero;
  bool arcSweep;
  bool arcLarge;

  @override
  String toString() {
    return 'PathSegmentData{$command $targetPoint $point1 $point2 $arcSweep $arcLarge}';
  }
}

class SvgPathNormalizer {
  _PathOffset _currentPoint = _PathOffset.zero;
  _PathOffset _subPathPoint = _PathOffset.zero;
  _PathOffset _controlPoint = _PathOffset.zero;
  SvgPathSegType _lastCommand = SvgPathSegType.unknown;

  void emitSegment(PathSegmentData segment, PathProxy path) {
    final PathSegmentData normSeg = segment;
    assert(_currentPoint != null); // ignore: unnecessary_null_comparison
    // Convert relative points to absolute points.
    switch (segment.command) {
      case SvgPathSegType.quadToRel:
        normSeg.point1 += _currentPoint;
        normSeg.targetPoint += _currentPoint;
        break;
      case SvgPathSegType.cubicToRel:
        normSeg.point1 += _currentPoint;
        continue smooth_rel;
      smooth_rel:
      case SvgPathSegType.smoothCubicToRel:
        normSeg.point2 += _currentPoint;
        continue arc_rel;
      case SvgPathSegType.moveToRel:
      case SvgPathSegType.lineToRel:
      case SvgPathSegType.lineToHorizontalRel:
      case SvgPathSegType.lineToVerticalRel:
      case SvgPathSegType.smoothQuadToRel:
      arc_rel:
      case SvgPathSegType.arcToRel:
        normSeg.targetPoint += _currentPoint;
        break;
      case SvgPathSegType.lineToHorizontalAbs:
        normSeg.targetPoint =
            _PathOffset(normSeg.targetPoint.dx, _currentPoint.dy);
        break;
      case SvgPathSegType.lineToVerticalAbs:
        normSeg.targetPoint =
            _PathOffset(_currentPoint.dx, normSeg.targetPoint.dy);
        break;
      case SvgPathSegType.close:
        // Reset m_currentPoint for the next path.
        normSeg.targetPoint = _subPathPoint;
        break;
      default:
        break;
    }

    // Update command verb, handle smooth segments and convert quadratic curve
    // segments to cubics.
    switch (segment.command) {
      case SvgPathSegType.moveToRel:
      case SvgPathSegType.moveToAbs:
        _subPathPoint = normSeg.targetPoint;
        // normSeg.command = SvgPathSegType.moveToAbs;
        path.moveTo(normSeg.targetPoint.dx, normSeg.targetPoint.dy);
        break;
      case SvgPathSegType.lineToRel:
      case SvgPathSegType.lineToAbs:
      case SvgPathSegType.lineToHorizontalRel:
      case SvgPathSegType.lineToHorizontalAbs:
      case SvgPathSegType.lineToVerticalRel:
      case SvgPathSegType.lineToVerticalAbs:
        // normSeg.command = SvgPathSegType.lineToAbs;
        path.lineTo(normSeg.targetPoint.dx, normSeg.targetPoint.dy);
        break;
      case SvgPathSegType.close:
        // normSeg.command = SvgPathSegType.close;
        path.close();
        break;
      case SvgPathSegType.smoothCubicToRel:
      case SvgPathSegType.smoothCubicToAbs:
        if (!isCubicCommand(_lastCommand)) {
          normSeg.point1 = _currentPoint;
        } else {
          normSeg.point1 = OffsetHelper.reflectedPoint(
            _currentPoint,
            _controlPoint,
          );
        }
        continue cubic_abs2;
      case SvgPathSegType.cubicToRel:
      cubic_abs2:
      case SvgPathSegType.cubicToAbs:
        _controlPoint = normSeg.point2;
        // normSeg.command = SvgPathSegType.cubicToAbs;
        path.cubicTo(
          normSeg.point1.dx,
          normSeg.point1.dy,
          normSeg.point2.dx,
          normSeg.point2.dy,
          normSeg.targetPoint.dx,
          normSeg.targetPoint.dy,
        );
        break;
      case SvgPathSegType.smoothQuadToRel:
      case SvgPathSegType.smoothQuadToAbs:
        if (!isQuadraticCommand(_lastCommand)) {
          normSeg.point1 = _currentPoint;
        } else {
          normSeg.point1 = OffsetHelper.reflectedPoint(
            _currentPoint,
            _controlPoint,
          );
        }
        continue quad_abs2;
      case SvgPathSegType.quadToRel:
      quad_abs2:
      case SvgPathSegType.quadToAbs:
        // Save the unmodified control point.
        _controlPoint = normSeg.point1;
        normSeg.point1 = OffsetHelper.blendPoints(_currentPoint, _controlPoint);
        normSeg.point2 = OffsetHelper.blendPoints(
          normSeg.targetPoint,
          _controlPoint,
        );
        // normSeg.command = SvgPathSegType.cubicToAbs;
        path.cubicTo(
          normSeg.point1.dx,
          normSeg.point1.dy,
          normSeg.point2.dx,
          normSeg.point2.dy,
          normSeg.targetPoint.dx,
          normSeg.targetPoint.dy,
        );
        break;
      case SvgPathSegType.arcToRel:
      case SvgPathSegType.arcToAbs:
        if (!_decomposeArcToCubic(_currentPoint, normSeg, path)) {
          // On failure, emit a line segment to the target point.
          // normSeg.command = SvgPathSegType.lineToAbs;
          path.lineTo(normSeg.targetPoint.dx, normSeg.targetPoint.dy);
          // } else {
          //   // decomposeArcToCubic() has already emitted the normalized
          //   // segments, so set command to PathSegArcAbs, to skip any further
          //   // emit.
          //   // normSeg.command = SvgPathSegType.arcToAbs;
        }
        break;
      default:
        throw StateError('Invalid command type in path');
    }

    _currentPoint = normSeg.targetPoint;

    if (!isCubicCommand(segment.command) &&
        !isQuadraticCommand(segment.command)) {
      _controlPoint = _currentPoint;
    }

    _lastCommand = segment.command;
  }

// This works by converting the SVG arc to "simple" beziers.
// Partly adapted from Niko's code in kdelibs/kdecore/svgicons.
// See also SVG implementation notes:
// http://www.w3.org/TR/SVG/implnote.html#ArcConversionEndpointToCenter
  bool _decomposeArcToCubic(
    _PathOffset currentPoint,
    PathSegmentData arcSegment,
    PathProxy path,
  ) {
    // If rx = 0 or ry = 0 then this arc is treated as a straight line segment (a
    // "lineto") joining the endpoints.
    // http://www.w3.org/TR/SVG/implnote.html#ArcOutOfRangeParameters
    double rx = arcSegment.arcRadii.dx.abs();
    double ry = arcSegment.arcRadii.dy.abs();
    if (rx == 0 || ry == 0) {
      return false;
    }

    // If the current point and target point for the arc are identical, it should
    // be treated as a zero length path. This ensures continuity in animations.
    if (arcSegment.targetPoint == currentPoint) {
      return false;
    }

    final double angle = arcSegment.arcAngle;

    final _PathOffset midPointDistance =
        (currentPoint - arcSegment.targetPoint) * 0.5;

    final Matrix4 pointTransform = Matrix4.identity();
    pointTransform.rotateZ(-angle);

    final _PathOffset transformedMidPoint = _mapPoint(
      pointTransform,
      _PathOffset(
        midPointDistance.dx,
        midPointDistance.dy,
      ),
    );

    final double squareRx = rx * rx;
    final double squareRy = ry * ry;
    final double squareX = transformedMidPoint.dx * transformedMidPoint.dx;
    final double squareY = transformedMidPoint.dy * transformedMidPoint.dy;

    // Check if the radii are big enough to draw the arc, scale radii if not.
    // http://www.w3.org/TR/SVG/implnote.html#ArcCorrectionOutOfRangeRadii
    final double radiiScale = squareX / squareRx + squareY / squareRy;
    if (radiiScale > 1.0) {
      rx *= math.sqrt(radiiScale);
      ry *= math.sqrt(radiiScale);
    }
    pointTransform.setIdentity();

    pointTransform.scale(1.0 / rx, 1.0 / ry);
    pointTransform.rotateZ(-angle);

    _PathOffset point1 = _mapPoint(pointTransform, currentPoint);
    _PathOffset point2 = _mapPoint(pointTransform, arcSegment.targetPoint);
    _PathOffset delta = point2 - point1;

    final double d = delta.dx * delta.dx + delta.dy * delta.dy;
    final double scaleFactorSquared = math.max(1.0 / d - 0.25, 0.0);
    double scaleFactor = math.sqrt(scaleFactorSquared);
    if (!scaleFactor.isFinite) {
      scaleFactor = 0.0;
    }

    if (arcSegment.arcSweep == arcSegment.arcLarge) {
      scaleFactor = -scaleFactor;
    }

    delta = delta * scaleFactor;
    final _PathOffset centerPoint =
        ((point1 + point2) * 0.5).translate(-delta.dy, delta.dx);

    final double theta1 = (point1 - centerPoint).direction;
    final double theta2 = (point2 - centerPoint).direction;

    double thetaArc = theta2 - theta1;

    if (thetaArc < 0.0 && arcSegment.arcSweep) {
      thetaArc += _twoPiFloat;
    } else if (thetaArc > 0.0 && !arcSegment.arcSweep) {
      thetaArc -= _twoPiFloat;
    }

    pointTransform.setIdentity();
    pointTransform.rotateZ(angle);
    pointTransform.scale(rx, ry);

    // Some results of atan2 on some platform implementations are not exact
    // enough. So that we get more cubic curves than expected here. Adding 0.001f
    // reduces the count of segments to the correct count.
    final int segments = (thetaArc / (_piOverTwoFloat + 0.001)).abs().ceil();
    for (int i = 0; i < segments; ++i) {
      final double startTheta = theta1 + i * thetaArc / segments;
      final double endTheta = theta1 + (i + 1) * thetaArc / segments;

      final double t = (8.0 / 6.0) * math.tan(0.25 * (endTheta - startTheta));
      if (!t.isFinite) {
        return false;
      }
      final double sinStartTheta = math.sin(startTheta);
      final double cosStartTheta = math.cos(startTheta);
      final double sinEndTheta = math.sin(endTheta);
      final double cosEndTheta = math.cos(endTheta);

      point1 = _PathOffset(
        cosStartTheta - t * sinStartTheta,
        sinStartTheta + t * cosStartTheta,
      ).translate(centerPoint.dx, centerPoint.dy);
      final _PathOffset targetPoint = _PathOffset(
        cosEndTheta,
        sinEndTheta,
      ).translate(centerPoint.dx, centerPoint.dy);
      point2 = targetPoint.translate(t * sinEndTheta, -t * cosEndTheta);

      final PathSegmentData cubicSegment = PathSegmentData();
      cubicSegment.command = SvgPathSegType.cubicToAbs;
      cubicSegment.point1 = _mapPoint(pointTransform, point1);
      cubicSegment.point2 = _mapPoint(pointTransform, point2);
      cubicSegment.targetPoint = _mapPoint(pointTransform, targetPoint);

      path.cubicTo(cubicSegment.x1, cubicSegment.y1, cubicSegment.x2,
          cubicSegment.y2, cubicSegment.x, cubicSegment.y);
      //consumer_->EmitSegment(cubicSegment);
    }
    return true;
  }

  _PathOffset _mapPoint(Matrix4 transform, _PathOffset point) {
    // a, b, 0.0, 0.0, c, d, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, e, f, 0.0, 1.0
    return _PathOffset(
      transform.storage[0] * point.dx +
          transform.storage[4] * point.dy +
          transform.storage[12],
      transform.storage[1] * point.dx +
          transform.storage[5] * point.dy +
          transform.storage[13],
    );
  }
}
