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
        'ecaa6ed03cb81aa3f8f880b3277fa3b4d5eb7cf239fe43391c952eef859f6c8b',
        119076,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w100,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '4c77f3deb0a85c25fcf826564d0d0dd59779d47de4771f1effb1c560fc6eff18',
        128656,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '3c2480dd85b532919e6f2ebac785575c9b04374bc826da8ab6ff2dc916d84472',
        122020,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'c65af8ef8a42d005bd00ac9a313ac8ba477549ec0a2c3aeeda93a990eaa7a51f',
        131308,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '642a20fc2d2d13f7d88d7723a39ea9b4aa85d127e6280acb14910d70df971666',
        121924,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '0ef865189d47b2f42f379db6b778d7b9ceb8e84f72c9ddd60bff10493b823a62',
        130860,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '075e6118452d96b7885561e874425e99987243c040df7f6bc8d4d4999c5a4f2c',
        120340,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'b4d765b347d00906192da0c67400fa3c0be43de230facc763cf0a29b6b382dfa',
        128476,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'b57cd7eed0b12d7a8f9242acb5507b7f9e51fe58ed7d0222493cb987c7e58fae',
        121932,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '17359399d89384e2d89ce1f37a607c6e80621596d30edfdfd92efb7213114cc9',
        130556,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '3f31f30a0d4601ed4b3e0715294eca84276e308cfb39aefcdd31acba96135c60',
        121732,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '2474f0a52234a01e85cd556fc2bcc1f10056a1d6eb1c4f3b57642a3ed0a3f004',
        130640,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '22d9094b915bab632e8f5f38c53b2a1886dfc7fd232bdf876067a5a62313b669',
        120132,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '2f1332cbf784d6ecb45db4e4bf0dac8ea63fd501f2dff087d98dac67b2fb773b',
        128732,
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
        '7986712be7e517deeea8e65dfcaa3c573925efa8cbb077d959e6cb22fcebad51',
        160040,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'e686cb38a1a206d64a945a5a15749a948c991b15e0adeddaae5b315cf4b1646a',
        161180,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'ee737a0180f9cdbfe9edce5cd2cc32840efe82178d3a4cc05f2c6f088558708b',
        161140,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'd5cf8fb8cf46567940400f93c9835d59225bce9745e4fb75915ed52d96041032',
        159400,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '55c3c36487c44b975a7a2c8839da2d983826c51742dcd77a1dffe0245eb4621f',
        164252,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'f25f975695c8b5dd3932d0307ed9fff200f64aee4f11a5a1005b71daa3b7d1ca',
        164372,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'b4df5f9a0306b37b9028cb36a8ec03de3e99a875ef041d0d319a8582f45bd9ca',
        163120,
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

  /// Applies the IBM Plex Sans Condensed font family from Google Fonts to the
  /// given [textStyle].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/IBM+Plex+Sans+Condensed
  static TextStyle ibmPlexSansCondensed({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
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
        '4359701d356037f60781732846a6c0c54e5376fca44feeee679b900b2cf24b6a',
        67556,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w100,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '72b9515bec967e45053fd58213e07c7e9bb056682bcc5efa46639e9002e0437a',
        72412,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '0a169b657937ba25550b3e5637cc978f130ede89db4d70e7042d8ed493337539',
        68084,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '8c42c57cb2e7a462c7c0eb0389164d5948836e5f2faefc6873f1b716bc2452c6',
        72872,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '125b3aa9887aacfa5c9e77d1dc1707524d51957aee431a9bec86daf8ef99c0a5',
        67544,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '30039787e59257bd60be700da04b2c0c31ef3e8c55285d9d44c31a69bf560004',
        72152,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '004230c8f1be169fbafda5423e3cdedf29ba98cd89b839151e6e8679ccdc434e',
        67272,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'cf695514e3bc921bc350bcc0760ba3a186071468a5466de495cb0d5422da36b0',
        72308,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '54b77f0c7f57a3fdb26116ff7b30843da116ce1f491d7b0a3eb56a3e50a6f3dc',
        67048,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'e5aedd1f42ca89c09b388bfefca57178ccb6b30aa143de54416f519d0323e379',
        71508,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'f2dd1f2ef0c68ca0bcae08c0aff1482ec9ad755cc469863967bfa95b7503d94e',
        67116,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '5a766054bc9c7ccf74de1aec104cb6090f02531743b8a7b25b263765e90d716f',
        71672,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'd3a3f89eadde3fccb18cf4841062fdf3cc3d9cf2aa5c927c86232980390d5a5b',
        66772,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '8f6e90cd159146c6edf1138dab20301af83f899b6bb9c8b3ade9f553e4560675',
        72184,
      ),
    };

    return googleFontsTextStyle(
      textStyle: textStyle,
      fontFamily: 'IBMPlexSansCondensed',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fonts: fonts,
    );
  }

  /// Applies the IBM Plex Sans Condensed font family from Google Fonts to every
  /// [TextStyle] in the given [textTheme].
  ///
  /// See:
  ///  * https://fonts.google.com/specimen/IBM+Plex+Sans+Condensed
  static TextTheme ibmPlexSansCondensedTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: ibmPlexSansCondensed(textStyle: textTheme.displayLarge),
      displayMedium: ibmPlexSansCondensed(textStyle: textTheme.displayMedium),
      displaySmall: ibmPlexSansCondensed(textStyle: textTheme.displaySmall),
      headlineLarge: ibmPlexSansCondensed(textStyle: textTheme.headlineLarge),
      headlineMedium: ibmPlexSansCondensed(textStyle: textTheme.headlineMedium),
      headlineSmall: ibmPlexSansCondensed(textStyle: textTheme.headlineSmall),
      titleLarge: ibmPlexSansCondensed(textStyle: textTheme.titleLarge),
      titleMedium: ibmPlexSansCondensed(textStyle: textTheme.titleMedium),
      titleSmall: ibmPlexSansCondensed(textStyle: textTheme.titleSmall),
      bodyLarge: ibmPlexSansCondensed(textStyle: textTheme.bodyLarge),
      bodyMedium: ibmPlexSansCondensed(textStyle: textTheme.bodyMedium),
      bodySmall: ibmPlexSansCondensed(textStyle: textTheme.bodySmall),
      labelLarge: ibmPlexSansCondensed(textStyle: textTheme.labelLarge),
      labelMedium: ibmPlexSansCondensed(textStyle: textTheme.labelMedium),
      labelSmall: ibmPlexSansCondensed(textStyle: textTheme.labelSmall),
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
        '347e76cc83e6870928dff6d04b934c1de1e87c616c70bcfa19477f36ca86368c',
        2189016,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'e2596e41b9d430673ac8d9650d9a85cc3ae17f0c69c7cd117f8211b18aaaaf28',
        2184072,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '2f45178fd20d19da0154ed946ade6dc6088dacb39fb453c7532ef5d047ba06bb',
        2177180,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '1852fd36dddabd488837a1181b0ccbb4ec5e1f697ba4088350c3899296da9469',
        2168316,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '499bba63b3091080e3af59007c7025fad6377d407c9f7154154bfbb3c458f757',
        2161896,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '5ae4ac075bfefac5edb0ff77ae50da637ace57762ef75c36427a31123189035b',
        2161420,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '0ec4f3596120c7517e951a7a5c4cc35f6fc9841d308f0420926d4b48ae62afd4',
        2163308,
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
        'dfb1aca4cb90b9768ef7ca4f9f8a769ea2949a597a6fe7a56d262a11e193384f',
        67408,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '9d20b0e657d2002a7533b0e8b1e905df01d6bca9d4e2d28f64b3997e02fcfe62',
        67492,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'fa1426a5315126c702525f0ff976126c086424fe738a11540bd655e50027c59c',
        67216,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '5e50785098eda6dc33ffaa4f6b3699dc50e13e1933f138b1691f8d5dbfdb6e7e',
        66592,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '29cca781e0847077407969f6e1a4a8ca2aa512b54e0eb9d8c854bbd38aa56df8',
        66736,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'c83e53239ee290a93f52bddf2f5b7ece9f2ae7515c2acee55b0893873adcaf84',
        66628,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '7edbc7a7d2c2ce0bc1b1caf6d497432bd7067fb06fba58b479a762b64e9bf939',
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
        '50bdbbe25c5caf824ed67474b3974dd13243f9236b1a397c703f4ea77e98f400',
        74032,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'b47fe23ace58f613373a60fadbbf7b04b6bdf4e5af5d360dc6e5011285673190',
        74012,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '0eec28cb97882fe9eda04710afac100681b446877fdfa40e4be939fff418282d',
        73480,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '68e7e1679d0c01df7e0701934cc907127417472c07dcee8bb0116e834fe6c496',
        72772,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '72643d026742c9d25bd6200abaeca0179dfa1c821201e57baddb608b0d0da7b1',
        72656,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'd26cad6edcbc5fce4fff2aa83b97769c3fc8b8e38e3dcbbf30d94c8cfbd4fa82',
        72416,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'ea7dcba70e4410e01e8f9c9e39d69d9b44618ef3411f5287821cf693ef102dde',
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
        'fe40ddc3bef548913ec825335e48fca70dfcc5883b7d4d1d7e974ee5b9a9851d',
        104900,
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
        '2bb1c4e2df79f3ce5912a4cc064fd07372f7ba7290f501296392d3d85750e5af',
        54900,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '0a8bbdfcc79d37371f4ab901886b8c4607ff11d3e52601c202355d03e42206a6',
        54908,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '4bf692aaba03b79077df7d951e2678c00ad5562caa89d87b82cd087d9be3f5af',
        54960,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'bb79240c20a7c66682c6ad589090801f37c19d036997076c67b13c81d7ad2ed4',
        54864,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '5982d9a28ebc2215a2f4b0fd9cbbbb94960dd036b1d97504205062ccb7ff0b3c',
        59332,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '0adb1d7a1c7b9ba9c58a6ab73f8540e05d02c2c970613c358d77682428d26f04',
        59460,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '820217cd6d690220ce3a13828d215e510d765191e67aba8a960bc2cba25a6aae',
        59528,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '45030721016c97ad1404cb439696e949c00d7f47b41e5603c44ad8bb2f3eefa9',
        59396,
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
        '152ab0b0e09faf97853a3d2c77132720284d29774a37a518148e7031366fd5d9',
        65224,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '6f0ca23b486b8b4af6f1bfe2f664fe4dd8ecedf41f254cc632adf66036ac383c',
        65520,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '4885969808dc3a9af4d6db6251bd239764d5304b35f298608d6b688b12cea1e6',
        65496,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '9995cbd86623cf9e523f0fdcd5f0a051931957c4cc3fed6da1bf0ad399e861bb',
        65580,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'bebbe00575a9cf5a6d8bf9725b6f2d91535c49023aa22e9831f023169e9963b1',
        65604,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '56b19105727ac155ddaa8ad9d5306925f6d1ea58ed0a4f677e646cf6af3ce36c',
        65696,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'fbcf8cec04982972e95fc38276d49b13a53e4d749ed3eb64f1d38812b9803f6c',
        65684,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '4dfa8fb7022dbf3e2cbe030abd6f31e226eea94a53dedc38588a758e026a1160',
        65808,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'eacf138d3f8a9e77ca737fe0552a9130184fb87ccc6aa6ce5de7703e7b7c2f29',
        65728,
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
        'c8c35689e7da0390f7892b9b578e9dd7e737eba68a57745b7dec9590c2a4bbbb',
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
        '2b12b2f84e426c99ea3fc2a4568ba81130fdc0b470de1566513db1fab5ee661c',
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
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '7aa6019906d07d02c7f71f1307a8c7bd601516a4794aa025f027fddf4205782b',
        36488,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '79636edb63cebb44381c35b98ddff9f940999a748245dc430faed3349baae8b1',
        37480,
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
        '75fdc42f4b86c6d05162e0e696074bc77f9483b6136637637644f3fa3cf647e8',
        73192,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '0f45eeccbaf7f0c29b8decd0e05b34ea1eccc3ba686c5c563a540d77a6ed012d',
        73032,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'a1f4f07a80e06b8d443f98b1d8cc653f75b27b5d5c5bcf773cb6790d7b73e8cb',
        72952,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '245ae08ab2f07f2789a46f10c512fc6db151a76f26e6a341ff53605717348dea',
        73388,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '593fb1a1d05659186300abc08b2c18161dac9440f2983722a528ab4bedd72530',
        73464,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '60baca380586ff95b011b91504775224feb9aa9bbcb62680fc7374c56b1abebe',
        73336,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'e6e5ea43bbf9375c14b26b42b92d674da01e809f47252e61d32ce15990b6cd87',
        73328,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '6cba238908373216d2731979369acb06cf14feadacc7e9f382086c58d8f07309',
        73120,
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
        'e991130356878de98d6707a19fbded1555b30eefb700440a445c57aabbf790d2',
        28000,
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
        '6bf9797e07322cbcafbb33edf113185451cf4daec1552e3331ed5bc8ad8bf044',
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
        '71c44dfecd32bbaa791b856c26e1f513fb4d5c925712f7d144b692b82dac75a2',
        37800,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'bedbee7e0198c60b09744b028a4407a44fd728f6cd3079e5634a4f7b30380ea3',
        36420,
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
        'ebbb17d0741a22f37a01f533d6231db00970f848658f0f2ce93ddc151c5f5b3c',
        229548,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '2deb09e19dbbfc34f5ea7a1df67dd819d7138d6f6a120e555289fba2746bfeda',
        226832,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '3c21de761a5e8ee0e07f9c6d2faafe85878a8b5965856de5739255948e21ac96',
        227704,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '9dba2c3e8a36d3230ac472f6671e90fd91bb77defefcc06327739186aded9320',
        227144,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '9614587bbc947d5e83b76dc2c94bb6473dfc46dfc6a4ae089d00235138048eff',
        224768,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '18256a9ed0e7ece18e69d6e7586ff3e0e12e372165d247fdaaf362785268df90',
        223676,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'fb0902f2cebc26f885f99fed7cd05d4148cdea23dedddddeb311718a74d98584',
        218780,
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
        'cde1f8ad95bce7e280a8181962a591b19eae25aa112a49941fb742b35d6a63eb',
        45920,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '635f6c99b5b9ec837159116b1ae4622f058c5ac802f574cc66a722b3cfda4314',
        47260,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'ad4dff80b3c9aa3ddcec56999ff333ed78bb655e19e27c7fb0c12dd523aa0925',
        46132,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '09545336cb17a99dd7f0803abfcfe216ed29d40467c5fa0c35a11ba4e6983c20',
        47484,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'd89af4341528ca47d9794ba55d2a627e2e8074c770e6177ff8f47d706f16b81a',
        45488,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'a69eda1c24b46ea6394e18c9e2af9b726f4382ca481cceced0f480eefe86d183',
        47144,
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
        '44e5076a51f0135f9babc4ad5932c0eaaec8adbccabe8f60daa581274e5aaf05',
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
        'd9b3720945df7191cc1b66c47a3d6b3276bf7f88bb2a7d7a214759d74f8c9773',
        48592,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '6b4c38fed862692cc5efa1286a1387baf15bc2787b930c8fd4bdbe26f0712091',
        48708,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '3e68decf51bcdcaa4c61342bae723ffda7e53aa043bd5dd8a763ba1588b370e6',
        48708,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'd863d4b453122cf2a6fec5697d9f715c5e2ab8d0ea0b652b98e3f7d054b2a270',
        48528,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '2553618409f356d0e5c8729917ae169cee7a757f4891ed3cd8746a258779dda7',
        50020,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'f6d785a7b5b7fa6bc79cdc5a826508d2ffaabb659b099f8bee28f77d6f0d9e7c',
        50204,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '3428096a2edde9fe23d7366c84c60b203c6dbdaf8824f4acf70e56bf68cc49f2',
        50168,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'aebc0ccd983222ecb1e975f2f090d89efe2784cc62fd79a69ca47d7c197f6df6',
        50028,
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
        '309aadf6d6254529fbfb5451b0905820ca2f4b9eccbb58fefcc161ae51020c72',
        48340,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '32a9b6b7a0dca68f7b51471c7e145fac9286b71a4ce9ec8fb720542e18bc1046',
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
        '19eb90a3227963d8c124046ae8af15e44fecb8736a27b4ab7092e81251addb6a',
        304132,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '590cd28bff41a00881b08db47d628291d96c50084f2710c9400c57c39cd2e4eb',
        304392,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '2e9b3d490cbe065fcdc783c1c6220b6f2ce5f1b1c5b81b0c8a9f8b4f27519257',
        303984,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'ecdb53099b1a68cd24c6900ea5beeafec81bd3c8cb9d0f3c51b9986583ba3982',
        303384,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '492dec3bc33255f9d81bd5fb18704ad72f96f9b9318e4171bc9f9be9dd4bf44b',
        308288,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'd7ba633bab7f40576e539a7e934a1301d7618dceea59c743de477c2c493462fc',
        309376,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'b7e339223d56e8c4210c86f1ba87b3d43d6c47e03956ea56f0a7a938ae61b2a3',
        309732,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '06fb8b97ad04af6b7fa9f2fb17d3763d28f6694f777f33dcf147e84c55a4e81a',
        310348,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '7485a755eabadd6c1b38664e848793fd919674ab8d09c25e9347e93bea9a7177',
        310000,
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
        'e7ffae93eaccdc071f195b2ee0e003519a551c80449ad508aca0bb3262b7d260',
        298728,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '404cf43ed675c94c12ca0699a8b0e8132d2568f0b0e6447947b2791baebb0f48',
        299044,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'dc26a04f1025b93c048c01a4b68c4926d1fffb5fffd33942d77449cb305f0b09',
        298696,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'd09b8f0d43ec915a1e498032fe7aaf881398894d747b4cefa2f4c0fea9daaf3d',
        298236,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'af87cb250f2aa0ef59ab6d84897bc1e14bee4e226ec367c6535a041aacbd406d',
        301448,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '762c775d505b2500346fddfcfbe912b4579d39a2df74f04fd226312ec04ba200',
        302188,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        'a6d3bb37d0a595f5452ae34e774865633a53e265c0f6b40f64721624d3adebe3',
        302784,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '309f9d518f9c443c9cbc3dd7998a1a90a1abc410e7176c702af930c11739822e',
        303844,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.normal,
      ): GoogleFontsFile(
        '2853ea2d892129f4b1a67469a6af18366ac29593869ff9f69d25040a2ae8c76f',
        303784,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w100,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'fb9f9ac062a81d3cac85c01b1bb487cfa5507e2262cbc5a733b2715fd92463b6',
        305140,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w200,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '859cd2f288b5684574a734c9895ddee44054ac2715a15a9c53efce6e75093e3e',
        305556,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'b2d9ecff15709212f28bd20cb559e50c48c109f6c29e95d4a0f9fe4eedc6ae2d',
        305296,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '62f4cb24f7ab7b7c7cc0ca1f4a95fba2ed250cdfaf876ae38775665520f49eec',
        304804,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '9ca4501d9026eeb3c07be5406abc88b977284d878d950bde86c29534b07f60ee',
        308056,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        'ecda800d7ce1b631d4ea4849fdd81fbddc65bfd62a418299a445547b37022bdc',
        308804,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '7f023f29f1d58cebb35de1435d6f33e54f02eca55aae26aadf115dd7c48313cd',
        309304,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '7fcc6ee52df53e0841a9153389e0b081cfb2028d034465f2fa379471d31fde7e',
        310196,
      ),
      const GoogleFontsVariant(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.italic,
      ): GoogleFontsFile(
        '14b1c39436da679c716b75839ece03b556254f651b43a0f78c19accde940b83e',
        310204,
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
        'ce682de681dd1cee15d9131306cec648aca501a02c8734e5d2d0e01d31590300',
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
        'a58fcfd40475c80662ec898030aa0e00d422067ec4d3bd8272fc2bf6799363dd',
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
