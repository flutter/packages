// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart' as legacy;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' as modern;

void main() {
  testWidgets('MaterialUiCompatibilityBridge provides mapped ColorScheme properties', (
    WidgetTester tester,
  ) async {
    legacy.ThemeData? capturedLegacyTheme;

    const modernColorScheme = modern.ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF112233),
      onPrimary: Color(0xFF445566),
      primaryContainer: Color(0xFF778899),
      onPrimaryContainer: Color(0xFFAABBCC),
      secondary: Color(0xFFDDEEFF),
      onSecondary: Color(0xFF123456),
      secondaryContainer: Color(0xFF654321),
      onSecondaryContainer: Color(0xFF001122),
      tertiary: Color(0xFF334455),
      onTertiary: Color(0xFF667788),
      tertiaryContainer: Color(0xFF99AABB),
      onTertiaryContainer: Color(0xFFCCDDEE),
      error: Color(0xFFFF0000),
      onError: Color(0xFFFFFFFF),
      errorContainer: Color(0xFF880000),
      onErrorContainer: Color(0xFFFF8888),
      surface: Color(0xFF101010),
      onSurface: Color(0xFFEEEEEE),
      surfaceDim: Color(0xFF050505),
      surfaceBright: Color(0xFF202020),
      surfaceContainerLowest: Color(0xFF000000),
      surfaceContainerLow: Color(0xFF0A0A0A),
      surfaceContainer: Color(0xFF151515),
      surfaceContainerHigh: Color(0xFF1F1F1F),
      surfaceContainerHighest: Color(0xFF282828),
      onSurfaceVariant: Color(0xFFCCCCCC),
      outline: Color(0xFF777777),
      outlineVariant: Color(0xFF444444),
      shadow: Color(0xFF000001),
      scrim: Color(0xFF000002),
      inverseSurface: Color(0xFFE0E0E0),
      onInverseSurface: Color(0xFF1F1F1F),
      inversePrimary: Color(0xFF90CAF9),
      surfaceTint: Color(0xFF112233),
    );

    final modernThemeData = modern.ThemeData(colorScheme: modernColorScheme);

    await tester.pumpWidget(
      modern.MaterialApp(
        theme: modernThemeData,
        home: modern.MaterialUiCompatibilityBridge(
          child: Builder(
            builder: (BuildContext context) {
              capturedLegacyTheme = legacy.Theme.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );

    expect(capturedLegacyTheme, isNotNull);
    expect(capturedLegacyTheme!.colorScheme.brightness, modernColorScheme.brightness);
    expect(capturedLegacyTheme!.colorScheme.primary, modernColorScheme.primary);
    expect(capturedLegacyTheme!.colorScheme.onPrimary, modernColorScheme.onPrimary);
    expect(capturedLegacyTheme!.colorScheme.secondary, modernColorScheme.secondary);
    expect(capturedLegacyTheme!.colorScheme.tertiary, modernColorScheme.tertiary);
    expect(capturedLegacyTheme!.colorScheme.error, modernColorScheme.error);
    expect(capturedLegacyTheme!.colorScheme.surface, modernColorScheme.surface);
    expect(capturedLegacyTheme!.colorScheme.onSurface, modernColorScheme.onSurface);
    expect(capturedLegacyTheme!.colorScheme.outline, modernColorScheme.outline);
    expect(capturedLegacyTheme!.colorScheme.shadow, modernColorScheme.shadow);
    expect(capturedLegacyTheme!.colorScheme.scrim, modernColorScheme.scrim);
  });

  testWidgets('MaterialUiCompatibilityBridge maps platform and visualDensity properties', (
    WidgetTester tester,
  ) async {
    legacy.ThemeData? capturedLegacyTheme;

    final modernThemeData = modern.ThemeData(
      platform: TargetPlatform.iOS,
      visualDensity: modern.VisualDensity.compact,
    );

    await tester.pumpWidget(
      modern.MaterialApp(
        theme: modernThemeData,
        home: modern.MaterialUiCompatibilityBridge(
          child: Builder(
            builder: (BuildContext context) {
              capturedLegacyTheme = legacy.Theme.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );

    expect(capturedLegacyTheme, isNotNull);
    expect(capturedLegacyTheme!.platform, modernThemeData.platform);
    expect(capturedLegacyTheme!.visualDensity.horizontal, modernThemeData.visualDensity.horizontal);
    expect(capturedLegacyTheme!.visualDensity.vertical, modernThemeData.visualDensity.vertical);
  });

  testWidgets('MaterialUiCompatibilityBridge maps TextTheme properties', (
    WidgetTester tester,
  ) async {
    legacy.ThemeData? capturedLegacyTheme;

    const modernTextTheme = modern.TextTheme(
      displayLarge: TextStyle(fontSize: 57.0, fontWeight: FontWeight.w400),
      headlineMedium: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(fontSize: 16.0, color: Color(0xFF123456)),
      labelSmall: TextStyle(fontSize: 11.0, letterSpacing: 0.5),
    );

    final modernThemeData = modern.ThemeData(textTheme: modernTextTheme);

    await tester.pumpWidget(
      modern.MaterialApp(
        theme: modernThemeData,
        home: modern.MaterialUiCompatibilityBridge(
          child: Builder(
            builder: (BuildContext context) {
              capturedLegacyTheme = legacy.Theme.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );

    expect(capturedLegacyTheme, isNotNull);
    expect(
      capturedLegacyTheme!.textTheme.displayLarge?.fontSize,
      modernTextTheme.displayLarge?.fontSize,
    );
    expect(
      capturedLegacyTheme!.textTheme.headlineMedium?.fontSize,
      modernTextTheme.headlineMedium?.fontSize,
    );
    expect(
      capturedLegacyTheme!.textTheme.headlineMedium?.fontWeight,
      modernTextTheme.headlineMedium?.fontWeight,
    );
    expect(
      capturedLegacyTheme!.textTheme.titleLarge?.fontSize,
      modernTextTheme.titleLarge?.fontSize,
    );
    expect(capturedLegacyTheme!.textTheme.bodyLarge?.color, modernTextTheme.bodyLarge?.color);
    expect(
      capturedLegacyTheme!.textTheme.labelSmall?.fontSize,
      modernTextTheme.labelSmall?.fontSize,
    );
  });

  testWidgets('MaterialUiCompatibilityBridge provides MaterialLocalizations for custom locales', (
    WidgetTester tester,
  ) async {
    legacy.MaterialLocalizations? capturedLegacyLocalizations;

    await tester.pumpWidget(
      modern.MaterialApp(
        locale: const Locale('es', 'ES'),
        localizationsDelegates: modern.GlobalMaterialLocalizations.delegates,
        supportedLocales: const <Locale>[Locale('en', 'US'), Locale('es', 'ES')],
        home: modern.MaterialUiCompatibilityBridge(
          child: Builder(
            builder: (BuildContext context) {
              capturedLegacyLocalizations = legacy.MaterialLocalizations.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );

    expect(capturedLegacyLocalizations, isNotNull);
    expect(capturedLegacyLocalizations!.okButtonLabel, 'ACEPTAR');
    expect(capturedLegacyLocalizations!.cancelButtonLabel, 'Cancelar');
  });

  testWidgets('MaterialUiCompatibilityBridge allows rendering legacy Material widgets', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      modern.MaterialApp(
        home: modern.MaterialUiCompatibilityBridge(
          child: legacy.Scaffold(
            appBar: legacy.AppBar(title: const Text('Legacy Title')),
            body: Center(
              child: legacy.ElevatedButton(onPressed: () {}, child: const Text('Legacy Button')),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Legacy Title'), findsOneWidget);
    expect(find.text('Legacy Button'), findsOneWidget);
    expect(find.byType(legacy.ElevatedButton), findsOneWidget);
    expect(find.byType(legacy.Scaffold), findsOneWidget);
  });

  testWidgets('MaterialUiCompatibilityBridge supports custom delegates', (
    WidgetTester tester,
  ) async {
    legacy.MaterialLocalizations? capturedLegacyLocalizations;

    await tester.pumpWidget(
      modern.MaterialApp(
        home: modern.MaterialUiCompatibilityBridge(
          delegates: const <LocalizationsDelegate<dynamic>>[
            legacy.DefaultMaterialLocalizations.delegate,
          ],
          child: Builder(
            builder: (BuildContext context) {
              capturedLegacyLocalizations = legacy.MaterialLocalizations.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );

    expect(capturedLegacyLocalizations, isNotNull);
    expect(capturedLegacyLocalizations!.okButtonLabel, isNotEmpty);
  });

  testWidgets('MaterialUiCompatibilityBridge works at root in MaterialApp.builder', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      modern.MaterialApp(
        builder: (BuildContext context, Widget? child) {
          return modern.MaterialUiCompatibilityBridge(child: child!);
        },
        home: modern.Scaffold(
          body: Column(
            children: <Widget>[
              modern.ElevatedButton(onPressed: () {}, child: const Text('Modern Button')),
              legacy.ElevatedButton(onPressed: () {}, child: const Text('Legacy Button')),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Modern Button'), findsOneWidget);
    expect(find.text('Legacy Button'), findsOneWidget);
    expect(find.byType(modern.ElevatedButton), findsOneWidget);
    expect(find.byType(legacy.ElevatedButton), findsOneWidget);
  });
}
