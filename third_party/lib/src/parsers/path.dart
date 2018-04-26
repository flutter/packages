// This code has been "translated" largely from the Chromium/blink source
// for SVG path parsing.

import 'dart:ui' show Path, Offset;
import 'dart:math' show sqrt, max, pi, tan, sin, cos, pow;
import 'package:vector_math/vector_math.dart' show Matrix4;

const double _twoPiFloat = pi * 2.0;
const double _piOverTwoFloat = pi / 2.0;

Path parseSvgPathData(String svg) {
  final SvgPathStringSource parser = new SvgPathStringSource(svg);
  final Path path = new Path();
  final SvgPathNormalizer normalizer = new SvgPathNormalizer();
  for (PathSegmentData seg in parser.parseSegments()) {
    normalizer.emitSegment(seg, path);
  }
  return path;
}

/// SvgPathSegType enumerates the various path segment commands.
///
/// [AsciiConstants] houses the ASCII numeric values of these commands
enum SvgPathSegType {
  /// Indicates initial state or error
  unknown,

  /// Z or z
  close,

  /// M
  moveToAbs,

  /// m
  moveToRel,

  /// L
  lineToAbs,

  /// l
  lineToRel,

  /// C
  cubicToAbs,

  /// c
  cubicToRel,

  /// Q
  quadToAbs,

  /// q
  quadToRel,

  /// A
  arcToAbs,

  /// a
  arcToRel,

  /// H
  lineToHorizontalAbs,

  /// h
  lineToHorizontalRel,

  /// V
  lineToVerticalAbs,

  /// v
  lineToVerticalRel,

  /// S
  smoothCubicToAbs,

  /// s
  smoothCubicToRel,

  /// T
  smoothQuadToAbs,

  /// t
  smoothQuadToRel
}

/// Character constants used internally.  Note that this parser does not
/// properly support non-ascii characters in the path, but it does support
/// unicode encoding.
///
/// Only contains values that are used by the parser (does not contain the full
/// ASCII set).
class AsciiConstants {
  const AsciiConstants._();

  static SvgPathSegType mapLetterToSegmentType(int lookahead) {
    return AsciiConstants.letterToSegmentType[lookahead] ??
        SvgPathSegType.unknown;
  }

  /// Map to go from ASCII constant to [SvgPathSegType]
  static const Map<int, SvgPathSegType> letterToSegmentType = const {
    upperZ: SvgPathSegType.close,
    lowerZ: SvgPathSegType.close,
    upperM: SvgPathSegType.moveToAbs,
    lowerM: SvgPathSegType.moveToRel,
    upperL: SvgPathSegType.lineToAbs,
    lowerL: SvgPathSegType.lineToRel,
    upperC: SvgPathSegType.cubicToAbs,
    lowerC: SvgPathSegType.cubicToRel,
    upperQ: SvgPathSegType.quadToAbs,
    lowerQ: SvgPathSegType.quadToRel,
    upperA: SvgPathSegType.arcToAbs,
    lowerA: SvgPathSegType.arcToRel,
    upperH: SvgPathSegType.lineToHorizontalAbs,
    lowerH: SvgPathSegType.lineToHorizontalRel,
    upperV: SvgPathSegType.lineToVerticalAbs,
    lowerV: SvgPathSegType.lineToVerticalRel,
    upperS: SvgPathSegType.smoothCubicToAbs,
    lowerS: SvgPathSegType.smoothCubicToRel,
    upperT: SvgPathSegType.smoothQuadToAbs,
    lowerT: SvgPathSegType.smoothQuadToRel,
  };

  /// `\t` (horizontal tab).
  static const int slashT = 9;

  /// `\n` (newline).
  static const int slashN = 10;

  /// `\f` (form feed).
  static const int slashF = 12;

  /// `\r` (carriage return).
  static const int slashR = 13;

  /// ` ` (space).
  static const int space = 32;

  /// `+` (plus).
  static const int plus = 43;

  /// `,` (comma).
  static const int comma = 44;

  /// `-` (minus).
  static const int minus = 45;

  /// `.` (period).
  static const int period = 46;

  /// 0 (the number zero).
  static const int number0 = 48;

  /// 1 (the number one).
  static const int number1 = 49;

  /// 2 (the number two).
  static const int number2 = 50;

  /// 3 (the number three).
  static const int number3 = 51;

