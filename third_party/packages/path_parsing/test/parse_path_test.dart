// Test paths taken from:
//   * https://github.com/chromium/chromium/blob/master/third_party/blink/renderer/core/svg/svg_path_parser_test.cc

import 'package:path_parsing/path_parsing.dart';
import 'package:path_parsing/src/path_segment_type.dart';
import 'package:test/test.dart';

// TODO(dnfield): a bunch of better tests could be written to track that commands are actually called with expected values/order
// For now we just want to know that something gets emitted and no exceptions are thrown (that's all the legacy tests really did anyway).
class TestPathProxy extends PathProxy {
  bool called = false;
  @override
  void close() {
    called = true;
  }

  @override
  void cubicTo(
    double x1,
    double y1,
    double x2,
    double y2,
    double x3,
    double y3,
  ) {
    called = true;
  }

  @override
  void lineTo(double x, double y) {
    called = true;
  }

  @override
  void moveTo(double x, double y) {
    called = true;
  }
}

void main() {
  void assertValidPath(String input) {
    final TestPathProxy proxy = TestPathProxy();
    // these shouldn't throw or assert
    writeSvgPathDataToPath(input, proxy);
    expect(proxy.called, true);
  }

  void assertInvalidPath(String input) {
    expect(
        () => writeSvgPathDataToPath(input, TestPathProxy()), throwsStateError);
  }

  test('Valid Paths', () {
    assertValidPath('M1,2');
    assertValidPath('m1,2');
    assertValidPath('M100,200 m3,4');
    assertValidPath('M100,200 L3,4');
    assertValidPath('M100,200 l3,4');
    assertValidPath('M100,200 H3');
    assertValidPath('M100,200 h3');
    assertValidPath('M100,200 V3');
    assertValidPath('M100,200 v3');
    assertValidPath('M100,200 Z');
    assertValidPath('M100,200 z');
    assertValidPath('M100,200 C3,4,5,6,7,8');
    assertValidPath('M100,200 c3,4,5,6,7,8');
    assertValidPath('M100,200 S3,4,5,6');
    assertValidPath('M100,200 s3,4,5,6');
    assertValidPath('M100,200 Q3,4,5,6');
    assertValidPath('M100,200 q3,4,5,6');
    assertValidPath('M100,200 T3,4');
    assertValidPath('M100,200 t3,4');
    assertValidPath('M100,200 A3,4,5,0,0,6,7');
    assertValidPath('M100,200 A3,4,5,1,0,6,7');
    assertValidPath('M100,200 A3,4,5,0,1,6,7');
    assertValidPath('M100,200 A3,4,5,1,1,6,7');
    assertValidPath('M100,200 a3,4,5,0,0,6,7');
    assertValidPath('M100,200 a3,4,5,0,1,6,7');
    assertValidPath('M100,200 a3,4,5,1,0,6,7');
    assertValidPath('M100,200 a3,4,5,1,1,6,7');
    assertValidPath('M100,200 a3,4,5,006,7');
    assertValidPath('M100,200 a3,4,5,016,7');
    assertValidPath('M100,200 a3,4,5,106,7');
    assertValidPath('M100,200 a3,4,5,116,7');
    assertValidPath('''
M19.0281,19.40466 20.7195,19.40466 20.7195,15.71439 24.11486,15.71439 24.11486,14.36762 20.7195,14.36762
20.7195,11.68641 24.74134,11.68641 24.74134,10.34618 19.0281,10.34618 	z''');

    assertValidPath(
        'M100,200 a0,4,5,0,0,10,0 a4,0,5,0,0,0,10 a0,0,5,0,0,-10,0 z');

    assertValidPath('M1,2,3,4');
    assertValidPath('m100,200,3,4');

    assertValidPath('M 100-200');
    assertValidPath('M 0.6.5');

    assertValidPath(' M1,2');
    assertValidPath('  M1,2');
    assertValidPath('\tM1,2');
    assertValidPath('\nM1,2');
    assertValidPath('\rM1,2');
    assertValidPath('M1,2 ');
    assertValidPath('M1,2\t');
    assertValidPath('M1,2\n');
    assertValidPath('M1,2\r');
    // assertValidPath('');
    // assertValidPath(' ');
    assertValidPath('M.1 .2 L.3 .4 .5 .6');
    assertValidPath('M1,1h2,3');
    assertValidPath('M1,1H2,3');
    assertValidPath('M1,1v2,3');
    assertValidPath('M1,1V2,3');
    assertValidPath('M1,1c2,3 4,5 6,7 8,9 10,11 12,13');
    assertValidPath('M1,1C2,3 4,5 6,7 8,9 10,11 12,13');
    assertValidPath('M1,1s2,3 4,5 6,7 8,9');
    assertValidPath('M1,1S2,3 4,5 6,7 8,9');
    assertValidPath('M1,1q2,3 4,5 6,7 8,9');
    assertValidPath('M1,1Q2,3 4,5 6,7 8,9');
    assertValidPath('M1,1t2,3 4,5');
    assertValidPath('M1,1T2,3 4,5');
    assertValidPath('M1,1a2,3,4,0,0,5,6 7,8,9,0,0,10,11');
    assertValidPath('M1,1A2,3,4,0,0,5,6 7,8,9,0,0,10,11');
    assertValidPath(
        'M22.1595 3.80852C19.6789 1.35254 16.3807 -4.80966e-07 12.8727 '
        '-4.80966e-07C9.36452 -4.80966e-07 6.06642 1.35254 3.58579 3.80852C1.77297 5.60333 '
        '0.53896 7.8599 0.0171889 10.3343C-0.0738999 10.7666 0.206109 11.1901 0.64265 '
        '11.2803C1.07908 11.3706 1.50711 11.0934 1.5982 10.661C2.05552 8.49195 3.13775 6.51338 4.72783 '
        '4.9391C9.21893 0.492838 16.5262 0.492728 21.0173 4.9391C25.5082 9.38548 25.5082 16.6202 '
        '21.0173 21.0667C16.5265 25.5132 9.21893 25.5133 4.72805 21.0669C3.17644 19.5307 2.10538 '
        '17.6035 1.63081 15.4937C1.53386 15.0627 1.10252 14.7908 0.66697 14.887C0.231645 14.983 '
        '-0.0427272 15.4103 0.0542205 15.8413C0.595668 18.2481 1.81686 20.4461 3.5859 '
        '22.1976C6.14623 24.7325 9.50955 26 12.8727 26C16.236 26 19.5991 24.7326 22.1595 22.1976C27.2802 '
        '17.1277 27.2802 8.87841 22.1595 3.80852Z');
    assertValidPath(
        'm18 11.8a.41.41 0 0 1 .24.08l.59.43h.05.72a.4.4 0 0 1 .39.28l.22.69a.08.08 0 '
        '0 0 0 0l.58.43a.41.41 0 0 1 .15.45l-.22.68a.09.09 0 0 0 0 .07l.22.68a.4.4 0 0 1 '
        '-.15.46l-.58.42a.1.1 0 0 0 0 0l-.22.68a.41.41 0 0 1 -.38.29h-.79l-.58.43a.41.41 0 '
        '0 1 -.24.08.46.46 0 0 1 -.24-.08l-.58-.43h-.06-.72a.41.41 0 0 1 -.39-.28l-.22-.68a.1.1 '
        '0 0 0 0 0l-.58-.43a.42.42 0 0 1 -.15-.46l.23-.67v-.02l-.29-.68a.43.43 0 0 1 '
        '.15-.46l.58-.42a.1.1 0 0 0 0-.05l.27-.69a.42.42 0 0 1 .39-.28h.78l.58-.43a.43.43 0 '
        '0 1 .25-.09m0-1a1.37 1.37 0 0 0 -.83.27l-.34.25h-.43a1.42 1.42 0 0 0 -1.34 '
        '1l-.13.4-.35.25a1.42 1.42 0 0 0 -.51 1.58l.13.4-.13.4a1.39 1.39 0 0 0 .52 '
        '1.59l.34.25.13.4a1.41 1.41 0 0 0 1.34 1h.43l.34.26a1.44 1.44 0 0 0 .83.27 1.38 1.38 0 0 0 '
        '.83-.28l.35-.24h.43a1.4 1.4 0 0 0 1.33-1l.13-.4.35-.26a1.39 1.39 0 0 0 '
        '.51-1.57l-.13-.4.13-.41a1.4 1.4 0 0 0 -.51-1.56l-.35-.25-.13-.41a1.4 1.4 0 0 0 '
        '-1.34-1h-.42l-.34-.26a1.43 1.43 0 0 0 -.84-.28z');
  });

  test('Malformed Paths', () {
    assertInvalidPath('M100,200 a3,4,5,2,1,6,7');
    assertInvalidPath('M100,200 a3,4,5,1,2,6,7');

    assertInvalidPath('\vM1,2');
    assertInvalidPath('xM1,2');
    assertInvalidPath('M1,2\v');
    assertInvalidPath('M1,2x');
    assertInvalidPath('M1,2 L40,0#90');

    assertInvalidPath('x');
    assertInvalidPath('L1,2');

    assertInvalidPath('M');
    assertInvalidPath('M0');

    assertInvalidPath('M1,1Z0');
    assertInvalidPath('M1,1z0');

    assertInvalidPath('M1,1c2,3 4,5 6,7 8');
    assertInvalidPath('M1,1C2,3 4,5 6,7 8');
    assertInvalidPath('M1,1s2,3 4,5 6');
    assertInvalidPath('M1,1S2,3 4,5 6');
    assertInvalidPath('M1,1q2,3 4,5 6');
    assertInvalidPath('M1,1Q2,3 4,5 6');
    assertInvalidPath('M1,1t2,3 4');
    assertInvalidPath('M1,1T2,3 4');
    assertInvalidPath('M1,1a2,3,4,0,0,5,6 7');
    assertInvalidPath('M1,1A2,3,4,0,0,5,6 7');
  });

  test('Missing commands/numbers/flags', () {
    // Missing initial moveto.
    assertInvalidPath(' 10 10');
    assertInvalidPath('L 10 10');
    // Invalid command letter.
    assertInvalidPath('M 10 10 #');
    assertInvalidPath('M 10 10 E 100 100');
    // Invalid number.
    assertInvalidPath('M 10 10 L100 ');
    assertInvalidPath('M 10 10 L100 #');
    assertInvalidPath('M 10 10 L100#100');
    assertInvalidPath('M0,0 A#,10 0 0,0 20,20');
    assertInvalidPath('M0,0 A10,# 0 0,0 20,20');
    assertInvalidPath('M0,0 A10,10 # 0,0 20,20');
    assertInvalidPath('M0,0 A10,10 0 0,0 #,20');
    assertInvalidPath('M0,0 A10,10 0 0,0 20,#');
    // Invalid arc-flag.
    assertInvalidPath('M0,0 A10,10 0 #,0 20,20');
    assertInvalidPath('M0,0 A10,10 0 0,# 20,20');
    assertInvalidPath('M0,0 A10,10 0 0,2 20,20');
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
