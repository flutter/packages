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

  /// Returns the segment type corresponding to the letter constant [lookahead].
  static SvgPathSegType mapLetterToSegmentType(int lookahead) {
    return AsciiConstants.letterToSegmentType[lookahead] ??
        SvgPathSegType.unknown;
  }

  /// Map to go from ASCII constant to [SvgPathSegType]
  static const Map<int, SvgPathSegType> letterToSegmentType =
      <int, SvgPathSegType>{
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
