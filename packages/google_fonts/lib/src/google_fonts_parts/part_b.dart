// GENERATED CODE - DO NOT EDIT

// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../google_fonts_base.dart';
import '../google_fonts_descriptor.dart';
import '../google_fonts_variant.dart';

/// Methods for fonts starting with 'B'.
class PartB {
  /// Applies the B612 font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/B612
  static TextStyle b612({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '29bc9dd8125dac43fbdfb38653463ca1ac396eed2674be15f566f304f39abe05',
        89040,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'b77c44dfed0702a94bd92d27d00b9da6ec11be924bda5e794fc5da4f74105836',
        92724,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '5c9406c6d212c60cfb04318f76f522ef4246b689c488431419690dc3a99ebeba',
        88692,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '5a6f3b9063106c9f048a800393507e5b311378874ff32019cb785a86d49d0059',
        91732,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'B612',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the B612 font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/B612
  static TextTheme b612TextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: b612(textStyle: textTheme.displayLarge),
      displayMedium: b612(textStyle: textTheme.displayMedium),
      displaySmall: b612(textStyle: textTheme.displaySmall),
      headlineLarge: b612(textStyle: textTheme.headlineLarge),
      headlineMedium: b612(textStyle: textTheme.headlineMedium),
      headlineSmall: b612(textStyle: textTheme.headlineSmall),
      titleLarge: b612(textStyle: textTheme.titleLarge),
      titleMedium: b612(textStyle: textTheme.titleMedium),
      titleSmall: b612(textStyle: textTheme.titleSmall),
      bodyLarge: b612(textStyle: textTheme.bodyLarge),
      bodyMedium: b612(textStyle: textTheme.bodyMedium),
      bodySmall: b612(textStyle: textTheme.bodySmall),
      labelLarge: b612(textStyle: textTheme.labelLarge),
      labelMedium: b612(textStyle: textTheme.labelMedium),
      labelSmall: b612(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the B612 Mono font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/B612+Mono
  static TextStyle b612Mono({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'd000dd45e5f0e911da0c815fb88b9a195fc02d82c2d945cae0e7f26b173bbbd0',
        86192,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '36d5da0f6b9d0caa1cb8780d010841c69cb5ed99206d9ee06258fd78505709dc',
        88680,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'afd0152ccca934a068576ec911f7f5f4b2b8272c728b92eed29061703d1e8d1f',
        85168,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '2701019977dcbb5e05e9ffaaca93b1a26b7e04980d41dcd28675f55f8f886f81',
        87484,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'B612Mono',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the B612 Mono font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/B612+Mono
  static TextTheme b612MonoTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: b612Mono(textStyle: textTheme.displayLarge),
      displayMedium: b612Mono(textStyle: textTheme.displayMedium),
      displaySmall: b612Mono(textStyle: textTheme.displaySmall),
      headlineLarge: b612Mono(textStyle: textTheme.headlineLarge),
      headlineMedium: b612Mono(textStyle: textTheme.headlineMedium),
      headlineSmall: b612Mono(textStyle: textTheme.headlineSmall),
      titleLarge: b612Mono(textStyle: textTheme.titleLarge),
      titleMedium: b612Mono(textStyle: textTheme.titleMedium),
      titleSmall: b612Mono(textStyle: textTheme.titleSmall),
      bodyLarge: b612Mono(textStyle: textTheme.bodyLarge),
      bodyMedium: b612Mono(textStyle: textTheme.bodyMedium),
      bodySmall: b612Mono(textStyle: textTheme.bodySmall),
      labelLarge: b612Mono(textStyle: textTheme.labelLarge),
      labelMedium: b612Mono(textStyle: textTheme.labelMedium),
      labelSmall: b612Mono(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the BIZ UDGothic font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/BIZ+UDGothic
  static TextStyle bizUDGothic({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'f0e93ce9e3edfc58d2874908e14b36b77a6f6dde51e7e1d919b99b27018b1621',
        3462768,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'aa66342f3412d3890b66d95543e0d0fa9fac466c227e596b9a36cf3ec1267387',
        3447448,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'BIZUDGothic',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the BIZ UDGothic font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/BIZ+UDGothic
  static TextTheme bizUDGothicTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: bizUDGothic(textStyle: textTheme.displayLarge),
      displayMedium: bizUDGothic(textStyle: textTheme.displayMedium),
      displaySmall: bizUDGothic(textStyle: textTheme.displaySmall),
      headlineLarge: bizUDGothic(textStyle: textTheme.headlineLarge),
      headlineMedium: bizUDGothic(textStyle: textTheme.headlineMedium),
      headlineSmall: bizUDGothic(textStyle: textTheme.headlineSmall),
      titleLarge: bizUDGothic(textStyle: textTheme.titleLarge),
      titleMedium: bizUDGothic(textStyle: textTheme.titleMedium),
      titleSmall: bizUDGothic(textStyle: textTheme.titleSmall),
      bodyLarge: bizUDGothic(textStyle: textTheme.bodyLarge),
      bodyMedium: bizUDGothic(textStyle: textTheme.bodyMedium),
      bodySmall: bizUDGothic(textStyle: textTheme.bodySmall),
      labelLarge: bizUDGothic(textStyle: textTheme.labelLarge),
      labelMedium: bizUDGothic(textStyle: textTheme.labelMedium),
      labelSmall: bizUDGothic(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the BIZ UDMincho font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/BIZ+UDMincho
  static TextStyle bizUDMincho({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '1059080ff70744bba179d6a7e827d89dee3db3945fe5b03073c728fb5b6e2962',
        4846784,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '8af176823dfbc4dfa239422487e2776972f542de9b87ca37aeb827d261ac6c24',
        5793964,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'BIZUDMincho',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the BIZ UDMincho font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/BIZ+UDMincho
  static TextTheme bizUDMinchoTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: bizUDMincho(textStyle: textTheme.displayLarge),
      displayMedium: bizUDMincho(textStyle: textTheme.displayMedium),
      displaySmall: bizUDMincho(textStyle: textTheme.displaySmall),
      headlineLarge: bizUDMincho(textStyle: textTheme.headlineLarge),
      headlineMedium: bizUDMincho(textStyle: textTheme.headlineMedium),
      headlineSmall: bizUDMincho(textStyle: textTheme.headlineSmall),
      titleLarge: bizUDMincho(textStyle: textTheme.titleLarge),
      titleMedium: bizUDMincho(textStyle: textTheme.titleMedium),
      titleSmall: bizUDMincho(textStyle: textTheme.titleSmall),
      bodyLarge: bizUDMincho(textStyle: textTheme.bodyLarge),
      bodyMedium: bizUDMincho(textStyle: textTheme.bodyMedium),
      bodySmall: bizUDMincho(textStyle: textTheme.bodySmall),
      labelLarge: bizUDMincho(textStyle: textTheme.labelLarge),
      labelMedium: bizUDMincho(textStyle: textTheme.labelMedium),
      labelSmall: bizUDMincho(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the BIZ UDPGothic font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/BIZ+UDPGothic
  static TextStyle bizUDPGothic({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '291a29a027700852f46a4f2d9773b3cf930ec51914ae072f7dbb89516ab40761',
        3392156,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '019120f98e56d3019702d5dc0dd916c4f9afb4e8baab3a34175068441125a1f2',
        3376824,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'BIZUDPGothic',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the BIZ UDPGothic font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/BIZ+UDPGothic
  static TextTheme bizUDPGothicTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: bizUDPGothic(textStyle: textTheme.displayLarge),
      displayMedium: bizUDPGothic(textStyle: textTheme.displayMedium),
      displaySmall: bizUDPGothic(textStyle: textTheme.displaySmall),
      headlineLarge: bizUDPGothic(textStyle: textTheme.headlineLarge),
      headlineMedium: bizUDPGothic(textStyle: textTheme.headlineMedium),
      headlineSmall: bizUDPGothic(textStyle: textTheme.headlineSmall),
      titleLarge: bizUDPGothic(textStyle: textTheme.titleLarge),
      titleMedium: bizUDPGothic(textStyle: textTheme.titleMedium),
      titleSmall: bizUDPGothic(textStyle: textTheme.titleSmall),
      bodyLarge: bizUDPGothic(textStyle: textTheme.bodyLarge),
      bodyMedium: bizUDPGothic(textStyle: textTheme.bodyMedium),
      bodySmall: bizUDPGothic(textStyle: textTheme.bodySmall),
      labelLarge: bizUDPGothic(textStyle: textTheme.labelLarge),
      labelMedium: bizUDPGothic(textStyle: textTheme.labelMedium),
      labelSmall: bizUDPGothic(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the BIZ UDPMincho font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/BIZ+UDPMincho
  static TextStyle bizUDPMincho({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'ae035268deaa3f6c59ffaf24ab3d0697f84ea1888fa7e76f698af8be9ef76ed3',
        4919464,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '64953b15bc53bb719ea5aa324f64f9df22c1894dd7eb9c28a199e733b62677ef',
        5880044,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'BIZUDPMincho',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the BIZ UDPMincho font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/BIZ+UDPMincho
  static TextTheme bizUDPMinchoTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: bizUDPMincho(textStyle: textTheme.displayLarge),
      displayMedium: bizUDPMincho(textStyle: textTheme.displayMedium),
      displaySmall: bizUDPMincho(textStyle: textTheme.displaySmall),
      headlineLarge: bizUDPMincho(textStyle: textTheme.headlineLarge),
      headlineMedium: bizUDPMincho(textStyle: textTheme.headlineMedium),
      headlineSmall: bizUDPMincho(textStyle: textTheme.headlineSmall),
      titleLarge: bizUDPMincho(textStyle: textTheme.titleLarge),
      titleMedium: bizUDPMincho(textStyle: textTheme.titleMedium),
      titleSmall: bizUDPMincho(textStyle: textTheme.titleSmall),
      bodyLarge: bizUDPMincho(textStyle: textTheme.bodyLarge),
      bodyMedium: bizUDPMincho(textStyle: textTheme.bodyMedium),
      bodySmall: bizUDPMincho(textStyle: textTheme.bodySmall),
      labelLarge: bizUDPMincho(textStyle: textTheme.labelLarge),
      labelMedium: bizUDPMincho(textStyle: textTheme.labelMedium),
      labelSmall: bizUDPMincho(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Babylonica font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Babylonica
  static TextStyle babylonica({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '67042b3bdc74088dfd4674df35d4f010dc4b33b739a7ac65bb085568d9c80c6f',
        333872,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Babylonica',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Babylonica font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Babylonica
  static TextTheme babylonicaTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: babylonica(textStyle: textTheme.displayLarge),
      displayMedium: babylonica(textStyle: textTheme.displayMedium),
      displaySmall: babylonica(textStyle: textTheme.displaySmall),
      headlineLarge: babylonica(textStyle: textTheme.headlineLarge),
      headlineMedium: babylonica(textStyle: textTheme.headlineMedium),
      headlineSmall: babylonica(textStyle: textTheme.headlineSmall),
      titleLarge: babylonica(textStyle: textTheme.titleLarge),
      titleMedium: babylonica(textStyle: textTheme.titleMedium),
      titleSmall: babylonica(textStyle: textTheme.titleSmall),
      bodyLarge: babylonica(textStyle: textTheme.bodyLarge),
      bodyMedium: babylonica(textStyle: textTheme.bodyMedium),
      bodySmall: babylonica(textStyle: textTheme.bodySmall),
      labelLarge: babylonica(textStyle: textTheme.labelLarge),
      labelMedium: babylonica(textStyle: textTheme.labelMedium),
      labelSmall: babylonica(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Bacasime Antique font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bacasime+Antique
  static TextStyle bacasimeAntique({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '0c8e7593a98f8c8773c59e63c9e37c01e5c60f99da330fe6f64d43da067810d1',
        29552,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'BacasimeAntique',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Bacasime Antique font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bacasime+Antique
  static TextTheme bacasimeAntiqueTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: bacasimeAntique(textStyle: textTheme.displayLarge),
      displayMedium: bacasimeAntique(textStyle: textTheme.displayMedium),
      displaySmall: bacasimeAntique(textStyle: textTheme.displaySmall),
      headlineLarge: bacasimeAntique(textStyle: textTheme.headlineLarge),
      headlineMedium: bacasimeAntique(textStyle: textTheme.headlineMedium),
      headlineSmall: bacasimeAntique(textStyle: textTheme.headlineSmall),
      titleLarge: bacasimeAntique(textStyle: textTheme.titleLarge),
      titleMedium: bacasimeAntique(textStyle: textTheme.titleMedium),
      titleSmall: bacasimeAntique(textStyle: textTheme.titleSmall),
      bodyLarge: bacasimeAntique(textStyle: textTheme.bodyLarge),
      bodyMedium: bacasimeAntique(textStyle: textTheme.bodyMedium),
      bodySmall: bacasimeAntique(textStyle: textTheme.bodySmall),
      labelLarge: bacasimeAntique(textStyle: textTheme.labelLarge),
      labelMedium: bacasimeAntique(textStyle: textTheme.labelMedium),
      labelSmall: bacasimeAntique(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Bad Script font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bad+Script
  static TextStyle badScript({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '5c860cdc1b476269a5634ebef873885abd228261472a533abd89bb7ddf639146',
        122456,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'BadScript',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Bad Script font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bad+Script
  static TextTheme badScriptTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: badScript(textStyle: textTheme.displayLarge),
      displayMedium: badScript(textStyle: textTheme.displayMedium),
      displaySmall: badScript(textStyle: textTheme.displaySmall),
      headlineLarge: badScript(textStyle: textTheme.headlineLarge),
      headlineMedium: badScript(textStyle: textTheme.headlineMedium),
      headlineSmall: badScript(textStyle: textTheme.headlineSmall),
      titleLarge: badScript(textStyle: textTheme.titleLarge),
      titleMedium: badScript(textStyle: textTheme.titleMedium),
      titleSmall: badScript(textStyle: textTheme.titleSmall),
      bodyLarge: badScript(textStyle: textTheme.bodyLarge),
      bodyMedium: badScript(textStyle: textTheme.bodyMedium),
      bodySmall: badScript(textStyle: textTheme.bodySmall),
      labelLarge: badScript(textStyle: textTheme.labelLarge),
      labelMedium: badScript(textStyle: textTheme.labelMedium),
      labelSmall: badScript(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Badeen Display font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Badeen+Display
  static TextStyle badeenDisplay({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '00c855df4e12dccf612ed76e4feef7778b29dae6213efa6f11e9f1b2f15e1c1f',
        45276,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'BadeenDisplay',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Badeen Display font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Badeen+Display
  static TextTheme badeenDisplayTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: badeenDisplay(textStyle: textTheme.displayLarge),
      displayMedium: badeenDisplay(textStyle: textTheme.displayMedium),
      displaySmall: badeenDisplay(textStyle: textTheme.displaySmall),
      headlineLarge: badeenDisplay(textStyle: textTheme.headlineLarge),
      headlineMedium: badeenDisplay(textStyle: textTheme.headlineMedium),
      headlineSmall: badeenDisplay(textStyle: textTheme.headlineSmall),
      titleLarge: badeenDisplay(textStyle: textTheme.titleLarge),
      titleMedium: badeenDisplay(textStyle: textTheme.titleMedium),
      titleSmall: badeenDisplay(textStyle: textTheme.titleSmall),
      bodyLarge: badeenDisplay(textStyle: textTheme.bodyLarge),
      bodyMedium: badeenDisplay(textStyle: textTheme.bodyMedium),
      bodySmall: badeenDisplay(textStyle: textTheme.bodySmall),
      labelLarge: badeenDisplay(textStyle: textTheme.labelLarge),
      labelMedium: badeenDisplay(textStyle: textTheme.labelMedium),
      labelSmall: badeenDisplay(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Bagel Fat One font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bagel+Fat+One
  static TextStyle bagelFatOne({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '867dc4545ae66d964f8ae2e18d0418b6e45a0e364565e9566c6ef48f07ab0ec4',
        971976,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'BagelFatOne',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Bagel Fat One font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bagel+Fat+One
  static TextTheme bagelFatOneTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: bagelFatOne(textStyle: textTheme.displayLarge),
      displayMedium: bagelFatOne(textStyle: textTheme.displayMedium),
      displaySmall: bagelFatOne(textStyle: textTheme.displaySmall),
      headlineLarge: bagelFatOne(textStyle: textTheme.headlineLarge),
      headlineMedium: bagelFatOne(textStyle: textTheme.headlineMedium),
      headlineSmall: bagelFatOne(textStyle: textTheme.headlineSmall),
      titleLarge: bagelFatOne(textStyle: textTheme.titleLarge),
      titleMedium: bagelFatOne(textStyle: textTheme.titleMedium),
      titleSmall: bagelFatOne(textStyle: textTheme.titleSmall),
      bodyLarge: bagelFatOne(textStyle: textTheme.bodyLarge),
      bodyMedium: bagelFatOne(textStyle: textTheme.bodyMedium),
      bodySmall: bagelFatOne(textStyle: textTheme.bodySmall),
      labelLarge: bagelFatOne(textStyle: textTheme.labelLarge),
      labelMedium: bagelFatOne(textStyle: textTheme.labelMedium),
      labelSmall: bagelFatOne(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Bahiana font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bahiana
  static TextStyle bahiana({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'e814f4c2e3a67c9343b2c2533a7ec6ba3074beb09700c3338e10187a3a98b4c1',
        46648,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Bahiana',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Bahiana font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bahiana
  static TextTheme bahianaTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: bahiana(textStyle: textTheme.displayLarge),
      displayMedium: bahiana(textStyle: textTheme.displayMedium),
      displaySmall: bahiana(textStyle: textTheme.displaySmall),
      headlineLarge: bahiana(textStyle: textTheme.headlineLarge),
      headlineMedium: bahiana(textStyle: textTheme.headlineMedium),
      headlineSmall: bahiana(textStyle: textTheme.headlineSmall),
      titleLarge: bahiana(textStyle: textTheme.titleLarge),
      titleMedium: bahiana(textStyle: textTheme.titleMedium),
      titleSmall: bahiana(textStyle: textTheme.titleSmall),
      bodyLarge: bahiana(textStyle: textTheme.bodyLarge),
      bodyMedium: bahiana(textStyle: textTheme.bodyMedium),
      bodySmall: bahiana(textStyle: textTheme.bodySmall),
      labelLarge: bahiana(textStyle: textTheme.labelLarge),
      labelMedium: bahiana(textStyle: textTheme.labelMedium),
      labelSmall: bahiana(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Bahianita font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bahianita
  static TextStyle bahianita({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '72554c00db8338dfcea172622a0db9f2db2c772327aebbcc776d8a0eb2ad04b2',
        92180,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Bahianita',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Bahianita font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bahianita
  static TextTheme bahianitaTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: bahianita(textStyle: textTheme.displayLarge),
      displayMedium: bahianita(textStyle: textTheme.displayMedium),
      displaySmall: bahianita(textStyle: textTheme.displaySmall),
      headlineLarge: bahianita(textStyle: textTheme.headlineLarge),
      headlineMedium: bahianita(textStyle: textTheme.headlineMedium),
      headlineSmall: bahianita(textStyle: textTheme.headlineSmall),
      titleLarge: bahianita(textStyle: textTheme.titleLarge),
      titleMedium: bahianita(textStyle: textTheme.titleMedium),
      titleSmall: bahianita(textStyle: textTheme.titleSmall),
      bodyLarge: bahianita(textStyle: textTheme.bodyLarge),
      bodyMedium: bahianita(textStyle: textTheme.bodyMedium),
      bodySmall: bahianita(textStyle: textTheme.bodySmall),
      labelLarge: bahianita(textStyle: textTheme.labelLarge),
      labelMedium: bahianita(textStyle: textTheme.labelMedium),
      labelSmall: bahianita(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Bai Jamjuree font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bai+Jamjuree
  static TextStyle baiJamjuree({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '9480364ae3c59475c997b72f728beaa20304a0ef7a9f32883116debd078bc154',
        78140,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '61b6992818b1406ce7004c1d822178f678dd32bcbbd73564432908ab6a438f9e',
        83696,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '387d0d7600e0d88939fff298b095803980a0995853d96924269b58f4eaddfa48',
        78480,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '87c3a0c7a294297e2923590d69b648a0c67d5dee6db6baae676eb5039423dc87',
        83876,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '75b7d8c47eedccd865f24dd6b34869e58570aa4585256ea16d9b9c06bf16b350',
        78508,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'b407dc138fabf0318e86c0d3192074adbd1bc52bc5c99c97d3f1b7527f8c4cea',
        83944,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '642eb10ea5fbcd5f4681bad8b823767d253396bd5d2a0401a6af52605b959895',
        78512,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '5f48001f2f71020bd554c49e7243d3dbbdff836cbefa4aeb044fa98803b48559',
        84024,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'a728f1f1b38dd64388e7074fa9e83c93d2e8a13faf3373ccae23cab147adbf85',
        78496,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '9834f9daca516f9b203241b8373b6104978cd0eb8a6494bfcae5e3489fb9d415',
        83856,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'abb0dd62200d9bd25ddf39752003cad30b4b09285d6a156d33f4dd1be91bb4c7',
        78172,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'bf20e31b1ec5792040e0b979d1eac7630a391f35e0e8d3797a7163f466b60448',
        83428,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'BaiJamjuree',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Bai Jamjuree font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bai+Jamjuree
  static TextTheme baiJamjureeTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: baiJamjuree(textStyle: textTheme.displayLarge),
      displayMedium: baiJamjuree(textStyle: textTheme.displayMedium),
      displaySmall: baiJamjuree(textStyle: textTheme.displaySmall),
      headlineLarge: baiJamjuree(textStyle: textTheme.headlineLarge),
      headlineMedium: baiJamjuree(textStyle: textTheme.headlineMedium),
      headlineSmall: baiJamjuree(textStyle: textTheme.headlineSmall),
      titleLarge: baiJamjuree(textStyle: textTheme.titleLarge),
      titleMedium: baiJamjuree(textStyle: textTheme.titleMedium),
      titleSmall: baiJamjuree(textStyle: textTheme.titleSmall),
      bodyLarge: baiJamjuree(textStyle: textTheme.bodyLarge),
      bodyMedium: baiJamjuree(textStyle: textTheme.bodyMedium),
      bodySmall: baiJamjuree(textStyle: textTheme.bodySmall),
      labelLarge: baiJamjuree(textStyle: textTheme.labelLarge),
      labelMedium: baiJamjuree(textStyle: textTheme.labelMedium),
      labelSmall: baiJamjuree(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Bakbak One font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bakbak+One
  static TextStyle bakbakOne({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '24d48558ea930ddf1ad6fe410cccbf9a12ef01e16246987f5c3c9eae03093957',
        146496,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'BakbakOne',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Bakbak One font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bakbak+One
  static TextTheme bakbakOneTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: bakbakOne(textStyle: textTheme.displayLarge),
      displayMedium: bakbakOne(textStyle: textTheme.displayMedium),
      displaySmall: bakbakOne(textStyle: textTheme.displaySmall),
      headlineLarge: bakbakOne(textStyle: textTheme.headlineLarge),
      headlineMedium: bakbakOne(textStyle: textTheme.headlineMedium),
      headlineSmall: bakbakOne(textStyle: textTheme.headlineSmall),
      titleLarge: bakbakOne(textStyle: textTheme.titleLarge),
      titleMedium: bakbakOne(textStyle: textTheme.titleMedium),
      titleSmall: bakbakOne(textStyle: textTheme.titleSmall),
      bodyLarge: bakbakOne(textStyle: textTheme.bodyLarge),
      bodyMedium: bakbakOne(textStyle: textTheme.bodyMedium),
      bodySmall: bakbakOne(textStyle: textTheme.bodySmall),
      labelLarge: bakbakOne(textStyle: textTheme.labelLarge),
      labelMedium: bakbakOne(textStyle: textTheme.labelMedium),
      labelSmall: bakbakOne(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Ballet font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Ballet
  static TextStyle ballet({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '2f1baa3810bd3d7efa8b9979e15d8d3636d837c915ab7b305e2ff13d2ce3a440',
        74336,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Ballet',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Ballet font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Ballet
  static TextTheme balletTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: ballet(textStyle: textTheme.displayLarge),
      displayMedium: ballet(textStyle: textTheme.displayMedium),
      displaySmall: ballet(textStyle: textTheme.displaySmall),
      headlineLarge: ballet(textStyle: textTheme.headlineLarge),
      headlineMedium: ballet(textStyle: textTheme.headlineMedium),
      headlineSmall: ballet(textStyle: textTheme.headlineSmall),
      titleLarge: ballet(textStyle: textTheme.titleLarge),
      titleMedium: ballet(textStyle: textTheme.titleMedium),
      titleSmall: ballet(textStyle: textTheme.titleSmall),
      bodyLarge: ballet(textStyle: textTheme.bodyLarge),
      bodyMedium: ballet(textStyle: textTheme.bodyMedium),
      bodySmall: ballet(textStyle: textTheme.bodySmall),
      labelLarge: ballet(textStyle: textTheme.labelLarge),
      labelMedium: ballet(textStyle: textTheme.labelMedium),
      labelSmall: ballet(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Baloo 2 font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Baloo+2
  static TextStyle baloo2({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'd904538a165e8c69b13c59c10fe8b77b20354a83883a0bc269f3b6494c7a6ea2',
        417824,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'd8177a2e3ca5b17279cf5d0cb0ee043c4de6bdf8d6c1898947946429d9481283',
        418140,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'ebc0059bc16fccdd40426abe2dea840739eb972b5feccedcd652a094cf0b2a8d',
        418064,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'ee32832e101e0b1ca5e78ea06eb805ddedb9a007238e18c6bdc3eb3b0c4fd4b4',
        417936,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'cb9f4e0c726fcc530057e47a9302668cc05cb3e5a20c23e8e053b26a4baf896e',
        417540,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Baloo2',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Baloo 2 font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Baloo+2
  static TextTheme baloo2TextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: baloo2(textStyle: textTheme.displayLarge),
      displayMedium: baloo2(textStyle: textTheme.displayMedium),
      displaySmall: baloo2(textStyle: textTheme.displaySmall),
      headlineLarge: baloo2(textStyle: textTheme.headlineLarge),
      headlineMedium: baloo2(textStyle: textTheme.headlineMedium),
      headlineSmall: baloo2(textStyle: textTheme.headlineSmall),
      titleLarge: baloo2(textStyle: textTheme.titleLarge),
      titleMedium: baloo2(textStyle: textTheme.titleMedium),
      titleSmall: baloo2(textStyle: textTheme.titleSmall),
      bodyLarge: baloo2(textStyle: textTheme.bodyLarge),
      bodyMedium: baloo2(textStyle: textTheme.bodyMedium),
      bodySmall: baloo2(textStyle: textTheme.bodySmall),
      labelLarge: baloo2(textStyle: textTheme.labelLarge),
      labelMedium: baloo2(textStyle: textTheme.labelMedium),
      labelSmall: baloo2(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Baloo Bhai 2 font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Baloo+Bhai+2
  static TextStyle balooBhai2({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'd3a3762fec75bba7eed19d1ca480251a7a3fd075d55745b2aa86bc7b6854480d',
        419804,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '11447fb20ac99b3ffb362bb9540a464f2f886bce9ed409e267c8593ea0bcae72',
        419928,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'dd407064f1b62b6f5396396015c801f730f7877ae086a8cb11f83ff31e8e2a7a',
        420176,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '2f7cd26a49ee877873648eba679953a3fa6f2dcb2d7fc6985c5b1c380aaf6bd5',
        420052,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '6dfbaa99325193b0d7804734c3bb74d0171e2fa768560fda5a678a7c78921168',
        419568,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'BalooBhai2',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Baloo Bhai 2 font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Baloo+Bhai+2
  static TextTheme balooBhai2TextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: balooBhai2(textStyle: textTheme.displayLarge),
      displayMedium: balooBhai2(textStyle: textTheme.displayMedium),
      displaySmall: balooBhai2(textStyle: textTheme.displaySmall),
      headlineLarge: balooBhai2(textStyle: textTheme.headlineLarge),
      headlineMedium: balooBhai2(textStyle: textTheme.headlineMedium),
      headlineSmall: balooBhai2(textStyle: textTheme.headlineSmall),
      titleLarge: balooBhai2(textStyle: textTheme.titleLarge),
      titleMedium: balooBhai2(textStyle: textTheme.titleMedium),
      titleSmall: balooBhai2(textStyle: textTheme.titleSmall),
      bodyLarge: balooBhai2(textStyle: textTheme.bodyLarge),
      bodyMedium: balooBhai2(textStyle: textTheme.bodyMedium),
      bodySmall: balooBhai2(textStyle: textTheme.bodySmall),
      labelLarge: balooBhai2(textStyle: textTheme.labelLarge),
      labelMedium: balooBhai2(textStyle: textTheme.labelMedium),
      labelSmall: balooBhai2(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Baloo Bhaijaan 2 font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Baloo+Bhaijaan+2
  static TextStyle balooBhaijaan2({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'e33d8cbf4e2aad3775a24bc44434447202c342edd0bc8db88a8e9bdc0dc3f487',
        172680,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'a5a7dbdb22b82f416e3bb8e471ffa2278ca8b1ea8a346ef3f29409f00acde9b6',
        172960,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'fbe2e6d80048651a667416b3088958a3862a40dcda7458b0bfa6f45019d520bb',
        173000,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '2a25882ee684cc2321efe9076854fadb3dd9ae9ecda60201f4057a3e01db3f05',
        173044,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'ae54099a7d41c5fb35dfabfcf8649894e236e589a861f05433904a9512bf72a5',
        172924,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'BalooBhaijaan2',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Baloo Bhaijaan 2 font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Baloo+Bhaijaan+2
  static TextTheme balooBhaijaan2TextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: balooBhaijaan2(textStyle: textTheme.displayLarge),
      displayMedium: balooBhaijaan2(textStyle: textTheme.displayMedium),
      displaySmall: balooBhaijaan2(textStyle: textTheme.displaySmall),
      headlineLarge: balooBhaijaan2(textStyle: textTheme.headlineLarge),
      headlineMedium: balooBhaijaan2(textStyle: textTheme.headlineMedium),
      headlineSmall: balooBhaijaan2(textStyle: textTheme.headlineSmall),
      titleLarge: balooBhaijaan2(textStyle: textTheme.titleLarge),
      titleMedium: balooBhaijaan2(textStyle: textTheme.titleMedium),
      titleSmall: balooBhaijaan2(textStyle: textTheme.titleSmall),
      bodyLarge: balooBhaijaan2(textStyle: textTheme.bodyLarge),
      bodyMedium: balooBhaijaan2(textStyle: textTheme.bodyMedium),
      bodySmall: balooBhaijaan2(textStyle: textTheme.bodySmall),
      labelLarge: balooBhaijaan2(textStyle: textTheme.labelLarge),
      labelMedium: balooBhaijaan2(textStyle: textTheme.labelMedium),
      labelSmall: balooBhaijaan2(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Baloo Bhaina 2 font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Baloo+Bhaina+2
  static TextStyle balooBhaina2({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'a3dac9c93b75a06993c64923fcd46794434655e21a9041b8c28373e10259c3fe',
        273844,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '64ea757f543e27c1e4ce1cda668f6059fe0f52f806869e55848abe9ada05f173',
        274896,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '2911049651a61a88b0b20d8abf22387b500d24c7f97dbae9441505675512526e',
        274944,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'c5d79d85eb8a03d9ecfc0d5268f90f4da7a9595981bf340c2ab8b0108f3e35b9',
        274784,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '2a1d5ff974326a5e746aad12dd23b68542a137965d27c962064efd7bf4c3a339',
        273264,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'BalooBhaina2',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Baloo Bhaina 2 font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Baloo+Bhaina+2
  static TextTheme balooBhaina2TextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: balooBhaina2(textStyle: textTheme.displayLarge),
      displayMedium: balooBhaina2(textStyle: textTheme.displayMedium),
      displaySmall: balooBhaina2(textStyle: textTheme.displaySmall),
      headlineLarge: balooBhaina2(textStyle: textTheme.headlineLarge),
      headlineMedium: balooBhaina2(textStyle: textTheme.headlineMedium),
      headlineSmall: balooBhaina2(textStyle: textTheme.headlineSmall),
      titleLarge: balooBhaina2(textStyle: textTheme.titleLarge),
      titleMedium: balooBhaina2(textStyle: textTheme.titleMedium),
      titleSmall: balooBhaina2(textStyle: textTheme.titleSmall),
      bodyLarge: balooBhaina2(textStyle: textTheme.bodyLarge),
      bodyMedium: balooBhaina2(textStyle: textTheme.bodyMedium),
      bodySmall: balooBhaina2(textStyle: textTheme.bodySmall),
      labelLarge: balooBhaina2(textStyle: textTheme.labelLarge),
      labelMedium: balooBhaina2(textStyle: textTheme.labelMedium),
      labelSmall: balooBhaina2(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Baloo Chettan 2 font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Baloo+Chettan+2
  static TextStyle balooChettan2({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '07f53925033056e79b2364943aad8bc52ec31ae5d8ade119fa77395d3ba843f7',
        191128,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '3ef25c18655776658cf3ea8662396aef1961642142f8f5667ca70ad44d05172a',
        191728,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '7583b2d1732151bcda2afa1a365e9a4fd46b058b3c1c0cc0068b742a1a66a3ac',
        191740,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'd11e1ad812e20f27246bbda8c391b878aea25d87c6b3ff7a82407d2ed4ed2d18',
        191648,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '9b4bb63068098769732ad53ffffcc15210f49e5923c476032f762139a78ddde4',
        191496,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'BalooChettan2',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Baloo Chettan 2 font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Baloo+Chettan+2
  static TextTheme balooChettan2TextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: balooChettan2(textStyle: textTheme.displayLarge),
      displayMedium: balooChettan2(textStyle: textTheme.displayMedium),
      displaySmall: balooChettan2(textStyle: textTheme.displaySmall),
      headlineLarge: balooChettan2(textStyle: textTheme.headlineLarge),
      headlineMedium: balooChettan2(textStyle: textTheme.headlineMedium),
      headlineSmall: balooChettan2(textStyle: textTheme.headlineSmall),
      titleLarge: balooChettan2(textStyle: textTheme.titleLarge),
      titleMedium: balooChettan2(textStyle: textTheme.titleMedium),
      titleSmall: balooChettan2(textStyle: textTheme.titleSmall),
      bodyLarge: balooChettan2(textStyle: textTheme.bodyLarge),
      bodyMedium: balooChettan2(textStyle: textTheme.bodyMedium),
      bodySmall: balooChettan2(textStyle: textTheme.bodySmall),
      labelLarge: balooChettan2(textStyle: textTheme.labelLarge),
      labelMedium: balooChettan2(textStyle: textTheme.labelMedium),
      labelSmall: balooChettan2(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Baloo Da 2 font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Baloo+Da+2
  static TextStyle balooDa2({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '35ff7579a7e177658518997396bcd6ef4f1b78ccf06cf3d6355dceea2d15fb7c',
        269996,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'e897e9c853f289e75aff02bcd2671daba8926168ee34fba048c34cb4fe6f915d',
        270528,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '79548f191b769e1b917c5ecca0cd884dae1369e36a2ee8c17d1cfc4e9c709543',
        270676,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'b18b0891b8b246349624b2f9df7eb418a890f51d60f23f3faa4be029d231f411',
        270356,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'd6bb69f8d5834ae1f95449eccbd3012f616d392046948daebd10bb5259ad2021',
        269480,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'BalooDa2',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Baloo Da 2 font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Baloo+Da+2
  static TextTheme balooDa2TextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: balooDa2(textStyle: textTheme.displayLarge),
      displayMedium: balooDa2(textStyle: textTheme.displayMedium),
      displaySmall: balooDa2(textStyle: textTheme.displaySmall),
      headlineLarge: balooDa2(textStyle: textTheme.headlineLarge),
      headlineMedium: balooDa2(textStyle: textTheme.headlineMedium),
      headlineSmall: balooDa2(textStyle: textTheme.headlineSmall),
      titleLarge: balooDa2(textStyle: textTheme.titleLarge),
      titleMedium: balooDa2(textStyle: textTheme.titleMedium),
      titleSmall: balooDa2(textStyle: textTheme.titleSmall),
      bodyLarge: balooDa2(textStyle: textTheme.bodyLarge),
      bodyMedium: balooDa2(textStyle: textTheme.bodyMedium),
      bodySmall: balooDa2(textStyle: textTheme.bodySmall),
      labelLarge: balooDa2(textStyle: textTheme.labelLarge),
      labelMedium: balooDa2(textStyle: textTheme.labelMedium),
      labelSmall: balooDa2(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Baloo Paaji 2 font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Baloo+Paaji+2
  static TextStyle balooPaaji2({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '000b137b698a21492719821c1e91c281331fb5f8425de6ed74f7970668a3c29f',
        148100,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'a525b344bf02c209396fe7b61e88e229ca3b05c8bb47324bf574f5912436bd8b',
        148348,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'fe13803d6494267d0577bae645f0ef26d6173533729126923a96160f9dc11058',
        148352,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '1301e2109062158d811f19e083d44fb5710a13f9032139980fa90d179bece66d',
        148228,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'cf3e37c083e6f52a6620e04613c85493e521991248475c695f4331c8bb5d9e23',
        148156,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'BalooPaaji2',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Baloo Paaji 2 font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Baloo+Paaji+2
  static TextTheme balooPaaji2TextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: balooPaaji2(textStyle: textTheme.displayLarge),
      displayMedium: balooPaaji2(textStyle: textTheme.displayMedium),
      displaySmall: balooPaaji2(textStyle: textTheme.displaySmall),
      headlineLarge: balooPaaji2(textStyle: textTheme.headlineLarge),
      headlineMedium: balooPaaji2(textStyle: textTheme.headlineMedium),
      headlineSmall: balooPaaji2(textStyle: textTheme.headlineSmall),
      titleLarge: balooPaaji2(textStyle: textTheme.titleLarge),
      titleMedium: balooPaaji2(textStyle: textTheme.titleMedium),
      titleSmall: balooPaaji2(textStyle: textTheme.titleSmall),
      bodyLarge: balooPaaji2(textStyle: textTheme.bodyLarge),
      bodyMedium: balooPaaji2(textStyle: textTheme.bodyMedium),
      bodySmall: balooPaaji2(textStyle: textTheme.bodySmall),
      labelLarge: balooPaaji2(textStyle: textTheme.labelLarge),
      labelMedium: balooPaaji2(textStyle: textTheme.labelMedium),
      labelSmall: balooPaaji2(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Baloo Tamma 2 font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Baloo+Tamma+2
  static TextStyle balooTamma2({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'ce49d755669c5d78e2fcc0789d9c771b774f6b93da4c8dac89630835d4c48163',
        280456,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'aee678d6631976c044c5e2542dd3fa6bd4b546e7bfe2caad4a5519112612594a',
        281552,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '1c3181dda67fe2a8f59a10b886d726d5b8982f6c80992a08bbad7b8b6da35ab1',
        281708,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '75ec51533858ce2edd1dd3defc96fd580644cdcdaa567071729282328a86485b',
        281636,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '9a467c5c1e0704b93a4bc5ee5af508f6b8a8759a559378c5b03d3658ffaa0b2b',
        281028,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'BalooTamma2',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Baloo Tamma 2 font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Baloo+Tamma+2
  static TextTheme balooTamma2TextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: balooTamma2(textStyle: textTheme.displayLarge),
      displayMedium: balooTamma2(textStyle: textTheme.displayMedium),
      displaySmall: balooTamma2(textStyle: textTheme.displaySmall),
      headlineLarge: balooTamma2(textStyle: textTheme.headlineLarge),
      headlineMedium: balooTamma2(textStyle: textTheme.headlineMedium),
      headlineSmall: balooTamma2(textStyle: textTheme.headlineSmall),
      titleLarge: balooTamma2(textStyle: textTheme.titleLarge),
      titleMedium: balooTamma2(textStyle: textTheme.titleMedium),
      titleSmall: balooTamma2(textStyle: textTheme.titleSmall),
      bodyLarge: balooTamma2(textStyle: textTheme.bodyLarge),
      bodyMedium: balooTamma2(textStyle: textTheme.bodyMedium),
      bodySmall: balooTamma2(textStyle: textTheme.bodySmall),
      labelLarge: balooTamma2(textStyle: textTheme.labelLarge),
      labelMedium: balooTamma2(textStyle: textTheme.labelMedium),
      labelSmall: balooTamma2(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Baloo Tammudu 2 font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Baloo+Tammudu+2
  static TextStyle balooTammudu2({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '9b731aefc583d4636f8e4ed71bc06b1b1e28213585e542cb178ec1be97194606',
        388520,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '0d590e548307a760e49571e7470c7442bf8cdf006d741b5b307bb30d4f4b4799',
        389988,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'dd123d5fd30b6355de1debac2687d3a03e4132018bb220cca96b6608363a14b2',
        389980,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '21d221a7bd660fc08af18199147656661d739c0721d599e28a5c61c4a9580795',
        389924,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '3d5307373576200a4f69ef6f88f40c652418815ed086bb9ff7ceba5ccd0e45b8',
        388224,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'BalooTammudu2',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Baloo Tammudu 2 font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Baloo+Tammudu+2
  static TextTheme balooTammudu2TextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: balooTammudu2(textStyle: textTheme.displayLarge),
      displayMedium: balooTammudu2(textStyle: textTheme.displayMedium),
      displaySmall: balooTammudu2(textStyle: textTheme.displaySmall),
      headlineLarge: balooTammudu2(textStyle: textTheme.headlineLarge),
      headlineMedium: balooTammudu2(textStyle: textTheme.headlineMedium),
      headlineSmall: balooTammudu2(textStyle: textTheme.headlineSmall),
      titleLarge: balooTammudu2(textStyle: textTheme.titleLarge),
      titleMedium: balooTammudu2(textStyle: textTheme.titleMedium),
      titleSmall: balooTammudu2(textStyle: textTheme.titleSmall),
      bodyLarge: balooTammudu2(textStyle: textTheme.bodyLarge),
      bodyMedium: balooTammudu2(textStyle: textTheme.bodyMedium),
      bodySmall: balooTammudu2(textStyle: textTheme.bodySmall),
      labelLarge: balooTammudu2(textStyle: textTheme.labelLarge),
      labelMedium: balooTammudu2(textStyle: textTheme.labelMedium),
      labelSmall: balooTammudu2(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Baloo Thambi 2 font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Baloo+Thambi+2
  static TextStyle balooThambi2({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '51a79dccefcc8f7fd95a217a82bfd267ccb0d34920462f9347819481a4564a61',
        171256,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'a6c5b6abd6788b492e66a9fc73dc2488f140cf090d8cd2164e33895998703264',
        171496,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '73c60398255ad672f15a2230188ffbf49723119b18ddea3f937929b33eb44e28',
        171580,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '9eb2cc5c72d9baa97a5f113beee6fbf5326775f7eb1e2795fd4876588f8f9045',
        171224,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '6ddc96f6d0a16bcddd46bfb6e1b327a9de5b4f1d3d97a407bfee1dc5a947c0e2',
        171224,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'BalooThambi2',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Baloo Thambi 2 font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Baloo+Thambi+2
  static TextTheme balooThambi2TextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: balooThambi2(textStyle: textTheme.displayLarge),
      displayMedium: balooThambi2(textStyle: textTheme.displayMedium),
      displaySmall: balooThambi2(textStyle: textTheme.displaySmall),
      headlineLarge: balooThambi2(textStyle: textTheme.headlineLarge),
      headlineMedium: balooThambi2(textStyle: textTheme.headlineMedium),
      headlineSmall: balooThambi2(textStyle: textTheme.headlineSmall),
      titleLarge: balooThambi2(textStyle: textTheme.titleLarge),
      titleMedium: balooThambi2(textStyle: textTheme.titleMedium),
      titleSmall: balooThambi2(textStyle: textTheme.titleSmall),
      bodyLarge: balooThambi2(textStyle: textTheme.bodyLarge),
      bodyMedium: balooThambi2(textStyle: textTheme.bodyMedium),
      bodySmall: balooThambi2(textStyle: textTheme.bodySmall),
      labelLarge: balooThambi2(textStyle: textTheme.labelLarge),
      labelMedium: balooThambi2(textStyle: textTheme.labelMedium),
      labelSmall: balooThambi2(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Balsamiq Sans font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Balsamiq+Sans
  static TextStyle balsamiqSans({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '3ee1b7dfb83c2721131df10c409f96f42165d8e59cb441647f902bc25230e9c8',
        323364,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '189cc10514d60471ffc6ba6118d1c30beaec5f511ceaa7905943bc684f6438fd',
        301404,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '0f9962f09eb61fb2af7af75eee3640990d4351c36cc994b80c488a5d37c2fa13',
        291260,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '0d2a4f57cff6fa5b2ee51dd01099a5ea2395c2d196bbda03d308ec367a25aa1b',
        273576,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'BalsamiqSans',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Balsamiq Sans font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Balsamiq+Sans
  static TextTheme balsamiqSansTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: balsamiqSans(textStyle: textTheme.displayLarge),
      displayMedium: balsamiqSans(textStyle: textTheme.displayMedium),
      displaySmall: balsamiqSans(textStyle: textTheme.displaySmall),
      headlineLarge: balsamiqSans(textStyle: textTheme.headlineLarge),
      headlineMedium: balsamiqSans(textStyle: textTheme.headlineMedium),
      headlineSmall: balsamiqSans(textStyle: textTheme.headlineSmall),
      titleLarge: balsamiqSans(textStyle: textTheme.titleLarge),
      titleMedium: balsamiqSans(textStyle: textTheme.titleMedium),
      titleSmall: balsamiqSans(textStyle: textTheme.titleSmall),
      bodyLarge: balsamiqSans(textStyle: textTheme.bodyLarge),
      bodyMedium: balsamiqSans(textStyle: textTheme.bodyMedium),
      bodySmall: balsamiqSans(textStyle: textTheme.bodySmall),
      labelLarge: balsamiqSans(textStyle: textTheme.labelLarge),
      labelMedium: balsamiqSans(textStyle: textTheme.labelMedium),
      labelSmall: balsamiqSans(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Balthazar font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Balthazar
  static TextStyle balthazar({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '07d4008122138b24ce528a3443bf01d43c6f92c031b4dfe642ec19fd1b5dcc69',
        26212,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Balthazar',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Balthazar font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Balthazar
  static TextTheme balthazarTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: balthazar(textStyle: textTheme.displayLarge),
      displayMedium: balthazar(textStyle: textTheme.displayMedium),
      displaySmall: balthazar(textStyle: textTheme.displaySmall),
      headlineLarge: balthazar(textStyle: textTheme.headlineLarge),
      headlineMedium: balthazar(textStyle: textTheme.headlineMedium),
      headlineSmall: balthazar(textStyle: textTheme.headlineSmall),
      titleLarge: balthazar(textStyle: textTheme.titleLarge),
      titleMedium: balthazar(textStyle: textTheme.titleMedium),
      titleSmall: balthazar(textStyle: textTheme.titleSmall),
      bodyLarge: balthazar(textStyle: textTheme.bodyLarge),
      bodyMedium: balthazar(textStyle: textTheme.bodyMedium),
      bodySmall: balthazar(textStyle: textTheme.bodySmall),
      labelLarge: balthazar(textStyle: textTheme.labelLarge),
      labelMedium: balthazar(textStyle: textTheme.labelMedium),
      labelSmall: balthazar(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Bangers font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bangers
  static TextStyle bangers({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'c0f2fbf70183afeccb0d42a5a75180dc93bbc4f032a04a6fac99b8e56f94fcae',
        66284,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Bangers',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Bangers font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bangers
  static TextTheme bangersTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: bangers(textStyle: textTheme.displayLarge),
      displayMedium: bangers(textStyle: textTheme.displayMedium),
      displaySmall: bangers(textStyle: textTheme.displaySmall),
      headlineLarge: bangers(textStyle: textTheme.headlineLarge),
      headlineMedium: bangers(textStyle: textTheme.headlineMedium),
      headlineSmall: bangers(textStyle: textTheme.headlineSmall),
      titleLarge: bangers(textStyle: textTheme.titleLarge),
      titleMedium: bangers(textStyle: textTheme.titleMedium),
      titleSmall: bangers(textStyle: textTheme.titleSmall),
      bodyLarge: bangers(textStyle: textTheme.bodyLarge),
      bodyMedium: bangers(textStyle: textTheme.bodyMedium),
      bodySmall: bangers(textStyle: textTheme.bodySmall),
      labelLarge: bangers(textStyle: textTheme.labelLarge),
      labelMedium: bangers(textStyle: textTheme.labelMedium),
      labelSmall: bangers(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Barlow font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Barlow
  static TextStyle barlow({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w100,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'd4cb2261daf93600b6051d1127eef2b2d77c74d66d79abdc62745aa15ea7f08f',
        61000,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w100,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'f5ea5b54ff862fcbdfe5eda82802a52c153a6935785a241adc8947cedd3d1c41',
        65076,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '14396b801c7944f99805b08f084276bd8b28958c8a452febae44521786491a3f',
        61208,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'a96f872a461901197fd2c9afcc61b4c345540a2ecbcc456ec3edd0a0ee26392f',
        65188,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '73be035dbec5c678f006ec17dd90157bb12f21073299e33965fdd8b586b748d7',
        61144,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'e57a19d3aa676335246c8f2371256faea680d33edb66e894bdb17317d1318dfc',
        65420,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '4fcb717393591e02cf9e1664e25e24475a44de32655cb6d7c919f28c07c7ac49',
        61256,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '200c8b35898374adc8d3fe1979a6a37b3e4a351c4b4ca444d9ba1746542af7f3',
        65436,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'bb18cb08b94c5a45fa80c03aec4e9471be28ec2378806c8e83570f27103fb61a',
        61228,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '36aebbfd3028801d16b8883db5817a69cbecc411805901b399ff830c4e20d671',
        65272,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '1538c291324c97d56446d95fb329ec4340521629119dd6440e61befe6a484f02',
        63652,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '49eb3c61cb107eac1d27e16c47e24abadf663664de8caca2b8664647f5431caf',
        66748,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'dac430310035fe39cf556a84a7151e1886b00a98315c04fd94bb8768cf2123df',
        63464,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '15964f959bc78f3cfdc1c0b4acefff96e07775f2ee8704edaec60b153dac2c8d',
        66464,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '69864f72c7aa71ca716961fd69633f935848a44d35c0d2972c70af4f1df68d55',
        63388,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'f004178d7b1180940c555d86a0d7cabfd09fb1146784703b0c5513fe767c0f97',
        66332,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '49f0e098b0167b5268fc7cf04fe28657a46345c8fee9388c58ef87cda6dcbca8',
        62680,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'afb02586ee77b9664a74afd65c4954480654fe9eb011d73d95e0fa9bd8b62eb5',
        65852,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Barlow',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Barlow font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Barlow
  static TextTheme barlowTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: barlow(textStyle: textTheme.displayLarge),
      displayMedium: barlow(textStyle: textTheme.displayMedium),
      displaySmall: barlow(textStyle: textTheme.displaySmall),
      headlineLarge: barlow(textStyle: textTheme.headlineLarge),
      headlineMedium: barlow(textStyle: textTheme.headlineMedium),
      headlineSmall: barlow(textStyle: textTheme.headlineSmall),
      titleLarge: barlow(textStyle: textTheme.titleLarge),
      titleMedium: barlow(textStyle: textTheme.titleMedium),
      titleSmall: barlow(textStyle: textTheme.titleSmall),
      bodyLarge: barlow(textStyle: textTheme.bodyLarge),
      bodyMedium: barlow(textStyle: textTheme.bodyMedium),
      bodySmall: barlow(textStyle: textTheme.bodySmall),
      labelLarge: barlow(textStyle: textTheme.labelLarge),
      labelMedium: barlow(textStyle: textTheme.labelMedium),
      labelSmall: barlow(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Barlow Condensed font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Barlow+Condensed
  static TextStyle barlowCondensed({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w100,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '9b6ab1a8807ff5b63413518d590eabaac7f6384b206aad7ad278a76da4d24df2',
        59160,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w100,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '6dcb81ea53181a70ce6fa4130350152b81789371476077c363338253d28edf84',
        64232,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'b692513d6760ce8231c9f2446e526859e7ad5585323cc26cf2184740c0cbc941',
        59440,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '0feb2885b03f8b0e328a13129a7953b2f388dc0186282fa5123ff62f200fd02d',
        64192,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '753c47d728971bf5b42d1851b8c9c9cf4fda6a8611818ec6a1e0af24cb9d2d27',
        59404,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '5eece17362d8b1ca8ed6f7392890d60fe4fbfb55f2badf4e0808899dc012f7e3',
        64112,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '1a5ddfa332cbee25c647b442e77d44d605de4fb54b3f905cb8fd62f8d4fc0aae',
        59424,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'af00d9f1f836d3e3093ece207c5d16ffec9f33c0a06ff3d42add2fb1dff07436',
        64256,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'de6afc7fd8afde724454ccc1e56f6319f18994a87eb3a78d9a886338344c078d',
        59332,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'fc548cb0cea8bb685ceb14a2973e57c21658438175bb645454272665f9e395a7',
        63976,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '9d3e372f7e40ab71fe2f6cb64edfd1f5e984d346cda7cd8c117db5d4680a3b56',
        61788,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '8df4575c214296a67aea8ab79fb4b007548374955c60e7fe9b07088695624e5c',
        65080,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '77873152fffc3ed53345bc5b5440561ca9454fd3eb50d74d11cd8ef6d93933c1',
        61696,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'dadca02f37a76341bb9014d671ef5b78756a73540675fc091c0fd70b680a8b64',
        64860,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '92ecf7865ec447e01c5d019a7eae34c793f943125c94b1d7c387a44d2e9b5cf7',
        61784,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '131e299553284b9df03231d5958e17033a899677f8832c28c269854452b52c05',
        64732,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '00918fae8ef12433c8d33c0ed472c7b7d7fff5e3d35f0d6e63a5711d8ad7bc56',
        60400,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '2f4f390eb03ee11af695aa77bd9afc4e90e249c89b2f696a3116e3326701ddc0',
        63400,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'BarlowCondensed',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Barlow Condensed font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Barlow+Condensed
  static TextTheme barlowCondensedTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: barlowCondensed(textStyle: textTheme.displayLarge),
      displayMedium: barlowCondensed(textStyle: textTheme.displayMedium),
      displaySmall: barlowCondensed(textStyle: textTheme.displaySmall),
      headlineLarge: barlowCondensed(textStyle: textTheme.headlineLarge),
      headlineMedium: barlowCondensed(textStyle: textTheme.headlineMedium),
      headlineSmall: barlowCondensed(textStyle: textTheme.headlineSmall),
      titleLarge: barlowCondensed(textStyle: textTheme.titleLarge),
      titleMedium: barlowCondensed(textStyle: textTheme.titleMedium),
      titleSmall: barlowCondensed(textStyle: textTheme.titleSmall),
      bodyLarge: barlowCondensed(textStyle: textTheme.bodyLarge),
      bodyMedium: barlowCondensed(textStyle: textTheme.bodyMedium),
      bodySmall: barlowCondensed(textStyle: textTheme.bodySmall),
      labelLarge: barlowCondensed(textStyle: textTheme.labelLarge),
      labelMedium: barlowCondensed(textStyle: textTheme.labelMedium),
      labelSmall: barlowCondensed(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Barlow Semi Condensed font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Barlow+Semi+Condensed
  static TextStyle barlowSemiCondensed({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w100,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'de5c50de6429d9406a5c9f960da8a59c8ac7eed525035ff974aa128a90520c0e',
        61564,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w100,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '5c1fe2dae8b9ea1d7a9afe712edf7f281d7ffe95ef81a9a2c8f0a54c105f8dad',
        66040,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'b486e5b872b8e06bfce9ccf309f336e22c540623f8530fb18b2831dc327f9ca5',
        61756,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '9f35d1c2fda6dce2f0522bdfadc5934e0441dfaff63eaa095c2c519ae666cc82',
        66052,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'b9ebc993c934f1cc60f2cfa183619a30c1d55871484e06e900887fde8e3dc10c',
        61852,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '43ab816bbf495254983104cad8178a7f5a9dc09af729f338e80377088871a083',
        65976,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'c94e5444e96376a571bf79b8897fdc43efbbc0db4b8738bad2d4c4fe93d99aff',
        61928,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'c07c98d59df52b07fe79d3916e0be5c230491822ad4ef59edcbf9cbbd76ca7df',
        65904,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'cbdc1a73b91fcee463e63c446cd4fc6ae1e9547127b53f75832b162b6e1f119d',
        61820,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'f25565d460e547a3276a3448d101807d6c09af58902d94ac1505c4214e90fff9',
        65800,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '490b2a19da27ff5d32aa9246ca6d2dbbab2604639535ec9f576df5d3f9421502',
        64256,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '23fd5b087ef2d824fd3e91838ac020ab45393eb7513e755fa37a19ca1d833147',
        67328,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'e99b87a6cc0ae1bdc3a307bc5b8b74eae4811d0e9e35bc94dfb05e0b68d67a40',
        64236,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '625322c03678544df151a89e4fa8dbe019ff51c97cded24e12e15b8b4286f96d',
        67068,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '94a93d82c21a6bbabd6948e1ea0ccd8f03cc57bfba54347e7ebd262f9abf1600',
        64264,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'b18d6e18f975c7980e4cbb140c49ba466ec299647db4d15331c1aa4cd3ce59b2',
        67064,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '45c3dcab40a000188643729a90327e92839201ab421f737cb3bb2464324e6fd9',
        63288,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '426a2354ec402b76a17a03e653d17d1f778608d1d1e0237c95e56eef21702d2c',
        66300,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'BarlowSemiCondensed',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Barlow Semi Condensed font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Barlow+Semi+Condensed
  static TextTheme barlowSemiCondensedTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: barlowSemiCondensed(textStyle: textTheme.displayLarge),
      displayMedium: barlowSemiCondensed(textStyle: textTheme.displayMedium),
      displaySmall: barlowSemiCondensed(textStyle: textTheme.displaySmall),
      headlineLarge: barlowSemiCondensed(textStyle: textTheme.headlineLarge),
      headlineMedium: barlowSemiCondensed(textStyle: textTheme.headlineMedium),
      headlineSmall: barlowSemiCondensed(textStyle: textTheme.headlineSmall),
      titleLarge: barlowSemiCondensed(textStyle: textTheme.titleLarge),
      titleMedium: barlowSemiCondensed(textStyle: textTheme.titleMedium),
      titleSmall: barlowSemiCondensed(textStyle: textTheme.titleSmall),
      bodyLarge: barlowSemiCondensed(textStyle: textTheme.bodyLarge),
      bodyMedium: barlowSemiCondensed(textStyle: textTheme.bodyMedium),
      bodySmall: barlowSemiCondensed(textStyle: textTheme.bodySmall),
      labelLarge: barlowSemiCondensed(textStyle: textTheme.labelLarge),
      labelMedium: barlowSemiCondensed(textStyle: textTheme.labelMedium),
      labelSmall: barlowSemiCondensed(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Barriecito font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Barriecito
  static TextStyle barriecito({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '4c8c9599c56a57f9ff3ca046fb25c36528a0cfdfad2535deeae91c87e993f43d',
        168284,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Barriecito',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Barriecito font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Barriecito
  static TextTheme barriecitoTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: barriecito(textStyle: textTheme.displayLarge),
      displayMedium: barriecito(textStyle: textTheme.displayMedium),
      displaySmall: barriecito(textStyle: textTheme.displaySmall),
      headlineLarge: barriecito(textStyle: textTheme.headlineLarge),
      headlineMedium: barriecito(textStyle: textTheme.headlineMedium),
      headlineSmall: barriecito(textStyle: textTheme.headlineSmall),
      titleLarge: barriecito(textStyle: textTheme.titleLarge),
      titleMedium: barriecito(textStyle: textTheme.titleMedium),
      titleSmall: barriecito(textStyle: textTheme.titleSmall),
      bodyLarge: barriecito(textStyle: textTheme.bodyLarge),
      bodyMedium: barriecito(textStyle: textTheme.bodyMedium),
      bodySmall: barriecito(textStyle: textTheme.bodySmall),
      labelLarge: barriecito(textStyle: textTheme.labelLarge),
      labelMedium: barriecito(textStyle: textTheme.labelMedium),
      labelSmall: barriecito(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Barrio font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Barrio
  static TextStyle barrio({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'c73e77cb0fcc68d0d94332f8915582a12f6c2b165f15acc69e0fac8043c43aab',
        141000,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Barrio',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Barrio font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Barrio
  static TextTheme barrioTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: barrio(textStyle: textTheme.displayLarge),
      displayMedium: barrio(textStyle: textTheme.displayMedium),
      displaySmall: barrio(textStyle: textTheme.displaySmall),
      headlineLarge: barrio(textStyle: textTheme.headlineLarge),
      headlineMedium: barrio(textStyle: textTheme.headlineMedium),
      headlineSmall: barrio(textStyle: textTheme.headlineSmall),
      titleLarge: barrio(textStyle: textTheme.titleLarge),
      titleMedium: barrio(textStyle: textTheme.titleMedium),
      titleSmall: barrio(textStyle: textTheme.titleSmall),
      bodyLarge: barrio(textStyle: textTheme.bodyLarge),
      bodyMedium: barrio(textStyle: textTheme.bodyMedium),
      bodySmall: barrio(textStyle: textTheme.bodySmall),
      labelLarge: barrio(textStyle: textTheme.labelLarge),
      labelMedium: barrio(textStyle: textTheme.labelMedium),
      labelSmall: barrio(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Basic font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Basic
  static TextStyle basic({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '15c18cb287c6877309c890fa731baa7e824f164a2f7e43055fe9cc8637697d86',
        42200,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Basic',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Basic font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Basic
  static TextTheme basicTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: basic(textStyle: textTheme.displayLarge),
      displayMedium: basic(textStyle: textTheme.displayMedium),
      displaySmall: basic(textStyle: textTheme.displaySmall),
      headlineLarge: basic(textStyle: textTheme.headlineLarge),
      headlineMedium: basic(textStyle: textTheme.headlineMedium),
      headlineSmall: basic(textStyle: textTheme.headlineSmall),
      titleLarge: basic(textStyle: textTheme.titleLarge),
      titleMedium: basic(textStyle: textTheme.titleMedium),
      titleSmall: basic(textStyle: textTheme.titleSmall),
      bodyLarge: basic(textStyle: textTheme.bodyLarge),
      bodyMedium: basic(textStyle: textTheme.bodyMedium),
      bodySmall: basic(textStyle: textTheme.bodySmall),
      labelLarge: basic(textStyle: textTheme.labelLarge),
      labelMedium: basic(textStyle: textTheme.labelMedium),
      labelSmall: basic(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Baskervville font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Baskervville
  static TextStyle baskervville({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '021332bbf36aac8da13ee1c395b5baea6431177e9aa88c3aaed902ebe5f61852',
        59828,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'b10f9c8fac76ff15d606a714c2345365a9f5d66dfac5977d661c6b98b0bd92b8',
        59972,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'd9e30a9faa913b97218444a6b4435f29fa93a5b43fe52f9776e96f6f64b696ca',
        59996,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'b0035cb99d120258fe4f720c3891e7bdaa870e6db6d88089e4f10bc042b890f6',
        59888,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '66a3178f7e14bcf7ce9bec1bb2ab392d734d6b752385360d25fa74ef09214808',
        61804,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '3da20c644caee72af9b5ceb6e0ab7f77389fb580008a1f08543456e56f592c2e',
        62024,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'fe5a9822a2a0d61f6a1f24c19237993db9fd5ff965c7b8c241dd3a69cb4e312f',
        62064,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'db84505f35cf700d26a0837e6571907cd06d702176b960fa7f2ee9e149967385',
        61520,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Baskervville',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Baskervville font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Baskervville
  static TextTheme baskervvilleTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: baskervville(textStyle: textTheme.displayLarge),
      displayMedium: baskervville(textStyle: textTheme.displayMedium),
      displaySmall: baskervville(textStyle: textTheme.displaySmall),
      headlineLarge: baskervville(textStyle: textTheme.headlineLarge),
      headlineMedium: baskervville(textStyle: textTheme.headlineMedium),
      headlineSmall: baskervville(textStyle: textTheme.headlineSmall),
      titleLarge: baskervville(textStyle: textTheme.titleLarge),
      titleMedium: baskervville(textStyle: textTheme.titleMedium),
      titleSmall: baskervville(textStyle: textTheme.titleSmall),
      bodyLarge: baskervville(textStyle: textTheme.bodyLarge),
      bodyMedium: baskervville(textStyle: textTheme.bodyMedium),
      bodySmall: baskervville(textStyle: textTheme.bodySmall),
      labelLarge: baskervville(textStyle: textTheme.labelLarge),
      labelMedium: baskervville(textStyle: textTheme.labelMedium),
      labelSmall: baskervville(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Baskervville SC font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Baskervville+SC
  static TextStyle baskervvilleSc({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'b7851f651599fa3a9f399b1254b1e2f33e06c09e1cff418c501140f16f3f4962',
        78276,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'fc9fcb8029ea57124589585504a2498b7db79d3885b76bc5c14356c85fa501a5',
        79264,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '779e5a54a7e741a917e78430f0ccbddfba52b86ec32f3bf86ec5be961c144c79',
        79348,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '904501629ab7ee5e3626978912ee38879ea633cf6693ea3ae3ee0b08e9a0ec74',
        79232,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'BaskervvilleSC',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Baskervville SC font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Baskervville+SC
  static TextTheme baskervvilleScTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: baskervvilleSc(textStyle: textTheme.displayLarge),
      displayMedium: baskervvilleSc(textStyle: textTheme.displayMedium),
      displaySmall: baskervvilleSc(textStyle: textTheme.displaySmall),
      headlineLarge: baskervvilleSc(textStyle: textTheme.headlineLarge),
      headlineMedium: baskervvilleSc(textStyle: textTheme.headlineMedium),
      headlineSmall: baskervvilleSc(textStyle: textTheme.headlineSmall),
      titleLarge: baskervvilleSc(textStyle: textTheme.titleLarge),
      titleMedium: baskervvilleSc(textStyle: textTheme.titleMedium),
      titleSmall: baskervvilleSc(textStyle: textTheme.titleSmall),
      bodyLarge: baskervvilleSc(textStyle: textTheme.bodyLarge),
      bodyMedium: baskervvilleSc(textStyle: textTheme.bodyMedium),
      bodySmall: baskervvilleSc(textStyle: textTheme.bodySmall),
      labelLarge: baskervvilleSc(textStyle: textTheme.labelLarge),
      labelMedium: baskervvilleSc(textStyle: textTheme.labelMedium),
      labelSmall: baskervvilleSc(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Battambang font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Battambang
  static TextStyle battambang({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w100,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '2945d97cc9bbd466dbf755036c7260bdc138cbbce2695670beaaf3ab8420819b',
        59320,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '80a21ab243101ce89c9890db1e8dc18e11123ef50789d416ee1086720af99c40',
        58752,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '52f720720ae62a367dade778a49b63c40cffc038890c48db8b8613d7ba767f12',
        63756,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'c34a808050fa4514d9d9a9f5d2379bcfc15dcdbbd8fa15a374c8248784b75f18',
        62148,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '3d4d37aaf17c90a28f58fcf301d09cab8e08b81082f4d9e261a7d552657904f2',
        59948,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Battambang',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Battambang font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Battambang
  static TextTheme battambangTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: battambang(textStyle: textTheme.displayLarge),
      displayMedium: battambang(textStyle: textTheme.displayMedium),
      displaySmall: battambang(textStyle: textTheme.displaySmall),
      headlineLarge: battambang(textStyle: textTheme.headlineLarge),
      headlineMedium: battambang(textStyle: textTheme.headlineMedium),
      headlineSmall: battambang(textStyle: textTheme.headlineSmall),
      titleLarge: battambang(textStyle: textTheme.titleLarge),
      titleMedium: battambang(textStyle: textTheme.titleMedium),
      titleSmall: battambang(textStyle: textTheme.titleSmall),
      bodyLarge: battambang(textStyle: textTheme.bodyLarge),
      bodyMedium: battambang(textStyle: textTheme.bodyMedium),
      bodySmall: battambang(textStyle: textTheme.bodySmall),
      labelLarge: battambang(textStyle: textTheme.labelLarge),
      labelMedium: battambang(textStyle: textTheme.labelMedium),
      labelSmall: battambang(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Baumans font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Baumans
  static TextStyle baumans({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '819fdefa5a1176397d590ac1672920fc8c51af57f4729004ce28c167c90fa8de',
        16392,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Baumans',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Baumans font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Baumans
  static TextTheme baumansTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: baumans(textStyle: textTheme.displayLarge),
      displayMedium: baumans(textStyle: textTheme.displayMedium),
      displaySmall: baumans(textStyle: textTheme.displaySmall),
      headlineLarge: baumans(textStyle: textTheme.headlineLarge),
      headlineMedium: baumans(textStyle: textTheme.headlineMedium),
      headlineSmall: baumans(textStyle: textTheme.headlineSmall),
      titleLarge: baumans(textStyle: textTheme.titleLarge),
      titleMedium: baumans(textStyle: textTheme.titleMedium),
      titleSmall: baumans(textStyle: textTheme.titleSmall),
      bodyLarge: baumans(textStyle: textTheme.bodyLarge),
      bodyMedium: baumans(textStyle: textTheme.bodyMedium),
      bodySmall: baumans(textStyle: textTheme.bodySmall),
      labelLarge: baumans(textStyle: textTheme.labelLarge),
      labelMedium: baumans(textStyle: textTheme.labelMedium),
      labelSmall: baumans(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Bayon font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bayon
  static TextStyle bayon({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '99a813ef40d0534db52fe34c136ce7cf50917766be7780d6f7918b1b931fcf1d',
        31844,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Bayon',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Bayon font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bayon
  static TextTheme bayonTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: bayon(textStyle: textTheme.displayLarge),
      displayMedium: bayon(textStyle: textTheme.displayMedium),
      displaySmall: bayon(textStyle: textTheme.displaySmall),
      headlineLarge: bayon(textStyle: textTheme.headlineLarge),
      headlineMedium: bayon(textStyle: textTheme.headlineMedium),
      headlineSmall: bayon(textStyle: textTheme.headlineSmall),
      titleLarge: bayon(textStyle: textTheme.titleLarge),
      titleMedium: bayon(textStyle: textTheme.titleMedium),
      titleSmall: bayon(textStyle: textTheme.titleSmall),
      bodyLarge: bayon(textStyle: textTheme.bodyLarge),
      bodyMedium: bayon(textStyle: textTheme.bodyMedium),
      bodySmall: bayon(textStyle: textTheme.bodySmall),
      labelLarge: bayon(textStyle: textTheme.labelLarge),
      labelMedium: bayon(textStyle: textTheme.labelMedium),
      labelSmall: bayon(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Be Vietnam Pro font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Be+Vietnam+Pro
  static TextStyle beVietnamPro({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w100,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '0abbd9ed2dbeca4d90ae2160babc5683fee0623d6619e98677d6c6c64a47e78d',
        72348,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w100,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'b31747559492756ac1ec72a582043ef3c4bb01b9644cacd0bf2341d97ab69438',
        73916,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '8442b499dec3f7ca8019bc9061a5e40b23df049b68fd6fb09e0ca82634de7fc6',
        72252,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '007babe76f7a0def9016117a5415c497089962a52f481521aa7b07923b3a2b54',
        74416,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '528f2c40df7b2e351de21c89fa2d2da9dc391eb91e462c4ca6d596626942c063',
        72484,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '97539b3eaac44fbfc77db70d3bb13477b61b28d82002d6712421e9c34d307423',
        74252,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '7137b7b25895e70fcb54f9459a4fbc520288ee1c5d1433a6b6ef7e46fe80f41c',
        72288,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '84ee08dc99068044d207dd0b14e83a0fa9daba6b5c52eeefcbf1d502d49edeb1',
        74040,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '8f73837ad7634172954987002dcf5644fd5bcfa44917d53341aa6ea27eeac36c',
        72424,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '4f965490bf034f592e9517ccd411a2fe5e9dff0b58e0b57bc0c644cdaf44065d',
        73976,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '0d403b77523ec5de7390d86eccaf8510f49274ed9a0621eb1350d65b6db8f8ac',
        72268,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '628b394f3e80196aacdcc6828ce411db4e6fe4d0b398da75a0ab22087d6264c6',
        73448,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '9349ce8e551cd214fbfcabb8b758e9cef74da57d5fb61678058909a60c916bb0',
        72172,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'cda4804e2a4fec70726ee9226a1cc997345332de65ca50a4e317551ee39957f5',
        73308,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'f47dd6df4d2348f0779645e06f9219c95e1a984142a9a2fba624f7d4cd6c5c2c',
        71864,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '062e86d2f3da0c837ae71af66ca70c3e70513d416fbf01a2cb38e472f3677820',
        73248,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '6eae3f450064c57f6f23ece8d287942d39ef4d1983fe30d427aa890455042be4',
        70768,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '480c256a2c227c03dc31705117db93192bbc4dcda9a89d2694dbfa2644e67bd1',
        72052,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'BeVietnamPro',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Be Vietnam Pro font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Be+Vietnam+Pro
  static TextTheme beVietnamProTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: beVietnamPro(textStyle: textTheme.displayLarge),
      displayMedium: beVietnamPro(textStyle: textTheme.displayMedium),
      displaySmall: beVietnamPro(textStyle: textTheme.displaySmall),
      headlineLarge: beVietnamPro(textStyle: textTheme.headlineLarge),
      headlineMedium: beVietnamPro(textStyle: textTheme.headlineMedium),
      headlineSmall: beVietnamPro(textStyle: textTheme.headlineSmall),
      titleLarge: beVietnamPro(textStyle: textTheme.titleLarge),
      titleMedium: beVietnamPro(textStyle: textTheme.titleMedium),
      titleSmall: beVietnamPro(textStyle: textTheme.titleSmall),
      bodyLarge: beVietnamPro(textStyle: textTheme.bodyLarge),
      bodyMedium: beVietnamPro(textStyle: textTheme.bodyMedium),
      bodySmall: beVietnamPro(textStyle: textTheme.bodySmall),
      labelLarge: beVietnamPro(textStyle: textTheme.labelLarge),
      labelMedium: beVietnamPro(textStyle: textTheme.labelMedium),
      labelSmall: beVietnamPro(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Beau Rivage font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Beau+Rivage
  static TextStyle beauRivage({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'ddd83eb0bdacceb749d27c2e8b767cc38b522153db450931f1ca8b682c8b423e',
        110720,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'BeauRivage',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Beau Rivage font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Beau+Rivage
  static TextTheme beauRivageTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: beauRivage(textStyle: textTheme.displayLarge),
      displayMedium: beauRivage(textStyle: textTheme.displayMedium),
      displaySmall: beauRivage(textStyle: textTheme.displaySmall),
      headlineLarge: beauRivage(textStyle: textTheme.headlineLarge),
      headlineMedium: beauRivage(textStyle: textTheme.headlineMedium),
      headlineSmall: beauRivage(textStyle: textTheme.headlineSmall),
      titleLarge: beauRivage(textStyle: textTheme.titleLarge),
      titleMedium: beauRivage(textStyle: textTheme.titleMedium),
      titleSmall: beauRivage(textStyle: textTheme.titleSmall),
      bodyLarge: beauRivage(textStyle: textTheme.bodyLarge),
      bodyMedium: beauRivage(textStyle: textTheme.bodyMedium),
      bodySmall: beauRivage(textStyle: textTheme.bodySmall),
      labelLarge: beauRivage(textStyle: textTheme.labelLarge),
      labelMedium: beauRivage(textStyle: textTheme.labelMedium),
      labelSmall: beauRivage(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Bebas Neue font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bebas+Neue
  static TextStyle bebasNeue({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'a1b67d8679c6f4d301f4a05c13d1a4032cefed98bd9b61b11b2fac9689c99116',
        38232,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'BebasNeue',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Bebas Neue font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bebas+Neue
  static TextTheme bebasNeueTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: bebasNeue(textStyle: textTheme.displayLarge),
      displayMedium: bebasNeue(textStyle: textTheme.displayMedium),
      displaySmall: bebasNeue(textStyle: textTheme.displaySmall),
      headlineLarge: bebasNeue(textStyle: textTheme.headlineLarge),
      headlineMedium: bebasNeue(textStyle: textTheme.headlineMedium),
      headlineSmall: bebasNeue(textStyle: textTheme.headlineSmall),
      titleLarge: bebasNeue(textStyle: textTheme.titleLarge),
      titleMedium: bebasNeue(textStyle: textTheme.titleMedium),
      titleSmall: bebasNeue(textStyle: textTheme.titleSmall),
      bodyLarge: bebasNeue(textStyle: textTheme.bodyLarge),
      bodyMedium: bebasNeue(textStyle: textTheme.bodyMedium),
      bodySmall: bebasNeue(textStyle: textTheme.bodySmall),
      labelLarge: bebasNeue(textStyle: textTheme.labelLarge),
      labelMedium: bebasNeue(textStyle: textTheme.labelMedium),
      labelSmall: bebasNeue(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Beiruti font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Beiruti
  static TextStyle beiruti({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'db50ac70f2eafc54f0d9728faeac03f7d06a001901837a7e47069362758a3d20',
        287876,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'b88e4b63d8cb109e59060da3025bac7ef4e1d66af84c297b1b2795934d2f1c81',
        287776,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '29bfc6ba7421f03588f887e80c39e07a13e1797d28716ae4a3adf1b1232f5ca5',
        287412,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '4c9db8ee008c0c7b4919021db44c931ce92e94c5351c6c989831b95d0204990a',
        287284,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'c02252c187ca1becaf478f76838616f956942e73fe81e35fa7b2b4f804634e79',
        287600,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '2164e954fbdf784cb26d0edb52252e8da44376f7c67e031696385ad49a88901f',
        287024,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '493dd0b10ca51318f424063bef61741e8090364a24400a70897632446bdd7708',
        287352,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'f6ce61f15d0574baf628833f33ae79f4a2dada6b198b318df31b4d951866f4b9',
        286228,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Beiruti',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Beiruti font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Beiruti
  static TextTheme beirutiTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: beiruti(textStyle: textTheme.displayLarge),
      displayMedium: beiruti(textStyle: textTheme.displayMedium),
      displaySmall: beiruti(textStyle: textTheme.displaySmall),
      headlineLarge: beiruti(textStyle: textTheme.headlineLarge),
      headlineMedium: beiruti(textStyle: textTheme.headlineMedium),
      headlineSmall: beiruti(textStyle: textTheme.headlineSmall),
      titleLarge: beiruti(textStyle: textTheme.titleLarge),
      titleMedium: beiruti(textStyle: textTheme.titleMedium),
      titleSmall: beiruti(textStyle: textTheme.titleSmall),
      bodyLarge: beiruti(textStyle: textTheme.bodyLarge),
      bodyMedium: beiruti(textStyle: textTheme.bodyMedium),
      bodySmall: beiruti(textStyle: textTheme.bodySmall),
      labelLarge: beiruti(textStyle: textTheme.labelLarge),
      labelMedium: beiruti(textStyle: textTheme.labelMedium),
      labelSmall: beiruti(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Belanosima font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Belanosima
  static TextStyle belanosima({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'b06a9311ac4b802bfd460ddb1e1536d57e6521dca28090c224cf2aadb4c176cb',
        37264,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '8cd2ff42ab4f269f649a0d3d55187a59e069bc33cef3d445a651a9bbb114371d',
        37708,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '94ca6a4a21e701cda5f93f60560fa69c22a927b1cd418757a7c271e9f0d7d0be',
        39184,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Belanosima',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Belanosima font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Belanosima
  static TextTheme belanosimaTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: belanosima(textStyle: textTheme.displayLarge),
      displayMedium: belanosima(textStyle: textTheme.displayMedium),
      displaySmall: belanosima(textStyle: textTheme.displaySmall),
      headlineLarge: belanosima(textStyle: textTheme.headlineLarge),
      headlineMedium: belanosima(textStyle: textTheme.headlineMedium),
      headlineSmall: belanosima(textStyle: textTheme.headlineSmall),
      titleLarge: belanosima(textStyle: textTheme.titleLarge),
      titleMedium: belanosima(textStyle: textTheme.titleMedium),
      titleSmall: belanosima(textStyle: textTheme.titleSmall),
      bodyLarge: belanosima(textStyle: textTheme.bodyLarge),
      bodyMedium: belanosima(textStyle: textTheme.bodyMedium),
      bodySmall: belanosima(textStyle: textTheme.bodySmall),
      labelLarge: belanosima(textStyle: textTheme.labelLarge),
      labelMedium: belanosima(textStyle: textTheme.labelMedium),
      labelSmall: belanosima(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Belgrano font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Belgrano
  static TextStyle belgrano({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'd5efe8d9726daced2f8cc022bd5b47c776764cb5a234e90690541db0301a9457',
        26644,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Belgrano',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Belgrano font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Belgrano
  static TextTheme belgranoTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: belgrano(textStyle: textTheme.displayLarge),
      displayMedium: belgrano(textStyle: textTheme.displayMedium),
      displaySmall: belgrano(textStyle: textTheme.displaySmall),
      headlineLarge: belgrano(textStyle: textTheme.headlineLarge),
      headlineMedium: belgrano(textStyle: textTheme.headlineMedium),
      headlineSmall: belgrano(textStyle: textTheme.headlineSmall),
      titleLarge: belgrano(textStyle: textTheme.titleLarge),
      titleMedium: belgrano(textStyle: textTheme.titleMedium),
      titleSmall: belgrano(textStyle: textTheme.titleSmall),
      bodyLarge: belgrano(textStyle: textTheme.bodyLarge),
      bodyMedium: belgrano(textStyle: textTheme.bodyMedium),
      bodySmall: belgrano(textStyle: textTheme.bodySmall),
      labelLarge: belgrano(textStyle: textTheme.labelLarge),
      labelMedium: belgrano(textStyle: textTheme.labelMedium),
      labelSmall: belgrano(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Bellefair font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bellefair
  static TextStyle bellefair({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '3aee7f82c73f8b42e70056cfe5c288e1416f071a21afbdc4cc3208e26739aa02',
        44092,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Bellefair',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Bellefair font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bellefair
  static TextTheme bellefairTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: bellefair(textStyle: textTheme.displayLarge),
      displayMedium: bellefair(textStyle: textTheme.displayMedium),
      displaySmall: bellefair(textStyle: textTheme.displaySmall),
      headlineLarge: bellefair(textStyle: textTheme.headlineLarge),
      headlineMedium: bellefair(textStyle: textTheme.headlineMedium),
      headlineSmall: bellefair(textStyle: textTheme.headlineSmall),
      titleLarge: bellefair(textStyle: textTheme.titleLarge),
      titleMedium: bellefair(textStyle: textTheme.titleMedium),
      titleSmall: bellefair(textStyle: textTheme.titleSmall),
      bodyLarge: bellefair(textStyle: textTheme.bodyLarge),
      bodyMedium: bellefair(textStyle: textTheme.bodyMedium),
      bodySmall: bellefair(textStyle: textTheme.bodySmall),
      labelLarge: bellefair(textStyle: textTheme.labelLarge),
      labelMedium: bellefair(textStyle: textTheme.labelMedium),
      labelSmall: bellefair(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Belleza font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Belleza
  static TextStyle belleza({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '5b66eabf3ebd0b7ec9164cfa450186715ea533e14765f3383b40e5d4e806297e',
        36788,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Belleza',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Belleza font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Belleza
  static TextTheme bellezaTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: belleza(textStyle: textTheme.displayLarge),
      displayMedium: belleza(textStyle: textTheme.displayMedium),
      displaySmall: belleza(textStyle: textTheme.displaySmall),
      headlineLarge: belleza(textStyle: textTheme.headlineLarge),
      headlineMedium: belleza(textStyle: textTheme.headlineMedium),
      headlineSmall: belleza(textStyle: textTheme.headlineSmall),
      titleLarge: belleza(textStyle: textTheme.titleLarge),
      titleMedium: belleza(textStyle: textTheme.titleMedium),
      titleSmall: belleza(textStyle: textTheme.titleSmall),
      bodyLarge: belleza(textStyle: textTheme.bodyLarge),
      bodyMedium: belleza(textStyle: textTheme.bodyMedium),
      bodySmall: belleza(textStyle: textTheme.bodySmall),
      labelLarge: belleza(textStyle: textTheme.labelLarge),
      labelMedium: belleza(textStyle: textTheme.labelMedium),
      labelSmall: belleza(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Bellota font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bellota
  static TextStyle bellota({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '7267a06224749788d1225f89aeb85648ca8f16a4c28326e271696b48a3743ba6',
        87260,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '78786fc5503dcf071074b70eaf67476238bf796d622cf9de79ebffc89421deb1',
        90124,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '2db601894a28dc47709b661019c34410a8737dc7e99dae88d8b1e35ab715089e',
        86932,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '8770c98e8ba98e597819c21f9fbd83107328857a3ca8e83e8199eb816680a440',
        89772,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '0f2646436c66e7c7d49cc54f2c1d0cfbc8589fec48b315254f5917b60073dd0f',
        87160,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '335115d63e9402c35fb1a5b477c051b2b46318e4e4dbba5844ad8b6b6e1ec4c2',
        89992,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Bellota',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Bellota font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bellota
  static TextTheme bellotaTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: bellota(textStyle: textTheme.displayLarge),
      displayMedium: bellota(textStyle: textTheme.displayMedium),
      displaySmall: bellota(textStyle: textTheme.displaySmall),
      headlineLarge: bellota(textStyle: textTheme.headlineLarge),
      headlineMedium: bellota(textStyle: textTheme.headlineMedium),
      headlineSmall: bellota(textStyle: textTheme.headlineSmall),
      titleLarge: bellota(textStyle: textTheme.titleLarge),
      titleMedium: bellota(textStyle: textTheme.titleMedium),
      titleSmall: bellota(textStyle: textTheme.titleSmall),
      bodyLarge: bellota(textStyle: textTheme.bodyLarge),
      bodyMedium: bellota(textStyle: textTheme.bodyMedium),
      bodySmall: bellota(textStyle: textTheme.bodySmall),
      labelLarge: bellota(textStyle: textTheme.labelLarge),
      labelMedium: bellota(textStyle: textTheme.labelMedium),
      labelSmall: bellota(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Bellota Text font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bellota+Text
  static TextStyle bellotaText({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '9cef5708850efe157c5d3be3170fe1d6ca556c11b85484e11b2485d95d9b3ffc',
        85412,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '2ccd789ece2cd09557ad0a842b09790270c94547c21c68576fa8661fea220639',
        88420,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '6e93788d57b23535011a5282bdaeab8a9b81d0aa95c30d479ef5a5fc8995e221',
        85288,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '7d38ea217ef5061a5a0331677d2f514ef3b7e3806dbbfd13266155806427eb4a',
        88132,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '8ce7d2b3ba8fdd826fba421bb07d1c7a86a8fde1683cf574e06d69a23c42ee7e',
        85380,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '02b8978b24462b31965580b8ec721c43933981d4d82b377b5c1ae3e0b0e1550c',
        88216,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'BellotaText',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Bellota Text font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bellota+Text
  static TextTheme bellotaTextTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: bellotaText(textStyle: textTheme.displayLarge),
      displayMedium: bellotaText(textStyle: textTheme.displayMedium),
      displaySmall: bellotaText(textStyle: textTheme.displaySmall),
      headlineLarge: bellotaText(textStyle: textTheme.headlineLarge),
      headlineMedium: bellotaText(textStyle: textTheme.headlineMedium),
      headlineSmall: bellotaText(textStyle: textTheme.headlineSmall),
      titleLarge: bellotaText(textStyle: textTheme.titleLarge),
      titleMedium: bellotaText(textStyle: textTheme.titleMedium),
      titleSmall: bellotaText(textStyle: textTheme.titleSmall),
      bodyLarge: bellotaText(textStyle: textTheme.bodyLarge),
      bodyMedium: bellotaText(textStyle: textTheme.bodyMedium),
      bodySmall: bellotaText(textStyle: textTheme.bodySmall),
      labelLarge: bellotaText(textStyle: textTheme.labelLarge),
      labelMedium: bellotaText(textStyle: textTheme.labelMedium),
      labelSmall: bellotaText(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the BenchNine font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/BenchNine
  static TextStyle benchNine({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '92efd6692cae586d570b248ab215ec7eecbd36bfa826b62daed83ab067d3d5c9',
        36148,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '5f43762fb392103ede81c2828c6c905e02b6b44c8f91e0a173fb463f6112bc3a',
        36912,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'ce2734b34c3eab0d08a45fee950a64981ae11e54f8ff0d1e4bc206c522c05674',
        36896,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'BenchNine',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the BenchNine font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/BenchNine
  static TextTheme benchNineTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: benchNine(textStyle: textTheme.displayLarge),
      displayMedium: benchNine(textStyle: textTheme.displayMedium),
      displaySmall: benchNine(textStyle: textTheme.displaySmall),
      headlineLarge: benchNine(textStyle: textTheme.headlineLarge),
      headlineMedium: benchNine(textStyle: textTheme.headlineMedium),
      headlineSmall: benchNine(textStyle: textTheme.headlineSmall),
      titleLarge: benchNine(textStyle: textTheme.titleLarge),
      titleMedium: benchNine(textStyle: textTheme.titleMedium),
      titleSmall: benchNine(textStyle: textTheme.titleSmall),
      bodyLarge: benchNine(textStyle: textTheme.bodyLarge),
      bodyMedium: benchNine(textStyle: textTheme.bodyMedium),
      bodySmall: benchNine(textStyle: textTheme.bodySmall),
      labelLarge: benchNine(textStyle: textTheme.labelLarge),
      labelMedium: benchNine(textStyle: textTheme.labelMedium),
      labelSmall: benchNine(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Benne font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Benne
  static TextStyle benne({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '2219c3539c1a6edab2abfdff57d20c101072c45318e49e0012b7717614f6080a',
        208536,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Benne',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Benne font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Benne
  static TextTheme benneTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: benne(textStyle: textTheme.displayLarge),
      displayMedium: benne(textStyle: textTheme.displayMedium),
      displaySmall: benne(textStyle: textTheme.displaySmall),
      headlineLarge: benne(textStyle: textTheme.headlineLarge),
      headlineMedium: benne(textStyle: textTheme.headlineMedium),
      headlineSmall: benne(textStyle: textTheme.headlineSmall),
      titleLarge: benne(textStyle: textTheme.titleLarge),
      titleMedium: benne(textStyle: textTheme.titleMedium),
      titleSmall: benne(textStyle: textTheme.titleSmall),
      bodyLarge: benne(textStyle: textTheme.bodyLarge),
      bodyMedium: benne(textStyle: textTheme.bodyMedium),
      bodySmall: benne(textStyle: textTheme.bodySmall),
      labelLarge: benne(textStyle: textTheme.labelLarge),
      labelMedium: benne(textStyle: textTheme.labelMedium),
      labelSmall: benne(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Bentham font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bentham
  static TextStyle bentham({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'bcf337bffd8dfc3b429455fc044c3a1e8e073f380a32d15a1c7169381dd10141',
        25852,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Bentham',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Bentham font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bentham
  static TextTheme benthamTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: bentham(textStyle: textTheme.displayLarge),
      displayMedium: bentham(textStyle: textTheme.displayMedium),
      displaySmall: bentham(textStyle: textTheme.displaySmall),
      headlineLarge: bentham(textStyle: textTheme.headlineLarge),
      headlineMedium: bentham(textStyle: textTheme.headlineMedium),
      headlineSmall: bentham(textStyle: textTheme.headlineSmall),
      titleLarge: bentham(textStyle: textTheme.titleLarge),
      titleMedium: bentham(textStyle: textTheme.titleMedium),
      titleSmall: bentham(textStyle: textTheme.titleSmall),
      bodyLarge: bentham(textStyle: textTheme.bodyLarge),
      bodyMedium: bentham(textStyle: textTheme.bodyMedium),
      bodySmall: bentham(textStyle: textTheme.bodySmall),
      labelLarge: bentham(textStyle: textTheme.labelLarge),
      labelMedium: bentham(textStyle: textTheme.labelMedium),
      labelSmall: bentham(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Berkshire Swash font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Berkshire+Swash
  static TextStyle berkshireSwash({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'cfd5e58bb57d809250fe10f8b696c58318e41c6f90127a37a106e94c0690b163',
        51908,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'BerkshireSwash',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Berkshire Swash font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Berkshire+Swash
  static TextTheme berkshireSwashTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: berkshireSwash(textStyle: textTheme.displayLarge),
      displayMedium: berkshireSwash(textStyle: textTheme.displayMedium),
      displaySmall: berkshireSwash(textStyle: textTheme.displaySmall),
      headlineLarge: berkshireSwash(textStyle: textTheme.headlineLarge),
      headlineMedium: berkshireSwash(textStyle: textTheme.headlineMedium),
      headlineSmall: berkshireSwash(textStyle: textTheme.headlineSmall),
      titleLarge: berkshireSwash(textStyle: textTheme.titleLarge),
      titleMedium: berkshireSwash(textStyle: textTheme.titleMedium),
      titleSmall: berkshireSwash(textStyle: textTheme.titleSmall),
      bodyLarge: berkshireSwash(textStyle: textTheme.bodyLarge),
      bodyMedium: berkshireSwash(textStyle: textTheme.bodyMedium),
      bodySmall: berkshireSwash(textStyle: textTheme.bodySmall),
      labelLarge: berkshireSwash(textStyle: textTheme.labelLarge),
      labelMedium: berkshireSwash(textStyle: textTheme.labelMedium),
      labelSmall: berkshireSwash(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Besley font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Besley
  static TextStyle besley({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '511f7241b61b58441847bbac772582ed41232c52aa7fecd9b694830214352ea1',
        55960,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '50440c54b5011cea5bb0f936a95668cd337c55167d7f3e2bcd71563c5fd4bd6a',
        56036,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'f9b2d5c5a967853b2eadc22d4c1ec84527e28b02fdf3816513cb5ec6e7f1b69f',
        56048,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '5976ea0a093b65066aa15add62004ad659b32c1867006d6914f9ee05188bf855',
        55988,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '3fda52282fefb3b8aad0ab0eb2e983f351fc5ed51c7ce418085d8634a53a0abc',
        56052,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '88ada78918e7a9777b226b24917f5a6995d053ccf75dfc38c6e941ea28f07f1c',
        56016,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '9b6ddf109e70f4a0d0f7070c9049874d8cf2f73b0edc7349047ee2b0e13f2276',
        56532,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '7268e27875f9dfc9d399dc94523b7cb5b9c9a3889d836df1276695f88ced644e',
        56728,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '28f14e12cfb4ba4bb3d61a96389ed8dbc842ed963141adf2f5cc338c585963c1',
        56768,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'e77e0dfc92a9279717b554cc44f8a98b11fab51096ef405e4ca34ccfbe5a4e3d',
        56688,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '39845314c440f9b2ec730f52484e546c48d61f049f4eb548be07316d0ce0df4e',
        56792,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '2abf48e1697e5b7ce9e369cb567bac1b2b1a727145aeafd6f75cd79ee42e646e',
        56736,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Besley',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Besley font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Besley
  static TextTheme besleyTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: besley(textStyle: textTheme.displayLarge),
      displayMedium: besley(textStyle: textTheme.displayMedium),
      displaySmall: besley(textStyle: textTheme.displaySmall),
      headlineLarge: besley(textStyle: textTheme.headlineLarge),
      headlineMedium: besley(textStyle: textTheme.headlineMedium),
      headlineSmall: besley(textStyle: textTheme.headlineSmall),
      titleLarge: besley(textStyle: textTheme.titleLarge),
      titleMedium: besley(textStyle: textTheme.titleMedium),
      titleSmall: besley(textStyle: textTheme.titleSmall),
      bodyLarge: besley(textStyle: textTheme.bodyLarge),
      bodyMedium: besley(textStyle: textTheme.bodyMedium),
      bodySmall: besley(textStyle: textTheme.bodySmall),
      labelLarge: besley(textStyle: textTheme.labelLarge),
      labelMedium: besley(textStyle: textTheme.labelMedium),
      labelSmall: besley(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Beth Ellen font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Beth+Ellen
  static TextStyle bethEllen({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'b8fa596edd5e469e18ec8d90f6481be7e5d372eec2f20ccf3cb0c53e1e220ab0',
        115600,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'BethEllen',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Beth Ellen font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Beth+Ellen
  static TextTheme bethEllenTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: bethEllen(textStyle: textTheme.displayLarge),
      displayMedium: bethEllen(textStyle: textTheme.displayMedium),
      displaySmall: bethEllen(textStyle: textTheme.displaySmall),
      headlineLarge: bethEllen(textStyle: textTheme.headlineLarge),
      headlineMedium: bethEllen(textStyle: textTheme.headlineMedium),
      headlineSmall: bethEllen(textStyle: textTheme.headlineSmall),
      titleLarge: bethEllen(textStyle: textTheme.titleLarge),
      titleMedium: bethEllen(textStyle: textTheme.titleMedium),
      titleSmall: bethEllen(textStyle: textTheme.titleSmall),
      bodyLarge: bethEllen(textStyle: textTheme.bodyLarge),
      bodyMedium: bethEllen(textStyle: textTheme.bodyMedium),
      bodySmall: bethEllen(textStyle: textTheme.bodySmall),
      labelLarge: bethEllen(textStyle: textTheme.labelLarge),
      labelMedium: bethEllen(textStyle: textTheme.labelMedium),
      labelSmall: bethEllen(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Bevan font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bevan
  static TextStyle bevan({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '89b233a253487b49138d44eb02ba920cb80f8ebc0758e595b026c97a118a1e33',
        70020,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'ea63f16995057978687af4c11e41be55d08bdca55ff7f23641eb257dc89a6f5b',
        71216,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Bevan',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Bevan font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bevan
  static TextTheme bevanTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: bevan(textStyle: textTheme.displayLarge),
      displayMedium: bevan(textStyle: textTheme.displayMedium),
      displaySmall: bevan(textStyle: textTheme.displaySmall),
      headlineLarge: bevan(textStyle: textTheme.headlineLarge),
      headlineMedium: bevan(textStyle: textTheme.headlineMedium),
      headlineSmall: bevan(textStyle: textTheme.headlineSmall),
      titleLarge: bevan(textStyle: textTheme.titleLarge),
      titleMedium: bevan(textStyle: textTheme.titleMedium),
      titleSmall: bevan(textStyle: textTheme.titleSmall),
      bodyLarge: bevan(textStyle: textTheme.bodyLarge),
      bodyMedium: bevan(textStyle: textTheme.bodyMedium),
      bodySmall: bevan(textStyle: textTheme.bodySmall),
      labelLarge: bevan(textStyle: textTheme.labelLarge),
      labelMedium: bevan(textStyle: textTheme.labelMedium),
      labelSmall: bevan(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the BhuTuka Expanded One font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/BhuTuka+Expanded+One
  static TextStyle bhuTukaExpandedOne({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '2eb2824cee42683348eb122be61b4f039d0425ec84a9ee7a0fad924c35e18a05',
        63848,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'BhuTukaExpandedOne',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the BhuTuka Expanded One font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/BhuTuka+Expanded+One
  static TextTheme bhuTukaExpandedOneTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: bhuTukaExpandedOne(textStyle: textTheme.displayLarge),
      displayMedium: bhuTukaExpandedOne(textStyle: textTheme.displayMedium),
      displaySmall: bhuTukaExpandedOne(textStyle: textTheme.displaySmall),
      headlineLarge: bhuTukaExpandedOne(textStyle: textTheme.headlineLarge),
      headlineMedium: bhuTukaExpandedOne(textStyle: textTheme.headlineMedium),
      headlineSmall: bhuTukaExpandedOne(textStyle: textTheme.headlineSmall),
      titleLarge: bhuTukaExpandedOne(textStyle: textTheme.titleLarge),
      titleMedium: bhuTukaExpandedOne(textStyle: textTheme.titleMedium),
      titleSmall: bhuTukaExpandedOne(textStyle: textTheme.titleSmall),
      bodyLarge: bhuTukaExpandedOne(textStyle: textTheme.bodyLarge),
      bodyMedium: bhuTukaExpandedOne(textStyle: textTheme.bodyMedium),
      bodySmall: bhuTukaExpandedOne(textStyle: textTheme.bodySmall),
      labelLarge: bhuTukaExpandedOne(textStyle: textTheme.labelLarge),
      labelMedium: bhuTukaExpandedOne(textStyle: textTheme.labelMedium),
      labelSmall: bhuTukaExpandedOne(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Big Shoulders font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Big+Shoulders
  static TextStyle bigShoulders({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w100,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '237230a1c554b183fd764a6481eb7d3a398a7cc7e2c9a23c3c94b73d5822613f',
        63188,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'e2ab8b708e1dbde8b791a3f2b9eff13f71c67349014cb1ef20497247e44cebf5',
        63596,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '16ec547dc5a08a1efb3795c468bc1521d86a7d25b42c51bcfac9e8663915102b',
        63616,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '3812edaeb38c61deca4a2e6b17e76d9920f1d71f3f9e2b23d0b7dbaf36c85b23',
        63536,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'a7d1228899e584e9dab04cba5a0d672d7d113525aa197f0c64dc7122833ebbed',
        63576,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '73ec48b9692a8436613666bf3c49731eea2e6746ca666baff891d70344285532',
        63536,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '47d2b3b669b0197fc095e56afe9ef7ba85edcb91dff39803649188b8a9bf5f81',
        63656,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '3afbc1a44918e7be879319aca89816b290a9a660d12a1e4f6b257e1c52376225',
        63688,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '9ee8f9d3e06cd96b25dbc01fff3ff31326ba2a7db487a188d334d0acf470db86',
        63640,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'BigShoulders',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Big Shoulders font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Big+Shoulders
  static TextTheme bigShouldersTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: bigShoulders(textStyle: textTheme.displayLarge),
      displayMedium: bigShoulders(textStyle: textTheme.displayMedium),
      displaySmall: bigShoulders(textStyle: textTheme.displaySmall),
      headlineLarge: bigShoulders(textStyle: textTheme.headlineLarge),
      headlineMedium: bigShoulders(textStyle: textTheme.headlineMedium),
      headlineSmall: bigShoulders(textStyle: textTheme.headlineSmall),
      titleLarge: bigShoulders(textStyle: textTheme.titleLarge),
      titleMedium: bigShoulders(textStyle: textTheme.titleMedium),
      titleSmall: bigShoulders(textStyle: textTheme.titleSmall),
      bodyLarge: bigShoulders(textStyle: textTheme.bodyLarge),
      bodyMedium: bigShoulders(textStyle: textTheme.bodyMedium),
      bodySmall: bigShoulders(textStyle: textTheme.bodySmall),
      labelLarge: bigShoulders(textStyle: textTheme.labelLarge),
      labelMedium: bigShoulders(textStyle: textTheme.labelMedium),
      labelSmall: bigShoulders(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Big Shoulders Inline font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Big+Shoulders+Inline
  static TextStyle bigShouldersInline({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w100,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'a833f245b2c5183d5eb041517b716c976cc26d227f7e3d5dbf8335c49c385d2c',
        109700,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '109b547d84a32b95f90604fdfe6c5cb039992c72ca94feb6de28f9eadf098b74',
        110356,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '327ed00b99063c4784cdc5d29d77b19bff225bbbc0abdce9e682de878b023219',
        110800,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '0333fd713fecb288a8287a2b73efae0505334515f7a51562e277d5ef2c4cf34e',
        111296,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '354208831440c2ae6751fed2a5a25e5c8a0086b8b35ea3253817b63f7b967ee1',
        111836,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '54a462931529f2ab9870573a2626615e7f54cfe028b96301e4f45782cf9ac7ac',
        112124,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '75dc4d40eb25b5a5a4d8faf769025f5ba03a0f229dfcbcbaa518f1d108b2222f',
        112440,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '546ce59401a4d66b0ae78f202a0da6cab9e35879fc9b5bf83afd9cca7a16efe1',
        112744,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '68993b91538bec40487bd17215a935950453d8ad3c06e2d95a5e8a8c7e1c60a2',
        112436,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'BigShouldersInline',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Big Shoulders Inline font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Big+Shoulders+Inline
  static TextTheme bigShouldersInlineTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: bigShouldersInline(textStyle: textTheme.displayLarge),
      displayMedium: bigShouldersInline(textStyle: textTheme.displayMedium),
      displaySmall: bigShouldersInline(textStyle: textTheme.displaySmall),
      headlineLarge: bigShouldersInline(textStyle: textTheme.headlineLarge),
      headlineMedium: bigShouldersInline(textStyle: textTheme.headlineMedium),
      headlineSmall: bigShouldersInline(textStyle: textTheme.headlineSmall),
      titleLarge: bigShouldersInline(textStyle: textTheme.titleLarge),
      titleMedium: bigShouldersInline(textStyle: textTheme.titleMedium),
      titleSmall: bigShouldersInline(textStyle: textTheme.titleSmall),
      bodyLarge: bigShouldersInline(textStyle: textTheme.bodyLarge),
      bodyMedium: bigShouldersInline(textStyle: textTheme.bodyMedium),
      bodySmall: bigShouldersInline(textStyle: textTheme.bodySmall),
      labelLarge: bigShouldersInline(textStyle: textTheme.labelLarge),
      labelMedium: bigShouldersInline(textStyle: textTheme.labelMedium),
      labelSmall: bigShouldersInline(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Big Shoulders Stencil font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Big+Shoulders+Stencil
  static TextStyle bigShouldersStencil({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w100,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'ccac3b45a958887deaa3a7a7d6f6474e54caf5c856abe723c9006f6c84bcf6c7',
        65568,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '2969720c09dd4a7fca568839df87aff6997844eae021748bde5fcccb2e0046cb',
        65952,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '657a2d7b1f2301196da81c0d89c66b6fb775c4c619cdbec2cf92e6f7d850015a',
        65956,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '77d90f19f483276f7703667ca45e3ff2a0fa72288d0bcead1df2917a901c9331',
        65960,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '3f7c7c2d6f6cc74cee5bef4bb6d17ef4103dacea7552cf5d0d0f9a5e3ba4921d',
        65988,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'e3ac2c64de59f37126283fd1b3f3768b6891d8f6f6c7a427439496610fd12068',
        66016,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '8b70408ed19b86f837a7df71f239d8ac7830b3cfd5943056ec81e9a67c484e80',
        66108,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '3284108be1ccc93b4a00afec249287e3d8d7a7a5dc2fb89e4e77d09bcb7407fa',
        66140,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'c6886f2ff96eb848292d43369dcaa7cb73f3b386f982132fb212fc5823028dd4',
        66120,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'BigShouldersStencil',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Big Shoulders Stencil font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Big+Shoulders+Stencil
  static TextTheme bigShouldersStencilTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: bigShouldersStencil(textStyle: textTheme.displayLarge),
      displayMedium: bigShouldersStencil(textStyle: textTheme.displayMedium),
      displaySmall: bigShouldersStencil(textStyle: textTheme.displaySmall),
      headlineLarge: bigShouldersStencil(textStyle: textTheme.headlineLarge),
      headlineMedium: bigShouldersStencil(textStyle: textTheme.headlineMedium),
      headlineSmall: bigShouldersStencil(textStyle: textTheme.headlineSmall),
      titleLarge: bigShouldersStencil(textStyle: textTheme.titleLarge),
      titleMedium: bigShouldersStencil(textStyle: textTheme.titleMedium),
      titleSmall: bigShouldersStencil(textStyle: textTheme.titleSmall),
      bodyLarge: bigShouldersStencil(textStyle: textTheme.bodyLarge),
      bodyMedium: bigShouldersStencil(textStyle: textTheme.bodyMedium),
      bodySmall: bigShouldersStencil(textStyle: textTheme.bodySmall),
      labelLarge: bigShouldersStencil(textStyle: textTheme.labelLarge),
      labelMedium: bigShouldersStencil(textStyle: textTheme.labelMedium),
      labelSmall: bigShouldersStencil(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Bigelow Rules font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bigelow+Rules
  static TextStyle bigelowRules({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '6a62c6e3152496d73b77afec95caaae2121da662cd31ae0171bc1187e471cf58',
        56704,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'BigelowRules',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Bigelow Rules font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bigelow+Rules
  static TextTheme bigelowRulesTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: bigelowRules(textStyle: textTheme.displayLarge),
      displayMedium: bigelowRules(textStyle: textTheme.displayMedium),
      displaySmall: bigelowRules(textStyle: textTheme.displaySmall),
      headlineLarge: bigelowRules(textStyle: textTheme.headlineLarge),
      headlineMedium: bigelowRules(textStyle: textTheme.headlineMedium),
      headlineSmall: bigelowRules(textStyle: textTheme.headlineSmall),
      titleLarge: bigelowRules(textStyle: textTheme.titleLarge),
      titleMedium: bigelowRules(textStyle: textTheme.titleMedium),
      titleSmall: bigelowRules(textStyle: textTheme.titleSmall),
      bodyLarge: bigelowRules(textStyle: textTheme.bodyLarge),
      bodyMedium: bigelowRules(textStyle: textTheme.bodyMedium),
      bodySmall: bigelowRules(textStyle: textTheme.bodySmall),
      labelLarge: bigelowRules(textStyle: textTheme.labelLarge),
      labelMedium: bigelowRules(textStyle: textTheme.labelMedium),
      labelSmall: bigelowRules(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Bigshot One font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bigshot+One
  static TextStyle bigshotOne({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '2b76bb5317fd3b7b99dc5ff17dbe492388438f36e8ee8348c2ae3ab4d7e1303f',
        34916,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'BigshotOne',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Bigshot One font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bigshot+One
  static TextTheme bigshotOneTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: bigshotOne(textStyle: textTheme.displayLarge),
      displayMedium: bigshotOne(textStyle: textTheme.displayMedium),
      displaySmall: bigshotOne(textStyle: textTheme.displaySmall),
      headlineLarge: bigshotOne(textStyle: textTheme.headlineLarge),
      headlineMedium: bigshotOne(textStyle: textTheme.headlineMedium),
      headlineSmall: bigshotOne(textStyle: textTheme.headlineSmall),
      titleLarge: bigshotOne(textStyle: textTheme.titleLarge),
      titleMedium: bigshotOne(textStyle: textTheme.titleMedium),
      titleSmall: bigshotOne(textStyle: textTheme.titleSmall),
      bodyLarge: bigshotOne(textStyle: textTheme.bodyLarge),
      bodyMedium: bigshotOne(textStyle: textTheme.bodyMedium),
      bodySmall: bigshotOne(textStyle: textTheme.bodySmall),
      labelLarge: bigshotOne(textStyle: textTheme.labelLarge),
      labelMedium: bigshotOne(textStyle: textTheme.labelMedium),
      labelSmall: bigshotOne(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Bilbo font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bilbo
  static TextStyle bilbo({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '603ce5a07f703ff9000ce47f89253da5c9b8c6a1f2375074ed87f4319dafa373',
        61336,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Bilbo',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Bilbo font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bilbo
  static TextTheme bilboTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: bilbo(textStyle: textTheme.displayLarge),
      displayMedium: bilbo(textStyle: textTheme.displayMedium),
      displaySmall: bilbo(textStyle: textTheme.displaySmall),
      headlineLarge: bilbo(textStyle: textTheme.headlineLarge),
      headlineMedium: bilbo(textStyle: textTheme.headlineMedium),
      headlineSmall: bilbo(textStyle: textTheme.headlineSmall),
      titleLarge: bilbo(textStyle: textTheme.titleLarge),
      titleMedium: bilbo(textStyle: textTheme.titleMedium),
      titleSmall: bilbo(textStyle: textTheme.titleSmall),
      bodyLarge: bilbo(textStyle: textTheme.bodyLarge),
      bodyMedium: bilbo(textStyle: textTheme.bodyMedium),
      bodySmall: bilbo(textStyle: textTheme.bodySmall),
      labelLarge: bilbo(textStyle: textTheme.labelLarge),
      labelMedium: bilbo(textStyle: textTheme.labelMedium),
      labelSmall: bilbo(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Bilbo Swash Caps font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bilbo+Swash+Caps
  static TextStyle bilboSwashCaps({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '95657ec0a940025da15129acd62ba8833f92775dcf6d05e394f076f587e3a405',
        56284,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'BilboSwashCaps',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Bilbo Swash Caps font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bilbo+Swash+Caps
  static TextTheme bilboSwashCapsTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: bilboSwashCaps(textStyle: textTheme.displayLarge),
      displayMedium: bilboSwashCaps(textStyle: textTheme.displayMedium),
      displaySmall: bilboSwashCaps(textStyle: textTheme.displaySmall),
      headlineLarge: bilboSwashCaps(textStyle: textTheme.headlineLarge),
      headlineMedium: bilboSwashCaps(textStyle: textTheme.headlineMedium),
      headlineSmall: bilboSwashCaps(textStyle: textTheme.headlineSmall),
      titleLarge: bilboSwashCaps(textStyle: textTheme.titleLarge),
      titleMedium: bilboSwashCaps(textStyle: textTheme.titleMedium),
      titleSmall: bilboSwashCaps(textStyle: textTheme.titleSmall),
      bodyLarge: bilboSwashCaps(textStyle: textTheme.bodyLarge),
      bodyMedium: bilboSwashCaps(textStyle: textTheme.bodyMedium),
      bodySmall: bilboSwashCaps(textStyle: textTheme.bodySmall),
      labelLarge: bilboSwashCaps(textStyle: textTheme.labelLarge),
      labelMedium: bilboSwashCaps(textStyle: textTheme.labelMedium),
      labelSmall: bilboSwashCaps(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the BioRhyme font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/BioRhyme
  static TextStyle bioRhyme({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '0b35fc1178716d3980a8adfc22a9f3bdc7319f931db1c93c8e3efa70bbe7f21d',
        61072,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'b3b1323f5db832bdf812038feb84a6ebf51334400e6212a3cff768db3abe99ac',
        61136,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '2e411090117deaabec68bea5f20de31572affb74095154fc0c8cbe5216937677',
        61816,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '95f551a833ccb4240dfbaffd36a52514e0a77e4e4d5bfb348ea5ede2900d3be7',
        61788,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '7c0fd909bff66acc36fd1f985f8ae85e9490928f38cde07afcd1c83d9da8f075',
        61836,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '1de28b6c2639021699b808e3dd8eea89c33804c3f70851f8d81e2f79467da025',
        61804,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '1a312280d99e51163175a4809d6c504e14516ca43c9c6ec75af200a189c040de',
        61836,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'BioRhyme',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the BioRhyme font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/BioRhyme
  static TextTheme bioRhymeTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: bioRhyme(textStyle: textTheme.displayLarge),
      displayMedium: bioRhyme(textStyle: textTheme.displayMedium),
      displaySmall: bioRhyme(textStyle: textTheme.displaySmall),
      headlineLarge: bioRhyme(textStyle: textTheme.headlineLarge),
      headlineMedium: bioRhyme(textStyle: textTheme.headlineMedium),
      headlineSmall: bioRhyme(textStyle: textTheme.headlineSmall),
      titleLarge: bioRhyme(textStyle: textTheme.titleLarge),
      titleMedium: bioRhyme(textStyle: textTheme.titleMedium),
      titleSmall: bioRhyme(textStyle: textTheme.titleSmall),
      bodyLarge: bioRhyme(textStyle: textTheme.bodyLarge),
      bodyMedium: bioRhyme(textStyle: textTheme.bodyMedium),
      bodySmall: bioRhyme(textStyle: textTheme.bodySmall),
      labelLarge: bioRhyme(textStyle: textTheme.labelLarge),
      labelMedium: bioRhyme(textStyle: textTheme.labelMedium),
      labelSmall: bioRhyme(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Birthstone font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Birthstone
  static TextStyle birthstone({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '8e6a7552babbd7b3d3170ae34652c5d480c97785c6728771a57d2f1ba516e733',
        97192,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Birthstone',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Birthstone font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Birthstone
  static TextTheme birthstoneTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: birthstone(textStyle: textTheme.displayLarge),
      displayMedium: birthstone(textStyle: textTheme.displayMedium),
      displaySmall: birthstone(textStyle: textTheme.displaySmall),
      headlineLarge: birthstone(textStyle: textTheme.headlineLarge),
      headlineMedium: birthstone(textStyle: textTheme.headlineMedium),
      headlineSmall: birthstone(textStyle: textTheme.headlineSmall),
      titleLarge: birthstone(textStyle: textTheme.titleLarge),
      titleMedium: birthstone(textStyle: textTheme.titleMedium),
      titleSmall: birthstone(textStyle: textTheme.titleSmall),
      bodyLarge: birthstone(textStyle: textTheme.bodyLarge),
      bodyMedium: birthstone(textStyle: textTheme.bodyMedium),
      bodySmall: birthstone(textStyle: textTheme.bodySmall),
      labelLarge: birthstone(textStyle: textTheme.labelLarge),
      labelMedium: birthstone(textStyle: textTheme.labelMedium),
      labelSmall: birthstone(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Birthstone Bounce font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Birthstone+Bounce
  static TextStyle birthstoneBounce({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'fbafd412c4739437d20d47a53dbad7e2916fe95f15983c5bf0459ae72557de1c',
        131964,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'd1635cd58a8d9037191e3a18161e334ba11042e3d875fb5cf285c203d551364a',
        129328,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'BirthstoneBounce',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Birthstone Bounce font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Birthstone+Bounce
  static TextTheme birthstoneBounceTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: birthstoneBounce(textStyle: textTheme.displayLarge),
      displayMedium: birthstoneBounce(textStyle: textTheme.displayMedium),
      displaySmall: birthstoneBounce(textStyle: textTheme.displaySmall),
      headlineLarge: birthstoneBounce(textStyle: textTheme.headlineLarge),
      headlineMedium: birthstoneBounce(textStyle: textTheme.headlineMedium),
      headlineSmall: birthstoneBounce(textStyle: textTheme.headlineSmall),
      titleLarge: birthstoneBounce(textStyle: textTheme.titleLarge),
      titleMedium: birthstoneBounce(textStyle: textTheme.titleMedium),
      titleSmall: birthstoneBounce(textStyle: textTheme.titleSmall),
      bodyLarge: birthstoneBounce(textStyle: textTheme.bodyLarge),
      bodyMedium: birthstoneBounce(textStyle: textTheme.bodyMedium),
      bodySmall: birthstoneBounce(textStyle: textTheme.bodySmall),
      labelLarge: birthstoneBounce(textStyle: textTheme.labelLarge),
      labelMedium: birthstoneBounce(textStyle: textTheme.labelMedium),
      labelSmall: birthstoneBounce(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Biryani font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Biryani
  static TextStyle biryani({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '43f9c4bdde725631d29d167134fd5d47bd43693f7e6854f8c2b2ab0b338838e7',
        116780,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'bed1c9a1c7d0532f742884921d2f92b32e36711cf751fefee592dde6c3e548e0',
        117180,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'ee53d8459db00d28d5dfe7a5443a7ea8a062d16b909088740d908bdd07617b82',
        116488,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'dd5594dc9b9328abb474af0883f6afabf26f214242586212b5d9ab147a0aa706',
        116460,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '4e3d6fea266747c0bf050aaf720ba717a3af53b91e13760a3e34709632039372',
        116280,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'f7c59e26470dd34e265d4a84977ee65a3df787169ae7fc20ad8d7bbee0ce636a',
        116244,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '4e9274784b25a5f18c439c8461f459dcf27099a5390cea69cc38c0329ced0635',
        115348,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Biryani',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Biryani font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Biryani
  static TextTheme biryaniTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: biryani(textStyle: textTheme.displayLarge),
      displayMedium: biryani(textStyle: textTheme.displayMedium),
      displaySmall: biryani(textStyle: textTheme.displaySmall),
      headlineLarge: biryani(textStyle: textTheme.headlineLarge),
      headlineMedium: biryani(textStyle: textTheme.headlineMedium),
      headlineSmall: biryani(textStyle: textTheme.headlineSmall),
      titleLarge: biryani(textStyle: textTheme.titleLarge),
      titleMedium: biryani(textStyle: textTheme.titleMedium),
      titleSmall: biryani(textStyle: textTheme.titleSmall),
      bodyLarge: biryani(textStyle: textTheme.bodyLarge),
      bodyMedium: biryani(textStyle: textTheme.bodyMedium),
      bodySmall: biryani(textStyle: textTheme.bodySmall),
      labelLarge: biryani(textStyle: textTheme.labelLarge),
      labelMedium: biryani(textStyle: textTheme.labelMedium),
      labelSmall: biryani(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Bitcount font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bitcount
  static TextStyle bitcount({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w100,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '2c82a650bf296cc8129980f4854adb4d25aae5fa941a922f9ef22b1eed7aa74f',
        65248,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'facc42638dd9bd1eefd18acf27fbead928d07af0d88adc5957c81c4c2714b2e0',
        65296,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'dd0bb156fade36be5338407e58166a84fdeb7cac7383ac8535475fcff1f97c63',
        65272,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '98b827e4d3d921a1beb0d95ef48afe0b84f723c364f2b677b7c4f90489f77d59',
        65256,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'f63b04f90dbb33e89fc5bed8f1959ff0c6f561d463f2a28122f0ec71e74a797b',
        65280,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'e080ad62f96558b935e1a5fd1a26eb9ca1c0485a050cab29465b8b72729afdf0',
        65296,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'c96aaf5a9214430c4d1902d7d08a9049ad7629ef5681a7c57485b861b5b02c6a',
        65228,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '0ed23a8bd64d470f5e8e02afd787135ed20839df1f661ee4707e0d733431e69b',
        65304,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '394d3ff6eefc431673c59154269d8a6c89294127a4b8b312997d3a801a760f13',
        65272,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Bitcount',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Bitcount font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bitcount
  static TextTheme bitcountTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: bitcount(textStyle: textTheme.displayLarge),
      displayMedium: bitcount(textStyle: textTheme.displayMedium),
      displaySmall: bitcount(textStyle: textTheme.displaySmall),
      headlineLarge: bitcount(textStyle: textTheme.headlineLarge),
      headlineMedium: bitcount(textStyle: textTheme.headlineMedium),
      headlineSmall: bitcount(textStyle: textTheme.headlineSmall),
      titleLarge: bitcount(textStyle: textTheme.titleLarge),
      titleMedium: bitcount(textStyle: textTheme.titleMedium),
      titleSmall: bitcount(textStyle: textTheme.titleSmall),
      bodyLarge: bitcount(textStyle: textTheme.bodyLarge),
      bodyMedium: bitcount(textStyle: textTheme.bodyMedium),
      bodySmall: bitcount(textStyle: textTheme.bodySmall),
      labelLarge: bitcount(textStyle: textTheme.labelLarge),
      labelMedium: bitcount(textStyle: textTheme.labelMedium),
      labelSmall: bitcount(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Bitcount Grid Double font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bitcount+Grid+Double
  static TextStyle bitcountGridDouble({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w100,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'b53c3c0249eacdfa94e816ee8ac8fc7e5dabcfe146dc5c3c492637ed6250e84b',
        61664,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'a7ce780c8bcc111c3630efa42235a182b0f00e460568989233320e75ab6c87ae',
        61712,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '3acbf4e48cfd8e99a7481c292c4b4b1d738ee017d6e07e153ffbdc94c8e9d186',
        61688,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '64022eaf4cf469db40d5db8ac673084b1c9afff3d599ba24cd209e02b9a74d52',
        61672,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '73e12d8d2ef9d04319d34e48860149e4dd0ffc2ceb2e736c165afa2fff214105',
        61696,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'af1a9d76ad7dfc907dc61607db88102a55d9437733f3353992b0337cc05fe43e',
        61712,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'f3c22c8c6d22f4fdf257ca5aa83b3143945e3ba8e52f23967871e17e5990dc98',
        61644,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '8804c67cb3c315678768e9be8ae438826d4b666b7c7604ebdf44a749cf44e935',
        61720,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'ff98423a09c314fb0e076b0158834f60e5bee55021e540a15b6a4293fdeddd15',
        61688,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'BitcountGridDouble',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Bitcount Grid Double font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bitcount+Grid+Double
  static TextTheme bitcountGridDoubleTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: bitcountGridDouble(textStyle: textTheme.displayLarge),
      displayMedium: bitcountGridDouble(textStyle: textTheme.displayMedium),
      displaySmall: bitcountGridDouble(textStyle: textTheme.displaySmall),
      headlineLarge: bitcountGridDouble(textStyle: textTheme.headlineLarge),
      headlineMedium: bitcountGridDouble(textStyle: textTheme.headlineMedium),
      headlineSmall: bitcountGridDouble(textStyle: textTheme.headlineSmall),
      titleLarge: bitcountGridDouble(textStyle: textTheme.titleLarge),
      titleMedium: bitcountGridDouble(textStyle: textTheme.titleMedium),
      titleSmall: bitcountGridDouble(textStyle: textTheme.titleSmall),
      bodyLarge: bitcountGridDouble(textStyle: textTheme.bodyLarge),
      bodyMedium: bitcountGridDouble(textStyle: textTheme.bodyMedium),
      bodySmall: bitcountGridDouble(textStyle: textTheme.bodySmall),
      labelLarge: bitcountGridDouble(textStyle: textTheme.labelLarge),
      labelMedium: bitcountGridDouble(textStyle: textTheme.labelMedium),
      labelSmall: bitcountGridDouble(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Bitcount Grid Double Ink font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bitcount+Grid+Double+Ink
  static TextStyle bitcountGridDoubleInk({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w100,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '3bf8ec16bfca3f9acefd4798cd522516b13d532371b31e0978fc4f549c0a41f1',
        79988,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'c9af046219c9d4d7012b2fae55ae51ea7357fe2200dca39b0deb23c53edb5189',
        80036,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '24517e467ee6739aac9757e46152166133fe11f1b60d83177a6c1ded6040a686',
        80012,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '83d8799dc4d455c1155be3d102b7ea79e1d48b49e4f9a1b4818d7ae95ce765ba',
        79996,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '7230ac2205116dcac2c0f5cba9def17d4a68cfded5cf4802156f1f6848c2696d',
        80020,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '8115fe238743e25fc1a12492b4454c531614629113249190db5ca0b2b36df40f',
        80036,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '756fd7d51764e5568d91df41dac6cb1b651b35310620756558cdb6f1f00df8ac',
        79968,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '8d2e44526c7a67b98f42d7c502fd4ec26f019972667c32ee5aecbfa0aef61ceb',
        80044,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '5f775703bad34af155c9376eb21f57a0823f51feda4e87c3c72c6cefa9632ca6',
        80012,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'BitcountGridDoubleInk',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Bitcount Grid Double Ink font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bitcount+Grid+Double+Ink
  static TextTheme bitcountGridDoubleInkTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: bitcountGridDoubleInk(textStyle: textTheme.displayLarge),
      displayMedium: bitcountGridDoubleInk(textStyle: textTheme.displayMedium),
      displaySmall: bitcountGridDoubleInk(textStyle: textTheme.displaySmall),
      headlineLarge: bitcountGridDoubleInk(textStyle: textTheme.headlineLarge),
      headlineMedium: bitcountGridDoubleInk(
        textStyle: textTheme.headlineMedium,
      ),
      headlineSmall: bitcountGridDoubleInk(textStyle: textTheme.headlineSmall),
      titleLarge: bitcountGridDoubleInk(textStyle: textTheme.titleLarge),
      titleMedium: bitcountGridDoubleInk(textStyle: textTheme.titleMedium),
      titleSmall: bitcountGridDoubleInk(textStyle: textTheme.titleSmall),
      bodyLarge: bitcountGridDoubleInk(textStyle: textTheme.bodyLarge),
      bodyMedium: bitcountGridDoubleInk(textStyle: textTheme.bodyMedium),
      bodySmall: bitcountGridDoubleInk(textStyle: textTheme.bodySmall),
      labelLarge: bitcountGridDoubleInk(textStyle: textTheme.labelLarge),
      labelMedium: bitcountGridDoubleInk(textStyle: textTheme.labelMedium),
      labelSmall: bitcountGridDoubleInk(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Bitcount Grid Single font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bitcount+Grid+Single
  static TextStyle bitcountGridSingle({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w100,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'd1756ca37a212874b3531ba95decb6ae7a0cda8507325ee8b16ce9419cb2b0cc',
        52908,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '2278b4f129753a401675e8e770b6bb84d7888e915055b34d5ae4c1d92b484a3c',
        52956,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '257629fcc666e6770a9a49c4485d58448d7c3b9c29802dfc5a03c81b5a248a47',
        52932,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'b1ce89b1535493fa9f491942aba00ba7c325b8fd8d07dffba756fc05fb6abf0e',
        52916,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '423ac1789d9eec5558f1cb4c602d0718b8ebd0f61f8c5fc336f295696cdaef86',
        52940,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'be680e66c562a94f7b2a84ed091599ab40ce24d9e4ce849199a1a8f0df81cff5',
        52956,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '1476a127993f4478bc21fb3541173a34d9bb077b9e030e7068b3539846ba7d47',
        52888,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '42e02eea4a1e7910be62805e363ceb5541faab3dad8ed05db1b02781e888e331',
        52964,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '01839e1471deffa7eeda541bfd6662e80698d4b0310d791c09a5c01f79e921db',
        52932,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'BitcountGridSingle',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Bitcount Grid Single font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bitcount+Grid+Single
  static TextTheme bitcountGridSingleTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: bitcountGridSingle(textStyle: textTheme.displayLarge),
      displayMedium: bitcountGridSingle(textStyle: textTheme.displayMedium),
      displaySmall: bitcountGridSingle(textStyle: textTheme.displaySmall),
      headlineLarge: bitcountGridSingle(textStyle: textTheme.headlineLarge),
      headlineMedium: bitcountGridSingle(textStyle: textTheme.headlineMedium),
      headlineSmall: bitcountGridSingle(textStyle: textTheme.headlineSmall),
      titleLarge: bitcountGridSingle(textStyle: textTheme.titleLarge),
      titleMedium: bitcountGridSingle(textStyle: textTheme.titleMedium),
      titleSmall: bitcountGridSingle(textStyle: textTheme.titleSmall),
      bodyLarge: bitcountGridSingle(textStyle: textTheme.bodyLarge),
      bodyMedium: bitcountGridSingle(textStyle: textTheme.bodyMedium),
      bodySmall: bitcountGridSingle(textStyle: textTheme.bodySmall),
      labelLarge: bitcountGridSingle(textStyle: textTheme.labelLarge),
      labelMedium: bitcountGridSingle(textStyle: textTheme.labelMedium),
      labelSmall: bitcountGridSingle(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Bitcount Grid Single Ink font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bitcount+Grid+Single+Ink
  static TextStyle bitcountGridSingleInk({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w100,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'cd4b5e68c7e0ae183c7536b06b3bbaa0aaab232ce8e15e755dd6a74acaaf2f9c',
        71064,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'b3beddbd083abb09f35f9f9bb63aa1d69496ea60d9e0b190ba0bde2a96345eb7',
        71112,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '854ddee2c8c97d5606535652748ac659b97e671d2c9692406152ea2876545bd4',
        71088,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'c399d0fa52939c97b941205e918e52a1e26c9e6fa0b742ce81aab9bfed51114b',
        71072,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '921f4edf95642ee46a453128f2355c4ff1e3d0d8372c22875d654e5add17817a',
        71096,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'e81fe334de4d8ba32c03b484b468fed425eb7f27e8fc5d7d6fba26deeef01bb6',
        71112,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'c92bc9208553489a46743369dbcc4b97baf2314098618414d7359d4d6ac8e0b7',
        71044,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'b42638310a2c5e09fe7745bca868afdc38843ae11a1f21bf979a8177ca74284d',
        71120,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'b4a26662841e440dd144704d1cd77fd4f789ecd0845922e4593d666b57ee8a30',
        71088,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'BitcountGridSingleInk',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Bitcount Grid Single Ink font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bitcount+Grid+Single+Ink
  static TextTheme bitcountGridSingleInkTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: bitcountGridSingleInk(textStyle: textTheme.displayLarge),
      displayMedium: bitcountGridSingleInk(textStyle: textTheme.displayMedium),
      displaySmall: bitcountGridSingleInk(textStyle: textTheme.displaySmall),
      headlineLarge: bitcountGridSingleInk(textStyle: textTheme.headlineLarge),
      headlineMedium: bitcountGridSingleInk(
        textStyle: textTheme.headlineMedium,
      ),
      headlineSmall: bitcountGridSingleInk(textStyle: textTheme.headlineSmall),
      titleLarge: bitcountGridSingleInk(textStyle: textTheme.titleLarge),
      titleMedium: bitcountGridSingleInk(textStyle: textTheme.titleMedium),
      titleSmall: bitcountGridSingleInk(textStyle: textTheme.titleSmall),
      bodyLarge: bitcountGridSingleInk(textStyle: textTheme.bodyLarge),
      bodyMedium: bitcountGridSingleInk(textStyle: textTheme.bodyMedium),
      bodySmall: bitcountGridSingleInk(textStyle: textTheme.bodySmall),
      labelLarge: bitcountGridSingleInk(textStyle: textTheme.labelLarge),
      labelMedium: bitcountGridSingleInk(textStyle: textTheme.labelMedium),
      labelSmall: bitcountGridSingleInk(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Bitcount Ink font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bitcount+Ink
  static TextStyle bitcountInk({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w100,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'f05c38a6eb39a92c08273f67634812da168ba4b7a9803ce20b508e25f0210718',
        85728,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'f178b32521f9a8c15074032be98e1d7ca7a6088a6fd3ba4c895bcd219f49fda9',
        85776,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'ec5e0e5e18ab236e5aa5810da758ed5b02ed94a14e3cd07bfef523721c2e0c29',
        85752,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '55cc23b74189ef10f5414d05c2d3f9f73dc8cd45008dfef11e4ee3a9a6d5ef8f',
        85736,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'a04104b6f21f352f1ac77f54c448ad5708eef3407a13a6ef069b4c1a2d94b600',
        85760,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '72413acaed555629f569926801dde8c2344439630b7048209ff62c3b5091b020',
        85776,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '0cea2b4f936a99fd0fd6e24681c107436277245f6249136bb62be89618f051d4',
        85708,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'de2934dd773e60cd1b188464df338afda4970a8c48001c0c67d80cbe21bbee3d',
        85784,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'be348eaa146c959984be78f63c609b2ff7d78ce00ec8619df56c32ae833fc4af',
        85752,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'BitcountInk',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Bitcount Ink font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bitcount+Ink
  static TextTheme bitcountInkTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: bitcountInk(textStyle: textTheme.displayLarge),
      displayMedium: bitcountInk(textStyle: textTheme.displayMedium),
      displaySmall: bitcountInk(textStyle: textTheme.displaySmall),
      headlineLarge: bitcountInk(textStyle: textTheme.headlineLarge),
      headlineMedium: bitcountInk(textStyle: textTheme.headlineMedium),
      headlineSmall: bitcountInk(textStyle: textTheme.headlineSmall),
      titleLarge: bitcountInk(textStyle: textTheme.titleLarge),
      titleMedium: bitcountInk(textStyle: textTheme.titleMedium),
      titleSmall: bitcountInk(textStyle: textTheme.titleSmall),
      bodyLarge: bitcountInk(textStyle: textTheme.bodyLarge),
      bodyMedium: bitcountInk(textStyle: textTheme.bodyMedium),
      bodySmall: bitcountInk(textStyle: textTheme.bodySmall),
      labelLarge: bitcountInk(textStyle: textTheme.labelLarge),
      labelMedium: bitcountInk(textStyle: textTheme.labelMedium),
      labelSmall: bitcountInk(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Bitcount Prop Double font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bitcount+Prop+Double
  static TextStyle bitcountPropDouble({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w100,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '10bd8715faff5541e8cca0b9a0b1e29623fa3e9cd63cb0f60b8530b7fefaddc9',
        75048,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'f799bc83aa832bb975b6da6648f5b2c796b5e2099db5ade091bec6e261ad3fde',
        75096,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '4b06b9f56889b9bf18fdddc697701ca3f53b514c89deafb9440f879f9d25eb6a',
        75068,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'b7244e96ae63ee79edb3c03a6c5dc45e3b858a9b17304a04b9b754891ebf7d9c',
        75052,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '87038637ab7203866257373ffd550098091b2fb4417e88125f26e7961daffd67',
        75076,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '405d7be72840bbcd8f216ac75bc64615e6c3d4d0ea9c64460be1c7153b1786e7',
        75092,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'b3a41705d7a7271714146d20c1213cdb48c88537ca0984fdf4685a224776fd2d',
        75024,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '4287ae919e4ae60636c5d867719d4a07bf866b32a76b4e22111eecd328947bf5',
        75100,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '18ee8c858c949a1aa6b8b51135a67ccd3200b0cbc114c9a54e51e69b878e84ae',
        75068,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'BitcountPropDouble',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Bitcount Prop Double font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bitcount+Prop+Double
  static TextTheme bitcountPropDoubleTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: bitcountPropDouble(textStyle: textTheme.displayLarge),
      displayMedium: bitcountPropDouble(textStyle: textTheme.displayMedium),
      displaySmall: bitcountPropDouble(textStyle: textTheme.displaySmall),
      headlineLarge: bitcountPropDouble(textStyle: textTheme.headlineLarge),
      headlineMedium: bitcountPropDouble(textStyle: textTheme.headlineMedium),
      headlineSmall: bitcountPropDouble(textStyle: textTheme.headlineSmall),
      titleLarge: bitcountPropDouble(textStyle: textTheme.titleLarge),
      titleMedium: bitcountPropDouble(textStyle: textTheme.titleMedium),
      titleSmall: bitcountPropDouble(textStyle: textTheme.titleSmall),
      bodyLarge: bitcountPropDouble(textStyle: textTheme.bodyLarge),
      bodyMedium: bitcountPropDouble(textStyle: textTheme.bodyMedium),
      bodySmall: bitcountPropDouble(textStyle: textTheme.bodySmall),
      labelLarge: bitcountPropDouble(textStyle: textTheme.labelLarge),
      labelMedium: bitcountPropDouble(textStyle: textTheme.labelMedium),
      labelSmall: bitcountPropDouble(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Bitcount Prop Double Ink font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bitcount+Prop+Double+Ink
  static TextStyle bitcountPropDoubleInk({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w100,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '18649f6d2bb46140f4fe74bf3e9d64f6e34c21d9b43f18f53c1b645caf0700cc',
        96988,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '35d971c3f6f49ad42cc451f4f103bd7b51837e65864ebda56ade6c064cd0cb16',
        97036,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'e84d378a5e8fea3423a8bd4b11bcd4920730a74fb66ab79f8d24f30f83d6560b',
        97008,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'cf069db684a30d0231ca836031580ec06a8bb95a1bcce51786a763dce7507719',
        96992,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'ed8dd9b62e7b900518f4d19ca250a94e8454d23778b05f29f99aac568c833962',
        97016,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'fb2a87926964579748ed2ce45e0ce0b407d25457c94dbc1bfccaa2153c63b7e1',
        97032,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'b3bd1df20a7f5b6d52f51da47696fb0909fa42f27e3f614f97d3ff2b1f145dff',
        96964,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'e40dab45ee2f2d170123922425c71eed22c0f3c77ddfc8344c6379b1d1f41841',
        97040,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'dd919f49893f260633a013127b188a5105c3b45399cd80b649be3b720acf6731',
        97008,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'BitcountPropDoubleInk',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Bitcount Prop Double Ink font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bitcount+Prop+Double+Ink
  static TextTheme bitcountPropDoubleInkTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: bitcountPropDoubleInk(textStyle: textTheme.displayLarge),
      displayMedium: bitcountPropDoubleInk(textStyle: textTheme.displayMedium),
      displaySmall: bitcountPropDoubleInk(textStyle: textTheme.displaySmall),
      headlineLarge: bitcountPropDoubleInk(textStyle: textTheme.headlineLarge),
      headlineMedium: bitcountPropDoubleInk(
        textStyle: textTheme.headlineMedium,
      ),
      headlineSmall: bitcountPropDoubleInk(textStyle: textTheme.headlineSmall),
      titleLarge: bitcountPropDoubleInk(textStyle: textTheme.titleLarge),
      titleMedium: bitcountPropDoubleInk(textStyle: textTheme.titleMedium),
      titleSmall: bitcountPropDoubleInk(textStyle: textTheme.titleSmall),
      bodyLarge: bitcountPropDoubleInk(textStyle: textTheme.bodyLarge),
      bodyMedium: bitcountPropDoubleInk(textStyle: textTheme.bodyMedium),
      bodySmall: bitcountPropDoubleInk(textStyle: textTheme.bodySmall),
      labelLarge: bitcountPropDoubleInk(textStyle: textTheme.labelLarge),
      labelMedium: bitcountPropDoubleInk(textStyle: textTheme.labelMedium),
      labelSmall: bitcountPropDoubleInk(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Bitcount Prop Single font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bitcount+Prop+Single
  static TextStyle bitcountPropSingle({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w100,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '7d17f6f20033e650b69b7a922b54a06214dcefac319638a8c6f4ba5dc7446345',
        70224,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '5dde60d449163ab154c46304db7d356cdac81f066f825c403c3ce3e36edaccb5',
        70272,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '96a2d3341cbacccc379aebe7318023799f3e71f8b5632a5c7cbc59fdb6d08892',
        70248,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '934f37c0c7b16c23bec944d32ad1e37ad8830781cabf52e57f2835a8b446d470',
        70232,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '4be0433aad09dc861b478d7b3546fab075347c3446ada5ccf2eec8355aef1bb2',
        70256,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'c6cf1e1a5f5eb87f5a9c0062b32c13f5cd4e5a0d183b39e811126d27efa5a6ca',
        70272,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '575a2de1fc6218e090e775e2cf16928b6838be204838cf3efb29a6f007d0e5fb',
        70204,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '1d4537100a39e726c8edae3ad84202059a22931f4e49ef0bcca456dd92c416db',
        70280,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '277a12748cf2dc78199a58524184a3dbd3b0cc61ecff8d191193cbc3506b29fd',
        70248,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'BitcountPropSingle',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Bitcount Prop Single font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bitcount+Prop+Single
  static TextTheme bitcountPropSingleTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: bitcountPropSingle(textStyle: textTheme.displayLarge),
      displayMedium: bitcountPropSingle(textStyle: textTheme.displayMedium),
      displaySmall: bitcountPropSingle(textStyle: textTheme.displaySmall),
      headlineLarge: bitcountPropSingle(textStyle: textTheme.headlineLarge),
      headlineMedium: bitcountPropSingle(textStyle: textTheme.headlineMedium),
      headlineSmall: bitcountPropSingle(textStyle: textTheme.headlineSmall),
      titleLarge: bitcountPropSingle(textStyle: textTheme.titleLarge),
      titleMedium: bitcountPropSingle(textStyle: textTheme.titleMedium),
      titleSmall: bitcountPropSingle(textStyle: textTheme.titleSmall),
      bodyLarge: bitcountPropSingle(textStyle: textTheme.bodyLarge),
      bodyMedium: bitcountPropSingle(textStyle: textTheme.bodyMedium),
      bodySmall: bitcountPropSingle(textStyle: textTheme.bodySmall),
      labelLarge: bitcountPropSingle(textStyle: textTheme.labelLarge),
      labelMedium: bitcountPropSingle(textStyle: textTheme.labelMedium),
      labelSmall: bitcountPropSingle(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Bitcount Prop Single Ink font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bitcount+Prop+Single+Ink
  static TextStyle bitcountPropSingleInk({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w100,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '6bcf2a2a0f6b2c5412ae8f75a94ae2afb7fab6b70174b31b09c1227841285914',
        91988,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'edd68ff972cf4c6332912a8033dbe2af82e1202abeb5b855b8ad6ddc25592c89',
        92036,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'e1232460e67cecab28c3a967c2e838cff0082644c9019231b6199cea1125cede',
        92012,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'd25fa90618e7b516a286e5b092ff36c2cba51aa091d6cd47776be86d1a81a9ef',
        91996,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'fcc75831711ca1d5d09463f5709fb94b5fc30dcc2fdf014c4198430c935904e6',
        92020,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'e252a7a0ea5b818877b13e7aba1605330d5ddc1f27df0663a5a135f7d8aa5f7a',
        92036,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '2ee09c1e404de40c4fe400aa794a6ff3a91d2239d1dfd55b3a8e7ce6ed689f25',
        91968,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '7c34c543a1106d577637cb7bf37f14d2a386f509de31c10670280d4e329486f9',
        92044,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '90c716dce5fc9172f4dc656310c9ac98ee30eaae073f669f779b46ac3c8535cf',
        92012,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'BitcountPropSingleInk',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Bitcount Prop Single Ink font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bitcount+Prop+Single+Ink
  static TextTheme bitcountPropSingleInkTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: bitcountPropSingleInk(textStyle: textTheme.displayLarge),
      displayMedium: bitcountPropSingleInk(textStyle: textTheme.displayMedium),
      displaySmall: bitcountPropSingleInk(textStyle: textTheme.displaySmall),
      headlineLarge: bitcountPropSingleInk(textStyle: textTheme.headlineLarge),
      headlineMedium: bitcountPropSingleInk(
        textStyle: textTheme.headlineMedium,
      ),
      headlineSmall: bitcountPropSingleInk(textStyle: textTheme.headlineSmall),
      titleLarge: bitcountPropSingleInk(textStyle: textTheme.titleLarge),
      titleMedium: bitcountPropSingleInk(textStyle: textTheme.titleMedium),
      titleSmall: bitcountPropSingleInk(textStyle: textTheme.titleSmall),
      bodyLarge: bitcountPropSingleInk(textStyle: textTheme.bodyLarge),
      bodyMedium: bitcountPropSingleInk(textStyle: textTheme.bodyMedium),
      bodySmall: bitcountPropSingleInk(textStyle: textTheme.bodySmall),
      labelLarge: bitcountPropSingleInk(textStyle: textTheme.labelLarge),
      labelMedium: bitcountPropSingleInk(textStyle: textTheme.labelMedium),
      labelSmall: bitcountPropSingleInk(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Bitcount Single font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bitcount+Single
  static TextStyle bitcountSingle({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w100,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'e2387ccf1d3bfb0acba800c60b710592214a1088b0627e80fa701a7686266a42',
        55756,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '3cbe483d9e2f2adba607114b4ddcf368e9c69b539983e743afc3832fafb9ef38',
        55804,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'c4b9371ef024257723747c692ff2d6c1df80708dc33ade953b3a35ff96e8adcf',
        55780,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '6994a6daa059a2da8565c1ba3c8fd93ca4bbfa8fdb8966bf9daa0d0ddd3b5bd4',
        55764,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'd9c0cfaf953948a6b25481eeb9052eb25a88149671827faf4c73e3bccec04a31',
        55788,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '1b2cfff57cf528a7e00d139dcd482a80f85d13cb96f204d9a6ad97d77afc45a7',
        55804,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '315265464d669f31a382d0d1ebf75c1f9c9c3a9f3a8ab5861222ffaa3fd3d516',
        55736,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '29ebb04f79de98dc9934a881fd08978f2236dfb4da6c65e98466b2647fd32693',
        55812,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '70b320ad07c6e08a39b807c1504b6cce02f4bbc2e99c10f6040715c9022f12e6',
        55780,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'BitcountSingle',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Bitcount Single font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bitcount+Single
  static TextTheme bitcountSingleTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: bitcountSingle(textStyle: textTheme.displayLarge),
      displayMedium: bitcountSingle(textStyle: textTheme.displayMedium),
      displaySmall: bitcountSingle(textStyle: textTheme.displaySmall),
      headlineLarge: bitcountSingle(textStyle: textTheme.headlineLarge),
      headlineMedium: bitcountSingle(textStyle: textTheme.headlineMedium),
      headlineSmall: bitcountSingle(textStyle: textTheme.headlineSmall),
      titleLarge: bitcountSingle(textStyle: textTheme.titleLarge),
      titleMedium: bitcountSingle(textStyle: textTheme.titleMedium),
      titleSmall: bitcountSingle(textStyle: textTheme.titleSmall),
      bodyLarge: bitcountSingle(textStyle: textTheme.bodyLarge),
      bodyMedium: bitcountSingle(textStyle: textTheme.bodyMedium),
      bodySmall: bitcountSingle(textStyle: textTheme.bodySmall),
      labelLarge: bitcountSingle(textStyle: textTheme.labelLarge),
      labelMedium: bitcountSingle(textStyle: textTheme.labelMedium),
      labelSmall: bitcountSingle(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Bitcount Single Ink font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bitcount+Single+Ink
  static TextStyle bitcountSingleInk({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w100,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'e402596046878eb644fb51846f0055d46e8d791e548dc104f668417784b75fe4',
        75920,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '93a8cb03084e9762979b87c8348aa8d196efad9f24e405ccfb835c52ccac85a3',
        75968,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '18c452b02542f4137b604156aa03e2c041b201bcc10972f674c04137ddbf4a29',
        75944,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'cb0955364b19a42fb5f288ab7e1bcac631729581dc6c23b4009a094cd0094ea3',
        75928,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '66ad3bbf0fb18cc4ff3d953f94cefc89c4368c23b168650c82aa666285be44b5',
        75952,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '7667156c5ecefe3f2d5dd772dd9d21c028a43ddbc78e274415c44b7d20d2dae4',
        75968,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'c21743bf986ee382b297c345f1bf428ad4ab8e02354e308ee7e23c6dadb01b00',
        75900,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '0486f8769ab449f312236576bcde4d2a4e7651c5574f4766ebc42f39f4e962a3',
        75976,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '3e90d6fbb09b1d29c3d64e3c834d53b3599919b358a2b0c3814b789c5d09d29e',
        75944,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'BitcountSingleInk',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Bitcount Single Ink font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bitcount+Single+Ink
  static TextTheme bitcountSingleInkTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: bitcountSingleInk(textStyle: textTheme.displayLarge),
      displayMedium: bitcountSingleInk(textStyle: textTheme.displayMedium),
      displaySmall: bitcountSingleInk(textStyle: textTheme.displaySmall),
      headlineLarge: bitcountSingleInk(textStyle: textTheme.headlineLarge),
      headlineMedium: bitcountSingleInk(textStyle: textTheme.headlineMedium),
      headlineSmall: bitcountSingleInk(textStyle: textTheme.headlineSmall),
      titleLarge: bitcountSingleInk(textStyle: textTheme.titleLarge),
      titleMedium: bitcountSingleInk(textStyle: textTheme.titleMedium),
      titleSmall: bitcountSingleInk(textStyle: textTheme.titleSmall),
      bodyLarge: bitcountSingleInk(textStyle: textTheme.bodyLarge),
      bodyMedium: bitcountSingleInk(textStyle: textTheme.bodyMedium),
      bodySmall: bitcountSingleInk(textStyle: textTheme.bodySmall),
      labelLarge: bitcountSingleInk(textStyle: textTheme.labelLarge),
      labelMedium: bitcountSingleInk(textStyle: textTheme.labelMedium),
      labelSmall: bitcountSingleInk(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Bitter font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bitter
  static TextStyle bitter({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w100,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'a6f494327c4b328b5830321fac364451cf4749a419f0ca9ad71a0577c057e150',
        147940,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '923ea8cfbebe11e162c5ddbb4071438eb06c3ce42194a55cfadcf7f5a8850b9b',
        149236,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '0a111b50bb5d05de9fa67f25962711cacdb0c7e8faa2af4558e60649a69d5d5c',
        149296,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'cd1b5ca759a96f4062ac3e72b6b744d89ea79cb2ca70d936ca0428803562b525',
        149308,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '7d9091c83ad94308f3b7b3ea497463a776b3ae24431c31c4bc1f7ac70942385a',
        149532,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '93cb556894ee5f6f1a78de555c9e0bda4c7a49e394b721a7337bf0f4a51d6525',
        149504,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '1d53478099039fbece3448d12fd06185d4c5732acbf6e802887304437a292d38',
        150576,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '93a6711ed0bd66a1b61609c694d00fd64ef83344c5ad27ce7b2cd4a6447c956b',
        158568,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'a8f9dcd0db96f490e822d9c57b0cd1f1dc7bf8ab995099f4e19a190bd02209b7',
        158264,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w100,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '7c5c798de9644679db8b996c5b86b40d034f713056c7d147ee0fe68d938b2e6d',
        147524,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '62c0592356e47440b0d42426eeb590ae2eeccd4e4fd8ed4bcace6a64075b9cf7',
        148348,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '7e66c1544eebaacfbc7af1c710eb06c1b2384e8859e8b4ef9d0c03bc7a241ab5',
        148372,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '2a4d973d6b08b655a8972facf6af426e94a59fdd67830275b9a30c5bcf29ec0a',
        148284,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '74e47b93ff9f20886ee6b995b003f14bfbfd5bd8788478e478f9726c9435a257',
        148416,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'dbfb3eb28fe8e9e1d40bd09982e13b526d3fb2e6d9bd84d612e2cb2bb3d2a543',
        148308,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'ca365bf6bf63201ec2e1e3d5d2ff599f8884bb35581f245497de54d39d47c399',
        149128,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'c07cb48d2f9e058f274c62f14b81f8d941d8d1076b34e9a0c2f1644109b95679',
        150976,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'c785285b39edccdce0ce2c5cc3dd0bc2717542eeea67499577a6fe0c1a412eb5',
        150824,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Bitter',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Bitter font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bitter
  static TextTheme bitterTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: bitter(textStyle: textTheme.displayLarge),
      displayMedium: bitter(textStyle: textTheme.displayMedium),
      displaySmall: bitter(textStyle: textTheme.displaySmall),
      headlineLarge: bitter(textStyle: textTheme.headlineLarge),
      headlineMedium: bitter(textStyle: textTheme.headlineMedium),
      headlineSmall: bitter(textStyle: textTheme.headlineSmall),
      titleLarge: bitter(textStyle: textTheme.titleLarge),
      titleMedium: bitter(textStyle: textTheme.titleMedium),
      titleSmall: bitter(textStyle: textTheme.titleSmall),
      bodyLarge: bitter(textStyle: textTheme.bodyLarge),
      bodyMedium: bitter(textStyle: textTheme.bodyMedium),
      bodySmall: bitter(textStyle: textTheme.bodySmall),
      labelLarge: bitter(textStyle: textTheme.labelLarge),
      labelMedium: bitter(textStyle: textTheme.labelMedium),
      labelSmall: bitter(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Black And White Picture font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Black+And+White+Picture
  static TextStyle blackAndWhitePicture({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '41b804166231efabea2d0dcc480c6a23353fb0dd79ca3139f66667ef061ba8b2',
        9586668,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'BlackAndWhitePicture',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Black And White Picture font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Black+And+White+Picture
  static TextTheme blackAndWhitePictureTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: blackAndWhitePicture(textStyle: textTheme.displayLarge),
      displayMedium: blackAndWhitePicture(textStyle: textTheme.displayMedium),
      displaySmall: blackAndWhitePicture(textStyle: textTheme.displaySmall),
      headlineLarge: blackAndWhitePicture(textStyle: textTheme.headlineLarge),
      headlineMedium: blackAndWhitePicture(textStyle: textTheme.headlineMedium),
      headlineSmall: blackAndWhitePicture(textStyle: textTheme.headlineSmall),
      titleLarge: blackAndWhitePicture(textStyle: textTheme.titleLarge),
      titleMedium: blackAndWhitePicture(textStyle: textTheme.titleMedium),
      titleSmall: blackAndWhitePicture(textStyle: textTheme.titleSmall),
      bodyLarge: blackAndWhitePicture(textStyle: textTheme.bodyLarge),
      bodyMedium: blackAndWhitePicture(textStyle: textTheme.bodyMedium),
      bodySmall: blackAndWhitePicture(textStyle: textTheme.bodySmall),
      labelLarge: blackAndWhitePicture(textStyle: textTheme.labelLarge),
      labelMedium: blackAndWhitePicture(textStyle: textTheme.labelMedium),
      labelSmall: blackAndWhitePicture(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Black Han Sans font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Black+Han+Sans
  static TextStyle blackHanSans({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '332eb07f319be667e16ce0392c7b8ac22c5642c3d479018080e91056efe4a225',
        383248,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'BlackHanSans',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Black Han Sans font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Black+Han+Sans
  static TextTheme blackHanSansTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: blackHanSans(textStyle: textTheme.displayLarge),
      displayMedium: blackHanSans(textStyle: textTheme.displayMedium),
      displaySmall: blackHanSans(textStyle: textTheme.displaySmall),
      headlineLarge: blackHanSans(textStyle: textTheme.headlineLarge),
      headlineMedium: blackHanSans(textStyle: textTheme.headlineMedium),
      headlineSmall: blackHanSans(textStyle: textTheme.headlineSmall),
      titleLarge: blackHanSans(textStyle: textTheme.titleLarge),
      titleMedium: blackHanSans(textStyle: textTheme.titleMedium),
      titleSmall: blackHanSans(textStyle: textTheme.titleSmall),
      bodyLarge: blackHanSans(textStyle: textTheme.bodyLarge),
      bodyMedium: blackHanSans(textStyle: textTheme.bodyMedium),
      bodySmall: blackHanSans(textStyle: textTheme.bodySmall),
      labelLarge: blackHanSans(textStyle: textTheme.labelLarge),
      labelMedium: blackHanSans(textStyle: textTheme.labelMedium),
      labelSmall: blackHanSans(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Black Ops One font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Black+Ops+One
  static TextStyle blackOpsOne({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '952681e808adde22e6c5a8b4c377f5809c752ad9fbe2044c2f7af189b7039049',
        131284,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'BlackOpsOne',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Black Ops One font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Black+Ops+One
  static TextTheme blackOpsOneTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: blackOpsOne(textStyle: textTheme.displayLarge),
      displayMedium: blackOpsOne(textStyle: textTheme.displayMedium),
      displaySmall: blackOpsOne(textStyle: textTheme.displaySmall),
      headlineLarge: blackOpsOne(textStyle: textTheme.headlineLarge),
      headlineMedium: blackOpsOne(textStyle: textTheme.headlineMedium),
      headlineSmall: blackOpsOne(textStyle: textTheme.headlineSmall),
      titleLarge: blackOpsOne(textStyle: textTheme.titleLarge),
      titleMedium: blackOpsOne(textStyle: textTheme.titleMedium),
      titleSmall: blackOpsOne(textStyle: textTheme.titleSmall),
      bodyLarge: blackOpsOne(textStyle: textTheme.bodyLarge),
      bodyMedium: blackOpsOne(textStyle: textTheme.bodyMedium),
      bodySmall: blackOpsOne(textStyle: textTheme.bodySmall),
      labelLarge: blackOpsOne(textStyle: textTheme.labelLarge),
      labelMedium: blackOpsOne(textStyle: textTheme.labelMedium),
      labelSmall: blackOpsOne(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Blaka font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Blaka
  static TextStyle blaka({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'f28d1a11ea10817530a561a9229ac33f356b1cf7da3d9a54e3bbc39ed500f183',
        41400,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Blaka',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Blaka font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Blaka
  static TextTheme blakaTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: blaka(textStyle: textTheme.displayLarge),
      displayMedium: blaka(textStyle: textTheme.displayMedium),
      displaySmall: blaka(textStyle: textTheme.displaySmall),
      headlineLarge: blaka(textStyle: textTheme.headlineLarge),
      headlineMedium: blaka(textStyle: textTheme.headlineMedium),
      headlineSmall: blaka(textStyle: textTheme.headlineSmall),
      titleLarge: blaka(textStyle: textTheme.titleLarge),
      titleMedium: blaka(textStyle: textTheme.titleMedium),
      titleSmall: blaka(textStyle: textTheme.titleSmall),
      bodyLarge: blaka(textStyle: textTheme.bodyLarge),
      bodyMedium: blaka(textStyle: textTheme.bodyMedium),
      bodySmall: blaka(textStyle: textTheme.bodySmall),
      labelLarge: blaka(textStyle: textTheme.labelLarge),
      labelMedium: blaka(textStyle: textTheme.labelMedium),
      labelSmall: blaka(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Blaka Hollow font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Blaka+Hollow
  static TextStyle blakaHollow({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'f1d434c1629f1df5e0f0fd701d0e7d0715f453372467aa4b4ab4ec8ba6cad6e0',
        52952,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'BlakaHollow',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Blaka Hollow font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Blaka+Hollow
  static TextTheme blakaHollowTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: blakaHollow(textStyle: textTheme.displayLarge),
      displayMedium: blakaHollow(textStyle: textTheme.displayMedium),
      displaySmall: blakaHollow(textStyle: textTheme.displaySmall),
      headlineLarge: blakaHollow(textStyle: textTheme.headlineLarge),
      headlineMedium: blakaHollow(textStyle: textTheme.headlineMedium),
      headlineSmall: blakaHollow(textStyle: textTheme.headlineSmall),
      titleLarge: blakaHollow(textStyle: textTheme.titleLarge),
      titleMedium: blakaHollow(textStyle: textTheme.titleMedium),
      titleSmall: blakaHollow(textStyle: textTheme.titleSmall),
      bodyLarge: blakaHollow(textStyle: textTheme.bodyLarge),
      bodyMedium: blakaHollow(textStyle: textTheme.bodyMedium),
      bodySmall: blakaHollow(textStyle: textTheme.bodySmall),
      labelLarge: blakaHollow(textStyle: textTheme.labelLarge),
      labelMedium: blakaHollow(textStyle: textTheme.labelMedium),
      labelSmall: blakaHollow(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Blaka Ink font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Blaka+Ink
  static TextStyle blakaInk({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '016cb09c484ccb4a6d579e821b330bdf8aa85e11270f4d919c270a147ecd6a52',
        367116,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'BlakaInk',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Blaka Ink font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Blaka+Ink
  static TextTheme blakaInkTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: blakaInk(textStyle: textTheme.displayLarge),
      displayMedium: blakaInk(textStyle: textTheme.displayMedium),
      displaySmall: blakaInk(textStyle: textTheme.displaySmall),
      headlineLarge: blakaInk(textStyle: textTheme.headlineLarge),
      headlineMedium: blakaInk(textStyle: textTheme.headlineMedium),
      headlineSmall: blakaInk(textStyle: textTheme.headlineSmall),
      titleLarge: blakaInk(textStyle: textTheme.titleLarge),
      titleMedium: blakaInk(textStyle: textTheme.titleMedium),
      titleSmall: blakaInk(textStyle: textTheme.titleSmall),
      bodyLarge: blakaInk(textStyle: textTheme.bodyLarge),
      bodyMedium: blakaInk(textStyle: textTheme.bodyMedium),
      bodySmall: blakaInk(textStyle: textTheme.bodySmall),
      labelLarge: blakaInk(textStyle: textTheme.labelLarge),
      labelMedium: blakaInk(textStyle: textTheme.labelMedium),
      labelSmall: blakaInk(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Blinker font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Blinker
  static TextStyle blinker({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w100,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '70cda2a3be45ad2cfc4fce3f02c9fb49fa6036674fa911da5edfd2e6ab9194ed',
        48360,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '68395b402c7e5dd97bef235fa3ebb781798b885a607f82097ffc21d9998a4dbc',
        49784,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'f1ddd07308d2eafa097914827e5e560c1008d54786afe03c98baaf1a03d7a0e4',
        49632,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'aba089cb0cf5b2715ebc8977e04464b6e018fbde24957fc76585b33a2e50d88b',
        48848,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '0eaca7103ebcbbb79acfd6b4d43e9f41766441925e2e196b1d7306b79c3c4a31',
        54592,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '16effec8257a788af0494d72d1561370e8b71a38d30f84c93937a63a8b2c93da',
        50068,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'e6aa48a1fc6ffffc66a2202248381c493cd9db369b885fd9bcded75829a399d2',
        54240,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '675e3bf1d97194fb60db3bac63f0ff1661cb47a59bb7e976cd8d11f142258d7f',
        53496,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Blinker',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Blinker font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Blinker
  static TextTheme blinkerTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: blinker(textStyle: textTheme.displayLarge),
      displayMedium: blinker(textStyle: textTheme.displayMedium),
      displaySmall: blinker(textStyle: textTheme.displaySmall),
      headlineLarge: blinker(textStyle: textTheme.headlineLarge),
      headlineMedium: blinker(textStyle: textTheme.headlineMedium),
      headlineSmall: blinker(textStyle: textTheme.headlineSmall),
      titleLarge: blinker(textStyle: textTheme.titleLarge),
      titleMedium: blinker(textStyle: textTheme.titleMedium),
      titleSmall: blinker(textStyle: textTheme.titleSmall),
      bodyLarge: blinker(textStyle: textTheme.bodyLarge),
      bodyMedium: blinker(textStyle: textTheme.bodyMedium),
      bodySmall: blinker(textStyle: textTheme.bodySmall),
      labelLarge: blinker(textStyle: textTheme.labelLarge),
      labelMedium: blinker(textStyle: textTheme.labelMedium),
      labelSmall: blinker(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Bodoni Moda font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bodoni+Moda
  static TextStyle bodoniModa({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '87dbbc7d3aea0f0d48c8b75305090f70eef6bc94eb7f2b4d04b239a632b9b03b',
        44728,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'f0bfd5985d44696ec13603d597a87c02918b2bd144711a7ad699aeb15c5b4142',
        44820,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'dee928336743a31541b309858f36979d168085cf7a4fc691d66bca423983698d',
        44856,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '2f718b560e3d906e9c4e1729f73d1f397df2c4a4998cc15ddc3d6366b559f0f0',
        44820,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'dad09be51cc7d0a70b4aac57b6e3a5131e58d7a25ade3b322a0699366d9b8b18',
        44904,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '3637bd6c369adee131390bc08d9e6df6371260f61f0a4caffae27b80be367a81',
        44856,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '0cf24a30d033cf11dcb07beb269dafc8c195cc899fd2d44245b5033ae7d30309',
        47532,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '1ba113ae30962c4a017618e86124f713eb56402275861fd03f2fa7379e3b4a4a',
        47684,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'b473d8f1c61d8341631d03c48173821de16c1084f9664c5e15406d3090c79f4c',
        47760,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'c4d86a2eed93eac901f592e93eaf4000dc22021356e6f27c8577a2f347c29142',
        47700,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'ed6d6f232aa631c7b1e7997fda824398d0a998c5e3e34d01cedceac76f076b65',
        47848,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '34725af43e2782087b5833e45a3f0f559aade9e38773bff4559aee3b477b19c1',
        47812,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'BodoniModa',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Bodoni Moda font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bodoni+Moda
  static TextTheme bodoniModaTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: bodoniModa(textStyle: textTheme.displayLarge),
      displayMedium: bodoniModa(textStyle: textTheme.displayMedium),
      displaySmall: bodoniModa(textStyle: textTheme.displaySmall),
      headlineLarge: bodoniModa(textStyle: textTheme.headlineLarge),
      headlineMedium: bodoniModa(textStyle: textTheme.headlineMedium),
      headlineSmall: bodoniModa(textStyle: textTheme.headlineSmall),
      titleLarge: bodoniModa(textStyle: textTheme.titleLarge),
      titleMedium: bodoniModa(textStyle: textTheme.titleMedium),
      titleSmall: bodoniModa(textStyle: textTheme.titleSmall),
      bodyLarge: bodoniModa(textStyle: textTheme.bodyLarge),
      bodyMedium: bodoniModa(textStyle: textTheme.bodyMedium),
      bodySmall: bodoniModa(textStyle: textTheme.bodySmall),
      labelLarge: bodoniModa(textStyle: textTheme.labelLarge),
      labelMedium: bodoniModa(textStyle: textTheme.labelMedium),
      labelSmall: bodoniModa(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Bodoni Moda SC font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bodoni+Moda+SC
  static TextStyle bodoniModaSc({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '4a8874163f42b8ac24467bf21daf54966d02f70fc570f026d4dac6fce95a70d8',
        52328,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'cd65d3aa9b596f22eceb118c5e34c78a8ebe42be00b2e3930be4b841502af256',
        52432,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'a278c6a13c9aa5ec502c30cfe86a4b7efd0bf02e68a15ab50fe47965210e0f35',
        52496,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '9e014465f19a0d76923a4a5bda825912005d82c30c29d12072be32b3f3dfe52d',
        52476,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '67bbd2811b21ab45f2b014d6f89cf41695e137c99eb37d29570c5b99092a4b13',
        52572,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '30d0acd22d905ac7f2b714921304d5958598a6a20b1036d88cbecdad2dfadb87',
        52520,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '704389a198c3b976feb1971cf3ce7ae3aa8fc98dbed3bfde45a137ce73e8c60d',
        55704,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'ebd645f6020e23e0ae70ea041b0dc20433db948a377ee4bb83f1000a2b04161f',
        55856,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '9e263acfccccaa522cc770ba9b7c2b426284666958a6fdebe3a9f5056e530d97',
        55968,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '61ec9aa7ad224b28ea4ad5d494b9aadf71fd7b1536c07908283041a31cdc99b6',
        55908,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'f89e420a25f441b4174fbbfd3d152e1b5bde6328e1219dcd6d74398c8722b6a3',
        56028,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'a5f64145693eaf4de88cd1c4f75f9067f7763bf436872cf374ffe3f587e45dad',
        56024,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'BodoniModaSC',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Bodoni Moda SC font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bodoni+Moda+SC
  static TextTheme bodoniModaScTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: bodoniModaSc(textStyle: textTheme.displayLarge),
      displayMedium: bodoniModaSc(textStyle: textTheme.displayMedium),
      displaySmall: bodoniModaSc(textStyle: textTheme.displaySmall),
      headlineLarge: bodoniModaSc(textStyle: textTheme.headlineLarge),
      headlineMedium: bodoniModaSc(textStyle: textTheme.headlineMedium),
      headlineSmall: bodoniModaSc(textStyle: textTheme.headlineSmall),
      titleLarge: bodoniModaSc(textStyle: textTheme.titleLarge),
      titleMedium: bodoniModaSc(textStyle: textTheme.titleMedium),
      titleSmall: bodoniModaSc(textStyle: textTheme.titleSmall),
      bodyLarge: bodoniModaSc(textStyle: textTheme.bodyLarge),
      bodyMedium: bodoniModaSc(textStyle: textTheme.bodyMedium),
      bodySmall: bodoniModaSc(textStyle: textTheme.bodySmall),
      labelLarge: bodoniModaSc(textStyle: textTheme.labelLarge),
      labelMedium: bodoniModaSc(textStyle: textTheme.labelMedium),
      labelSmall: bodoniModaSc(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Bokor font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bokor
  static TextStyle bokor({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '2cad8288faa197d80322663e114f9785a05af6b5bdd69d0e6c8815e8b42e1a26',
        75416,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Bokor',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Bokor font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bokor
  static TextTheme bokorTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: bokor(textStyle: textTheme.displayLarge),
      displayMedium: bokor(textStyle: textTheme.displayMedium),
      displaySmall: bokor(textStyle: textTheme.displaySmall),
      headlineLarge: bokor(textStyle: textTheme.headlineLarge),
      headlineMedium: bokor(textStyle: textTheme.headlineMedium),
      headlineSmall: bokor(textStyle: textTheme.headlineSmall),
      titleLarge: bokor(textStyle: textTheme.titleLarge),
      titleMedium: bokor(textStyle: textTheme.titleMedium),
      titleSmall: bokor(textStyle: textTheme.titleSmall),
      bodyLarge: bokor(textStyle: textTheme.bodyLarge),
      bodyMedium: bokor(textStyle: textTheme.bodyMedium),
      bodySmall: bokor(textStyle: textTheme.bodySmall),
      labelLarge: bokor(textStyle: textTheme.labelLarge),
      labelMedium: bokor(textStyle: textTheme.labelMedium),
      labelSmall: bokor(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Boldonse font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Boldonse
  static TextStyle boldonse({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'd0004d95fcbe347ac2a98658bfc82ca18f242ca193bca4c7669df11bfe1c3558',
        55864,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Boldonse',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Boldonse font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Boldonse
  static TextTheme boldonseTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: boldonse(textStyle: textTheme.displayLarge),
      displayMedium: boldonse(textStyle: textTheme.displayMedium),
      displaySmall: boldonse(textStyle: textTheme.displaySmall),
      headlineLarge: boldonse(textStyle: textTheme.headlineLarge),
      headlineMedium: boldonse(textStyle: textTheme.headlineMedium),
      headlineSmall: boldonse(textStyle: textTheme.headlineSmall),
      titleLarge: boldonse(textStyle: textTheme.titleLarge),
      titleMedium: boldonse(textStyle: textTheme.titleMedium),
      titleSmall: boldonse(textStyle: textTheme.titleSmall),
      bodyLarge: boldonse(textStyle: textTheme.bodyLarge),
      bodyMedium: boldonse(textStyle: textTheme.bodyMedium),
      bodySmall: boldonse(textStyle: textTheme.bodySmall),
      labelLarge: boldonse(textStyle: textTheme.labelLarge),
      labelMedium: boldonse(textStyle: textTheme.labelMedium),
      labelSmall: boldonse(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Bona Nova font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bona+Nova
  static TextStyle bonaNova({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'bc7be5f3fc2c743a930ce1c29ef555c35a7eff13fc32d23f5e2cad7b920cc651',
        198216,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '182831d7ae506ac276704d5a83df2c035915e3cb003973dc3d2ae24753c48cd9',
        215924,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'aebc8a21907deed34ae4623197d9c48e236bb8c7759766a076af20410785ac59',
        196324,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'BonaNova',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Bona Nova font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bona+Nova
  static TextTheme bonaNovaTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: bonaNova(textStyle: textTheme.displayLarge),
      displayMedium: bonaNova(textStyle: textTheme.displayMedium),
      displaySmall: bonaNova(textStyle: textTheme.displaySmall),
      headlineLarge: bonaNova(textStyle: textTheme.headlineLarge),
      headlineMedium: bonaNova(textStyle: textTheme.headlineMedium),
      headlineSmall: bonaNova(textStyle: textTheme.headlineSmall),
      titleLarge: bonaNova(textStyle: textTheme.titleLarge),
      titleMedium: bonaNova(textStyle: textTheme.titleMedium),
      titleSmall: bonaNova(textStyle: textTheme.titleSmall),
      bodyLarge: bonaNova(textStyle: textTheme.bodyLarge),
      bodyMedium: bonaNova(textStyle: textTheme.bodyMedium),
      bodySmall: bonaNova(textStyle: textTheme.bodySmall),
      labelLarge: bonaNova(textStyle: textTheme.labelLarge),
      labelMedium: bonaNova(textStyle: textTheme.labelMedium),
      labelSmall: bonaNova(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Bona Nova SC font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bona+Nova+SC
  static TextStyle bonaNovaSc({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '737e6876332ec78b45985104a38b73928a38c3db5586719310d3d01ca6df4b61',
        238580,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '05e6965dbf9b3fed96f5d3f1c921588867a97b97e88f3c4c7ead4382a4372190',
        253184,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'df10eb2e3751cdc600c97cad5d087f6557006dfd08f69721b443f7b6a4b1ba23',
        235580,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'BonaNovaSC',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Bona Nova SC font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bona+Nova+SC
  static TextTheme bonaNovaScTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: bonaNovaSc(textStyle: textTheme.displayLarge),
      displayMedium: bonaNovaSc(textStyle: textTheme.displayMedium),
      displaySmall: bonaNovaSc(textStyle: textTheme.displaySmall),
      headlineLarge: bonaNovaSc(textStyle: textTheme.headlineLarge),
      headlineMedium: bonaNovaSc(textStyle: textTheme.headlineMedium),
      headlineSmall: bonaNovaSc(textStyle: textTheme.headlineSmall),
      titleLarge: bonaNovaSc(textStyle: textTheme.titleLarge),
      titleMedium: bonaNovaSc(textStyle: textTheme.titleMedium),
      titleSmall: bonaNovaSc(textStyle: textTheme.titleSmall),
      bodyLarge: bonaNovaSc(textStyle: textTheme.bodyLarge),
      bodyMedium: bonaNovaSc(textStyle: textTheme.bodyMedium),
      bodySmall: bonaNovaSc(textStyle: textTheme.bodySmall),
      labelLarge: bonaNovaSc(textStyle: textTheme.labelLarge),
      labelMedium: bonaNovaSc(textStyle: textTheme.labelMedium),
      labelSmall: bonaNovaSc(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Bonbon font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bonbon
  static TextStyle bonbon({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '1540a43fadea3f6ed9f2596f39c8ff93cb06629a9b9b1c32836ddd258f048700',
        33780,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Bonbon',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Bonbon font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bonbon
  static TextTheme bonbonTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: bonbon(textStyle: textTheme.displayLarge),
      displayMedium: bonbon(textStyle: textTheme.displayMedium),
      displaySmall: bonbon(textStyle: textTheme.displaySmall),
      headlineLarge: bonbon(textStyle: textTheme.headlineLarge),
      headlineMedium: bonbon(textStyle: textTheme.headlineMedium),
      headlineSmall: bonbon(textStyle: textTheme.headlineSmall),
      titleLarge: bonbon(textStyle: textTheme.titleLarge),
      titleMedium: bonbon(textStyle: textTheme.titleMedium),
      titleSmall: bonbon(textStyle: textTheme.titleSmall),
      bodyLarge: bonbon(textStyle: textTheme.bodyLarge),
      bodyMedium: bonbon(textStyle: textTheme.bodyMedium),
      bodySmall: bonbon(textStyle: textTheme.bodySmall),
      labelLarge: bonbon(textStyle: textTheme.labelLarge),
      labelMedium: bonbon(textStyle: textTheme.labelMedium),
      labelSmall: bonbon(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Bonheur Royale font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bonheur+Royale
  static TextStyle bonheurRoyale({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '57d243ec59f08aad89be6a121db38923783c5dfd10e25f23d00d14e454d8c4b9',
        87260,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'BonheurRoyale',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Bonheur Royale font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bonheur+Royale
  static TextTheme bonheurRoyaleTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: bonheurRoyale(textStyle: textTheme.displayLarge),
      displayMedium: bonheurRoyale(textStyle: textTheme.displayMedium),
      displaySmall: bonheurRoyale(textStyle: textTheme.displaySmall),
      headlineLarge: bonheurRoyale(textStyle: textTheme.headlineLarge),
      headlineMedium: bonheurRoyale(textStyle: textTheme.headlineMedium),
      headlineSmall: bonheurRoyale(textStyle: textTheme.headlineSmall),
      titleLarge: bonheurRoyale(textStyle: textTheme.titleLarge),
      titleMedium: bonheurRoyale(textStyle: textTheme.titleMedium),
      titleSmall: bonheurRoyale(textStyle: textTheme.titleSmall),
      bodyLarge: bonheurRoyale(textStyle: textTheme.bodyLarge),
      bodyMedium: bonheurRoyale(textStyle: textTheme.bodyMedium),
      bodySmall: bonheurRoyale(textStyle: textTheme.bodySmall),
      labelLarge: bonheurRoyale(textStyle: textTheme.labelLarge),
      labelMedium: bonheurRoyale(textStyle: textTheme.labelMedium),
      labelSmall: bonheurRoyale(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Boogaloo font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Boogaloo
  static TextStyle boogaloo({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '5e1b36d62ddaa798bc5c40fe7df6d951e6ca0026aef7208c4461bc057f0fbd61',
        31224,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Boogaloo',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Boogaloo font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Boogaloo
  static TextTheme boogalooTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: boogaloo(textStyle: textTheme.displayLarge),
      displayMedium: boogaloo(textStyle: textTheme.displayMedium),
      displaySmall: boogaloo(textStyle: textTheme.displaySmall),
      headlineLarge: boogaloo(textStyle: textTheme.headlineLarge),
      headlineMedium: boogaloo(textStyle: textTheme.headlineMedium),
      headlineSmall: boogaloo(textStyle: textTheme.headlineSmall),
      titleLarge: boogaloo(textStyle: textTheme.titleLarge),
      titleMedium: boogaloo(textStyle: textTheme.titleMedium),
      titleSmall: boogaloo(textStyle: textTheme.titleSmall),
      bodyLarge: boogaloo(textStyle: textTheme.bodyLarge),
      bodyMedium: boogaloo(textStyle: textTheme.bodyMedium),
      bodySmall: boogaloo(textStyle: textTheme.bodySmall),
      labelLarge: boogaloo(textStyle: textTheme.labelLarge),
      labelMedium: boogaloo(textStyle: textTheme.labelMedium),
      labelSmall: boogaloo(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Borel font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Borel
  static TextStyle borel({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '783316b33c744e63516c15b94e9f31dba7bb17f181a8cb31c173c021cf367cf7',
        143872,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Borel',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Borel font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Borel
  static TextTheme borelTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: borel(textStyle: textTheme.displayLarge),
      displayMedium: borel(textStyle: textTheme.displayMedium),
      displaySmall: borel(textStyle: textTheme.displaySmall),
      headlineLarge: borel(textStyle: textTheme.headlineLarge),
      headlineMedium: borel(textStyle: textTheme.headlineMedium),
      headlineSmall: borel(textStyle: textTheme.headlineSmall),
      titleLarge: borel(textStyle: textTheme.titleLarge),
      titleMedium: borel(textStyle: textTheme.titleMedium),
      titleSmall: borel(textStyle: textTheme.titleSmall),
      bodyLarge: borel(textStyle: textTheme.bodyLarge),
      bodyMedium: borel(textStyle: textTheme.bodyMedium),
      bodySmall: borel(textStyle: textTheme.bodySmall),
      labelLarge: borel(textStyle: textTheme.labelLarge),
      labelMedium: borel(textStyle: textTheme.labelMedium),
      labelSmall: borel(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Bowlby One font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bowlby+One
  static TextStyle bowlbyOne({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '295679a1645b41e496426642f74f4e964ed1ca4ecba18d17e2c06fd48a855502',
        58036,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'BowlbyOne',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Bowlby One font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bowlby+One
  static TextTheme bowlbyOneTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: bowlbyOne(textStyle: textTheme.displayLarge),
      displayMedium: bowlbyOne(textStyle: textTheme.displayMedium),
      displaySmall: bowlbyOne(textStyle: textTheme.displaySmall),
      headlineLarge: bowlbyOne(textStyle: textTheme.headlineLarge),
      headlineMedium: bowlbyOne(textStyle: textTheme.headlineMedium),
      headlineSmall: bowlbyOne(textStyle: textTheme.headlineSmall),
      titleLarge: bowlbyOne(textStyle: textTheme.titleLarge),
      titleMedium: bowlbyOne(textStyle: textTheme.titleMedium),
      titleSmall: bowlbyOne(textStyle: textTheme.titleSmall),
      bodyLarge: bowlbyOne(textStyle: textTheme.bodyLarge),
      bodyMedium: bowlbyOne(textStyle: textTheme.bodyMedium),
      bodySmall: bowlbyOne(textStyle: textTheme.bodySmall),
      labelLarge: bowlbyOne(textStyle: textTheme.labelLarge),
      labelMedium: bowlbyOne(textStyle: textTheme.labelMedium),
      labelSmall: bowlbyOne(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Bowlby One SC font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bowlby+One+SC
  static TextStyle bowlbyOneSc({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '7de8e3ab5995e51e27e2e02b0564c3ed2c6ef22dcc08b03e76a63233b1c3e5d5',
        42524,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'BowlbyOneSC',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Bowlby One SC font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bowlby+One+SC
  static TextTheme bowlbyOneScTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: bowlbyOneSc(textStyle: textTheme.displayLarge),
      displayMedium: bowlbyOneSc(textStyle: textTheme.displayMedium),
      displaySmall: bowlbyOneSc(textStyle: textTheme.displaySmall),
      headlineLarge: bowlbyOneSc(textStyle: textTheme.headlineLarge),
      headlineMedium: bowlbyOneSc(textStyle: textTheme.headlineMedium),
      headlineSmall: bowlbyOneSc(textStyle: textTheme.headlineSmall),
      titleLarge: bowlbyOneSc(textStyle: textTheme.titleLarge),
      titleMedium: bowlbyOneSc(textStyle: textTheme.titleMedium),
      titleSmall: bowlbyOneSc(textStyle: textTheme.titleSmall),
      bodyLarge: bowlbyOneSc(textStyle: textTheme.bodyLarge),
      bodyMedium: bowlbyOneSc(textStyle: textTheme.bodyMedium),
      bodySmall: bowlbyOneSc(textStyle: textTheme.bodySmall),
      labelLarge: bowlbyOneSc(textStyle: textTheme.labelLarge),
      labelMedium: bowlbyOneSc(textStyle: textTheme.labelMedium),
      labelSmall: bowlbyOneSc(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Braah One font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Braah+One
  static TextStyle braahOne({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '63eddbd1328bb905c3480ec5de0b959a1b04ec2e53ff9c09a80501a395ea9d90',
        78528,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'BraahOne',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Braah One font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Braah+One
  static TextTheme braahOneTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: braahOne(textStyle: textTheme.displayLarge),
      displayMedium: braahOne(textStyle: textTheme.displayMedium),
      displaySmall: braahOne(textStyle: textTheme.displaySmall),
      headlineLarge: braahOne(textStyle: textTheme.headlineLarge),
      headlineMedium: braahOne(textStyle: textTheme.headlineMedium),
      headlineSmall: braahOne(textStyle: textTheme.headlineSmall),
      titleLarge: braahOne(textStyle: textTheme.titleLarge),
      titleMedium: braahOne(textStyle: textTheme.titleMedium),
      titleSmall: braahOne(textStyle: textTheme.titleSmall),
      bodyLarge: braahOne(textStyle: textTheme.bodyLarge),
      bodyMedium: braahOne(textStyle: textTheme.bodyMedium),
      bodySmall: braahOne(textStyle: textTheme.bodySmall),
      labelLarge: braahOne(textStyle: textTheme.labelLarge),
      labelMedium: braahOne(textStyle: textTheme.labelMedium),
      labelSmall: braahOne(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Brawler font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Brawler
  static TextStyle brawler({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'e0d4b696165bc22de1ebf4311429a9212b02fd077f70d4132ca54a67136720ce',
        39088,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '4769547d4a6a1abf9cda5f8f8cd62742ba10463bbf5ea3bceb8b827a92b6262f',
        32500,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Brawler',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Brawler font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Brawler
  static TextTheme brawlerTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: brawler(textStyle: textTheme.displayLarge),
      displayMedium: brawler(textStyle: textTheme.displayMedium),
      displaySmall: brawler(textStyle: textTheme.displaySmall),
      headlineLarge: brawler(textStyle: textTheme.headlineLarge),
      headlineMedium: brawler(textStyle: textTheme.headlineMedium),
      headlineSmall: brawler(textStyle: textTheme.headlineSmall),
      titleLarge: brawler(textStyle: textTheme.titleLarge),
      titleMedium: brawler(textStyle: textTheme.titleMedium),
      titleSmall: brawler(textStyle: textTheme.titleSmall),
      bodyLarge: brawler(textStyle: textTheme.bodyLarge),
      bodyMedium: brawler(textStyle: textTheme.bodyMedium),
      bodySmall: brawler(textStyle: textTheme.bodySmall),
      labelLarge: brawler(textStyle: textTheme.labelLarge),
      labelMedium: brawler(textStyle: textTheme.labelMedium),
      labelSmall: brawler(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Bree Serif font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bree+Serif
  static TextStyle breeSerif({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'd58c962d480e97d7b958f4cc94ff9da86bd30a95b9cea2fa0cc4baab60cf444c',
        42976,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'BreeSerif',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Bree Serif font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bree+Serif
  static TextTheme breeSerifTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: breeSerif(textStyle: textTheme.displayLarge),
      displayMedium: breeSerif(textStyle: textTheme.displayMedium),
      displaySmall: breeSerif(textStyle: textTheme.displaySmall),
      headlineLarge: breeSerif(textStyle: textTheme.headlineLarge),
      headlineMedium: breeSerif(textStyle: textTheme.headlineMedium),
      headlineSmall: breeSerif(textStyle: textTheme.headlineSmall),
      titleLarge: breeSerif(textStyle: textTheme.titleLarge),
      titleMedium: breeSerif(textStyle: textTheme.titleMedium),
      titleSmall: breeSerif(textStyle: textTheme.titleSmall),
      bodyLarge: breeSerif(textStyle: textTheme.bodyLarge),
      bodyMedium: breeSerif(textStyle: textTheme.bodyMedium),
      bodySmall: breeSerif(textStyle: textTheme.bodySmall),
      labelLarge: breeSerif(textStyle: textTheme.labelLarge),
      labelMedium: breeSerif(textStyle: textTheme.labelMedium),
      labelSmall: breeSerif(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Bricolage Grotesque font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bricolage+Grotesque
  static TextStyle bricolageGrotesque({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '7e7f81ec1406e7cd762fb6ac93ef111d6b2683914fa98164683da4d39dca1608',
        82316,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '1966d6e7298b6f7382fa7faa1fdfbb0c5906ec61a020190b1dbf3cc34f918cce',
        82188,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '939dc04e2f37d72dcd6616a48c6545c5f357b89084766a9ee28bd3dfea161ddf',
        82168,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '9a13292c84d3d6d6cdc2aed28340bde9db24865ec0e5e9b49fd03a4a8ada6d43',
        82220,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'ea506831d0960376a1d3895ea68fd70fd93dd5a6d464c927898a6743e9c1a188',
        82280,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '441dfdf87403d13d21f818dbba584ea5c49021ae8479863ef8d983c94f89e5f9',
        82180,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '9d6e6be444efda1fd2d8af9e289b8c09c3ab441b8006bddb2b49c96f97841d07',
        82308,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'BricolageGrotesque',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Bricolage Grotesque font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bricolage+Grotesque
  static TextTheme bricolageGrotesqueTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: bricolageGrotesque(textStyle: textTheme.displayLarge),
      displayMedium: bricolageGrotesque(textStyle: textTheme.displayMedium),
      displaySmall: bricolageGrotesque(textStyle: textTheme.displaySmall),
      headlineLarge: bricolageGrotesque(textStyle: textTheme.headlineLarge),
      headlineMedium: bricolageGrotesque(textStyle: textTheme.headlineMedium),
      headlineSmall: bricolageGrotesque(textStyle: textTheme.headlineSmall),
      titleLarge: bricolageGrotesque(textStyle: textTheme.titleLarge),
      titleMedium: bricolageGrotesque(textStyle: textTheme.titleMedium),
      titleSmall: bricolageGrotesque(textStyle: textTheme.titleSmall),
      bodyLarge: bricolageGrotesque(textStyle: textTheme.bodyLarge),
      bodyMedium: bricolageGrotesque(textStyle: textTheme.bodyMedium),
      bodySmall: bricolageGrotesque(textStyle: textTheme.bodySmall),
      labelLarge: bricolageGrotesque(textStyle: textTheme.labelLarge),
      labelMedium: bricolageGrotesque(textStyle: textTheme.labelMedium),
      labelSmall: bricolageGrotesque(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Bruno Ace font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bruno+Ace
  static TextStyle brunoAce({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'bbca71a0e002a28e06c19053cddd4dd36b766ed9df14c58fabb2b0fe187317f9',
        40284,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'BrunoAce',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Bruno Ace font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bruno+Ace
  static TextTheme brunoAceTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: brunoAce(textStyle: textTheme.displayLarge),
      displayMedium: brunoAce(textStyle: textTheme.displayMedium),
      displaySmall: brunoAce(textStyle: textTheme.displaySmall),
      headlineLarge: brunoAce(textStyle: textTheme.headlineLarge),
      headlineMedium: brunoAce(textStyle: textTheme.headlineMedium),
      headlineSmall: brunoAce(textStyle: textTheme.headlineSmall),
      titleLarge: brunoAce(textStyle: textTheme.titleLarge),
      titleMedium: brunoAce(textStyle: textTheme.titleMedium),
      titleSmall: brunoAce(textStyle: textTheme.titleSmall),
      bodyLarge: brunoAce(textStyle: textTheme.bodyLarge),
      bodyMedium: brunoAce(textStyle: textTheme.bodyMedium),
      bodySmall: brunoAce(textStyle: textTheme.bodySmall),
      labelLarge: brunoAce(textStyle: textTheme.labelLarge),
      labelMedium: brunoAce(textStyle: textTheme.labelMedium),
      labelSmall: brunoAce(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Bruno Ace SC font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bruno+Ace+SC
  static TextStyle brunoAceSc({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '315dc296253f4a92e5a13e75d97b10efdbf0f5d67b7430d9eef38d0096c8bcf4',
        39244,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'BrunoAceSC',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Bruno Ace SC font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bruno+Ace+SC
  static TextTheme brunoAceScTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: brunoAceSc(textStyle: textTheme.displayLarge),
      displayMedium: brunoAceSc(textStyle: textTheme.displayMedium),
      displaySmall: brunoAceSc(textStyle: textTheme.displaySmall),
      headlineLarge: brunoAceSc(textStyle: textTheme.headlineLarge),
      headlineMedium: brunoAceSc(textStyle: textTheme.headlineMedium),
      headlineSmall: brunoAceSc(textStyle: textTheme.headlineSmall),
      titleLarge: brunoAceSc(textStyle: textTheme.titleLarge),
      titleMedium: brunoAceSc(textStyle: textTheme.titleMedium),
      titleSmall: brunoAceSc(textStyle: textTheme.titleSmall),
      bodyLarge: brunoAceSc(textStyle: textTheme.bodyLarge),
      bodyMedium: brunoAceSc(textStyle: textTheme.bodyMedium),
      bodySmall: brunoAceSc(textStyle: textTheme.bodySmall),
      labelLarge: brunoAceSc(textStyle: textTheme.labelLarge),
      labelMedium: brunoAceSc(textStyle: textTheme.labelMedium),
      labelSmall: brunoAceSc(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Brygada 1918 font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Brygada+1918
  static TextStyle brygada1918({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'ba71876ebddee19e3f62e4b191c7372fcd9fdfd78656d0e1d071a3643a836465',
        121484,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '190a62625d79b765b27942b6e1ecffd549d224d00415f9c2b85aa068cf67ac06',
        122024,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '5180e5523a0db8751112aeda27a99f3740f731dfd3cb4faa6547c62482ebbee0',
        122000,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '5f01a70d3beacd63fc95651c0adfacd1001d003dc29cdd645a29f8368ad8b1f4',
        121940,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'd140d31baf9a031b3cd3946d6171a3967c9c05fad5507a235c21d80934e230b9',
        120804,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'a559dbfa35a755d9e61ced8a14a61cfe4ed1685a6acd0688b9e0edafd937f8f3',
        121004,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '316f5a84d9a6c982e17dc1689eec6140e2e8036bb7e02a8a5a101ccabf6fc4e6',
        121128,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'e85e1ad860782d816e9cfef3d29b8d5c9167e6c185b387399bb2c9d127d9d2b4',
        121040,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Brygada1918',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Brygada 1918 font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Brygada+1918
  static TextTheme brygada1918TextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: brygada1918(textStyle: textTheme.displayLarge),
      displayMedium: brygada1918(textStyle: textTheme.displayMedium),
      displaySmall: brygada1918(textStyle: textTheme.displaySmall),
      headlineLarge: brygada1918(textStyle: textTheme.headlineLarge),
      headlineMedium: brygada1918(textStyle: textTheme.headlineMedium),
      headlineSmall: brygada1918(textStyle: textTheme.headlineSmall),
      titleLarge: brygada1918(textStyle: textTheme.titleLarge),
      titleMedium: brygada1918(textStyle: textTheme.titleMedium),
      titleSmall: brygada1918(textStyle: textTheme.titleSmall),
      bodyLarge: brygada1918(textStyle: textTheme.bodyLarge),
      bodyMedium: brygada1918(textStyle: textTheme.bodyMedium),
      bodySmall: brygada1918(textStyle: textTheme.bodySmall),
      labelLarge: brygada1918(textStyle: textTheme.labelLarge),
      labelMedium: brygada1918(textStyle: textTheme.labelMedium),
      labelSmall: brygada1918(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Bubblegum Sans font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bubblegum+Sans
  static TextStyle bubblegumSans({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '75c0878aea2de485a694ed9d6c7a7a3b2f48e6f5e8de30cf6b8bcbaf0872e1c2',
        36660,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'BubblegumSans',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Bubblegum Sans font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bubblegum+Sans
  static TextTheme bubblegumSansTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: bubblegumSans(textStyle: textTheme.displayLarge),
      displayMedium: bubblegumSans(textStyle: textTheme.displayMedium),
      displaySmall: bubblegumSans(textStyle: textTheme.displaySmall),
      headlineLarge: bubblegumSans(textStyle: textTheme.headlineLarge),
      headlineMedium: bubblegumSans(textStyle: textTheme.headlineMedium),
      headlineSmall: bubblegumSans(textStyle: textTheme.headlineSmall),
      titleLarge: bubblegumSans(textStyle: textTheme.titleLarge),
      titleMedium: bubblegumSans(textStyle: textTheme.titleMedium),
      titleSmall: bubblegumSans(textStyle: textTheme.titleSmall),
      bodyLarge: bubblegumSans(textStyle: textTheme.bodyLarge),
      bodyMedium: bubblegumSans(textStyle: textTheme.bodyMedium),
      bodySmall: bubblegumSans(textStyle: textTheme.bodySmall),
      labelLarge: bubblegumSans(textStyle: textTheme.labelLarge),
      labelMedium: bubblegumSans(textStyle: textTheme.labelMedium),
      labelSmall: bubblegumSans(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Bubbler One font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bubbler+One
  static TextStyle bubblerOne({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'a1069015b76a5629afc944a3ce37f5cb51991c9a15bbed42a9c74b4995b44f01',
        29284,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'BubblerOne',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Bubbler One font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bubbler+One
  static TextTheme bubblerOneTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: bubblerOne(textStyle: textTheme.displayLarge),
      displayMedium: bubblerOne(textStyle: textTheme.displayMedium),
      displaySmall: bubblerOne(textStyle: textTheme.displaySmall),
      headlineLarge: bubblerOne(textStyle: textTheme.headlineLarge),
      headlineMedium: bubblerOne(textStyle: textTheme.headlineMedium),
      headlineSmall: bubblerOne(textStyle: textTheme.headlineSmall),
      titleLarge: bubblerOne(textStyle: textTheme.titleLarge),
      titleMedium: bubblerOne(textStyle: textTheme.titleMedium),
      titleSmall: bubblerOne(textStyle: textTheme.titleSmall),
      bodyLarge: bubblerOne(textStyle: textTheme.bodyLarge),
      bodyMedium: bubblerOne(textStyle: textTheme.bodyMedium),
      bodySmall: bubblerOne(textStyle: textTheme.bodySmall),
      labelLarge: bubblerOne(textStyle: textTheme.labelLarge),
      labelMedium: bubblerOne(textStyle: textTheme.labelMedium),
      labelSmall: bubblerOne(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Buda font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Buda
  static TextStyle buda({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '6a3de746e9bb57f1126ceb335a59aceb989b2f7b1a424171bd75ce32288ec829',
        33364,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Buda',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Buda font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Buda
  static TextTheme budaTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: buda(textStyle: textTheme.displayLarge),
      displayMedium: buda(textStyle: textTheme.displayMedium),
      displaySmall: buda(textStyle: textTheme.displaySmall),
      headlineLarge: buda(textStyle: textTheme.headlineLarge),
      headlineMedium: buda(textStyle: textTheme.headlineMedium),
      headlineSmall: buda(textStyle: textTheme.headlineSmall),
      titleLarge: buda(textStyle: textTheme.titleLarge),
      titleMedium: buda(textStyle: textTheme.titleMedium),
      titleSmall: buda(textStyle: textTheme.titleSmall),
      bodyLarge: buda(textStyle: textTheme.bodyLarge),
      bodyMedium: buda(textStyle: textTheme.bodyMedium),
      bodySmall: buda(textStyle: textTheme.bodySmall),
      labelLarge: buda(textStyle: textTheme.labelLarge),
      labelMedium: buda(textStyle: textTheme.labelMedium),
      labelSmall: buda(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Buenard font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Buenard
  static TextStyle buenard({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'ac07f1eaffbd0a8f9bc910f1d45d64827dabbcc9a7937a9fd7e6ffca4527a8aa',
        47116,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '4ed51154affb7d960c2f8a58b086f3e526e6655c6a143c59b8ed6574123f36fb',
        47236,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'be782e620afcb49d2d23658241bc5cf4deabbc98098399f30f84d935969e65c1',
        47256,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '573cefb59454135f66ef26f66f19e752b609abe87068def44f83e167671d41bf',
        47084,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Buenard',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Buenard font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Buenard
  static TextTheme buenardTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: buenard(textStyle: textTheme.displayLarge),
      displayMedium: buenard(textStyle: textTheme.displayMedium),
      displaySmall: buenard(textStyle: textTheme.displaySmall),
      headlineLarge: buenard(textStyle: textTheme.headlineLarge),
      headlineMedium: buenard(textStyle: textTheme.headlineMedium),
      headlineSmall: buenard(textStyle: textTheme.headlineSmall),
      titleLarge: buenard(textStyle: textTheme.titleLarge),
      titleMedium: buenard(textStyle: textTheme.titleMedium),
      titleSmall: buenard(textStyle: textTheme.titleSmall),
      bodyLarge: buenard(textStyle: textTheme.bodyLarge),
      bodyMedium: buenard(textStyle: textTheme.bodyMedium),
      bodySmall: buenard(textStyle: textTheme.bodySmall),
      labelLarge: buenard(textStyle: textTheme.labelLarge),
      labelMedium: buenard(textStyle: textTheme.labelMedium),
      labelSmall: buenard(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Bungee font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bungee
  static TextStyle bungee({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'aa707aa79b5eac140e0b956c513c5a5e6e04d308d06047088a9c1437b1f88ea5',
        110432,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Bungee',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Bungee font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bungee
  static TextTheme bungeeTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: bungee(textStyle: textTheme.displayLarge),
      displayMedium: bungee(textStyle: textTheme.displayMedium),
      displaySmall: bungee(textStyle: textTheme.displaySmall),
      headlineLarge: bungee(textStyle: textTheme.headlineLarge),
      headlineMedium: bungee(textStyle: textTheme.headlineMedium),
      headlineSmall: bungee(textStyle: textTheme.headlineSmall),
      titleLarge: bungee(textStyle: textTheme.titleLarge),
      titleMedium: bungee(textStyle: textTheme.titleMedium),
      titleSmall: bungee(textStyle: textTheme.titleSmall),
      bodyLarge: bungee(textStyle: textTheme.bodyLarge),
      bodyMedium: bungee(textStyle: textTheme.bodyMedium),
      bodySmall: bungee(textStyle: textTheme.bodySmall),
      labelLarge: bungee(textStyle: textTheme.labelLarge),
      labelMedium: bungee(textStyle: textTheme.labelMedium),
      labelSmall: bungee(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Bungee Hairline font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bungee+Hairline
  static TextStyle bungeeHairline({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '9186c591f8dab61fb008dcc20b9970794de2285d3049d941905f228d9c0255aa',
        96152,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'BungeeHairline',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Bungee Hairline font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bungee+Hairline
  static TextTheme bungeeHairlineTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: bungeeHairline(textStyle: textTheme.displayLarge),
      displayMedium: bungeeHairline(textStyle: textTheme.displayMedium),
      displaySmall: bungeeHairline(textStyle: textTheme.displaySmall),
      headlineLarge: bungeeHairline(textStyle: textTheme.headlineLarge),
      headlineMedium: bungeeHairline(textStyle: textTheme.headlineMedium),
      headlineSmall: bungeeHairline(textStyle: textTheme.headlineSmall),
      titleLarge: bungeeHairline(textStyle: textTheme.titleLarge),
      titleMedium: bungeeHairline(textStyle: textTheme.titleMedium),
      titleSmall: bungeeHairline(textStyle: textTheme.titleSmall),
      bodyLarge: bungeeHairline(textStyle: textTheme.bodyLarge),
      bodyMedium: bungeeHairline(textStyle: textTheme.bodyMedium),
      bodySmall: bungeeHairline(textStyle: textTheme.bodySmall),
      labelLarge: bungeeHairline(textStyle: textTheme.labelLarge),
      labelMedium: bungeeHairline(textStyle: textTheme.labelMedium),
      labelSmall: bungeeHairline(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Bungee Inline font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bungee+Inline
  static TextStyle bungeeInline({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'b1d48b3ce6fc0bdc54f38ef30425bdb199a3c48c395add01788652b2ab2b0f67',
        143768,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'BungeeInline',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Bungee Inline font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bungee+Inline
  static TextTheme bungeeInlineTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: bungeeInline(textStyle: textTheme.displayLarge),
      displayMedium: bungeeInline(textStyle: textTheme.displayMedium),
      displaySmall: bungeeInline(textStyle: textTheme.displaySmall),
      headlineLarge: bungeeInline(textStyle: textTheme.headlineLarge),
      headlineMedium: bungeeInline(textStyle: textTheme.headlineMedium),
      headlineSmall: bungeeInline(textStyle: textTheme.headlineSmall),
      titleLarge: bungeeInline(textStyle: textTheme.titleLarge),
      titleMedium: bungeeInline(textStyle: textTheme.titleMedium),
      titleSmall: bungeeInline(textStyle: textTheme.titleSmall),
      bodyLarge: bungeeInline(textStyle: textTheme.bodyLarge),
      bodyMedium: bungeeInline(textStyle: textTheme.bodyMedium),
      bodySmall: bungeeInline(textStyle: textTheme.bodySmall),
      labelLarge: bungeeInline(textStyle: textTheme.labelLarge),
      labelMedium: bungeeInline(textStyle: textTheme.labelMedium),
      labelSmall: bungeeInline(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Bungee Outline font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bungee+Outline
  static TextStyle bungeeOutline({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'bc3560f327a5463c3c20a61a5e83985706e35cc884e83ed979937e46a29899e8',
        193448,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'BungeeOutline',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Bungee Outline font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bungee+Outline
  static TextTheme bungeeOutlineTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: bungeeOutline(textStyle: textTheme.displayLarge),
      displayMedium: bungeeOutline(textStyle: textTheme.displayMedium),
      displaySmall: bungeeOutline(textStyle: textTheme.displaySmall),
      headlineLarge: bungeeOutline(textStyle: textTheme.headlineLarge),
      headlineMedium: bungeeOutline(textStyle: textTheme.headlineMedium),
      headlineSmall: bungeeOutline(textStyle: textTheme.headlineSmall),
      titleLarge: bungeeOutline(textStyle: textTheme.titleLarge),
      titleMedium: bungeeOutline(textStyle: textTheme.titleMedium),
      titleSmall: bungeeOutline(textStyle: textTheme.titleSmall),
      bodyLarge: bungeeOutline(textStyle: textTheme.bodyLarge),
      bodyMedium: bungeeOutline(textStyle: textTheme.bodyMedium),
      bodySmall: bungeeOutline(textStyle: textTheme.bodySmall),
      labelLarge: bungeeOutline(textStyle: textTheme.labelLarge),
      labelMedium: bungeeOutline(textStyle: textTheme.labelMedium),
      labelSmall: bungeeOutline(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Bungee Shade font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bungee+Shade
  static TextStyle bungeeShade({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '4a013762d0a4a012f698a3e272235b218a06ad328e36612f72d71150395e5dc0',
        293112,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'BungeeShade',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Bungee Shade font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bungee+Shade
  static TextTheme bungeeShadeTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: bungeeShade(textStyle: textTheme.displayLarge),
      displayMedium: bungeeShade(textStyle: textTheme.displayMedium),
      displaySmall: bungeeShade(textStyle: textTheme.displaySmall),
      headlineLarge: bungeeShade(textStyle: textTheme.headlineLarge),
      headlineMedium: bungeeShade(textStyle: textTheme.headlineMedium),
      headlineSmall: bungeeShade(textStyle: textTheme.headlineSmall),
      titleLarge: bungeeShade(textStyle: textTheme.titleLarge),
      titleMedium: bungeeShade(textStyle: textTheme.titleMedium),
      titleSmall: bungeeShade(textStyle: textTheme.titleSmall),
      bodyLarge: bungeeShade(textStyle: textTheme.bodyLarge),
      bodyMedium: bungeeShade(textStyle: textTheme.bodyMedium),
      bodySmall: bungeeShade(textStyle: textTheme.bodySmall),
      labelLarge: bungeeShade(textStyle: textTheme.labelLarge),
      labelMedium: bungeeShade(textStyle: textTheme.labelMedium),
      labelSmall: bungeeShade(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Bungee Spice font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bungee+Spice
  static TextStyle bungeeSpice({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '4e48fb9c3aa4cffe3742544a17c675a286135b62e3f6bf956bb2b56a69ff1ade',
        1487960,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'BungeeSpice',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Bungee Spice font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bungee+Spice
  static TextTheme bungeeSpiceTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: bungeeSpice(textStyle: textTheme.displayLarge),
      displayMedium: bungeeSpice(textStyle: textTheme.displayMedium),
      displaySmall: bungeeSpice(textStyle: textTheme.displaySmall),
      headlineLarge: bungeeSpice(textStyle: textTheme.headlineLarge),
      headlineMedium: bungeeSpice(textStyle: textTheme.headlineMedium),
      headlineSmall: bungeeSpice(textStyle: textTheme.headlineSmall),
      titleLarge: bungeeSpice(textStyle: textTheme.titleLarge),
      titleMedium: bungeeSpice(textStyle: textTheme.titleMedium),
      titleSmall: bungeeSpice(textStyle: textTheme.titleSmall),
      bodyLarge: bungeeSpice(textStyle: textTheme.bodyLarge),
      bodyMedium: bungeeSpice(textStyle: textTheme.bodyMedium),
      bodySmall: bungeeSpice(textStyle: textTheme.bodySmall),
      labelLarge: bungeeSpice(textStyle: textTheme.labelLarge),
      labelMedium: bungeeSpice(textStyle: textTheme.labelMedium),
      labelSmall: bungeeSpice(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Bungee Tint font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bungee+Tint
  static TextStyle bungeeTint({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '5b5a4319a46bb69e074797e8f250d37d8ada79392400e42218c2a9f879be6313',
        209116,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'BungeeTint',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Bungee Tint font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bungee+Tint
  static TextTheme bungeeTintTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: bungeeTint(textStyle: textTheme.displayLarge),
      displayMedium: bungeeTint(textStyle: textTheme.displayMedium),
      displaySmall: bungeeTint(textStyle: textTheme.displaySmall),
      headlineLarge: bungeeTint(textStyle: textTheme.headlineLarge),
      headlineMedium: bungeeTint(textStyle: textTheme.headlineMedium),
      headlineSmall: bungeeTint(textStyle: textTheme.headlineSmall),
      titleLarge: bungeeTint(textStyle: textTheme.titleLarge),
      titleMedium: bungeeTint(textStyle: textTheme.titleMedium),
      titleSmall: bungeeTint(textStyle: textTheme.titleSmall),
      bodyLarge: bungeeTint(textStyle: textTheme.bodyLarge),
      bodyMedium: bungeeTint(textStyle: textTheme.bodyMedium),
      bodySmall: bungeeTint(textStyle: textTheme.bodySmall),
      labelLarge: bungeeTint(textStyle: textTheme.labelLarge),
      labelMedium: bungeeTint(textStyle: textTheme.labelMedium),
      labelSmall: bungeeTint(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Butcherman font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Butcherman
  static TextStyle butcherman({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'a08f622a3dd41ce4301737d1125ddd7afb8da7fd8402c9e0ab4a4dcff48fed40',
        63320,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Butcherman',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Butcherman font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Butcherman
  static TextTheme butchermanTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: butcherman(textStyle: textTheme.displayLarge),
      displayMedium: butcherman(textStyle: textTheme.displayMedium),
      displaySmall: butcherman(textStyle: textTheme.displaySmall),
      headlineLarge: butcherman(textStyle: textTheme.headlineLarge),
      headlineMedium: butcherman(textStyle: textTheme.headlineMedium),
      headlineSmall: butcherman(textStyle: textTheme.headlineSmall),
      titleLarge: butcherman(textStyle: textTheme.titleLarge),
      titleMedium: butcherman(textStyle: textTheme.titleMedium),
      titleSmall: butcherman(textStyle: textTheme.titleSmall),
      bodyLarge: butcherman(textStyle: textTheme.bodyLarge),
      bodyMedium: butcherman(textStyle: textTheme.bodyMedium),
      bodySmall: butcherman(textStyle: textTheme.bodySmall),
      labelLarge: butcherman(textStyle: textTheme.labelLarge),
      labelMedium: butcherman(textStyle: textTheme.labelMedium),
      labelSmall: butcherman(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Butterfly Kids font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Butterfly+Kids
  static TextStyle butterflyKids({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '3129ed9c8f8c847f01b767bb6439f519af3796ea3387cc5128092c2919aae4a9',
        200428,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'ButterflyKids',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Butterfly Kids font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Butterfly+Kids
  static TextTheme butterflyKidsTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: butterflyKids(textStyle: textTheme.displayLarge),
      displayMedium: butterflyKids(textStyle: textTheme.displayMedium),
      displaySmall: butterflyKids(textStyle: textTheme.displaySmall),
      headlineLarge: butterflyKids(textStyle: textTheme.headlineLarge),
      headlineMedium: butterflyKids(textStyle: textTheme.headlineMedium),
      headlineSmall: butterflyKids(textStyle: textTheme.headlineSmall),
      titleLarge: butterflyKids(textStyle: textTheme.titleLarge),
      titleMedium: butterflyKids(textStyle: textTheme.titleMedium),
      titleSmall: butterflyKids(textStyle: textTheme.titleSmall),
      bodyLarge: butterflyKids(textStyle: textTheme.bodyLarge),
      bodyMedium: butterflyKids(textStyle: textTheme.bodyMedium),
      bodySmall: butterflyKids(textStyle: textTheme.bodySmall),
      labelLarge: butterflyKids(textStyle: textTheme.labelLarge),
      labelMedium: butterflyKids(textStyle: textTheme.labelMedium),
      labelSmall: butterflyKids(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Bytesized font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bytesized
  static TextStyle bytesized({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'c3fa2db8be7b9abfe5aeb827c17c646a7cf2bd01491e482436186db9d6ea382f',
        20376,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Bytesized',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Bytesized font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Bytesized
  static TextTheme bytesizedTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: bytesized(textStyle: textTheme.displayLarge),
      displayMedium: bytesized(textStyle: textTheme.displayMedium),
      displaySmall: bytesized(textStyle: textTheme.displaySmall),
      headlineLarge: bytesized(textStyle: textTheme.headlineLarge),
      headlineMedium: bytesized(textStyle: textTheme.headlineMedium),
      headlineSmall: bytesized(textStyle: textTheme.headlineSmall),
      titleLarge: bytesized(textStyle: textTheme.titleLarge),
      titleMedium: bytesized(textStyle: textTheme.titleMedium),
      titleSmall: bytesized(textStyle: textTheme.titleSmall),
      bodyLarge: bytesized(textStyle: textTheme.bodyLarge),
      bodyMedium: bytesized(textStyle: textTheme.bodyMedium),
      bodySmall: bytesized(textStyle: textTheme.bodySmall),
      labelLarge: bytesized(textStyle: textTheme.labelLarge),
      labelMedium: bytesized(textStyle: textTheme.labelMedium),
      labelSmall: bytesized(textStyle: textTheme.labelSmall),
    );
  }
}
