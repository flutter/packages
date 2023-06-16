// GENERATED CODE - DO NOT EDIT

// Copyright 2019 The Flutter team. All rights reserved.
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
        '61620675803f698131e86cf064952390b832f3a0f99f62c73ac81154c6750601',
        60420,
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
        '6a4f45115f0edfd41682c245df0a47b848b5481e2667157d678c2d90b6e1fd0c',
        66220,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '97c20c193a14afdb34dd049d23ae28d22d9ff16b5b4b4c1d1940c98dcea862cd',
        69168,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'c671689a4d5accf2d33e669688b409bad32c068681501dba0b363dce32c08db7',
        66504,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '7cdb63d16bfaabb01ddade50df20bababc0a4dc40933ab9bce7884ec9ab8ae6c',
        67072,
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
        '43148a651032c9c84a1d65382e00106356e8a26e79f9eec239ab1c0279e18199',
        69824,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'aac584531c39378baf684f2506643cad4e5ac1ee405cda09a9626a638ba6dcda',
        76520,
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
        'd00add3a7d91f903eb33bcb08d397693c60d68bb5673410ba279a83490f8b054',
        170408,
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
        'eb79c2d944e6bad1454af9c526f7b0f455ae9121b057b63fba13233563ecb20e',
        161264,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '87ab0343137d5b40f3f68001c44798e863129804436ee6f8e701faf3dee6d0aa',
        161684,
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
        'bc78949640efd655010c39e69aaeda9530490c7e743461b068199dec2490ed51',
        266328,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'f92c8b2448b71e06c16c3aeebb5ad089b8283a712dabddd0fe77c3ea73e0d33e',
        267856,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '422da9ad3c93a5266cb5c8a25bd62267dfde9feec5e474592953728ef84ae4cb',
        268072,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '7d73cc743a5f5ff41cf04b3bf381ae685a22a04a9363076defa1ed4ca5ca2742',
        276056,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'c3ba2aa43b9021b782440d1d83c839344117e146742ab8e92733a04666efbcb8',
        275212,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '2590e0e5b947eb96b17ddc6d28943c8b4e506ad23525f9f838c08374f4b55cee',
        275368,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'a3ab51a4aa09c3d81b3bce84fc223bcf3d8d39b64a1de96327333eb9291be9c9',
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
        '191fc8a1e3b4668bbb19cc9af2b229e4263c9c2648bcaa6facde50cdc59c4e22',
        258504,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'e7c8fd936e57eebbdb1b4fda7f68de616916b9a59f59262c93231b1336688e19',
        265792,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '6b32cb1d23c41e4b5986de84c7fdafcfd12a4ffc68d06b34e1969429277b033e',
        267276,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '837b8e7dbc881fde1383e15f1eb2a13625f61f388ba02a8ad1f1567edfb59c4f',
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
        '1c44a4167df6a652d60eff5592d747a10d1e25c136037d6d899864bc67b5d264',
        235316,
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
        'a2f58eb822f72ee97f41d537a95e3a1d552530a57ba1e38751d57c48df19ee63',
        61404,
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
        'd2db2684e8935576e37c73e94f92c3dc60d4efbaddfad9c64afb4aaab4d21e4b',
        57136,
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
        '8d6ddfbe03cb652eec90cbf4132a5d73459b20f305864f7ab40be49c77548b08',
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
        '2ce584979ecc740ed4d94f123f0bc1612989ea03455e8dd26e85d26e218b8228',
        22532,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '0f60994b94f3453708949987c5f4de2c6565de04b9cc9dee0b6e7994c00ea0c4',
        22332,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '4a6387bd194071ae48a95dd6cb519324455a117ebe3d25ec46818cd809460fbc',
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
        '14d1d89ec564c9165e51cb0325c0ec56157d53ba4393e12c44ccd3d443cdee68',
        97492,
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
        '32be52a6c083c152b0d05252078e61e818ead9a0098369c31baf97439f6b4134',
        71284,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '1dccfb204d86c59c0e001e131fa60fa56437b15009a9609ea16e8955bcfb6e7b',
        71296,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '85e72e8f579b876587e196df1ba953b8cb1d6564c6995e0b315d59970c83d571',
        71296,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '36443c634364bf8734860f42dd9ba253b217b87621e1148e61bc61eb28dff0ca',
        71312,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '7b38c8618914002694a0d9f035d401ba6e95889036ae80cdeeeaf0c0bb1d2ded',
        71336,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'e7711efa2601306310c95b4c8bf67ebc51f327e09d7a1c995af12c3e5d084e1e',
        71344,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '089eef74e952632f14c0be299517703357a0cee6ebf0d4ef4990cefa91901919',
        71320,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '8e01871585e96f1af1e78bde4d3506da34755bf3058f1b1950ae0196e1bd6d79',
        71420,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '0300e0b5ade718d4368571574cda34cb3d6506beb5ed7cfa164f52c6efa95659',
        70800,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w100,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '99fdb265620b1173db35b2ab7d94643f14803aa300f40efc7f2cde8e6b300452',
        54196,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '2150d00c8d3beab5856d168226bb612fbc5b98686f80f1952e65ca76c4f8e67c',
        54232,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '57fc6d7a85be91531f228fb2f0c1ba21de350bf3e83c335414c40074b69eb64b',
        54200,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '283782d3e7e440fc40a549c355404014843831f13768f8d9ca74f365111de8fc',
        54108,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'e1c7453a1f74c52adf8df11778601fc054e273ca270f6eda022dab3451f0b924',
        54236,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '444bae9e180019d87aff12f7a13aa194649b280c81668f2a73efe89c6bad9c99',
        54288,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '674dd8376561c140ce7c9b25f45bb488f945b4fb86492193eea181f88d49b2a5',
        54224,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'ff4a3ac9746d4175435735b25e10e803fc8337d2b442412adf1bb04a004fc72e',
        54404,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '6e5c0a5224496beb9ba59840b2c2cf497156306c6ad77399bc6dc2cf18e36b42',
        53808,
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
        '3fed30da7d0fa977883405b4f71b1b092091ea919b5924255b21c0424a209242',
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
        '82e5e1a07e448d4b75eeeac02f45e6c1aa44100fb8260c4feeb7a286b1bdadf9',
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
        '4262d730d1f40976e5f2c67f582a81d98f6001c3dd47c1c79eec8501b04113c7',
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
        'b810ebafb000c09b01ed598d6b0e1d9d0e464568738a970a8d9032e7f648eebd',
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
        '2d45bfb9bfc5515838e5ecd83fcb1560c29ef44ddb51258ffa1eddb057207f4e',
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
        '76a02cbd18995f08626f822b75ab64928d13930841a9e1bc101da523d0ddb3a7',
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
        '6fbbce30d76ab765d0d2808216f873765b430cf1d770bdd73a3d501f80301795',
        56848,
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
        '5860d03b182eecb6784906194844f7cf4b4d377a91847ac0ca8409d519af5fbe',
        86036,
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
        '23b7c1f8bc4f40de75932d2b535c8417be16a063f99f79a31f83625d77c99533',
        70500,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '769fe1c23ac7bb65a5f452a3f3c1dfd0ebd9919fba6dce129519399fb3352bb4',
        70960,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '2a3ced26dffa571e9af06df2e8f993f618d287a756679e3b5b3b19bbf5cb0878',
        70888,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'b70b53a3bab899fa04a4e0521d1db8b6f37ea7a87209505195cd792b43985938',
        70824,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '76b83e6d1c612cf1f5b89053cf6d22211be4d6d4cee356da3c7b3ad5c391467a',
        70884,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '36084dfd35dd36f620da5a26d692b4f197d8000862f791f08161a80b49a21663',
        71244,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'ff4c11ff083d56c085e363d0118a5a6f0f8b4013c919a2072f7acfe4c3b68366',
        71240,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '76773c6546827004f1cd5a7e42697dabf5d0e18c4894ad8620800e0a3a52f2a6',
        71272,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '8f88ac81537802ec95d444acb84398677f854c1f58e5243c1d3ffc83fe5399fd',
        71132,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w100,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '8dcbb4bf77dc57d1351a739970424cf9c3a47c368efbfa0959ac6acb73c89735',
        74992,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'fd28a831091f6587e79747e19dfc4afb4a391b627d8aaab5047a429d59ec7d9e',
        75880,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '68209f40a087d172f8b32dae93a0dc2411f1477884224bbc7a3526f07591b820',
        75904,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'fc3d173a9dc82a9c6278c6596732c5c1d70936f0eb69142b415b3086ac98f948',
        75900,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'c9b65c7c4ace15e886c6da3f96cf6ffb22ef3b3590d9c9b7b04967e5c0551320',
        75988,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '766a77e7efbf0917b7f85a7149b7306892c45ac933cbf87e65a6eb74e30e27f7',
        76276,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '73a8c527100a39289b4358eb5a703e388c046c0d8ecf75780b3ba46a49add568',
        76220,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'b610bdece7ca75d7d6599e37475f1c70b1a5d786b0180c37976480ff8a79c702',
        76284,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '52e3ab7774ed5ad8cec129c90a9c07c5b54386c63d396146abef1a090f3e2485',
        76100,
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
        '0ddf1d3369b3c53fbdaf845334102a58e41432e789422d1189432a16d97032e9',
        67416,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '913d6c4d14fc526db65bd55da0ea7d38f7ab96ddfc4b5aa2080a7774d5e21e2d',
        68932,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '6a0eedb975dee1fe50f423f1968acb072cd9d03bf3614987ff0fe2a6b2bc9bcf',
        67192,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '012b2a84223455e832e113f3b5001682f24809607b8dbfaab305722b3d07ecfc',
        69384,
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
        'f0eecde45310f495a829494bd7b53b66798e02c4f5186d8b5d669d3616294b2e',
        64348,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '8a7fc88205495ca2de8223a6868c1319e1b5eb582faa3da4bc588495c6d8178a',
        64268,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '9e9547b7898cbc339de1646650df1c176d8b92461a7636066fbed3dbe2991f00',
        64304,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '51f5abd8abb7aad78523e1f8ae62f23a380e5da6e0cdb6227df31aaba76b855c',
        64284,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'e880a1ebaf84e09f3cb96df2ad18c6da5e3761afe42e0e2ccc17bc75cc1ad37c',
        63604,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'd0650da32caad81c291e24d343393874d7e73ae6566742dbc1da7c53c08f3c57',
        64312,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '304bcd125a72c8269ecb393344202eee88c641d6f23b58fc79874710f5f4198d',
        64304,
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
        'eb2223aac39d48a765c374de3ac4a88d46233a0c42a607eb1ecf87643408398e',
        135932,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'c66a69851cb91b1e8f28967f5c5efd7ea51453059134d263a9805df7fe8fc9a0',
        136008,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '3feddf1bd920700903a44e3d552c96f5fc390eb517ec4b1e87849de606e10c00',
        136064,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '543eaa1e5a4a4f3cda972f5b90652d2c59eb8885207926911584b5a0b74b3ccd',
        136080,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '1557b961c0a64eaed3a8f47405da6beab98a90b6dc4133a4924442ca42c5bbfc',
        136188,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '810b9719ca38ad24d83ce991e24310e00c12b20c13fe50b76b9b002559028eca',
        136284,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '487b305c29bb7491f3de9e2ce80c7b48549864df967a4dec67c2a89cd81b9af3',
        138096,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'e6424765532d8e25429993ee43d775502c0ae0410c46a88ad91ca0af3eff4144',
        138224,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '3e3a70bfdcf0a95be20a74145764c94e4e6d482bab030e17035a6f33452c6c34',
        138312,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w100,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '6479232af20f30d89191f0bdd3ad64a69454618decf5d8486b6d422c8deab9c6',
        137184,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '8e4b7b1b292eb954cdc19ec23a65a3da5309683b74b39f01d736ddb913f0beea',
        137348,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'b2bb50938adb3f51ffd20beb0e884422d37640f2f29e1a6768acebea0544374e',
        137356,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'd44563d5f78dc7cb4b91fb07c6df9270b179d17f1bafc390466648ee3376e7b1',
        137208,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'b04b2b182ae7ae303ee16bc7bef1d4524fb268106938bd073c384c484a0f0cfd',
        137764,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'a503b28ea0b4bc3e1143784cc438355b364be93a7847002201f51a5c049c7d95',
        137860,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '06ab2d9147afba6d50e68999834cdca87f61299a11afb6bb91f1b3e4023e876d',
        139392,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '2d2aa8acef53d5686d6630166f837cc3f9b22099a286e2f04138626844463f2d',
        139520,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '235fc9de8a70261c796f5da366ba643595782687dd736ab2afae3024eeb84204',
        139520,
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
        'e8a3225c84c1e95d8814d62d3f1495bac69f7265209866e1069a72bc629e8e6b',
        105364,
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
        '3597113a9b547a2f2f1e38b48d5c8c0cfacf0819c4405635c8b79384a8c6c4d5',
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
        'a2bac54655d89ca927b46d12c6c011d2ace6eadd6705a2c5aeaf5c32c8d9b3d1',
        28044,
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
        '87dc25938534fe3359f2320e115b81e55cb90512199be0fb296ce96fea0a4ce3',
        84876,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'e48dc9cd68c5304da355ba565b0b8c1b7e6058033acc06b844e46a6e7de5e36b',
        85856,
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
        'dc2628b3c224cf8259a48469a86d9b02395dd71044f690ea553ec757fb1ceaa4',
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
        '26252f66458d2b59d34781ad3edc302b6aba9a567198b3417999fd384aeeeeab',
        123176,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '7c8900348a0d0bf852e9b7a1ba3e4b115c1a5a107d8507d719ecd46633ba506e',
        123540,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '5702f276eac5ce344af67c57df28e8e689ef982f068ae2efbb258bbf9b685143',
        123608,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'e3a772adf3668d5394d2a8ca0b8430e09a69ee641744a6133e3054de07434e28',
        123468,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '35fa7d45959af1db8f5c9ffb162748b92a1442ab0bdf604b63d3271a57722b02',
        123540,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '522d9c25ffe9606d2b231248cfafe55d714b1c9443c41553b5bee5425c11425f',
        123464,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '240d7456846b9e76cae058d2c4c9d9766b766426ec32053d3659554a509a78af',
        110776,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '0da5f482e9936a888e71abaeb534d78b415a61ddfebcd731fb6b5fdd6017557d',
        111128,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'c05375a52355aabc27d0afdb64d33dac784826f1ed5eed84a83358f9dc47f843',
        111160,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'd4059ae3f7982d96c8b574b12a7775fa83ca6a9ab392fe390622b6a31ed2e401',
        111064,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '110b4a179ddae9effa90b7ec44d79bb83605ffaca825486e147d8cb3b4594195',
        111048,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '2b37e77291c15edcb1556eeac3f110d24de5e73cf05063459dd717ff7fd0af81',
        110688,
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
        '2f13bfd324c8d216d47bae4ea721f22eef366014fa840d3f1bac3fd48a73869d',
        94340,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '7e18e0b16594ec807b46963ad7b21589cd8283f72f087ae288a43c8e80a7df63',
        91492,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'a6b28eb0402ac35154975914b6788e6ed1651f39cfcbb2cfe734dee369d9cbd2',
        97320,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '30f58569af160a4acfb1ea34af5a26f20eff5d1d5fffc236c1365fd79bce7415',
        94452,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'd1a86f44058098e05949a322ebc45623e9c26f3031184d021604f59f1981d4f2',
        96100,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'd8220fb7fdc9826905f9674a3448aa9dc121dec3fd3d69f0fdedc048ae43bbac',
        92760,
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
        'cd931c02ece53167dcba0ef17aa7deba1c0df77f3dd471e600bbcc03eb3c3b9f',
        63196,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '37ae3c859d5985cae47e412093a518a8c58d8f41996be2bac0c87eb31408af4b',
        63164,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '4597957691de6665850da72e373fc34e555badca842ea6fdddd2407baadaabe4',
        63144,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '8e4ed68b5fa75e6081983ad80dfd4e91ba5659b78db8d6ece0073234eec87f20',
        63196,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '941b3282d23f016f5425197fe0d2d2dd20bdcf6e9e40e7e6719b05c21987e443',
        63204,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'fa4b65d420cbc7e3b62f74f3760a10cb0abc4d56d156d5d1a94c87c11a5e5c6d',
        63132,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'db749963d6b5e867f19688a6cd716e052d61c506dd27fc9bff8d1c4637fb5891',
        63168,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '54c5a80a09fca0930e667cbfb38c1e05caa363f7644fc7ba28ab7a67fedbc959',
        64928,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'e13cecddb846261cc524b1a00ec4aa2d870e98e2a3b80fde46985a7356527c45',
        64896,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'fb2a33a5975e1a9f51338dead1363cefc4072ea3d6786cf2a5db2c44ce3eff49',
        64660,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '47a2b76a0e9aba1c7b9affd3f4acd986f66cf04cdbb5363e059d0b0d1be4ba31',
        64880,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '755ab0299c20a9edfeb96341fcdeb62e7196599b03a0157c0e83befb3d0d3226',
        64872,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '7c124e8d7c0f646ef5c41939fa83d867ebb573067321b70d07c8e95bdce5947d',
        64740,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '0054f5b0b7f8e4c4a1247596771bb449eaaec32641e6f09473c7dda7298e171c',
        64824,
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
        'e73a38f29556dbeee2af20850e4b5e08f881a397d52186e36e8a5d68cb252043',
        98128,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '7de12f42b336fce6abe424926d8e64c940b25ea8639a39fc39143b970cc506ea',
        98264,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '8c360c687241bd97933fe5d525a0e45408041b9f5ef5edbe5984f2bb7800975a',
        98228,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '97dcbdda1f932f3367875090ee5d041ba60f023c5465c977aad872499756ce0d',
        98144,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '2d28ca984db4ee29fe787cbc1809a5850511313cd87761fde5ecaf92c893999e',
        97960,
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
        'cb10a2b2fd12262b4cc477613596ada8beac64133a493ba6125ab5d17635a312',
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
        '801780d5def5239ba7fcd2e398eced436b9fe34dcf0a8e95ef2dbc5ec257fe30',
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
        '94e89c5446e772c9cd78c1cc662272e80360b75f863f38c9b6e27599bcc2bbcc',
        162696,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '3aa6787055531b48ec8dbf7ebe8a31ae15b5f9f36e5f23f45d123f84167d0982',
        163468,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'e8070999fdc9fced391bfd5c6f314427316d2df1f5d9317c7cbcf0ffe877dc29',
        163528,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '2f1f211fca1d28cabb59b4083a4c1aecd9f6eb13264ada1e04f3fddbb1fe68f6',
        161604,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '1e81709ffbda20b938802c595fc6b862685930fcbb165fe904f1dd0520ea7b9a',
        165672,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '310506b13b1abe971569e2190efa27a532fa6412f28c4fbb8db9534050747f73',
        166856,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '9c662731f849a25d052d6de710792cf69e213bffb61a42de18e1990a741b8759',
        166948,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '65b274fefbccdffbffc39eb73b8af10cd4449b21f6b8fd2d7b0c160096273728',
        165320,
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
        'ff5048298cf73a00572ecfd2b1b5a01f0c95316d6c9572a9a5d447acf64b5eba',
        50944,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '3a66df60d8b8e0a17998580926c00c9e76393f70bea4f1ece95fd971a331ec5a',
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
        '10d76856928ee3245d8c54871db74b5443bf21650a642d1ee82550402b207e73',
        33288,
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
        '8fdd7bd71e6e52da5bfb6d9a8b04ffe1528531c843c5daca4508f2b174871f9d',
        41064,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'ab9d09ef00f909a9151c7fd965cfee7f57ed31fcaed13596aaadeeac2b324b6c',
        40856,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'a5486e9d9450953453dd2a919b5f386a428e3a91d07ad48ca5bf7e3b9c481749',
        41724,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '4f5cd9eaa7092d57cf94be6082253d25aa924a5673fe0db988b10a36797156a0',
        41640,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '160447a7c46f78c2e5c2f77c92d1e3c2dd1bb55d6e5973c51a533342355a949d',
        41716,
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
        '737ca127bc1d4acf197e258b373c31f20148f17bffcc784b9028b25bf5883eac',
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
        'ad9ae03d8549de3f511f393127a1d1b6b22bdaccdb12ed14be14099ec839221b',
        157864,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w100,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '93e1999eddc7ab5b50ba4b350b1cebf75ee119f1bd62f74bfca9933d8f7a2e05',
        183040,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'b9f58caa28112f0c392f47e478df266027816bc8e05fa3f8a2153de7639f0742',
        157668,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'e420a773415c3d6eba38a52fa18270850a33df744c8c4b49996968f1e4b6807e',
        182180,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'bb36435e8f368d57e2807b02653757e2f39311982461de642a31966a6c3956fc',
        156144,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '4c6fcf2be5739f54cf2b72ce3257cf919694e3533a2059584ce08e376207be5d',
        180484,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '705290b12f58c6d70aafcaaf461dbc3d2f7f19d0f4362af1843b107d95d4960a',
        154584,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '9944daf2dac6d1c49aef7e4d0e4de71a79d4d65efabcb43945498db8ae119005',
        178076,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'a05eb17c43309b14b916303c48995b19407a7cdcf47bc6d8085d464722627918',
        152824,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '5dff9130f23647877185ba17e2fe31d83c889f9ac0505b0831a671256ec87ef4',
        176472,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'a24a61e9a408f85504dcdcd11edc4995adceb4ab585c0011f39cfbe193248b71',
        151480,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '00e34c6ab7c020708797444bf9ed8e085cd48805ba92df15a1524e1b52d920ec',
        174592,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '9ecfd020e9cc0b676025df8390c0dc8cc2062523540887dd04bec0ef4d5a449c',
        150252,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'db69b13e2e486582c4431f84cf547907b7fd4fa2858b1619777087bd96f65332',
        172684,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '87d223678cfaeac6f207cfd6f38e16a3dcaf6a1a04bd9d35be56321812672f43',
        149028,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '5a916637aaa600bd00e94027737e027dfc6b585767a752677acd96489750b23a',
        169940,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '58bae164452a59c75685191f42f83865d0a9eb41a72af48fa7ddcd15379e7c8d',
        147656,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'df356ffaef0d9c67439829eceeadd432df5a0d0a33cc42ef28f16092226fc84e',
        167640,
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
        '7e606b04dc6d3beefa63fb8574c5c94ca599a657613dbef25e9d4ffcc516b2ce',
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
        '5ffa3e00fe13d8c796425f086372e09ac506494bc8014cd46c8b979b469a3f36',
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
        '7176e723ac59341e96f8f7fac382d27c5cbc9cf031361c08544cb9f3f7f22407',
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
        '99d6391c41374dd216836cee0f835497bebddfe9f592c78e4b248c213821174b',
        208808,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '6be56c0a508027043913912e42c3f32ba498ed449bf54e8e5a5969d99ae8e421',
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
        '44421bffc579c56106cf41ebfad49c48cfb88fb84eac0106ab72c26f0d88cfcb',
        97556,
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
        'd929a0daa6abfe6f274a1403b5cc9444e9a186990036134b3477fcbdc46d64d2',
        60248,
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
        '534f5faa2ced868a712042f4c95f231b7c56a6bceafc6615d457a74f5a7f4f3d',
        51828,
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
        '5bdb75d17dcd2834ac7b42b5eae0c71b7a88c1091c84a5394b80d930e654900f',
        104492,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'aef01661b8a6cdb19ac36278a78ffaf6c67c28838b2599b5cc7f3848b3224ad5',
        106940,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '8c84bef1541933cb762ae3f4032a89f606fd34ebcf7e27eb61430a359e4c0c11',
        108224,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '7520c73525fd73f1670ace1aa87b801fc26861b95369402742fc49869a97aa48',
        105508,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '054fe054f8dcfa6e63ff29b33a7318bbc2ec682505c26b60e255be50773aaa41',
        102616,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '7dff18712926b6289fa42d217619727144fb279b0216926ae4afd9b170ce8989',
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
        'cb534d9dfc4a1db0f2035df13b1334824492f3e951f53ce6f47fce4dec43dc9e',
        28440,
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
        'a923972fc6a8f837b08ff28aa393ce8e25915480f9fde8697d9db4b2edcdb79e',
        90928,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w100,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '26544c427a79a6119bf94344e57763d9ee8ce3d6ea4aaaf8a84b629c50fad4f0',
        100536,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '8d3a1c0cd528f46d2d75523cdb9d6bad276dc53abf9b3fbd9644ad2012f6f54d',
        90896,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '2cae4dd896939dd04b4995679220aa164bb417edf97f79fa1e7478e50791dbb4',
        100552,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '8d962242d54764061a52e839d1ccde13c8620ef2b9a2bdc9d83580e67565b30c',
        90300,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '070ac0ef78a2a51821bfa8f5ea71bece4b888dc87d4fa5871db43b941f0aa802',
        99952,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'c80d481e346d71c2d400d1a7d76a30a38b08b0af0f84c8a3b21a249936da04df',
        90184,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'ef8175f765e6c09d08768c173382c9894b2597475633f1635d8e29dd3008fafc',
        98976,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'a044b49afd543a590faf28ae6d9a0dcc6b16599caea46881a430f9bcc99158eb',
        90152,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '936420f7119ac4fd8a32517f996411a5d932553b941a9b201f212247050eee55',
        98712,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '60b9ea916e82cfa321e507e359ad34d66325466f676f2519bd741d6b5ce4c1ea',
        88144,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'dfcd92f4dd89104220cbabccaf41678e59d3a80a52ccbd3ac2c52587ded7b510',
        98476,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '0bce6d5e10c9f6e26959195929cdbc293a347eb5f02b41233c5667c8788cfff7',
        89704,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '322d1b5cfb4160f6d8afc15e0dfe869ecece7a2878a4d47983ee3d8ee7b15931',
        98116,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '499673d9643ba4a3cc8d6197deec7d8581c6b3e1bb70316cf751f76faed9a44e',
        89248,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '877690c0ee29d9f70d35d529c58947286f05a4c1edd34c621799996a9b2f331f',
        97988,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '5d8a1dad60319b81217377cee15370d9fdae20a5a3358ba2aab442a8a688d88f',
        88988,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '626e81a57e26f28c8425e3b6303cdc58301f9feffb867fe8f705dad819aab5ee',
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
        'e0d4c5c46d7882d98840549b88ff8d86d6ee75b3fecce6b7a365f8ddbd76a01a',
        41952,
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
        '95425d8c31c56289224ea845c070a7fdb09e951a6c6af125e180241e825a3418',
        56000,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '711dae8d1ea4ca1d9425cfe75e761ec52a590a9665023f835b3c551b97003309',
        56164,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '54c6a3f69c8d66dd2a93c0515110bc18266f0aec80442fce8d0568cbed8bd47f',
        56164,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'f4a41453a5a6d8f1d1ffbb50a4ec8faa2e6102c46d52d8bbd8e3c91099d1c4c2',
        56128,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'c3703872195fd1bffc0f518ad1e2b46d6454110de8a9910196b8a553fdc627a2',
        56116,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '835eed35c373048de033d5b62eaba4dd1281975011c93bedf63423b8ad4790d1',
        56196,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '9f49bc2108813ec7bbff80901bd7e110ec7c632fb7bf9199164b517a29d6559e',
        56304,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '6d320adbe78c159a32ad46693279e1701dd413b4d7d4b3b3966216f2d33a2a84',
        56468,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'e56896212ac49011ef1bb74c107724277e94eea950d211636ef935287708d381',
        56408,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w100,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '5a10cfd6c83bf8ed9c425364181dbc6116926a6bb5fc61eea3db8c581e8b6ded',
        58248,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '0309a9a67a68c1471fceca43c8c787c89896ed9b5e8513e37111e92bef73275c',
        58464,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'd174f7374a0cbda5b027d51b0139507b2bbe3b0cfe391eaee912e1205f5eb584',
        58408,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '5b851ce56994eb1300246087fbd29288751e3f57b63f2ecc98324ad148dae0e1',
        58264,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'e1b726e96efc6374fa67e24303547577b8459d751da051167eb6e2637b58bcac',
        58376,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '9f65c1b1c63028c1c2c08c2f954f92cd2971b209beb83b7f5fced5d34d5ee2d4',
        58500,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'c037e259b9334354a38b0fb647ae093461a5a4368bb8e4b3a1ea25bb1d8dceb3',
        58636,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'fe6ba2144f9d290de0bfd9408549dc8c795d5639c4316ca4ea4bc4f531d02fd4',
        58844,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'fe693c18393e59401e8ff7947d545975d60650a9e3e85021a65e42a6bbb2e755',
        58804,
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
        'fe4beaaa9e56f94d986dfc08615189974bf8ecb9c21114796f3471b39bd4a294',
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
        '5cee34121e6f9605021e3451b4e9a301d0964bd717bb0c8ba82748a10cea8898',
        22596,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '6e6136370b0abeed8d4cb41b8ba67f8baa9009d78caf32c1c652f5c4d2c84495',
        23876,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'badf78148b7dcfdcc97d42b082880e74f5561d25dc69dd7c8a33a60252d018d3',
        22364,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '170e876845304805c7cce4dfe37478c67aa8a5a63f3d76fb66f766e348aac270',
        23760,
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
        'f15afa5d9a544514805bcac196e73bde7bf592775059393db8fba3964f2f9e8c',
        59652,
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
