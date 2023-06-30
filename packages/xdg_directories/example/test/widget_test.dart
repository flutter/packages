// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:example/main.dart';

void main() {
  Map<String, String> envVars = Platform.environment;

  testWidgets('Get config xdg Directory', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our payload starts at ''.
    expect(find.text('empty'), findsOneWidget);

    // Tap one button  and trigger a frame.
    await tester.tap(find.byKey(const Key("getConfigXdgDirectory")));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.textContaining("[Directory: '/etc/xdg/xdg-ubuntu', Directory: '/etc/xdg']"), findsOneWidget);
  });

  testWidgets('Get cache home directory', (WidgetTester tester) async {
    String dirHome = "Directory: '${envVars['HOME'].toString()}/.cache'";
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Tap one button  and trigger a frame.
    await tester.tap(find.byKey(const Key("getCacheHome")));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text(dirHome), findsOneWidget);
  });

testWidgets('Get config directory', (WidgetTester tester) async {
    String config = "Directory: '${envVars['HOME'].toString()}/.config'";
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Tap one button  and trigger a frame.
    await tester.tap(find.byKey(const Key("getConfigHome")));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text(config), findsOneWidget);
  });

  testWidgets('Get user directory name', (WidgetTester tester) async {
    String userDir = "Directory: '${envVars['HOME'].toString()}'";
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Tap one button  and trigger a frame.
    await tester.tap(find.byKey(const Key("getUserDirectoryName")));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text(userDir), findsOneWidget);
  });
}
