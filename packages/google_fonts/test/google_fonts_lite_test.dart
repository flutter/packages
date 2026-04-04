// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  testWidgets('GoogleFontsLite getFont returns the correct font with the given parameters', (WidgetTester tester) async {
    final textStyle = TextStyle(
      color: const Color(0xAABBCCDD),
      fontSize: 20,
      letterSpacing: 20,
      wordSpacing: 20,
      height: 20,
      decorationThickness: 20,
      fontWeight: FontWeight.w300,
      fontStyle: FontStyle.italic,
      textBaseline: TextBaseline.alphabetic,
      locale: const Locale('fr'),
      background: Paint()..color = const Color(0xAABBCCDD),
      shadows: const <Shadow>[Shadow(blurRadius: 1)],
      fontFeatures: const <FontFeature>[FontFeature.slashedZero()],
      decoration: TextDecoration.lineThrough,
      decorationColor: const Color(0xAABBCCDD),
      decorationStyle: TextDecorationStyle.dashed,
    );

    void verifyTextStyle(TextStyle res) {
      expect(res.fontFamily, equals('Lato_300italic'));
      expect(res.color, equals(textStyle.color));
      expect(res.fontSize, equals(textStyle.fontSize));
      expect(res.letterSpacing, equals(textStyle.letterSpacing));
      expect(res.wordSpacing, equals(textStyle.wordSpacing));
      expect(res.decorationThickness, equals(textStyle.decorationThickness));
      expect(res.fontWeight, equals(textStyle.fontWeight));
      expect(res.fontStyle, equals(textStyle.fontStyle));
      expect(res.textBaseline, equals(textStyle.textBaseline));
      expect(res.locale, equals(textStyle.locale));
      expect(res.background, equals(textStyle.background));
      expect(res.shadows, equals(textStyle.shadows));
      expect(res.fontFeatures, equals(textStyle.fontFeatures));
      expect(res.decoration, equals(textStyle.decoration));
      expect(res.decorationColor, equals(textStyle.decorationColor));
      expect(res.decorationStyle, equals(textStyle.decorationStyle));
    }

    verifyTextStyle(GoogleFontsLite.getFont(
      'Lato',
      textStyle: textStyle,
    ));

    verifyTextStyle(GoogleFontsLite.getFont(
      'Lato',
      color: textStyle.color,
      fontSize: textStyle.fontSize,
      letterSpacing: textStyle.letterSpacing,
      wordSpacing: textStyle.wordSpacing,
      height: textStyle.height,
      decorationThickness: textStyle.decorationThickness,
      fontWeight: textStyle.fontWeight,
      fontStyle: textStyle.fontStyle,
      textBaseline: textStyle.textBaseline,
      locale: textStyle.locale,
      background: textStyle.background,
      shadows: textStyle.shadows,
      fontFeatures: textStyle.fontFeatures,
      decoration: textStyle.decoration,
      decorationColor: textStyle.decorationColor,
      decorationStyle: textStyle.decorationStyle,
    ));
  });

  testWidgets('GoogleFontsLite getFont supports fonts with spaces in their family name', (WidgetTester tester) async {
    final TextStyle style = GoogleFontsLite.getFont('Open Sans');
    expect(style.fontFamily, equals('OpenSans_regular'));
    expect(style.fontFamilyFallback, equals(<String>['OpenSans']));
  });

  testWidgets('GoogleFontsLite getFont throws an exception when the fontFamily is unknown', (WidgetTester tester) async {
    expect(
      () => GoogleFontsLite.getFont('ZZZ_NON_EXISTENT_FONT_ZZZ'),
      throwsA(
        isA<Exception>().having(
          (Exception e) => e.toString(),
          'message',
          contains("No font family by name 'ZZZ_NON_EXISTENT_FONT_ZZZ' was found."),
        ),
      ),
    );
  });

  test('GoogleFontsLite.fontsMap keys match GoogleFonts.asMap keys exactly', () {
    expect(GoogleFontsLite.fontsMap.keys, equals(GoogleFonts.asMap().keys));
  });
}
