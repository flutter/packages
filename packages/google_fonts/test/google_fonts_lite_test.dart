// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_fonts/google_fonts_lite.dart' as lite;
import 'package:google_fonts/src/google_fonts_base.dart';
import 'package:mockito/mockito.dart';

class MockAssetManifest extends Mock implements AssetManifest {
  @override
  List<String> listAssets() => <String>[];
}

void main() {
  setUpAll(() {
    assetManifest = MockAssetManifest();
  });

  tearDown(() {
    clearCache();
    pendingFontFutures.clear();
  });
  testWidgets('GoogleFontsLite getFont returns the correct font with the given parameters', (
    WidgetTester tester,
  ) async {
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

    verifyTextStyle(GoogleFontsLite.getFont('Lato', textStyle: textStyle));

    verifyTextStyle(
      GoogleFontsLite.getFont(
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
      ),
    );
  });

  testWidgets('GoogleFontsLite getFont supports fonts with spaces in their family name', (
    WidgetTester tester,
  ) async {
    final TextStyle style = GoogleFontsLite.getFont('Open Sans');
    expect(style.fontFamily, equals('OpenSans_regular'));
    expect(style.fontFamilyFallback, equals(<String>['OpenSans']));
  });

  testWidgets('GoogleFontsLite getFont throws an exception when the fontFamily is unknown', (
    WidgetTester tester,
  ) async {
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

  test('GoogleFontsLite.config and GoogleFonts.config share the same instance', () {
    expect(identical(GoogleFontsLite.config, GoogleFonts.config), isTrue);
    addTearDown(() {
      GoogleFontsLite.config.allowRuntimeFetching = true;
    });
    GoogleFontsLite.config.allowRuntimeFetching = false;
    expect(GoogleFonts.config.allowRuntimeFetching, isFalse);
  });

  test('GoogleFontsLite.pendingFonts awaits loaded fonts and accepts optional argument', () async {
    pendingFontFutures.clear();
    expect(await GoogleFontsLite.pendingFonts(), isEmpty);
    expect(
      await GoogleFontsLite.pendingFonts(<TextStyle>[const TextStyle(fontFamily: 'Lato')]),
      isEmpty,
    );
  });

  testWidgets('GoogleFontsLite.getTextTheme creates matching TextTheme', (
    WidgetTester tester,
  ) async {
    final TextTheme liteTheme = GoogleFontsLite.getTextTheme('Lato');
    final TextTheme heavyTheme = GoogleFonts.latoTextTheme();
    expect(liteTheme, equals(heavyTheme));
  });

  testWidgets('GoogleFontsLite.getTextTheme preserves existing TextTheme properties', (
    WidgetTester tester,
  ) async {
    const customStyle = TextStyle(fontSize: 42.0, color: Colors.purple);
    final lightTheme = ThemeData.light();
    final TextTheme customBaseTheme = lightTheme.textTheme.copyWith(displayLarge: customStyle);
    final TextTheme resultTheme = GoogleFontsLite.getTextTheme('Lato', customBaseTheme);
    expect(resultTheme.displayLarge?.fontSize, equals(42.0));
    expect(resultTheme.displayLarge?.color, equals(Colors.purple));
    expect(resultTheme.displayLarge?.fontFamily, contains('Lato'));
  });

  test('GoogleFontsLite.getTextTheme throws on unknown font family', () {
    expect(
      () => GoogleFontsLite.getTextTheme('NonExistentFamily'),
      throwsA(
        isA<ArgumentError>().having(
          (ArgumentError e) => e.message,
          'message',
          contains("No font family by name 'NonExistentFamily' was found."),
        ),
      ),
    );
  });

  test('google_fonts_lite.dart entrypoint exports expected public symbols', () {
    expect(lite.GoogleFontsLite.fontsMap, isNotEmpty);
    expect(lite.GoogleFontsLite.config, isA<lite.GoogleFontsConfig>());
    expect(lite.GoogleFontsLite.config, isA<lite.Config>());
  });
}
