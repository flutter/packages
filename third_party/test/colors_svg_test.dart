import 'dart:ui' show Color;

import 'package:test/test.dart';
import 'package:flutter_svg/src/svg/colors.dart';

void main() {
  const Color white = const Color(0xFFFFFFFF);
  const Color black = const Color(0xFF000000);
  test('Color Tests', () {
    expect(parseColor('#FFFFFF'), white);
    expect(parseColor('white'), white);
    expect(parseColor('rgb(255, 255, 255)'), white);
    expect(parseColor('rgb(100%, 100%, 100%)'), white);
    expect(parseColor('RGB(  100%   ,   100.0% ,  99.9999% )'), white);
    expect(parseColor('rGb( .0%,0.0%,.0000001% )'), black);
    expect(parseColor('rgba(255,255, 255, 255)'), white);
    expect(parseColor('#DDFFFFFF'), const Color(0xDDFFFFFF));
    expect(parseColor(''), black);
    expect(parseColor('none'), null);
    expect(() => parseColor('invalid name'), throwsStateError);
  });
}
