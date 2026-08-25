// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: deprecated_member_use

import 'package:cupertino_ui/cupertino_ui.dart' as modern;
import 'package:flutter/cupertino.dart' as legacy;
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CupertinoUiCompatibilityBridge provides mapped CupertinoThemeData properties', (
    WidgetTester tester,
  ) async {
    legacy.CupertinoThemeData? capturedLegacyTheme;

    const modernThemeData = modern.CupertinoThemeData(
      brightness: Brightness.dark,
      primaryColor: Color(0xFF00FF00),
      primaryContrastingColor: Color(0xFFFF0000),
      barBackgroundColor: Color(0xFF111111),
      scaffoldBackgroundColor: Color(0xFF222222),
    );

    await tester.pumpWidget(
      modern.CupertinoApp(
        theme: modernThemeData,
        home: modern.CupertinoUiCompatibilityBridge(
          child: Builder(
            builder: (BuildContext context) {
              capturedLegacyTheme = legacy.CupertinoTheme.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );

    expect(capturedLegacyTheme, isNotNull);
    expect(capturedLegacyTheme!.brightness, modernThemeData.brightness);
    expect(capturedLegacyTheme!.primaryColor, modernThemeData.primaryColor);
    expect(capturedLegacyTheme!.primaryContrastingColor, modernThemeData.primaryContrastingColor);
    expect(capturedLegacyTheme!.barBackgroundColor, modernThemeData.barBackgroundColor);
    expect(capturedLegacyTheme!.scaffoldBackgroundColor, modernThemeData.scaffoldBackgroundColor);
  });

  testWidgets('CupertinoUiCompatibilityBridge maps CupertinoTextThemeData properties', (
    WidgetTester tester,
  ) async {
    legacy.CupertinoThemeData? capturedLegacyTheme;

    const modernTextTheme = modern.CupertinoTextThemeData(
      navTitleTextStyle: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
      actionTextStyle: TextStyle(fontSize: 16.0, color: Color(0xFF123456)),
    );

    const modernThemeData = modern.CupertinoThemeData(textTheme: modernTextTheme);

    await tester.pumpWidget(
      modern.CupertinoApp(
        theme: modernThemeData,
        home: modern.CupertinoUiCompatibilityBridge(
          child: Builder(
            builder: (BuildContext context) {
              capturedLegacyTheme = legacy.CupertinoTheme.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );

    expect(capturedLegacyTheme, isNotNull);
    expect(
      capturedLegacyTheme!.textTheme.navTitleTextStyle.fontSize,
      modernTextTheme.navTitleTextStyle.fontSize,
    );
    expect(
      capturedLegacyTheme!.textTheme.navTitleTextStyle.fontWeight,
      modernTextTheme.navTitleTextStyle.fontWeight,
    );
    expect(
      capturedLegacyTheme!.textTheme.actionTextStyle.color,
      modernTextTheme.actionTextStyle.color,
    );
  });

  testWidgets('CupertinoUiCompatibilityBridge provides CupertinoLocalizations', (
    WidgetTester tester,
  ) async {
    legacy.CupertinoLocalizations? capturedLegacyLocalizations;

    await tester.pumpWidget(
      modern.CupertinoApp(
        home: modern.CupertinoUiCompatibilityBridge(
          child: Builder(
            builder: (BuildContext context) {
              capturedLegacyLocalizations = legacy.CupertinoLocalizations.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );

    expect(capturedLegacyLocalizations, isNotNull);
    expect(capturedLegacyLocalizations!.datePickerDateOrder, isNotNull);
    expect(capturedLegacyLocalizations!.modalBarrierDismissLabel, isNotEmpty);
  });

  testWidgets('CupertinoUiCompatibilityBridge allows rendering legacy Cupertino widgets', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      modern.CupertinoApp(
        home: modern.CupertinoUiCompatibilityBridge(
          child: legacy.CupertinoPageScaffold(
            navigationBar: const legacy.CupertinoNavigationBar(middle: Text('Legacy Title')),
            child: Center(
              child: legacy.CupertinoButton(onPressed: () {}, child: const Text('Legacy Button')),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Legacy Title'), findsOneWidget);
    expect(find.text('Legacy Button'), findsOneWidget);
    expect(find.byType(legacy.CupertinoButton), findsOneWidget);
    expect(find.byType(legacy.CupertinoPageScaffold), findsOneWidget);
  });

  testWidgets('CupertinoUiCompatibilityBridge supports custom delegates', (
    WidgetTester tester,
  ) async {
    legacy.CupertinoLocalizations? capturedLegacyLocalizations;

    await tester.pumpWidget(
      modern.CupertinoApp(
        home: modern.CupertinoUiCompatibilityBridge(
          delegates: const <LocalizationsDelegate<dynamic>>[GlobalCupertinoLocalizations.delegate],
          child: Builder(
            builder: (BuildContext context) {
              capturedLegacyLocalizations = legacy.CupertinoLocalizations.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );

    expect(capturedLegacyLocalizations, isNotNull);
    expect(capturedLegacyLocalizations!.modalBarrierDismissLabel, isNotEmpty);
  });

  testWidgets('CupertinoUiCompatibilityBridge works at root in CupertinoApp.builder', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      modern.CupertinoApp(
        builder: (BuildContext context, Widget? child) {
          return modern.CupertinoUiCompatibilityBridge(child: child!);
        },
        home: modern.CupertinoPageScaffold(
          child: Column(
            children: <Widget>[
              modern.CupertinoButton(onPressed: () {}, child: const Text('Modern Button')),
              legacy.CupertinoButton(onPressed: () {}, child: const Text('Legacy Button')),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Modern Button'), findsOneWidget);
    expect(find.text('Legacy Button'), findsOneWidget);
    expect(find.byType(modern.CupertinoButton), findsOneWidget);
    expect(find.byType(legacy.CupertinoButton), findsOneWidget);
  });
}
