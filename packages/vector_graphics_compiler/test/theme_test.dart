// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: prefer_const_constructors

import 'package:flutter_test/flutter_test.dart';
import 'package:vector_graphics_compiler/src/paint.dart';
import 'package:vector_graphics_compiler/src/svg/theme.dart';

void main() {
  group('SvgTheme', () {
    group('constructor', () {
      test('sets currentColor', () {
        const Color currentColor = Color(0xFFB0E3BE);

        expect(
          SvgTheme(
            currentColor: currentColor,
          ).currentColor,
          equals(currentColor),
        );
      });

      test('sets fontSize', () {
        const double fontSize = 14.0;

        expect(
          SvgTheme(
            currentColor: Color(0xFFB0E3BE),
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
            SvgTheme(),
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
          xHeight: 6.0,
        ),
        equals(
          SvgTheme(
            currentColor: Color(0xFF6F2173),
            xHeight: 6.0,
          ),
        ),
      );
    });
  });
}
