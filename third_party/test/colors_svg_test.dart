import 'dart:ui' show Color;

import 'package:test/test.dart';

import 'xml_svg_test.dart';

void main() {
  const Color white = Color(0xFFFFFFFF);
  const Color black = Color(0xFF000000);
  test('Color Tests', () {
    final TestSvgParserState testSvgParserState = TestSvgParserState();
    expect(testSvgParserState.parseColor('#FFFFFF'), white);
    expect(testSvgParserState.parseColor('white'), white);
    expect(testSvgParserState.parseColor('rgb(255, 255, 255)'), white);
    expect(testSvgParserState.parseColor('rgb(100%, 100%, 100%)'), white);
    expect(
        testSvgParserState.parseColor('RGB(  100%   ,   100.0% ,  99.9999% )'),
        white);
    expect(testSvgParserState.parseColor('rGb( .0%,0.0%,.0000001% )'), black);
    expect(testSvgParserState.parseColor('rgba(255,255, 255, 0.0)'),
        const Color(0x00FFFFFF));
    expect(testSvgParserState.parseColor('rgba(0,0, 0, 1.0)'),
        const Color(0xFF000000));
    expect(testSvgParserState.parseColor('#DDFFFFFF'), const Color(0xDDFFFFFF));
    expect(testSvgParserState.parseColor(''), null);
    expect(
        testSvgParserState.parseColor('transparent'), const Color(0x00FFFFFF));
    expect(testSvgParserState.parseColor('none'), null);
    expect(
        testSvgParserState.parseColor('hsl(0,0%,0%)'), const Color(0xFF000000));
    expect(testSvgParserState.parseColor('hsl(0,0%,100%)'),
        const Color(0xFFFFFFFF));
    expect(testSvgParserState.parseColor('hsl(136,47%,79%)'),
        const Color(0xFFB0E3BE));
    expect(testSvgParserState.parseColor('hsl(136,80%,9%)'),
        const Color(0xFF05290E));
    expect(testSvgParserState.parseColor('hsl(17,55%,29%)'),
        const Color(0xFF733821));
    expect(testSvgParserState.parseColor('hsl(78,55%,29%)'),
        const Color(0xFF5A7321));
    expect(testSvgParserState.parseColor('hsl(192,55%,29%)'),
        const Color(0xFF216273));
    expect(testSvgParserState.parseColor('hsl(297,55%,29%)'),
        const Color(0xFF6F2173));
    expect(testSvgParserState.parseColor('hsla(0,0%,100%, 0.0)'),
        const Color(0x00FFFFFF));
    expect(testSvgParserState.parseColor('currentColor'), null);
    expect(testSvgParserState.parseColor('currentcolor'), null);
    expect(
        () => testSvgParserState.parseColor('invalid name'), throwsStateError);
  });
}
