// This is a basic Flutter widget test.
// To perform an interaction with a widget in your test, use the WidgetTester utility that Flutter
// provides. For example, you can send tap and scroll gestures. You can also use WidgetTester to
// find child widgets in the widget tree, read text, and verify that the values of widget properties
// are correct.

import 'dart:ui';
import 'package:test/test.dart';

import 'package:flutter_svg/src/parsers/path.dart';

void main() {
  test('Path parse test', () {
    var parser = new SvgPathStringSource('''M19.0281,19.40466 20.7195,19.40466 20.7195,15.71439 24.11486,15.71439 24.11486,14.36762 20.7195,14.36762 
20.7195,11.68641 24.74134,11.68641 24.74134,10.34618 19.0281,10.34618 	z''');
    SvgPathNormalizer normalizer = new SvgPathNormalizer();
    for (PathSegmentData seg in parser.parseSegments()) {
      print(seg);
      normalizer.emitSegment(seg, new Path());
    }
  });

  test('Check character constants', () {
    expect(AsciiConstants.slashT, '\t'.codeUnitAt(0));
    expect(AsciiConstants.slashN, '\n'.codeUnitAt(0));
    expect(AsciiConstants.slashF, '\f'.codeUnitAt(0));
    expect(AsciiConstants.slashR, '\r'.codeUnitAt(0));
    expect(AsciiConstants.space, ' '.codeUnitAt(0));
    expect(AsciiConstants.period, '.'.codeUnitAt(0));
    expect(AsciiConstants.plus, '+'.codeUnitAt(0));
    expect(AsciiConstants.comma, ','.codeUnitAt(0));
    expect(AsciiConstants.minus, '-'.codeUnitAt(0));
    expect(AsciiConstants.number0, '0'.codeUnitAt(0));
    expect(AsciiConstants.number1, '1'.codeUnitAt(0));
    expect(AsciiConstants.number2, '2'.codeUnitAt(0));
    expect(AsciiConstants.number3, '3'.codeUnitAt(0));
    expect(AsciiConstants.number4, '4'.codeUnitAt(0));
    expect(AsciiConstants.number5, '5'.codeUnitAt(0));
    expect(AsciiConstants.number6, '6'.codeUnitAt(0));
    expect(AsciiConstants.number7, '7'.codeUnitAt(0));
    expect(AsciiConstants.number8, '8'.codeUnitAt(0));
    expect(AsciiConstants.number9, '9'.codeUnitAt(0));
    expect(AsciiConstants.upperA, 'A'.codeUnitAt(0));
    expect(AsciiConstants.upperC, 'C'.codeUnitAt(0));
    expect(AsciiConstants.upperE, 'E'.codeUnitAt(0));
    expect(AsciiConstants.upperH, 'H'.codeUnitAt(0));
    expect(AsciiConstants.upperL, 'L'.codeUnitAt(0));
    expect(AsciiConstants.upperM, 'M'.codeUnitAt(0));
    expect(AsciiConstants.upperQ, 'Q'.codeUnitAt(0));
    expect(AsciiConstants.upperS, 'S'.codeUnitAt(0));
    expect(AsciiConstants.upperT, 'T'.codeUnitAt(0));
    expect(AsciiConstants.upperV, 'V'.codeUnitAt(0));
    expect(AsciiConstants.upperZ, 'Z'.codeUnitAt(0));
    expect(AsciiConstants.lowerA, 'a'.codeUnitAt(0));
    expect(AsciiConstants.lowerC, 'c'.codeUnitAt(0));
    expect(AsciiConstants.lowerE, 'e'.codeUnitAt(0));
    expect(AsciiConstants.lowerH, 'h'.codeUnitAt(0));
    expect(AsciiConstants.lowerL, 'l'.codeUnitAt(0));
    expect(AsciiConstants.lowerM, 'm'.codeUnitAt(0));
    expect(AsciiConstants.lowerQ, 'q'.codeUnitAt(0));
    expect(AsciiConstants.lowerS, 's'.codeUnitAt(0));
    expect(AsciiConstants.lowerT, 't'.codeUnitAt(0));
    expect(AsciiConstants.lowerV, 'v'.codeUnitAt(0));
    expect(AsciiConstants.lowerX, 'x'.codeUnitAt(0));
    expect(AsciiConstants.lowerZ, 'z'.codeUnitAt(0));
    expect(AsciiConstants.tilde, '~'.codeUnitAt(0));
  });
}