  /// 4 (the number four).
  static const int number4 = 52;

  /// 5 (the number five).
  static const int number5 = 53;

  /// 6 (the number six).
  static const int number6 = 54;

  /// 7 (the number seven).
  static const int number7 = 55;

  /// 8 (the number eight).
  static const int number8 = 56;

  /// 9 (the number nine).
  static const int number9 = 57;

  /// A
  static const int upperA = 65;

  /// C
  static const int upperC = 67;

  /// E
  static const int upperE = 69;

  /// H
  static const int upperH = 72;

  /// L
  static const int upperL = 76;

  /// M
  static const int upperM = 77;

  /// Q
  static const int upperQ = 81;

  /// S
  static const int upperS = 83;

  /// T
  static const int upperT = 84;

  /// V
  static const int upperV = 86;

  /// Z
  static const int upperZ = 90;

  /// a
  static const int lowerA = 97;

  /// c
  static const int lowerC = 99;

  /// e
  static const int lowerE = 101;

  /// h
  static const int lowerH = 104;

  /// l
  static const int lowerL = 108;

  /// m
  static const int lowerM = 109;

  /// q
  static const int lowerQ = 113;

  /// s
  static const int lowerS = 115;

  /// t
  static const int lowerT = 116;

  /// v
  static const int lowerV = 118;

  /// x
  static const int lowerX = 120;

  /// z
  static const int lowerZ = 122;

  /// `~` (tilde)
  static const int tilde = 126;
}

class SvgPathStringSource {
  SvgPathSegType _previousCommand;
  List<int> _codePoints;
  int _idx;

