// GENERATED CODE - DO NOT EDIT

// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../google_fonts_base.dart';
import '../google_fonts_descriptor.dart';
import '../google_fonts_variant.dart';

/// Methods for fonts starting with 'I'.
class PartI {
  /// Applies the IBM Plex Mono font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/IBM+Plex+Mono
  static TextStyle ibmPlexMono({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
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
        '28b47d79415935b4eb7e21b4ab6567b49ec8c5654769456ec98e2193e8998fdd',
        77016,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w100,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '29dc9c11fa19d718d763725de56a911b985eec34ff0ce19cbdfbe81438f1f5f4',
        83652,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '777e2bfad74ee25085099fe319dec1ab75fa07afe1fd95511691a7d785e5e76a',
        76620,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'dec2d3b718edf9c988b7bc4bf9cc2ff98c0a73b3704321db9bd77c8c10da9f57',
        83624,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'fb12a959f0a3b900dfb41e969e19ea06d7fd0e546d20848c74d7c0a09bb9fcc5',
        76372,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'fcb360ec811b8ad1bcbcaa48f01ac3b20321699d2c2a44ac2061d61f1856356f',
        83248,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'd37b0be393abb9e88603a9493e97d0ca660146b93fad3897d22358f3a93e7a05',
        76988,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '129654d831d41d7c91e3068d3a41048ac376d3268e6fa37d70a32655f80b28df',
        84068,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'ccde6e24d2f07f518ab9860bb438d768dade104dd9f4a5e8c7442885ff4bad81',
        76544,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '7c4d06a8e36553d03d27fce5ed3e3190fffb6f1809b94cafcb51831e43550b5c',
        83312,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'f22d51089f8e130bf17474587afa91909c802be2733c8f6e79f33eb7318b2d77',
        76516,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'c53a0ff962598476827ac59e2871f2edc365bbf0bf021477f6adea969df952b6',
        82964,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '655d8d7800662579d0ec6d4b4cfdffd1f647a5f24575f42d4bb0b295f0dd8779',
        76560,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'dc02aef1a17967582c7dc41541adcfa296295b0b2419a6a94e018112c560a30a',
        83348,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'IBMPlexMono',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the IBM Plex Mono font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/IBM+Plex+Mono
  static TextTheme ibmPlexMonoTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: ibmPlexMono(textStyle: textTheme.displayLarge),
      displayMedium: ibmPlexMono(textStyle: textTheme.displayMedium),
      displaySmall: ibmPlexMono(textStyle: textTheme.displaySmall),
      headlineLarge: ibmPlexMono(textStyle: textTheme.headlineLarge),
      headlineMedium: ibmPlexMono(textStyle: textTheme.headlineMedium),
      headlineSmall: ibmPlexMono(textStyle: textTheme.headlineSmall),
      titleLarge: ibmPlexMono(textStyle: textTheme.titleLarge),
      titleMedium: ibmPlexMono(textStyle: textTheme.titleMedium),
      titleSmall: ibmPlexMono(textStyle: textTheme.titleSmall),
      bodyLarge: ibmPlexMono(textStyle: textTheme.bodyLarge),
      bodyMedium: ibmPlexMono(textStyle: textTheme.bodyMedium),
      bodySmall: ibmPlexMono(textStyle: textTheme.bodySmall),
      labelLarge: ibmPlexMono(textStyle: textTheme.labelLarge),
      labelMedium: ibmPlexMono(textStyle: textTheme.labelMedium),
      labelSmall: ibmPlexMono(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the IBM Plex Sans font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/IBM+Plex+Sans
  static TextStyle ibmPlexSans({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
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
        '07b15b8cae648cc63e48778860d98ed956c10f6557c8cdbe8fb5ab1c2f80e5c4',
        183544,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '33603895dbda8df0109110667c86ea605ecc2365ed63c45f0edd9fe4f087e5bc',
        183776,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '4406bd542f87f6b8a4bf1e52c1436211324a8c461ae78052cecfda41e393306e',
        183664,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '12e6996253206716d0cd23a5d26cec773a78f7a3a0df93f832e0b3754c1e39b2',
        183172,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '45ab33487e9f920313400178cb0bd4540eddadc23a294ad3fe47a0d5e41ff644',
        183204,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '7778c3dcd29c41c4da33221bac3951b0f0882b94ba55cecc17a1a42bb047060a',
        183212,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'aa5026e2a6226c14976279a67ebbbf0d78caba2fa3fe242e42d83fc6010b28a8',
        183148,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w100,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'bff5ab424d2fba588b7f93a42c529301affa6ecf888ed1c56c22dda3f5b9e142',
        198752,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '1ac25d5b78c92acf767a1d973313a2f0e19d82247e5866d41abac5d90e510a81',
        198836,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '44df52b9a0b72eb035bea9461a5b54741e2b3dbf5372a11ab082067b2b07020f',
        198720,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '9eab3cf3d7efaf9ae0e734a905cea8c978e9352e6223f212ab15df1fb8c73239',
        198148,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '005b9ac7334e6b59b4ad788c696e50f4f29e134d3c12c323fd928f56e4f720b2',
        198308,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'ef07254ab181bb8aa149bf545a8f5197f1ae37f0bc9962c2a6a2292a2393ef38',
        198328,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'e0386b71c72ad4e0eb8d117e19ef5b45857b367d26ba5ccd22c064fddc08f249',
        198152,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '4e1ed2792a1ad23e7d882b25232385397e8452e49d6e7e0b2918af866c8fa630',
        486372,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'afe90dba9b98194ee0ebebe94e85266fcdbc1d82a58af109db1fc2843be385cd',
        548048,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'IBMPlexSans',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the IBM Plex Sans font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/IBM+Plex+Sans
  static TextTheme ibmPlexSansTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: ibmPlexSans(textStyle: textTheme.displayLarge),
      displayMedium: ibmPlexSans(textStyle: textTheme.displayMedium),
      displaySmall: ibmPlexSans(textStyle: textTheme.displaySmall),
      headlineLarge: ibmPlexSans(textStyle: textTheme.headlineLarge),
      headlineMedium: ibmPlexSans(textStyle: textTheme.headlineMedium),
      headlineSmall: ibmPlexSans(textStyle: textTheme.headlineSmall),
      titleLarge: ibmPlexSans(textStyle: textTheme.titleLarge),
      titleMedium: ibmPlexSans(textStyle: textTheme.titleMedium),
      titleSmall: ibmPlexSans(textStyle: textTheme.titleSmall),
      bodyLarge: ibmPlexSans(textStyle: textTheme.bodyLarge),
      bodyMedium: ibmPlexSans(textStyle: textTheme.bodyMedium),
      bodySmall: ibmPlexSans(textStyle: textTheme.bodySmall),
      labelLarge: ibmPlexSans(textStyle: textTheme.labelLarge),
      labelMedium: ibmPlexSans(textStyle: textTheme.labelMedium),
      labelSmall: ibmPlexSans(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the IBM Plex Sans Arabic font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/IBM+Plex+Sans+Arabic
  static TextStyle ibmPlexSansArabic({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
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
        '3e37b91e94bc50eaa90a97067251c3ed1a0f6f3330c2f8c0325d0bd78f2fc472',
        160564,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '5118fbc3904b3db03d3c8dcd6fb0dbd0972b897a10906a540c8f1ecc5bd7ca63',
        161740,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '0712bcecba66b2dd8d9affb6ca2a12d0d62c8f7d96776030a03c4f000027b655',
        161740,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '1dd5b8658755ac24816510d55a5fb695a1afb4501670975bf25b280c26374402',
        159912,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '562c4db5603ce976913e221339e8fcc9627254bf8c818bb88a9ed1a7aa03c5a0',
        164208,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '8c07e6cd6d0f3e35d2679c155d3c259e7bddfee21549f01a0b09d35b4d7a39c6',
        164284,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '7147bc82b252b7ab0e19d656da55d46cace739e45096c9d9d4fe23616216e77b',
        163188,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'IBMPlexSansArabic',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the IBM Plex Sans Arabic font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/IBM+Plex+Sans+Arabic
  static TextTheme ibmPlexSansArabicTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: ibmPlexSansArabic(textStyle: textTheme.displayLarge),
      displayMedium: ibmPlexSansArabic(textStyle: textTheme.displayMedium),
      displaySmall: ibmPlexSansArabic(textStyle: textTheme.displaySmall),
      headlineLarge: ibmPlexSansArabic(textStyle: textTheme.headlineLarge),
      headlineMedium: ibmPlexSansArabic(textStyle: textTheme.headlineMedium),
      headlineSmall: ibmPlexSansArabic(textStyle: textTheme.headlineSmall),
      titleLarge: ibmPlexSansArabic(textStyle: textTheme.titleLarge),
      titleMedium: ibmPlexSansArabic(textStyle: textTheme.titleMedium),
      titleSmall: ibmPlexSansArabic(textStyle: textTheme.titleSmall),
      bodyLarge: ibmPlexSansArabic(textStyle: textTheme.bodyLarge),
      bodyMedium: ibmPlexSansArabic(textStyle: textTheme.bodyMedium),
      bodySmall: ibmPlexSansArabic(textStyle: textTheme.bodySmall),
      labelLarge: ibmPlexSansArabic(textStyle: textTheme.labelLarge),
      labelMedium: ibmPlexSansArabic(textStyle: textTheme.labelMedium),
      labelSmall: ibmPlexSansArabic(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the IBM Plex Sans Devanagari font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/IBM+Plex+Sans+Devanagari
  static TextStyle ibmPlexSansDevanagari({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
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
        '26222a55c7b54eac8ac00c38d24e96a071fab7e14541604e9b5e33ff787e193a',
        227304,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'bbf44e48e794bdeebcfb861d82fd798db6f565051bb5cdb93533c8cb5da50c5b',
        226388,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'a9ef7da21ecc648fa076838dddba8c12c3768611a77e002f8efe8bbb2f96c6e6',
        224040,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'cd96a2c6e113335c648e1ca5430523a1a6596ad2083defa614bd3c8e6306b406',
        216932,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '7a11e01c2c0f31dc05cc65b4d8c2ccbd45df4f6ff1016d3bd74be4f4dcf4d4c5',
        216368,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '9a88a15fd208a69c9ddff139b7219462c90a687150256c39585bca093a206b2c',
        215880,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '3324e230bdaeb5f3f1aca8c9285c08a2dc50a242c95aaf893c54ee49f3d8f136',
        207516,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'IBMPlexSansDevanagari',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the IBM Plex Sans Devanagari font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/IBM+Plex+Sans+Devanagari
  static TextTheme ibmPlexSansDevanagariTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: ibmPlexSansDevanagari(textStyle: textTheme.displayLarge),
      displayMedium: ibmPlexSansDevanagari(textStyle: textTheme.displayMedium),
      displaySmall: ibmPlexSansDevanagari(textStyle: textTheme.displaySmall),
      headlineLarge: ibmPlexSansDevanagari(textStyle: textTheme.headlineLarge),
      headlineMedium: ibmPlexSansDevanagari(
        textStyle: textTheme.headlineMedium,
      ),
      headlineSmall: ibmPlexSansDevanagari(textStyle: textTheme.headlineSmall),
      titleLarge: ibmPlexSansDevanagari(textStyle: textTheme.titleLarge),
      titleMedium: ibmPlexSansDevanagari(textStyle: textTheme.titleMedium),
      titleSmall: ibmPlexSansDevanagari(textStyle: textTheme.titleSmall),
      bodyLarge: ibmPlexSansDevanagari(textStyle: textTheme.bodyLarge),
      bodyMedium: ibmPlexSansDevanagari(textStyle: textTheme.bodyMedium),
      bodySmall: ibmPlexSansDevanagari(textStyle: textTheme.bodySmall),
      labelLarge: ibmPlexSansDevanagari(textStyle: textTheme.labelLarge),
      labelMedium: ibmPlexSansDevanagari(textStyle: textTheme.labelMedium),
      labelSmall: ibmPlexSansDevanagari(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the IBM Plex Sans Hebrew font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/IBM+Plex+Sans+Hebrew
  static TextStyle ibmPlexSansHebrew({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
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
        '30122c6b872720d71fb51f29348770366c2f7f8b6496a968001ce05b78e94183',
        59468,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'e4cc99f13a204792a9f798157261ca14fbdc712ecfc7562a7568382519462e80',
        59856,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '4828f83e175919f5091ea5b1dd24c8f95af671c472e78b40e2eed1de7347eb00',
        59568,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '87e21e7a79edfd25bc9d0e67485b6fb6feb82e1a01e5654898b4825a07bcc914',
        58472,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '0362e334f6824d2e9e305203cd83f64672618eec48bd646e2c483dc16ff1227a',
        59172,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'e9ae6f4f770e9d1bd3709f54ad07a39428d05a046cc096975e26e7f3ca118c5e',
        59032,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'c6a79c82f40d4b5954ed9f6cf885a337dede77b13ea3900bdf74be52b75ec262',
        58976,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'IBMPlexSansHebrew',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the IBM Plex Sans Hebrew font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/IBM+Plex+Sans+Hebrew
  static TextTheme ibmPlexSansHebrewTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: ibmPlexSansHebrew(textStyle: textTheme.displayLarge),
      displayMedium: ibmPlexSansHebrew(textStyle: textTheme.displayMedium),
      displaySmall: ibmPlexSansHebrew(textStyle: textTheme.displaySmall),
      headlineLarge: ibmPlexSansHebrew(textStyle: textTheme.headlineLarge),
      headlineMedium: ibmPlexSansHebrew(textStyle: textTheme.headlineMedium),
      headlineSmall: ibmPlexSansHebrew(textStyle: textTheme.headlineSmall),
      titleLarge: ibmPlexSansHebrew(textStyle: textTheme.titleLarge),
      titleMedium: ibmPlexSansHebrew(textStyle: textTheme.titleMedium),
      titleSmall: ibmPlexSansHebrew(textStyle: textTheme.titleSmall),
      bodyLarge: ibmPlexSansHebrew(textStyle: textTheme.bodyLarge),
      bodyMedium: ibmPlexSansHebrew(textStyle: textTheme.bodyMedium),
      bodySmall: ibmPlexSansHebrew(textStyle: textTheme.bodySmall),
      labelLarge: ibmPlexSansHebrew(textStyle: textTheme.labelLarge),
      labelMedium: ibmPlexSansHebrew(textStyle: textTheme.labelMedium),
      labelSmall: ibmPlexSansHebrew(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the IBM Plex Sans JP font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/IBM+Plex+Sans+JP
  static TextStyle ibmPlexSansJp({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
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
        'b17d085a512d6e04ed9b6687370942990443789c8d8d22e41cde833a316a1297',
        2189584,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'a5e09934848baaa404b8fc49e0019a8701f85aaa14eec67958a68d847ac36e72',
        2184640,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '9b81e7708451883ee7ad20cef0c0585425ea5e2b7f70a13fb892ec157dc9b8fa',
        2177748,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '5b3457392bed0cf794d7b80b7118b33d6d27f79da8229cf5af99a0647e3e20b7',
        2168884,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'f1b2643286719ebc0d49fe9764b227eb0664df246a1da217b0ecbd30748c6b3c',
        2162464,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'ee2f238ef09c88c53402be8702809829ff3c8fac1f159fc2bdecc9268b7c2806',
        2161988,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '53efa9a8071ef41198f33c6d5bfa64037ef091ec386db6a078ae6c5b73537b99',
        2163876,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'IBMPlexSansJP',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the IBM Plex Sans JP font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/IBM+Plex+Sans+JP
  static TextTheme ibmPlexSansJpTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: ibmPlexSansJp(textStyle: textTheme.displayLarge),
      displayMedium: ibmPlexSansJp(textStyle: textTheme.displayMedium),
      displaySmall: ibmPlexSansJp(textStyle: textTheme.displaySmall),
      headlineLarge: ibmPlexSansJp(textStyle: textTheme.headlineLarge),
      headlineMedium: ibmPlexSansJp(textStyle: textTheme.headlineMedium),
      headlineSmall: ibmPlexSansJp(textStyle: textTheme.headlineSmall),
      titleLarge: ibmPlexSansJp(textStyle: textTheme.titleLarge),
      titleMedium: ibmPlexSansJp(textStyle: textTheme.titleMedium),
      titleSmall: ibmPlexSansJp(textStyle: textTheme.titleSmall),
      bodyLarge: ibmPlexSansJp(textStyle: textTheme.bodyLarge),
      bodyMedium: ibmPlexSansJp(textStyle: textTheme.bodyMedium),
      bodySmall: ibmPlexSansJp(textStyle: textTheme.bodySmall),
      labelLarge: ibmPlexSansJp(textStyle: textTheme.labelLarge),
      labelMedium: ibmPlexSansJp(textStyle: textTheme.labelMedium),
      labelSmall: ibmPlexSansJp(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the IBM Plex Sans KR font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/IBM+Plex+Sans+KR
  static TextStyle ibmPlexSansKr({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
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
        'ef3327df28bb5ee46c14c7504ecfa8ef33690f8416bc5db691e7c0a369729e1c',
        2508648,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '8c2c1d397ff887a625237a52846d79ab559db693a6cd6e7e45d827533522ec40',
        2466112,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '982adf4e620d09aa395ba00adf471151216f73858fa703758d74a57e717d76c7',
        2443504,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '62934a5c2c8c3885a168db3fb82e11958dc90a6b54d2a337a19ec6a9a1e9c02a',
        2430632,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'f3025e6ce7610a97034fd9409aa923e5996f02caee2740097777f05d222738cc',
        2414528,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '6a1334096562f30411c060d6d7088003d47dcd767b6e74ff38877e489d3a455f',
        2406700,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'ce05da3cfe2e05a2880f55ba16a02ab98c0f779c5bf26b21651711474d1e74a2',
        2402612,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'IBMPlexSansKR',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the IBM Plex Sans KR font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/IBM+Plex+Sans+KR
  static TextTheme ibmPlexSansKrTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: ibmPlexSansKr(textStyle: textTheme.displayLarge),
      displayMedium: ibmPlexSansKr(textStyle: textTheme.displayMedium),
      displaySmall: ibmPlexSansKr(textStyle: textTheme.displaySmall),
      headlineLarge: ibmPlexSansKr(textStyle: textTheme.headlineLarge),
      headlineMedium: ibmPlexSansKr(textStyle: textTheme.headlineMedium),
      headlineSmall: ibmPlexSansKr(textStyle: textTheme.headlineSmall),
      titleLarge: ibmPlexSansKr(textStyle: textTheme.titleLarge),
      titleMedium: ibmPlexSansKr(textStyle: textTheme.titleMedium),
      titleSmall: ibmPlexSansKr(textStyle: textTheme.titleSmall),
      bodyLarge: ibmPlexSansKr(textStyle: textTheme.bodyLarge),
      bodyMedium: ibmPlexSansKr(textStyle: textTheme.bodyMedium),
      bodySmall: ibmPlexSansKr(textStyle: textTheme.bodySmall),
      labelLarge: ibmPlexSansKr(textStyle: textTheme.labelLarge),
      labelMedium: ibmPlexSansKr(textStyle: textTheme.labelMedium),
      labelSmall: ibmPlexSansKr(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the IBM Plex Sans Thai font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/IBM+Plex+Sans+Thai
  static TextStyle ibmPlexSansThai({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
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
        '8b2456a4769be63a1b5eff85a7cd768add99d5290434ea9cd5161409d70356d7',
        67408,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '565023bdfb445ee80222544aa1e381b49fc804e71b104837a77d4c653eeec4f8',
        67492,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'a9f367ffb205bffe3ae7ce91f6dff5aa5778f585416f586b664bf7cbafb08885',
        67216,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '22238e186615af34f67cff11e61e95da68362e18dc0e1d99f028486614aa7c64',
        66592,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '02fd9c13c1e5542ad1817f4775b4b91dc289bfd1140d3172105c2938c968e085',
        66736,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'd6ce03777efde74303c7a41c3e3b59102290f45ab277d5108213f2338e634db6',
        66628,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '494e80ca0d93bcfce180e8624d845d48cf280aceb16026c4e6881439f41b3e1e',
        66684,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'IBMPlexSansThai',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the IBM Plex Sans Thai font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/IBM+Plex+Sans+Thai
  static TextTheme ibmPlexSansThaiTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: ibmPlexSansThai(textStyle: textTheme.displayLarge),
      displayMedium: ibmPlexSansThai(textStyle: textTheme.displayMedium),
      displaySmall: ibmPlexSansThai(textStyle: textTheme.displaySmall),
      headlineLarge: ibmPlexSansThai(textStyle: textTheme.headlineLarge),
      headlineMedium: ibmPlexSansThai(textStyle: textTheme.headlineMedium),
      headlineSmall: ibmPlexSansThai(textStyle: textTheme.headlineSmall),
      titleLarge: ibmPlexSansThai(textStyle: textTheme.titleLarge),
      titleMedium: ibmPlexSansThai(textStyle: textTheme.titleMedium),
      titleSmall: ibmPlexSansThai(textStyle: textTheme.titleSmall),
      bodyLarge: ibmPlexSansThai(textStyle: textTheme.bodyLarge),
      bodyMedium: ibmPlexSansThai(textStyle: textTheme.bodyMedium),
      bodySmall: ibmPlexSansThai(textStyle: textTheme.bodySmall),
      labelLarge: ibmPlexSansThai(textStyle: textTheme.labelLarge),
      labelMedium: ibmPlexSansThai(textStyle: textTheme.labelMedium),
      labelSmall: ibmPlexSansThai(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the IBM Plex Sans Thai Looped font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/IBM+Plex+Sans+Thai+Looped
  static TextStyle ibmPlexSansThaiLooped({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
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
        'eab0601f2caf87105bc0f5418754f8c2e60a8b3459cb424ebe5c596fe3ca2e48',
        74032,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '9143ac0f70df21bc369b07cba49b1b164309aa283ee40b8d6a07bcc6a8a8ce1b',
        74012,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '34fda694e49fe88f8a5f9698139bbdf75c08992b3d178dad9576345ca05dd393',
        73480,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '38ff63b8eb381edbe5c8e85a1e58241150fb82cc286c8dfdb67a4d5c0ac89a03',
        72772,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '35794e4b699a2ae1b5c7f64f9e17ca2c4b08bb9c948841b4b948a4511b2db4d5',
        72656,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '311eca0075cd9e4df58d19f2e54b4e4564324504f80378feddea98335f7df2b6',
        72416,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '6fef444cc03938e55d94789d352a57acf9d26aaf46d4b9b0aec3922e2140b19f',
        72352,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'IBMPlexSansThaiLooped',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the IBM Plex Sans Thai Looped font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/IBM+Plex+Sans+Thai+Looped
  static TextTheme ibmPlexSansThaiLoopedTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: ibmPlexSansThaiLooped(textStyle: textTheme.displayLarge),
      displayMedium: ibmPlexSansThaiLooped(textStyle: textTheme.displayMedium),
      displaySmall: ibmPlexSansThaiLooped(textStyle: textTheme.displaySmall),
      headlineLarge: ibmPlexSansThaiLooped(textStyle: textTheme.headlineLarge),
      headlineMedium: ibmPlexSansThaiLooped(
        textStyle: textTheme.headlineMedium,
      ),
      headlineSmall: ibmPlexSansThaiLooped(textStyle: textTheme.headlineSmall),
      titleLarge: ibmPlexSansThaiLooped(textStyle: textTheme.titleLarge),
      titleMedium: ibmPlexSansThaiLooped(textStyle: textTheme.titleMedium),
      titleSmall: ibmPlexSansThaiLooped(textStyle: textTheme.titleSmall),
      bodyLarge: ibmPlexSansThaiLooped(textStyle: textTheme.bodyLarge),
      bodyMedium: ibmPlexSansThaiLooped(textStyle: textTheme.bodyMedium),
      bodySmall: ibmPlexSansThaiLooped(textStyle: textTheme.bodySmall),
      labelLarge: ibmPlexSansThaiLooped(textStyle: textTheme.labelLarge),
      labelMedium: ibmPlexSansThaiLooped(textStyle: textTheme.labelMedium),
      labelSmall: ibmPlexSansThaiLooped(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the IBM Plex Serif font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/IBM+Plex+Serif
  static TextStyle ibmPlexSerif({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
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
        '248e9035e1a0db5130f0786217c4b1acc2b4a541e9a2e407cac4f845efb3c5f4',
        106116,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w100,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'e50dee63d411e13edb89c6c1e999434a14ee50a3048fc21cd3293e84f427d40e',
        115664,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'b47641aa70f00ffb63b6fd7cb92a98ebe25db8e1e8db5d0f7168eb63c3eff89b',
        108800,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '6bff065a5f4a402b6830f1ba5e11f59cd8ed8feb453a4a59fd9e4f2c153e3529',
        119692,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '295e45ac55603ae0d5a8a34644b1f71e767c7f086d61c1a9edb632d3af3f12ea',
        108764,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '089c077ef33bcbdde66514513cabcc5b958ae56376b658115bbd83f57e33ac88',
        119388,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'd0dda69d56db0ec73d8d03f3930be13b4968727196cddf5b8ec43c39be19794c',
        108524,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '572060fcbaff9f13f3d8f73f82bd27654697cd58f987ac4773fa61b19000c05d',
        119452,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'e1451fea7730c65b2e013f95af33d292f8e730d5e7d5f9ebb9722f1dd927be7a',
        109216,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '5efda0096d5bc0993adcda33e1381c34e4e5cb72c5ddd02cf56cd950b9c19636',
        119388,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '92909831461cb5d57564fb95050f6e21c5913e1ca47b420b390d5d4f69f28bfa',
        109120,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '39d5bcc5f3ed22fa65bd00e10d56745e806505144dcadb0d6761dc688831325f',
        119496,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '683da1e76d8705d9390db5ca35b26a0eeee3e5628169c0352fe7333c08239234',
        107704,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'dcc61b858f184d8ee3aba8cda03c193ea5e22f8e04a9b771c013466fb73e505c',
        118364,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'IBMPlexSerif',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the IBM Plex Serif font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/IBM+Plex+Serif
  static TextTheme ibmPlexSerifTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: ibmPlexSerif(textStyle: textTheme.displayLarge),
      displayMedium: ibmPlexSerif(textStyle: textTheme.displayMedium),
      displaySmall: ibmPlexSerif(textStyle: textTheme.displaySmall),
      headlineLarge: ibmPlexSerif(textStyle: textTheme.headlineLarge),
      headlineMedium: ibmPlexSerif(textStyle: textTheme.headlineMedium),
      headlineSmall: ibmPlexSerif(textStyle: textTheme.headlineSmall),
      titleLarge: ibmPlexSerif(textStyle: textTheme.titleLarge),
      titleMedium: ibmPlexSerif(textStyle: textTheme.titleMedium),
      titleSmall: ibmPlexSerif(textStyle: textTheme.titleSmall),
      bodyLarge: ibmPlexSerif(textStyle: textTheme.bodyLarge),
      bodyMedium: ibmPlexSerif(textStyle: textTheme.bodyMedium),
      bodySmall: ibmPlexSerif(textStyle: textTheme.bodySmall),
      labelLarge: ibmPlexSerif(textStyle: textTheme.labelLarge),
      labelMedium: ibmPlexSerif(textStyle: textTheme.labelMedium),
      labelSmall: ibmPlexSerif(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the IM Fell DW Pica font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/IM+Fell+DW+Pica
  static TextStyle imFellDwPica({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '9459af8e5add9e53e1987687ba7b01d4ff12a705be7880f7b82ebe2690a496ed',
        211184,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'ec84e5dd06394d3d71cbb9f538eba396d80e6b852e947e21ecbf22ad16b9bd22',
        238596,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'IMFellDWPica',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the IM Fell DW Pica font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/IM+Fell+DW+Pica
  static TextTheme imFellDwPicaTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: imFellDwPica(textStyle: textTheme.displayLarge),
      displayMedium: imFellDwPica(textStyle: textTheme.displayMedium),
      displaySmall: imFellDwPica(textStyle: textTheme.displaySmall),
      headlineLarge: imFellDwPica(textStyle: textTheme.headlineLarge),
      headlineMedium: imFellDwPica(textStyle: textTheme.headlineMedium),
      headlineSmall: imFellDwPica(textStyle: textTheme.headlineSmall),
      titleLarge: imFellDwPica(textStyle: textTheme.titleLarge),
      titleMedium: imFellDwPica(textStyle: textTheme.titleMedium),
      titleSmall: imFellDwPica(textStyle: textTheme.titleSmall),
      bodyLarge: imFellDwPica(textStyle: textTheme.bodyLarge),
      bodyMedium: imFellDwPica(textStyle: textTheme.bodyMedium),
      bodySmall: imFellDwPica(textStyle: textTheme.bodySmall),
      labelLarge: imFellDwPica(textStyle: textTheme.labelLarge),
      labelMedium: imFellDwPica(textStyle: textTheme.labelMedium),
      labelSmall: imFellDwPica(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the IM Fell DW Pica SC font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/IM+Fell+DW+Pica+SC
  static TextStyle imFellDwPicaSc({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'b42029cd8d085bda39149c65bee3c543027c09b57d91fff0f599214f8ac736da',
        192592,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'IMFellDWPicaSC',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the IM Fell DW Pica SC font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/IM+Fell+DW+Pica+SC
  static TextTheme imFellDwPicaScTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: imFellDwPicaSc(textStyle: textTheme.displayLarge),
      displayMedium: imFellDwPicaSc(textStyle: textTheme.displayMedium),
      displaySmall: imFellDwPicaSc(textStyle: textTheme.displaySmall),
      headlineLarge: imFellDwPicaSc(textStyle: textTheme.headlineLarge),
      headlineMedium: imFellDwPicaSc(textStyle: textTheme.headlineMedium),
      headlineSmall: imFellDwPicaSc(textStyle: textTheme.headlineSmall),
      titleLarge: imFellDwPicaSc(textStyle: textTheme.titleLarge),
      titleMedium: imFellDwPicaSc(textStyle: textTheme.titleMedium),
      titleSmall: imFellDwPicaSc(textStyle: textTheme.titleSmall),
      bodyLarge: imFellDwPicaSc(textStyle: textTheme.bodyLarge),
      bodyMedium: imFellDwPicaSc(textStyle: textTheme.bodyMedium),
      bodySmall: imFellDwPicaSc(textStyle: textTheme.bodySmall),
      labelLarge: imFellDwPicaSc(textStyle: textTheme.labelLarge),
      labelMedium: imFellDwPicaSc(textStyle: textTheme.labelMedium),
      labelSmall: imFellDwPicaSc(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the IM Fell Double Pica font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/IM+Fell+Double+Pica
  static TextStyle imFellDoublePica({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '24def9ccd9a7f48cae0a5c65904e793384586acd5ca5626d6df5445f95464761',
        205192,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '8b51629cdc58e927d88b04f67541e2a217d9938695be6446346a3bda587169c7',
        249120,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'IMFellDoublePica',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the IM Fell Double Pica font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/IM+Fell+Double+Pica
  static TextTheme imFellDoublePicaTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: imFellDoublePica(textStyle: textTheme.displayLarge),
      displayMedium: imFellDoublePica(textStyle: textTheme.displayMedium),
      displaySmall: imFellDoublePica(textStyle: textTheme.displaySmall),
      headlineLarge: imFellDoublePica(textStyle: textTheme.headlineLarge),
      headlineMedium: imFellDoublePica(textStyle: textTheme.headlineMedium),
      headlineSmall: imFellDoublePica(textStyle: textTheme.headlineSmall),
      titleLarge: imFellDoublePica(textStyle: textTheme.titleLarge),
      titleMedium: imFellDoublePica(textStyle: textTheme.titleMedium),
      titleSmall: imFellDoublePica(textStyle: textTheme.titleSmall),
      bodyLarge: imFellDoublePica(textStyle: textTheme.bodyLarge),
      bodyMedium: imFellDoublePica(textStyle: textTheme.bodyMedium),
      bodySmall: imFellDoublePica(textStyle: textTheme.bodySmall),
      labelLarge: imFellDoublePica(textStyle: textTheme.labelLarge),
      labelMedium: imFellDoublePica(textStyle: textTheme.labelMedium),
      labelSmall: imFellDoublePica(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the IM Fell Double Pica SC font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/IM+Fell+Double+Pica+SC
  static TextStyle imFellDoublePicaSc({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '32f5223943f05df18b728db045334bd10f22c3e732251ee4add3e535c480870e',
        191624,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'IMFellDoublePicaSC',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the IM Fell Double Pica SC font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/IM+Fell+Double+Pica+SC
  static TextTheme imFellDoublePicaScTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: imFellDoublePicaSc(textStyle: textTheme.displayLarge),
      displayMedium: imFellDoublePicaSc(textStyle: textTheme.displayMedium),
      displaySmall: imFellDoublePicaSc(textStyle: textTheme.displaySmall),
      headlineLarge: imFellDoublePicaSc(textStyle: textTheme.headlineLarge),
      headlineMedium: imFellDoublePicaSc(textStyle: textTheme.headlineMedium),
      headlineSmall: imFellDoublePicaSc(textStyle: textTheme.headlineSmall),
      titleLarge: imFellDoublePicaSc(textStyle: textTheme.titleLarge),
      titleMedium: imFellDoublePicaSc(textStyle: textTheme.titleMedium),
      titleSmall: imFellDoublePicaSc(textStyle: textTheme.titleSmall),
      bodyLarge: imFellDoublePicaSc(textStyle: textTheme.bodyLarge),
      bodyMedium: imFellDoublePicaSc(textStyle: textTheme.bodyMedium),
      bodySmall: imFellDoublePicaSc(textStyle: textTheme.bodySmall),
      labelLarge: imFellDoublePicaSc(textStyle: textTheme.labelLarge),
      labelMedium: imFellDoublePicaSc(textStyle: textTheme.labelMedium),
      labelSmall: imFellDoublePicaSc(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the IM Fell English font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/IM+Fell+English
  static TextStyle imFellEnglish({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'b6f6962a9871041173c353a1465bf991162134e91a8ebc1c0f73295766176932',
        189680,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'a88c22cd52b1985e7d3a77ad3683feccc9dd2a8cdf2935bedb3fce32b333c779',
        197028,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'IMFellEnglish',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the IM Fell English font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/IM+Fell+English
  static TextTheme imFellEnglishTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: imFellEnglish(textStyle: textTheme.displayLarge),
      displayMedium: imFellEnglish(textStyle: textTheme.displayMedium),
      displaySmall: imFellEnglish(textStyle: textTheme.displaySmall),
      headlineLarge: imFellEnglish(textStyle: textTheme.headlineLarge),
      headlineMedium: imFellEnglish(textStyle: textTheme.headlineMedium),
      headlineSmall: imFellEnglish(textStyle: textTheme.headlineSmall),
      titleLarge: imFellEnglish(textStyle: textTheme.titleLarge),
      titleMedium: imFellEnglish(textStyle: textTheme.titleMedium),
      titleSmall: imFellEnglish(textStyle: textTheme.titleSmall),
      bodyLarge: imFellEnglish(textStyle: textTheme.bodyLarge),
      bodyMedium: imFellEnglish(textStyle: textTheme.bodyMedium),
      bodySmall: imFellEnglish(textStyle: textTheme.bodySmall),
      labelLarge: imFellEnglish(textStyle: textTheme.labelLarge),
      labelMedium: imFellEnglish(textStyle: textTheme.labelMedium),
      labelSmall: imFellEnglish(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the IM Fell English SC font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/IM+Fell+English+SC
  static TextStyle imFellEnglishSc({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '895adc2b5463f96c9d617d63ed7cb703b00efa1f2039767aa24d97a12f137d36',
        179108,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'IMFellEnglishSC',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the IM Fell English SC font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/IM+Fell+English+SC
  static TextTheme imFellEnglishScTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: imFellEnglishSc(textStyle: textTheme.displayLarge),
      displayMedium: imFellEnglishSc(textStyle: textTheme.displayMedium),
      displaySmall: imFellEnglishSc(textStyle: textTheme.displaySmall),
      headlineLarge: imFellEnglishSc(textStyle: textTheme.headlineLarge),
      headlineMedium: imFellEnglishSc(textStyle: textTheme.headlineMedium),
      headlineSmall: imFellEnglishSc(textStyle: textTheme.headlineSmall),
      titleLarge: imFellEnglishSc(textStyle: textTheme.titleLarge),
      titleMedium: imFellEnglishSc(textStyle: textTheme.titleMedium),
      titleSmall: imFellEnglishSc(textStyle: textTheme.titleSmall),
      bodyLarge: imFellEnglishSc(textStyle: textTheme.bodyLarge),
      bodyMedium: imFellEnglishSc(textStyle: textTheme.bodyMedium),
      bodySmall: imFellEnglishSc(textStyle: textTheme.bodySmall),
      labelLarge: imFellEnglishSc(textStyle: textTheme.labelLarge),
      labelMedium: imFellEnglishSc(textStyle: textTheme.labelMedium),
      labelSmall: imFellEnglishSc(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the IM Fell French Canon font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/IM+Fell+French+Canon
  static TextStyle imFellFrenchCanon({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '0628eb90b4ea261f205fcb44d0ba858917f4ab4bccead4e82d0ad216b60eca5a',
        140704,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '469413b568988dd75baf5cd92c8d8e7488e3f3b3e4f6a320adec03a44796fb3b',
        152844,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'IMFellFrenchCanon',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the IM Fell French Canon font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/IM+Fell+French+Canon
  static TextTheme imFellFrenchCanonTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: imFellFrenchCanon(textStyle: textTheme.displayLarge),
      displayMedium: imFellFrenchCanon(textStyle: textTheme.displayMedium),
      displaySmall: imFellFrenchCanon(textStyle: textTheme.displaySmall),
      headlineLarge: imFellFrenchCanon(textStyle: textTheme.headlineLarge),
      headlineMedium: imFellFrenchCanon(textStyle: textTheme.headlineMedium),
      headlineSmall: imFellFrenchCanon(textStyle: textTheme.headlineSmall),
      titleLarge: imFellFrenchCanon(textStyle: textTheme.titleLarge),
      titleMedium: imFellFrenchCanon(textStyle: textTheme.titleMedium),
      titleSmall: imFellFrenchCanon(textStyle: textTheme.titleSmall),
      bodyLarge: imFellFrenchCanon(textStyle: textTheme.bodyLarge),
      bodyMedium: imFellFrenchCanon(textStyle: textTheme.bodyMedium),
      bodySmall: imFellFrenchCanon(textStyle: textTheme.bodySmall),
      labelLarge: imFellFrenchCanon(textStyle: textTheme.labelLarge),
      labelMedium: imFellFrenchCanon(textStyle: textTheme.labelMedium),
      labelSmall: imFellFrenchCanon(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the IM Fell French Canon SC font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/IM+Fell+French+Canon+SC
  static TextStyle imFellFrenchCanonSc({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'dc3444ab98e1b881f5ebf3e55d015850337c9f33cb0797dd1575471c2c506ad7',
        131564,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'IMFellFrenchCanonSC',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the IM Fell French Canon SC font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/IM+Fell+French+Canon+SC
  static TextTheme imFellFrenchCanonScTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: imFellFrenchCanonSc(textStyle: textTheme.displayLarge),
      displayMedium: imFellFrenchCanonSc(textStyle: textTheme.displayMedium),
      displaySmall: imFellFrenchCanonSc(textStyle: textTheme.displaySmall),
      headlineLarge: imFellFrenchCanonSc(textStyle: textTheme.headlineLarge),
      headlineMedium: imFellFrenchCanonSc(textStyle: textTheme.headlineMedium),
      headlineSmall: imFellFrenchCanonSc(textStyle: textTheme.headlineSmall),
      titleLarge: imFellFrenchCanonSc(textStyle: textTheme.titleLarge),
      titleMedium: imFellFrenchCanonSc(textStyle: textTheme.titleMedium),
      titleSmall: imFellFrenchCanonSc(textStyle: textTheme.titleSmall),
      bodyLarge: imFellFrenchCanonSc(textStyle: textTheme.bodyLarge),
      bodyMedium: imFellFrenchCanonSc(textStyle: textTheme.bodyMedium),
      bodySmall: imFellFrenchCanonSc(textStyle: textTheme.bodySmall),
      labelLarge: imFellFrenchCanonSc(textStyle: textTheme.labelLarge),
      labelMedium: imFellFrenchCanonSc(textStyle: textTheme.labelMedium),
      labelSmall: imFellFrenchCanonSc(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the IM Fell Great Primer font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/IM+Fell+Great+Primer
  static TextStyle imFellGreatPrimer({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '370ece4793dbcaf0eee325718a3d90055b03dab7fb30cf4e28209d1923421e8f',
        210524,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '05fa578ead197e918f537cd79fb0d944884b6364bc9c47c52a5838e1838d02c3',
        243096,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'IMFellGreatPrimer',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the IM Fell Great Primer font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/IM+Fell+Great+Primer
  static TextTheme imFellGreatPrimerTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: imFellGreatPrimer(textStyle: textTheme.displayLarge),
      displayMedium: imFellGreatPrimer(textStyle: textTheme.displayMedium),
      displaySmall: imFellGreatPrimer(textStyle: textTheme.displaySmall),
      headlineLarge: imFellGreatPrimer(textStyle: textTheme.headlineLarge),
      headlineMedium: imFellGreatPrimer(textStyle: textTheme.headlineMedium),
      headlineSmall: imFellGreatPrimer(textStyle: textTheme.headlineSmall),
      titleLarge: imFellGreatPrimer(textStyle: textTheme.titleLarge),
      titleMedium: imFellGreatPrimer(textStyle: textTheme.titleMedium),
      titleSmall: imFellGreatPrimer(textStyle: textTheme.titleSmall),
      bodyLarge: imFellGreatPrimer(textStyle: textTheme.bodyLarge),
      bodyMedium: imFellGreatPrimer(textStyle: textTheme.bodyMedium),
      bodySmall: imFellGreatPrimer(textStyle: textTheme.bodySmall),
      labelLarge: imFellGreatPrimer(textStyle: textTheme.labelLarge),
      labelMedium: imFellGreatPrimer(textStyle: textTheme.labelMedium),
      labelSmall: imFellGreatPrimer(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the IM Fell Great Primer SC font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/IM+Fell+Great+Primer+SC
  static TextStyle imFellGreatPrimerSc({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'e08827d0ff29ee91c0e4e486b583ffefafb018e6193eb83f130c1832b4379878',
        198108,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'IMFellGreatPrimerSC',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the IM Fell Great Primer SC font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/IM+Fell+Great+Primer+SC
  static TextTheme imFellGreatPrimerScTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: imFellGreatPrimerSc(textStyle: textTheme.displayLarge),
      displayMedium: imFellGreatPrimerSc(textStyle: textTheme.displayMedium),
      displaySmall: imFellGreatPrimerSc(textStyle: textTheme.displaySmall),
      headlineLarge: imFellGreatPrimerSc(textStyle: textTheme.headlineLarge),
      headlineMedium: imFellGreatPrimerSc(textStyle: textTheme.headlineMedium),
      headlineSmall: imFellGreatPrimerSc(textStyle: textTheme.headlineSmall),
      titleLarge: imFellGreatPrimerSc(textStyle: textTheme.titleLarge),
      titleMedium: imFellGreatPrimerSc(textStyle: textTheme.titleMedium),
      titleSmall: imFellGreatPrimerSc(textStyle: textTheme.titleSmall),
      bodyLarge: imFellGreatPrimerSc(textStyle: textTheme.bodyLarge),
      bodyMedium: imFellGreatPrimerSc(textStyle: textTheme.bodyMedium),
      bodySmall: imFellGreatPrimerSc(textStyle: textTheme.bodySmall),
      labelLarge: imFellGreatPrimerSc(textStyle: textTheme.labelLarge),
      labelMedium: imFellGreatPrimerSc(textStyle: textTheme.labelMedium),
      labelSmall: imFellGreatPrimerSc(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Iansui font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Iansui
  static TextStyle iansui({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '54582dc5a36f7f793c7a2cf7bcc59e8d354120ebfc10724310934b598f7c8bc1',
        8561724,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Iansui',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Iansui font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Iansui
  static TextTheme iansuiTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: iansui(textStyle: textTheme.displayLarge),
      displayMedium: iansui(textStyle: textTheme.displayMedium),
      displaySmall: iansui(textStyle: textTheme.displaySmall),
      headlineLarge: iansui(textStyle: textTheme.headlineLarge),
      headlineMedium: iansui(textStyle: textTheme.headlineMedium),
      headlineSmall: iansui(textStyle: textTheme.headlineSmall),
      titleLarge: iansui(textStyle: textTheme.titleLarge),
      titleMedium: iansui(textStyle: textTheme.titleMedium),
      titleSmall: iansui(textStyle: textTheme.titleSmall),
      bodyLarge: iansui(textStyle: textTheme.bodyLarge),
      bodyMedium: iansui(textStyle: textTheme.bodyMedium),
      bodySmall: iansui(textStyle: textTheme.bodySmall),
      labelLarge: iansui(textStyle: textTheme.labelLarge),
      labelMedium: iansui(textStyle: textTheme.labelMedium),
      labelSmall: iansui(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Ibarra Real Nova font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Ibarra+Real+Nova
  static TextStyle ibarraRealNova({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '6dbd281e257d4c113e6afb92a17863c0dbd22b780296c359e2cc0f7b28d1b106',
        54900,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'dca9e0d59da9a625706cb21d150c87c485632de3d6a008b6f724d39f996dafcb',
        54908,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '16987773001b8f2336bf1ab0aee945bcc8c47fb9a2d9f1e171249b5e81f7decf',
        54960,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'e3a0c6ee5175df3fdb7864eaa0ce1c08566de76eb1830b6a64613de6dd556cc2',
        54864,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'e595a9abdee462527c8c8e7592957847db94ab9cf20a171ffcbc2f8db1477245',
        59332,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '6e4ec29af57ba34c4c996d53639ea477b245d5df40a60175bdc125d11b19f045',
        59460,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'fc39ccac213d5166fca971404542caab49ece842f084933faaa421124aa36086',
        59528,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '0de66fa2cb647376c116aed5783a20f77a31bc1d84a1f5122e485feb381066b0',
        59396,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '4684baf422491c7925b6dedecf122621834284dbe49375f7c711c5565eed0e76',
        86100,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'c2bfbd01fd6584ad806485ebf7919b2220fb35cf69c6f858fd82d27a2f6e6596',
        92660,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'IbarraRealNova',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Ibarra Real Nova font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Ibarra+Real+Nova
  static TextTheme ibarraRealNovaTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: ibarraRealNova(textStyle: textTheme.displayLarge),
      displayMedium: ibarraRealNova(textStyle: textTheme.displayMedium),
      displaySmall: ibarraRealNova(textStyle: textTheme.displaySmall),
      headlineLarge: ibarraRealNova(textStyle: textTheme.headlineLarge),
      headlineMedium: ibarraRealNova(textStyle: textTheme.headlineMedium),
      headlineSmall: ibarraRealNova(textStyle: textTheme.headlineSmall),
      titleLarge: ibarraRealNova(textStyle: textTheme.titleLarge),
      titleMedium: ibarraRealNova(textStyle: textTheme.titleMedium),
      titleSmall: ibarraRealNova(textStyle: textTheme.titleSmall),
      bodyLarge: ibarraRealNova(textStyle: textTheme.bodyLarge),
      bodyMedium: ibarraRealNova(textStyle: textTheme.bodyMedium),
      bodySmall: ibarraRealNova(textStyle: textTheme.bodySmall),
      labelLarge: ibarraRealNova(textStyle: textTheme.labelLarge),
      labelMedium: ibarraRealNova(textStyle: textTheme.labelMedium),
      labelSmall: ibarraRealNova(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Iceberg font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Iceberg
  static TextStyle iceberg({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '071ae00cb407c3955eb2df84105d369107cd729f43a9d9c66b103b25fa3c0ad4',
        13156,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Iceberg',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Iceberg font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Iceberg
  static TextTheme icebergTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: iceberg(textStyle: textTheme.displayLarge),
      displayMedium: iceberg(textStyle: textTheme.displayMedium),
      displaySmall: iceberg(textStyle: textTheme.displaySmall),
      headlineLarge: iceberg(textStyle: textTheme.headlineLarge),
      headlineMedium: iceberg(textStyle: textTheme.headlineMedium),
      headlineSmall: iceberg(textStyle: textTheme.headlineSmall),
      titleLarge: iceberg(textStyle: textTheme.titleLarge),
      titleMedium: iceberg(textStyle: textTheme.titleMedium),
      titleSmall: iceberg(textStyle: textTheme.titleSmall),
      bodyLarge: iceberg(textStyle: textTheme.bodyLarge),
      bodyMedium: iceberg(textStyle: textTheme.bodyMedium),
      bodySmall: iceberg(textStyle: textTheme.bodySmall),
      labelLarge: iceberg(textStyle: textTheme.labelLarge),
      labelMedium: iceberg(textStyle: textTheme.labelMedium),
      labelSmall: iceberg(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Iceland font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Iceland
  static TextStyle iceland({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '60c31b972ef0cd764b1b88e2e0f55b295f412ced49e5e456522b490f02493f2b',
        14276,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Iceland',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Iceland font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Iceland
  static TextTheme icelandTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: iceland(textStyle: textTheme.displayLarge),
      displayMedium: iceland(textStyle: textTheme.displayMedium),
      displaySmall: iceland(textStyle: textTheme.displaySmall),
      headlineLarge: iceland(textStyle: textTheme.headlineLarge),
      headlineMedium: iceland(textStyle: textTheme.headlineMedium),
      headlineSmall: iceland(textStyle: textTheme.headlineSmall),
      titleLarge: iceland(textStyle: textTheme.titleLarge),
      titleMedium: iceland(textStyle: textTheme.titleMedium),
      titleSmall: iceland(textStyle: textTheme.titleSmall),
      bodyLarge: iceland(textStyle: textTheme.bodyLarge),
      bodyMedium: iceland(textStyle: textTheme.bodyMedium),
      bodySmall: iceland(textStyle: textTheme.bodySmall),
      labelLarge: iceland(textStyle: textTheme.labelLarge),
      labelMedium: iceland(textStyle: textTheme.labelMedium),
      labelSmall: iceland(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Imbue font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Imbue
  static TextStyle imbue({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
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
        '8273b37d30c60ff77298a7da1dc4741b304314d0e06ac3177e93ffacbd142d63',
        65188,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '991a62fc8864b87ba9c72abf0af20e6bd8229ab0dc9a1699185e16c8a048f684',
        65484,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '18361c1f8b3aa4c34ae0d5d44d73e4cdff2b70542865791484362e11ef6fe108',
        65460,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'e37a7ab4faf55413cde37ab3cc015170b10b15e8fc8bcb20f0afbe3ddf7cd08d',
        65520,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '119d87943cd9b6f7efdfc58d53c7e9f0556b7ede2e5cc0ac4f2d149e7fbbd2ca',
        65568,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '98843eb4d598933ad94691b1de5e7fd9b685fbc1b5ef3c2aaf0f3d8b67775574',
        65660,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '6b2af4f90594b792e20c7c8f4035b7ed092f48ef4ebe37a9dc58b87e49c8ad2b',
        65624,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '328cfe1ab07c456a0aacb8d3a3223b7d7e8c68936359a8eff6ba41b148d23683',
        65772,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '96460e232ce98bf8e8e575daf7bbf36d55db2d929c1e425946236311784b3a3d',
        65692,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'c90790eef90ec66d0591949bb7fac05894d65c2a2f8536d56ace51b4d6c6b955',
        164628,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Imbue',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Imbue font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Imbue
  static TextTheme imbueTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: imbue(textStyle: textTheme.displayLarge),
      displayMedium: imbue(textStyle: textTheme.displayMedium),
      displaySmall: imbue(textStyle: textTheme.displaySmall),
      headlineLarge: imbue(textStyle: textTheme.headlineLarge),
      headlineMedium: imbue(textStyle: textTheme.headlineMedium),
      headlineSmall: imbue(textStyle: textTheme.headlineSmall),
      titleLarge: imbue(textStyle: textTheme.titleLarge),
      titleMedium: imbue(textStyle: textTheme.titleMedium),
      titleSmall: imbue(textStyle: textTheme.titleSmall),
      bodyLarge: imbue(textStyle: textTheme.bodyLarge),
      bodyMedium: imbue(textStyle: textTheme.bodyMedium),
      bodySmall: imbue(textStyle: textTheme.bodySmall),
      labelLarge: imbue(textStyle: textTheme.labelLarge),
      labelMedium: imbue(textStyle: textTheme.labelMedium),
      labelSmall: imbue(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Imperial Script font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Imperial+Script
  static TextStyle imperialScript({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '020e346d04fc0978efb3f7f3b86b5ceda29ff1435d8cf6914d2c093e992550c9',
        98212,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'ImperialScript',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Imperial Script font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Imperial+Script
  static TextTheme imperialScriptTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: imperialScript(textStyle: textTheme.displayLarge),
      displayMedium: imperialScript(textStyle: textTheme.displayMedium),
      displaySmall: imperialScript(textStyle: textTheme.displaySmall),
      headlineLarge: imperialScript(textStyle: textTheme.headlineLarge),
      headlineMedium: imperialScript(textStyle: textTheme.headlineMedium),
      headlineSmall: imperialScript(textStyle: textTheme.headlineSmall),
      titleLarge: imperialScript(textStyle: textTheme.titleLarge),
      titleMedium: imperialScript(textStyle: textTheme.titleMedium),
      titleSmall: imperialScript(textStyle: textTheme.titleSmall),
      bodyLarge: imperialScript(textStyle: textTheme.bodyLarge),
      bodyMedium: imperialScript(textStyle: textTheme.bodyMedium),
      bodySmall: imperialScript(textStyle: textTheme.bodySmall),
      labelLarge: imperialScript(textStyle: textTheme.labelLarge),
      labelMedium: imperialScript(textStyle: textTheme.labelMedium),
      labelSmall: imperialScript(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Imprima font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Imprima
  static TextStyle imprima({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '7582f8cc65dd58fddc00fc46eb74320836aa9fc5c649f7b8c1b10301d5f2324c',
        34796,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Imprima',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Imprima font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Imprima
  static TextTheme imprimaTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: imprima(textStyle: textTheme.displayLarge),
      displayMedium: imprima(textStyle: textTheme.displayMedium),
      displaySmall: imprima(textStyle: textTheme.displaySmall),
      headlineLarge: imprima(textStyle: textTheme.headlineLarge),
      headlineMedium: imprima(textStyle: textTheme.headlineMedium),
      headlineSmall: imprima(textStyle: textTheme.headlineSmall),
      titleLarge: imprima(textStyle: textTheme.titleLarge),
      titleMedium: imprima(textStyle: textTheme.titleMedium),
      titleSmall: imprima(textStyle: textTheme.titleSmall),
      bodyLarge: imprima(textStyle: textTheme.bodyLarge),
      bodyMedium: imprima(textStyle: textTheme.bodyMedium),
      bodySmall: imprima(textStyle: textTheme.bodySmall),
      labelLarge: imprima(textStyle: textTheme.labelLarge),
      labelMedium: imprima(textStyle: textTheme.labelMedium),
      labelSmall: imprima(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Inclusive Sans font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Inclusive+Sans
  static TextStyle inclusiveSans({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
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
        '8e2a45a94ddd2a8a6ba92970bdac39af5b63d0d78562f41632d01a17b7626415',
        57768,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'cce36cf40e1bb08a0e5c00cabb4f0fe366e221a5e1665767a51916595c5357ac',
        57828,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'c5065e58f872e6969f048cc55c612c4db1c9168175f6ac7564344b0f62949ae4',
        57884,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '771b5240344f318763967be8ca3316ed4ea1b942e80a0b34f5584214e99f2f92',
        58480,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '21dfcf4d614633ac41a41ee42601b94c322e72721c2f6e1cd79282204de0df1d',
        58376,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '8bc6ad2fa76b19c133eadb7a862b0dd53967251490e341d75ff7cb1c2955f0d5',
        59008,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'bd80eaac97371dd06d9c77203e5b371b70132720329be20a93279cc6139c87b4',
        58984,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'be1ec72cd8686ce362e2b27945c615ffa688e801564a5f3ed8b256322c18b423',
        59108,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '98127472210a04e672925f194e0f77167e8838eda0db4105d7b0078ebaa5c8a0',
        59728,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'f5e98fe1afac684391043f9837a632298b4f933393053b4602780876a469c197',
        59552,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'd4a4d95288c5ee6a47d805df7230be6afa2c9d694ee4752ce26d2cb42c4243de',
        107304,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'e658ec36e7738d316b2e5e25aec0a1a4f9f3aba8c8ae872bbe48bc54724b15a3',
        109492,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'InclusiveSans',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Inclusive Sans font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Inclusive+Sans
  static TextTheme inclusiveSansTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: inclusiveSans(textStyle: textTheme.displayLarge),
      displayMedium: inclusiveSans(textStyle: textTheme.displayMedium),
      displaySmall: inclusiveSans(textStyle: textTheme.displaySmall),
      headlineLarge: inclusiveSans(textStyle: textTheme.headlineLarge),
      headlineMedium: inclusiveSans(textStyle: textTheme.headlineMedium),
      headlineSmall: inclusiveSans(textStyle: textTheme.headlineSmall),
      titleLarge: inclusiveSans(textStyle: textTheme.titleLarge),
      titleMedium: inclusiveSans(textStyle: textTheme.titleMedium),
      titleSmall: inclusiveSans(textStyle: textTheme.titleSmall),
      bodyLarge: inclusiveSans(textStyle: textTheme.bodyLarge),
      bodyMedium: inclusiveSans(textStyle: textTheme.bodyMedium),
      bodySmall: inclusiveSans(textStyle: textTheme.bodySmall),
      labelLarge: inclusiveSans(textStyle: textTheme.labelLarge),
      labelMedium: inclusiveSans(textStyle: textTheme.labelMedium),
      labelSmall: inclusiveSans(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Inconsolata font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Inconsolata
  static TextStyle inconsolata({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
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
        '749a2a168664d2c866b74be29fa0c412d185951ff862e97b5c36546bb54a9c39',
        73192,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'c2005290f47c080725f69856b1abc72841fab6fafd7118e8c5b3bd0054f1833d',
        73032,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'a0aefc01334c1de50242833a57c72be0e158a8723411b85e03e9e7a2aa692228',
        72952,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'ad06d812cd5af85391b286c350331b454abaa9d5e4ebc9d1a9c5c2c1bb071bd6',
        73388,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '25f8723af5de530f4d3cff308e5fb09baa00d4cf88fbc2805c6d6a47bb6a2f8a',
        73464,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'fa95fcf06de211a7ba3fdcf3bc1e3880ea306bd2c654c44dd2c72dde8d66d603',
        73336,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'da7e66bd81c62a97c9238dbf675184215514db2363e69ffced344c40c528ec18',
        73328,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '0ff21c66ad0c1ccb7fd0c49a023308b2c65be37f745757a19becc2d1dfcf46dd',
        73120,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'ee8318b46ab30e6706b1e2ebc866ecbb1cde0490a5f86b6d83036f0005db6360',
        312428,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Inconsolata',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Inconsolata font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Inconsolata
  static TextTheme inconsolataTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: inconsolata(textStyle: textTheme.displayLarge),
      displayMedium: inconsolata(textStyle: textTheme.displayMedium),
      displaySmall: inconsolata(textStyle: textTheme.displaySmall),
      headlineLarge: inconsolata(textStyle: textTheme.headlineLarge),
      headlineMedium: inconsolata(textStyle: textTheme.headlineMedium),
      headlineSmall: inconsolata(textStyle: textTheme.headlineSmall),
      titleLarge: inconsolata(textStyle: textTheme.titleLarge),
      titleMedium: inconsolata(textStyle: textTheme.titleMedium),
      titleSmall: inconsolata(textStyle: textTheme.titleSmall),
      bodyLarge: inconsolata(textStyle: textTheme.bodyLarge),
      bodyMedium: inconsolata(textStyle: textTheme.bodyMedium),
      bodySmall: inconsolata(textStyle: textTheme.bodySmall),
      labelLarge: inconsolata(textStyle: textTheme.labelLarge),
      labelMedium: inconsolata(textStyle: textTheme.labelMedium),
      labelSmall: inconsolata(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Inder font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Inder
  static TextStyle inder({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'a1e9a9cbaf4f35975974799cba625a0b53fbcb12391b8132af214293c583ca34',
        28104,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Inder',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Inder font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Inder
  static TextTheme inderTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: inder(textStyle: textTheme.displayLarge),
      displayMedium: inder(textStyle: textTheme.displayMedium),
      displaySmall: inder(textStyle: textTheme.displaySmall),
      headlineLarge: inder(textStyle: textTheme.headlineLarge),
      headlineMedium: inder(textStyle: textTheme.headlineMedium),
      headlineSmall: inder(textStyle: textTheme.headlineSmall),
      titleLarge: inder(textStyle: textTheme.titleLarge),
      titleMedium: inder(textStyle: textTheme.titleMedium),
      titleSmall: inder(textStyle: textTheme.titleSmall),
      bodyLarge: inder(textStyle: textTheme.bodyLarge),
      bodyMedium: inder(textStyle: textTheme.bodyMedium),
      bodySmall: inder(textStyle: textTheme.bodySmall),
      labelLarge: inder(textStyle: textTheme.labelLarge),
      labelMedium: inder(textStyle: textTheme.labelMedium),
      labelSmall: inder(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Indie Flower font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Indie+Flower
  static TextStyle indieFlower({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '6c348c11a26f21a66feb698894e308102f3f5b7f6346757ecb868f86bff34dc4',
        45684,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'IndieFlower',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Indie Flower font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Indie+Flower
  static TextTheme indieFlowerTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: indieFlower(textStyle: textTheme.displayLarge),
      displayMedium: indieFlower(textStyle: textTheme.displayMedium),
      displaySmall: indieFlower(textStyle: textTheme.displaySmall),
      headlineLarge: indieFlower(textStyle: textTheme.headlineLarge),
      headlineMedium: indieFlower(textStyle: textTheme.headlineMedium),
      headlineSmall: indieFlower(textStyle: textTheme.headlineSmall),
      titleLarge: indieFlower(textStyle: textTheme.titleLarge),
      titleMedium: indieFlower(textStyle: textTheme.titleMedium),
      titleSmall: indieFlower(textStyle: textTheme.titleSmall),
      bodyLarge: indieFlower(textStyle: textTheme.bodyLarge),
      bodyMedium: indieFlower(textStyle: textTheme.bodyMedium),
      bodySmall: indieFlower(textStyle: textTheme.bodySmall),
      labelLarge: indieFlower(textStyle: textTheme.labelLarge),
      labelMedium: indieFlower(textStyle: textTheme.labelMedium),
      labelSmall: indieFlower(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Ingrid Darling font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Ingrid+Darling
  static TextStyle ingridDarling({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '8f15f92b4d115f4f9ca194d043b0149516d0fb6971d8427188ac228215348648',
        101080,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'IngridDarling',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Ingrid Darling font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Ingrid+Darling
  static TextTheme ingridDarlingTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: ingridDarling(textStyle: textTheme.displayLarge),
      displayMedium: ingridDarling(textStyle: textTheme.displayMedium),
      displaySmall: ingridDarling(textStyle: textTheme.displaySmall),
      headlineLarge: ingridDarling(textStyle: textTheme.headlineLarge),
      headlineMedium: ingridDarling(textStyle: textTheme.headlineMedium),
      headlineSmall: ingridDarling(textStyle: textTheme.headlineSmall),
      titleLarge: ingridDarling(textStyle: textTheme.titleLarge),
      titleMedium: ingridDarling(textStyle: textTheme.titleMedium),
      titleSmall: ingridDarling(textStyle: textTheme.titleSmall),
      bodyLarge: ingridDarling(textStyle: textTheme.bodyLarge),
      bodyMedium: ingridDarling(textStyle: textTheme.bodyMedium),
      bodySmall: ingridDarling(textStyle: textTheme.bodySmall),
      labelLarge: ingridDarling(textStyle: textTheme.labelLarge),
      labelMedium: ingridDarling(textStyle: textTheme.labelMedium),
      labelSmall: ingridDarling(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Inika font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Inika
  static TextStyle inika({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '591590272d7a6a314d2e3d1566d2fd5a394c7ebd85b475c6ba1467a8cc869649',
        37808,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'b4e48713a4a046651e1d7f7c5e9c13bc3394458f739dd76c6532756aef042a0c',
        36444,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Inika',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Inika font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Inika
  static TextTheme inikaTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: inika(textStyle: textTheme.displayLarge),
      displayMedium: inika(textStyle: textTheme.displayMedium),
      displaySmall: inika(textStyle: textTheme.displaySmall),
      headlineLarge: inika(textStyle: textTheme.headlineLarge),
      headlineMedium: inika(textStyle: textTheme.headlineMedium),
      headlineSmall: inika(textStyle: textTheme.headlineSmall),
      titleLarge: inika(textStyle: textTheme.titleLarge),
      titleMedium: inika(textStyle: textTheme.titleMedium),
      titleSmall: inika(textStyle: textTheme.titleSmall),
      bodyLarge: inika(textStyle: textTheme.bodyLarge),
      bodyMedium: inika(textStyle: textTheme.bodyMedium),
      bodySmall: inika(textStyle: textTheme.bodySmall),
      labelLarge: inika(textStyle: textTheme.labelLarge),
      labelMedium: inika(textStyle: textTheme.labelMedium),
      labelSmall: inika(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Inknut Antiqua font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Inknut+Antiqua
  static TextStyle inknutAntiqua({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
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
        '445bfe575c4fcbdca87e6b173ba5cf2c139d7a507fdd17d7095a5cd5d1bf80b4',
        229632,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '314758cfa26d9cb9c21e4fc3bd07b000e312508889499630ee8cd60c6d2fa801',
        226920,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '39c64c09acb683fb7278cb02bd946af1effab3eccb14d606c283d85dd8f6f3cc',
        227788,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'f7e1b9b85ecb285143f253901051b1be03d5135655029a01f41a626c0a6018ff',
        227228,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '1e0f978b0f07ca59f94cc424d7386a1d71dcf07f9d9aa72d3714144669441f02',
        224852,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'e38cd7dacfb4c3409c1fea0768090e56064d40395aa64d26a7600247d3de0ba5',
        223760,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '906d89c5416eddf5ac4949a1efa4f56be7fa94f2c9a08a48294b589ac2def206',
        218860,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'InknutAntiqua',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Inknut Antiqua font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Inknut+Antiqua
  static TextTheme inknutAntiquaTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: inknutAntiqua(textStyle: textTheme.displayLarge),
      displayMedium: inknutAntiqua(textStyle: textTheme.displayMedium),
      displaySmall: inknutAntiqua(textStyle: textTheme.displaySmall),
      headlineLarge: inknutAntiqua(textStyle: textTheme.headlineLarge),
      headlineMedium: inknutAntiqua(textStyle: textTheme.headlineMedium),
      headlineSmall: inknutAntiqua(textStyle: textTheme.headlineSmall),
      titleLarge: inknutAntiqua(textStyle: textTheme.titleLarge),
      titleMedium: inknutAntiqua(textStyle: textTheme.titleMedium),
      titleSmall: inknutAntiqua(textStyle: textTheme.titleSmall),
      bodyLarge: inknutAntiqua(textStyle: textTheme.bodyLarge),
      bodyMedium: inknutAntiqua(textStyle: textTheme.bodyMedium),
      bodySmall: inknutAntiqua(textStyle: textTheme.bodySmall),
      labelLarge: inknutAntiqua(textStyle: textTheme.labelLarge),
      labelMedium: inknutAntiqua(textStyle: textTheme.labelMedium),
      labelSmall: inknutAntiqua(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Inria Sans font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Inria+Sans
  static TextStyle inriaSans({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
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
        '5fa2920dc86903b45b3952a45c05fc28dea0fc6db884b1576a66a2c95e57ebca',
        46092,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '87ddc2795ba33c1e79863e56fe6e6208fb4b3203fbdaa702a82d2d9ce45c25f4',
        47432,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '01ffd184df52e6206425a49493d56e77c20f126b8ad830f6012a8cfa106b8338',
        46304,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'aedd519d11b9c5745edc55510d04ae7812cbd077b2ebcd9d2f111882af589ac1',
        47656,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'b685a418721d1176c3a863c44e6aac1d2f645c78dae0a8553a935c5871006c54',
        45656,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '6a0cfddc548be8b99cd2e50196f8f6fb1f10493c1b2544728aa3ea74998749f6',
        47312,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'InriaSans',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Inria Sans font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Inria+Sans
  static TextTheme inriaSansTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: inriaSans(textStyle: textTheme.displayLarge),
      displayMedium: inriaSans(textStyle: textTheme.displayMedium),
      displaySmall: inriaSans(textStyle: textTheme.displaySmall),
      headlineLarge: inriaSans(textStyle: textTheme.headlineLarge),
      headlineMedium: inriaSans(textStyle: textTheme.headlineMedium),
      headlineSmall: inriaSans(textStyle: textTheme.headlineSmall),
      titleLarge: inriaSans(textStyle: textTheme.titleLarge),
      titleMedium: inriaSans(textStyle: textTheme.titleMedium),
      titleSmall: inriaSans(textStyle: textTheme.titleSmall),
      bodyLarge: inriaSans(textStyle: textTheme.bodyLarge),
      bodyMedium: inriaSans(textStyle: textTheme.bodyMedium),
      bodySmall: inriaSans(textStyle: textTheme.bodySmall),
      labelLarge: inriaSans(textStyle: textTheme.labelLarge),
      labelMedium: inriaSans(textStyle: textTheme.labelMedium),
      labelSmall: inriaSans(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Inria Serif font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Inria+Serif
  static TextStyle inriaSerif({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
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
        'c71d97049494c7880807f46681a338152ab24d021cbc371eedc8193d09260368',
        56092,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'd31743ddd53566587ec2a63813d3e4c65fa00d3a7314c3de15fe9967568eb9b7',
        55824,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '0c81112820ed934a9056f6aeb996eeb921353c22508b9345182e3fd0bd655f47',
        56316,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '36a4f48f355d72f4703150dce94e8c1964d8072bac0fcb69ad36c15cbd54e730',
        55980,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'ab64b8bc9ef6acb19c5909aa402a5ca8095d700b63f53750f13fec024a366b60',
        56136,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'f7bbb9fc760b8f2d738fa41f84e5f315175e8c3861646a42e7e3129ceb6e1f5a',
        55908,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'InriaSerif',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Inria Serif font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Inria+Serif
  static TextTheme inriaSerifTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: inriaSerif(textStyle: textTheme.displayLarge),
      displayMedium: inriaSerif(textStyle: textTheme.displayMedium),
      displaySmall: inriaSerif(textStyle: textTheme.displaySmall),
      headlineLarge: inriaSerif(textStyle: textTheme.headlineLarge),
      headlineMedium: inriaSerif(textStyle: textTheme.headlineMedium),
      headlineSmall: inriaSerif(textStyle: textTheme.headlineSmall),
      titleLarge: inriaSerif(textStyle: textTheme.titleLarge),
      titleMedium: inriaSerif(textStyle: textTheme.titleMedium),
      titleSmall: inriaSerif(textStyle: textTheme.titleSmall),
      bodyLarge: inriaSerif(textStyle: textTheme.bodyLarge),
      bodyMedium: inriaSerif(textStyle: textTheme.bodyMedium),
      bodySmall: inriaSerif(textStyle: textTheme.bodySmall),
      labelLarge: inriaSerif(textStyle: textTheme.labelLarge),
      labelMedium: inriaSerif(textStyle: textTheme.labelMedium),
      labelSmall: inriaSerif(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Inspiration font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Inspiration
  static TextStyle inspiration({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'ab5c709999bba4b6f962fdddaf18942559aafd79ca255c16ebbaa69b7f17bb24',
        105024,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Inspiration',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Inspiration font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Inspiration
  static TextTheme inspirationTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: inspiration(textStyle: textTheme.displayLarge),
      displayMedium: inspiration(textStyle: textTheme.displayMedium),
      displaySmall: inspiration(textStyle: textTheme.displaySmall),
      headlineLarge: inspiration(textStyle: textTheme.headlineLarge),
      headlineMedium: inspiration(textStyle: textTheme.headlineMedium),
      headlineSmall: inspiration(textStyle: textTheme.headlineSmall),
      titleLarge: inspiration(textStyle: textTheme.titleLarge),
      titleMedium: inspiration(textStyle: textTheme.titleMedium),
      titleSmall: inspiration(textStyle: textTheme.titleSmall),
      bodyLarge: inspiration(textStyle: textTheme.bodyLarge),
      bodyMedium: inspiration(textStyle: textTheme.bodyMedium),
      bodySmall: inspiration(textStyle: textTheme.bodySmall),
      labelLarge: inspiration(textStyle: textTheme.labelLarge),
      labelMedium: inspiration(textStyle: textTheme.labelMedium),
      labelSmall: inspiration(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Instrument Sans font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Instrument+Sans
  static TextStyle instrumentSans({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'a0d636084c04969c1f0ebde2187f920cce7c21fcb58aa2a512c4fb0a79b518b4',
        48592,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '7f1dc3bbee47afef26069635d4bd6b05e1ded803508d4adf02417cb74569c8d2',
        48708,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'c750849900ffada1e52e2ea9fb58316e9479d0c2decb69bd0c45aa5f27a5b318',
        48708,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '472225de858ea55c07a28b7730cce5104b0c9d32d5599d916e9676243ab46dd2',
        48528,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '75b6bf1697b636982209f2bb51b1ffebe96b043e14f56d5c109c6a9c1884ab8f',
        50020,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '421fb175e91a8fc5718842e753aff667481a30973d25ed925f82a01342c9e5a3',
        50204,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '0ef583cc282ca4a958244d979fcf01131b4795afb35fe22d9259093d3d355bbf',
        50168,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'deb338669d6ff1390f08393bac2b49de889d0275709134d744498616f1212e36',
        50028,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '463e73a2a444c90c4328245629e28d0a5480bc2a059d45ce5951da2b5bab152c',
        141112,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '57f217f020378f5c72c308228ea521612d9094d5f843414673abe2324a20084b',
        147496,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'InstrumentSans',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Instrument Sans font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Instrument+Sans
  static TextTheme instrumentSansTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: instrumentSans(textStyle: textTheme.displayLarge),
      displayMedium: instrumentSans(textStyle: textTheme.displayMedium),
      displaySmall: instrumentSans(textStyle: textTheme.displaySmall),
      headlineLarge: instrumentSans(textStyle: textTheme.headlineLarge),
      headlineMedium: instrumentSans(textStyle: textTheme.headlineMedium),
      headlineSmall: instrumentSans(textStyle: textTheme.headlineSmall),
      titleLarge: instrumentSans(textStyle: textTheme.titleLarge),
      titleMedium: instrumentSans(textStyle: textTheme.titleMedium),
      titleSmall: instrumentSans(textStyle: textTheme.titleSmall),
      bodyLarge: instrumentSans(textStyle: textTheme.bodyLarge),
      bodyMedium: instrumentSans(textStyle: textTheme.bodyMedium),
      bodySmall: instrumentSans(textStyle: textTheme.bodySmall),
      labelLarge: instrumentSans(textStyle: textTheme.labelLarge),
      labelMedium: instrumentSans(textStyle: textTheme.labelMedium),
      labelSmall: instrumentSans(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Instrument Serif font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Instrument+Serif
  static TextStyle instrumentSerif({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'ee7535ec55e3f48b913d66868731b3b35df0800e16d8f8ea95d3a991b71c74d7',
        48340,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'c05dead00e34a309cdacba455105ea12c69a7193b50ff438e518f22aa530cb03',
        47920,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'InstrumentSerif',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Instrument Serif font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Instrument+Serif
  static TextTheme instrumentSerifTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: instrumentSerif(textStyle: textTheme.displayLarge),
      displayMedium: instrumentSerif(textStyle: textTheme.displayMedium),
      displaySmall: instrumentSerif(textStyle: textTheme.displaySmall),
      headlineLarge: instrumentSerif(textStyle: textTheme.headlineLarge),
      headlineMedium: instrumentSerif(textStyle: textTheme.headlineMedium),
      headlineSmall: instrumentSerif(textStyle: textTheme.headlineSmall),
      titleLarge: instrumentSerif(textStyle: textTheme.titleLarge),
      titleMedium: instrumentSerif(textStyle: textTheme.titleMedium),
      titleSmall: instrumentSerif(textStyle: textTheme.titleSmall),
      bodyLarge: instrumentSerif(textStyle: textTheme.bodyLarge),
      bodyMedium: instrumentSerif(textStyle: textTheme.bodyMedium),
      bodySmall: instrumentSerif(textStyle: textTheme.bodySmall),
      labelLarge: instrumentSerif(textStyle: textTheme.labelLarge),
      labelMedium: instrumentSerif(textStyle: textTheme.labelMedium),
      labelSmall: instrumentSerif(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Intel One Mono font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Intel+One+Mono
  static TextStyle intelOneMono({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
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
        '87fa303ced89f7baf2b19ff26dae83c9b086d4b6d5dfa2e429eeb53b1c29ccc6',
        58780,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'b009a08e7bd9f3493b0d0f60ce029eeec0eac92175a487ec72b7afe476cf0d6a',
        60864,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '297ea2abd9954ad51db112ec4a52c675f9b50b181a3fe7b31c989e6628d72420',
        58632,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '88a81ca6fdf2928fbea394723352283dd4e195673038204884017ce0b7d1d673',
        60596,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '5b97f5415b8b4b7063814ae5d486cc312caf4d35e7fdd73ad286e7e4c5cf7125',
        58260,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'be8a98b96f38bf802c24f975a78bfc6c9cd81dbbf35cc6aa330ec618733b9a6b',
        60304,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '546dcfb41cd14a19bbe7cf97b6d51a66eab95e2c5fd8d6e41d45b0aff63278b5',
        58308,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'c873754af7deb6855adee3f87ea29a621bf8d5d4388097c70bba0e59e463d9d7',
        60344,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'c527bbfdc117cad2b071ebd75b2d4234ad5c3deed89509ce968a4c7a447315ba',
        58280,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'e833db7126a955b42c7cb15298c88b41efd73ebbe8b9a668acdc524b59caebcc',
        60284,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '028cf7ff8466ad657d285bbb3ec6739da73589d13f29757570d98a32d7b3eb23',
        94364,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '03b1093541180acb2691de4a948d1b9f4fe0756545a4c5222f726bd4bce08886',
        98912,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'IntelOneMono',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Intel One Mono font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Intel+One+Mono
  static TextTheme intelOneMonoTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: intelOneMono(textStyle: textTheme.displayLarge),
      displayMedium: intelOneMono(textStyle: textTheme.displayMedium),
      displaySmall: intelOneMono(textStyle: textTheme.displaySmall),
      headlineLarge: intelOneMono(textStyle: textTheme.headlineLarge),
      headlineMedium: intelOneMono(textStyle: textTheme.headlineMedium),
      headlineSmall: intelOneMono(textStyle: textTheme.headlineSmall),
      titleLarge: intelOneMono(textStyle: textTheme.titleLarge),
      titleMedium: intelOneMono(textStyle: textTheme.titleMedium),
      titleSmall: intelOneMono(textStyle: textTheme.titleSmall),
      bodyLarge: intelOneMono(textStyle: textTheme.bodyLarge),
      bodyMedium: intelOneMono(textStyle: textTheme.bodyMedium),
      bodySmall: intelOneMono(textStyle: textTheme.bodySmall),
      labelLarge: intelOneMono(textStyle: textTheme.labelLarge),
      labelMedium: intelOneMono(textStyle: textTheme.labelMedium),
      labelSmall: intelOneMono(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Inter font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Inter
  static TextStyle inter({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
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
        '36201b34de0f9164edaadfa3854a84e0e4e6184588a03e775ef0ac0a24783139',
        325004,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '4fbc12952c229be983a58502c92fc6bcde626d86d490cc71d980de52e5e975b1',
        325580,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '8641cf8fd5e04d0f94062395a2d1ab1ba5467831af690069e8f3ea0efe640d70',
        325724,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '15b294b67f2f8bbc04d990023ef4aec66502b87dc9040d84abe5f896ccb693de',
        324796,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '36a36ff7ac46dc2aeceac3a80a87a67e7b844b8fc936699259aac8fba9bcf734',
        325280,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '334bb2c51aeba5f566abac8d03a7e75ab3234d6926b52e92a85dc704129258b5',
        326024,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '76121a34a606cc8a0e1ef5a47d2b9ba9678c41f5c852d63eb28f62069373bfad',
        326444,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '6af943899936fd3fd15a5889db4a384cec311c9bfe33d74bcfd3e0ae56f1b1d1',
        327300,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'd892b18d080d1200aa41ea8851da84dd8c24c33843d491fa034ac57b16f22973',
        327236,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w100,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '2337920eef2532d7ee1b86c084df8282c26c5d02be5f2ab0d019eb4b32aacdc8',
        329100,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'a87b13dcc6b25a8b0aae8f6bafa9937b25a7f8cf964234077d09c71e4d9324c2',
        329368,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'c5261dd4a04dd4db44151b40873e9c3e4b430e8c24fe1c644096299eaa02a055',
        329188,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '0e6e7a16caca2f42fb4966bf550abe48a84dc8de32d326797c8c03e6357c0133',
        328228,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '9f84b48a486d84347767cb5ece2e783df7ebe8125afad8766bbf2e37a1d6f229',
        328740,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '177d819b8ba335a1bf59f59e34a53d679c0f755166f8afd396ade32048b36bbf',
        329596,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'cf34025c1822d7ccfe8836913810b34a92a3c41417a24c9aa5bac8dd717e08ea',
        330108,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'e5337853143e2863cc03cc02bcb8f9ae538ffcfb7b839e54825631133b5e66b1',
        330996,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'ebf63e7eba6963dbe2020d1eb047760d6af1388cfda2bb14a3f2f8cc72427478',
        331020,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '6fde7a0c6454e99e1444d50851ddaa210d0b90cecb448dfc84d9b2e3379274b0',
        846496,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'cb49c2bf2d1b4e1f05c6559f0d6ea83e8713539f576d3514395d49270ab55458',
        876348,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Inter',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Inter font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Inter
  static TextTheme interTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: inter(textStyle: textTheme.displayLarge),
      displayMedium: inter(textStyle: textTheme.displayMedium),
      displaySmall: inter(textStyle: textTheme.displaySmall),
      headlineLarge: inter(textStyle: textTheme.headlineLarge),
      headlineMedium: inter(textStyle: textTheme.headlineMedium),
      headlineSmall: inter(textStyle: textTheme.headlineSmall),
      titleLarge: inter(textStyle: textTheme.titleLarge),
      titleMedium: inter(textStyle: textTheme.titleMedium),
      titleSmall: inter(textStyle: textTheme.titleSmall),
      bodyLarge: inter(textStyle: textTheme.bodyLarge),
      bodyMedium: inter(textStyle: textTheme.bodyMedium),
      bodySmall: inter(textStyle: textTheme.bodySmall),
      labelLarge: inter(textStyle: textTheme.labelLarge),
      labelMedium: inter(textStyle: textTheme.labelMedium),
      labelSmall: inter(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Inter Tight font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Inter+Tight
  static TextStyle interTight({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
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
        'f58300df80a35b5826acee76f5ad647a63e8a7d85de480ab8fbfe65b903f44d0',
        298728,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '895efa80b1eedc9c96bcc33af39d0de3441db7ff431f8255983904817a64d1b5',
        299044,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '7fded91ef99068b2039eee1acbf48d0695996f58310baf319dec588c208d276d',
        298696,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'b5870f2b8371ba9960dc77dfa37e120bad10ebc1df99c7c599a45cec88878030',
        298236,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '92876967545f89e11170e78cddb26b49351f11041f1732bb06f03bf057cefb58',
        301448,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '0d0fbc342424a4a311190f0c4a672e7c48fb4ec03a750f4d65ed6ce4c6467cee',
        302188,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '1e25f240753c06659b0e998b1823d1a50a1349d2112de8aceeffb438dfd03ca8',
        302784,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '68ed7feb2c06560b6377186a2f931b3f284d07a74b4ba50b20538fc264dac1a2',
        303844,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'ad14ebe8d9a9e36df0dd02f009b7fe245630f290748c226b5194ced07ead2365',
        303784,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w100,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '8e108cffaca4cedf4b7059f029bfb94171b069d54e6d65bc98912b93613339c5',
        305140,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '5cfc2a35b4c552386314566a9d347da86ad443393efb974508b73a3ef1764a8d',
        305556,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '20b77d07a611ecbb7a1bcf788e334aee9aeec1e789a60efd10826e13f8045390',
        305296,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '203dd6923e9debedef46d85035097f853c4c2382188ba8ba727c1adba929d376',
        304804,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '12b6108a3aab549a52b9948dc3ba6132f28653e3378e5c552b3c209099b348b3',
        308056,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '76c454283fe641ff11d30e1ff340c2bcbb7dc2aa9fa291dcc13dca950a466015',
        308804,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '4a6f44a004898ef67dda4f9ba341dc42e5ba9bc5c9435f8e7d420f1c652a0fc9',
        309304,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'db0ba6ce8accf41c10715be391e9858ebf47a19f9980be8f9e769dccf31df57c',
        310196,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '362d4f14897417aea353eb43be7bd3df30a27377407e1644ba32a4fec7651a8a',
        310204,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '41cdc624cb7d59f5ae52356186c88ad58b8bb3701d91bc03f796cddf46210f8c',
        573364,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '79001d2ef8056b2e396efbc7455b76c8c45d2ce9fc9ca006567af5fb36da121a',
        585512,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'InterTight',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Inter Tight font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Inter+Tight
  static TextTheme interTightTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: interTight(textStyle: textTheme.displayLarge),
      displayMedium: interTight(textStyle: textTheme.displayMedium),
      displaySmall: interTight(textStyle: textTheme.displaySmall),
      headlineLarge: interTight(textStyle: textTheme.headlineLarge),
      headlineMedium: interTight(textStyle: textTheme.headlineMedium),
      headlineSmall: interTight(textStyle: textTheme.headlineSmall),
      titleLarge: interTight(textStyle: textTheme.titleLarge),
      titleMedium: interTight(textStyle: textTheme.titleMedium),
      titleSmall: interTight(textStyle: textTheme.titleSmall),
      bodyLarge: interTight(textStyle: textTheme.bodyLarge),
      bodyMedium: interTight(textStyle: textTheme.bodyMedium),
      bodySmall: interTight(textStyle: textTheme.bodySmall),
      labelLarge: interTight(textStyle: textTheme.labelLarge),
      labelMedium: interTight(textStyle: textTheme.labelMedium),
      labelSmall: interTight(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Irish Grover font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Irish+Grover
  static TextStyle irishGrover({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'c45cde9746bdc3f9c99497d67a5cc07d017351d00e1f1435fce5d56a92011667',
        50660,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'IrishGrover',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Irish Grover font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Irish+Grover
  static TextTheme irishGroverTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: irishGrover(textStyle: textTheme.displayLarge),
      displayMedium: irishGrover(textStyle: textTheme.displayMedium),
      displaySmall: irishGrover(textStyle: textTheme.displaySmall),
      headlineLarge: irishGrover(textStyle: textTheme.headlineLarge),
      headlineMedium: irishGrover(textStyle: textTheme.headlineMedium),
      headlineSmall: irishGrover(textStyle: textTheme.headlineSmall),
      titleLarge: irishGrover(textStyle: textTheme.titleLarge),
      titleMedium: irishGrover(textStyle: textTheme.titleMedium),
      titleSmall: irishGrover(textStyle: textTheme.titleSmall),
      bodyLarge: irishGrover(textStyle: textTheme.bodyLarge),
      bodyMedium: irishGrover(textStyle: textTheme.bodyMedium),
      bodySmall: irishGrover(textStyle: textTheme.bodySmall),
      labelLarge: irishGrover(textStyle: textTheme.labelLarge),
      labelMedium: irishGrover(textStyle: textTheme.labelMedium),
      labelSmall: irishGrover(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Island Moments font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Island+Moments
  static TextStyle islandMoments({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '5723b982bedfec24e6b21580309d97b0871fdbd86b2859aab0a835ef28fa35b6',
        369664,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'IslandMoments',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Island Moments font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Island+Moments
  static TextTheme islandMomentsTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: islandMoments(textStyle: textTheme.displayLarge),
      displayMedium: islandMoments(textStyle: textTheme.displayMedium),
      displaySmall: islandMoments(textStyle: textTheme.displaySmall),
      headlineLarge: islandMoments(textStyle: textTheme.headlineLarge),
      headlineMedium: islandMoments(textStyle: textTheme.headlineMedium),
      headlineSmall: islandMoments(textStyle: textTheme.headlineSmall),
      titleLarge: islandMoments(textStyle: textTheme.titleLarge),
      titleMedium: islandMoments(textStyle: textTheme.titleMedium),
      titleSmall: islandMoments(textStyle: textTheme.titleSmall),
      bodyLarge: islandMoments(textStyle: textTheme.bodyLarge),
      bodyMedium: islandMoments(textStyle: textTheme.bodyMedium),
      bodySmall: islandMoments(textStyle: textTheme.bodySmall),
      labelLarge: islandMoments(textStyle: textTheme.labelLarge),
      labelMedium: islandMoments(textStyle: textTheme.labelMedium),
      labelSmall: islandMoments(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Istok Web font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Istok+Web
  static TextStyle istokWeb({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'da65d0808e72d7f8305f3cdf14854b27fab7eb564a58cb79dcd3e5548e55047e',
        131980,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'cab6e7fce689e3aaaa23f9b7a3198d44f94dcfc3457e7146a0d230a2668fc37b',
        85944,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '76af307f7639549f56107e9930ff08f6abbd8aa008c13562df811ebd202f9ab3',
        90304,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '45a20a7ffb42444f89c5fa1c1d9ca8d0d918903352bca0d084ec52af8ba4a7e0',
        85972,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'IstokWeb',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Istok Web font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Istok+Web
  static TextTheme istokWebTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: istokWeb(textStyle: textTheme.displayLarge),
      displayMedium: istokWeb(textStyle: textTheme.displayMedium),
      displaySmall: istokWeb(textStyle: textTheme.displaySmall),
      headlineLarge: istokWeb(textStyle: textTheme.headlineLarge),
      headlineMedium: istokWeb(textStyle: textTheme.headlineMedium),
      headlineSmall: istokWeb(textStyle: textTheme.headlineSmall),
      titleLarge: istokWeb(textStyle: textTheme.titleLarge),
      titleMedium: istokWeb(textStyle: textTheme.titleMedium),
      titleSmall: istokWeb(textStyle: textTheme.titleSmall),
      bodyLarge: istokWeb(textStyle: textTheme.bodyLarge),
      bodyMedium: istokWeb(textStyle: textTheme.bodyMedium),
      bodySmall: istokWeb(textStyle: textTheme.bodySmall),
      labelLarge: istokWeb(textStyle: textTheme.labelLarge),
      labelMedium: istokWeb(textStyle: textTheme.labelMedium),
      labelSmall: istokWeb(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Italiana font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Italiana
  static TextStyle italiana({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '5bdff8035423ba170564235ef5ca38132c5247496ba27877652d9babe096b2af',
        26660,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Italiana',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Italiana font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Italiana
  static TextTheme italianaTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: italiana(textStyle: textTheme.displayLarge),
      displayMedium: italiana(textStyle: textTheme.displayMedium),
      displaySmall: italiana(textStyle: textTheme.displaySmall),
      headlineLarge: italiana(textStyle: textTheme.headlineLarge),
      headlineMedium: italiana(textStyle: textTheme.headlineMedium),
      headlineSmall: italiana(textStyle: textTheme.headlineSmall),
      titleLarge: italiana(textStyle: textTheme.titleLarge),
      titleMedium: italiana(textStyle: textTheme.titleMedium),
      titleSmall: italiana(textStyle: textTheme.titleSmall),
      bodyLarge: italiana(textStyle: textTheme.bodyLarge),
      bodyMedium: italiana(textStyle: textTheme.bodyMedium),
      bodySmall: italiana(textStyle: textTheme.bodySmall),
      labelLarge: italiana(textStyle: textTheme.labelLarge),
      labelMedium: italiana(textStyle: textTheme.labelMedium),
      labelSmall: italiana(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Italianno font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Italianno
  static TextStyle italianno({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '53b4aedbfd782c2be19b7144790babb5f65c78a9985fcf0533fdab1db1736037',
        92212,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Italianno',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Italianno font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Italianno
  static TextTheme italiannoTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: italianno(textStyle: textTheme.displayLarge),
      displayMedium: italianno(textStyle: textTheme.displayMedium),
      displaySmall: italianno(textStyle: textTheme.displaySmall),
      headlineLarge: italianno(textStyle: textTheme.headlineLarge),
      headlineMedium: italianno(textStyle: textTheme.headlineMedium),
      headlineSmall: italianno(textStyle: textTheme.headlineSmall),
      titleLarge: italianno(textStyle: textTheme.titleLarge),
      titleMedium: italianno(textStyle: textTheme.titleMedium),
      titleSmall: italianno(textStyle: textTheme.titleSmall),
      bodyLarge: italianno(textStyle: textTheme.bodyLarge),
      bodyMedium: italianno(textStyle: textTheme.bodyMedium),
      bodySmall: italianno(textStyle: textTheme.bodySmall),
      labelLarge: italianno(textStyle: textTheme.labelLarge),
      labelMedium: italianno(textStyle: textTheme.labelMedium),
      labelSmall: italianno(textStyle: textTheme.labelSmall),
    );
  }

  /// Applies the Itim font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Itim
  static TextStyle itim({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<ui.Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fonts = <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '8822fb9055096918b3b97c47f55481b7f8b0876adec03de80bd5cbec9d2f6e5a',
        234800,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'Itim',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the Itim font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/Itim
  static TextTheme itimTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: itim(textStyle: textTheme.displayLarge),
      displayMedium: itim(textStyle: textTheme.displayMedium),
      displaySmall: itim(textStyle: textTheme.displaySmall),
      headlineLarge: itim(textStyle: textTheme.headlineLarge),
      headlineMedium: itim(textStyle: textTheme.headlineMedium),
      headlineSmall: itim(textStyle: textTheme.headlineSmall),
      titleLarge: itim(textStyle: textTheme.titleLarge),
      titleMedium: itim(textStyle: textTheme.titleMedium),
      titleSmall: itim(textStyle: textTheme.titleSmall),
      bodyLarge: itim(textStyle: textTheme.bodyLarge),
      bodyMedium: itim(textStyle: textTheme.bodyMedium),
      bodySmall: itim(textStyle: textTheme.bodySmall),
      labelLarge: itim(textStyle: textTheme.labelLarge),
      labelMedium: itim(textStyle: textTheme.labelMedium),
      labelSmall: itim(textStyle: textTheme.labelSmall),
    );
  }
}
