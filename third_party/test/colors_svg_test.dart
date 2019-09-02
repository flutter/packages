import 'dart:ui' show Color;

import 'package:flutter_svg/src/svg/colors.dart';
import 'package:test/test.dart';

void main() {
  const Color white = Color(0xFFFFFFFF);
  const Color black = Color(0xFF000000);
  test('Color Tests', () {
    expect(parseColor('#FFFFFF'), white);
    expect(parseColor('white'), white);
    expect(parseColor('rgb(255, 255, 255)'), white);
    expect(parseColor('rgb(100%, 100%, 100%)'), white);
    expect(parseColor('RGB(  100%   ,   100.0% ,  99.9999% )'), white);
    expect(parseColor('rGb( .0%,0.0%,.0000001% )'), black);
    expect(parseColor('rgba(255,255, 255, 0.0)'), const Color(0x00FFFFFF));
    expect(parseColor('rgba(0,0, 0, 1.0)'), const Color(0xFF000000));
    expect(parseColor('#DDFFFFFF'), const Color(0xDDFFFFFF));
    expect(parseColor(''), black);
    expect(parseColor('transparent'), const Color(0x00FFFFFF));
    expect(parseColor('none'), null);
    expect(parseColor('hsl(0,0%,0%)'), const Color(0xFF000000));
    expect(parseColor('hsl(0,0%,100%)'), const Color(0xFFFFFFFF));
    expect(parseColor('hsl(136,47%,79%)'), const Color(0xFFB0E3BE));
    expect(parseColor('hsl(136,80%,9%)'), const Color(0xFF05290E));
    expect(parseColor('hsl(135,100%,50%)'), const Color(0xFF00FF40));
    expect(parseColor('hsl(136,54%,43%)'), const Color(0xFF32A952));
    expect(parseColor('hsla(0,0%,100%, 0.0)'), const Color(0x00FFFFFF));
    expect(() => parseColor('invalid name'), throwsStateError);
  });
}
