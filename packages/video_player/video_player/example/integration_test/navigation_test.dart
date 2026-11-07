// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_example/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('repeated stopped-player notifications pop only the video route', (
    WidgetTester tester,
  ) async {
    app.main();
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey<String>('push_tab')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    for (var attempt = 0; attempt < 50 && find.byType(VideoPlayer).evaluate().isEmpty; attempt++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    final VideoPlayer player = tester.widget<VideoPlayer>(find.byType(VideoPlayer).last);
    final VideoPlayerController controller = player.controller;
    expect(controller.value.isPlaying, isTrue);

    // Keep these notifications in one frame; pumping between them hides
    // route-removal reentrancy.
    controller.value = controller.value.copyWith(isPlaying: false);
    controller.value = controller.value.copyWith(
      position: controller.value.duration,
      isCompleted: true,
    );
    controller.value = controller.value.copyWith(volume: 0);

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.takeException(), isNull);

    final Finder home = find.byKey(const ValueKey<String>('home_page'));
    expect(home, findsOneWidget);
    expect(Navigator.of(tester.element(home)).canPop(), isFalse);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('natural playback completion returns to the home route', (WidgetTester tester) async {
    app.main();
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey<String>('push_tab')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    final Finder home = find.byKey(const ValueKey<String>('home_page'));
    expect(home, findsNothing);
    for (var attempt = 0; attempt < 120 && home.evaluate().isEmpty; attempt++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.takeException(), isNull);
    expect(home, findsOneWidget);
    expect(Navigator.of(tester.element(home)).canPop(), isFalse);
    await tester.pumpWidget(const SizedBox());
  });
}
