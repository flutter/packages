// GENERATED CODE - DO NOT EDIT

// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../google_fonts_base.dart';
import '../google_fonts_descriptor.dart';
import '../google_fonts_variant.dart';

/// Methods for fonts starting with 'X'.
class PartX {
  /// Applies the Xanh Mono font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Xanh+Mono
  static TextStyle xanhMono({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'e93b1f1a41c9c6d924ab92f23c91764b6e6ade7b78e0e568115ff446644699b6',
        38916,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '94d5da2862ea346a4bb60d377d2593cda0fb55078716b137334b859485c91c34',
        41920,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'XanhMono',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Xanh Mono font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Xanh+Mono
  static TextTheme xanhMonoTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: xanhMono(textStyle: textTheme.displayLarge),
      displayMedium: xanhMono(textStyle: textTheme.displayMedium),
      displaySmall: xanhMono(textStyle: textTheme.displaySmall),
      headlineLarge: xanhMono(textStyle: textTheme.headlineLarge),
      headlineMedium: xanhMono(textStyle: textTheme.headlineMedium),
      headlineSmall: xanhMono(textStyle: textTheme.headlineSmall),
      titleLarge: xanhMono(textStyle: textTheme.titleLarge),
      titleMedium: xanhMono(textStyle: textTheme.titleMedium),
      titleSmall: xanhMono(textStyle: textTheme.titleSmall),
      bodyLarge: xanhMono(textStyle: textTheme.bodyLarge),
      bodyMedium: xanhMono(textStyle: textTheme.bodyMedium),
      bodySmall: xanhMono(textStyle: textTheme.bodySmall),
      labelLarge: xanhMono(textStyle: textTheme.labelLarge),
      labelMedium: xanhMono(textStyle: textTheme.labelMedium),
      labelSmall: xanhMono(textStyle: textTheme.labelSmall),
    );
  }
}