  SvgPathStringSource(String string) {
    assert(string != null);
    _previousCommand = SvgPathSegType.unknown;
    _codePoints = string.codeUnits;
    _idx = 0;
    _skipOptionalSvgSpaces();
  }

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
    while (_idx < _codePoints.length && _isHtmlSpace(_codePoints[_idx])) _idx++;
    return _idx < _codePoints.length;
  }

  bool _skipOptionalSvgSpacesOrDelimiter(
      [int delimiter = AsciiConstants.comma]) {
    if (_idx < _codePoints.length &&
        !_isHtmlSpace(_codePoints[_idx]) &&
        _codePoints[_idx] != delimiter) return false;
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
      int lookahead, SvgPathSegType nextCommand) {
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
    return x >= 37 && x <= 38;
  }

  // We use this generic parseNumber function to allow the Path parsing code to
  // work at a higher precision internally, without any unnecessary runtime cost
  // or code complexity.
  double _parseNumber() {
    _skipOptionalSvgSpaces();

    // read the sign
    int sign = 1;
    int end = _codePoints.length;
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
      throw new StateError(
          'First character of a number must be one of [0-9+-.]');

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
      if (!_isValidRange(integer)) throw new StateError('Numeric overflow');
    }

    double decimal = 0.0;
    if (_idx < end && _codePoints[_idx] == AsciiConstants.period) {
      // read the decimals
      _idx++;

      // There must be a least one digit following the .
      if (_idx >= end ||
          _codePoints[_idx] < AsciiConstants.number0 ||
          _codePoints[_idx] > AsciiConstants.number9)
        throw new StateError(
            'There must be at least one digit following the .');

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
        throw new StateError('Missing exponent');

      double exponent = 0.0;
      while (_idx < end &&
          _codePoints[_idx] >= AsciiConstants.number0 &&
          _codePoints[_idx] <= AsciiConstants.number9) {
        exponent *= 10.0;
        exponent += _codePoints[_idx] - AsciiConstants.number0;
        _idx++;
      }
      if (exponentIsNegative) exponent = -exponent;
      // Make sure exponent is valid.
      if (!_isValidExponent(exponent)) throw new StateError('Invalid exponent');
      if (exponent != 0) number *= pow(10.0, exponent);
    }

    // Don't return Infinity() or NaN().
    if (!_isValidRange(number)) throw new StateError('Numeric overflow');

    // if (mode & kAllowTrailingWhitespace)
    _skipOptionalSvgSpacesOrDelimiter();

    return number;
  }

  bool _parseArcFlag() {
    if (!hasMoreData) throw new StateError('Expected more data');
    final int flagChar = _codePoints[_idx];
    _idx++;
    _skipOptionalSvgSpacesOrDelimiter();

    if (flagChar == AsciiConstants.number0)
      return false;
    else if (flagChar == AsciiConstants.number1)
      return true;
    else
      throw new StateError('Invalid flag value');
  }

  bool get hasMoreData => _idx < _codePoints.length;

  Iterable<PathSegmentData> parseSegments() sync* {
    while (hasMoreData) {
      yield parseSegment();
    }
  }

  PathSegmentData parseSegment() {
    assert(hasMoreData);
    PathSegmentData segment = new PathSegmentData();
    int lookahead = _codePoints[_idx];
    SvgPathSegType command = AsciiConstants.mapLetterToSegmentType(lookahead);
    if (_previousCommand == SvgPathSegType.unknown) {
      // First command has to be a moveto.
      if (command != SvgPathSegType.moveToRel &&
          command != SvgPathSegType.moveToAbs) {
        throw new StateError('Expected to find moveTo command');
        // SetErrorMark(SVGParseStatus::kExpectedMoveToCommand);
        // return segment;
      }
      // Consume command letter.
      _idx++;
    } else if (command == SvgPathSegType.unknown) {
      // Possibly an implicit command.
      assert(_previousCommand != SvgPathSegType.unknown);
      command = _maybeImplicitCommand(lookahead, command);
      if (command == null || command == SvgPathSegType.unknown) {
        throw new StateError('Expected a path command');
      }
    } else {
      // Valid explicit command.
      _idx++;
    }

    segment.command = _previousCommand = command;

    switch (segment.command) {
      case SvgPathSegType.cubicToRel:
      case SvgPathSegType.cubicToAbs:
        segment.point1 = new Offset(_parseNumber(), _parseNumber());
        continue cubic_smooth;
      case SvgPathSegType.smoothCubicToRel:
      cubic_smooth:
      case SvgPathSegType.smoothCubicToAbs:
        segment.point2 = new Offset(_parseNumber(), _parseNumber());
        continue quad_smooth;
      case SvgPathSegType.moveToRel:
      case SvgPathSegType.moveToAbs:
      case SvgPathSegType.lineToRel:
      case SvgPathSegType.lineToAbs:
      case SvgPathSegType.smoothQuadToRel:
      quad_smooth:
      case SvgPathSegType.smoothQuadToAbs:
        segment.targetPoint = new Offset(_parseNumber(), _parseNumber());
        break;
      case SvgPathSegType.lineToHorizontalRel:
      case SvgPathSegType.lineToHorizontalAbs:
        segment.targetPoint =
            new Offset(_parseNumber(), segment.targetPoint?.dy ?? 0.0);
        break;
      case SvgPathSegType.lineToVerticalRel:
      case SvgPathSegType.lineToVerticalAbs:
        segment.targetPoint =
            new Offset(segment.targetPoint?.dx ?? 0.0, _parseNumber());
        break;
      case SvgPathSegType.close:
        _skipOptionalSvgSpaces();
        break;
      case SvgPathSegType.quadToRel:
      case SvgPathSegType.quadToAbs:
        segment.point1 = new Offset(_parseNumber(), _parseNumber());
        segment.targetPoint = new Offset(_parseNumber(), _parseNumber());

        break;
      case SvgPathSegType.arcToRel:
      case SvgPathSegType.arcToAbs:
        segment.point1 = new Offset(_parseNumber(), _parseNumber());
        segment.arcAngle = _parseNumber();
        segment.arcLarge = _parseArcFlag();
        segment.arcSweep = _parseArcFlag();
        segment.targetPoint = new Offset(_parseNumber(), _parseNumber());
        break;
      case SvgPathSegType.unknown:
        throw new StateError('Unknown segment command');
    }

    return segment;
  }
}

class OffsetHelper {
  static Offset reflectedPoint(Offset reflectedIn, Offset pointToReflect) {
    return new Offset(2 * reflectedIn.dx - pointToReflect.dx,
        2 * reflectedIn.dy - pointToReflect.dy);
  }

  static const double _kOneOverThree = 1.0 / 3.0;

