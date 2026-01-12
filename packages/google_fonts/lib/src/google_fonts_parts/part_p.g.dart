// GENERATED CODE - DO NOT EDIT

// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../google_fonts_base.dart';
import '../google_fonts_descriptor.dart';
import '../google_fonts_variant.dart';

/// Methods for fonts starting with 'P'.
class PartP {
  /// Applies the PT Mono font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/PT+Mono
  static TextStyle ptMono({
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
        '02a5924a29c2e9b93e400b36f86aa232efd510ad921d86af053aa59f756fbce0',
        60512,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PTMono',
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

  /// Applies the PT Mono font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/PT+Mono
  static TextTheme ptMonoTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: ptMono(textStyle: textTheme.displayLarge),
      displayMedium: ptMono(textStyle: textTheme.displayMedium),
      displaySmall: ptMono(textStyle: textTheme.displaySmall),
      headlineLarge: ptMono(textStyle: textTheme.headlineLarge),
      headlineMedium: ptMono(textStyle: textTheme.headlineMedium),
      headlineSmall: ptMono(textStyle: textTheme.headlineSmall),
      titleLarge: ptMono(textStyle: textTheme.titleLarge),
      titleMedium: ptMono(textStyle: textTheme.titleMedium),
      titleSmall: ptMono(textStyle: textTheme.titleSmall),
      bodyLarge: ptMono(textStyle: textTheme.bodyLarge),
      bodyMedium: ptMono(textStyle: textTheme.bodyMedium),
      bodySmall: ptMono(textStyle: textTheme.bodySmall),
      labelLarge: ptMono(textStyle: textTheme.labelLarge),
      labelMedium: ptMono(textStyle: textTheme.labelMedium),
      labelSmall: ptMono(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the PT Sans font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/PT+Sans
  static TextStyle ptSans({
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
        'c714eabe5798901318eaea4224306de43298ae5418307353f889188207bc26a4',
        66228,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '2969f3a3b70273141c82ce30f261960ad2e2fb436fff6b16001191ad36191f43',
        69228,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'e29960a9325d4042d681ae15a5aba5b6871abefd76f5bf42c428270ba9088520',
        66516,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '5a46868e949726c4a21ab461dddd575c0df6590ac41c6421f3656d2cf88a37ef',
        67112,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PTSans',
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

  /// Applies the PT Sans font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/PT+Sans
  static TextTheme ptSansTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: ptSans(textStyle: textTheme.displayLarge),
      displayMedium: ptSans(textStyle: textTheme.displayMedium),
      displaySmall: ptSans(textStyle: textTheme.displaySmall),
      headlineLarge: ptSans(textStyle: textTheme.headlineLarge),
      headlineMedium: ptSans(textStyle: textTheme.headlineMedium),
      headlineSmall: ptSans(textStyle: textTheme.headlineSmall),
      titleLarge: ptSans(textStyle: textTheme.titleLarge),
      titleMedium: ptSans(textStyle: textTheme.titleMedium),
      titleSmall: ptSans(textStyle: textTheme.titleSmall),
      bodyLarge: ptSans(textStyle: textTheme.bodyLarge),
      bodyMedium: ptSans(textStyle: textTheme.bodyMedium),
      bodySmall: ptSans(textStyle: textTheme.bodySmall),
      labelLarge: ptSans(textStyle: textTheme.labelLarge),
      labelMedium: ptSans(textStyle: textTheme.labelMedium),
      labelSmall: ptSans(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the PT Sans Caption font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/PT+Sans+Caption
  static TextStyle ptSansCaption({
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
        '130ffd62cde7dba62f9dbe12fbf067fbfdc6fddf257896f0cb161a0d7fa1d313',
        68020,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'ea3d1fb9eff3878a6fd779fa9c7307a899e077faca691b72a7c4aa4a00b3d39e',
        68832,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PTSansCaption',
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

  /// Applies the PT Sans Caption font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/PT+Sans+Caption
  static TextTheme ptSansCaptionTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: ptSansCaption(textStyle: textTheme.displayLarge),
      displayMedium: ptSansCaption(textStyle: textTheme.displayMedium),
      displaySmall: ptSansCaption(textStyle: textTheme.displaySmall),
      headlineLarge: ptSansCaption(textStyle: textTheme.headlineLarge),
      headlineMedium: ptSansCaption(textStyle: textTheme.headlineMedium),
      headlineSmall: ptSansCaption(textStyle: textTheme.headlineSmall),
      titleLarge: ptSansCaption(textStyle: textTheme.titleLarge),
      titleMedium: ptSansCaption(textStyle: textTheme.titleMedium),
      titleSmall: ptSansCaption(textStyle: textTheme.titleSmall),
      bodyLarge: ptSansCaption(textStyle: textTheme.bodyLarge),
      bodyMedium: ptSansCaption(textStyle: textTheme.bodyMedium),
      bodySmall: ptSansCaption(textStyle: textTheme.bodySmall),
      labelLarge: ptSansCaption(textStyle: textTheme.labelLarge),
      labelMedium: ptSansCaption(textStyle: textTheme.labelMedium),
      labelSmall: ptSansCaption(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the PT Sans Narrow font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/PT+Sans+Narrow
  static TextStyle ptSansNarrow({
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
        '552b97d55d9cdc87428c7293def48adeb1b90185d8c4e99c7bb6afc0bc34845f',
        65748,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '6c6bb6ece90ad6898c11afd6eca7b6860a040c246833ba6679838d9354806eaf',
        63832,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PTSansNarrow',
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

  /// Applies the PT Sans Narrow font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/PT+Sans+Narrow
  static TextTheme ptSansNarrowTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: ptSansNarrow(textStyle: textTheme.displayLarge),
      displayMedium: ptSansNarrow(textStyle: textTheme.displayMedium),
      displaySmall: ptSansNarrow(textStyle: textTheme.displaySmall),
      headlineLarge: ptSansNarrow(textStyle: textTheme.headlineLarge),
      headlineMedium: ptSansNarrow(textStyle: textTheme.headlineMedium),
      headlineSmall: ptSansNarrow(textStyle: textTheme.headlineSmall),
      titleLarge: ptSansNarrow(textStyle: textTheme.titleLarge),
      titleMedium: ptSansNarrow(textStyle: textTheme.titleMedium),
      titleSmall: ptSansNarrow(textStyle: textTheme.titleSmall),
      bodyLarge: ptSansNarrow(textStyle: textTheme.bodyLarge),
      bodyMedium: ptSansNarrow(textStyle: textTheme.bodyMedium),
      bodySmall: ptSansNarrow(textStyle: textTheme.bodySmall),
      labelLarge: ptSansNarrow(textStyle: textTheme.labelLarge),
      labelMedium: ptSansNarrow(textStyle: textTheme.labelMedium),
      labelSmall: ptSansNarrow(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the PT Serif font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/PT+Serif
  static TextStyle ptSerif({
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
        '0638ef6b9c547faff0b143e0668bc997224f5fc73e797f5055e39e29c6e2b004',
        78696,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'f7d2eca0c84d7fa8bdd081cde01acab643250de4f2b20bb00c4d58bf96bb6856',
        82648,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '94e0e54c632f18a0814cd6473701b683cff328324b9b9c4c95eac134cfdd8040',
        80936,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '7115b024296098d2e652eaea0836b0219c0992a7f32647087807d46107ac477a',
        84164,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PTSerif',
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

  /// Applies the PT Serif font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/PT+Serif
  static TextTheme ptSerifTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: ptSerif(textStyle: textTheme.displayLarge),
      displayMedium: ptSerif(textStyle: textTheme.displayMedium),
      displaySmall: ptSerif(textStyle: textTheme.displaySmall),
      headlineLarge: ptSerif(textStyle: textTheme.headlineLarge),
      headlineMedium: ptSerif(textStyle: textTheme.headlineMedium),
      headlineSmall: ptSerif(textStyle: textTheme.headlineSmall),
      titleLarge: ptSerif(textStyle: textTheme.titleLarge),
      titleMedium: ptSerif(textStyle: textTheme.titleMedium),
      titleSmall: ptSerif(textStyle: textTheme.titleSmall),
      bodyLarge: ptSerif(textStyle: textTheme.bodyLarge),
      bodyMedium: ptSerif(textStyle: textTheme.bodyMedium),
      bodySmall: ptSerif(textStyle: textTheme.bodySmall),
      labelLarge: ptSerif(textStyle: textTheme.labelLarge),
      labelMedium: ptSerif(textStyle: textTheme.labelMedium),
      labelSmall: ptSerif(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the PT Serif Caption font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/PT+Serif+Caption
  static TextStyle ptSerifCaption({
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
        'fbdee8724bc2bfd94ecfa87d0c6993b59fb855bdf0a9b53f06d0445eccaf2b61',
        69868,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'a2120a5938253a7e77c681a9e794c39d00fcdec187781b1cb7d5f0a30321608c',
        76632,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PTSerifCaption',
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

  /// Applies the PT Serif Caption font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/PT+Serif+Caption
  static TextTheme ptSerifCaptionTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: ptSerifCaption(textStyle: textTheme.displayLarge),
      displayMedium: ptSerifCaption(textStyle: textTheme.displayMedium),
      displaySmall: ptSerifCaption(textStyle: textTheme.displaySmall),
      headlineLarge: ptSerifCaption(textStyle: textTheme.headlineLarge),
      headlineMedium: ptSerifCaption(textStyle: textTheme.headlineMedium),
      headlineSmall: ptSerifCaption(textStyle: textTheme.headlineSmall),
      titleLarge: ptSerifCaption(textStyle: textTheme.titleLarge),
      titleMedium: ptSerifCaption(textStyle: textTheme.titleMedium),
      titleSmall: ptSerifCaption(textStyle: textTheme.titleSmall),
      bodyLarge: ptSerifCaption(textStyle: textTheme.bodyLarge),
      bodyMedium: ptSerifCaption(textStyle: textTheme.bodyMedium),
      bodySmall: ptSerifCaption(textStyle: textTheme.bodySmall),
      labelLarge: ptSerifCaption(textStyle: textTheme.labelLarge),
      labelMedium: ptSerifCaption(textStyle: textTheme.labelMedium),
      labelSmall: ptSerifCaption(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Pacifico font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Pacifico
  static TextStyle pacifico({
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
        '6bee281fb0df108aac201c1c277da345935bf7271e0cc42b99455890c936823e',
        170436,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Pacifico',
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

  /// Applies the Pacifico font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Pacifico
  static TextTheme pacificoTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: pacifico(textStyle: textTheme.displayLarge),
      displayMedium: pacifico(textStyle: textTheme.displayMedium),
      displaySmall: pacifico(textStyle: textTheme.displaySmall),
      headlineLarge: pacifico(textStyle: textTheme.headlineLarge),
      headlineMedium: pacifico(textStyle: textTheme.headlineMedium),
      headlineSmall: pacifico(textStyle: textTheme.headlineSmall),
      titleLarge: pacifico(textStyle: textTheme.titleLarge),
      titleMedium: pacifico(textStyle: textTheme.titleMedium),
      titleSmall: pacifico(textStyle: textTheme.titleSmall),
      bodyLarge: pacifico(textStyle: textTheme.bodyLarge),
      bodyMedium: pacifico(textStyle: textTheme.bodyMedium),
      bodySmall: pacifico(textStyle: textTheme.bodySmall),
      labelLarge: pacifico(textStyle: textTheme.labelLarge),
      labelMedium: pacifico(textStyle: textTheme.labelMedium),
      labelSmall: pacifico(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Padauk font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Padauk
  static TextStyle padauk({
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
        'ed2d20822f0888bc9301b63490f4f6661075068b0661d5d317ce0607e93bbd7a',
        161244,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '9d350c5332808de2952b0324f9580df4b6930887921e206a169dfe8270f7b708',
        161664,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Padauk',
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

  /// Applies the Padauk font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Padauk
  static TextTheme padaukTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: padauk(textStyle: textTheme.displayLarge),
      displayMedium: padauk(textStyle: textTheme.displayMedium),
      displaySmall: padauk(textStyle: textTheme.displaySmall),
      headlineLarge: padauk(textStyle: textTheme.headlineLarge),
      headlineMedium: padauk(textStyle: textTheme.headlineMedium),
      headlineSmall: padauk(textStyle: textTheme.headlineSmall),
      titleLarge: padauk(textStyle: textTheme.titleLarge),
      titleMedium: padauk(textStyle: textTheme.titleMedium),
      titleSmall: padauk(textStyle: textTheme.titleSmall),
      bodyLarge: padauk(textStyle: textTheme.bodyLarge),
      bodyMedium: padauk(textStyle: textTheme.bodyMedium),
      bodySmall: padauk(textStyle: textTheme.bodySmall),
      labelLarge: padauk(textStyle: textTheme.labelLarge),
      labelMedium: padauk(textStyle: textTheme.labelMedium),
      labelSmall: padauk(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Padyakke Expanded One font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Padyakke+Expanded+One
  static TextStyle padyakkeExpandedOne({
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
        'e9af55152219cb5e60e9a3923208f771967dca65e44fe1f1d0eb9056d6129f64',
        263848,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PadyakkeExpandedOne',
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

  /// Applies the Padyakke Expanded One font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Padyakke+Expanded+One
  static TextTheme padyakkeExpandedOneTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: padyakkeExpandedOne(textStyle: textTheme.displayLarge),
      displayMedium: padyakkeExpandedOne(textStyle: textTheme.displayMedium),
      displaySmall: padyakkeExpandedOne(textStyle: textTheme.displaySmall),
      headlineLarge: padyakkeExpandedOne(textStyle: textTheme.headlineLarge),
      headlineMedium: padyakkeExpandedOne(textStyle: textTheme.headlineMedium),
      headlineSmall: padyakkeExpandedOne(textStyle: textTheme.headlineSmall),
      titleLarge: padyakkeExpandedOne(textStyle: textTheme.titleLarge),
      titleMedium: padyakkeExpandedOne(textStyle: textTheme.titleMedium),
      titleSmall: padyakkeExpandedOne(textStyle: textTheme.titleSmall),
      bodyLarge: padyakkeExpandedOne(textStyle: textTheme.bodyLarge),
      bodyMedium: padyakkeExpandedOne(textStyle: textTheme.bodyMedium),
      bodySmall: padyakkeExpandedOne(textStyle: textTheme.bodySmall),
      labelLarge: padyakkeExpandedOne(textStyle: textTheme.labelLarge),
      labelMedium: padyakkeExpandedOne(textStyle: textTheme.labelMedium),
      labelSmall: padyakkeExpandedOne(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Palanquin font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Palanquin
  static TextStyle palanquin({
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
        '659a2da7bd683d477879bf0da09eece77dba5b9749509154215ae7622c429f41',
        266328,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '76aed475084712714f55afa7e17978e91f04e18b942f3f5dda453ca4e88078ba',
        267856,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '78b5859d3acbcdf037cf0f26540cdd3503ec3b5892dbb4a3d195b5755fa4352f',
        268072,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '6fc400ffee3b8e06ffc17f4779e5607ab775824de32845f46c9799fc6b6f4800',
        276056,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '7ba11f6006fffcada1f5d12b2d6ffdc7e2de6b2a10b3cc574de4029d5a6932b0',
        275212,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'fcc77f028ce3a047bdd0fa0d280ff4a59165a67680ef9a40388ea4f1c1eaa781',
        275368,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '025e6953f784139450a8ff520671162ad13f6fe0072a53676c034f55cef3b226',
        263920,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Palanquin',
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

  /// Applies the Palanquin font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Palanquin
  static TextTheme palanquinTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: palanquin(textStyle: textTheme.displayLarge),
      displayMedium: palanquin(textStyle: textTheme.displayMedium),
      displaySmall: palanquin(textStyle: textTheme.displaySmall),
      headlineLarge: palanquin(textStyle: textTheme.headlineLarge),
      headlineMedium: palanquin(textStyle: textTheme.headlineMedium),
      headlineSmall: palanquin(textStyle: textTheme.headlineSmall),
      titleLarge: palanquin(textStyle: textTheme.titleLarge),
      titleMedium: palanquin(textStyle: textTheme.titleMedium),
      titleSmall: palanquin(textStyle: textTheme.titleSmall),
      bodyLarge: palanquin(textStyle: textTheme.bodyLarge),
      bodyMedium: palanquin(textStyle: textTheme.bodyMedium),
      bodySmall: palanquin(textStyle: textTheme.bodySmall),
      labelLarge: palanquin(textStyle: textTheme.labelLarge),
      labelMedium: palanquin(textStyle: textTheme.labelMedium),
      labelSmall: palanquin(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Palanquin Dark font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Palanquin+Dark
  static TextStyle palanquinDark({
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
        '06ae96d3b5baa08180fd6608dae60844766fb69ee250e39d34f3e0a368a0a8c2',
        258504,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'cb8e4d8cbd9bbd7f45ef9382b32af4f401c0a62617ec29fb8c82a6adced16d79',
        265792,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'f6d8f83cc36ba0f917765970c9c0cdad9b5d30011aff4b40541a44541b9957a7',
        267276,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '567e96934c765e2a8efe1578631dd61246f6bf4b0d751fd3e21c8013979759f4',
        258052,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PalanquinDark',
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

  /// Applies the Palanquin Dark font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Palanquin+Dark
  static TextTheme palanquinDarkTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: palanquinDark(textStyle: textTheme.displayLarge),
      displayMedium: palanquinDark(textStyle: textTheme.displayMedium),
      displaySmall: palanquinDark(textStyle: textTheme.displaySmall),
      headlineLarge: palanquinDark(textStyle: textTheme.headlineLarge),
      headlineMedium: palanquinDark(textStyle: textTheme.headlineMedium),
      headlineSmall: palanquinDark(textStyle: textTheme.headlineSmall),
      titleLarge: palanquinDark(textStyle: textTheme.titleLarge),
      titleMedium: palanquinDark(textStyle: textTheme.titleMedium),
      titleSmall: palanquinDark(textStyle: textTheme.titleSmall),
      bodyLarge: palanquinDark(textStyle: textTheme.bodyLarge),
      bodyMedium: palanquinDark(textStyle: textTheme.bodyMedium),
      bodySmall: palanquinDark(textStyle: textTheme.bodySmall),
      labelLarge: palanquinDark(textStyle: textTheme.labelLarge),
      labelMedium: palanquinDark(textStyle: textTheme.labelMedium),
      labelSmall: palanquinDark(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Palette Mosaic font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Palette+Mosaic
  static TextStyle paletteMosaic({
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
        '6cf0ab4dbb321f7a6614aff29f7cda81877cf9feb94b9a69234176b2f8c1f63e',
        141936,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PaletteMosaic',
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

  /// Applies the Palette Mosaic font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Palette+Mosaic
  static TextTheme paletteMosaicTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: paletteMosaic(textStyle: textTheme.displayLarge),
      displayMedium: paletteMosaic(textStyle: textTheme.displayMedium),
      displaySmall: paletteMosaic(textStyle: textTheme.displaySmall),
      headlineLarge: paletteMosaic(textStyle: textTheme.headlineLarge),
      headlineMedium: paletteMosaic(textStyle: textTheme.headlineMedium),
      headlineSmall: paletteMosaic(textStyle: textTheme.headlineSmall),
      titleLarge: paletteMosaic(textStyle: textTheme.titleLarge),
      titleMedium: paletteMosaic(textStyle: textTheme.titleMedium),
      titleSmall: paletteMosaic(textStyle: textTheme.titleSmall),
      bodyLarge: paletteMosaic(textStyle: textTheme.bodyLarge),
      bodyMedium: paletteMosaic(textStyle: textTheme.bodyMedium),
      bodySmall: paletteMosaic(textStyle: textTheme.bodySmall),
      labelLarge: paletteMosaic(textStyle: textTheme.labelLarge),
      labelMedium: paletteMosaic(textStyle: textTheme.labelMedium),
      labelSmall: paletteMosaic(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Pangolin font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Pangolin
  static TextStyle pangolin({
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
        'b6fc65595735e68ceb5ccae54220c6cb14de1abfd8d49918d2c31dd8b03b13ef',
        235380,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Pangolin',
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

  /// Applies the Pangolin font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Pangolin
  static TextTheme pangolinTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: pangolin(textStyle: textTheme.displayLarge),
      displayMedium: pangolin(textStyle: textTheme.displayMedium),
      displaySmall: pangolin(textStyle: textTheme.displaySmall),
      headlineLarge: pangolin(textStyle: textTheme.headlineLarge),
      headlineMedium: pangolin(textStyle: textTheme.headlineMedium),
      headlineSmall: pangolin(textStyle: textTheme.headlineSmall),
      titleLarge: pangolin(textStyle: textTheme.titleLarge),
      titleMedium: pangolin(textStyle: textTheme.titleMedium),
      titleSmall: pangolin(textStyle: textTheme.titleSmall),
      bodyLarge: pangolin(textStyle: textTheme.bodyLarge),
      bodyMedium: pangolin(textStyle: textTheme.bodyMedium),
      bodySmall: pangolin(textStyle: textTheme.bodySmall),
      labelLarge: pangolin(textStyle: textTheme.labelLarge),
      labelMedium: pangolin(textStyle: textTheme.labelMedium),
      labelSmall: pangolin(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Paprika font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Paprika
  static TextStyle paprika({
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
        'cdc859602fb19edf32f73843607c44cdf3f883b594c9e8c08e10e32689b617ea',
        61548,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Paprika',
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

  /// Applies the Paprika font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Paprika
  static TextTheme paprikaTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: paprika(textStyle: textTheme.displayLarge),
      displayMedium: paprika(textStyle: textTheme.displayMedium),
      displaySmall: paprika(textStyle: textTheme.displaySmall),
      headlineLarge: paprika(textStyle: textTheme.headlineLarge),
      headlineMedium: paprika(textStyle: textTheme.headlineMedium),
      headlineSmall: paprika(textStyle: textTheme.headlineSmall),
      titleLarge: paprika(textStyle: textTheme.titleLarge),
      titleMedium: paprika(textStyle: textTheme.titleMedium),
      titleSmall: paprika(textStyle: textTheme.titleSmall),
      bodyLarge: paprika(textStyle: textTheme.bodyLarge),
      bodyMedium: paprika(textStyle: textTheme.bodyMedium),
      bodySmall: paprika(textStyle: textTheme.bodySmall),
      labelLarge: paprika(textStyle: textTheme.labelLarge),
      labelMedium: paprika(textStyle: textTheme.labelMedium),
      labelSmall: paprika(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Parastoo font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Parastoo
  static TextStyle parastoo({
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
        '07b8b214b35de808a826cd6bd19e6df11b57427da36ad2e5a8c3737a767f1c32',
        106972,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '93a6872b4101065de495768ea7e9f8adef0fbf1d831a048523704dcf6062f46f',
        107288,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'f8a53a19b40ccf90338610dfbd36137709ca9c3180db7196301f6c1d488d438a',
        107216,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'f10f69e174a7fc1163df0888e317cc3212b27b043d317afc81f7859da1d0c613',
        106584,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'f32c1185d6b7545f2b5955001c6220229c29d3162227f29cf1a417bad74662f5',
        165904,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Parastoo',
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

  /// Applies the Parastoo font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Parastoo
  static TextTheme parastooTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: parastoo(textStyle: textTheme.displayLarge),
      displayMedium: parastoo(textStyle: textTheme.displayMedium),
      displaySmall: parastoo(textStyle: textTheme.displaySmall),
      headlineLarge: parastoo(textStyle: textTheme.headlineLarge),
      headlineMedium: parastoo(textStyle: textTheme.headlineMedium),
      headlineSmall: parastoo(textStyle: textTheme.headlineSmall),
      titleLarge: parastoo(textStyle: textTheme.titleLarge),
      titleMedium: parastoo(textStyle: textTheme.titleMedium),
      titleSmall: parastoo(textStyle: textTheme.titleSmall),
      bodyLarge: parastoo(textStyle: textTheme.bodyLarge),
      bodyMedium: parastoo(textStyle: textTheme.bodyMedium),
      bodySmall: parastoo(textStyle: textTheme.bodySmall),
      labelLarge: parastoo(textStyle: textTheme.labelLarge),
      labelMedium: parastoo(textStyle: textTheme.labelMedium),
      labelSmall: parastoo(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Parisienne font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Parisienne
  static TextStyle parisienne({
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
        'ac30611f9658f44a04fd278374bc7292e2f5e5f1ab2fa013600994e749eede40',
        57172,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Parisienne',
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

  /// Applies the Parisienne font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Parisienne
  static TextTheme parisienneTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: parisienne(textStyle: textTheme.displayLarge),
      displayMedium: parisienne(textStyle: textTheme.displayMedium),
      displaySmall: parisienne(textStyle: textTheme.displaySmall),
      headlineLarge: parisienne(textStyle: textTheme.headlineLarge),
      headlineMedium: parisienne(textStyle: textTheme.headlineMedium),
      headlineSmall: parisienne(textStyle: textTheme.headlineSmall),
      titleLarge: parisienne(textStyle: textTheme.titleLarge),
      titleMedium: parisienne(textStyle: textTheme.titleMedium),
      titleSmall: parisienne(textStyle: textTheme.titleSmall),
      bodyLarge: parisienne(textStyle: textTheme.bodyLarge),
      bodyMedium: parisienne(textStyle: textTheme.bodyMedium),
      bodySmall: parisienne(textStyle: textTheme.bodySmall),
      labelLarge: parisienne(textStyle: textTheme.labelLarge),
      labelMedium: parisienne(textStyle: textTheme.labelMedium),
      labelSmall: parisienne(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Parkinsans font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Parkinsans
  static TextStyle parkinsans({
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
        '7337491122859f8e04a27aa74bd3692209c11edb415190bdf38724daa42f04a8',
        43844,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '0c2de174b6dfb304ec8f50eeb695179490ce33842f209f73491fc1150dc4ae64',
        43776,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'c098078a06f51f6340a3de3ab2f3d673082d18943834aa18f1255056c4f2b344',
        43812,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '5c8d1f0a7f04aab21be3629323ec04a8f44bb1e37cd64147a48a62ef85f6df48',
        43996,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'f52fe4138357e7a3c1e424fe7c45bdb213a7c176487a0d10de70aac2f359d671',
        43960,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '70bce0ce66e617dd4323d5df3c28504ea3c95e4e6eca8dcdcc3f2ab98dc6a38e',
        43984,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '8e0c16b0af88c9b90da636aa23858058b127132480ea44cde3ac62738e095ead',
        91264,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Parkinsans',
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

  /// Applies the Parkinsans font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Parkinsans
  static TextTheme parkinsansTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: parkinsans(textStyle: textTheme.displayLarge),
      displayMedium: parkinsans(textStyle: textTheme.displayMedium),
      displaySmall: parkinsans(textStyle: textTheme.displaySmall),
      headlineLarge: parkinsans(textStyle: textTheme.headlineLarge),
      headlineMedium: parkinsans(textStyle: textTheme.headlineMedium),
      headlineSmall: parkinsans(textStyle: textTheme.headlineSmall),
      titleLarge: parkinsans(textStyle: textTheme.titleLarge),
      titleMedium: parkinsans(textStyle: textTheme.titleMedium),
      titleSmall: parkinsans(textStyle: textTheme.titleSmall),
      bodyLarge: parkinsans(textStyle: textTheme.bodyLarge),
      bodyMedium: parkinsans(textStyle: textTheme.bodyMedium),
      bodySmall: parkinsans(textStyle: textTheme.bodySmall),
      labelLarge: parkinsans(textStyle: textTheme.labelLarge),
      labelMedium: parkinsans(textStyle: textTheme.labelMedium),
      labelSmall: parkinsans(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Passero One font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Passero+One
  static TextStyle passeroOne({
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
        '4fe71228388d12cd66ca85a1d816554a1f7c7d99c00f05e99aa67a86b91a2108',
        29796,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PasseroOne',
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

  /// Applies the Passero One font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Passero+One
  static TextTheme passeroOneTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: passeroOne(textStyle: textTheme.displayLarge),
      displayMedium: passeroOne(textStyle: textTheme.displayMedium),
      displaySmall: passeroOne(textStyle: textTheme.displaySmall),
      headlineLarge: passeroOne(textStyle: textTheme.headlineLarge),
      headlineMedium: passeroOne(textStyle: textTheme.headlineMedium),
      headlineSmall: passeroOne(textStyle: textTheme.headlineSmall),
      titleLarge: passeroOne(textStyle: textTheme.titleLarge),
      titleMedium: passeroOne(textStyle: textTheme.titleMedium),
      titleSmall: passeroOne(textStyle: textTheme.titleSmall),
      bodyLarge: passeroOne(textStyle: textTheme.bodyLarge),
      bodyMedium: passeroOne(textStyle: textTheme.bodyMedium),
      bodySmall: passeroOne(textStyle: textTheme.bodySmall),
      labelLarge: passeroOne(textStyle: textTheme.labelLarge),
      labelMedium: passeroOne(textStyle: textTheme.labelMedium),
      labelSmall: passeroOne(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Passion One font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Passion+One
  static TextStyle passionOne({
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
        'f2176b5df30b0255fac1746e9e21abba08fb801a0b2bdd29d857c7037f2b27e4',
        22532,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '7e35b119f0f4a2bb20fa0710a2ecb30e164992269db29ef2d55365c09be5dc77',
        22332,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'c62a47c8617e4fc1760a66c4856467b46f132d1555817d3e94737af412a43425',
        21832,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PassionOne',
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

  /// Applies the Passion One font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Passion+One
  static TextTheme passionOneTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: passionOne(textStyle: textTheme.displayLarge),
      displayMedium: passionOne(textStyle: textTheme.displayMedium),
      displaySmall: passionOne(textStyle: textTheme.displaySmall),
      headlineLarge: passionOne(textStyle: textTheme.headlineLarge),
      headlineMedium: passionOne(textStyle: textTheme.headlineMedium),
      headlineSmall: passionOne(textStyle: textTheme.headlineSmall),
      titleLarge: passionOne(textStyle: textTheme.titleLarge),
      titleMedium: passionOne(textStyle: textTheme.titleMedium),
      titleSmall: passionOne(textStyle: textTheme.titleSmall),
      bodyLarge: passionOne(textStyle: textTheme.bodyLarge),
      bodyMedium: passionOne(textStyle: textTheme.bodyMedium),
      bodySmall: passionOne(textStyle: textTheme.bodySmall),
      labelLarge: passionOne(textStyle: textTheme.labelLarge),
      labelMedium: passionOne(textStyle: textTheme.labelMedium),
      labelSmall: passionOne(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Passions Conflict font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Passions+Conflict
  static TextStyle passionsConflict({
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
        '3da50f2077276ddb430d2d60e09d3dd5448e47b4590ea6e9160f8340f55780fc',
        97564,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PassionsConflict',
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

  /// Applies the Passions Conflict font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Passions+Conflict
  static TextTheme passionsConflictTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: passionsConflict(textStyle: textTheme.displayLarge),
      displayMedium: passionsConflict(textStyle: textTheme.displayMedium),
      displaySmall: passionsConflict(textStyle: textTheme.displaySmall),
      headlineLarge: passionsConflict(textStyle: textTheme.headlineLarge),
      headlineMedium: passionsConflict(textStyle: textTheme.headlineMedium),
      headlineSmall: passionsConflict(textStyle: textTheme.headlineSmall),
      titleLarge: passionsConflict(textStyle: textTheme.titleLarge),
      titleMedium: passionsConflict(textStyle: textTheme.titleMedium),
      titleSmall: passionsConflict(textStyle: textTheme.titleSmall),
      bodyLarge: passionsConflict(textStyle: textTheme.bodyLarge),
      bodyMedium: passionsConflict(textStyle: textTheme.bodyMedium),
      bodySmall: passionsConflict(textStyle: textTheme.bodySmall),
      labelLarge: passionsConflict(textStyle: textTheme.labelLarge),
      labelMedium: passionsConflict(textStyle: textTheme.labelMedium),
      labelSmall: passionsConflict(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Pathway Extreme font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Pathway+Extreme
  static TextStyle pathwayExtreme({
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
        '96912989143b69e5080a817304e244cc413ae0489fcf285024bb701c5bc7ddce',
        71248,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '03c1e2e37191b43b863ae1035cb317cd03f1b81e6f86587e10a1b1119a87143b',
        71260,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '77a9d8cec9a54b6e09859d2a2a9ad9a8f1eacbafcd987b25905f13df01f8dde7',
        71260,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'e4932509b5f4d7b53c623f5827ca363d4cb53bc740cc4d33070cf39cf6568d05',
        71252,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '39c997f8999582ec7c921f7056867f517a78a4c646639bb8c596035d245fa39a',
        71300,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '197130e63fc717874a61b1036b05c83992a096629b2649d273ea2bb02a7a12a8',
        71308,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'c8dab7ddec322b2fb47ca49ba961e64e7a576360b31ad90f307733f79a479aa9',
        71260,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'b0e2a2a5d6414d43912c27b4d48ee6c0d0fa1df07268d81e323b606c16c860c0',
        71384,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '8802622b1f3e804394627e6931f264351b33d1ae40bac10ae2dc460c1c3059fe',
        70764,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w100,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '203dca13a52cf2c5adff3888eb86d011ddc18430785756e81b9a7cc343ef42ec',
        54148,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '0905f4dc75083d660d258d4a946abac7b05b97e19b7f60bbdc2b1e5e2f2411db',
        54184,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '8c7b57481023d23eec945966b44a68fb769221536c630d6082ad448203923e70',
        54152,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'ac2bff112833210f1d47e5e721b3be1d6de588cba40d787b1330787fcc2b011a',
        54048,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '8c1cedf6e9d64d235092d3aa0ae5471d78ba686df231a4db7742892efd0429f8',
        54188,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '8c1c954d15d919c7c8532bc35ad2f4cacade2d844270deea363672e7bf452912',
        54240,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'ff69a476818c6377e46cbdcceafc71f92ec5ef8f6255e919ac515d86742bf7f4',
        54164,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '46955d7450ee80fe60857070e89a9c5227ff9d2302f4305b6f172aee14c95fd1',
        54356,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '0573aca103ed6cc5accfe7d7169aa22adf35137eac0129bb5b9ce2520638f39a',
        53760,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'c3abb7612e7583c48e7ed7e76e7021ec278832df1b101655c700afa2f9a78bc5',
        281392,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'a5a8f42f6ab9da34693740d1750afa71461ce29da4043a8eb94b0d7ff25f008b',
        202136,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PathwayExtreme',
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

  /// Applies the Pathway Extreme font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Pathway+Extreme
  static TextTheme pathwayExtremeTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: pathwayExtreme(textStyle: textTheme.displayLarge),
      displayMedium: pathwayExtreme(textStyle: textTheme.displayMedium),
      displaySmall: pathwayExtreme(textStyle: textTheme.displaySmall),
      headlineLarge: pathwayExtreme(textStyle: textTheme.headlineLarge),
      headlineMedium: pathwayExtreme(textStyle: textTheme.headlineMedium),
      headlineSmall: pathwayExtreme(textStyle: textTheme.headlineSmall),
      titleLarge: pathwayExtreme(textStyle: textTheme.titleLarge),
      titleMedium: pathwayExtreme(textStyle: textTheme.titleMedium),
      titleSmall: pathwayExtreme(textStyle: textTheme.titleSmall),
      bodyLarge: pathwayExtreme(textStyle: textTheme.bodyLarge),
      bodyMedium: pathwayExtreme(textStyle: textTheme.bodyMedium),
      bodySmall: pathwayExtreme(textStyle: textTheme.bodySmall),
      labelLarge: pathwayExtreme(textStyle: textTheme.labelLarge),
      labelMedium: pathwayExtreme(textStyle: textTheme.labelMedium),
      labelSmall: pathwayExtreme(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Pathway Gothic One font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Pathway+Gothic+One
  static TextStyle pathwayGothicOne({
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
        'baabfaf530d983b373d8a738e84ca669ca1256b0c44a6ccaadb54d45e32251b3',
        32260,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PathwayGothicOne',
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

  /// Applies the Pathway Gothic One font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Pathway+Gothic+One
  static TextTheme pathwayGothicOneTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: pathwayGothicOne(textStyle: textTheme.displayLarge),
      displayMedium: pathwayGothicOne(textStyle: textTheme.displayMedium),
      displaySmall: pathwayGothicOne(textStyle: textTheme.displaySmall),
      headlineLarge: pathwayGothicOne(textStyle: textTheme.headlineLarge),
      headlineMedium: pathwayGothicOne(textStyle: textTheme.headlineMedium),
      headlineSmall: pathwayGothicOne(textStyle: textTheme.headlineSmall),
      titleLarge: pathwayGothicOne(textStyle: textTheme.titleLarge),
      titleMedium: pathwayGothicOne(textStyle: textTheme.titleMedium),
      titleSmall: pathwayGothicOne(textStyle: textTheme.titleSmall),
      bodyLarge: pathwayGothicOne(textStyle: textTheme.bodyLarge),
      bodyMedium: pathwayGothicOne(textStyle: textTheme.bodyMedium),
      bodySmall: pathwayGothicOne(textStyle: textTheme.bodySmall),
      labelLarge: pathwayGothicOne(textStyle: textTheme.labelLarge),
      labelMedium: pathwayGothicOne(textStyle: textTheme.labelMedium),
      labelSmall: pathwayGothicOne(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Patrick Hand font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Patrick+Hand
  static TextStyle patrickHand({
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
        '309ba7d5200f03efa6c3d747d7ad47a5a354464ae0a6ffcb02c747286bc50964',
        81712,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PatrickHand',
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

  /// Applies the Patrick Hand font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Patrick+Hand
  static TextTheme patrickHandTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: patrickHand(textStyle: textTheme.displayLarge),
      displayMedium: patrickHand(textStyle: textTheme.displayMedium),
      displaySmall: patrickHand(textStyle: textTheme.displaySmall),
      headlineLarge: patrickHand(textStyle: textTheme.headlineLarge),
      headlineMedium: patrickHand(textStyle: textTheme.headlineMedium),
      headlineSmall: patrickHand(textStyle: textTheme.headlineSmall),
      titleLarge: patrickHand(textStyle: textTheme.titleLarge),
      titleMedium: patrickHand(textStyle: textTheme.titleMedium),
      titleSmall: patrickHand(textStyle: textTheme.titleSmall),
      bodyLarge: patrickHand(textStyle: textTheme.bodyLarge),
      bodyMedium: patrickHand(textStyle: textTheme.bodyMedium),
      bodySmall: patrickHand(textStyle: textTheme.bodySmall),
      labelLarge: patrickHand(textStyle: textTheme.labelLarge),
      labelMedium: patrickHand(textStyle: textTheme.labelMedium),
      labelSmall: patrickHand(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Patrick Hand SC font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Patrick+Hand+SC
  static TextStyle patrickHandSc({
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
        '3017032681334eb2567923be94945c423aa3a3f666a12b8fff2ebcfe56365a8a',
        80644,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PatrickHandSC',
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

  /// Applies the Patrick Hand SC font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Patrick+Hand+SC
  static TextTheme patrickHandScTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: patrickHandSc(textStyle: textTheme.displayLarge),
      displayMedium: patrickHandSc(textStyle: textTheme.displayMedium),
      displaySmall: patrickHandSc(textStyle: textTheme.displaySmall),
      headlineLarge: patrickHandSc(textStyle: textTheme.headlineLarge),
      headlineMedium: patrickHandSc(textStyle: textTheme.headlineMedium),
      headlineSmall: patrickHandSc(textStyle: textTheme.headlineSmall),
      titleLarge: patrickHandSc(textStyle: textTheme.titleLarge),
      titleMedium: patrickHandSc(textStyle: textTheme.titleMedium),
      titleSmall: patrickHandSc(textStyle: textTheme.titleSmall),
      bodyLarge: patrickHandSc(textStyle: textTheme.bodyLarge),
      bodyMedium: patrickHandSc(textStyle: textTheme.bodyMedium),
      bodySmall: patrickHandSc(textStyle: textTheme.bodySmall),
      labelLarge: patrickHandSc(textStyle: textTheme.labelLarge),
      labelMedium: patrickHandSc(textStyle: textTheme.labelMedium),
      labelSmall: patrickHandSc(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Pattaya font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Pattaya
  static TextStyle pattaya({
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
        '01923c8b76276fa44609912b0aba62665cd0bfa0b62171329c6ac162e18dca99',
        204156,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Pattaya',
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

  /// Applies the Pattaya font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Pattaya
  static TextTheme pattayaTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: pattaya(textStyle: textTheme.displayLarge),
      displayMedium: pattaya(textStyle: textTheme.displayMedium),
      displaySmall: pattaya(textStyle: textTheme.displaySmall),
      headlineLarge: pattaya(textStyle: textTheme.headlineLarge),
      headlineMedium: pattaya(textStyle: textTheme.headlineMedium),
      headlineSmall: pattaya(textStyle: textTheme.headlineSmall),
      titleLarge: pattaya(textStyle: textTheme.titleLarge),
      titleMedium: pattaya(textStyle: textTheme.titleMedium),
      titleSmall: pattaya(textStyle: textTheme.titleSmall),
      bodyLarge: pattaya(textStyle: textTheme.bodyLarge),
      bodyMedium: pattaya(textStyle: textTheme.bodyMedium),
      bodySmall: pattaya(textStyle: textTheme.bodySmall),
      labelLarge: pattaya(textStyle: textTheme.labelLarge),
      labelMedium: pattaya(textStyle: textTheme.labelMedium),
      labelSmall: pattaya(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Patua One font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Patua+One
  static TextStyle patuaOne({
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
        '22dcea47f5aae25798deb8ab26ca2af353f88af63719b0b788fbc4d59767b1d0',
        33312,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PatuaOne',
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

  /// Applies the Patua One font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Patua+One
  static TextTheme patuaOneTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: patuaOne(textStyle: textTheme.displayLarge),
      displayMedium: patuaOne(textStyle: textTheme.displayMedium),
      displaySmall: patuaOne(textStyle: textTheme.displaySmall),
      headlineLarge: patuaOne(textStyle: textTheme.headlineLarge),
      headlineMedium: patuaOne(textStyle: textTheme.headlineMedium),
      headlineSmall: patuaOne(textStyle: textTheme.headlineSmall),
      titleLarge: patuaOne(textStyle: textTheme.titleLarge),
      titleMedium: patuaOne(textStyle: textTheme.titleMedium),
      titleSmall: patuaOne(textStyle: textTheme.titleSmall),
      bodyLarge: patuaOne(textStyle: textTheme.bodyLarge),
      bodyMedium: patuaOne(textStyle: textTheme.bodyMedium),
      bodySmall: patuaOne(textStyle: textTheme.bodySmall),
      labelLarge: patuaOne(textStyle: textTheme.labelLarge),
      labelMedium: patuaOne(textStyle: textTheme.labelMedium),
      labelSmall: patuaOne(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Pavanam font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Pavanam
  static TextStyle pavanam({
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
        '1721bec23badfcf8526cc5b2fe74fbff683ef8f2228e985302382beb422a53f6',
        46768,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Pavanam',
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

  /// Applies the Pavanam font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Pavanam
  static TextTheme pavanamTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: pavanam(textStyle: textTheme.displayLarge),
      displayMedium: pavanam(textStyle: textTheme.displayMedium),
      displaySmall: pavanam(textStyle: textTheme.displaySmall),
      headlineLarge: pavanam(textStyle: textTheme.headlineLarge),
      headlineMedium: pavanam(textStyle: textTheme.headlineMedium),
      headlineSmall: pavanam(textStyle: textTheme.headlineSmall),
      titleLarge: pavanam(textStyle: textTheme.titleLarge),
      titleMedium: pavanam(textStyle: textTheme.titleMedium),
      titleSmall: pavanam(textStyle: textTheme.titleSmall),
      bodyLarge: pavanam(textStyle: textTheme.bodyLarge),
      bodyMedium: pavanam(textStyle: textTheme.bodyMedium),
      bodySmall: pavanam(textStyle: textTheme.bodySmall),
      labelLarge: pavanam(textStyle: textTheme.labelLarge),
      labelMedium: pavanam(textStyle: textTheme.labelMedium),
      labelSmall: pavanam(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Paytone One font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Paytone+One
  static TextStyle paytoneOne({
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
        '45e24958cce8aac961fed07633e51429bffdc071a54bd3c494539257bf3122ae',
        79148,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PaytoneOne',
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

  /// Applies the Paytone One font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Paytone+One
  static TextTheme paytoneOneTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: paytoneOne(textStyle: textTheme.displayLarge),
      displayMedium: paytoneOne(textStyle: textTheme.displayMedium),
      displaySmall: paytoneOne(textStyle: textTheme.displaySmall),
      headlineLarge: paytoneOne(textStyle: textTheme.headlineLarge),
      headlineMedium: paytoneOne(textStyle: textTheme.headlineMedium),
      headlineSmall: paytoneOne(textStyle: textTheme.headlineSmall),
      titleLarge: paytoneOne(textStyle: textTheme.titleLarge),
      titleMedium: paytoneOne(textStyle: textTheme.titleMedium),
      titleSmall: paytoneOne(textStyle: textTheme.titleSmall),
      bodyLarge: paytoneOne(textStyle: textTheme.bodyLarge),
      bodyMedium: paytoneOne(textStyle: textTheme.bodyMedium),
      bodySmall: paytoneOne(textStyle: textTheme.bodySmall),
      labelLarge: paytoneOne(textStyle: textTheme.labelLarge),
      labelMedium: paytoneOne(textStyle: textTheme.labelMedium),
      labelSmall: paytoneOne(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Peddana font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Peddana
  static TextStyle peddana({
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
        '61cbf23b0a1e9885b15880791511fea5e533ad069f3199d8890b21f390011609',
        439344,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Peddana',
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

  /// Applies the Peddana font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Peddana
  static TextTheme peddanaTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: peddana(textStyle: textTheme.displayLarge),
      displayMedium: peddana(textStyle: textTheme.displayMedium),
      displaySmall: peddana(textStyle: textTheme.displaySmall),
      headlineLarge: peddana(textStyle: textTheme.headlineLarge),
      headlineMedium: peddana(textStyle: textTheme.headlineMedium),
      headlineSmall: peddana(textStyle: textTheme.headlineSmall),
      titleLarge: peddana(textStyle: textTheme.titleLarge),
      titleMedium: peddana(textStyle: textTheme.titleMedium),
      titleSmall: peddana(textStyle: textTheme.titleSmall),
      bodyLarge: peddana(textStyle: textTheme.bodyLarge),
      bodyMedium: peddana(textStyle: textTheme.bodyMedium),
      bodySmall: peddana(textStyle: textTheme.bodySmall),
      labelLarge: peddana(textStyle: textTheme.labelLarge),
      labelMedium: peddana(textStyle: textTheme.labelMedium),
      labelSmall: peddana(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Peralta font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Peralta
  static TextStyle peralta({
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
        '1c0f5580edc0cdaa240bf58a267658652ba893a955a438c17e452fa1db350552',
        56856,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Peralta',
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

  /// Applies the Peralta font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Peralta
  static TextTheme peraltaTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: peralta(textStyle: textTheme.displayLarge),
      displayMedium: peralta(textStyle: textTheme.displayMedium),
      displaySmall: peralta(textStyle: textTheme.displaySmall),
      headlineLarge: peralta(textStyle: textTheme.headlineLarge),
      headlineMedium: peralta(textStyle: textTheme.headlineMedium),
      headlineSmall: peralta(textStyle: textTheme.headlineSmall),
      titleLarge: peralta(textStyle: textTheme.titleLarge),
      titleMedium: peralta(textStyle: textTheme.titleMedium),
      titleSmall: peralta(textStyle: textTheme.titleSmall),
      bodyLarge: peralta(textStyle: textTheme.bodyLarge),
      bodyMedium: peralta(textStyle: textTheme.bodyMedium),
      bodySmall: peralta(textStyle: textTheme.bodySmall),
      labelLarge: peralta(textStyle: textTheme.labelLarge),
      labelMedium: peralta(textStyle: textTheme.labelMedium),
      labelSmall: peralta(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Permanent Marker font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Permanent+Marker
  static TextStyle permanentMarker({
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
        'a96da3e1e3ae127eaecf81d137f7a017e14753955bf2449763b6b4118f98df12',
        72860,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PermanentMarker',
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

  /// Applies the Permanent Marker font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Permanent+Marker
  static TextTheme permanentMarkerTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: permanentMarker(textStyle: textTheme.displayLarge),
      displayMedium: permanentMarker(textStyle: textTheme.displayMedium),
      displaySmall: permanentMarker(textStyle: textTheme.displaySmall),
      headlineLarge: permanentMarker(textStyle: textTheme.headlineLarge),
      headlineMedium: permanentMarker(textStyle: textTheme.headlineMedium),
      headlineSmall: permanentMarker(textStyle: textTheme.headlineSmall),
      titleLarge: permanentMarker(textStyle: textTheme.titleLarge),
      titleMedium: permanentMarker(textStyle: textTheme.titleMedium),
      titleSmall: permanentMarker(textStyle: textTheme.titleSmall),
      bodyLarge: permanentMarker(textStyle: textTheme.bodyLarge),
      bodyMedium: permanentMarker(textStyle: textTheme.bodyMedium),
      bodySmall: permanentMarker(textStyle: textTheme.bodySmall),
      labelLarge: permanentMarker(textStyle: textTheme.labelLarge),
      labelMedium: permanentMarker(textStyle: textTheme.labelMedium),
      labelSmall: permanentMarker(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Petemoss font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Petemoss
  static TextStyle petemoss({
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
        'c6b65b149f45c8ef86d51ba05ab2dad45c580a9ec9edba364c9fe60874dc37fd',
        86072,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Petemoss',
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

  /// Applies the Petemoss font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Petemoss
  static TextTheme petemossTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: petemoss(textStyle: textTheme.displayLarge),
      displayMedium: petemoss(textStyle: textTheme.displayMedium),
      displaySmall: petemoss(textStyle: textTheme.displaySmall),
      headlineLarge: petemoss(textStyle: textTheme.headlineLarge),
      headlineMedium: petemoss(textStyle: textTheme.headlineMedium),
      headlineSmall: petemoss(textStyle: textTheme.headlineSmall),
      titleLarge: petemoss(textStyle: textTheme.titleLarge),
      titleMedium: petemoss(textStyle: textTheme.titleMedium),
      titleSmall: petemoss(textStyle: textTheme.titleSmall),
      bodyLarge: petemoss(textStyle: textTheme.bodyLarge),
      bodyMedium: petemoss(textStyle: textTheme.bodyMedium),
      bodySmall: petemoss(textStyle: textTheme.bodySmall),
      labelLarge: petemoss(textStyle: textTheme.labelLarge),
      labelMedium: petemoss(textStyle: textTheme.labelMedium),
      labelSmall: petemoss(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Petit Formal Script font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Petit+Formal+Script
  static TextStyle petitFormalScript({
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
        '0efc3d4163f42ed319e0ea770c0d6c006be374cc3c665057f6b96e5d1f345062',
        110204,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PetitFormalScript',
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

  /// Applies the Petit Formal Script font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Petit+Formal+Script
  static TextTheme petitFormalScriptTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: petitFormalScript(textStyle: textTheme.displayLarge),
      displayMedium: petitFormalScript(textStyle: textTheme.displayMedium),
      displaySmall: petitFormalScript(textStyle: textTheme.displaySmall),
      headlineLarge: petitFormalScript(textStyle: textTheme.headlineLarge),
      headlineMedium: petitFormalScript(textStyle: textTheme.headlineMedium),
      headlineSmall: petitFormalScript(textStyle: textTheme.headlineSmall),
      titleLarge: petitFormalScript(textStyle: textTheme.titleLarge),
      titleMedium: petitFormalScript(textStyle: textTheme.titleMedium),
      titleSmall: petitFormalScript(textStyle: textTheme.titleSmall),
      bodyLarge: petitFormalScript(textStyle: textTheme.bodyLarge),
      bodyMedium: petitFormalScript(textStyle: textTheme.bodyMedium),
      bodySmall: petitFormalScript(textStyle: textTheme.bodySmall),
      labelLarge: petitFormalScript(textStyle: textTheme.labelLarge),
      labelMedium: petitFormalScript(textStyle: textTheme.labelMedium),
      labelSmall: petitFormalScript(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Petrona font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Petrona
  static TextStyle petrona({
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
        '543c33083152247faf0e8775c157ec23ac3962d7e42dfd5cdc6bdb5ec0b04ed1',
        70500,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'b9449d6b40564c020327d59d72dd54bef0db5ded7872982a5c70197f5312ac8f',
        70960,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '3fd3dbbdde07fd861674de2dea1084a2c43dc5e12e2864017abcd92a18a0968b',
        70888,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '893b40227be3c91bcb79b4a06054508dd6cd451f5a83a4888d30d3c7313d4f74',
        70824,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '24c7d8a35e44ce7c55d92253ec79aef7f77d24a98d51ca7057f1d174efc4be29',
        70884,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '734569d3fb4d906ce1b1ca0635104571ca078c37ad409f813e80161e36db9730',
        71244,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '54dfe5afe6a5aaae7409788d33ac23d08e225944caf199f1243ec15ed1d62c4d',
        71240,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'e838b73472b7cc040fa90062e16594e01499b203feb929ae5c59b1dc6426b5a3',
        71272,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'cc6bc0f7bb55896c042e880b76d06378e8d149bb064588fdb70a9145b0f027c8',
        71132,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w100,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'b452e62628a470d7dd2e5d81c10287df2c2996577f3b5d7dde273d9397d635ad',
        74992,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'fb1be1a04cfa07997dd9c40a24b82c272cbe6e2f8a32e652b350e7e16507d405',
        75880,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'e7103640954918079b7a0d533b2dbb4d85116ed3b7d8f7385451792a959c19fc',
        75904,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'acda44878099a25b654df2d2ab078d347214874df460af45d4291cec2787e987',
        75900,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'ec395cf67328a947cb0dcbdb48f3a5a65e531decaec18af37eba883ef25554c7',
        75988,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '200ad849de07954180e17bba303ec266ac776bf02c9475006cdc20b07345966b',
        76276,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '4255de23b3be238ce1e3601e145fbc771cb7958331b3044681026e9acba7a81f',
        76220,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'e581fbbe97058aa4e4a094a7bcdb4771525dbe8ea05ab974a29f06a8ff3b8fb4',
        76284,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'c633f33bf0dde7ae5e5a02bed39b85e5145edc2bff6f5092a5e23cd9643fc627',
        76100,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'b9c13c1aba407185cba43b4e8fe97744d18fa55712109090d4993ae31fa9c54d',
        136036,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '938fc6fbe7c3604febe09a77dfe22473a34a5575e9e8bd1c835bdb07aea9360f',
        147772,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Petrona',
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

  /// Applies the Petrona font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Petrona
  static TextTheme petronaTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: petrona(textStyle: textTheme.displayLarge),
      displayMedium: petrona(textStyle: textTheme.displayMedium),
      displaySmall: petrona(textStyle: textTheme.displaySmall),
      headlineLarge: petrona(textStyle: textTheme.headlineLarge),
      headlineMedium: petrona(textStyle: textTheme.headlineMedium),
      headlineSmall: petrona(textStyle: textTheme.headlineSmall),
      titleLarge: petrona(textStyle: textTheme.titleLarge),
      titleMedium: petrona(textStyle: textTheme.titleMedium),
      titleSmall: petrona(textStyle: textTheme.titleSmall),
      bodyLarge: petrona(textStyle: textTheme.bodyLarge),
      bodyMedium: petrona(textStyle: textTheme.bodyMedium),
      bodySmall: petrona(textStyle: textTheme.bodySmall),
      labelLarge: petrona(textStyle: textTheme.labelLarge),
      labelMedium: petrona(textStyle: textTheme.labelMedium),
      labelSmall: petrona(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Phetsarath font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Phetsarath
  static TextStyle phetsarath({
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
        '1f9d8ffad78e90a2dc8e8e9057d0cd2a59e63939eecea586b84ca6d07ef193d9',
        29584,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'dae4dfa1042134857fac45019b28926119003d358e38c5f7b4905f23f53b4a08',
        28652,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Phetsarath',
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

  /// Applies the Phetsarath font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Phetsarath
  static TextTheme phetsarathTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: phetsarath(textStyle: textTheme.displayLarge),
      displayMedium: phetsarath(textStyle: textTheme.displayMedium),
      displaySmall: phetsarath(textStyle: textTheme.displaySmall),
      headlineLarge: phetsarath(textStyle: textTheme.headlineLarge),
      headlineMedium: phetsarath(textStyle: textTheme.headlineMedium),
      headlineSmall: phetsarath(textStyle: textTheme.headlineSmall),
      titleLarge: phetsarath(textStyle: textTheme.titleLarge),
      titleMedium: phetsarath(textStyle: textTheme.titleMedium),
      titleSmall: phetsarath(textStyle: textTheme.titleSmall),
      bodyLarge: phetsarath(textStyle: textTheme.bodyLarge),
      bodyMedium: phetsarath(textStyle: textTheme.bodyMedium),
      bodySmall: phetsarath(textStyle: textTheme.bodySmall),
      labelLarge: phetsarath(textStyle: textTheme.labelLarge),
      labelMedium: phetsarath(textStyle: textTheme.labelMedium),
      labelSmall: phetsarath(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Philosopher font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Philosopher
  static TextStyle philosopher({
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
        '5a728cdf93ac5e834c97256e292ddceafb0855f840506df26476c8a7936a583b',
        71632,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '63ae23fa96aeb9264bae9c6f5119a025241b3ed9128ed07ae7db22a7f36d414a',
        79260,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'ea9f950189c424a2f8be5ac27639286229dfbf4acbdcc482c626c83f0797abea',
        71472,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '92ecf828c81ab017b82747ce21ee474859825b17de11ddcb221b11ef58bbc097',
        80064,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Philosopher',
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

  /// Applies the Philosopher font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Philosopher
  static TextTheme philosopherTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: philosopher(textStyle: textTheme.displayLarge),
      displayMedium: philosopher(textStyle: textTheme.displayMedium),
      displaySmall: philosopher(textStyle: textTheme.displaySmall),
      headlineLarge: philosopher(textStyle: textTheme.headlineLarge),
      headlineMedium: philosopher(textStyle: textTheme.headlineMedium),
      headlineSmall: philosopher(textStyle: textTheme.headlineSmall),
      titleLarge: philosopher(textStyle: textTheme.titleLarge),
      titleMedium: philosopher(textStyle: textTheme.titleMedium),
      titleSmall: philosopher(textStyle: textTheme.titleSmall),
      bodyLarge: philosopher(textStyle: textTheme.bodyLarge),
      bodyMedium: philosopher(textStyle: textTheme.bodyMedium),
      bodySmall: philosopher(textStyle: textTheme.bodySmall),
      labelLarge: philosopher(textStyle: textTheme.labelLarge),
      labelMedium: philosopher(textStyle: textTheme.labelMedium),
      labelSmall: philosopher(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Phudu font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Phudu
  static TextStyle phudu({
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
        'a1cbc0810e332a1e4a206516925db19b11f9602121a4744d9064c6e3f565459a',
        64348,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '0bc6f2d14c53a131e85fbd140f9eaf370a848e43397daa0ab240230455577d84',
        64268,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '5503681a01295b91dc84aad884f0767c8041622c0926cad72472877214393a71',
        64316,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '8edb108623e78001f91d63eb90fc26c3ef483c7762829a42d45e9815fa6640f1',
        64304,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'bfad6bde11abdde125bacfb3c102cff144927a2712183d24e67afe891f4aa7a6',
        63628,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '9be27834704d9fc795a4e0ec7b9a4f5c949641c8624440c7b59037e9a2d75838',
        64348,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'f29c99be19179d417121bbddc1a59a8bffebeee23ef77222ab078049231b946a',
        64344,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '0ce103b0d263f44e0a74916f6b86f59b37a51a02ca9290f8bf573ebfb808b769',
        127792,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Phudu',
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

  /// Applies the Phudu font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Phudu
  static TextTheme phuduTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: phudu(textStyle: textTheme.displayLarge),
      displayMedium: phudu(textStyle: textTheme.displayMedium),
      displaySmall: phudu(textStyle: textTheme.displaySmall),
      headlineLarge: phudu(textStyle: textTheme.headlineLarge),
      headlineMedium: phudu(textStyle: textTheme.headlineMedium),
      headlineSmall: phudu(textStyle: textTheme.headlineSmall),
      titleLarge: phudu(textStyle: textTheme.titleLarge),
      titleMedium: phudu(textStyle: textTheme.titleMedium),
      titleSmall: phudu(textStyle: textTheme.titleSmall),
      bodyLarge: phudu(textStyle: textTheme.bodyLarge),
      bodyMedium: phudu(textStyle: textTheme.bodyMedium),
      bodySmall: phudu(textStyle: textTheme.bodySmall),
      labelLarge: phudu(textStyle: textTheme.labelLarge),
      labelMedium: phudu(textStyle: textTheme.labelMedium),
      labelSmall: phudu(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Piazzolla font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Piazzolla
  static TextStyle piazzolla({
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
        'e8f966ce1c959b360ff3f21415eea7a4a6bc61c70f80e49eef16bb691389f22d',
        135808,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '088867a75449edea8520b5ae1d7d74656931ce6bb250428ab87821782265163a',
        135884,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '554cbdff28765cb8a327154fc151b24aa520642734a73812529e7e4f964cef26',
        135940,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '0c15f4d5a357a4817a995b4d209b93f344be8840299938310625003f0de7c136',
        135956,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '0f92320926ddea5deae487128bf966e28136ec21e50fef5edbcf92b073b57caf',
        136064,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '8a4f53132a7d136f8e2aa1321bb88ee1410d8c695f440fe4d866afbd3bb28c78',
        136160,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'd81568b2b266f1c7c793a4e68d421876ef1c42739ef5375eed2e56ab479e68ef',
        137972,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'a8300d02c12824e22998fd7c3badcb4de47413a7d5f91c064b086722e131df4b',
        138100,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'd301670a10eb22b9f479976b0dafd787bfc57b52394dc5e2a1b671001e28c96f',
        138188,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w100,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'c52398585aa30ffb13c523d7976b9ae9fe60c758679f536f3de9cf30c3ca226e',
        137060,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'bb35d9a126749fc8bf7dfce45aa5417549b54b9bd3a9b4fa5cb620c0a82071a6',
        137224,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'bf739a76acce110b2fab5abc1fb6800368ad5cf6026809ca9ab96ac9c6579742',
        137232,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '3951f3c8ff1503d410123dcc3d3b6ffdfc1f16e932fdfa74595d434b2787b7ab',
        137084,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'bcc4c157611f3462b9f5356a302967e106ed41de1e056369b3aac4f50fc511aa',
        137640,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'de4b743f7fb31935b20dd7880b0e6dea34ec4b327ae73acb12562b0f20732045',
        137736,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '01aecae9202359a0f7249f18e3d3aefc33e176207ddbc375a503ebb18452c2b7',
        139268,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '016049da50262136a32a432fb073e68f1f5fb0d183ff5d31e6503729726bb502',
        139396,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '8cb6b1e3eed1af94466c23bf52d003e419c45fe14317451a92ef39b44fe9c0b5',
        139396,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'a7dc5cb3881902baa8f21f4d3d7eaa7b2af8cb69184356ced5199b5c2cbde66f',
        336868,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '00dc83b70d62f6ed2116a6cda8740d9ff6964f3fb16a049f811bfc2e86386cb0',
        343404,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Piazzolla',
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

  /// Applies the Piazzolla font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Piazzolla
  static TextTheme piazzollaTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: piazzolla(textStyle: textTheme.displayLarge),
      displayMedium: piazzolla(textStyle: textTheme.displayMedium),
      displaySmall: piazzolla(textStyle: textTheme.displaySmall),
      headlineLarge: piazzolla(textStyle: textTheme.headlineLarge),
      headlineMedium: piazzolla(textStyle: textTheme.headlineMedium),
      headlineSmall: piazzolla(textStyle: textTheme.headlineSmall),
      titleLarge: piazzolla(textStyle: textTheme.titleLarge),
      titleMedium: piazzolla(textStyle: textTheme.titleMedium),
      titleSmall: piazzolla(textStyle: textTheme.titleSmall),
      bodyLarge: piazzolla(textStyle: textTheme.bodyLarge),
      bodyMedium: piazzolla(textStyle: textTheme.bodyMedium),
      bodySmall: piazzolla(textStyle: textTheme.bodySmall),
      labelLarge: piazzolla(textStyle: textTheme.labelLarge),
      labelMedium: piazzolla(textStyle: textTheme.labelMedium),
      labelSmall: piazzolla(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Piedra font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Piedra
  static TextStyle piedra({
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
        'e6723b2f515c20ab95775753ac7ac4643d0773f784c5b01b6f38c75e73ff15d8',
        73968,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Piedra',
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

  /// Applies the Piedra font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Piedra
  static TextTheme piedraTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: piedra(textStyle: textTheme.displayLarge),
      displayMedium: piedra(textStyle: textTheme.displayMedium),
      displaySmall: piedra(textStyle: textTheme.displaySmall),
      headlineLarge: piedra(textStyle: textTheme.headlineLarge),
      headlineMedium: piedra(textStyle: textTheme.headlineMedium),
      headlineSmall: piedra(textStyle: textTheme.headlineSmall),
      titleLarge: piedra(textStyle: textTheme.titleLarge),
      titleMedium: piedra(textStyle: textTheme.titleMedium),
      titleSmall: piedra(textStyle: textTheme.titleSmall),
      bodyLarge: piedra(textStyle: textTheme.bodyLarge),
      bodyMedium: piedra(textStyle: textTheme.bodyMedium),
      bodySmall: piedra(textStyle: textTheme.bodySmall),
      labelLarge: piedra(textStyle: textTheme.labelLarge),
      labelMedium: piedra(textStyle: textTheme.labelMedium),
      labelSmall: piedra(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Pinyon Script font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Pinyon+Script
  static TextStyle pinyonScript({
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
        '11eeace1c1d7a6f01a1a73e91580a742ddfdc46e3f0edbda5dcf3613ac8dd5e5',
        108032,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PinyonScript',
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

  /// Applies the Pinyon Script font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Pinyon+Script
  static TextTheme pinyonScriptTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: pinyonScript(textStyle: textTheme.displayLarge),
      displayMedium: pinyonScript(textStyle: textTheme.displayMedium),
      displaySmall: pinyonScript(textStyle: textTheme.displaySmall),
      headlineLarge: pinyonScript(textStyle: textTheme.headlineLarge),
      headlineMedium: pinyonScript(textStyle: textTheme.headlineMedium),
      headlineSmall: pinyonScript(textStyle: textTheme.headlineSmall),
      titleLarge: pinyonScript(textStyle: textTheme.titleLarge),
      titleMedium: pinyonScript(textStyle: textTheme.titleMedium),
      titleSmall: pinyonScript(textStyle: textTheme.titleSmall),
      bodyLarge: pinyonScript(textStyle: textTheme.bodyLarge),
      bodyMedium: pinyonScript(textStyle: textTheme.bodyMedium),
      bodySmall: pinyonScript(textStyle: textTheme.bodySmall),
      labelLarge: pinyonScript(textStyle: textTheme.labelLarge),
      labelMedium: pinyonScript(textStyle: textTheme.labelMedium),
      labelSmall: pinyonScript(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Pirata One font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Pirata+One
  static TextStyle pirataOne({
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
        'a3b78a02a84a89389255d545696986a4add46285ae3f32d150234b1929a2c72e',
        53648,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PirataOne',
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

  /// Applies the Pirata One font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Pirata+One
  static TextTheme pirataOneTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: pirataOne(textStyle: textTheme.displayLarge),
      displayMedium: pirataOne(textStyle: textTheme.displayMedium),
      displaySmall: pirataOne(textStyle: textTheme.displaySmall),
      headlineLarge: pirataOne(textStyle: textTheme.headlineLarge),
      headlineMedium: pirataOne(textStyle: textTheme.headlineMedium),
      headlineSmall: pirataOne(textStyle: textTheme.headlineSmall),
      titleLarge: pirataOne(textStyle: textTheme.titleLarge),
      titleMedium: pirataOne(textStyle: textTheme.titleMedium),
      titleSmall: pirataOne(textStyle: textTheme.titleSmall),
      bodyLarge: pirataOne(textStyle: textTheme.bodyLarge),
      bodyMedium: pirataOne(textStyle: textTheme.bodyMedium),
      bodySmall: pirataOne(textStyle: textTheme.bodySmall),
      labelLarge: pirataOne(textStyle: textTheme.labelLarge),
      labelMedium: pirataOne(textStyle: textTheme.labelMedium),
      labelSmall: pirataOne(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Pixelify Sans font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Pixelify+Sans
  static TextStyle pixelifySans({
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
        'c67da31274fee92d7e2bdb65142815d6b0bbd4c64c208652ae7c2502aa93770d',
        49816,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '00a95176e4f983b9c84d4ab68cb09845b3d17d8167a315ff513519a8ca0c844b',
        49588,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '5ca969d87be4981bea0c9db81fc7f33f3b740fab0d78fc0b5d8780141aec1a70',
        49620,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '3e0ad95871821b3a85ba4dae37b973ea3f759fdab8e51bd113983b7b4ad5962e',
        49372,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '5771e29011b1b1e9bef6324f6bf54d38b96dba317f1232ef494c3401f8b409fa',
        76948,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PixelifySans',
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

  /// Applies the Pixelify Sans font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Pixelify+Sans
  static TextTheme pixelifySansTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: pixelifySans(textStyle: textTheme.displayLarge),
      displayMedium: pixelifySans(textStyle: textTheme.displayMedium),
      displaySmall: pixelifySans(textStyle: textTheme.displaySmall),
      headlineLarge: pixelifySans(textStyle: textTheme.headlineLarge),
      headlineMedium: pixelifySans(textStyle: textTheme.headlineMedium),
      headlineSmall: pixelifySans(textStyle: textTheme.headlineSmall),
      titleLarge: pixelifySans(textStyle: textTheme.titleLarge),
      titleMedium: pixelifySans(textStyle: textTheme.titleMedium),
      titleSmall: pixelifySans(textStyle: textTheme.titleSmall),
      bodyLarge: pixelifySans(textStyle: textTheme.bodyLarge),
      bodyMedium: pixelifySans(textStyle: textTheme.bodyMedium),
      bodySmall: pixelifySans(textStyle: textTheme.bodySmall),
      labelLarge: pixelifySans(textStyle: textTheme.labelLarge),
      labelMedium: pixelifySans(textStyle: textTheme.labelMedium),
      labelSmall: pixelifySans(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Plaster font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Plaster
  static TextStyle plaster({
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
        'fcc4c3ef2e559eeaef5051dbf7b6bfab4312a95a455e1b3130e3a25c2e61b155',
        28132,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Plaster',
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

  /// Applies the Plaster font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Plaster
  static TextTheme plasterTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: plaster(textStyle: textTheme.displayLarge),
      displayMedium: plaster(textStyle: textTheme.displayMedium),
      displaySmall: plaster(textStyle: textTheme.displaySmall),
      headlineLarge: plaster(textStyle: textTheme.headlineLarge),
      headlineMedium: plaster(textStyle: textTheme.headlineMedium),
      headlineSmall: plaster(textStyle: textTheme.headlineSmall),
      titleLarge: plaster(textStyle: textTheme.titleLarge),
      titleMedium: plaster(textStyle: textTheme.titleMedium),
      titleSmall: plaster(textStyle: textTheme.titleSmall),
      bodyLarge: plaster(textStyle: textTheme.bodyLarge),
      bodyMedium: plaster(textStyle: textTheme.bodyMedium),
      bodySmall: plaster(textStyle: textTheme.bodySmall),
      labelLarge: plaster(textStyle: textTheme.labelLarge),
      labelMedium: plaster(textStyle: textTheme.labelMedium),
      labelSmall: plaster(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Platypi font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Platypi
  static TextStyle platypi({
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
        '5db68b2d3d825df679c926f70f9f234429df67ce3f787ca7356cc63857aa7ac6',
        101656,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '2c754a31101517fe27928a505b4c65ba266125ec7df6ffd6f4b5eaff30d10851',
        101792,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'c761ef5be4637a23fc002ac6cc6e290b62f390018e20457f58fcb91d48b60808',
        101792,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '7d6ed224367abc226725252d5ceca4baa5be95094ebe671d168b978edbbd60b4',
        101816,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'e28bac16ae0f9f679e6dd2b96ff68cf1321fac3b9e110cfe4179b1eaeef3dcb8',
        101868,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'd12692680ccd6a44fd72cbb065e1243ddefc1702ccd3ae0cf4dabe7c6823ad52',
        101780,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '57d25567e281c1873d6cf28b342e46b167e5a9336da363e195fd8e637ecbf3cb',
        99264,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '5fec4264fb7ff33fe0d2cde7d2e09caff19f58769c8c371f2cdd9ce503aa2a76',
        99368,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '801aa8ea498cbc65081a76abba210a430cf04bd6f00f2500897eb1ee0af2d016',
        99512,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '120f1f427d40e02d78ce40d4fbf0dd350c93e1b717bb678d2ede548c4025b6fe',
        99568,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '048d58e4d0e701378c7d03c6a3b2f6ed6e67602d1bfb8c30c166dd431134d586',
        99440,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'e4463312989c011568c8eacb71f68b4336f5ecd9d7814e84c5048f915951820f',
        99576,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'f0fd65c9209dd2ae7a37fd49e62f3de000ec36bc12888624a08a5f7ca97e64f5',
        165836,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '74f8b5c315fe70e274a70ba4147b8a78d439c1f665f70c9a67746de1247b88b7',
        161988,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Platypi',
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

  /// Applies the Platypi font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Platypi
  static TextTheme platypiTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: platypi(textStyle: textTheme.displayLarge),
      displayMedium: platypi(textStyle: textTheme.displayMedium),
      displaySmall: platypi(textStyle: textTheme.displaySmall),
      headlineLarge: platypi(textStyle: textTheme.headlineLarge),
      headlineMedium: platypi(textStyle: textTheme.headlineMedium),
      headlineSmall: platypi(textStyle: textTheme.headlineSmall),
      titleLarge: platypi(textStyle: textTheme.titleLarge),
      titleMedium: platypi(textStyle: textTheme.titleMedium),
      titleSmall: platypi(textStyle: textTheme.titleSmall),
      bodyLarge: platypi(textStyle: textTheme.bodyLarge),
      bodyMedium: platypi(textStyle: textTheme.bodyMedium),
      bodySmall: platypi(textStyle: textTheme.bodySmall),
      labelLarge: platypi(textStyle: textTheme.labelLarge),
      labelMedium: platypi(textStyle: textTheme.labelMedium),
      labelSmall: platypi(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Play font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Play
  static TextStyle play({
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
        'f9a162dff4d63f394589d709b0745f1a7eb1188f94c3e2c796d536c8fc8fbe80',
        84888,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '4f0600f08d3c37eb544d892fee6a0aa902159f53776fd3f8b3202525fd427ea6',
        85872,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Play',
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

  /// Applies the Play font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Play
  static TextTheme playTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: play(textStyle: textTheme.displayLarge),
      displayMedium: play(textStyle: textTheme.displayMedium),
      displaySmall: play(textStyle: textTheme.displaySmall),
      headlineLarge: play(textStyle: textTheme.headlineLarge),
      headlineMedium: play(textStyle: textTheme.headlineMedium),
      headlineSmall: play(textStyle: textTheme.headlineSmall),
      titleLarge: play(textStyle: textTheme.titleLarge),
      titleMedium: play(textStyle: textTheme.titleMedium),
      titleSmall: play(textStyle: textTheme.titleSmall),
      bodyLarge: play(textStyle: textTheme.bodyLarge),
      bodyMedium: play(textStyle: textTheme.bodyMedium),
      bodySmall: play(textStyle: textTheme.bodySmall),
      labelLarge: play(textStyle: textTheme.labelLarge),
      labelMedium: play(textStyle: textTheme.labelMedium),
      labelSmall: play(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playball font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playball
  static TextStyle playball({
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
        '2a3299442a4f7cebfc56918238e3665610b3e12e603b3195569e286b4f87152e',
        142600,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Playball',
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

  /// Applies the Playball font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playball
  static TextTheme playballTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playball(textStyle: textTheme.displayLarge),
      displayMedium: playball(textStyle: textTheme.displayMedium),
      displaySmall: playball(textStyle: textTheme.displaySmall),
      headlineLarge: playball(textStyle: textTheme.headlineLarge),
      headlineMedium: playball(textStyle: textTheme.headlineMedium),
      headlineSmall: playball(textStyle: textTheme.headlineSmall),
      titleLarge: playball(textStyle: textTheme.titleLarge),
      titleMedium: playball(textStyle: textTheme.titleMedium),
      titleSmall: playball(textStyle: textTheme.titleSmall),
      bodyLarge: playball(textStyle: textTheme.bodyLarge),
      bodyMedium: playball(textStyle: textTheme.bodyMedium),
      bodySmall: playball(textStyle: textTheme.bodySmall),
      labelLarge: playball(textStyle: textTheme.labelLarge),
      labelMedium: playball(textStyle: textTheme.labelMedium),
      labelSmall: playball(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playfair font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playfair
  static TextStyle playfair({
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
        'bcef22035e02eb05d1befbc1cdd76f78a7e121778b00dd6e772d7728914928fe',
        215968,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '1f03babf04beacc38614d9a32ba8cc787e79eeef4301945494c8fd302fd82950',
        216136,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '9e2414f69636c0907f4f10b6c8242c850397271490dbe9142421486ecc11b3c0',
        216048,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '66a769d0dd4d2cf4a0b8938984a9ae7577a0b5ce7d98e382909704edf1f630ec',
        216164,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '9a6e34888f8aa879f5d410e07cfc79067cb21b0b03eb8991439640da81c6d5a3',
        215940,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '70fe45bc09830504e2695d416528836e0b9b511e1e3b69b470b888751fa512ce',
        216300,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '48453560c4a1ea7537da3e52ea75c5504efe93852309104011e0a8b3746fd917',
        216380,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'c6dcc0ff91f311cb82ca08cccc4c478f441d8f2cd51676f23d13e72dc25f05e8',
        229284,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '6c64d2a1190949d47ee1ea8f307d64894b12544c506ade72ab012cb846473331',
        229416,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '9ef0574dfe89508f10ff828a6085cc2f2728ce9c92b72d1c739467d5f730c562',
        229708,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '2bd15e072265bd51ee38ba4e465ce87bbb44479bf7476b438686ab771235d4b9',
        230052,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'abeafe67837399ec0e0e5d758b2375ff04287a0b34192b7d84d478e1a84aafe8',
        231632,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '9c59b19092bd155641362f894a2897bd7929a2b187541e74b3d4cd3eaaf82bd9',
        231536,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '9614953c36067ab58e539bf477a4fa3231ed2a2334ef2e4d94d69e86f352e4c5',
        231792,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'fc57e382f679dbc3e14d83422e258e983d6e9a6097d6d6b53952053ca7d16239',
        1130432,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '26615c0c1a54c2412942f5b5ecab4289a1f3272398ea4e1223fcb4c9569b12c7',
        1143572,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Playfair',
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

  /// Applies the Playfair font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playfair
  static TextTheme playfairTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playfair(textStyle: textTheme.displayLarge),
      displayMedium: playfair(textStyle: textTheme.displayMedium),
      displaySmall: playfair(textStyle: textTheme.displaySmall),
      headlineLarge: playfair(textStyle: textTheme.headlineLarge),
      headlineMedium: playfair(textStyle: textTheme.headlineMedium),
      headlineSmall: playfair(textStyle: textTheme.headlineSmall),
      titleLarge: playfair(textStyle: textTheme.titleLarge),
      titleMedium: playfair(textStyle: textTheme.titleMedium),
      titleSmall: playfair(textStyle: textTheme.titleSmall),
      bodyLarge: playfair(textStyle: textTheme.bodyLarge),
      bodyMedium: playfair(textStyle: textTheme.bodyMedium),
      bodySmall: playfair(textStyle: textTheme.bodySmall),
      labelLarge: playfair(textStyle: textTheme.labelLarge),
      labelMedium: playfair(textStyle: textTheme.labelMedium),
      labelSmall: playfair(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playfair Display font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playfair+Display
  static TextStyle playfairDisplay({
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
        '775cd3f92411b97cc374e0d8909c5caf3713508120866dc62b08f7a20213ba6d',
        123216,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '102a056af74fd12dd9436188b5c3bf72aa6e7e1ae55223d4e6cd76652edff492',
        123584,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '9d28ec9ef0160652a7f0c9a1be5a55361b9f5249e8da1ad0b81916dbf1fee7e5',
        123648,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '529bffba18f383c1e3d0c1851b77b3bccfdd841ab051a5517543efca15b65038',
        123512,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '3deba1ed67c7bec5ee3e5700c2d6d83d9924a4f86bbaaa384cfeeffc1a78b10d',
        123584,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'c3f0632fe42bdeeb4fec24a7f834ab4456190ed005811d20637fd94146557738',
        123508,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'ef34ad679cbd7e276b4f9571d5e3137f01375933b014491057999ab8bfcfb098',
        110792,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '91e3874ae9688ff249b7a421a4e4b1195045493e04b08e8689e7e921a80b98ca',
        111144,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'f69cc5c56ec3b71180884c7e773e10bece78999e5adb6342a0e545bc7bcf954a',
        111184,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '8f3e22cdbc44cf8bb17383f36cc23c73b70cb15e4c6d9a28f55ed4eaa77b294c',
        111104,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'aad0b6d9413555eef1df8d7257a88bbec727fc407cffacddc945e2a5f986a858',
        111092,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'ad2fa5f23dc596322ff1fd50252c044c45a9f679ef81a8059b6c0767bd37248b',
        110732,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'a6911f7d1ed08dd0fd36f5826fe9f9f33b052b940c34f20cab59d91809746612',
        193568,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'd2c697d28d1dc8d01721c0895b0098d11b659a303c2f3909a335a2bb967e419d',
        176680,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlayfairDisplay',
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

  /// Applies the Playfair Display font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playfair+Display
  static TextTheme playfairDisplayTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playfairDisplay(textStyle: textTheme.displayLarge),
      displayMedium: playfairDisplay(textStyle: textTheme.displayMedium),
      displaySmall: playfairDisplay(textStyle: textTheme.displaySmall),
      headlineLarge: playfairDisplay(textStyle: textTheme.headlineLarge),
      headlineMedium: playfairDisplay(textStyle: textTheme.headlineMedium),
      headlineSmall: playfairDisplay(textStyle: textTheme.headlineSmall),
      titleLarge: playfairDisplay(textStyle: textTheme.titleLarge),
      titleMedium: playfairDisplay(textStyle: textTheme.titleMedium),
      titleSmall: playfairDisplay(textStyle: textTheme.titleSmall),
      bodyLarge: playfairDisplay(textStyle: textTheme.bodyLarge),
      bodyMedium: playfairDisplay(textStyle: textTheme.bodyMedium),
      bodySmall: playfairDisplay(textStyle: textTheme.bodySmall),
      labelLarge: playfairDisplay(textStyle: textTheme.labelLarge),
      labelMedium: playfairDisplay(textStyle: textTheme.labelMedium),
      labelSmall: playfairDisplay(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playfair Display SC font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playfair+Display+SC
  static TextStyle playfairDisplaySc({
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
        'e2e5de64c36474180fc68005480114a825daa3439b96a45e246237a7f2e02de1',
        94472,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '6f991f07f0780a5613b5588a0af6721cf42d1e30b5bfb37e0a8e0ad29c0a3aa4',
        91592,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '660ed6e351c427201e5bf534911d9e6594c5957d94e684c409b9157eedb10451',
        97440,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'f7851b787cfc21e9281f1851d089fb08108e1040f6ad04b172f5372a0e0d2859',
        94548,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '2eeaf9dae89af23beb5311628d7a1a55ea0eb99836a35cf17ec871cfd79a505b',
        96208,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '41c7ce200a39f9a58695666c9c74713fa7f2abe0891c64c62ab86421c86ed383',
        92856,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlayfairDisplaySC',
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

  /// Applies the Playfair Display SC font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playfair+Display+SC
  static TextTheme playfairDisplayScTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playfairDisplaySc(textStyle: textTheme.displayLarge),
      displayMedium: playfairDisplaySc(textStyle: textTheme.displayMedium),
      displaySmall: playfairDisplaySc(textStyle: textTheme.displaySmall),
      headlineLarge: playfairDisplaySc(textStyle: textTheme.headlineLarge),
      headlineMedium: playfairDisplaySc(textStyle: textTheme.headlineMedium),
      headlineSmall: playfairDisplaySc(textStyle: textTheme.headlineSmall),
      titleLarge: playfairDisplaySc(textStyle: textTheme.titleLarge),
      titleMedium: playfairDisplaySc(textStyle: textTheme.titleMedium),
      titleSmall: playfairDisplaySc(textStyle: textTheme.titleSmall),
      bodyLarge: playfairDisplaySc(textStyle: textTheme.bodyLarge),
      bodyMedium: playfairDisplaySc(textStyle: textTheme.bodyMedium),
      bodySmall: playfairDisplaySc(textStyle: textTheme.bodySmall),
      labelLarge: playfairDisplaySc(textStyle: textTheme.labelLarge),
      labelMedium: playfairDisplaySc(textStyle: textTheme.labelMedium),
      labelSmall: playfairDisplaySc(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playpen Sans font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playpen+Sans
  static TextStyle playpenSans({
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
        'cf9a098d8e49b3af9982bb8314ab288fca528381dcfa8f8ae59b2b0a1bc854ed',
        702440,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '310f0d62a99e0b740a9849a3e2b748756ac1d0dc01175c1431fd5e8237ee689f',
        704280,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '894bcc12afef1053f6d66da11b0c250ecc4283113e283b7a6064b11824e63a5d',
        704704,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'f3373dbaec1e5d7e6943bd2a1697180a8c0659acfc0f18e7a06e6a7d9386c013',
        704252,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '7fc487d7f783e36f7af5502f0a3288ebf7d2a70d7c337e5f0db38ddd8f831f33',
        704916,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '886ea9cce91c08d21e6ac219d7d46f1709f52fe23cc7bbcf73a2048bb4441f90',
        706120,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '3bbad295dfba8a3b5d2a1aec165199725b13eba1e3dcc7338e9bc2a4bc08d2a3',
        706024,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'abbf6644dc668e74ec4b5eec76e884c19d3a783e657a63b7b8710c5b683c57c4',
        704916,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '29692d9cba80ee48199e17c7b769ece4703f5e6a3f85fc59c9260431f2e6a888',
        1493820,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaypenSans',
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

  /// Applies the Playpen Sans font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playpen+Sans
  static TextTheme playpenSansTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playpenSans(textStyle: textTheme.displayLarge),
      displayMedium: playpenSans(textStyle: textTheme.displayMedium),
      displaySmall: playpenSans(textStyle: textTheme.displaySmall),
      headlineLarge: playpenSans(textStyle: textTheme.headlineLarge),
      headlineMedium: playpenSans(textStyle: textTheme.headlineMedium),
      headlineSmall: playpenSans(textStyle: textTheme.headlineSmall),
      titleLarge: playpenSans(textStyle: textTheme.titleLarge),
      titleMedium: playpenSans(textStyle: textTheme.titleMedium),
      titleSmall: playpenSans(textStyle: textTheme.titleSmall),
      bodyLarge: playpenSans(textStyle: textTheme.bodyLarge),
      bodyMedium: playpenSans(textStyle: textTheme.bodyMedium),
      bodySmall: playpenSans(textStyle: textTheme.bodySmall),
      labelLarge: playpenSans(textStyle: textTheme.labelLarge),
      labelMedium: playpenSans(textStyle: textTheme.labelMedium),
      labelSmall: playpenSans(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playpen Sans Arabic font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playpen+Sans+Arabic
  static TextStyle playpenSansArabic({
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
        '1603e0e5efc23de78d580a3d71da195b6a8987d7dfc3f661818a345d5fd5ce04',
        337052,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'c0c63b77e27fcce42b9e2dbafc4a2b58bfaf38d020821779b14d0ea7f5a75abf',
        338144,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'aa260c54c7ef421cdc8a50f7580562fcf9a97f92329a1368ee6c4d4b23f88aa6',
        338208,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '5acb51955b6893189c3f37977267b54ccf4595987e1787193ec607bc80572ca3',
        338044,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '81b38e57951d3575b1ca728a9d7ffda00f2f0bc9e989ecf30eb71aaa5e5656e0',
        338312,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'dae3e52f30f8ec2e67c8242125d3c0cbbed9b7c3de36b4bb053d7c5e066f25e6',
        338992,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '09c3f5268983cb6396775bda2b780779dfddebf4fc7ecca5b5d73c91a363dac2',
        338912,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'a85131f175891f7eff055eaf981e5e031d108d8ef8f4ded61303261373b57b8c',
        338128,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '3e86a12bd7bdd5acfdbb53ac8c0e9046f4df9aa609ca010dcfac0719c7d12904',
        714932,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaypenSansArabic',
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

  /// Applies the Playpen Sans Arabic font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playpen+Sans+Arabic
  static TextTheme playpenSansArabicTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playpenSansArabic(textStyle: textTheme.displayLarge),
      displayMedium: playpenSansArabic(textStyle: textTheme.displayMedium),
      displaySmall: playpenSansArabic(textStyle: textTheme.displaySmall),
      headlineLarge: playpenSansArabic(textStyle: textTheme.headlineLarge),
      headlineMedium: playpenSansArabic(textStyle: textTheme.headlineMedium),
      headlineSmall: playpenSansArabic(textStyle: textTheme.headlineSmall),
      titleLarge: playpenSansArabic(textStyle: textTheme.titleLarge),
      titleMedium: playpenSansArabic(textStyle: textTheme.titleMedium),
      titleSmall: playpenSansArabic(textStyle: textTheme.titleSmall),
      bodyLarge: playpenSansArabic(textStyle: textTheme.bodyLarge),
      bodyMedium: playpenSansArabic(textStyle: textTheme.bodyMedium),
      bodySmall: playpenSansArabic(textStyle: textTheme.bodySmall),
      labelLarge: playpenSansArabic(textStyle: textTheme.labelLarge),
      labelMedium: playpenSansArabic(textStyle: textTheme.labelMedium),
      labelSmall: playpenSansArabic(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playpen Sans Deva font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playpen+Sans+Deva
  static TextStyle playpenSansDeva({
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
        '754c72aff55c6d4a19d9af6e348bf444f1863f0aaea5c26e544270ab41d8fa8a',
        689796,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '9e4146a274c18dbb60020b7dad8f0e1cbecc30c5108a11b13875c4d9d465136d',
        693604,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'cc921087d84e81a8f84f532cb4167332ef8d2c9e3b3fa1003f4cd86fbdf5b23e',
        695472,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'bd663ba124516924dbfad74cd3ff5402ca43dcc6e97e8a27cc2186b95990edcd',
        696652,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'e05ee9b588517acf5b35a654c7c18a12729ae49bbb3efd2558351eb5ceea4cf8',
        697308,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'c69e002a9a9064df0692bdb09e2505ab28e631f42a239ecbb7d987caf05c3737',
        698520,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'f36364c468b9b797ffa8db097603f2e74933adc881f07d99bf0c7bb8ff3425a8',
        698284,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '96627e409518d0dd15d3fe6f48988cbe86b134bcad90bf4bc479e0ee4bbfca6d',
        696716,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '52e63b28aa29c19196198d1e31a9b76022389d12ade5d2dfe9e14ee3ab005e0f',
        1526564,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaypenSansDeva',
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

  /// Applies the Playpen Sans Deva font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playpen+Sans+Deva
  static TextTheme playpenSansDevaTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playpenSansDeva(textStyle: textTheme.displayLarge),
      displayMedium: playpenSansDeva(textStyle: textTheme.displayMedium),
      displaySmall: playpenSansDeva(textStyle: textTheme.displaySmall),
      headlineLarge: playpenSansDeva(textStyle: textTheme.headlineLarge),
      headlineMedium: playpenSansDeva(textStyle: textTheme.headlineMedium),
      headlineSmall: playpenSansDeva(textStyle: textTheme.headlineSmall),
      titleLarge: playpenSansDeva(textStyle: textTheme.titleLarge),
      titleMedium: playpenSansDeva(textStyle: textTheme.titleMedium),
      titleSmall: playpenSansDeva(textStyle: textTheme.titleSmall),
      bodyLarge: playpenSansDeva(textStyle: textTheme.bodyLarge),
      bodyMedium: playpenSansDeva(textStyle: textTheme.bodyMedium),
      bodySmall: playpenSansDeva(textStyle: textTheme.bodySmall),
      labelLarge: playpenSansDeva(textStyle: textTheme.labelLarge),
      labelMedium: playpenSansDeva(textStyle: textTheme.labelMedium),
      labelSmall: playpenSansDeva(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playpen Sans Hebrew font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playpen+Sans+Hebrew
  static TextStyle playpenSansHebrew({
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
        '12b5813bbd3bd556097fc1d70b7e24bf1860c641209c130af013592c100488d3',
        289252,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '83a5ab162720f9076e6cf8e8d40a13cfeca2e127022f9b20de4ab99824deba50',
        290080,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '1edf9124f46768212c23a673d2e3c43ff99275b10ce5bd95a534bbb59b3eb347',
        290244,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '43f0fdfc5acf08f68836f6fc2e9b412fdcb900314ef5395e110a7885b3570125',
        289980,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '91161a0e87861d96d425c34340f0dde412320a9dbe8881daf521105623c3a980',
        290348,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '7c37f10fbb2ee4baba2a3485015b60effcbc0d1b2c101f8f91ff78211e3a6648',
        291096,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '21fcd6dbe447c16220af43f34bd517cb8047d21a5060ab69fd6a1f25d8415dc3',
        291160,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'c03b95aa10a79b98e0e186c66f2595766d3125ea36639e3bebc07af398fbd858',
        290712,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '94781b0937ee4a24592b425941cac47270cc1f643ebe6c0547b545a43563b672',
        610208,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaypenSansHebrew',
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

  /// Applies the Playpen Sans Hebrew font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playpen+Sans+Hebrew
  static TextTheme playpenSansHebrewTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playpenSansHebrew(textStyle: textTheme.displayLarge),
      displayMedium: playpenSansHebrew(textStyle: textTheme.displayMedium),
      displaySmall: playpenSansHebrew(textStyle: textTheme.displaySmall),
      headlineLarge: playpenSansHebrew(textStyle: textTheme.headlineLarge),
      headlineMedium: playpenSansHebrew(textStyle: textTheme.headlineMedium),
      headlineSmall: playpenSansHebrew(textStyle: textTheme.headlineSmall),
      titleLarge: playpenSansHebrew(textStyle: textTheme.titleLarge),
      titleMedium: playpenSansHebrew(textStyle: textTheme.titleMedium),
      titleSmall: playpenSansHebrew(textStyle: textTheme.titleSmall),
      bodyLarge: playpenSansHebrew(textStyle: textTheme.bodyLarge),
      bodyMedium: playpenSansHebrew(textStyle: textTheme.bodyMedium),
      bodySmall: playpenSansHebrew(textStyle: textTheme.bodySmall),
      labelLarge: playpenSansHebrew(textStyle: textTheme.labelLarge),
      labelMedium: playpenSansHebrew(textStyle: textTheme.labelMedium),
      labelSmall: playpenSansHebrew(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playpen Sans Thai font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playpen+Sans+Thai
  static TextStyle playpenSansThai({
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
        '31e5697339762b0c0b7b5c8e5849dd973a4fee884337703263c77c9f58e169d7',
        328712,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '48bdb8338bde1f83e3cec7627e43f5a198983fa49b08a46528e2aaa2e775a627',
        329416,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '449d54d384a7ab4e28d02b78988f72d362c7015e295f17724bc9815c3cf81166',
        329528,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '0f5763da21d0682d0b906d3d82e64f35d156ee7817f597751424c37ca06d4d96',
        329372,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '4c5b9ea5aec147902bec085664fefefa3260293bc6227791b1374f6ae93ee75b',
        329580,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '030f3bf0a191affd06681571de76425b607f844af195cd4170ca6e40510fddbb',
        330412,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'ec4fa844813d076dfcfb043b3e6098abba347dda6f1808a2ea63630ce7f80b38',
        330384,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'a50214d5839fce087b31a3497ce5041e665870b7d51b95ad727a6b3865f8bcdd',
        329916,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '3ca45404de3fca399f117172707a9e3f804ac103ad812ded26de22ddccbf74b9',
        717232,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaypenSansThai',
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

  /// Applies the Playpen Sans Thai font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playpen+Sans+Thai
  static TextTheme playpenSansThaiTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playpenSansThai(textStyle: textTheme.displayLarge),
      displayMedium: playpenSansThai(textStyle: textTheme.displayMedium),
      displaySmall: playpenSansThai(textStyle: textTheme.displaySmall),
      headlineLarge: playpenSansThai(textStyle: textTheme.headlineLarge),
      headlineMedium: playpenSansThai(textStyle: textTheme.headlineMedium),
      headlineSmall: playpenSansThai(textStyle: textTheme.headlineSmall),
      titleLarge: playpenSansThai(textStyle: textTheme.titleLarge),
      titleMedium: playpenSansThai(textStyle: textTheme.titleMedium),
      titleSmall: playpenSansThai(textStyle: textTheme.titleSmall),
      bodyLarge: playpenSansThai(textStyle: textTheme.bodyLarge),
      bodyMedium: playpenSansThai(textStyle: textTheme.bodyMedium),
      bodySmall: playpenSansThai(textStyle: textTheme.bodySmall),
      labelLarge: playpenSansThai(textStyle: textTheme.labelLarge),
      labelMedium: playpenSansThai(textStyle: textTheme.labelMedium),
      labelSmall: playpenSansThai(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite AR font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+AR
  static TextStyle playwriteAr({
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
        '625eda10d19a2fc55b2163405051c5f3f9e42e8f62ad8e11f50dfe24cabc9fbb',
        131028,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'd92bb9cf6e4629d8aa66699f15ad8ddb91027f97213391f92ea41d56af1a4a73',
        131292,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '0cac8ddd8e83a827ec8b81b453dee33c2efd5732152dd756ff0dcf4803c20345',
        131324,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '65936a72f3f8fec849df1310ccb7ea1cc7ecfcf61e8e423812212548444fd5de',
        131124,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '3cce51411a14d217c3ef29bc817a026d27b2e66d45a91e2b2569288902253236',
        197452,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteAR',
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

  /// Applies the Playwrite AR font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+AR
  static TextTheme playwriteArTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteAr(textStyle: textTheme.displayLarge),
      displayMedium: playwriteAr(textStyle: textTheme.displayMedium),
      displaySmall: playwriteAr(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteAr(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteAr(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteAr(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteAr(textStyle: textTheme.titleLarge),
      titleMedium: playwriteAr(textStyle: textTheme.titleMedium),
      titleSmall: playwriteAr(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteAr(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteAr(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteAr(textStyle: textTheme.bodySmall),
      labelLarge: playwriteAr(textStyle: textTheme.labelLarge),
      labelMedium: playwriteAr(textStyle: textTheme.labelMedium),
      labelSmall: playwriteAr(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite AR Guides font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+AR+Guides
  static TextStyle playwriteArGuides({
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
        '1ae3a880340e0b3a8ee3585334bd27e209363a225dc9e08c5ac5fc6b50f5ecad',
        224524,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteARGuides',
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

  /// Applies the Playwrite AR Guides font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+AR+Guides
  static TextTheme playwriteArGuidesTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteArGuides(textStyle: textTheme.displayLarge),
      displayMedium: playwriteArGuides(textStyle: textTheme.displayMedium),
      displaySmall: playwriteArGuides(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteArGuides(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteArGuides(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteArGuides(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteArGuides(textStyle: textTheme.titleLarge),
      titleMedium: playwriteArGuides(textStyle: textTheme.titleMedium),
      titleSmall: playwriteArGuides(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteArGuides(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteArGuides(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteArGuides(textStyle: textTheme.bodySmall),
      labelLarge: playwriteArGuides(textStyle: textTheme.labelLarge),
      labelMedium: playwriteArGuides(textStyle: textTheme.labelMedium),
      labelSmall: playwriteArGuides(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite AT font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+AT
  static TextStyle playwriteAt({
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
        '6a73dbf5b9a2252366621fbb1c92050eb666ba9ac22e5e83ac8e06217d6cd66d',
        114936,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '3ccbc8e4ea027b7d2b072eab6ba212a7556975f1b0c5c460a89d12f139a0f743',
        115180,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '9fd7877530ba5a5de36e02f9bbd416b160283565bdcf2c464098d992e383de35',
        115088,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'a524d49c4df1abd1f253a16de1465777b906a1c9e6f580fe93393542585bd85c',
        114880,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w100,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '369b649136639e98e1d15bb030406750c8238857a942cdcf78a4194cbc0cba57',
        117088,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '1ff25e92d088e42cf26be272b4af3361dd08f86bc63f55bda0031723372de8e2',
        117084,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '90170965a43e58f6299decf61f5d5c0e8f609ea9de129e64a4587f32858ba15b',
        116952,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '4590037b549e5a9e505c25b4f4c936a53ea3c8656570fa4f3cacc3d2bd4325ab',
        116672,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '37855b9cf89c99b414bfd5c22cabafd0075427798613935d2d09ee0542e2536e',
        172652,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '572b355ef7b8faf743923fa49b60c72d7e4d5967da768968ae77b5873fc5b792',
        175676,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteAT',
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

  /// Applies the Playwrite AT font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+AT
  static TextTheme playwriteAtTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteAt(textStyle: textTheme.displayLarge),
      displayMedium: playwriteAt(textStyle: textTheme.displayMedium),
      displaySmall: playwriteAt(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteAt(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteAt(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteAt(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteAt(textStyle: textTheme.titleLarge),
      titleMedium: playwriteAt(textStyle: textTheme.titleMedium),
      titleSmall: playwriteAt(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteAt(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteAt(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteAt(textStyle: textTheme.bodySmall),
      labelLarge: playwriteAt(textStyle: textTheme.labelLarge),
      labelMedium: playwriteAt(textStyle: textTheme.labelMedium),
      labelSmall: playwriteAt(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite AT Guides font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+AT+Guides
  static TextStyle playwriteAtGuides({
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
        '3ef5f198f8a4f5b8e88701e041b785d78d0312bea175ea8babc932305d80d0b1',
        207024,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'ac1ff98ef1d942c584b1a2358d102c7bf977a0fe0099a17028f2a290f8f872bd',
        210700,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteATGuides',
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

  /// Applies the Playwrite AT Guides font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+AT+Guides
  static TextTheme playwriteAtGuidesTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteAtGuides(textStyle: textTheme.displayLarge),
      displayMedium: playwriteAtGuides(textStyle: textTheme.displayMedium),
      displaySmall: playwriteAtGuides(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteAtGuides(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteAtGuides(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteAtGuides(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteAtGuides(textStyle: textTheme.titleLarge),
      titleMedium: playwriteAtGuides(textStyle: textTheme.titleMedium),
      titleSmall: playwriteAtGuides(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteAtGuides(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteAtGuides(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteAtGuides(textStyle: textTheme.bodySmall),
      labelLarge: playwriteAtGuides(textStyle: textTheme.labelLarge),
      labelMedium: playwriteAtGuides(textStyle: textTheme.labelMedium),
      labelSmall: playwriteAtGuides(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite AU NSW font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+AU+NSW
  static TextStyle playwriteAuNsw({
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
        '6b3010cc6c7287f27e67538fa617d964da68b898f3a1f9ab857af2fc990206ca',
        87108,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'e26ec1543dd7b1f51a3341dae5d112f9db0a74a34de1bf6f8c9f1073c691a603',
        87204,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'b9dffb43720bfe7030a7168d29f655669fa087a5e1ab49863dca0399bba38443',
        87084,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '60899c4c4fad980810abf4080b6c4175e24e7d31705b51ff12164ff5b0552489',
        86920,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '3a502c428bd64dd80da5c1547db30ef3ab456becf9955c6a10eb2634499ab885',
        129224,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteAUNSW',
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

  /// Applies the Playwrite AU NSW font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+AU+NSW
  static TextTheme playwriteAuNswTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteAuNsw(textStyle: textTheme.displayLarge),
      displayMedium: playwriteAuNsw(textStyle: textTheme.displayMedium),
      displaySmall: playwriteAuNsw(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteAuNsw(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteAuNsw(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteAuNsw(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteAuNsw(textStyle: textTheme.titleLarge),
      titleMedium: playwriteAuNsw(textStyle: textTheme.titleMedium),
      titleSmall: playwriteAuNsw(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteAuNsw(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteAuNsw(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteAuNsw(textStyle: textTheme.bodySmall),
      labelLarge: playwriteAuNsw(textStyle: textTheme.labelLarge),
      labelMedium: playwriteAuNsw(textStyle: textTheme.labelMedium),
      labelSmall: playwriteAuNsw(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite AU NSW Guides font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+AU+NSW+Guides
  static TextStyle playwriteAuNswGuides({
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
        '5425dc50a7c5e13be8fea136fe7f0e0dc5422036fc9ca728f83c06384699ee31',
        183568,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteAUNSWGuides',
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

  /// Applies the Playwrite AU NSW Guides font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+AU+NSW+Guides
  static TextTheme playwriteAuNswGuidesTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteAuNswGuides(textStyle: textTheme.displayLarge),
      displayMedium: playwriteAuNswGuides(textStyle: textTheme.displayMedium),
      displaySmall: playwriteAuNswGuides(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteAuNswGuides(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteAuNswGuides(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteAuNswGuides(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteAuNswGuides(textStyle: textTheme.titleLarge),
      titleMedium: playwriteAuNswGuides(textStyle: textTheme.titleMedium),
      titleSmall: playwriteAuNswGuides(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteAuNswGuides(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteAuNswGuides(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteAuNswGuides(textStyle: textTheme.bodySmall),
      labelLarge: playwriteAuNswGuides(textStyle: textTheme.labelLarge),
      labelMedium: playwriteAuNswGuides(textStyle: textTheme.labelMedium),
      labelSmall: playwriteAuNswGuides(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite AU QLD font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+AU+QLD
  static TextStyle playwriteAuQld({
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
        'f758f627cc78072b28827fbe77599ea6e8f8930ca5ba7a29a305ab2ea57c95e8',
        94980,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'b0d0803ffef50c01f12675d0525aa7b63ef1f800b4ee7051c335de65cd13beee',
        95084,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'bb16b31775b896ea51bb9ba6d856adcbd55e56de9c5d56edb3e15648f81f563e',
        94992,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '3c776fbf112f90a4458bb08110f4071b3a9cdf9867bbfe66b48d1a0aa2fb6de2',
        94812,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'e2f0d0800949901028610fbd45d40ea1254e8a6e5f42f86385ebf20bb9963950',
        140756,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteAUQLD',
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

  /// Applies the Playwrite AU QLD font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+AU+QLD
  static TextTheme playwriteAuQldTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteAuQld(textStyle: textTheme.displayLarge),
      displayMedium: playwriteAuQld(textStyle: textTheme.displayMedium),
      displaySmall: playwriteAuQld(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteAuQld(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteAuQld(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteAuQld(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteAuQld(textStyle: textTheme.titleLarge),
      titleMedium: playwriteAuQld(textStyle: textTheme.titleMedium),
      titleSmall: playwriteAuQld(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteAuQld(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteAuQld(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteAuQld(textStyle: textTheme.bodySmall),
      labelLarge: playwriteAuQld(textStyle: textTheme.labelLarge),
      labelMedium: playwriteAuQld(textStyle: textTheme.labelMedium),
      labelSmall: playwriteAuQld(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite AU QLD Guides font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+AU+QLD+Guides
  static TextStyle playwriteAuQldGuides({
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
        'dcc55eb7c367db42ae5132144c92132f49b798be6451c8cdc2f7ea52c6032b74',
        190812,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteAUQLDGuides',
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

  /// Applies the Playwrite AU QLD Guides font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+AU+QLD+Guides
  static TextTheme playwriteAuQldGuidesTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteAuQldGuides(textStyle: textTheme.displayLarge),
      displayMedium: playwriteAuQldGuides(textStyle: textTheme.displayMedium),
      displaySmall: playwriteAuQldGuides(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteAuQldGuides(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteAuQldGuides(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteAuQldGuides(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteAuQldGuides(textStyle: textTheme.titleLarge),
      titleMedium: playwriteAuQldGuides(textStyle: textTheme.titleMedium),
      titleSmall: playwriteAuQldGuides(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteAuQldGuides(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteAuQldGuides(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteAuQldGuides(textStyle: textTheme.bodySmall),
      labelLarge: playwriteAuQldGuides(textStyle: textTheme.labelLarge),
      labelMedium: playwriteAuQldGuides(textStyle: textTheme.labelMedium),
      labelSmall: playwriteAuQldGuides(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite AU SA font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+AU+SA
  static TextStyle playwriteAuSa({
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
        'a34c79393e083690ea39566619fa896bd95b32de97bf2617fec26bef2262c6a8',
        86792,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '490cfc4cd01fd975458bc8ae947af262db9f26f4999202a0ef00ac04932c640f',
        86844,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '898209456f4289e195d7cce57bd94674b7bd7714a48b3afabe4c135b010a87f8',
        86736,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '9a59d6d9ceb23835d5174f2926b5b0a714dd043c497f12f30c43fd3a97713c0e',
        86588,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '82aa02337a25a8f8aa6044c0a8d3233ce6ba731b61ecf74d3d922ccd35638471',
        128468,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteAUSA',
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

  /// Applies the Playwrite AU SA font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+AU+SA
  static TextTheme playwriteAuSaTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteAuSa(textStyle: textTheme.displayLarge),
      displayMedium: playwriteAuSa(textStyle: textTheme.displayMedium),
      displaySmall: playwriteAuSa(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteAuSa(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteAuSa(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteAuSa(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteAuSa(textStyle: textTheme.titleLarge),
      titleMedium: playwriteAuSa(textStyle: textTheme.titleMedium),
      titleSmall: playwriteAuSa(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteAuSa(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteAuSa(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteAuSa(textStyle: textTheme.bodySmall),
      labelLarge: playwriteAuSa(textStyle: textTheme.labelLarge),
      labelMedium: playwriteAuSa(textStyle: textTheme.labelMedium),
      labelSmall: playwriteAuSa(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite AU SA Guides font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+AU+SA+Guides
  static TextStyle playwriteAuSaGuides({
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
        '63e6fa25049c39412d3dee17aece74033bb824dcb75303f342c0df7201316218',
        183852,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteAUSAGuides',
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

  /// Applies the Playwrite AU SA Guides font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+AU+SA+Guides
  static TextTheme playwriteAuSaGuidesTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteAuSaGuides(textStyle: textTheme.displayLarge),
      displayMedium: playwriteAuSaGuides(textStyle: textTheme.displayMedium),
      displaySmall: playwriteAuSaGuides(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteAuSaGuides(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteAuSaGuides(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteAuSaGuides(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteAuSaGuides(textStyle: textTheme.titleLarge),
      titleMedium: playwriteAuSaGuides(textStyle: textTheme.titleMedium),
      titleSmall: playwriteAuSaGuides(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteAuSaGuides(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteAuSaGuides(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteAuSaGuides(textStyle: textTheme.bodySmall),
      labelLarge: playwriteAuSaGuides(textStyle: textTheme.labelLarge),
      labelMedium: playwriteAuSaGuides(textStyle: textTheme.labelMedium),
      labelSmall: playwriteAuSaGuides(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite AU TAS font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+AU+TAS
  static TextStyle playwriteAuTas({
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
        'fab8511c359214d66fd3294204a061f37a98b2b60af1c54e2910c16e20d77c9a',
        87052,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '253009c5a3a1246412a82c42fe760629aed2aa7df2ff20f8f4bc566cd4c53648',
        87220,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'd76c50772d9505d293614832c4afc393ddedb9cb5dbc73f78f29168583a4519a',
        87132,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'acbb2fce5387c4ed96033f65a69fac8ef66c7978f2671379a3e2fad2d9f05667',
        86976,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '1132f154cfcda392c7bef31d4f4e518c88d6bd9339e02e46f8411a12a372054a',
        129440,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteAUTAS',
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

  /// Applies the Playwrite AU TAS font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+AU+TAS
  static TextTheme playwriteAuTasTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteAuTas(textStyle: textTheme.displayLarge),
      displayMedium: playwriteAuTas(textStyle: textTheme.displayMedium),
      displaySmall: playwriteAuTas(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteAuTas(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteAuTas(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteAuTas(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteAuTas(textStyle: textTheme.titleLarge),
      titleMedium: playwriteAuTas(textStyle: textTheme.titleMedium),
      titleSmall: playwriteAuTas(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteAuTas(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteAuTas(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteAuTas(textStyle: textTheme.bodySmall),
      labelLarge: playwriteAuTas(textStyle: textTheme.labelLarge),
      labelMedium: playwriteAuTas(textStyle: textTheme.labelMedium),
      labelSmall: playwriteAuTas(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite AU TAS Guides font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+AU+TAS+Guides
  static TextStyle playwriteAuTasGuides({
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
        '8136fffe5de0c8ed174bf982bd724a72ff7c2d01b5bab6977304a41a6bfe23a2',
        184336,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteAUTASGuides',
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

  /// Applies the Playwrite AU TAS Guides font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+AU+TAS+Guides
  static TextTheme playwriteAuTasGuidesTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteAuTasGuides(textStyle: textTheme.displayLarge),
      displayMedium: playwriteAuTasGuides(textStyle: textTheme.displayMedium),
      displaySmall: playwriteAuTasGuides(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteAuTasGuides(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteAuTasGuides(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteAuTasGuides(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteAuTasGuides(textStyle: textTheme.titleLarge),
      titleMedium: playwriteAuTasGuides(textStyle: textTheme.titleMedium),
      titleSmall: playwriteAuTasGuides(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteAuTasGuides(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteAuTasGuides(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteAuTasGuides(textStyle: textTheme.bodySmall),
      labelLarge: playwriteAuTasGuides(textStyle: textTheme.labelLarge),
      labelMedium: playwriteAuTasGuides(textStyle: textTheme.labelMedium),
      labelSmall: playwriteAuTasGuides(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite AU VIC font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+AU+VIC
  static TextStyle playwriteAuVic({
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
        'b72eacd10e6add7c7347d9d5068321affec31cab3e6bcf28024bdefd59c1f658',
        101192,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '992546f02f367750fcfecbe4cbd24f00bd145985adfc878a6d69d5247ae317ff',
        101380,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'f7d7e526f6972ada22acafabfe39fc2edc4649ab97976c6527af90396a2a2b30',
        101300,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '38d5cee13478dd0533a552556cc971adc090341ffbb74711dcfcb5a0b98ca059',
        101100,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '8cdc492523b0acba8b5545d8c33310c67f03d5b9676310fad11bf149b1c619c1',
        150444,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteAUVIC',
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

  /// Applies the Playwrite AU VIC font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+AU+VIC
  static TextTheme playwriteAuVicTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteAuVic(textStyle: textTheme.displayLarge),
      displayMedium: playwriteAuVic(textStyle: textTheme.displayMedium),
      displaySmall: playwriteAuVic(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteAuVic(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteAuVic(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteAuVic(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteAuVic(textStyle: textTheme.titleLarge),
      titleMedium: playwriteAuVic(textStyle: textTheme.titleMedium),
      titleSmall: playwriteAuVic(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteAuVic(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteAuVic(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteAuVic(textStyle: textTheme.bodySmall),
      labelLarge: playwriteAuVic(textStyle: textTheme.labelLarge),
      labelMedium: playwriteAuVic(textStyle: textTheme.labelMedium),
      labelSmall: playwriteAuVic(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite AU VIC Guides font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+AU+VIC+Guides
  static TextStyle playwriteAuVicGuides({
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
        '9277ea815c50f3d1b101a80bf4077c01feeb9509d138d16c8702b1d691d0be9c',
        197116,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteAUVICGuides',
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

  /// Applies the Playwrite AU VIC Guides font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+AU+VIC+Guides
  static TextTheme playwriteAuVicGuidesTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteAuVicGuides(textStyle: textTheme.displayLarge),
      displayMedium: playwriteAuVicGuides(textStyle: textTheme.displayMedium),
      displaySmall: playwriteAuVicGuides(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteAuVicGuides(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteAuVicGuides(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteAuVicGuides(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteAuVicGuides(textStyle: textTheme.titleLarge),
      titleMedium: playwriteAuVicGuides(textStyle: textTheme.titleMedium),
      titleSmall: playwriteAuVicGuides(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteAuVicGuides(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteAuVicGuides(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteAuVicGuides(textStyle: textTheme.bodySmall),
      labelLarge: playwriteAuVicGuides(textStyle: textTheme.labelLarge),
      labelMedium: playwriteAuVicGuides(textStyle: textTheme.labelMedium),
      labelSmall: playwriteAuVicGuides(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite BE VLG font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+BE+VLG
  static TextStyle playwriteBeVlg({
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
        '902a93aaad857c413b090b4e3671a62ddeac4fea9cb7a5da0b03130c1ea66426',
        126492,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '2986f0aa85792fc3039857a1ceadc320a8f8d76dcdf1607c5cfa111181244318',
        126592,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '2dda29f7e0f5ddec5e073cc434a14ff59cc779e02011296938288294f71c57c4',
        126452,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '0dad9c9dd6711312a330426f232929d8fc2c0fde8c2ea4f2820f71c53de8c5e0',
        126160,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '33eb81ec0c322e176fd5508447445b88e9349600f4d3e2470fa064d334a51152',
        190412,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteBEVLG',
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

  /// Applies the Playwrite BE VLG font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+BE+VLG
  static TextTheme playwriteBeVlgTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteBeVlg(textStyle: textTheme.displayLarge),
      displayMedium: playwriteBeVlg(textStyle: textTheme.displayMedium),
      displaySmall: playwriteBeVlg(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteBeVlg(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteBeVlg(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteBeVlg(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteBeVlg(textStyle: textTheme.titleLarge),
      titleMedium: playwriteBeVlg(textStyle: textTheme.titleMedium),
      titleSmall: playwriteBeVlg(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteBeVlg(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteBeVlg(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteBeVlg(textStyle: textTheme.bodySmall),
      labelLarge: playwriteBeVlg(textStyle: textTheme.labelLarge),
      labelMedium: playwriteBeVlg(textStyle: textTheme.labelMedium),
      labelSmall: playwriteBeVlg(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite BE VLG Guides font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+BE+VLG+Guides
  static TextStyle playwriteBeVlgGuides({
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
        'cc0c289ef2b1d46ade40118d7832d4e0c9a264ad92981fc5178dbde069d66025',
        220468,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteBEVLGGuides',
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

  /// Applies the Playwrite BE VLG Guides font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+BE+VLG+Guides
  static TextTheme playwriteBeVlgGuidesTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteBeVlgGuides(textStyle: textTheme.displayLarge),
      displayMedium: playwriteBeVlgGuides(textStyle: textTheme.displayMedium),
      displaySmall: playwriteBeVlgGuides(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteBeVlgGuides(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteBeVlgGuides(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteBeVlgGuides(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteBeVlgGuides(textStyle: textTheme.titleLarge),
      titleMedium: playwriteBeVlgGuides(textStyle: textTheme.titleMedium),
      titleSmall: playwriteBeVlgGuides(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteBeVlgGuides(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteBeVlgGuides(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteBeVlgGuides(textStyle: textTheme.bodySmall),
      labelLarge: playwriteBeVlgGuides(textStyle: textTheme.labelLarge),
      labelMedium: playwriteBeVlgGuides(textStyle: textTheme.labelMedium),
      labelSmall: playwriteBeVlgGuides(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite BE WAL font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+BE+WAL
  static TextStyle playwriteBeWal({
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
        'd5a6530751e7ba3f4dc792376f89ac0471e8c4b854a830744daa3678c306cb2f',
        128536,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'f1eafea0b5bd2a60cbe9f8a8779907541281628baa08c47eea5d79812bfcffc4',
        128756,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '16bbd968b9ba16c8a18212a3ad3ed76f82ab2b5b4340326eb75173d5d5c08972',
        128808,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '35d506691ee1f97f284213b3466ee5a48f6f4533a804ba2fd87d5830ad64ea2d',
        128632,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '6b273d1abed156fb85ef5a4d55b4fe4300b15d302ebf4b86fc4c0bbf514de987',
        194684,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteBEWAL',
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

  /// Applies the Playwrite BE WAL font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+BE+WAL
  static TextTheme playwriteBeWalTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteBeWal(textStyle: textTheme.displayLarge),
      displayMedium: playwriteBeWal(textStyle: textTheme.displayMedium),
      displaySmall: playwriteBeWal(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteBeWal(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteBeWal(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteBeWal(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteBeWal(textStyle: textTheme.titleLarge),
      titleMedium: playwriteBeWal(textStyle: textTheme.titleMedium),
      titleSmall: playwriteBeWal(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteBeWal(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteBeWal(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteBeWal(textStyle: textTheme.bodySmall),
      labelLarge: playwriteBeWal(textStyle: textTheme.labelLarge),
      labelMedium: playwriteBeWal(textStyle: textTheme.labelMedium),
      labelSmall: playwriteBeWal(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite BE WAL Guides font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+BE+WAL+Guides
  static TextStyle playwriteBeWalGuides({
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
        'f3936d2f48069bdce257d92864061de5762fec5de5baa5cbdc90930ae0a3e50d',
        222060,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteBEWALGuides',
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

  /// Applies the Playwrite BE WAL Guides font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+BE+WAL+Guides
  static TextTheme playwriteBeWalGuidesTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteBeWalGuides(textStyle: textTheme.displayLarge),
      displayMedium: playwriteBeWalGuides(textStyle: textTheme.displayMedium),
      displaySmall: playwriteBeWalGuides(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteBeWalGuides(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteBeWalGuides(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteBeWalGuides(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteBeWalGuides(textStyle: textTheme.titleLarge),
      titleMedium: playwriteBeWalGuides(textStyle: textTheme.titleMedium),
      titleSmall: playwriteBeWalGuides(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteBeWalGuides(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteBeWalGuides(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteBeWalGuides(textStyle: textTheme.bodySmall),
      labelLarge: playwriteBeWalGuides(textStyle: textTheme.labelLarge),
      labelMedium: playwriteBeWalGuides(textStyle: textTheme.labelMedium),
      labelSmall: playwriteBeWalGuides(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite BR font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+BR
  static TextStyle playwriteBr({
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
        '274c236c91a0a281e7763329cf3b5d09222ddcfe8ef40c1a5313333bf78b7b08',
        130408,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '1cc340ce2730f1bb63677802b61dcb8c47e8ea80ae6c6c1818991e7725946fad',
        130636,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '50ee4148f422d9f1a1cdaaa125b0868ab5f21e264acb526f14e7e40c3b7252ad',
        130740,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'b3743e28e837d1cce928176906b547cac6d316c0eb0f955c5b7b5ffad74beb35',
        130468,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '3c4681121e89639e1aedf79bfc77d8b19a2bf0f1413c6fa2115cfe7427a3788e',
        196496,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteBR',
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

  /// Applies the Playwrite BR font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+BR
  static TextTheme playwriteBrTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteBr(textStyle: textTheme.displayLarge),
      displayMedium: playwriteBr(textStyle: textTheme.displayMedium),
      displaySmall: playwriteBr(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteBr(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteBr(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteBr(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteBr(textStyle: textTheme.titleLarge),
      titleMedium: playwriteBr(textStyle: textTheme.titleMedium),
      titleSmall: playwriteBr(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteBr(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteBr(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteBr(textStyle: textTheme.bodySmall),
      labelLarge: playwriteBr(textStyle: textTheme.labelLarge),
      labelMedium: playwriteBr(textStyle: textTheme.labelMedium),
      labelSmall: playwriteBr(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite BR Guides font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+BR+Guides
  static TextStyle playwriteBrGuides({
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
        '4a7464b8fa9f3589846c6fab271ee2969e148a8e9c6094526ec23bbc28c2665f',
        223880,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteBRGuides',
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

  /// Applies the Playwrite BR Guides font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+BR+Guides
  static TextTheme playwriteBrGuidesTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteBrGuides(textStyle: textTheme.displayLarge),
      displayMedium: playwriteBrGuides(textStyle: textTheme.displayMedium),
      displaySmall: playwriteBrGuides(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteBrGuides(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteBrGuides(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteBrGuides(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteBrGuides(textStyle: textTheme.titleLarge),
      titleMedium: playwriteBrGuides(textStyle: textTheme.titleMedium),
      titleSmall: playwriteBrGuides(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteBrGuides(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteBrGuides(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteBrGuides(textStyle: textTheme.bodySmall),
      labelLarge: playwriteBrGuides(textStyle: textTheme.labelLarge),
      labelMedium: playwriteBrGuides(textStyle: textTheme.labelMedium),
      labelSmall: playwriteBrGuides(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite CA font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+CA
  static TextStyle playwriteCa({
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
        '7394de190ad4e9ffc87c6f5a02de2eccd1ad74992713fa9d869b5cca82a01ecc',
        131596,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '30219d7b954bb324b8897dd2dd023f85a86b3d6bc44ee4ec53ed04ace82df8aa',
        131700,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '0c5bd39f6a49beb0513fa3b5b0f7c6d696d12e45ea82063d667a0541f8a6251f',
        131688,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '3b6831047cedd26ba707a812491dc42c349661cb06ede838b397d9a7f60bb15d',
        131432,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'e0722a50bf66621658c479b819231fb36333f9452066d4a4c48700c5fd22ed59',
        197916,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteCA',
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

  /// Applies the Playwrite CA font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+CA
  static TextTheme playwriteCaTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteCa(textStyle: textTheme.displayLarge),
      displayMedium: playwriteCa(textStyle: textTheme.displayMedium),
      displaySmall: playwriteCa(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteCa(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteCa(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteCa(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteCa(textStyle: textTheme.titleLarge),
      titleMedium: playwriteCa(textStyle: textTheme.titleMedium),
      titleSmall: playwriteCa(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteCa(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteCa(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteCa(textStyle: textTheme.bodySmall),
      labelLarge: playwriteCa(textStyle: textTheme.labelLarge),
      labelMedium: playwriteCa(textStyle: textTheme.labelMedium),
      labelSmall: playwriteCa(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite CA Guides font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+CA+Guides
  static TextStyle playwriteCaGuides({
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
        '822e3ddaeacfbc04b997a093d17e59e70ed7d66314f860804141aeb6fb069649',
        225956,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteCAGuides',
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

  /// Applies the Playwrite CA Guides font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+CA+Guides
  static TextTheme playwriteCaGuidesTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteCaGuides(textStyle: textTheme.displayLarge),
      displayMedium: playwriteCaGuides(textStyle: textTheme.displayMedium),
      displaySmall: playwriteCaGuides(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteCaGuides(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteCaGuides(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteCaGuides(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteCaGuides(textStyle: textTheme.titleLarge),
      titleMedium: playwriteCaGuides(textStyle: textTheme.titleMedium),
      titleSmall: playwriteCaGuides(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteCaGuides(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteCaGuides(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteCaGuides(textStyle: textTheme.bodySmall),
      labelLarge: playwriteCaGuides(textStyle: textTheme.labelLarge),
      labelMedium: playwriteCaGuides(textStyle: textTheme.labelMedium),
      labelSmall: playwriteCaGuides(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite CL font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+CL
  static TextStyle playwriteCl({
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
        '75a73d47cf3a14f99b17878b822b17537bdc61c72037e8fb7b80bd86496f2b7d',
        129968,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'b6e25b560b1ee580c3024d30ae4ba6c318b0cb149277ff89e1229e2fe14622a6',
        130220,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '4e5bffacddc58b6a8b053224d3d0c023fb43d66cc09709eb77f955e0a82d1380',
        130308,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'a7a15ac21d465a7b1843645d3989ded50779d5dfbaff27f278ae43d406d8718a',
        130052,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '9d80e8a2b3a137fb4f0c13f64d6fcb0c0a9160f57747470ca48d98533678e680',
        195836,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteCL',
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

  /// Applies the Playwrite CL font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+CL
  static TextTheme playwriteClTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteCl(textStyle: textTheme.displayLarge),
      displayMedium: playwriteCl(textStyle: textTheme.displayMedium),
      displaySmall: playwriteCl(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteCl(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteCl(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteCl(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteCl(textStyle: textTheme.titleLarge),
      titleMedium: playwriteCl(textStyle: textTheme.titleMedium),
      titleSmall: playwriteCl(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteCl(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteCl(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteCl(textStyle: textTheme.bodySmall),
      labelLarge: playwriteCl(textStyle: textTheme.labelLarge),
      labelMedium: playwriteCl(textStyle: textTheme.labelMedium),
      labelSmall: playwriteCl(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite CL Guides font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+CL+Guides
  static TextStyle playwriteClGuides({
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
        'fb2ba470ca8a1ab02ee3ba68388944e30be77d4b1d9861e20e5c1c736c3b6484',
        222820,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteCLGuides',
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

  /// Applies the Playwrite CL Guides font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+CL+Guides
  static TextTheme playwriteClGuidesTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteClGuides(textStyle: textTheme.displayLarge),
      displayMedium: playwriteClGuides(textStyle: textTheme.displayMedium),
      displaySmall: playwriteClGuides(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteClGuides(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteClGuides(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteClGuides(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteClGuides(textStyle: textTheme.titleLarge),
      titleMedium: playwriteClGuides(textStyle: textTheme.titleMedium),
      titleSmall: playwriteClGuides(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteClGuides(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteClGuides(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteClGuides(textStyle: textTheme.bodySmall),
      labelLarge: playwriteClGuides(textStyle: textTheme.labelLarge),
      labelMedium: playwriteClGuides(textStyle: textTheme.labelMedium),
      labelSmall: playwriteClGuides(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite CO font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+CO
  static TextStyle playwriteCo({
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
        '14af40c67ed21768a2ddb9404155b6ca2702e645c93aa8a8c653b07b7e4e56e1',
        130664,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'ca9a40a99ac8d03e2dbc130cba80a18d254f4d64053a4847c22581e29953354d',
        130696,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'c47130648149a8936d4bb29028b550df97280a50cbaa05cb3c8c31317ad1ffa7',
        130560,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'f2ad4e72bc785e1d40a18fb6cc645a6b9e46c8c62cd0316e31b6aa9cb3365310',
        130276,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'b482b0f55bc2ecda1e74d38eca5c158d28a486418f45245bbeffc65d5dde048f',
        196832,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteCO',
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

  /// Applies the Playwrite CO font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+CO
  static TextTheme playwriteCoTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteCo(textStyle: textTheme.displayLarge),
      displayMedium: playwriteCo(textStyle: textTheme.displayMedium),
      displaySmall: playwriteCo(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteCo(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteCo(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteCo(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteCo(textStyle: textTheme.titleLarge),
      titleMedium: playwriteCo(textStyle: textTheme.titleMedium),
      titleSmall: playwriteCo(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteCo(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteCo(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteCo(textStyle: textTheme.bodySmall),
      labelLarge: playwriteCo(textStyle: textTheme.labelLarge),
      labelMedium: playwriteCo(textStyle: textTheme.labelMedium),
      labelSmall: playwriteCo(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite CO Guides font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+CO+Guides
  static TextStyle playwriteCoGuides({
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
        '85cbe132b5e5a0ae39f4eecf849f2807d89eecc174f14a84cfc48ef0e114cc61',
        224904,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteCOGuides',
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

  /// Applies the Playwrite CO Guides font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+CO+Guides
  static TextTheme playwriteCoGuidesTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteCoGuides(textStyle: textTheme.displayLarge),
      displayMedium: playwriteCoGuides(textStyle: textTheme.displayMedium),
      displaySmall: playwriteCoGuides(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteCoGuides(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteCoGuides(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteCoGuides(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteCoGuides(textStyle: textTheme.titleLarge),
      titleMedium: playwriteCoGuides(textStyle: textTheme.titleMedium),
      titleSmall: playwriteCoGuides(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteCoGuides(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteCoGuides(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteCoGuides(textStyle: textTheme.bodySmall),
      labelLarge: playwriteCoGuides(textStyle: textTheme.labelLarge),
      labelMedium: playwriteCoGuides(textStyle: textTheme.labelMedium),
      labelSmall: playwriteCoGuides(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite CU font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+CU
  static TextStyle playwriteCu({
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
        '496a6b1c5543ace235f1a6cc2ec83912ee54112b28dcd6ae46f356d94011bdfa',
        131756,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '3eba6f9fce5d8b900d49c85851a339a9fcb496d8b69a912c307942a368cb37ef',
        131848,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '9e63c341da6cf9a069a195d372395cf2d9bfdb6599aa3d84e85d14d74ff87d43',
        131688,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'e4c5a006b0d267c88833f179db1b09e948c2c8fd038fe497d2bf3697faaa64f0',
        131440,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '5f27baa1b11317aca8ee65a33210d6135caa6959ce02a4d8ed118bcd8130bf83',
        198172,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteCU',
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

  /// Applies the Playwrite CU font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+CU
  static TextTheme playwriteCuTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteCu(textStyle: textTheme.displayLarge),
      displayMedium: playwriteCu(textStyle: textTheme.displayMedium),
      displaySmall: playwriteCu(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteCu(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteCu(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteCu(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteCu(textStyle: textTheme.titleLarge),
      titleMedium: playwriteCu(textStyle: textTheme.titleMedium),
      titleSmall: playwriteCu(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteCu(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteCu(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteCu(textStyle: textTheme.bodySmall),
      labelLarge: playwriteCu(textStyle: textTheme.labelLarge),
      labelMedium: playwriteCu(textStyle: textTheme.labelMedium),
      labelSmall: playwriteCu(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite CU Guides font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+CU+Guides
  static TextStyle playwriteCuGuides({
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
        'a29af3682906f73bea3e08b2b44cc40c7203a10f2a011b6dcafacde160e73988',
        227312,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteCUGuides',
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

  /// Applies the Playwrite CU Guides font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+CU+Guides
  static TextTheme playwriteCuGuidesTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteCuGuides(textStyle: textTheme.displayLarge),
      displayMedium: playwriteCuGuides(textStyle: textTheme.displayMedium),
      displaySmall: playwriteCuGuides(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteCuGuides(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteCuGuides(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteCuGuides(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteCuGuides(textStyle: textTheme.titleLarge),
      titleMedium: playwriteCuGuides(textStyle: textTheme.titleMedium),
      titleSmall: playwriteCuGuides(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteCuGuides(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteCuGuides(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteCuGuides(textStyle: textTheme.bodySmall),
      labelLarge: playwriteCuGuides(textStyle: textTheme.labelLarge),
      labelMedium: playwriteCuGuides(textStyle: textTheme.labelMedium),
      labelSmall: playwriteCuGuides(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite CZ font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+CZ
  static TextStyle playwriteCz({
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
        'b1b49a5f8f8c605d5da2e2d2184bab3592481cf4a98e3cc94ee7cf8bc0a2456e',
        128632,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '4049efadc2a5215b6e1a9875b78b680b2e91053e91da6aaf2316c1c573b0a09e',
        128740,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '8d0aff77bb77d7e5e42a99f97675e325bf7cd8de5d8a70d17c9e7a70f94b7816',
        128608,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '92ee2048a86a0f4709676d420af021f944b1f911c2c87ac7ab7bfe8d7fd5a56f',
        128372,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'c1578d02a95376988da720eb5ac74e0d23b30eef67cb347650f34dca58417271',
        193060,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteCZ',
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

  /// Applies the Playwrite CZ font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+CZ
  static TextTheme playwriteCzTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteCz(textStyle: textTheme.displayLarge),
      displayMedium: playwriteCz(textStyle: textTheme.displayMedium),
      displaySmall: playwriteCz(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteCz(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteCz(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteCz(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteCz(textStyle: textTheme.titleLarge),
      titleMedium: playwriteCz(textStyle: textTheme.titleMedium),
      titleSmall: playwriteCz(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteCz(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteCz(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteCz(textStyle: textTheme.bodySmall),
      labelLarge: playwriteCz(textStyle: textTheme.labelLarge),
      labelMedium: playwriteCz(textStyle: textTheme.labelMedium),
      labelSmall: playwriteCz(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite CZ Guides font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+CZ+Guides
  static TextStyle playwriteCzGuides({
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
        '75306d59e22a7480fa15e0cedb82b4c52556ebbd611783d503812aaa096e3e42',
        222976,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteCZGuides',
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

  /// Applies the Playwrite CZ Guides font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+CZ+Guides
  static TextTheme playwriteCzGuidesTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteCzGuides(textStyle: textTheme.displayLarge),
      displayMedium: playwriteCzGuides(textStyle: textTheme.displayMedium),
      displaySmall: playwriteCzGuides(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteCzGuides(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteCzGuides(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteCzGuides(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteCzGuides(textStyle: textTheme.titleLarge),
      titleMedium: playwriteCzGuides(textStyle: textTheme.titleMedium),
      titleSmall: playwriteCzGuides(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteCzGuides(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteCzGuides(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteCzGuides(textStyle: textTheme.bodySmall),
      labelLarge: playwriteCzGuides(textStyle: textTheme.labelLarge),
      labelMedium: playwriteCzGuides(textStyle: textTheme.labelMedium),
      labelSmall: playwriteCzGuides(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite DE Grund font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+DE+Grund
  static TextStyle playwriteDeGrund({
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
        'c30132bfffa081c5cc58f3680b195e774a78c02e2e9c2964c32643fa4db930a9',
        57088,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'd2c4d2b061ee3a04ad3e8fd20fcb4ae52f0914a5f69a256db19bf4d68afb3e69',
        57204,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '2555069974bcf14c2ca121964f0a3ab70de63a65bb001ee76a122ec676c65899',
        57124,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'e475da53f8b3f6cf3672826765ff071cda310b21fe115697fca6f273b661be8b',
        57080,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '2cde9c110adf5fd1dd126282d32b56b4fc996519234d68dc42e45ace11a7c0c4',
        85228,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteDEGrund',
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

  /// Applies the Playwrite DE Grund font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+DE+Grund
  static TextTheme playwriteDeGrundTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteDeGrund(textStyle: textTheme.displayLarge),
      displayMedium: playwriteDeGrund(textStyle: textTheme.displayMedium),
      displaySmall: playwriteDeGrund(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteDeGrund(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteDeGrund(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteDeGrund(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteDeGrund(textStyle: textTheme.titleLarge),
      titleMedium: playwriteDeGrund(textStyle: textTheme.titleMedium),
      titleSmall: playwriteDeGrund(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteDeGrund(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteDeGrund(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteDeGrund(textStyle: textTheme.bodySmall),
      labelLarge: playwriteDeGrund(textStyle: textTheme.labelLarge),
      labelMedium: playwriteDeGrund(textStyle: textTheme.labelMedium),
      labelSmall: playwriteDeGrund(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite DE Grund Guides font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+DE+Grund+Guides
  static TextStyle playwriteDeGrundGuides({
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
        '303183b3e11dc3e4312cb918f4def7b11b2c4c5857e4fa7e1cb91680d8db32fa',
        137528,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteDEGrundGuides',
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

  /// Applies the Playwrite DE Grund Guides font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+DE+Grund+Guides
  static TextTheme playwriteDeGrundGuidesTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteDeGrundGuides(textStyle: textTheme.displayLarge),
      displayMedium: playwriteDeGrundGuides(textStyle: textTheme.displayMedium),
      displaySmall: playwriteDeGrundGuides(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteDeGrundGuides(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteDeGrundGuides(
        textStyle: textTheme.headlineMedium,
      ),
      headlineSmall: playwriteDeGrundGuides(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteDeGrundGuides(textStyle: textTheme.titleLarge),
      titleMedium: playwriteDeGrundGuides(textStyle: textTheme.titleMedium),
      titleSmall: playwriteDeGrundGuides(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteDeGrundGuides(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteDeGrundGuides(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteDeGrundGuides(textStyle: textTheme.bodySmall),
      labelLarge: playwriteDeGrundGuides(textStyle: textTheme.labelLarge),
      labelMedium: playwriteDeGrundGuides(textStyle: textTheme.labelMedium),
      labelSmall: playwriteDeGrundGuides(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite DE LA font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+DE+LA
  static TextStyle playwriteDeLa({
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
        'ce1f920669a89ae493a13fbf95da2610ff1ca27e95795631414b8502bd93b320',
        125948,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '5624548c6130c017915c07f2c04ae5ef29b99433bcab7b346f30033fee20b6f6',
        126040,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'edd4a6fbb678219b9767acabf75aaf41946a18dac6d9387f2d23b1dc11d6a5b7',
        125992,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '19577ef5d3197730c6d2eb8cc5ebcfa26fc482bd25530aa4deabafdbf55456fc',
        125784,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'fe15d5c08e03e6847d9dd5a1c29e37b1143c0475dfeb6dd40d4a4af99d473eed',
        189696,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteDELA',
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

  /// Applies the Playwrite DE LA font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+DE+LA
  static TextTheme playwriteDeLaTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteDeLa(textStyle: textTheme.displayLarge),
      displayMedium: playwriteDeLa(textStyle: textTheme.displayMedium),
      displaySmall: playwriteDeLa(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteDeLa(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteDeLa(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteDeLa(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteDeLa(textStyle: textTheme.titleLarge),
      titleMedium: playwriteDeLa(textStyle: textTheme.titleMedium),
      titleSmall: playwriteDeLa(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteDeLa(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteDeLa(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteDeLa(textStyle: textTheme.bodySmall),
      labelLarge: playwriteDeLa(textStyle: textTheme.labelLarge),
      labelMedium: playwriteDeLa(textStyle: textTheme.labelMedium),
      labelSmall: playwriteDeLa(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite DE LA Guides font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+DE+LA+Guides
  static TextStyle playwriteDeLaGuides({
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
        'a0be1f7325e378223698235d7170b31dcf35d2d48924da6497990640d53bd677',
        220216,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteDELAGuides',
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

  /// Applies the Playwrite DE LA Guides font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+DE+LA+Guides
  static TextTheme playwriteDeLaGuidesTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteDeLaGuides(textStyle: textTheme.displayLarge),
      displayMedium: playwriteDeLaGuides(textStyle: textTheme.displayMedium),
      displaySmall: playwriteDeLaGuides(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteDeLaGuides(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteDeLaGuides(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteDeLaGuides(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteDeLaGuides(textStyle: textTheme.titleLarge),
      titleMedium: playwriteDeLaGuides(textStyle: textTheme.titleMedium),
      titleSmall: playwriteDeLaGuides(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteDeLaGuides(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteDeLaGuides(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteDeLaGuides(textStyle: textTheme.bodySmall),
      labelLarge: playwriteDeLaGuides(textStyle: textTheme.labelLarge),
      labelMedium: playwriteDeLaGuides(textStyle: textTheme.labelMedium),
      labelSmall: playwriteDeLaGuides(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite DE SAS font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+DE+SAS
  static TextStyle playwriteDeSas({
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
        '28e110160e2d775ce134d758fd273a257b11fb040536884c3538a5f09f620cd2',
        119024,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '8457cba941aa78f619c3c2febb402b777d3ebf89c6b886af5c0e901801652aab',
        119080,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'bbea7150a53ca0f85c1fa0f485d0ef79276c4130c6f2be377d19f295ebd24410',
        119012,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '2f8f7cd458e3fd72a460a4d69b73d47f54e32d431da6ab626a4d5b97b5505e03',
        118844,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'ea6f393478261d8cb9f8a77b1a7fda4cabe793f2d64784a18d1fbe02e339d04f',
        178452,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteDESAS',
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

  /// Applies the Playwrite DE SAS font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+DE+SAS
  static TextTheme playwriteDeSasTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteDeSas(textStyle: textTheme.displayLarge),
      displayMedium: playwriteDeSas(textStyle: textTheme.displayMedium),
      displaySmall: playwriteDeSas(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteDeSas(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteDeSas(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteDeSas(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteDeSas(textStyle: textTheme.titleLarge),
      titleMedium: playwriteDeSas(textStyle: textTheme.titleMedium),
      titleSmall: playwriteDeSas(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteDeSas(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteDeSas(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteDeSas(textStyle: textTheme.bodySmall),
      labelLarge: playwriteDeSas(textStyle: textTheme.labelLarge),
      labelMedium: playwriteDeSas(textStyle: textTheme.labelMedium),
      labelSmall: playwriteDeSas(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite DE SAS Guides font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+DE+SAS+Guides
  static TextStyle playwriteDeSasGuides({
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
        '34c95df3f77675297a4de767a78f401872da84fb72d04f2580959445cbbd9d58',
        213524,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteDESASGuides',
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

  /// Applies the Playwrite DE SAS Guides font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+DE+SAS+Guides
  static TextTheme playwriteDeSasGuidesTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteDeSasGuides(textStyle: textTheme.displayLarge),
      displayMedium: playwriteDeSasGuides(textStyle: textTheme.displayMedium),
      displaySmall: playwriteDeSasGuides(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteDeSasGuides(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteDeSasGuides(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteDeSasGuides(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteDeSasGuides(textStyle: textTheme.titleLarge),
      titleMedium: playwriteDeSasGuides(textStyle: textTheme.titleMedium),
      titleSmall: playwriteDeSasGuides(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteDeSasGuides(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteDeSasGuides(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteDeSasGuides(textStyle: textTheme.bodySmall),
      labelLarge: playwriteDeSasGuides(textStyle: textTheme.labelLarge),
      labelMedium: playwriteDeSasGuides(textStyle: textTheme.labelMedium),
      labelSmall: playwriteDeSasGuides(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite DE VA font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+DE+VA
  static TextStyle playwriteDeVa({
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
        '75ce10754ca9c4d88f90d241a59c6c5ab1faec45cd7e61bfd37136080d3b8526',
        111660,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'd88012c50fa29a2a53e32086b85964d910d12449ff6f6ebf96671aaf9890d60f',
        111724,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '8a5ca6d0ebc311ea66963dcb57f340f8b087706301e9ec6324867effb5b88304',
        111592,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'b9f17a21fa54b6c13d278b66545c45cb7c9a8eb8eb68eae27adc834cd1dd196e',
        111408,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '21ea055c298c4de8fb244b054c91828cf873a89d7434f7df07f58f99c1ddbcb8',
        166556,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteDEVA',
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

  /// Applies the Playwrite DE VA font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+DE+VA
  static TextTheme playwriteDeVaTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteDeVa(textStyle: textTheme.displayLarge),
      displayMedium: playwriteDeVa(textStyle: textTheme.displayMedium),
      displaySmall: playwriteDeVa(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteDeVa(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteDeVa(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteDeVa(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteDeVa(textStyle: textTheme.titleLarge),
      titleMedium: playwriteDeVa(textStyle: textTheme.titleMedium),
      titleSmall: playwriteDeVa(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteDeVa(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteDeVa(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteDeVa(textStyle: textTheme.bodySmall),
      labelLarge: playwriteDeVa(textStyle: textTheme.labelLarge),
      labelMedium: playwriteDeVa(textStyle: textTheme.labelMedium),
      labelSmall: playwriteDeVa(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite DE VA Guides font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+DE+VA+Guides
  static TextStyle playwriteDeVaGuides({
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
        '32bacb91e5d62c306cca8b45fb916f857cada263a1595881e3a3bcd99d5340f6',
        208692,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteDEVAGuides',
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

  /// Applies the Playwrite DE VA Guides font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+DE+VA+Guides
  static TextTheme playwriteDeVaGuidesTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteDeVaGuides(textStyle: textTheme.displayLarge),
      displayMedium: playwriteDeVaGuides(textStyle: textTheme.displayMedium),
      displaySmall: playwriteDeVaGuides(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteDeVaGuides(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteDeVaGuides(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteDeVaGuides(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteDeVaGuides(textStyle: textTheme.titleLarge),
      titleMedium: playwriteDeVaGuides(textStyle: textTheme.titleMedium),
      titleSmall: playwriteDeVaGuides(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteDeVaGuides(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteDeVaGuides(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteDeVaGuides(textStyle: textTheme.bodySmall),
      labelLarge: playwriteDeVaGuides(textStyle: textTheme.labelLarge),
      labelMedium: playwriteDeVaGuides(textStyle: textTheme.labelMedium),
      labelSmall: playwriteDeVaGuides(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite DK Loopet font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+DK+Loopet
  static TextStyle playwriteDkLoopet({
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
        'a933407ea05d8c47b489535ad347742a02671a9c2f6e0de14d0f0f2a511ad2c7',
        100192,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'ef8ffbed53b6a5a274fa99f8ed112d56ae6a2152edf12664cb237b9ac10aba16',
        100260,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'ce5f9b0f0360a6a9a20a48d05c65f6442e6e1769a4a8e99da43327237826a739',
        100128,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '491427f450a2773eda1c8d9b2047b60f9c341302603a44af86bb4df891f6337e',
        99824,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '7fa79d212008ffcbb31b04c3138f354f299270e0ca86c91523b9b4130c600fc7',
        148532,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteDKLoopet',
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

  /// Applies the Playwrite DK Loopet font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+DK+Loopet
  static TextTheme playwriteDkLoopetTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteDkLoopet(textStyle: textTheme.displayLarge),
      displayMedium: playwriteDkLoopet(textStyle: textTheme.displayMedium),
      displaySmall: playwriteDkLoopet(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteDkLoopet(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteDkLoopet(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteDkLoopet(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteDkLoopet(textStyle: textTheme.titleLarge),
      titleMedium: playwriteDkLoopet(textStyle: textTheme.titleMedium),
      titleSmall: playwriteDkLoopet(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteDkLoopet(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteDkLoopet(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteDkLoopet(textStyle: textTheme.bodySmall),
      labelLarge: playwriteDkLoopet(textStyle: textTheme.labelLarge),
      labelMedium: playwriteDkLoopet(textStyle: textTheme.labelMedium),
      labelSmall: playwriteDkLoopet(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite DK Loopet Guides font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+DK+Loopet+Guides
  static TextStyle playwriteDkLoopetGuides({
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
        'b744d7c0013e53f09f3d1c8b1d0144dbb784e9d26763868540feb89e5e50461c',
        195632,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteDKLoopetGuides',
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

  /// Applies the Playwrite DK Loopet Guides font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+DK+Loopet+Guides
  static TextTheme playwriteDkLoopetGuidesTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteDkLoopetGuides(textStyle: textTheme.displayLarge),
      displayMedium: playwriteDkLoopetGuides(
        textStyle: textTheme.displayMedium,
      ),
      displaySmall: playwriteDkLoopetGuides(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteDkLoopetGuides(
        textStyle: textTheme.headlineLarge,
      ),
      headlineMedium: playwriteDkLoopetGuides(
        textStyle: textTheme.headlineMedium,
      ),
      headlineSmall: playwriteDkLoopetGuides(
        textStyle: textTheme.headlineSmall,
      ),
      titleLarge: playwriteDkLoopetGuides(textStyle: textTheme.titleLarge),
      titleMedium: playwriteDkLoopetGuides(textStyle: textTheme.titleMedium),
      titleSmall: playwriteDkLoopetGuides(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteDkLoopetGuides(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteDkLoopetGuides(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteDkLoopetGuides(textStyle: textTheme.bodySmall),
      labelLarge: playwriteDkLoopetGuides(textStyle: textTheme.labelLarge),
      labelMedium: playwriteDkLoopetGuides(textStyle: textTheme.labelMedium),
      labelSmall: playwriteDkLoopetGuides(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite DK Uloopet font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+DK+Uloopet
  static TextStyle playwriteDkUloopet({
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
        'd9422b00b2a96135b0eee5c6c31c31daff73ac1f2948637c16e2c21dca2fbebe',
        92380,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'bde58bd0f968e3ba17112bc452b392e6230416fe1605dd7482c7f15af6679101',
        92444,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '3446a27b8a71a299e35590ce5f4c21eb04758229ebb38607af618e1750e5729e',
        92316,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'e70d81d3d685a3c15d31b3843051aee068d72aa1c68c6d8d50a495bdd0603131',
        92008,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'b6744130ae99896c9e0de3baa33e6365596aa60f6e4a8520f216fd552fe5eefe',
        136592,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteDKUloopet',
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

  /// Applies the Playwrite DK Uloopet font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+DK+Uloopet
  static TextTheme playwriteDkUloopetTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteDkUloopet(textStyle: textTheme.displayLarge),
      displayMedium: playwriteDkUloopet(textStyle: textTheme.displayMedium),
      displaySmall: playwriteDkUloopet(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteDkUloopet(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteDkUloopet(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteDkUloopet(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteDkUloopet(textStyle: textTheme.titleLarge),
      titleMedium: playwriteDkUloopet(textStyle: textTheme.titleMedium),
      titleSmall: playwriteDkUloopet(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteDkUloopet(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteDkUloopet(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteDkUloopet(textStyle: textTheme.bodySmall),
      labelLarge: playwriteDkUloopet(textStyle: textTheme.labelLarge),
      labelMedium: playwriteDkUloopet(textStyle: textTheme.labelMedium),
      labelSmall: playwriteDkUloopet(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite DK Uloopet Guides font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+DK+Uloopet+Guides
  static TextStyle playwriteDkUloopetGuides({
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
        '1ab2d54787df89e8a6bd9c4bc28cad13dbf22118a00b0df3b3af5fdd5434a094',
        188896,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteDKUloopetGuides',
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

  /// Applies the Playwrite DK Uloopet Guides font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+DK+Uloopet+Guides
  static TextTheme playwriteDkUloopetGuidesTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteDkUloopetGuides(textStyle: textTheme.displayLarge),
      displayMedium: playwriteDkUloopetGuides(
        textStyle: textTheme.displayMedium,
      ),
      displaySmall: playwriteDkUloopetGuides(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteDkUloopetGuides(
        textStyle: textTheme.headlineLarge,
      ),
      headlineMedium: playwriteDkUloopetGuides(
        textStyle: textTheme.headlineMedium,
      ),
      headlineSmall: playwriteDkUloopetGuides(
        textStyle: textTheme.headlineSmall,
      ),
      titleLarge: playwriteDkUloopetGuides(textStyle: textTheme.titleLarge),
      titleMedium: playwriteDkUloopetGuides(textStyle: textTheme.titleMedium),
      titleSmall: playwriteDkUloopetGuides(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteDkUloopetGuides(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteDkUloopetGuides(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteDkUloopetGuides(textStyle: textTheme.bodySmall),
      labelLarge: playwriteDkUloopetGuides(textStyle: textTheme.labelLarge),
      labelMedium: playwriteDkUloopetGuides(textStyle: textTheme.labelMedium),
      labelSmall: playwriteDkUloopetGuides(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite ES font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+ES
  static TextStyle playwriteEs({
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
        '3a9ab3ca002f436a034f1ee9460b6b81d71688bc0621813fc3bed439e52d88ef',
        106168,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '5168f90cc14ebfdf5d5c4c576df91b2ec840d51cffb8eeaa466f4fa6144e9bc8',
        106388,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '6a636fc62a5063cfe25779a9acf001c10bb897d2e831d5cece5a902c66d1eca4',
        106424,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '653b9ea078c2aaa82187b717aa564e9fbebfb243b798843cbbabecde9e3e2a03',
        106248,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '2785aadab9fd530c3bc3428900b8a349f3c6cd7adaa10df0f601816fb969ca4a',
        157928,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteES',
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

  /// Applies the Playwrite ES font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+ES
  static TextTheme playwriteEsTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteEs(textStyle: textTheme.displayLarge),
      displayMedium: playwriteEs(textStyle: textTheme.displayMedium),
      displaySmall: playwriteEs(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteEs(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteEs(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteEs(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteEs(textStyle: textTheme.titleLarge),
      titleMedium: playwriteEs(textStyle: textTheme.titleMedium),
      titleSmall: playwriteEs(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteEs(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteEs(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteEs(textStyle: textTheme.bodySmall),
      labelLarge: playwriteEs(textStyle: textTheme.labelLarge),
      labelMedium: playwriteEs(textStyle: textTheme.labelMedium),
      labelSmall: playwriteEs(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite ES Deco font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+ES+Deco
  static TextStyle playwriteEsDeco({
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
        '64996580b3b80772c1dc41ed690070f03fee5c402775a5aaa9fc6abe9b84bb9f',
        128036,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '2c04e0db23486b33a6ad588aef8dc345e731961ff49f8328a5cbaf46df6c0078',
        128272,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'bbf549dd782049b546c474e52d596e34bbd959ad42a5847861963221b058b3e0',
        128324,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'ccb2337fe6e86a46c0e8a214a0c748ac3f629568efc4512e31198fd735a6ebdc',
        128112,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'c402111901ac9ac1d0c5aa03c9fce1a48e1b67436ecaaaeb771ffbbd873d00e2',
        192780,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteESDeco',
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

  /// Applies the Playwrite ES Deco font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+ES+Deco
  static TextTheme playwriteEsDecoTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteEsDeco(textStyle: textTheme.displayLarge),
      displayMedium: playwriteEsDeco(textStyle: textTheme.displayMedium),
      displaySmall: playwriteEsDeco(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteEsDeco(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteEsDeco(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteEsDeco(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteEsDeco(textStyle: textTheme.titleLarge),
      titleMedium: playwriteEsDeco(textStyle: textTheme.titleMedium),
      titleSmall: playwriteEsDeco(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteEsDeco(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteEsDeco(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteEsDeco(textStyle: textTheme.bodySmall),
      labelLarge: playwriteEsDeco(textStyle: textTheme.labelLarge),
      labelMedium: playwriteEsDeco(textStyle: textTheme.labelMedium),
      labelSmall: playwriteEsDeco(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite ES Deco Guides font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+ES+Deco+Guides
  static TextStyle playwriteEsDecoGuides({
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
        '39517f38229164de24ab1471ae703ac5dcb87b4fe4196ae49815a95b7ef1e964',
        221792,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteESDecoGuides',
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

  /// Applies the Playwrite ES Deco Guides font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+ES+Deco+Guides
  static TextTheme playwriteEsDecoGuidesTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteEsDecoGuides(textStyle: textTheme.displayLarge),
      displayMedium: playwriteEsDecoGuides(textStyle: textTheme.displayMedium),
      displaySmall: playwriteEsDecoGuides(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteEsDecoGuides(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteEsDecoGuides(
        textStyle: textTheme.headlineMedium,
      ),
      headlineSmall: playwriteEsDecoGuides(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteEsDecoGuides(textStyle: textTheme.titleLarge),
      titleMedium: playwriteEsDecoGuides(textStyle: textTheme.titleMedium),
      titleSmall: playwriteEsDecoGuides(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteEsDecoGuides(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteEsDecoGuides(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteEsDecoGuides(textStyle: textTheme.bodySmall),
      labelLarge: playwriteEsDecoGuides(textStyle: textTheme.labelLarge),
      labelMedium: playwriteEsDecoGuides(textStyle: textTheme.labelMedium),
      labelSmall: playwriteEsDecoGuides(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite ES Guides font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+ES+Guides
  static TextStyle playwriteEsGuides({
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
        '072dffaa904a5c0c093bde9fb4c3e46f9d9ad587387a62c6262e9c2d055f19ae',
        199732,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteESGuides',
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

  /// Applies the Playwrite ES Guides font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+ES+Guides
  static TextTheme playwriteEsGuidesTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteEsGuides(textStyle: textTheme.displayLarge),
      displayMedium: playwriteEsGuides(textStyle: textTheme.displayMedium),
      displaySmall: playwriteEsGuides(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteEsGuides(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteEsGuides(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteEsGuides(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteEsGuides(textStyle: textTheme.titleLarge),
      titleMedium: playwriteEsGuides(textStyle: textTheme.titleMedium),
      titleSmall: playwriteEsGuides(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteEsGuides(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteEsGuides(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteEsGuides(textStyle: textTheme.bodySmall),
      labelLarge: playwriteEsGuides(textStyle: textTheme.labelLarge),
      labelMedium: playwriteEsGuides(textStyle: textTheme.labelMedium),
      labelSmall: playwriteEsGuides(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite FR Moderne font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+FR+Moderne
  static TextStyle playwriteFrModerne({
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
        '6c278493a3387130bccfbe10269e0572ec9749ea8702b8595c362ec1fa797e5a',
        84724,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '8fb636279a672841b144bcfba28e9a1c5d7ce0da5a08e2947a7c79395152e80a',
        84852,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '450d25f7a7362334e74ab66887483ca4ae87f47b852b7c44e9e753d354781c10',
        84796,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '4757836adf11f27b68647b33303bc15d00c594739f7041cf4feeedba177482a7',
        84608,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'acff79e59c90020c509dd270e23944d3766e894387c15389cfb084f0a8fd31a5',
        124900,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteFRModerne',
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

  /// Applies the Playwrite FR Moderne font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+FR+Moderne
  static TextTheme playwriteFrModerneTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteFrModerne(textStyle: textTheme.displayLarge),
      displayMedium: playwriteFrModerne(textStyle: textTheme.displayMedium),
      displaySmall: playwriteFrModerne(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteFrModerne(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteFrModerne(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteFrModerne(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteFrModerne(textStyle: textTheme.titleLarge),
      titleMedium: playwriteFrModerne(textStyle: textTheme.titleMedium),
      titleSmall: playwriteFrModerne(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteFrModerne(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteFrModerne(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteFrModerne(textStyle: textTheme.bodySmall),
      labelLarge: playwriteFrModerne(textStyle: textTheme.labelLarge),
      labelMedium: playwriteFrModerne(textStyle: textTheme.labelMedium),
      labelSmall: playwriteFrModerne(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite FR Moderne Guides font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+FR+Moderne+Guides
  static TextStyle playwriteFrModerneGuides({
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
        'd65df261c8d398962a59ff6c2af61e63918b16ce591d0d05ab8b02363ed0f534',
        180108,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteFRModerneGuides',
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

  /// Applies the Playwrite FR Moderne Guides font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+FR+Moderne+Guides
  static TextTheme playwriteFrModerneGuidesTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteFrModerneGuides(textStyle: textTheme.displayLarge),
      displayMedium: playwriteFrModerneGuides(
        textStyle: textTheme.displayMedium,
      ),
      displaySmall: playwriteFrModerneGuides(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteFrModerneGuides(
        textStyle: textTheme.headlineLarge,
      ),
      headlineMedium: playwriteFrModerneGuides(
        textStyle: textTheme.headlineMedium,
      ),
      headlineSmall: playwriteFrModerneGuides(
        textStyle: textTheme.headlineSmall,
      ),
      titleLarge: playwriteFrModerneGuides(textStyle: textTheme.titleLarge),
      titleMedium: playwriteFrModerneGuides(textStyle: textTheme.titleMedium),
      titleSmall: playwriteFrModerneGuides(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteFrModerneGuides(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteFrModerneGuides(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteFrModerneGuides(textStyle: textTheme.bodySmall),
      labelLarge: playwriteFrModerneGuides(textStyle: textTheme.labelLarge),
      labelMedium: playwriteFrModerneGuides(textStyle: textTheme.labelMedium),
      labelSmall: playwriteFrModerneGuides(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite FR Trad font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+FR+Trad
  static TextStyle playwriteFrTrad({
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
        'e2e785a2bf981b225854cd0286fdbe191b8ca4a38c714a52867a1c89e175ebc1',
        130440,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '1120f8bdff8e02cdb3be0970b9b0008991178b35839261db01377f1ce60756d4',
        130616,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '6b48c35b069d84624dfc80c37a368d6673e9ee041605329e94a789279149555a',
        130680,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '50e31171a3819bf505b0286a335b49f29aa34d2175610d39611b35511b635f0c',
        130476,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '1912fd4c97d8eece4d6666d271ef0c88f48c4a0d094366cef33b8ca9e1ecb9f8',
        196672,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteFRTrad',
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

  /// Applies the Playwrite FR Trad font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+FR+Trad
  static TextTheme playwriteFrTradTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteFrTrad(textStyle: textTheme.displayLarge),
      displayMedium: playwriteFrTrad(textStyle: textTheme.displayMedium),
      displaySmall: playwriteFrTrad(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteFrTrad(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteFrTrad(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteFrTrad(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteFrTrad(textStyle: textTheme.titleLarge),
      titleMedium: playwriteFrTrad(textStyle: textTheme.titleMedium),
      titleSmall: playwriteFrTrad(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteFrTrad(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteFrTrad(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteFrTrad(textStyle: textTheme.bodySmall),
      labelLarge: playwriteFrTrad(textStyle: textTheme.labelLarge),
      labelMedium: playwriteFrTrad(textStyle: textTheme.labelMedium),
      labelSmall: playwriteFrTrad(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite FR Trad Guides font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+FR+Trad+Guides
  static TextStyle playwriteFrTradGuides({
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
        '3be1ddac2c71d146bda1a1bc203dc2878a2b1873b676b69023fc05a8874f9ec2',
        223984,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteFRTradGuides',
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

  /// Applies the Playwrite FR Trad Guides font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+FR+Trad+Guides
  static TextTheme playwriteFrTradGuidesTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteFrTradGuides(textStyle: textTheme.displayLarge),
      displayMedium: playwriteFrTradGuides(textStyle: textTheme.displayMedium),
      displaySmall: playwriteFrTradGuides(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteFrTradGuides(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteFrTradGuides(
        textStyle: textTheme.headlineMedium,
      ),
      headlineSmall: playwriteFrTradGuides(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteFrTradGuides(textStyle: textTheme.titleLarge),
      titleMedium: playwriteFrTradGuides(textStyle: textTheme.titleMedium),
      titleSmall: playwriteFrTradGuides(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteFrTradGuides(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteFrTradGuides(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteFrTradGuides(textStyle: textTheme.bodySmall),
      labelLarge: playwriteFrTradGuides(textStyle: textTheme.labelLarge),
      labelMedium: playwriteFrTradGuides(textStyle: textTheme.labelMedium),
      labelSmall: playwriteFrTradGuides(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite GB J font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+GB+J
  static TextStyle playwriteGbJ({
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
        'be87d4c2f61676ba43c08de0c4b4b45496a036e9dc73f2ff89170e1e233db4a5',
        93144,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'dc78b3f4d1ab89407387d80f2feb13de2badff59d1fff26141e0be48795fc0de',
        93368,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'aeb5eab936f0c36dff7be3507dacb9bbb94a74093f8c0ac37b313cf65e7a630f',
        93356,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '52e21af958a0c1d1ce33901563b82a904d4d4ce0ab6bb7116bb21c31c99498b4',
        93124,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w100,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '90bc8e5b91257a669bcc99e856f360abafe4acc5936e2452959a40424128a797',
        94724,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '4e066383ee65d7c4091f4d1877d68259163f9c121e90b248f40b6dbac308c36e',
        94876,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '852d6ecf1e8a6a4d64f90e3ec37e461cfbce09613d52e56986c8e94f724ea0f7',
        94784,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '4daa41ade50c7f13b53d230ac8635e5aea9ad5a4f5eee577cdff1587865473be',
        94568,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '8e0f945ae9fb3990b37432f8c94055e108cfd9c1c7621ce78a52e68df673108a',
        138128,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'b59c7aa1000722b78cf5c3035a31d8eec41d6c3a34a66647c5cbb63244475d50',
        140288,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteGBJ',
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

  /// Applies the Playwrite GB J font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+GB+J
  static TextTheme playwriteGbJTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteGbJ(textStyle: textTheme.displayLarge),
      displayMedium: playwriteGbJ(textStyle: textTheme.displayMedium),
      displaySmall: playwriteGbJ(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteGbJ(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteGbJ(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteGbJ(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteGbJ(textStyle: textTheme.titleLarge),
      titleMedium: playwriteGbJ(textStyle: textTheme.titleMedium),
      titleSmall: playwriteGbJ(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteGbJ(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteGbJ(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteGbJ(textStyle: textTheme.bodySmall),
      labelLarge: playwriteGbJ(textStyle: textTheme.labelLarge),
      labelMedium: playwriteGbJ(textStyle: textTheme.labelMedium),
      labelSmall: playwriteGbJ(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite GB J Guides font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+GB+J+Guides
  static TextStyle playwriteGbJGuides({
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
        '80d6da313b5576d670dc0cc222d2dbfe6592734912357cc14cee3ff589baf23e',
        188200,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '7d3d9f26215cb47330cec8c196701ec7d9ff95d393541ceb795e76341e4ae444',
        191676,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteGBJGuides',
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

  /// Applies the Playwrite GB J Guides font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+GB+J+Guides
  static TextTheme playwriteGbJGuidesTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteGbJGuides(textStyle: textTheme.displayLarge),
      displayMedium: playwriteGbJGuides(textStyle: textTheme.displayMedium),
      displaySmall: playwriteGbJGuides(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteGbJGuides(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteGbJGuides(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteGbJGuides(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteGbJGuides(textStyle: textTheme.titleLarge),
      titleMedium: playwriteGbJGuides(textStyle: textTheme.titleMedium),
      titleSmall: playwriteGbJGuides(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteGbJGuides(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteGbJGuides(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteGbJGuides(textStyle: textTheme.bodySmall),
      labelLarge: playwriteGbJGuides(textStyle: textTheme.labelLarge),
      labelMedium: playwriteGbJGuides(textStyle: textTheme.labelMedium),
      labelSmall: playwriteGbJGuides(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite GB S font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+GB+S
  static TextStyle playwriteGbS({
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
        '2d49d49fb5ef61ede7cbb11fa21f1832a62c62d76908fa03d965883713c2419b',
        85304,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'bd16bd4dfd3a6c52a9cda94090d0dd8f13e48da89e1bb0125a1d176dc20ed562',
        85528,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '4e25b3dbc35833c464bf08a6403798fda614f2627ee6f27afc5e59b85dbd9d9f',
        85416,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '69dbaa4fe60ec6a833a601c6565856af72e2fb64a0259d79a77416fa8b013098',
        85244,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w100,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '0f4c82c89fea54037ece4e6f19f0e907487830c1e5eed9de73c19bea61239b1a',
        86752,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'baca3916146c9bc1c41874cafeff3f2728fc7aa32621207491fd2ca4fbf6730b',
        86972,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'ce0b2ec11f0d1fbc1fafcbfcdbfb5f0b5a4b15c4e7a62c926fd3505756e5d0c8',
        86884,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'e743c8d70cbfebc192bc04faa3a17ba4573783d8a9ad3abb94d566d80084bacd',
        86632,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '281c871dcb97c9d3b520aa2e9f6f9582e2581bd9bc9ad102879ad72eb62a516a',
        126668,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'fcc42f05b90a35525fe74dca126c87093a605b20f35c89df6b1969e6a52642b2',
        128680,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteGBS',
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

  /// Applies the Playwrite GB S font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+GB+S
  static TextTheme playwriteGbSTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteGbS(textStyle: textTheme.displayLarge),
      displayMedium: playwriteGbS(textStyle: textTheme.displayMedium),
      displaySmall: playwriteGbS(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteGbS(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteGbS(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteGbS(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteGbS(textStyle: textTheme.titleLarge),
      titleMedium: playwriteGbS(textStyle: textTheme.titleMedium),
      titleSmall: playwriteGbS(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteGbS(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteGbS(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteGbS(textStyle: textTheme.bodySmall),
      labelLarge: playwriteGbS(textStyle: textTheme.labelLarge),
      labelMedium: playwriteGbS(textStyle: textTheme.labelMedium),
      labelSmall: playwriteGbS(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite GB S Guides font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+GB+S+Guides
  static TextStyle playwriteGbSGuides({
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
        '8c69a508d7d8a76279fb7275245b563312c1c7173852537b05be5abf3b0cff96',
        180420,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'f0b744d143c2c1b220116c6731f2e202f68d977d38e9102509c32851457c5186',
        183904,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteGBSGuides',
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

  /// Applies the Playwrite GB S Guides font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+GB+S+Guides
  static TextTheme playwriteGbSGuidesTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteGbSGuides(textStyle: textTheme.displayLarge),
      displayMedium: playwriteGbSGuides(textStyle: textTheme.displayMedium),
      displaySmall: playwriteGbSGuides(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteGbSGuides(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteGbSGuides(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteGbSGuides(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteGbSGuides(textStyle: textTheme.titleLarge),
      titleMedium: playwriteGbSGuides(textStyle: textTheme.titleMedium),
      titleSmall: playwriteGbSGuides(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteGbSGuides(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteGbSGuides(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteGbSGuides(textStyle: textTheme.bodySmall),
      labelLarge: playwriteGbSGuides(textStyle: textTheme.labelLarge),
      labelMedium: playwriteGbSGuides(textStyle: textTheme.labelMedium),
      labelSmall: playwriteGbSGuides(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite HR font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+HR
  static TextStyle playwriteHr({
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
        '06c08b8962986f69110759bd357cf81a2d3f55c2bbce8f15b001d7977fbd6c47',
        121952,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '8596a0d9653f34b1a5bbb88be61112e6a0adce7151540dd2f11ce057fe9d11aa',
        122008,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '228e3fd463262a8ba3425c7e88b281cb5a7e45b2ad9c2bba46d0bc776f5267e7',
        121880,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '965d3a115ef28515b7439d4c8e6d8f74e95109a4aa81b9080a2057aea2dfd68a',
        121568,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '04a2c332eef7c299978fdda23ffe300f2c15d0dbe16406b18e13f6fdd09d0a74',
        182156,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteHR',
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

  /// Applies the Playwrite HR font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+HR
  static TextTheme playwriteHrTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteHr(textStyle: textTheme.displayLarge),
      displayMedium: playwriteHr(textStyle: textTheme.displayMedium),
      displaySmall: playwriteHr(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteHr(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteHr(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteHr(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteHr(textStyle: textTheme.titleLarge),
      titleMedium: playwriteHr(textStyle: textTheme.titleMedium),
      titleSmall: playwriteHr(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteHr(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteHr(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteHr(textStyle: textTheme.bodySmall),
      labelLarge: playwriteHr(textStyle: textTheme.labelLarge),
      labelMedium: playwriteHr(textStyle: textTheme.labelMedium),
      labelSmall: playwriteHr(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite HR Guides font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+HR+Guides
  static TextStyle playwriteHrGuides({
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
        'de18581e5206dd61b1d869a3cf3b3630a3e5ddf88c58fd27d81b78e21eac0bec',
        218692,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteHRGuides',
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

  /// Applies the Playwrite HR Guides font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+HR+Guides
  static TextTheme playwriteHrGuidesTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteHrGuides(textStyle: textTheme.displayLarge),
      displayMedium: playwriteHrGuides(textStyle: textTheme.displayMedium),
      displaySmall: playwriteHrGuides(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteHrGuides(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteHrGuides(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteHrGuides(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteHrGuides(textStyle: textTheme.titleLarge),
      titleMedium: playwriteHrGuides(textStyle: textTheme.titleMedium),
      titleSmall: playwriteHrGuides(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteHrGuides(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteHrGuides(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteHrGuides(textStyle: textTheme.bodySmall),
      labelLarge: playwriteHrGuides(textStyle: textTheme.labelLarge),
      labelMedium: playwriteHrGuides(textStyle: textTheme.labelMedium),
      labelSmall: playwriteHrGuides(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite HR Lijeva font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+HR+Lijeva
  static TextStyle playwriteHrLijeva({
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
        '7d31226cf116abf8b707fb080277e7172f29754e1bbeb310bd9f5d41e8f6dc2a',
        119752,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '21524ecc9cdd432d7067b74b46a4081d3974fff83d6f5b6e05db2cf15888c60e',
        120028,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'db08ed132a06aac7fdc2941a15784a5f1b4066154dc4b5bddf81eb80d71102ee',
        119976,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '01449cd5bd7024b01d2460e10c9bcdaed027788311a42404fe662a9fb44ee4cd',
        119724,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'fba76bd2dcba3f0d1c434ee3182bc2fad47442f90f830f1baad93e317f20ba8a',
        179320,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteHRLijeva',
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

  /// Applies the Playwrite HR Lijeva font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+HR+Lijeva
  static TextTheme playwriteHrLijevaTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteHrLijeva(textStyle: textTheme.displayLarge),
      displayMedium: playwriteHrLijeva(textStyle: textTheme.displayMedium),
      displaySmall: playwriteHrLijeva(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteHrLijeva(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteHrLijeva(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteHrLijeva(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteHrLijeva(textStyle: textTheme.titleLarge),
      titleMedium: playwriteHrLijeva(textStyle: textTheme.titleMedium),
      titleSmall: playwriteHrLijeva(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteHrLijeva(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteHrLijeva(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteHrLijeva(textStyle: textTheme.bodySmall),
      labelLarge: playwriteHrLijeva(textStyle: textTheme.labelLarge),
      labelMedium: playwriteHrLijeva(textStyle: textTheme.labelMedium),
      labelSmall: playwriteHrLijeva(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite HR Lijeva Guides font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+HR+Lijeva+Guides
  static TextStyle playwriteHrLijevaGuides({
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
        '4d85eb74904b04207bf29595e7a7fe9a50d4c973c888a6fcf6b82fc2c69bb934',
        214856,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteHRLijevaGuides',
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

  /// Applies the Playwrite HR Lijeva Guides font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+HR+Lijeva+Guides
  static TextTheme playwriteHrLijevaGuidesTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteHrLijevaGuides(textStyle: textTheme.displayLarge),
      displayMedium: playwriteHrLijevaGuides(
        textStyle: textTheme.displayMedium,
      ),
      displaySmall: playwriteHrLijevaGuides(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteHrLijevaGuides(
        textStyle: textTheme.headlineLarge,
      ),
      headlineMedium: playwriteHrLijevaGuides(
        textStyle: textTheme.headlineMedium,
      ),
      headlineSmall: playwriteHrLijevaGuides(
        textStyle: textTheme.headlineSmall,
      ),
      titleLarge: playwriteHrLijevaGuides(textStyle: textTheme.titleLarge),
      titleMedium: playwriteHrLijevaGuides(textStyle: textTheme.titleMedium),
      titleSmall: playwriteHrLijevaGuides(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteHrLijevaGuides(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteHrLijevaGuides(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteHrLijevaGuides(textStyle: textTheme.bodySmall),
      labelLarge: playwriteHrLijevaGuides(textStyle: textTheme.labelLarge),
      labelMedium: playwriteHrLijevaGuides(textStyle: textTheme.labelMedium),
      labelSmall: playwriteHrLijevaGuides(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite HU font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+HU
  static TextStyle playwriteHu({
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
        '29c8dd90904c22e5e784ab7ef78bcd0da0b06108c02628f1334ba8a325637b6a',
        119916,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '70b19eb3a5b08c048cb8e75998014413a0aa60eca41c2d8d2b257ba30f3d2c35',
        120148,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '4f91fa3c8fe54468796f9e7470e5c2438c5d0adf6c5f3eb560134b94ea825853',
        120088,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '028ac6d3a615a181cd463bcd71c49fa8b3901c1fcf411260547e4a91086cc388',
        119916,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '724deb92bb33e1b3edb6adb36b786e5266f1c6514ed3f6ff5aed1a4eb4a7c032',
        179992,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteHU',
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

  /// Applies the Playwrite HU font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+HU
  static TextTheme playwriteHuTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteHu(textStyle: textTheme.displayLarge),
      displayMedium: playwriteHu(textStyle: textTheme.displayMedium),
      displaySmall: playwriteHu(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteHu(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteHu(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteHu(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteHu(textStyle: textTheme.titleLarge),
      titleMedium: playwriteHu(textStyle: textTheme.titleMedium),
      titleSmall: playwriteHu(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteHu(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteHu(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteHu(textStyle: textTheme.bodySmall),
      labelLarge: playwriteHu(textStyle: textTheme.labelLarge),
      labelMedium: playwriteHu(textStyle: textTheme.labelMedium),
      labelSmall: playwriteHu(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite HU Guides font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+HU+Guides
  static TextStyle playwriteHuGuides({
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
        'b09ad5455f5f39a2ade38fd4828e5bccb611db4353d1588a21eb87e81e95b663',
        213324,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteHUGuides',
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

  /// Applies the Playwrite HU Guides font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+HU+Guides
  static TextTheme playwriteHuGuidesTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteHuGuides(textStyle: textTheme.displayLarge),
      displayMedium: playwriteHuGuides(textStyle: textTheme.displayMedium),
      displaySmall: playwriteHuGuides(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteHuGuides(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteHuGuides(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteHuGuides(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteHuGuides(textStyle: textTheme.titleLarge),
      titleMedium: playwriteHuGuides(textStyle: textTheme.titleMedium),
      titleSmall: playwriteHuGuides(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteHuGuides(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteHuGuides(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteHuGuides(textStyle: textTheme.bodySmall),
      labelLarge: playwriteHuGuides(textStyle: textTheme.labelLarge),
      labelMedium: playwriteHuGuides(textStyle: textTheme.labelMedium),
      labelSmall: playwriteHuGuides(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite ID font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+ID
  static TextStyle playwriteId({
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
        'afd6d8bca061e08692849c7d4853bf6469ecf6504c1ee102d4b92cc2efb9329a',
        126920,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'fbccbb3e9f677bc91ba2d15d6411e0fe20b2ce08850c10ff46e849a5421adff6',
        127136,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '37985fdae655106fbf11fd3bf371f50b467d98dba179a988a757b506e7994d5e',
        127220,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'e2bf18df9eb987fe8a34007343d732d6bb64e492a046f139e88209ae8d6a2800',
        127040,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '8e195dc42d95f4fd6a9b1e107a05f792258914e1146dcbc565f8adc2d3e6463a',
        190560,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteID',
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

  /// Applies the Playwrite ID font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+ID
  static TextTheme playwriteIdTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteId(textStyle: textTheme.displayLarge),
      displayMedium: playwriteId(textStyle: textTheme.displayMedium),
      displaySmall: playwriteId(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteId(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteId(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteId(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteId(textStyle: textTheme.titleLarge),
      titleMedium: playwriteId(textStyle: textTheme.titleMedium),
      titleSmall: playwriteId(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteId(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteId(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteId(textStyle: textTheme.bodySmall),
      labelLarge: playwriteId(textStyle: textTheme.labelLarge),
      labelMedium: playwriteId(textStyle: textTheme.labelMedium),
      labelSmall: playwriteId(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite ID Guides font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+ID+Guides
  static TextStyle playwriteIdGuides({
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
        '5374842f82496243aef2f4be78c536a98ae5a8ae4735604bb0e35af7bdf81016',
        221160,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteIDGuides',
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

  /// Applies the Playwrite ID Guides font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+ID+Guides
  static TextTheme playwriteIdGuidesTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteIdGuides(textStyle: textTheme.displayLarge),
      displayMedium: playwriteIdGuides(textStyle: textTheme.displayMedium),
      displaySmall: playwriteIdGuides(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteIdGuides(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteIdGuides(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteIdGuides(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteIdGuides(textStyle: textTheme.titleLarge),
      titleMedium: playwriteIdGuides(textStyle: textTheme.titleMedium),
      titleSmall: playwriteIdGuides(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteIdGuides(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteIdGuides(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteIdGuides(textStyle: textTheme.bodySmall),
      labelLarge: playwriteIdGuides(textStyle: textTheme.labelLarge),
      labelMedium: playwriteIdGuides(textStyle: textTheme.labelMedium),
      labelSmall: playwriteIdGuides(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite IE font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+IE
  static TextStyle playwriteIe({
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
        'c1ccbb0360d9876acffd7e764e7f3489343669c202196656b3ad09e4e5d5773c',
        123044,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '6082064d56c90bee1996de743bb6acb5f1c501fd896277099fd0517c3da6f599',
        123152,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '047e65ffb5898aab6ea70d83aea5bd8a065afb5c8fba7b5ac3e53e1a157e787a',
        122888,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '4dc13616461bfddc0c6b6cb120aaf71efa812878d8cda648f6f6c6facb5db4db',
        122684,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'bd6d56e6637521f4c0317774a60ff9b605d5ec81d67f4f77ee979c8ada3f52c4',
        184296,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteIE',
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

  /// Applies the Playwrite IE font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+IE
  static TextTheme playwriteIeTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteIe(textStyle: textTheme.displayLarge),
      displayMedium: playwriteIe(textStyle: textTheme.displayMedium),
      displaySmall: playwriteIe(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteIe(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteIe(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteIe(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteIe(textStyle: textTheme.titleLarge),
      titleMedium: playwriteIe(textStyle: textTheme.titleMedium),
      titleSmall: playwriteIe(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteIe(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteIe(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteIe(textStyle: textTheme.bodySmall),
      labelLarge: playwriteIe(textStyle: textTheme.labelLarge),
      labelMedium: playwriteIe(textStyle: textTheme.labelMedium),
      labelSmall: playwriteIe(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite IE Guides font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+IE+Guides
  static TextStyle playwriteIeGuides({
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
        'a1eccb52f58b8cd58e1b78e6edc303bf20b2093ac9c4e84705c45631136af0b3',
        219552,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteIEGuides',
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

  /// Applies the Playwrite IE Guides font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+IE+Guides
  static TextTheme playwriteIeGuidesTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteIeGuides(textStyle: textTheme.displayLarge),
      displayMedium: playwriteIeGuides(textStyle: textTheme.displayMedium),
      displaySmall: playwriteIeGuides(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteIeGuides(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteIeGuides(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteIeGuides(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteIeGuides(textStyle: textTheme.titleLarge),
      titleMedium: playwriteIeGuides(textStyle: textTheme.titleMedium),
      titleSmall: playwriteIeGuides(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteIeGuides(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteIeGuides(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteIeGuides(textStyle: textTheme.bodySmall),
      labelLarge: playwriteIeGuides(textStyle: textTheme.labelLarge),
      labelMedium: playwriteIeGuides(textStyle: textTheme.labelMedium),
      labelSmall: playwriteIeGuides(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite IN font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+IN
  static TextStyle playwriteIn({
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
        '16def864f9d3817eeffc71aee574cb6d3f024db9895c043e424eba5bb212c681',
        132048,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'e1b805e37f9aeec96e6d6f5b44c025eb2491f585e02fb603c06bb66518fc1c1b',
        132236,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '7b4786843d5700813c95cece646d2e34cee39de35fca40eebf247427bdfbc442',
        132108,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '603160793b034161ffc112c8f1f63a18b466121cdbbbc5c29d8e307c66771c1f',
        131940,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'ea5801a5140fcc81098fc3034cdcacb8fee58505f881af393c552e3e905982bb',
        198856,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteIN',
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

  /// Applies the Playwrite IN font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+IN
  static TextTheme playwriteInTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteIn(textStyle: textTheme.displayLarge),
      displayMedium: playwriteIn(textStyle: textTheme.displayMedium),
      displaySmall: playwriteIn(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteIn(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteIn(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteIn(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteIn(textStyle: textTheme.titleLarge),
      titleMedium: playwriteIn(textStyle: textTheme.titleMedium),
      titleSmall: playwriteIn(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteIn(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteIn(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteIn(textStyle: textTheme.bodySmall),
      labelLarge: playwriteIn(textStyle: textTheme.labelLarge),
      labelMedium: playwriteIn(textStyle: textTheme.labelMedium),
      labelSmall: playwriteIn(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite IN Guides font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+IN+Guides
  static TextStyle playwriteInGuides({
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
        'e0b7efab8c8e43a09b8b7e014cf9d8915c1f0f8bb5f8dd46c944beac33c38b24',
        227164,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteINGuides',
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

  /// Applies the Playwrite IN Guides font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+IN+Guides
  static TextTheme playwriteInGuidesTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteInGuides(textStyle: textTheme.displayLarge),
      displayMedium: playwriteInGuides(textStyle: textTheme.displayMedium),
      displaySmall: playwriteInGuides(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteInGuides(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteInGuides(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteInGuides(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteInGuides(textStyle: textTheme.titleLarge),
      titleMedium: playwriteInGuides(textStyle: textTheme.titleMedium),
      titleSmall: playwriteInGuides(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteInGuides(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteInGuides(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteInGuides(textStyle: textTheme.bodySmall),
      labelLarge: playwriteInGuides(textStyle: textTheme.labelLarge),
      labelMedium: playwriteInGuides(textStyle: textTheme.labelMedium),
      labelSmall: playwriteInGuides(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite IS font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+IS
  static TextStyle playwriteIs({
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
        'c4fe5312173a738fc634dcce26ee43858905d94c075f2133c95be31fef7f551f',
        88004,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '0c3cf2cdfc688c7ba4f810342c62f64748a0dcf4cf372d88fcd5caa6f17dd022',
        88196,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'f1df1bf79846f4dca7a7d8c034f05f0aab668fa54ef01e0edc0de71ba946e12a',
        87988,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '780cf13115710e4c6d14e459e9811d95a01e9dca3bb32ce1ff404b1427274bb7',
        87852,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '7828a272f63a5b9bb281a89d8df87354961560210ce8fd923ebce53916e4cae7',
        130492,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteIS',
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

  /// Applies the Playwrite IS font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+IS
  static TextTheme playwriteIsTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteIs(textStyle: textTheme.displayLarge),
      displayMedium: playwriteIs(textStyle: textTheme.displayMedium),
      displaySmall: playwriteIs(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteIs(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteIs(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteIs(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteIs(textStyle: textTheme.titleLarge),
      titleMedium: playwriteIs(textStyle: textTheme.titleMedium),
      titleSmall: playwriteIs(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteIs(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteIs(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteIs(textStyle: textTheme.bodySmall),
      labelLarge: playwriteIs(textStyle: textTheme.labelLarge),
      labelMedium: playwriteIs(textStyle: textTheme.labelMedium),
      labelSmall: playwriteIs(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite IS Guides font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+IS+Guides
  static TextStyle playwriteIsGuides({
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
        '39bacdf4049933ca6b66959ef5fbadaa293ff8fb3244dc90d952d5a94e192447',
        184152,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteISGuides',
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

  /// Applies the Playwrite IS Guides font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+IS+Guides
  static TextTheme playwriteIsGuidesTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteIsGuides(textStyle: textTheme.displayLarge),
      displayMedium: playwriteIsGuides(textStyle: textTheme.displayMedium),
      displaySmall: playwriteIsGuides(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteIsGuides(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteIsGuides(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteIsGuides(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteIsGuides(textStyle: textTheme.titleLarge),
      titleMedium: playwriteIsGuides(textStyle: textTheme.titleMedium),
      titleSmall: playwriteIsGuides(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteIsGuides(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteIsGuides(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteIsGuides(textStyle: textTheme.bodySmall),
      labelLarge: playwriteIsGuides(textStyle: textTheme.labelLarge),
      labelMedium: playwriteIsGuides(textStyle: textTheme.labelMedium),
      labelSmall: playwriteIsGuides(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite IT Moderna font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+IT+Moderna
  static TextStyle playwriteItModerna({
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
        '95fac06604cf36b2c30b02f42880870b83c6c42b8c0e37ed2e6249a22c708340',
        92584,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '6348cc529a43bb54964c692ec78d5a0b0c1579921db6e3cc53f3e701d2b13bb2',
        92800,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'c5f557cc228eca40aacaf82a2368869405091282d5f8f803ade75bad1c541a53',
        92788,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '266488db1b17a8c08f4619f93eba3355ca31bafe206c2e6f988eb8ac146cc92b',
        92572,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'dbb041548442fb71862584b1df092c5ac31256b3c89b8b9a72e47a7272b50da0',
        137068,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteITModerna',
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

  /// Applies the Playwrite IT Moderna font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+IT+Moderna
  static TextTheme playwriteItModernaTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteItModerna(textStyle: textTheme.displayLarge),
      displayMedium: playwriteItModerna(textStyle: textTheme.displayMedium),
      displaySmall: playwriteItModerna(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteItModerna(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteItModerna(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteItModerna(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteItModerna(textStyle: textTheme.titleLarge),
      titleMedium: playwriteItModerna(textStyle: textTheme.titleMedium),
      titleSmall: playwriteItModerna(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteItModerna(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteItModerna(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteItModerna(textStyle: textTheme.bodySmall),
      labelLarge: playwriteItModerna(textStyle: textTheme.labelLarge),
      labelMedium: playwriteItModerna(textStyle: textTheme.labelMedium),
      labelSmall: playwriteItModerna(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite IT Moderna Guides font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+IT+Moderna+Guides
  static TextStyle playwriteItModernaGuides({
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
        'f216dd17662f61decfbbda1027736716684444a1f4877fcf6bbc9e4608b4a898',
        188892,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteITModernaGuides',
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

  /// Applies the Playwrite IT Moderna Guides font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+IT+Moderna+Guides
  static TextTheme playwriteItModernaGuidesTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteItModernaGuides(textStyle: textTheme.displayLarge),
      displayMedium: playwriteItModernaGuides(
        textStyle: textTheme.displayMedium,
      ),
      displaySmall: playwriteItModernaGuides(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteItModernaGuides(
        textStyle: textTheme.headlineLarge,
      ),
      headlineMedium: playwriteItModernaGuides(
        textStyle: textTheme.headlineMedium,
      ),
      headlineSmall: playwriteItModernaGuides(
        textStyle: textTheme.headlineSmall,
      ),
      titleLarge: playwriteItModernaGuides(textStyle: textTheme.titleLarge),
      titleMedium: playwriteItModernaGuides(textStyle: textTheme.titleMedium),
      titleSmall: playwriteItModernaGuides(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteItModernaGuides(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteItModernaGuides(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteItModernaGuides(textStyle: textTheme.bodySmall),
      labelLarge: playwriteItModernaGuides(textStyle: textTheme.labelLarge),
      labelMedium: playwriteItModernaGuides(textStyle: textTheme.labelMedium),
      labelSmall: playwriteItModernaGuides(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite IT Trad font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+IT+Trad
  static TextStyle playwriteItTrad({
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
        '812a1961bcb3ffefac3468240e1cbc310e26dd816609baa116649c217c3e0f23',
        125484,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'efce0ac841a3ca29aba3b0a8ca5b62e739199a1954b6823db9da448c3c305f40',
        125684,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'f12adef1fa846f8b7bc699e053f161307b0e296200e9301f7907411191c8f202',
        125608,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '46b1b8e3671f79a7028ffec23a630ed32c1860320debda6cac5748b6250bd90f',
        125460,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '50b96d882766343e163ad518fe96676a4b2cb7f265f7deab3a99b5c349c37153',
        189192,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteITTrad',
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

  /// Applies the Playwrite IT Trad font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+IT+Trad
  static TextTheme playwriteItTradTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteItTrad(textStyle: textTheme.displayLarge),
      displayMedium: playwriteItTrad(textStyle: textTheme.displayMedium),
      displaySmall: playwriteItTrad(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteItTrad(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteItTrad(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteItTrad(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteItTrad(textStyle: textTheme.titleLarge),
      titleMedium: playwriteItTrad(textStyle: textTheme.titleMedium),
      titleSmall: playwriteItTrad(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteItTrad(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteItTrad(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteItTrad(textStyle: textTheme.bodySmall),
      labelLarge: playwriteItTrad(textStyle: textTheme.labelLarge),
      labelMedium: playwriteItTrad(textStyle: textTheme.labelMedium),
      labelSmall: playwriteItTrad(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite IT Trad Guides font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+IT+Trad+Guides
  static TextStyle playwriteItTradGuides({
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
        '0eb1d52a493cac75b74cd07cfeff7e69cf09f6b579b37005df1a4e4dbd0b6ca9',
        217932,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteITTradGuides',
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

  /// Applies the Playwrite IT Trad Guides font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+IT+Trad+Guides
  static TextTheme playwriteItTradGuidesTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteItTradGuides(textStyle: textTheme.displayLarge),
      displayMedium: playwriteItTradGuides(textStyle: textTheme.displayMedium),
      displaySmall: playwriteItTradGuides(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteItTradGuides(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteItTradGuides(
        textStyle: textTheme.headlineMedium,
      ),
      headlineSmall: playwriteItTradGuides(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteItTradGuides(textStyle: textTheme.titleLarge),
      titleMedium: playwriteItTradGuides(textStyle: textTheme.titleMedium),
      titleSmall: playwriteItTradGuides(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteItTradGuides(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteItTradGuides(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteItTradGuides(textStyle: textTheme.bodySmall),
      labelLarge: playwriteItTradGuides(textStyle: textTheme.labelLarge),
      labelMedium: playwriteItTradGuides(textStyle: textTheme.labelMedium),
      labelSmall: playwriteItTradGuides(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite MX font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+MX
  static TextStyle playwriteMx({
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
        'ff47ecd1b3dee5fb140b4fd64621ceb95dfb44b7715d023cc14ade37f2b3290d',
        131720,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'acede31b953e03ceb68c20853f3ae734a77e21a6718c8af5110dd23a82a9e047',
        131764,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '315766fefca0c1e2b6e969f5fcde0665f8a4687e06da91eac59fc24d10b1f9ac',
        131624,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'bcc25470a7304fb0f6ef97097114e758e2d49a762b2fe1ce966b6a56b392e8f8',
        131344,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '4fdf0e5b05590e8915eaebe6344a251117f7e61d30a87bdf19e077e2a4b07ba7',
        198252,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteMX',
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

  /// Applies the Playwrite MX font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+MX
  static TextTheme playwriteMxTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteMx(textStyle: textTheme.displayLarge),
      displayMedium: playwriteMx(textStyle: textTheme.displayMedium),
      displaySmall: playwriteMx(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteMx(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteMx(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteMx(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteMx(textStyle: textTheme.titleLarge),
      titleMedium: playwriteMx(textStyle: textTheme.titleMedium),
      titleSmall: playwriteMx(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteMx(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteMx(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteMx(textStyle: textTheme.bodySmall),
      labelLarge: playwriteMx(textStyle: textTheme.labelLarge),
      labelMedium: playwriteMx(textStyle: textTheme.labelMedium),
      labelSmall: playwriteMx(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite MX Guides font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+MX+Guides
  static TextStyle playwriteMxGuides({
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
        'c9aa9fa96ed1000cfcffb299875caa7bfbba3302784ba7fb5e83356fc114a21a',
        227044,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteMXGuides',
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

  /// Applies the Playwrite MX Guides font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+MX+Guides
  static TextTheme playwriteMxGuidesTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteMxGuides(textStyle: textTheme.displayLarge),
      displayMedium: playwriteMxGuides(textStyle: textTheme.displayMedium),
      displaySmall: playwriteMxGuides(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteMxGuides(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteMxGuides(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteMxGuides(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteMxGuides(textStyle: textTheme.titleLarge),
      titleMedium: playwriteMxGuides(textStyle: textTheme.titleMedium),
      titleSmall: playwriteMxGuides(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteMxGuides(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteMxGuides(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteMxGuides(textStyle: textTheme.bodySmall),
      labelLarge: playwriteMxGuides(textStyle: textTheme.labelLarge),
      labelMedium: playwriteMxGuides(textStyle: textTheme.labelMedium),
      labelSmall: playwriteMxGuides(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite NG Modern font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+NG+Modern
  static TextStyle playwriteNgModern({
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
        '5f6db1c9078807f43c2e8dc63e2a678cecc71f162ff6dab78bab2224ce3d82c7',
        85232,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'ad318322d9687ca63c93953543764e1803278f59d261c7a0c56789a83146edf4',
        85408,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '5819cf5b8c15f008fe0db3f4984c81ab632b3b3911303feb24cc6858b38d1c3b',
        85384,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'd9733ce5e1e9d2270b1663af57018957d7f7855a2c5548c03ddfc96cfc6811ec',
        85260,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '2e652b1a2c58f5aa1a02bdf9a50049a0c879db9fd284684d3ec16309d7bbbad3',
        126764,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteNGModern',
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

  /// Applies the Playwrite NG Modern font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+NG+Modern
  static TextTheme playwriteNgModernTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteNgModern(textStyle: textTheme.displayLarge),
      displayMedium: playwriteNgModern(textStyle: textTheme.displayMedium),
      displaySmall: playwriteNgModern(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteNgModern(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteNgModern(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteNgModern(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteNgModern(textStyle: textTheme.titleLarge),
      titleMedium: playwriteNgModern(textStyle: textTheme.titleMedium),
      titleSmall: playwriteNgModern(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteNgModern(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteNgModern(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteNgModern(textStyle: textTheme.bodySmall),
      labelLarge: playwriteNgModern(textStyle: textTheme.labelLarge),
      labelMedium: playwriteNgModern(textStyle: textTheme.labelMedium),
      labelSmall: playwriteNgModern(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite NG Modern Guides font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+NG+Modern+Guides
  static TextStyle playwriteNgModernGuides({
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
        'c3ad4bf63a1f3239d70e7d93eb130f8484bb32b7954bcbb552961410f1af05c4',
        180612,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteNGModernGuides',
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

  /// Applies the Playwrite NG Modern Guides font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+NG+Modern+Guides
  static TextTheme playwriteNgModernGuidesTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteNgModernGuides(textStyle: textTheme.displayLarge),
      displayMedium: playwriteNgModernGuides(
        textStyle: textTheme.displayMedium,
      ),
      displaySmall: playwriteNgModernGuides(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteNgModernGuides(
        textStyle: textTheme.headlineLarge,
      ),
      headlineMedium: playwriteNgModernGuides(
        textStyle: textTheme.headlineMedium,
      ),
      headlineSmall: playwriteNgModernGuides(
        textStyle: textTheme.headlineSmall,
      ),
      titleLarge: playwriteNgModernGuides(textStyle: textTheme.titleLarge),
      titleMedium: playwriteNgModernGuides(textStyle: textTheme.titleMedium),
      titleSmall: playwriteNgModernGuides(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteNgModernGuides(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteNgModernGuides(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteNgModernGuides(textStyle: textTheme.bodySmall),
      labelLarge: playwriteNgModernGuides(textStyle: textTheme.labelLarge),
      labelMedium: playwriteNgModernGuides(textStyle: textTheme.labelMedium),
      labelSmall: playwriteNgModernGuides(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite NL font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+NL
  static TextStyle playwriteNl({
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
        'ca0bb9c30df19eea60f3500355dd254ac05eef5aa2ecf368235ecfb1df70703b',
        127808,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'c9df803779613547788fe091479dfcc26de657001fdbb2b7caf6b9c1ea8122f0',
        127840,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'cc67a8b7ab81a942c19287f44aece7edbacd017a445cb8ae72fd0c64f31dbef2',
        127760,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'f49ceaccc3eee72413663e5fd2c863ce464c065591c423519049c36f59fd97ca',
        127540,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'e8a490391e92212862718066a2d80f9ecc6552be909331d0b425da4a8ba949eb',
        191380,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteNL',
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

  /// Applies the Playwrite NL font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+NL
  static TextTheme playwriteNlTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteNl(textStyle: textTheme.displayLarge),
      displayMedium: playwriteNl(textStyle: textTheme.displayMedium),
      displaySmall: playwriteNl(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteNl(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteNl(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteNl(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteNl(textStyle: textTheme.titleLarge),
      titleMedium: playwriteNl(textStyle: textTheme.titleMedium),
      titleSmall: playwriteNl(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteNl(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteNl(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteNl(textStyle: textTheme.bodySmall),
      labelLarge: playwriteNl(textStyle: textTheme.labelLarge),
      labelMedium: playwriteNl(textStyle: textTheme.labelMedium),
      labelSmall: playwriteNl(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite NL Guides font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+NL+Guides
  static TextStyle playwriteNlGuides({
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
        '7215190ac0c8c5325240381fbf5c781cebb22a8df737317c4f420154336400d2',
        222508,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteNLGuides',
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

  /// Applies the Playwrite NL Guides font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+NL+Guides
  static TextTheme playwriteNlGuidesTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteNlGuides(textStyle: textTheme.displayLarge),
      displayMedium: playwriteNlGuides(textStyle: textTheme.displayMedium),
      displaySmall: playwriteNlGuides(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteNlGuides(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteNlGuides(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteNlGuides(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteNlGuides(textStyle: textTheme.titleLarge),
      titleMedium: playwriteNlGuides(textStyle: textTheme.titleMedium),
      titleSmall: playwriteNlGuides(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteNlGuides(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteNlGuides(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteNlGuides(textStyle: textTheme.bodySmall),
      labelLarge: playwriteNlGuides(textStyle: textTheme.labelLarge),
      labelMedium: playwriteNlGuides(textStyle: textTheme.labelMedium),
      labelSmall: playwriteNlGuides(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite NO font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+NO
  static TextStyle playwriteNo({
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
        '8d86a4fbcff9fcab718eecc5c9dd6a347e2f35772e6776798dba7ceb0f47fd22',
        106844,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '42db2e6d9e7f3d7139f37ac91f95d8c8e143640b3114a27f90ed9b65b1546c52',
        106960,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '46e5bd3f08d4c26779d9e21d0aac323c2f8377c7a1a4626b63b6b08cbf4544bf',
        106780,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '2700da370e98a314337d9d6ac35c09ce8b424578df378a15f11c21399298ad19',
        106576,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '05222fecb3af6f3423ca3ddf8b681b022ad5a58e06f01e053f35d90330fb626f',
        160316,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteNO',
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

  /// Applies the Playwrite NO font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+NO
  static TextTheme playwriteNoTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteNo(textStyle: textTheme.displayLarge),
      displayMedium: playwriteNo(textStyle: textTheme.displayMedium),
      displaySmall: playwriteNo(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteNo(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteNo(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteNo(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteNo(textStyle: textTheme.titleLarge),
      titleMedium: playwriteNo(textStyle: textTheme.titleMedium),
      titleSmall: playwriteNo(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteNo(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteNo(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteNo(textStyle: textTheme.bodySmall),
      labelLarge: playwriteNo(textStyle: textTheme.labelLarge),
      labelMedium: playwriteNo(textStyle: textTheme.labelMedium),
      labelSmall: playwriteNo(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite NO Guides font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+NO+Guides
  static TextStyle playwriteNoGuides({
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
        'bb19f6b4e37a92f24f3561d63c5a8ed1d0fb2349da75281e6473ca58adcc248f',
        202448,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteNOGuides',
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

  /// Applies the Playwrite NO Guides font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+NO+Guides
  static TextTheme playwriteNoGuidesTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteNoGuides(textStyle: textTheme.displayLarge),
      displayMedium: playwriteNoGuides(textStyle: textTheme.displayMedium),
      displaySmall: playwriteNoGuides(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteNoGuides(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteNoGuides(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteNoGuides(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteNoGuides(textStyle: textTheme.titleLarge),
      titleMedium: playwriteNoGuides(textStyle: textTheme.titleMedium),
      titleSmall: playwriteNoGuides(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteNoGuides(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteNoGuides(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteNoGuides(textStyle: textTheme.bodySmall),
      labelLarge: playwriteNoGuides(textStyle: textTheme.labelLarge),
      labelMedium: playwriteNoGuides(textStyle: textTheme.labelMedium),
      labelSmall: playwriteNoGuides(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite NZ font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+NZ
  static TextStyle playwriteNz({
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
        '12b889eee10a905b902cd8286a7990c6ea7ac1a3351f64867322ea6aa3fd9c56',
        87260,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '90fa83f73039a5bedca2b367f8857a4f8d5ff55d6404c4642c9a55491cce2269',
        87416,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'de911f53fd492802b8e1d9a83bc1ed7bddaa46d56e031731eec7dc85e69a4459',
        87360,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '1d5d24541268eb985ae9c15de9f0d260e223079042ff2d391df2a3e454acdb92',
        87112,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'b10837fb257c8acf2c16487fb09086a8c06788860ea6c81bcb6cada2dcca7b91',
        129472,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteNZ',
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

  /// Applies the Playwrite NZ font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+NZ
  static TextTheme playwriteNzTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteNz(textStyle: textTheme.displayLarge),
      displayMedium: playwriteNz(textStyle: textTheme.displayMedium),
      displaySmall: playwriteNz(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteNz(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteNz(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteNz(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteNz(textStyle: textTheme.titleLarge),
      titleMedium: playwriteNz(textStyle: textTheme.titleMedium),
      titleSmall: playwriteNz(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteNz(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteNz(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteNz(textStyle: textTheme.bodySmall),
      labelLarge: playwriteNz(textStyle: textTheme.labelLarge),
      labelMedium: playwriteNz(textStyle: textTheme.labelMedium),
      labelSmall: playwriteNz(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite NZ Guides font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+NZ+Guides
  static TextStyle playwriteNzGuides({
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
        'b0b19c82ecec3e10afb20fd79030e7bd30a18b60c2bf083599dd3ec9504facc6',
        184396,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteNZGuides',
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

  /// Applies the Playwrite NZ Guides font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+NZ+Guides
  static TextTheme playwriteNzGuidesTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteNzGuides(textStyle: textTheme.displayLarge),
      displayMedium: playwriteNzGuides(textStyle: textTheme.displayMedium),
      displaySmall: playwriteNzGuides(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteNzGuides(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteNzGuides(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteNzGuides(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteNzGuides(textStyle: textTheme.titleLarge),
      titleMedium: playwriteNzGuides(textStyle: textTheme.titleMedium),
      titleSmall: playwriteNzGuides(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteNzGuides(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteNzGuides(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteNzGuides(textStyle: textTheme.bodySmall),
      labelLarge: playwriteNzGuides(textStyle: textTheme.labelLarge),
      labelMedium: playwriteNzGuides(textStyle: textTheme.labelMedium),
      labelSmall: playwriteNzGuides(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite PE font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+PE
  static TextStyle playwritePe({
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
        '3566bdf72232375d898d0fcef20234e1030f3b43d4434f92b1bb2ccc0b792753',
        130128,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '61641660a0f5b1080577eb3ff67f96bdac2c2636c5f9d006ffcaa19bf425a4dc',
        130252,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '8538cfd2ed7a0c86627884f2eca45254a90c3893ead57c7852f1d844665cba98',
        130228,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'd25894c5a8db9c7e46ef432b82a8a701269309828ff26e1473f79b2acd271191',
        129992,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'cfd5c31adcd3d6824d71275215d0d39ac370c9df0b2ee6a325642fdc02b6bb1c',
        195908,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywritePE',
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

  /// Applies the Playwrite PE font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+PE
  static TextTheme playwritePeTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwritePe(textStyle: textTheme.displayLarge),
      displayMedium: playwritePe(textStyle: textTheme.displayMedium),
      displaySmall: playwritePe(textStyle: textTheme.displaySmall),
      headlineLarge: playwritePe(textStyle: textTheme.headlineLarge),
      headlineMedium: playwritePe(textStyle: textTheme.headlineMedium),
      headlineSmall: playwritePe(textStyle: textTheme.headlineSmall),
      titleLarge: playwritePe(textStyle: textTheme.titleLarge),
      titleMedium: playwritePe(textStyle: textTheme.titleMedium),
      titleSmall: playwritePe(textStyle: textTheme.titleSmall),
      bodyLarge: playwritePe(textStyle: textTheme.bodyLarge),
      bodyMedium: playwritePe(textStyle: textTheme.bodyMedium),
      bodySmall: playwritePe(textStyle: textTheme.bodySmall),
      labelLarge: playwritePe(textStyle: textTheme.labelLarge),
      labelMedium: playwritePe(textStyle: textTheme.labelMedium),
      labelSmall: playwritePe(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite PE Guides font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+PE+Guides
  static TextStyle playwritePeGuides({
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
        'd22aa7a400b89433233ac8e8611985b8c77a3337fe52a9fbeda75909791ec989',
        224092,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywritePEGuides',
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

  /// Applies the Playwrite PE Guides font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+PE+Guides
  static TextTheme playwritePeGuidesTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwritePeGuides(textStyle: textTheme.displayLarge),
      displayMedium: playwritePeGuides(textStyle: textTheme.displayMedium),
      displaySmall: playwritePeGuides(textStyle: textTheme.displaySmall),
      headlineLarge: playwritePeGuides(textStyle: textTheme.headlineLarge),
      headlineMedium: playwritePeGuides(textStyle: textTheme.headlineMedium),
      headlineSmall: playwritePeGuides(textStyle: textTheme.headlineSmall),
      titleLarge: playwritePeGuides(textStyle: textTheme.titleLarge),
      titleMedium: playwritePeGuides(textStyle: textTheme.titleMedium),
      titleSmall: playwritePeGuides(textStyle: textTheme.titleSmall),
      bodyLarge: playwritePeGuides(textStyle: textTheme.bodyLarge),
      bodyMedium: playwritePeGuides(textStyle: textTheme.bodyMedium),
      bodySmall: playwritePeGuides(textStyle: textTheme.bodySmall),
      labelLarge: playwritePeGuides(textStyle: textTheme.labelLarge),
      labelMedium: playwritePeGuides(textStyle: textTheme.labelMedium),
      labelSmall: playwritePeGuides(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite PL font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+PL
  static TextStyle playwritePl({
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
        '41bc768c67e270bb1d33275b026bd0745b20a7b5d5d27b1303c441e41eee6791',
        115460,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '29c02911b5c034e6df4aae69362cb7191eb1dc71bc1af53aaacdbf6126291669',
        115688,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '5adefc7fbec3e9ddfcac106fef494f0949a2be17a13b1109fe43847ba3a805c8',
        115680,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '8d62007915f5e2d9cabdb9382932e59754b6b4d6c47e09a31ad9c510c6932203',
        115456,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'd102d6b6393730acd817eed6bc56ef973f356d481836ba6672afc80d94b1b98e',
        173280,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywritePL',
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

  /// Applies the Playwrite PL font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+PL
  static TextTheme playwritePlTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwritePl(textStyle: textTheme.displayLarge),
      displayMedium: playwritePl(textStyle: textTheme.displayMedium),
      displaySmall: playwritePl(textStyle: textTheme.displaySmall),
      headlineLarge: playwritePl(textStyle: textTheme.headlineLarge),
      headlineMedium: playwritePl(textStyle: textTheme.headlineMedium),
      headlineSmall: playwritePl(textStyle: textTheme.headlineSmall),
      titleLarge: playwritePl(textStyle: textTheme.titleLarge),
      titleMedium: playwritePl(textStyle: textTheme.titleMedium),
      titleSmall: playwritePl(textStyle: textTheme.titleSmall),
      bodyLarge: playwritePl(textStyle: textTheme.bodyLarge),
      bodyMedium: playwritePl(textStyle: textTheme.bodyMedium),
      bodySmall: playwritePl(textStyle: textTheme.bodySmall),
      labelLarge: playwritePl(textStyle: textTheme.labelLarge),
      labelMedium: playwritePl(textStyle: textTheme.labelMedium),
      labelSmall: playwritePl(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite PL Guides font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+PL+Guides
  static TextStyle playwritePlGuides({
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
        '8b103e063042da6eb9f4648360b9dbc28be6cb07db4267f0065e87bde02e8fa0',
        208116,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywritePLGuides',
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

  /// Applies the Playwrite PL Guides font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+PL+Guides
  static TextTheme playwritePlGuidesTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwritePlGuides(textStyle: textTheme.displayLarge),
      displayMedium: playwritePlGuides(textStyle: textTheme.displayMedium),
      displaySmall: playwritePlGuides(textStyle: textTheme.displaySmall),
      headlineLarge: playwritePlGuides(textStyle: textTheme.headlineLarge),
      headlineMedium: playwritePlGuides(textStyle: textTheme.headlineMedium),
      headlineSmall: playwritePlGuides(textStyle: textTheme.headlineSmall),
      titleLarge: playwritePlGuides(textStyle: textTheme.titleLarge),
      titleMedium: playwritePlGuides(textStyle: textTheme.titleMedium),
      titleSmall: playwritePlGuides(textStyle: textTheme.titleSmall),
      bodyLarge: playwritePlGuides(textStyle: textTheme.bodyLarge),
      bodyMedium: playwritePlGuides(textStyle: textTheme.bodyMedium),
      bodySmall: playwritePlGuides(textStyle: textTheme.bodySmall),
      labelLarge: playwritePlGuides(textStyle: textTheme.labelLarge),
      labelMedium: playwritePlGuides(textStyle: textTheme.labelMedium),
      labelSmall: playwritePlGuides(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite PT font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+PT
  static TextStyle playwritePt({
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
        '873443bae82441830d8765711abb8c7ce3ffd86b3a7b7ee0d06f5d03949ac83c',
        128664,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '21eae4d32c5dc3fdbf48de923012ab0808c8bc6f6077f187f0c60283060f50e7',
        128896,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '196c50ab5b625f98c48b7eba6d7b77323688bd2b878f8f6929997153c683814d',
        128932,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'b4a417016e96e2427163f9b1c3bd3fef78035e5c6f89f56e5826983be2af7fae',
        128740,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'fcea1902a3b3b751a5f270b2076921b8692fd2388874d68e1ade2699d58803e3',
        194416,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywritePT',
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

  /// Applies the Playwrite PT font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+PT
  static TextTheme playwritePtTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwritePt(textStyle: textTheme.displayLarge),
      displayMedium: playwritePt(textStyle: textTheme.displayMedium),
      displaySmall: playwritePt(textStyle: textTheme.displaySmall),
      headlineLarge: playwritePt(textStyle: textTheme.headlineLarge),
      headlineMedium: playwritePt(textStyle: textTheme.headlineMedium),
      headlineSmall: playwritePt(textStyle: textTheme.headlineSmall),
      titleLarge: playwritePt(textStyle: textTheme.titleLarge),
      titleMedium: playwritePt(textStyle: textTheme.titleMedium),
      titleSmall: playwritePt(textStyle: textTheme.titleSmall),
      bodyLarge: playwritePt(textStyle: textTheme.bodyLarge),
      bodyMedium: playwritePt(textStyle: textTheme.bodyMedium),
      bodySmall: playwritePt(textStyle: textTheme.bodySmall),
      labelLarge: playwritePt(textStyle: textTheme.labelLarge),
      labelMedium: playwritePt(textStyle: textTheme.labelMedium),
      labelSmall: playwritePt(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite PT Guides font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+PT+Guides
  static TextStyle playwritePtGuides({
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
        'bb3ebfed4c2c47d284fc0e41a739397e31511abc6ce41e71218e9a13db6a5592',
        222520,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywritePTGuides',
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

  /// Applies the Playwrite PT Guides font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+PT+Guides
  static TextTheme playwritePtGuidesTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwritePtGuides(textStyle: textTheme.displayLarge),
      displayMedium: playwritePtGuides(textStyle: textTheme.displayMedium),
      displaySmall: playwritePtGuides(textStyle: textTheme.displaySmall),
      headlineLarge: playwritePtGuides(textStyle: textTheme.headlineLarge),
      headlineMedium: playwritePtGuides(textStyle: textTheme.headlineMedium),
      headlineSmall: playwritePtGuides(textStyle: textTheme.headlineSmall),
      titleLarge: playwritePtGuides(textStyle: textTheme.titleLarge),
      titleMedium: playwritePtGuides(textStyle: textTheme.titleMedium),
      titleSmall: playwritePtGuides(textStyle: textTheme.titleSmall),
      bodyLarge: playwritePtGuides(textStyle: textTheme.bodyLarge),
      bodyMedium: playwritePtGuides(textStyle: textTheme.bodyMedium),
      bodySmall: playwritePtGuides(textStyle: textTheme.bodySmall),
      labelLarge: playwritePtGuides(textStyle: textTheme.labelLarge),
      labelMedium: playwritePtGuides(textStyle: textTheme.labelMedium),
      labelSmall: playwritePtGuides(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite RO font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+RO
  static TextStyle playwriteRo({
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
        '6f1ac4d09082f6532ea596f463929c4ddaa400050a29a14a27debe71ee673c41',
        129620,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '12afa89c7073bc2a6d968d69654f7b11c19524bb6f5314408aa688885461a73b',
        129716,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'd3e4da2ef4fe9ac5b2ac1f6d479141d3e8211f05a90a0652d9edafdc62b09a78',
        129528,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '38e4e6af7555a480a965a89de8c1d097a1f285e90243af5d4b34fcf0fb2a6ea2',
        129204,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'b881f2bbc6b0073da925e3a8b82f3e8fc1362b30324b58b61f9b3f242c547cb5',
        195284,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteRO',
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

  /// Applies the Playwrite RO font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+RO
  static TextTheme playwriteRoTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteRo(textStyle: textTheme.displayLarge),
      displayMedium: playwriteRo(textStyle: textTheme.displayMedium),
      displaySmall: playwriteRo(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteRo(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteRo(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteRo(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteRo(textStyle: textTheme.titleLarge),
      titleMedium: playwriteRo(textStyle: textTheme.titleMedium),
      titleSmall: playwriteRo(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteRo(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteRo(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteRo(textStyle: textTheme.bodySmall),
      labelLarge: playwriteRo(textStyle: textTheme.labelLarge),
      labelMedium: playwriteRo(textStyle: textTheme.labelMedium),
      labelSmall: playwriteRo(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite RO Guides font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+RO+Guides
  static TextStyle playwriteRoGuides({
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
        '302bef51b4fd6d058aca360af1182e2510f617e79a91b908c9f35df4753ccdce',
        224012,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteROGuides',
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

  /// Applies the Playwrite RO Guides font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+RO+Guides
  static TextTheme playwriteRoGuidesTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteRoGuides(textStyle: textTheme.displayLarge),
      displayMedium: playwriteRoGuides(textStyle: textTheme.displayMedium),
      displaySmall: playwriteRoGuides(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteRoGuides(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteRoGuides(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteRoGuides(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteRoGuides(textStyle: textTheme.titleLarge),
      titleMedium: playwriteRoGuides(textStyle: textTheme.titleMedium),
      titleSmall: playwriteRoGuides(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteRoGuides(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteRoGuides(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteRoGuides(textStyle: textTheme.bodySmall),
      labelLarge: playwriteRoGuides(textStyle: textTheme.labelLarge),
      labelMedium: playwriteRoGuides(textStyle: textTheme.labelMedium),
      labelSmall: playwriteRoGuides(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite SK font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+SK
  static TextStyle playwriteSk({
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
        'e674643d1b38f99e7fa19ae6db725fc6eff312794ea4a4079fcdd7b76df62677',
        128632,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '9454fbccbde107a6f5893d4012d4dc0120d54cf52b73dab207a4825d5bd8f8b3',
        128740,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '025477729ea565e5642922fae126b74e51515092a2bed1a3a086bcd37daa2cb5',
        128608,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '38e869093bfc515d7f5594bd9998c67f5309a1e6f063518a8b24e7ab12a09f42',
        128372,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'e89fbfcb976b73ab0f4b54207ba376b918fe0081e69038b6928374cf7fe22fe6',
        193060,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteSK',
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

  /// Applies the Playwrite SK font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+SK
  static TextTheme playwriteSkTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteSk(textStyle: textTheme.displayLarge),
      displayMedium: playwriteSk(textStyle: textTheme.displayMedium),
      displaySmall: playwriteSk(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteSk(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteSk(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteSk(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteSk(textStyle: textTheme.titleLarge),
      titleMedium: playwriteSk(textStyle: textTheme.titleMedium),
      titleSmall: playwriteSk(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteSk(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteSk(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteSk(textStyle: textTheme.bodySmall),
      labelLarge: playwriteSk(textStyle: textTheme.labelLarge),
      labelMedium: playwriteSk(textStyle: textTheme.labelMedium),
      labelSmall: playwriteSk(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite SK Guides font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+SK+Guides
  static TextStyle playwriteSkGuides({
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
        'e6339aea28104f54062ade2b628892db1a07752619e72a2d4d528eee3deb9936',
        222976,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteSKGuides',
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

  /// Applies the Playwrite SK Guides font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+SK+Guides
  static TextTheme playwriteSkGuidesTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteSkGuides(textStyle: textTheme.displayLarge),
      displayMedium: playwriteSkGuides(textStyle: textTheme.displayMedium),
      displaySmall: playwriteSkGuides(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteSkGuides(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteSkGuides(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteSkGuides(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteSkGuides(textStyle: textTheme.titleLarge),
      titleMedium: playwriteSkGuides(textStyle: textTheme.titleMedium),
      titleSmall: playwriteSkGuides(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteSkGuides(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteSkGuides(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteSkGuides(textStyle: textTheme.bodySmall),
      labelLarge: playwriteSkGuides(textStyle: textTheme.labelLarge),
      labelMedium: playwriteSkGuides(textStyle: textTheme.labelMedium),
      labelSmall: playwriteSkGuides(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite TZ font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+TZ
  static TextStyle playwriteTz({
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
        '370de49adac585a38ba4b68e422e1fcd0cecf02f21e60e98910b3313a36ab276',
        127636,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '04138cc053a5abf7bcee4a58fcbaad0e48fe200dfdb35540761664f1ebe9e97a',
        127760,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'c486035351604105160a3e82d7d5e960f2ca23bf7b496aa54a439a33c78ceddb',
        127600,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '0e4765d37a299faffea27974cbf2e7ebb79bf7b9b156ac8fb03c70b6b50841be',
        127432,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'c822470ced99c1c1a544468e27bfa97b8853844206614fccfff9fb56333519a8',
        191980,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteTZ',
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

  /// Applies the Playwrite TZ font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+TZ
  static TextTheme playwriteTzTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteTz(textStyle: textTheme.displayLarge),
      displayMedium: playwriteTz(textStyle: textTheme.displayMedium),
      displaySmall: playwriteTz(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteTz(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteTz(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteTz(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteTz(textStyle: textTheme.titleLarge),
      titleMedium: playwriteTz(textStyle: textTheme.titleMedium),
      titleSmall: playwriteTz(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteTz(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteTz(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteTz(textStyle: textTheme.bodySmall),
      labelLarge: playwriteTz(textStyle: textTheme.labelLarge),
      labelMedium: playwriteTz(textStyle: textTheme.labelMedium),
      labelSmall: playwriteTz(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite TZ Guides font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+TZ+Guides
  static TextStyle playwriteTzGuides({
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
        'ebf96ffe1d966669f96fa040376b537f7f4fbcd1a1af98154ef822cb5b6534e7',
        222440,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteTZGuides',
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

  /// Applies the Playwrite TZ Guides font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+TZ+Guides
  static TextTheme playwriteTzGuidesTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteTzGuides(textStyle: textTheme.displayLarge),
      displayMedium: playwriteTzGuides(textStyle: textTheme.displayMedium),
      displaySmall: playwriteTzGuides(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteTzGuides(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteTzGuides(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteTzGuides(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteTzGuides(textStyle: textTheme.titleLarge),
      titleMedium: playwriteTzGuides(textStyle: textTheme.titleMedium),
      titleSmall: playwriteTzGuides(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteTzGuides(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteTzGuides(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteTzGuides(textStyle: textTheme.bodySmall),
      labelLarge: playwriteTzGuides(textStyle: textTheme.labelLarge),
      labelMedium: playwriteTzGuides(textStyle: textTheme.labelMedium),
      labelSmall: playwriteTzGuides(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite US Modern font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+US+Modern
  static TextStyle playwriteUsModern({
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
        '54ae6d2a0ff797cbf1e73bd31f644de1351ffe30a70f49316604715894e873d9',
        90176,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'f36e3c642f6b359841691052bda014e9a88ed9a43516d10e93fbf17f67e9b502',
        90360,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '7a33251811c0cf0c768e4031fa97775359ca7073d93fa14768b58f9c0aa014ef',
        90352,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'd0c0bab8066b023b50d2ba7fe7761a2154f08dac1d16df23d0e97bb3e423c9ef',
        90236,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'b3cae09f717489e6a29bdbe7e2883f5e7d62b0ff183a197ccf842945464ddbeb',
        133144,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteUSModern',
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

  /// Applies the Playwrite US Modern font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+US+Modern
  static TextTheme playwriteUsModernTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteUsModern(textStyle: textTheme.displayLarge),
      displayMedium: playwriteUsModern(textStyle: textTheme.displayMedium),
      displaySmall: playwriteUsModern(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteUsModern(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteUsModern(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteUsModern(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteUsModern(textStyle: textTheme.titleLarge),
      titleMedium: playwriteUsModern(textStyle: textTheme.titleMedium),
      titleSmall: playwriteUsModern(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteUsModern(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteUsModern(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteUsModern(textStyle: textTheme.bodySmall),
      labelLarge: playwriteUsModern(textStyle: textTheme.labelLarge),
      labelMedium: playwriteUsModern(textStyle: textTheme.labelMedium),
      labelSmall: playwriteUsModern(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite US Modern Guides font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+US+Modern+Guides
  static TextStyle playwriteUsModernGuides({
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
        '205cf08f55379645ebb2f0e4024f95384afcfd7528acba5424f62506631b65f9',
        185916,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteUSModernGuides',
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

  /// Applies the Playwrite US Modern Guides font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+US+Modern+Guides
  static TextTheme playwriteUsModernGuidesTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteUsModernGuides(textStyle: textTheme.displayLarge),
      displayMedium: playwriteUsModernGuides(
        textStyle: textTheme.displayMedium,
      ),
      displaySmall: playwriteUsModernGuides(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteUsModernGuides(
        textStyle: textTheme.headlineLarge,
      ),
      headlineMedium: playwriteUsModernGuides(
        textStyle: textTheme.headlineMedium,
      ),
      headlineSmall: playwriteUsModernGuides(
        textStyle: textTheme.headlineSmall,
      ),
      titleLarge: playwriteUsModernGuides(textStyle: textTheme.titleLarge),
      titleMedium: playwriteUsModernGuides(textStyle: textTheme.titleMedium),
      titleSmall: playwriteUsModernGuides(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteUsModernGuides(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteUsModernGuides(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteUsModernGuides(textStyle: textTheme.bodySmall),
      labelLarge: playwriteUsModernGuides(textStyle: textTheme.labelLarge),
      labelMedium: playwriteUsModernGuides(textStyle: textTheme.labelMedium),
      labelSmall: playwriteUsModernGuides(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite US Trad font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+US+Trad
  static TextStyle playwriteUsTrad({
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
        '9e9dea8a2d0bb5d77a94da7772182e9a0000fe643672efe08201812ffb870b2b',
        130060,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '3604cca1a6541da1aa1dc7b81219cbf260d14bbd935c003c66653599b5a7702b',
        130224,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '16d041eab76e24de0a03375d4657319f0b87dbb0ca04739931400ce2bcfb736d',
        130160,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '499b1d5f63152ee75f9055e80faa2612161e2a7d43261971b0eab188fcf9010f',
        129872,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'ddaa1a2fcd87a856cd848c9eb2f11f1ef777a9a1a74ed79875547fa2f74c1660',
        195476,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteUSTrad',
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

  /// Applies the Playwrite US Trad font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+US+Trad
  static TextTheme playwriteUsTradTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteUsTrad(textStyle: textTheme.displayLarge),
      displayMedium: playwriteUsTrad(textStyle: textTheme.displayMedium),
      displaySmall: playwriteUsTrad(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteUsTrad(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteUsTrad(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteUsTrad(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteUsTrad(textStyle: textTheme.titleLarge),
      titleMedium: playwriteUsTrad(textStyle: textTheme.titleMedium),
      titleSmall: playwriteUsTrad(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteUsTrad(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteUsTrad(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteUsTrad(textStyle: textTheme.bodySmall),
      labelLarge: playwriteUsTrad(textStyle: textTheme.labelLarge),
      labelMedium: playwriteUsTrad(textStyle: textTheme.labelMedium),
      labelSmall: playwriteUsTrad(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite US Trad Guides font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+US+Trad+Guides
  static TextStyle playwriteUsTradGuides({
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
        '3403634490605bdec2ce83f6a5e87a7f4d87f98bae991ffd9a6261bb59e29658',
        224216,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteUSTradGuides',
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

  /// Applies the Playwrite US Trad Guides font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+US+Trad+Guides
  static TextTheme playwriteUsTradGuidesTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteUsTradGuides(textStyle: textTheme.displayLarge),
      displayMedium: playwriteUsTradGuides(textStyle: textTheme.displayMedium),
      displaySmall: playwriteUsTradGuides(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteUsTradGuides(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteUsTradGuides(
        textStyle: textTheme.headlineMedium,
      ),
      headlineSmall: playwriteUsTradGuides(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteUsTradGuides(textStyle: textTheme.titleLarge),
      titleMedium: playwriteUsTradGuides(textStyle: textTheme.titleMedium),
      titleSmall: playwriteUsTradGuides(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteUsTradGuides(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteUsTradGuides(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteUsTradGuides(textStyle: textTheme.bodySmall),
      labelLarge: playwriteUsTradGuides(textStyle: textTheme.labelLarge),
      labelMedium: playwriteUsTradGuides(textStyle: textTheme.labelMedium),
      labelSmall: playwriteUsTradGuides(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite VN font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+VN
  static TextStyle playwriteVn({
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
        '8f68ae3ef15c6cff0f258f24bdee80a9b4518b4d56460393734dcb85c7aa534a',
        127856,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '933857bf769a43a18a40843a64ef3ecb0cd44da6f4e2446210da8b01d6e0ee8e',
        128024,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'd326a50ab9131e1327aa014b967fd0cb976c7f554b67649b7649fffac4fb1284',
        128036,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '90b8b6b0dcf7bb756979c8bd6f25f0b96bf7d96d36eb1e1e846eb0ac50472d01',
        127800,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'ac0c184caa4a011d140b7f3f9395e4abddff342cad45f8616d4f9008ae8fb2c7',
        193228,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteVN',
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

  /// Applies the Playwrite VN font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+VN
  static TextTheme playwriteVnTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteVn(textStyle: textTheme.displayLarge),
      displayMedium: playwriteVn(textStyle: textTheme.displayMedium),
      displaySmall: playwriteVn(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteVn(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteVn(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteVn(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteVn(textStyle: textTheme.titleLarge),
      titleMedium: playwriteVn(textStyle: textTheme.titleMedium),
      titleSmall: playwriteVn(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteVn(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteVn(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteVn(textStyle: textTheme.bodySmall),
      labelLarge: playwriteVn(textStyle: textTheme.labelLarge),
      labelMedium: playwriteVn(textStyle: textTheme.labelMedium),
      labelSmall: playwriteVn(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite VN Guides font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+VN+Guides
  static TextStyle playwriteVnGuides({
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
        '00741fe5179fc8bf9e5b10899ca6eb2bebabe2701a47d81a8b596014de1e7894',
        222200,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteVNGuides',
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

  /// Applies the Playwrite VN Guides font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+VN+Guides
  static TextTheme playwriteVnGuidesTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteVnGuides(textStyle: textTheme.displayLarge),
      displayMedium: playwriteVnGuides(textStyle: textTheme.displayMedium),
      displaySmall: playwriteVnGuides(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteVnGuides(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteVnGuides(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteVnGuides(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteVnGuides(textStyle: textTheme.titleLarge),
      titleMedium: playwriteVnGuides(textStyle: textTheme.titleMedium),
      titleSmall: playwriteVnGuides(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteVnGuides(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteVnGuides(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteVnGuides(textStyle: textTheme.bodySmall),
      labelLarge: playwriteVnGuides(textStyle: textTheme.labelLarge),
      labelMedium: playwriteVnGuides(textStyle: textTheme.labelMedium),
      labelSmall: playwriteVnGuides(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite ZA font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+ZA
  static TextStyle playwriteZa({
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
        '3fb4df179fc301091f83a70ad1f7b3b87583aa9877c8d37ef57cb350334e1252',
        122876,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '29acaf278bcad0cc15f11677ff2ddb93420152790e21c768abd004e5cad028ef',
        122992,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '0e23b8086a48967a7257d0331a572514ba01935f4efe7a971accfe596d96ee41',
        122876,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '7fa83b59286b7fa7abb57aae05ee3372af1ca9e1dc091f5d6102ebb88cff9ad2',
        122728,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '9ea0d724099d0f609a22c02c9f1014ad0a82fe68f83b08e7e0d14baaa318f6c3',
        185576,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteZA',
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

  /// Applies the Playwrite ZA font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+ZA
  static TextTheme playwriteZaTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteZa(textStyle: textTheme.displayLarge),
      displayMedium: playwriteZa(textStyle: textTheme.displayMedium),
      displaySmall: playwriteZa(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteZa(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteZa(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteZa(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteZa(textStyle: textTheme.titleLarge),
      titleMedium: playwriteZa(textStyle: textTheme.titleMedium),
      titleSmall: playwriteZa(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteZa(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteZa(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteZa(textStyle: textTheme.bodySmall),
      labelLarge: playwriteZa(textStyle: textTheme.labelLarge),
      labelMedium: playwriteZa(textStyle: textTheme.labelMedium),
      labelSmall: playwriteZa(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Playwrite ZA Guides font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+ZA+Guides
  static TextStyle playwriteZaGuides({
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
        '592b30cc1896faf22d5dd5765fe54a4960408f3cda5569c02648893feeaa035e',
        217468,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlaywriteZAGuides',
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

  /// Applies the Playwrite ZA Guides font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Playwrite+ZA+Guides
  static TextTheme playwriteZaGuidesTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: playwriteZaGuides(textStyle: textTheme.displayLarge),
      displayMedium: playwriteZaGuides(textStyle: textTheme.displayMedium),
      displaySmall: playwriteZaGuides(textStyle: textTheme.displaySmall),
      headlineLarge: playwriteZaGuides(textStyle: textTheme.headlineLarge),
      headlineMedium: playwriteZaGuides(textStyle: textTheme.headlineMedium),
      headlineSmall: playwriteZaGuides(textStyle: textTheme.headlineSmall),
      titleLarge: playwriteZaGuides(textStyle: textTheme.titleLarge),
      titleMedium: playwriteZaGuides(textStyle: textTheme.titleMedium),
      titleSmall: playwriteZaGuides(textStyle: textTheme.titleSmall),
      bodyLarge: playwriteZaGuides(textStyle: textTheme.bodyLarge),
      bodyMedium: playwriteZaGuides(textStyle: textTheme.bodyMedium),
      bodySmall: playwriteZaGuides(textStyle: textTheme.bodySmall),
      labelLarge: playwriteZaGuides(textStyle: textTheme.labelLarge),
      labelMedium: playwriteZaGuides(textStyle: textTheme.labelMedium),
      labelSmall: playwriteZaGuides(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Plus Jakarta Sans font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Plus+Jakarta+Sans
  static TextStyle plusJakartaSans({
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
        '236b94978716a5b9532c5ab11f7d69ba195e1cacf00146a91ab46c507b7148a3',
        63372,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '98eea411373148b109f3cb8c85cbd9294707f2b56ace31774050d3353789f20c',
        63348,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '1306435ed883e4a1e6dad370e6d035955da71f4df9c07ca192833f7cb58a18d7',
        63312,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'd4478b49f18c5b0db7bd8fbbb033595061dea8c03a86246710035d750e515130',
        63380,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '8590ab94f96850ab246d5795a9ba442e42f64036673bc329573dfe93efbc7c87',
        63388,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '5b6d946cf820c9851ff7b4776425ee43f5cf405c6f891a4a7fcb4a74d5e32d52',
        63312,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '9ab901a45e6afa0c663def7606b753bbdfb60fc73bf3277e8110c167ddb6bbc3',
        63348,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '67b0a9a73692842dfe2b3afc51e19b05929acd2d25761d1068d18c642f2d4666',
        65100,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'f52b200f4061ce556c9519366bb05d2b52e62861b23069a5a7d003a285749663',
        65060,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '14903fca938022aedf08d6a058799acce99a141639bbdd956bfe370f65d27846',
        64824,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '45812f4eb5d8828cc7d8e9c65c1b955bbb5f6e750f7fc9f2acbaea3e1b12a89d',
        65048,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'f55a6642a9bc37b2ab89232acb67a7d592321cc91c06fde02969b1eaf4cefafd',
        65044,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'b99e8615e6827a31612beeb8a14a7abbead8fabe6254d993898d0e9c05c2aea7',
        64912,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'a87b91600420655aab081027f098d0d873c7a82fbe154d2591fc437457b21701',
        64988,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'ef83a8775d8e3dcd6850493ed3312d39e55e0e042ecb1ba4d7856f8eeed9319c',
        122344,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '701dc9fbd7df6ff7177409bb33dc6d59ef1a7e93977c58a4653cfec6db85b4de',
        126312,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PlusJakartaSans',
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

  /// Applies the Plus Jakarta Sans font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Plus+Jakarta+Sans
  static TextTheme plusJakartaSansTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: plusJakartaSans(textStyle: textTheme.displayLarge),
      displayMedium: plusJakartaSans(textStyle: textTheme.displayMedium),
      displaySmall: plusJakartaSans(textStyle: textTheme.displaySmall),
      headlineLarge: plusJakartaSans(textStyle: textTheme.headlineLarge),
      headlineMedium: plusJakartaSans(textStyle: textTheme.headlineMedium),
      headlineSmall: plusJakartaSans(textStyle: textTheme.headlineSmall),
      titleLarge: plusJakartaSans(textStyle: textTheme.titleLarge),
      titleMedium: plusJakartaSans(textStyle: textTheme.titleMedium),
      titleSmall: plusJakartaSans(textStyle: textTheme.titleSmall),
      bodyLarge: plusJakartaSans(textStyle: textTheme.bodyLarge),
      bodyMedium: plusJakartaSans(textStyle: textTheme.bodyMedium),
      bodySmall: plusJakartaSans(textStyle: textTheme.bodySmall),
      labelLarge: plusJakartaSans(textStyle: textTheme.labelLarge),
      labelMedium: plusJakartaSans(textStyle: textTheme.labelMedium),
      labelSmall: plusJakartaSans(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Pochaevsk font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Pochaevsk
  static TextStyle pochaevsk({
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
        '9e2aa683b658e2dfbfe1f002663f9adf6a44d962b660f927e865ea7f23833f6d',
        117188,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Pochaevsk',
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

  /// Applies the Pochaevsk font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Pochaevsk
  static TextTheme pochaevskTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: pochaevsk(textStyle: textTheme.displayLarge),
      displayMedium: pochaevsk(textStyle: textTheme.displayMedium),
      displaySmall: pochaevsk(textStyle: textTheme.displaySmall),
      headlineLarge: pochaevsk(textStyle: textTheme.headlineLarge),
      headlineMedium: pochaevsk(textStyle: textTheme.headlineMedium),
      headlineSmall: pochaevsk(textStyle: textTheme.headlineSmall),
      titleLarge: pochaevsk(textStyle: textTheme.titleLarge),
      titleMedium: pochaevsk(textStyle: textTheme.titleMedium),
      titleSmall: pochaevsk(textStyle: textTheme.titleSmall),
      bodyLarge: pochaevsk(textStyle: textTheme.bodyLarge),
      bodyMedium: pochaevsk(textStyle: textTheme.bodyMedium),
      bodySmall: pochaevsk(textStyle: textTheme.bodySmall),
      labelLarge: pochaevsk(textStyle: textTheme.labelLarge),
      labelMedium: pochaevsk(textStyle: textTheme.labelMedium),
      labelSmall: pochaevsk(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Podkova font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Podkova
  static TextStyle podkova({
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
        '4e68bf8a4f37dca1a8a038b87ceaceacf212975824646ab862e2a1bfe68af977',
        96732,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '9101650bf1afa796b25e3f1fa16b83ec1b4ee3e44209a24a2368c131bb695c7b',
        96880,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'd820e77744c307eb136d691d10300ffa8ec0f7e709ebefc94c9deecb8c6f53b6',
        96856,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '29bc728f68a0690f726528c184284dbff1309d883cae2f9f0bc867d3add6401d',
        97256,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'dfd8be64cd367c3597bcbe8ffa98f308bae4e2ba49998d9f79edc2001b8110fa',
        97512,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '3149db9729303e7b305ab986a099b6ab61176501c014118a84de78340ebb2540',
        161328,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Podkova',
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

  /// Applies the Podkova font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Podkova
  static TextTheme podkovaTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: podkova(textStyle: textTheme.displayLarge),
      displayMedium: podkova(textStyle: textTheme.displayMedium),
      displaySmall: podkova(textStyle: textTheme.displaySmall),
      headlineLarge: podkova(textStyle: textTheme.headlineLarge),
      headlineMedium: podkova(textStyle: textTheme.headlineMedium),
      headlineSmall: podkova(textStyle: textTheme.headlineSmall),
      titleLarge: podkova(textStyle: textTheme.titleLarge),
      titleMedium: podkova(textStyle: textTheme.titleMedium),
      titleSmall: podkova(textStyle: textTheme.titleSmall),
      bodyLarge: podkova(textStyle: textTheme.bodyLarge),
      bodyMedium: podkova(textStyle: textTheme.bodyMedium),
      bodySmall: podkova(textStyle: textTheme.bodySmall),
      labelLarge: podkova(textStyle: textTheme.labelLarge),
      labelMedium: podkova(textStyle: textTheme.labelMedium),
      labelSmall: podkova(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Poetsen One font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Poetsen+One
  static TextStyle poetsenOne({
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
        '597d44dfb3a81f513c1f2edbe5de791a7b8e5b846c017b9417c1808c8cbc0426',
        112560,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PoetsenOne',
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

  /// Applies the Poetsen One font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Poetsen+One
  static TextTheme poetsenOneTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: poetsenOne(textStyle: textTheme.displayLarge),
      displayMedium: poetsenOne(textStyle: textTheme.displayMedium),
      displaySmall: poetsenOne(textStyle: textTheme.displaySmall),
      headlineLarge: poetsenOne(textStyle: textTheme.headlineLarge),
      headlineMedium: poetsenOne(textStyle: textTheme.headlineMedium),
      headlineSmall: poetsenOne(textStyle: textTheme.headlineSmall),
      titleLarge: poetsenOne(textStyle: textTheme.titleLarge),
      titleMedium: poetsenOne(textStyle: textTheme.titleMedium),
      titleSmall: poetsenOne(textStyle: textTheme.titleSmall),
      bodyLarge: poetsenOne(textStyle: textTheme.bodyLarge),
      bodyMedium: poetsenOne(textStyle: textTheme.bodyMedium),
      bodySmall: poetsenOne(textStyle: textTheme.bodySmall),
      labelLarge: poetsenOne(textStyle: textTheme.labelLarge),
      labelMedium: poetsenOne(textStyle: textTheme.labelMedium),
      labelSmall: poetsenOne(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Poiret One font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Poiret+One
  static TextStyle poiretOne({
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
        'fd166323a7982e59e87b13e56fce19f413e0a9860f6c35dd2a4b82f4ad4527b6',
        44704,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PoiretOne',
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

  /// Applies the Poiret One font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Poiret+One
  static TextTheme poiretOneTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: poiretOne(textStyle: textTheme.displayLarge),
      displayMedium: poiretOne(textStyle: textTheme.displayMedium),
      displaySmall: poiretOne(textStyle: textTheme.displaySmall),
      headlineLarge: poiretOne(textStyle: textTheme.headlineLarge),
      headlineMedium: poiretOne(textStyle: textTheme.headlineMedium),
      headlineSmall: poiretOne(textStyle: textTheme.headlineSmall),
      titleLarge: poiretOne(textStyle: textTheme.titleLarge),
      titleMedium: poiretOne(textStyle: textTheme.titleMedium),
      titleSmall: poiretOne(textStyle: textTheme.titleSmall),
      bodyLarge: poiretOne(textStyle: textTheme.bodyLarge),
      bodyMedium: poiretOne(textStyle: textTheme.bodyMedium),
      bodySmall: poiretOne(textStyle: textTheme.bodySmall),
      labelLarge: poiretOne(textStyle: textTheme.labelLarge),
      labelMedium: poiretOne(textStyle: textTheme.labelMedium),
      labelSmall: poiretOne(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Poller One font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Poller+One
  static TextStyle pollerOne({
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
        'e90d5df6dff8ec8036a26de903aeb4bcebe690c4d3006a1252496b3b8c59732e',
        28172,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PollerOne',
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

  /// Applies the Poller One font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Poller+One
  static TextTheme pollerOneTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: pollerOne(textStyle: textTheme.displayLarge),
      displayMedium: pollerOne(textStyle: textTheme.displayMedium),
      displaySmall: pollerOne(textStyle: textTheme.displaySmall),
      headlineLarge: pollerOne(textStyle: textTheme.headlineLarge),
      headlineMedium: pollerOne(textStyle: textTheme.headlineMedium),
      headlineSmall: pollerOne(textStyle: textTheme.headlineSmall),
      titleLarge: pollerOne(textStyle: textTheme.titleLarge),
      titleMedium: pollerOne(textStyle: textTheme.titleMedium),
      titleSmall: pollerOne(textStyle: textTheme.titleSmall),
      bodyLarge: pollerOne(textStyle: textTheme.bodyLarge),
      bodyMedium: pollerOne(textStyle: textTheme.bodyMedium),
      bodySmall: pollerOne(textStyle: textTheme.bodySmall),
      labelLarge: pollerOne(textStyle: textTheme.labelLarge),
      labelMedium: pollerOne(textStyle: textTheme.labelMedium),
      labelSmall: pollerOne(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Poltawski Nowy font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Poltawski+Nowy
  static TextStyle poltawskiNowy({
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
        'bd691d97cee858d9c0f240eb0906b482821cf65375d8a6b573b96c4b0f3b7a02',
        162696,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '552779ba45164cd692fa5dd924ee0b61f46b544546e28af736f12a8b53d05488',
        163468,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '9a6cb1940dc02b1e6895711aaeb825c724bdb73abed5ec4fc8427bd1e3284d5e',
        163528,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'cf49136923b1015a077cc1597cbf5227e5157ecf047591de39871dd59f48df78',
        161604,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'cd8322b2484be5f5cc36e801d6e3a9d16ae267ea65e1f5df48d96c175e40de4b',
        165672,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '6e96d72cd90f1a78f16a13891f790b94ec2d5b256483caf69e298b54d9fbf9ff',
        166856,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '7c32b0cc2f236da919c498d5f9869a8ff3f2281ca38eb11c25222a58f52f27c5',
        166948,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'c5b978ba4cc25a23ebbbd5ba2f45e4b980772d73fdbcd766fec3ab9c245496f4',
        165320,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'b468a4f4e10ac03059f9670cb7de1cd580da3554ecf120899e2522bf9b8b9602',
        252440,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '9cfed7f7060813af1c5d90956ebfd05c2ffadd40bf606b6dafdfc756feb18215',
        256052,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PoltawskiNowy',
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

  /// Applies the Poltawski Nowy font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Poltawski+Nowy
  static TextTheme poltawskiNowyTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: poltawskiNowy(textStyle: textTheme.displayLarge),
      displayMedium: poltawskiNowy(textStyle: textTheme.displayMedium),
      displaySmall: poltawskiNowy(textStyle: textTheme.displaySmall),
      headlineLarge: poltawskiNowy(textStyle: textTheme.headlineLarge),
      headlineMedium: poltawskiNowy(textStyle: textTheme.headlineMedium),
      headlineSmall: poltawskiNowy(textStyle: textTheme.headlineSmall),
      titleLarge: poltawskiNowy(textStyle: textTheme.titleLarge),
      titleMedium: poltawskiNowy(textStyle: textTheme.titleMedium),
      titleSmall: poltawskiNowy(textStyle: textTheme.titleSmall),
      bodyLarge: poltawskiNowy(textStyle: textTheme.bodyLarge),
      bodyMedium: poltawskiNowy(textStyle: textTheme.bodyMedium),
      bodySmall: poltawskiNowy(textStyle: textTheme.bodySmall),
      labelLarge: poltawskiNowy(textStyle: textTheme.labelLarge),
      labelMedium: poltawskiNowy(textStyle: textTheme.labelMedium),
      labelSmall: poltawskiNowy(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Poly font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Poly
  static TextStyle poly({
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
        '35e7dc055929f521a2ee63fc8aaff0d8db3f273c223d5a3c97203bc78c8b57a8',
        51008,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '13bfe558d1648e490c48a75346d326e984500eab8007f0cb761b1cec2bb114be',
        65812,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Poly',
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

  /// Applies the Poly font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Poly
  static TextTheme polyTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: poly(textStyle: textTheme.displayLarge),
      displayMedium: poly(textStyle: textTheme.displayMedium),
      displaySmall: poly(textStyle: textTheme.displaySmall),
      headlineLarge: poly(textStyle: textTheme.headlineLarge),
      headlineMedium: poly(textStyle: textTheme.headlineMedium),
      headlineSmall: poly(textStyle: textTheme.headlineSmall),
      titleLarge: poly(textStyle: textTheme.titleLarge),
      titleMedium: poly(textStyle: textTheme.titleMedium),
      titleSmall: poly(textStyle: textTheme.titleSmall),
      bodyLarge: poly(textStyle: textTheme.bodyLarge),
      bodyMedium: poly(textStyle: textTheme.bodyMedium),
      bodySmall: poly(textStyle: textTheme.bodySmall),
      labelLarge: poly(textStyle: textTheme.labelLarge),
      labelMedium: poly(textStyle: textTheme.labelMedium),
      labelSmall: poly(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Pompiere font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Pompiere
  static TextStyle pompiere({
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
        '8f7b0762d12111e41f701e0ea622ea5c6a84829ad72075c63bcf00f4e5f666aa',
        33356,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Pompiere',
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

  /// Applies the Pompiere font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Pompiere
  static TextTheme pompiereTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: pompiere(textStyle: textTheme.displayLarge),
      displayMedium: pompiere(textStyle: textTheme.displayMedium),
      displaySmall: pompiere(textStyle: textTheme.displaySmall),
      headlineLarge: pompiere(textStyle: textTheme.headlineLarge),
      headlineMedium: pompiere(textStyle: textTheme.headlineMedium),
      headlineSmall: pompiere(textStyle: textTheme.headlineSmall),
      titleLarge: pompiere(textStyle: textTheme.titleLarge),
      titleMedium: pompiere(textStyle: textTheme.titleMedium),
      titleSmall: pompiere(textStyle: textTheme.titleSmall),
      bodyLarge: pompiere(textStyle: textTheme.bodyLarge),
      bodyMedium: pompiere(textStyle: textTheme.bodyMedium),
      bodySmall: pompiere(textStyle: textTheme.bodySmall),
      labelLarge: pompiere(textStyle: textTheme.labelLarge),
      labelMedium: pompiere(textStyle: textTheme.labelMedium),
      labelSmall: pompiere(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Ponnala font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Ponnala
  static TextStyle ponnala({
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
        '3254557faf01d7b6b2a1b97a48df9ab4943756e18add661cb1188519efd14849',
        237452,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Ponnala',
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

  /// Applies the Ponnala font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Ponnala
  static TextTheme ponnalaTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: ponnala(textStyle: textTheme.displayLarge),
      displayMedium: ponnala(textStyle: textTheme.displayMedium),
      displaySmall: ponnala(textStyle: textTheme.displaySmall),
      headlineLarge: ponnala(textStyle: textTheme.headlineLarge),
      headlineMedium: ponnala(textStyle: textTheme.headlineMedium),
      headlineSmall: ponnala(textStyle: textTheme.headlineSmall),
      titleLarge: ponnala(textStyle: textTheme.titleLarge),
      titleMedium: ponnala(textStyle: textTheme.titleMedium),
      titleSmall: ponnala(textStyle: textTheme.titleSmall),
      bodyLarge: ponnala(textStyle: textTheme.bodyLarge),
      bodyMedium: ponnala(textStyle: textTheme.bodyMedium),
      bodySmall: ponnala(textStyle: textTheme.bodySmall),
      labelLarge: ponnala(textStyle: textTheme.labelLarge),
      labelMedium: ponnala(textStyle: textTheme.labelMedium),
      labelSmall: ponnala(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Ponomar font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Ponomar
  static TextStyle ponomar({
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
        'c15d62b747c0414c875f2850c9d4d972fdb66bc5662fc71f0a9df417e2232e7b',
        219256,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Ponomar',
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

  /// Applies the Ponomar font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Ponomar
  static TextTheme ponomarTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: ponomar(textStyle: textTheme.displayLarge),
      displayMedium: ponomar(textStyle: textTheme.displayMedium),
      displaySmall: ponomar(textStyle: textTheme.displaySmall),
      headlineLarge: ponomar(textStyle: textTheme.headlineLarge),
      headlineMedium: ponomar(textStyle: textTheme.headlineMedium),
      headlineSmall: ponomar(textStyle: textTheme.headlineSmall),
      titleLarge: ponomar(textStyle: textTheme.titleLarge),
      titleMedium: ponomar(textStyle: textTheme.titleMedium),
      titleSmall: ponomar(textStyle: textTheme.titleSmall),
      bodyLarge: ponomar(textStyle: textTheme.bodyLarge),
      bodyMedium: ponomar(textStyle: textTheme.bodyMedium),
      bodySmall: ponomar(textStyle: textTheme.bodySmall),
      labelLarge: ponomar(textStyle: textTheme.labelLarge),
      labelMedium: ponomar(textStyle: textTheme.labelMedium),
      labelSmall: ponomar(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Pontano Sans font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Pontano+Sans
  static TextStyle pontanoSans({
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
        '3d4483f6c5302f9e0691b77c6a49f0a9dd985ab17c95b33cb93195aa3b0eb2c3',
        40996,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'ba9b25e0ecc2799bbb1e7add66ae829f18222feb38b3fdec29a9f502c9fa61ed',
        40832,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '100890ccfca657b6860311832c7783ac2e959f2dd00f670cc34bdc8ea8a24272',
        41652,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '59fa0a12ea8084ff31171bb54043d5158d94b56980aed85ace4f7409d760b7d7',
        41572,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '5d94c49009b420e6be9a7ca0fa20c526117181817e7b89d67f76bd4ef1211fc7',
        41652,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '8af4e90d9ee3d7e4b5c9a5ab70283553036cbda4a08d8f21bdcccf1124ed3336',
        76212,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PontanoSans',
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

  /// Applies the Pontano Sans font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Pontano+Sans
  static TextTheme pontanoSansTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: pontanoSans(textStyle: textTheme.displayLarge),
      displayMedium: pontanoSans(textStyle: textTheme.displayMedium),
      displaySmall: pontanoSans(textStyle: textTheme.displaySmall),
      headlineLarge: pontanoSans(textStyle: textTheme.headlineLarge),
      headlineMedium: pontanoSans(textStyle: textTheme.headlineMedium),
      headlineSmall: pontanoSans(textStyle: textTheme.headlineSmall),
      titleLarge: pontanoSans(textStyle: textTheme.titleLarge),
      titleMedium: pontanoSans(textStyle: textTheme.titleMedium),
      titleSmall: pontanoSans(textStyle: textTheme.titleSmall),
      bodyLarge: pontanoSans(textStyle: textTheme.bodyLarge),
      bodyMedium: pontanoSans(textStyle: textTheme.bodyMedium),
      bodySmall: pontanoSans(textStyle: textTheme.bodySmall),
      labelLarge: pontanoSans(textStyle: textTheme.labelLarge),
      labelMedium: pontanoSans(textStyle: textTheme.labelMedium),
      labelSmall: pontanoSans(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Poor Story font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Poor+Story
  static TextStyle poorStory({
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
        '4dac2b9dc14e6e8150f5569c9e7fae7de22943fdca46179dda69211ff30470d7',
        1802964,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PoorStory',
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

  /// Applies the Poor Story font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Poor+Story
  static TextTheme poorStoryTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: poorStory(textStyle: textTheme.displayLarge),
      displayMedium: poorStory(textStyle: textTheme.displayMedium),
      displaySmall: poorStory(textStyle: textTheme.displaySmall),
      headlineLarge: poorStory(textStyle: textTheme.headlineLarge),
      headlineMedium: poorStory(textStyle: textTheme.headlineMedium),
      headlineSmall: poorStory(textStyle: textTheme.headlineSmall),
      titleLarge: poorStory(textStyle: textTheme.titleLarge),
      titleMedium: poorStory(textStyle: textTheme.titleMedium),
      titleSmall: poorStory(textStyle: textTheme.titleSmall),
      bodyLarge: poorStory(textStyle: textTheme.bodyLarge),
      bodyMedium: poorStory(textStyle: textTheme.bodyMedium),
      bodySmall: poorStory(textStyle: textTheme.bodySmall),
      labelLarge: poorStory(textStyle: textTheme.labelLarge),
      labelMedium: poorStory(textStyle: textTheme.labelMedium),
      labelSmall: poorStory(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Poppins font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Poppins
  static TextStyle poppins({
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
        '62fbc976e89f481e5cfbdd8c5ba3fb2d54d34f321d26e09d0aee1e92322f4c03',
        157916,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w100,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '2f3c36836267be3cd724b1fdac2eea7c01592c2b710db1e870496228d513d997',
        183088,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '5e69d1e6141575a4e9376c58d0c7df89225d9d824b31f2190da9737b6dfb004c',
        157716,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'a72b549384105f91114dd04de46734ceba741969117aeee0a91540f215ba1abc',
        182224,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'c2cc8d8186b7df39bad617387a8c35ac03820abc2646973434ead86fe89041a7',
        156188,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '79f1f2616c610d0e7225d8d223e6c1492f55d9bd1a70ca24c7cf7193f2f582f7',
        180524,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '2dd6eb23c4972b346197d272c4e2479b89ed240ece4d2b0e0cd89f0c1caa2710',
        154628,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '269c0b1ed19ae25d8b499778df368bb5c7a32dc1b1343048b1c54544cc3f6387',
        178112,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'c0ba5609d6562c76ab7db73fa9c9b283d210598cb318a45d4085f540e4753d60',
        152860,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '2ba6604eb5ff37f0512176b1a1fa03e455aca7cf8f6f1b2f403427c6081267ab',
        176504,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'ec23e010878cf0841f910ef94f62294e40c7d77ce99be250dba2911d0a1a61cd',
        151516,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '0d37ac5823b014e3e50552370ee3868fedafcda8e309129fa769e2f2a5908947',
        174628,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'ed709f2ba2be295030614990104cb4c9c62bc2a2445c25ccb19a1500158a5a8b',
        150292,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '080843be82e9e08f0d19a3678b6cc92748afb93bed4dadf920197a6d3d86fea0',
        172720,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '959b003f035e38fa3f274632c1f7b54983688f9e8860c1bd0335fd1b309dec74',
        149072,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '0ab5746e65950113cc97c59d11c1b2ff29222c6ecead29819220b1621c129e6f',
        169984,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '3b2ce657fc4350b5a66ba61a748986d01abfe385401cb581ed35c44a7a1d5d88',
        147708,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '05aeab4a2bc04c13ad70ca2edfe9ac52af313012b26efe68d69e82fedad9a3f9',
        167692,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Poppins',
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

  /// Applies the Poppins font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Poppins
  static TextTheme poppinsTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: poppins(textStyle: textTheme.displayLarge),
      displayMedium: poppins(textStyle: textTheme.displayMedium),
      displaySmall: poppins(textStyle: textTheme.displaySmall),
      headlineLarge: poppins(textStyle: textTheme.headlineLarge),
      headlineMedium: poppins(textStyle: textTheme.headlineMedium),
      headlineSmall: poppins(textStyle: textTheme.headlineSmall),
      titleLarge: poppins(textStyle: textTheme.titleLarge),
      titleMedium: poppins(textStyle: textTheme.titleMedium),
      titleSmall: poppins(textStyle: textTheme.titleSmall),
      bodyLarge: poppins(textStyle: textTheme.bodyLarge),
      bodyMedium: poppins(textStyle: textTheme.bodyMedium),
      bodySmall: poppins(textStyle: textTheme.bodySmall),
      labelLarge: poppins(textStyle: textTheme.labelLarge),
      labelMedium: poppins(textStyle: textTheme.labelMedium),
      labelSmall: poppins(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Port Lligat Sans font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Port+Lligat+Sans
  static TextStyle portLligatSans({
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
        '450b98b5ebc7b82307e9a68d1b2dad3c4ab841eb7ec72f716ab1d3f10f1d2f84',
        31556,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PortLligatSans',
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

  /// Applies the Port Lligat Sans font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Port+Lligat+Sans
  static TextTheme portLligatSansTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: portLligatSans(textStyle: textTheme.displayLarge),
      displayMedium: portLligatSans(textStyle: textTheme.displayMedium),
      displaySmall: portLligatSans(textStyle: textTheme.displaySmall),
      headlineLarge: portLligatSans(textStyle: textTheme.headlineLarge),
      headlineMedium: portLligatSans(textStyle: textTheme.headlineMedium),
      headlineSmall: portLligatSans(textStyle: textTheme.headlineSmall),
      titleLarge: portLligatSans(textStyle: textTheme.titleLarge),
      titleMedium: portLligatSans(textStyle: textTheme.titleMedium),
      titleSmall: portLligatSans(textStyle: textTheme.titleSmall),
      bodyLarge: portLligatSans(textStyle: textTheme.bodyLarge),
      bodyMedium: portLligatSans(textStyle: textTheme.bodyMedium),
      bodySmall: portLligatSans(textStyle: textTheme.bodySmall),
      labelLarge: portLligatSans(textStyle: textTheme.labelLarge),
      labelMedium: portLligatSans(textStyle: textTheme.labelMedium),
      labelSmall: portLligatSans(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Port Lligat Slab font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Port+Lligat+Slab
  static TextStyle portLligatSlab({
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
        '81fa41860fa92264e04b596ead173758bb60be0c64de12bd0705f12e6aadca45',
        35600,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PortLligatSlab',
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

  /// Applies the Port Lligat Slab font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Port+Lligat+Slab
  static TextTheme portLligatSlabTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: portLligatSlab(textStyle: textTheme.displayLarge),
      displayMedium: portLligatSlab(textStyle: textTheme.displayMedium),
      displaySmall: portLligatSlab(textStyle: textTheme.displaySmall),
      headlineLarge: portLligatSlab(textStyle: textTheme.headlineLarge),
      headlineMedium: portLligatSlab(textStyle: textTheme.headlineMedium),
      headlineSmall: portLligatSlab(textStyle: textTheme.headlineSmall),
      titleLarge: portLligatSlab(textStyle: textTheme.titleLarge),
      titleMedium: portLligatSlab(textStyle: textTheme.titleMedium),
      titleSmall: portLligatSlab(textStyle: textTheme.titleSmall),
      bodyLarge: portLligatSlab(textStyle: textTheme.bodyLarge),
      bodyMedium: portLligatSlab(textStyle: textTheme.bodyMedium),
      bodySmall: portLligatSlab(textStyle: textTheme.bodySmall),
      labelLarge: portLligatSlab(textStyle: textTheme.labelLarge),
      labelMedium: portLligatSlab(textStyle: textTheme.labelMedium),
      labelSmall: portLligatSlab(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Potta One font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Potta+One
  static TextStyle pottaOne({
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
        '46bcce6f76fd1e987d60591b911332cbf3ef51f1bd2ca99b138caed86e8636e5',
        4911476,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PottaOne',
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

  /// Applies the Potta One font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Potta+One
  static TextTheme pottaOneTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: pottaOne(textStyle: textTheme.displayLarge),
      displayMedium: pottaOne(textStyle: textTheme.displayMedium),
      displaySmall: pottaOne(textStyle: textTheme.displaySmall),
      headlineLarge: pottaOne(textStyle: textTheme.headlineLarge),
      headlineMedium: pottaOne(textStyle: textTheme.headlineMedium),
      headlineSmall: pottaOne(textStyle: textTheme.headlineSmall),
      titleLarge: pottaOne(textStyle: textTheme.titleLarge),
      titleMedium: pottaOne(textStyle: textTheme.titleMedium),
      titleSmall: pottaOne(textStyle: textTheme.titleSmall),
      bodyLarge: pottaOne(textStyle: textTheme.bodyLarge),
      bodyMedium: pottaOne(textStyle: textTheme.bodyMedium),
      bodySmall: pottaOne(textStyle: textTheme.bodySmall),
      labelLarge: pottaOne(textStyle: textTheme.labelLarge),
      labelMedium: pottaOne(textStyle: textTheme.labelMedium),
      labelSmall: pottaOne(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Pragati Narrow font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Pragati+Narrow
  static TextStyle pragatiNarrow({
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
        'aa17ecd52b449c9f729b0b12daaaddd5453093e9f1bb6eb3618a6d037d7f2b58',
        208808,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'd932fb062cbe9cdf96d64b8a100edfde3d3fec9534bc5d1b9ee58d27e6b4e1f3',
        208068,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PragatiNarrow',
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

  /// Applies the Pragati Narrow font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Pragati+Narrow
  static TextTheme pragatiNarrowTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: pragatiNarrow(textStyle: textTheme.displayLarge),
      displayMedium: pragatiNarrow(textStyle: textTheme.displayMedium),
      displaySmall: pragatiNarrow(textStyle: textTheme.displaySmall),
      headlineLarge: pragatiNarrow(textStyle: textTheme.headlineLarge),
      headlineMedium: pragatiNarrow(textStyle: textTheme.headlineMedium),
      headlineSmall: pragatiNarrow(textStyle: textTheme.headlineSmall),
      titleLarge: pragatiNarrow(textStyle: textTheme.titleLarge),
      titleMedium: pragatiNarrow(textStyle: textTheme.titleMedium),
      titleSmall: pragatiNarrow(textStyle: textTheme.titleSmall),
      bodyLarge: pragatiNarrow(textStyle: textTheme.bodyLarge),
      bodyMedium: pragatiNarrow(textStyle: textTheme.bodyMedium),
      bodySmall: pragatiNarrow(textStyle: textTheme.bodySmall),
      labelLarge: pragatiNarrow(textStyle: textTheme.labelLarge),
      labelMedium: pragatiNarrow(textStyle: textTheme.labelMedium),
      labelSmall: pragatiNarrow(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Praise font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Praise
  static TextStyle praise({
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
        '2087d0eb49eb8323564cda884f297f40766d343607f2e4b65090cdb06d0cf8f1',
        97588,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Praise',
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

  /// Applies the Praise font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Praise
  static TextTheme praiseTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: praise(textStyle: textTheme.displayLarge),
      displayMedium: praise(textStyle: textTheme.displayMedium),
      displaySmall: praise(textStyle: textTheme.displaySmall),
      headlineLarge: praise(textStyle: textTheme.headlineLarge),
      headlineMedium: praise(textStyle: textTheme.headlineMedium),
      headlineSmall: praise(textStyle: textTheme.headlineSmall),
      titleLarge: praise(textStyle: textTheme.titleLarge),
      titleMedium: praise(textStyle: textTheme.titleMedium),
      titleSmall: praise(textStyle: textTheme.titleSmall),
      bodyLarge: praise(textStyle: textTheme.bodyLarge),
      bodyMedium: praise(textStyle: textTheme.bodyMedium),
      bodySmall: praise(textStyle: textTheme.bodySmall),
      labelLarge: praise(textStyle: textTheme.labelLarge),
      labelMedium: praise(textStyle: textTheme.labelMedium),
      labelSmall: praise(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Prata font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Prata
  static TextStyle prata({
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
        'dd969aa1fc429ecdb4862649feee6f24b6d313c658f6a703f184ac046eeb63f5',
        60272,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Prata',
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

  /// Applies the Prata font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Prata
  static TextTheme prataTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: prata(textStyle: textTheme.displayLarge),
      displayMedium: prata(textStyle: textTheme.displayMedium),
      displaySmall: prata(textStyle: textTheme.displaySmall),
      headlineLarge: prata(textStyle: textTheme.headlineLarge),
      headlineMedium: prata(textStyle: textTheme.headlineMedium),
      headlineSmall: prata(textStyle: textTheme.headlineSmall),
      titleLarge: prata(textStyle: textTheme.titleLarge),
      titleMedium: prata(textStyle: textTheme.titleMedium),
      titleSmall: prata(textStyle: textTheme.titleSmall),
      bodyLarge: prata(textStyle: textTheme.bodyLarge),
      bodyMedium: prata(textStyle: textTheme.bodyMedium),
      bodySmall: prata(textStyle: textTheme.bodySmall),
      labelLarge: prata(textStyle: textTheme.labelLarge),
      labelMedium: prata(textStyle: textTheme.labelMedium),
      labelSmall: prata(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Preahvihear font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Preahvihear
  static TextStyle preahvihear({
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
        '6b500722428c12066b7835b014adddc7df356ba4674ecdb7b0889625092b53c7',
        51856,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Preahvihear',
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

  /// Applies the Preahvihear font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Preahvihear
  static TextTheme preahvihearTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: preahvihear(textStyle: textTheme.displayLarge),
      displayMedium: preahvihear(textStyle: textTheme.displayMedium),
      displaySmall: preahvihear(textStyle: textTheme.displaySmall),
      headlineLarge: preahvihear(textStyle: textTheme.headlineLarge),
      headlineMedium: preahvihear(textStyle: textTheme.headlineMedium),
      headlineSmall: preahvihear(textStyle: textTheme.headlineSmall),
      titleLarge: preahvihear(textStyle: textTheme.titleLarge),
      titleMedium: preahvihear(textStyle: textTheme.titleMedium),
      titleSmall: preahvihear(textStyle: textTheme.titleSmall),
      bodyLarge: preahvihear(textStyle: textTheme.bodyLarge),
      bodyMedium: preahvihear(textStyle: textTheme.bodyMedium),
      bodySmall: preahvihear(textStyle: textTheme.bodySmall),
      labelLarge: preahvihear(textStyle: textTheme.labelLarge),
      labelMedium: preahvihear(textStyle: textTheme.labelMedium),
      labelSmall: preahvihear(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Press Start 2P font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Press+Start+2P
  static TextStyle pressStart2p({
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
        '8e9e854f71aebd3bb8342321d0cc92cabf68e27354dd7a90e806bce895da8dca',
        55168,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PressStart2P',
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

  /// Applies the Press Start 2P font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Press+Start+2P
  static TextTheme pressStart2pTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: pressStart2p(textStyle: textTheme.displayLarge),
      displayMedium: pressStart2p(textStyle: textTheme.displayMedium),
      displaySmall: pressStart2p(textStyle: textTheme.displaySmall),
      headlineLarge: pressStart2p(textStyle: textTheme.headlineLarge),
      headlineMedium: pressStart2p(textStyle: textTheme.headlineMedium),
      headlineSmall: pressStart2p(textStyle: textTheme.headlineSmall),
      titleLarge: pressStart2p(textStyle: textTheme.titleLarge),
      titleMedium: pressStart2p(textStyle: textTheme.titleMedium),
      titleSmall: pressStart2p(textStyle: textTheme.titleSmall),
      bodyLarge: pressStart2p(textStyle: textTheme.bodyLarge),
      bodyMedium: pressStart2p(textStyle: textTheme.bodyMedium),
      bodySmall: pressStart2p(textStyle: textTheme.bodySmall),
      labelLarge: pressStart2p(textStyle: textTheme.labelLarge),
      labelMedium: pressStart2p(textStyle: textTheme.labelMedium),
      labelSmall: pressStart2p(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Pridi font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Pridi
  static TextStyle pridi({
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
        '6a203e818c2df43809c2de3280751adea716ddcc943ad7b7f04950082103d98f',
        104492,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '1af02215445893d50b3a4e9e40b6b04cff4c38e3cb12eb3d5dc9186c424b5ce6',
        106940,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'fe3d792fc850c5480227c6e81cf204052d5ffd91fe1d857abff996893433f76b',
        108224,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'ae3a3ffdb97757419d65dea134a2fbe96273cc0aac2057816f0138579868793e',
        105508,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '7696864ba72b6ee5d405bbef2e3ad86a7f24ea7b71c2d65e6959c9f6570e0a62',
        102616,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '183e56adf4d872e6a86216efb2d3380e9e5ff78b5d7c1cf85b8b4e4f51a4fbeb',
        101764,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Pridi',
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

  /// Applies the Pridi font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Pridi
  static TextTheme pridiTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: pridi(textStyle: textTheme.displayLarge),
      displayMedium: pridi(textStyle: textTheme.displayMedium),
      displaySmall: pridi(textStyle: textTheme.displaySmall),
      headlineLarge: pridi(textStyle: textTheme.headlineLarge),
      headlineMedium: pridi(textStyle: textTheme.headlineMedium),
      headlineSmall: pridi(textStyle: textTheme.headlineSmall),
      titleLarge: pridi(textStyle: textTheme.titleLarge),
      titleMedium: pridi(textStyle: textTheme.titleMedium),
      titleSmall: pridi(textStyle: textTheme.titleSmall),
      bodyLarge: pridi(textStyle: textTheme.bodyLarge),
      bodyMedium: pridi(textStyle: textTheme.bodyMedium),
      bodySmall: pridi(textStyle: textTheme.bodySmall),
      labelLarge: pridi(textStyle: textTheme.labelLarge),
      labelMedium: pridi(textStyle: textTheme.labelMedium),
      labelSmall: pridi(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Princess Sofia font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Princess+Sofia
  static TextStyle princessSofia({
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
        '970bb1a01c8d692ead4dc75da70eae89204fd472ebfc088c529fc1e42aae7d9c',
        270232,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PrincessSofia',
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

  /// Applies the Princess Sofia font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Princess+Sofia
  static TextTheme princessSofiaTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: princessSofia(textStyle: textTheme.displayLarge),
      displayMedium: princessSofia(textStyle: textTheme.displayMedium),
      displaySmall: princessSofia(textStyle: textTheme.displaySmall),
      headlineLarge: princessSofia(textStyle: textTheme.headlineLarge),
      headlineMedium: princessSofia(textStyle: textTheme.headlineMedium),
      headlineSmall: princessSofia(textStyle: textTheme.headlineSmall),
      titleLarge: princessSofia(textStyle: textTheme.titleLarge),
      titleMedium: princessSofia(textStyle: textTheme.titleMedium),
      titleSmall: princessSofia(textStyle: textTheme.titleSmall),
      bodyLarge: princessSofia(textStyle: textTheme.bodyLarge),
      bodyMedium: princessSofia(textStyle: textTheme.bodyMedium),
      bodySmall: princessSofia(textStyle: textTheme.bodySmall),
      labelLarge: princessSofia(textStyle: textTheme.labelLarge),
      labelMedium: princessSofia(textStyle: textTheme.labelMedium),
      labelSmall: princessSofia(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Prociono font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Prociono
  static TextStyle prociono({
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
        'd76f3c8cbe2dab1d2d4e6845ea269d87fb7015ff6c70a0a71926d774c57c604b',
        28568,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Prociono',
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

  /// Applies the Prociono font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Prociono
  static TextTheme procionoTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: prociono(textStyle: textTheme.displayLarge),
      displayMedium: prociono(textStyle: textTheme.displayMedium),
      displaySmall: prociono(textStyle: textTheme.displaySmall),
      headlineLarge: prociono(textStyle: textTheme.headlineLarge),
      headlineMedium: prociono(textStyle: textTheme.headlineMedium),
      headlineSmall: prociono(textStyle: textTheme.headlineSmall),
      titleLarge: prociono(textStyle: textTheme.titleLarge),
      titleMedium: prociono(textStyle: textTheme.titleMedium),
      titleSmall: prociono(textStyle: textTheme.titleSmall),
      bodyLarge: prociono(textStyle: textTheme.bodyLarge),
      bodyMedium: prociono(textStyle: textTheme.bodyMedium),
      bodySmall: prociono(textStyle: textTheme.bodySmall),
      labelLarge: prociono(textStyle: textTheme.labelLarge),
      labelMedium: prociono(textStyle: textTheme.labelMedium),
      labelSmall: prociono(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Prompt font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Prompt
  static TextStyle prompt({
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
        'a489290a327fc510777e83dc82e711b781169edb7a84e2a785b5867ec4c864dd',
        90928,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w100,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'bd3c655402d47efd8cddebde74b9afd2282dd26b039f93ae2b0e487aa10090c2',
        100536,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '588ba94aa8c3d0d517dcac7ef3b1fc061153b53c6df2b7b0e1f6e05c73df4705',
        90896,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'cbe6b84d858740f8bc9913242f3e20fa01edbb32b8ef0519f0c1547934fd860a',
        100552,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'baf069e3700f657f80949346c929509c0e0f208da514d380e427bada5635b5fa',
        90300,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'ae280957d7c3fcf17881f323498a163916d72d7e2490a9a4775c0f9c6f59d308',
        99952,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '9b50e6c5262fe9153ad942fb914a5b57cb22f3397089de49de58eeda1c0dad45',
        90212,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '38e7c34ce7e432b73db52318813b6dd310f29f0b6e710c72eb524e879b9c18e9',
        98976,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '3a89ffa348255a18e0c17a93b50c3fc60e513d7b0ada71bc82b8520611865806',
        90152,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '0a9689dc478d6814ea7b89255ece8cb91ebddfa5e9805ec227d60bdbbe0fae69',
        98712,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '5bb01b2b8c5212b8d0e9290ead5691a895f910537d4ed4d6e9518c49920100e8',
        88144,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '98f312c2e42be523aabba2c918ed5fdb7414288e1654349ebf8ba34bcd54dcb5',
        98476,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '66bdb078d934c265653181ce3b20c446b41b649b50d774755765c72af7bf9cde',
        89704,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '35047d1cdaaf9794f6e2fd863bd4a159ea348432d2f7f7520a00b6f752e299a4',
        98096,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'c6f3e7c789f99bf8bb7dae3ccf8cebd3ef0933193fdffbddb638d42f1f8ecc86',
        89248,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'bb780b378160efe571a36af7533ae866b9dbe3125a21c76725d069351f153264',
        97988,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '4a9dde16bb4c8d123aa995dac5999bdcb06327a304184c2a47573626b2e7a23b',
        88988,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '69afa7ad7b23d764ff62beb1a0a79f3a6fb4af796aa007b81fa6a112b312bbad',
        111796,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Prompt',
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

  /// Applies the Prompt font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Prompt
  static TextTheme promptTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: prompt(textStyle: textTheme.displayLarge),
      displayMedium: prompt(textStyle: textTheme.displayMedium),
      displaySmall: prompt(textStyle: textTheme.displaySmall),
      headlineLarge: prompt(textStyle: textTheme.headlineLarge),
      headlineMedium: prompt(textStyle: textTheme.headlineMedium),
      headlineSmall: prompt(textStyle: textTheme.headlineSmall),
      titleLarge: prompt(textStyle: textTheme.titleLarge),
      titleMedium: prompt(textStyle: textTheme.titleMedium),
      titleSmall: prompt(textStyle: textTheme.titleSmall),
      bodyLarge: prompt(textStyle: textTheme.bodyLarge),
      bodyMedium: prompt(textStyle: textTheme.bodyMedium),
      bodySmall: prompt(textStyle: textTheme.bodySmall),
      labelLarge: prompt(textStyle: textTheme.labelLarge),
      labelMedium: prompt(textStyle: textTheme.labelMedium),
      labelSmall: prompt(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Prosto One font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Prosto+One
  static TextStyle prostoOne({
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
        '69aef8be92fb59ad8cffcbb12dae8f597f1332089e50b06f776c03b3402895ce',
        41992,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'ProstoOne',
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

  /// Applies the Prosto One font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Prosto+One
  static TextTheme prostoOneTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: prostoOne(textStyle: textTheme.displayLarge),
      displayMedium: prostoOne(textStyle: textTheme.displayMedium),
      displaySmall: prostoOne(textStyle: textTheme.displaySmall),
      headlineLarge: prostoOne(textStyle: textTheme.headlineLarge),
      headlineMedium: prostoOne(textStyle: textTheme.headlineMedium),
      headlineSmall: prostoOne(textStyle: textTheme.headlineSmall),
      titleLarge: prostoOne(textStyle: textTheme.titleLarge),
      titleMedium: prostoOne(textStyle: textTheme.titleMedium),
      titleSmall: prostoOne(textStyle: textTheme.titleSmall),
      bodyLarge: prostoOne(textStyle: textTheme.bodyLarge),
      bodyMedium: prostoOne(textStyle: textTheme.bodyMedium),
      bodySmall: prostoOne(textStyle: textTheme.bodySmall),
      labelLarge: prostoOne(textStyle: textTheme.labelLarge),
      labelMedium: prostoOne(textStyle: textTheme.labelMedium),
      labelSmall: prostoOne(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Protest Guerrilla font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Protest+Guerrilla
  static TextStyle protestGuerrilla({
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
        '252d087ef16fe4b43f17eddacfa63105741a98653f8ac91b9d510e6b2c3af5ec',
        58680,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'ProtestGuerrilla',
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

  /// Applies the Protest Guerrilla font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Protest+Guerrilla
  static TextTheme protestGuerrillaTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: protestGuerrilla(textStyle: textTheme.displayLarge),
      displayMedium: protestGuerrilla(textStyle: textTheme.displayMedium),
      displaySmall: protestGuerrilla(textStyle: textTheme.displaySmall),
      headlineLarge: protestGuerrilla(textStyle: textTheme.headlineLarge),
      headlineMedium: protestGuerrilla(textStyle: textTheme.headlineMedium),
      headlineSmall: protestGuerrilla(textStyle: textTheme.headlineSmall),
      titleLarge: protestGuerrilla(textStyle: textTheme.titleLarge),
      titleMedium: protestGuerrilla(textStyle: textTheme.titleMedium),
      titleSmall: protestGuerrilla(textStyle: textTheme.titleSmall),
      bodyLarge: protestGuerrilla(textStyle: textTheme.bodyLarge),
      bodyMedium: protestGuerrilla(textStyle: textTheme.bodyMedium),
      bodySmall: protestGuerrilla(textStyle: textTheme.bodySmall),
      labelLarge: protestGuerrilla(textStyle: textTheme.labelLarge),
      labelMedium: protestGuerrilla(textStyle: textTheme.labelMedium),
      labelSmall: protestGuerrilla(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Protest Revolution font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Protest+Revolution
  static TextStyle protestRevolution({
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
        '11f5b933e668b2e1d23a70a32415a2841483176eb7d998a5f2fbe5b955206c4a',
        600592,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'ProtestRevolution',
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

  /// Applies the Protest Revolution font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Protest+Revolution
  static TextTheme protestRevolutionTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: protestRevolution(textStyle: textTheme.displayLarge),
      displayMedium: protestRevolution(textStyle: textTheme.displayMedium),
      displaySmall: protestRevolution(textStyle: textTheme.displaySmall),
      headlineLarge: protestRevolution(textStyle: textTheme.headlineLarge),
      headlineMedium: protestRevolution(textStyle: textTheme.headlineMedium),
      headlineSmall: protestRevolution(textStyle: textTheme.headlineSmall),
      titleLarge: protestRevolution(textStyle: textTheme.titleLarge),
      titleMedium: protestRevolution(textStyle: textTheme.titleMedium),
      titleSmall: protestRevolution(textStyle: textTheme.titleSmall),
      bodyLarge: protestRevolution(textStyle: textTheme.bodyLarge),
      bodyMedium: protestRevolution(textStyle: textTheme.bodyMedium),
      bodySmall: protestRevolution(textStyle: textTheme.bodySmall),
      labelLarge: protestRevolution(textStyle: textTheme.labelLarge),
      labelMedium: protestRevolution(textStyle: textTheme.labelMedium),
      labelSmall: protestRevolution(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Protest Riot font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Protest+Riot
  static TextStyle protestRiot({
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
        'a0b17219049310dcdad28287f187c77961302f6c97787245e2d5cf6834c8b05d',
        74092,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'ProtestRiot',
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

  /// Applies the Protest Riot font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Protest+Riot
  static TextTheme protestRiotTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: protestRiot(textStyle: textTheme.displayLarge),
      displayMedium: protestRiot(textStyle: textTheme.displayMedium),
      displaySmall: protestRiot(textStyle: textTheme.displaySmall),
      headlineLarge: protestRiot(textStyle: textTheme.headlineLarge),
      headlineMedium: protestRiot(textStyle: textTheme.headlineMedium),
      headlineSmall: protestRiot(textStyle: textTheme.headlineSmall),
      titleLarge: protestRiot(textStyle: textTheme.titleLarge),
      titleMedium: protestRiot(textStyle: textTheme.titleMedium),
      titleSmall: protestRiot(textStyle: textTheme.titleSmall),
      bodyLarge: protestRiot(textStyle: textTheme.bodyLarge),
      bodyMedium: protestRiot(textStyle: textTheme.bodyMedium),
      bodySmall: protestRiot(textStyle: textTheme.bodySmall),
      labelLarge: protestRiot(textStyle: textTheme.labelLarge),
      labelMedium: protestRiot(textStyle: textTheme.labelMedium),
      labelSmall: protestRiot(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Protest Strike font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Protest+Strike
  static TextStyle protestStrike({
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
        'a4e0c466aa53e3705612e3c8d6d8ddeeda2e15bd0f776e71b49eff78b79b92a9',
        58504,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'ProtestStrike',
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

  /// Applies the Protest Strike font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Protest+Strike
  static TextTheme protestStrikeTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: protestStrike(textStyle: textTheme.displayLarge),
      displayMedium: protestStrike(textStyle: textTheme.displayMedium),
      displaySmall: protestStrike(textStyle: textTheme.displaySmall),
      headlineLarge: protestStrike(textStyle: textTheme.headlineLarge),
      headlineMedium: protestStrike(textStyle: textTheme.headlineMedium),
      headlineSmall: protestStrike(textStyle: textTheme.headlineSmall),
      titleLarge: protestStrike(textStyle: textTheme.titleLarge),
      titleMedium: protestStrike(textStyle: textTheme.titleMedium),
      titleSmall: protestStrike(textStyle: textTheme.titleSmall),
      bodyLarge: protestStrike(textStyle: textTheme.bodyLarge),
      bodyMedium: protestStrike(textStyle: textTheme.bodyMedium),
      bodySmall: protestStrike(textStyle: textTheme.bodySmall),
      labelLarge: protestStrike(textStyle: textTheme.labelLarge),
      labelMedium: protestStrike(textStyle: textTheme.labelMedium),
      labelSmall: protestStrike(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Proza Libre font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Proza+Libre
  static TextStyle prozaLibre({
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
        'b794eb5e68c76f1be231c6abd83206310d36a11079fa39c789b7bcc310e66288',
        76196,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '83bad983eca414b664a29ed143268ad65f1e0994116be3b7437531465af33166',
        76068,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '8736a3a1098c5523c6b05fb8b47a4f8ef005df6cd4c8d3cc29d95af6ce08e72c',
        76272,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'b168db04e9d0e28c9a73b994528dd61226db580191372bc9643a9b436d41fabe',
        76424,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '11121bf929802549ba247318f909f057b9bc81376e6671d815fdac994f3fcb34',
        76508,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '0510042f3e1ff0fa3ff2afa95271ec3e5adc7737ec70e8f1604a9f5e596e402b',
        76428,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '8a86b73094aafa9de9ab868185799b92d6b67d32ab9cef91b2edff4c225d51d6',
        76084,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'ec3614b2eee1833771c89e21c4c70eb3770b26b7290e2465e94f7ef7cc7ad065',
        76224,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '2b04207f332a3a7c05f6aa3bbb6328ce2f4f5c6fff1c59097f45902f46507f52',
        89932,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '9a7c3d16aee13a00d55b67bd114de9890ac30c30aa6fcbfc791e56c76e9d6297',
        89228,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'ProzaLibre',
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

  /// Applies the Proza Libre font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Proza+Libre
  static TextTheme prozaLibreTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: prozaLibre(textStyle: textTheme.displayLarge),
      displayMedium: prozaLibre(textStyle: textTheme.displayMedium),
      displaySmall: prozaLibre(textStyle: textTheme.displaySmall),
      headlineLarge: prozaLibre(textStyle: textTheme.headlineLarge),
      headlineMedium: prozaLibre(textStyle: textTheme.headlineMedium),
      headlineSmall: prozaLibre(textStyle: textTheme.headlineSmall),
      titleLarge: prozaLibre(textStyle: textTheme.titleLarge),
      titleMedium: prozaLibre(textStyle: textTheme.titleMedium),
      titleSmall: prozaLibre(textStyle: textTheme.titleSmall),
      bodyLarge: prozaLibre(textStyle: textTheme.bodyLarge),
      bodyMedium: prozaLibre(textStyle: textTheme.bodyMedium),
      bodySmall: prozaLibre(textStyle: textTheme.bodySmall),
      labelLarge: prozaLibre(textStyle: textTheme.labelLarge),
      labelMedium: prozaLibre(textStyle: textTheme.labelMedium),
      labelSmall: prozaLibre(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Public Sans font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Public+Sans
  static TextStyle publicSans({
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
        'cbc55ef297c51e1a0f8c72e05717a4711074e6e040f9c9657ff88b29f1b0067d',
        56000,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '807c09d5b99bdaf4f084b226c873fe2d4ca33bab5945fed83567d2a3f16d342d',
        56176,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'ad7bf570be7407917699d4eadb6a415b81b38099b66b677ce133e2f0d7c6049a',
        56176,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '66ba2d7468d17e65d7538ae9ddc6e663510174db00bf10003d0726c817cf8a18',
        56148,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '679cce2a9e56089a66c76772e3fb3924a01325a094ac8f3d5f2d489ca9781069',
        56140,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '968c928dfacff6aa0ece63e93b2865deece05577da941f453ffc7e48b665d4da',
        56220,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '6707c8bf0774eec994c7ae15c8cbe9adb13c5fad63b4cfdd9733e94ab7f40277',
        56340,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'b314c88b978246718779b1530c1e3e65e31ac9e4f3d5d838fe0e5d4a63a02c77',
        56508,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '05e6a4da968754f0614965a2d228e04f06babc1c50c1c512ea2e91c4e82c9dd0',
        56476,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w100,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'edb39f3dbacddcd877d4732cfbc9490cfd7bf4a5855b01c7470ba2767fee1a47',
        58248,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '3179dd0d18e85849aef78ae55c83789614358a5a999f900b9e5a18d7a9ef0490',
        58476,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '7e85bfc9f9f3a84d4bba169ef15dbe2c2f2a2a609c8b2f60575645a038ab7c5e',
        58424,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '3d778a4166530a9dc308fa32cafd0a7d95d2efe12efce3ca92fee8c6f289c925',
        58280,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '2926bfbe1ca0b702a81dff880515452ce35bcb555f78486d76951e647e3e0e50',
        58400,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '7552a78c51bcee8a38a952b7508d43981416c45c4afa73eef3ab5db899986c7e',
        58536,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'a15e4e721e3a036eac47141fb7f977b8040264af943e18757af77ba300d6fae8',
        58684,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'a9c5315d2ae5fc100d938c56672343340596ffe69b31d9e0c3784829a2e5e322',
        58892,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'f01005a9323da92732c62aa76dc0f58827b477069cc7587b9c95d8995eb1f55c',
        58868,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '423c8f69a5ffdb9125b13102ffbd503cbf60cd290075daba2c6f32943eb5375d',
        98212,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '11556545acab3c5bc59bc9678cc9256c27114f08c8f8d327583827c9eae32d2b',
        102588,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PublicSans',
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

  /// Applies the Public Sans font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Public+Sans
  static TextTheme publicSansTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: publicSans(textStyle: textTheme.displayLarge),
      displayMedium: publicSans(textStyle: textTheme.displayMedium),
      displaySmall: publicSans(textStyle: textTheme.displaySmall),
      headlineLarge: publicSans(textStyle: textTheme.headlineLarge),
      headlineMedium: publicSans(textStyle: textTheme.headlineMedium),
      headlineSmall: publicSans(textStyle: textTheme.headlineSmall),
      titleLarge: publicSans(textStyle: textTheme.titleLarge),
      titleMedium: publicSans(textStyle: textTheme.titleMedium),
      titleSmall: publicSans(textStyle: textTheme.titleSmall),
      bodyLarge: publicSans(textStyle: textTheme.bodyLarge),
      bodyMedium: publicSans(textStyle: textTheme.bodyMedium),
      bodySmall: publicSans(textStyle: textTheme.bodySmall),
      labelLarge: publicSans(textStyle: textTheme.labelLarge),
      labelMedium: publicSans(textStyle: textTheme.labelMedium),
      labelSmall: publicSans(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Puppies Play font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Puppies+Play
  static TextStyle puppiesPlay({
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
        'b316722d9f408bd52ef25b5b786b903ea36a2dcd116d1e95c10bb9c558de0a9c',
        103680,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PuppiesPlay',
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

  /// Applies the Puppies Play font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Puppies+Play
  static TextTheme puppiesPlayTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: puppiesPlay(textStyle: textTheme.displayLarge),
      displayMedium: puppiesPlay(textStyle: textTheme.displayMedium),
      displaySmall: puppiesPlay(textStyle: textTheme.displaySmall),
      headlineLarge: puppiesPlay(textStyle: textTheme.headlineLarge),
      headlineMedium: puppiesPlay(textStyle: textTheme.headlineMedium),
      headlineSmall: puppiesPlay(textStyle: textTheme.headlineSmall),
      titleLarge: puppiesPlay(textStyle: textTheme.titleLarge),
      titleMedium: puppiesPlay(textStyle: textTheme.titleMedium),
      titleSmall: puppiesPlay(textStyle: textTheme.titleSmall),
      bodyLarge: puppiesPlay(textStyle: textTheme.bodyLarge),
      bodyMedium: puppiesPlay(textStyle: textTheme.bodyMedium),
      bodySmall: puppiesPlay(textStyle: textTheme.bodySmall),
      labelLarge: puppiesPlay(textStyle: textTheme.labelLarge),
      labelMedium: puppiesPlay(textStyle: textTheme.labelMedium),
      labelSmall: puppiesPlay(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Puritan font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Puritan
  static TextStyle puritan({
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
        '1cb7f55e5f92b1ebd41ed56532c723d8e39af753319441a3702b11d4ffc3bce7',
        22600,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '175b8c86afcba7b9a08130700b7aa26aff348e0a1634c70ea2ba12fbf40fac6a',
        23880,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'c09bf5c069ad1de20a3404e99d46dc169e0e5e4cbcc8361585e37173a40d6897',
        22376,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '70f00c0ac7ccbc41cc29cb6db7df2b241c27143436b3d81fd34c346673dd9359',
        23772,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Puritan',
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

  /// Applies the Puritan font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Puritan
  static TextTheme puritanTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: puritan(textStyle: textTheme.displayLarge),
      displayMedium: puritan(textStyle: textTheme.displayMedium),
      displaySmall: puritan(textStyle: textTheme.displaySmall),
      headlineLarge: puritan(textStyle: textTheme.headlineLarge),
      headlineMedium: puritan(textStyle: textTheme.headlineMedium),
      headlineSmall: puritan(textStyle: textTheme.headlineSmall),
      titleLarge: puritan(textStyle: textTheme.titleLarge),
      titleMedium: puritan(textStyle: textTheme.titleMedium),
      titleSmall: puritan(textStyle: textTheme.titleSmall),
      bodyLarge: puritan(textStyle: textTheme.bodyLarge),
      bodyMedium: puritan(textStyle: textTheme.bodyMedium),
      bodySmall: puritan(textStyle: textTheme.bodySmall),
      labelLarge: puritan(textStyle: textTheme.labelLarge),
      labelMedium: puritan(textStyle: textTheme.labelMedium),
      labelSmall: puritan(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Purple Purse font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Purple+Purse
  static TextStyle purplePurse({
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
        '2a2a42f6e80f35a3eccae7f30d1f7ab086cfe2d4905020d35c9d2b3994e6b952',
        59664,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'PurplePurse',
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

  /// Applies the Purple Purse font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Purple+Purse
  static TextTheme purplePurseTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: purplePurse(textStyle: textTheme.displayLarge),
      displayMedium: purplePurse(textStyle: textTheme.displayMedium),
      displaySmall: purplePurse(textStyle: textTheme.displaySmall),
      headlineLarge: purplePurse(textStyle: textTheme.headlineLarge),
      headlineMedium: purplePurse(textStyle: textTheme.headlineMedium),
      headlineSmall: purplePurse(textStyle: textTheme.headlineSmall),
      titleLarge: purplePurse(textStyle: textTheme.titleLarge),
      titleMedium: purplePurse(textStyle: textTheme.titleMedium),
      titleSmall: purplePurse(textStyle: textTheme.titleSmall),
      bodyLarge: purplePurse(textStyle: textTheme.bodyLarge),
      bodyMedium: purplePurse(textStyle: textTheme.bodyMedium),
      bodySmall: purplePurse(textStyle: textTheme.bodySmall),
      labelLarge: purplePurse(textStyle: textTheme.labelLarge),
      labelMedium: purplePurse(textStyle: textTheme.labelMedium),
      labelSmall: purplePurse(textStyle: textTheme.labelSmall),
    );
  }
}
