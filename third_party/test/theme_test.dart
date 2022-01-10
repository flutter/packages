// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_svg/src/svg/theme.dart';
import 'package:test/test.dart';

void main() {
  group('SvgTheme', () {
    group('constructor', () {
      test('sets currentColor', () {
        const Color currentColor = Color(0xFFB0E3BE);

        expect(
          SvgTheme(
            currentColor: currentColor,
            fontSize: 14.0,
          ).currentColor,
          equals(currentColor),
        );
      });

      test('sets fontSize', () {
        const double fontSize = 14.0;

        expect(
          SvgTheme(
            currentColor: Color(0xFFB0E3BE),
            fontSize: fontSize,
          ).fontSize,
          equals(fontSize),
        );
      });

      test(
          'sets fontSize to 14 '
          'by default', () {
        expect(
          SvgTheme(),
          equals(
            SvgTheme(fontSize: 14.0),
          ),
        );
      });

      test('sets xHeight', () {
        const double xHeight = 8.0;

        expect(
          SvgTheme(
            fontSize: 26.0,
            xHeight: xHeight,
          ).xHeight,
          equals(xHeight),
        );
      });

      test(
          'sets xHeight as fontSize divided by 2 '
          'by default', () {
        const double fontSize = 16.0;

        expect(
          SvgTheme(
            fontSize: fontSize,
          ).xHeight,
          equals(fontSize / 2),
        );
      });
    });

    test('supports value equality', () {
      expect(
        SvgTheme(
          currentColor: Color(0xFF6F2173),
          fontSize: 14.0,
          xHeight: 6.0,
        ),
        equals(
          SvgTheme(
            currentColor: Color(0xFF6F2173),
            fontSize: 14.0,
            xHeight: 6.0,
          ),
        ),
      );
    });
  });
}