  /// Blend the points with a ratio (1/3):(2/3).
  static Offset blendPoints(Offset p1, Offset p2) {
    return Offset((p1.dx + 2 * p2.dx) * _kOneOverThree,
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

class PathSegmentData {
  PathSegmentData()
      : command = SvgPathSegType.unknown,
        arcSweep = false,
        arcLarge = false;

  Offset get arcRadii => point1;

  double get arcAngle => point2.dx;
  set arcAngle(double angle) => point2 = new Offset(angle, point2.dy);

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
  Offset targetPoint;
  Offset point1;
  Offset point2;
  bool arcSweep;
  bool arcLarge;

  @override
  String toString() {
    return 'PathSegmentData{$command $targetPoint $point1 $point2 $arcSweep $arcLarge}';
  }
}

class SvgPathNormalizer {
  Offset _currentPoint = Offset.zero;
  Offset _subPathPoint = Offset.zero;
  Offset _controlPoint = Offset.zero;
  SvgPathSegType _lastCommand = SvgPathSegType.unknown;

  void emitSegment(PathSegmentData segment, Path path) {
    PathSegmentData normSeg = segment;
    assert(
        normSeg.command == SvgPathSegType.close || normSeg.targetPoint != null);
    assert(_currentPoint != null);
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
            new Offset(normSeg.targetPoint.dx, _currentPoint.dy);
        break;
      case SvgPathSegType.lineToVerticalAbs:
        normSeg.targetPoint =
            new Offset(_currentPoint.dx, normSeg.targetPoint.dy);
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
        normSeg.command = SvgPathSegType.moveToAbs;
        path.moveTo(normSeg.targetPoint.dx, normSeg.targetPoint.dy);
        break;
      case SvgPathSegType.lineToRel:
      case SvgPathSegType.lineToAbs:
      case SvgPathSegType.lineToHorizontalRel:
      case SvgPathSegType.lineToHorizontalAbs:
      case SvgPathSegType.lineToVerticalRel:
      case SvgPathSegType.lineToVerticalAbs:
        normSeg.command = SvgPathSegType.lineToAbs;
        path.lineTo(normSeg.targetPoint.dx, normSeg.targetPoint.dy);
        break;
      case SvgPathSegType.close:
        normSeg.command = SvgPathSegType.close;
        path.close();
        break;
      case SvgPathSegType.smoothCubicToRel:
      case SvgPathSegType.smoothCubicToAbs:
        if (!isCubicCommand(_lastCommand))
          normSeg.point1 = _currentPoint;
        else
          normSeg.point1 =
              OffsetHelper.reflectedPoint(_currentPoint, _controlPoint);
        continue cubic_abs2;
      case SvgPathSegType.cubicToRel:
      cubic_abs2:
      case SvgPathSegType.cubicToAbs:
        _controlPoint = normSeg.point2;
        normSeg.command = SvgPathSegType.cubicToAbs;
        path.cubicTo(normSeg.point1.dx, normSeg.point1.dy, normSeg.point2.dx,
            normSeg.point2.dy, normSeg.targetPoint.dx, normSeg.targetPoint.dy);
        break;
      case SvgPathSegType.smoothQuadToRel:
      case SvgPathSegType.smoothQuadToAbs:
        if (!isQuadraticCommand(_lastCommand))
          normSeg.point1 = _currentPoint;
        else
          normSeg.point1 =
              OffsetHelper.reflectedPoint(_currentPoint, _controlPoint);
        continue quad_abs2;
      case SvgPathSegType.quadToRel:
      quad_abs2:
      case SvgPathSegType.quadToAbs:
        // Save the unmodified control point.
        _controlPoint = normSeg.point1;
        normSeg.point1 = OffsetHelper.blendPoints(_currentPoint, _controlPoint);
        normSeg.point2 =
            OffsetHelper.blendPoints(normSeg.targetPoint, _controlPoint);
        normSeg.command = SvgPathSegType.cubicToAbs;
        path.cubicTo(normSeg.point1.dx, normSeg.point1.dy, normSeg.point2.dx,
            normSeg.point2.dy, normSeg.targetPoint.dx, normSeg.targetPoint.dy);
        break;
      case SvgPathSegType.arcToRel:
      case SvgPathSegType.arcToAbs:
        if (!_decomposeArcToCubic(_currentPoint, normSeg, path)) {
          // On failure, emit a line segment to the target point.
          normSeg.command = SvgPathSegType.lineToAbs;
          path.lineTo(normSeg.targetPoint.dx, normSeg.targetPoint.dy);
        } else {
          // decomposeArcToCubic() has already emitted the normalized
          // segments, so set command to PathSegArcAbs, to skip any further
          // emit.
          normSeg.command = SvgPathSegType.arcToAbs;
        }
        break;
      default:
        throw new StateError('Invalid command type in path');
    }

    // if (normSeg.command != SvgPathSegType.arcToAbs) {
    //
    //   //consumer_.EmitSegment(normSeg);
    // }

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
      Offset currentPoint, PathSegmentData arcSegment, Path path) {
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

    double angle = arcSegment.arcAngle;

    Offset midPointDistance = currentPoint - arcSegment.targetPoint;
    midPointDistance.scale(0.5, 0.5);

    Matrix4 pointTransform = new Matrix4.identity();
    pointTransform.rotateZ(-angle);

    Offset transformedMidPoint = _mapPoint(
        pointTransform, Offset(midPointDistance.dx, midPointDistance.dy));
    double squareRx = rx * rx;
    double squareRy = ry * ry;
    double squareX = transformedMidPoint.dx * transformedMidPoint.dx;
    double squareY = transformedMidPoint.dy * transformedMidPoint.dy;

    // Check if the radii are big enough to draw the arc, scale radii if not.
    // http://www.w3.org/TR/SVG/implnote.html#ArcCorrectionOutOfRangeRadii
    double radiiScale = squareX / squareRx + squareY / squareRy;
    if (radiiScale > 1) {
      rx *= sqrt(radiiScale);
      ry *= sqrt(radiiScale);
    }

    pointTransform.setIdentity();
    pointTransform.scale(1 / rx, 1 / ry);
    pointTransform.rotateZ(-angle);

    Offset point1 = _mapPoint(pointTransform, currentPoint);
    Offset point2 = _mapPoint(pointTransform, arcSegment.targetPoint);
    Offset delta = point2 - point1;

    double d = delta.dx * delta.dx + delta.dy * delta.dy;
    double scaleFactorSquared = max(1 / d - 0.25, 0.0);

    double scaleFactor = sqrt(scaleFactorSquared);
    if (arcSegment.arcSweep == arcSegment.arcLarge) scaleFactor = -scaleFactor;

    delta.scale(scaleFactor, scaleFactor);
    Offset centerPoint = point1 + point2;
    centerPoint.scale(0.5, 0.5);
    centerPoint.translate(-delta.dx, delta.dy);

    double theta1 = (point1 - centerPoint).direction;
    double theta2 = (point2 - centerPoint).direction;

    double thetaArc = theta2 - theta1;
    if (thetaArc < 0 && arcSegment.arcSweep)
      thetaArc += _twoPiFloat;
    else if (thetaArc > 0 && !arcSegment.arcSweep) thetaArc -= _twoPiFloat;

    pointTransform.setIdentity();
    pointTransform.rotateZ(angle);
    pointTransform.scale(rx, ry);

    // Some results of atan2 on some platform implementations are not exact
    // enough. So that we get more cubic curves than expected here. Adding 0.001f
    // reduces the count of sgements to the correct count.
    final int segments = (thetaArc / (_piOverTwoFloat + 0.001)).abs().ceil();
    for (int i = 0; i < segments; ++i) {
      final double startTheta = theta1 + i * thetaArc / segments;
      final double endTheta = theta1 + (i + 1) * thetaArc / segments;

      final double t = (8 / 6.0) * tan(0.25 * (endTheta - startTheta));
      if (!t.isFinite) return false;
      final double sinStartTheta = sin(startTheta);
      final double cosStartTheta = cos(startTheta);
      final double sinEndTheta = sin(endTheta);
      final double cosEndTheta = cos(endTheta);

      point1 = Offset(
          cosStartTheta - t * sinStartTheta, sinStartTheta + t * cosStartTheta);
      point1.translate(centerPoint.dx, centerPoint.dy);
      final Offset targetPoint = new Offset(cosEndTheta, sinEndTheta);
      targetPoint.translate(centerPoint.dx, centerPoint.dy);
      point2 = targetPoint;
      point2.translate(t * sinEndTheta, -t * cosEndTheta);

      final PathSegmentData cubicSegment = new PathSegmentData();
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

  Offset _mapPoint(Matrix4 transform, Offset point) {
    // a, b, 0.0, 0.0, c, d, 0.0, 0.0, e, f, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0
    return new Offset(
      (transform[0] * point.dx + transform[4] * point.dy + transform[8]),
      (transform[1] * point.dx + transform[5] * point.dy + transform[9]),
    );
  }
}
