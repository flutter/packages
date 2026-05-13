// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs, unreachable_from_main

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

List<Widget> textStyleExamples(BuildContext context) {
  return <Widget>[
    // #docregion StaticFont
    Text('This is Google Fonts', style: GoogleFonts.lato()),
    // #enddocregion StaticFont
    // #docregion DynamicFont
    Text('This is Google Fonts', style: GoogleFonts.getFont('Lato')),
    // #enddocregion DynamicFont
    // #docregion ExistingStyle
    Text(
      'This is Google Fonts',
      style: GoogleFonts.lato(
        textStyle: const TextStyle(color: Colors.blue, letterSpacing: .5),
      ),
    ),
    // #enddocregion ExistingStyle
    // #docregion ExistingThemeStyle
    Text(
      'This is Google Fonts',
      style: GoogleFonts.lato(
        textStyle: Theme.of(context).textTheme.headlineMedium,
      ),
    ),
    // #enddocregion ExistingThemeStyle
    // #docregion ExistingStyleWithOverrides
    Text(
      'This is Google Fonts',
      style: GoogleFonts.lato(
        textStyle: Theme.of(context).textTheme.displayLarge,
        fontSize: 48,
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
      ),
    ),
    // #enddocregion ExistingStyleWithOverrides
  ];
}

Map<FontWeight, String> fontWeightMapping() {
  return
  // #docregion FontWeightMap
  <FontWeight, String>{
    FontWeight.w100: 'Thin',
    FontWeight.w200: 'ExtraLight',
    FontWeight.w300: 'Light',
    FontWeight.w400: 'Regular',
    FontWeight.w500: 'Medium',
    FontWeight.w600: 'SemiBold',
    FontWeight.w700: 'Bold',
    FontWeight.w800: 'ExtraBold',
    FontWeight.w900: 'Black',
  };
  // #enddocregion FontWeightMap
}

/// Single-font app theme example.
// #docregion AppThemeSimple
class MyApp extends StatelessWidget {
  // #enddocregion AppThemeSimple
  const MyApp({super.key});

  // #docregion AppThemeSimple
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // #enddocregion AppThemeSimple
      title: 'Example',
      // #docregion AppThemeSimple
      theme: _buildTheme(Brightness.dark),
      // #enddocregion AppThemeSimple
      home: const Text('placeholder'),
      // #docregion AppThemeSimple
    );
  }
}

ThemeData _buildTheme(Brightness brightness) {
  final baseTheme = ThemeData(brightness: brightness);

  return baseTheme.copyWith(
    textTheme: GoogleFonts.latoTextTheme(baseTheme.textTheme),
  );
}
// #enddocregion AppThemeSimple

/// Multi-font app theme example.
class MyMultiFontApp extends StatelessWidget {
  const MyMultiFontApp({super.key});

  @override
  Widget build(BuildContext context) {
    // #docregion AppThemeComplex
    final TextTheme textTheme = Theme.of(context).textTheme;

    return MaterialApp(
      // #enddocregion AppThemeComplex
      title: 'Example',
      // #docregion AppThemeComplex
      theme: ThemeData(
        textTheme: GoogleFonts.latoTextTheme(textTheme).copyWith(
          bodyMedium: GoogleFonts.oswald(textStyle: textTheme.bodyMedium),
        ),
      ),
      // #enddocregion AppThemeComplex
      home: const Text('placeholder'),
      // #docregion AppThemeComplex
    );
    // #enddocregion AppThemeComplex
  }
}

// #docregion LicenseRegistration
void main() {
  LicenseRegistry.addLicense(() async* {
    final String license = await rootBundle.loadString('google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(<String>['google_fonts'], license);
  });

  runApp(const MyApp());
}

// #enddocregion LicenseRegistration
