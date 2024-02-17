// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_example/main.dart';

void main() {
  testWidgets('can pop the page after the video plays without crashing',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    // expect current page is home page.
    expect(find.byKey(const Key('home_page')), findsOneWidget);

    // tap the '^' icon and push _PlayerVideoAndPopPage.
    await tester.tap(find.byKey(const Key('push_tab')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('home_page')), findsNothing);
    expect(find.byType(VideoPlayer), findsOneWidget);

    // wait for the video to play end.
    final VideoPlayer videoPlayer =
        find.byType(VideoPlayer).first.evaluate().single.widget as VideoPlayer;
    final Duration videoDuration = videoPlayer.controller.value.duration;
    await tester.pump(videoDuration);

    // expect pop _PlayerVideoAndPopPage.
    expect(find.byKey(const Key('home_page')), findsOneWidget);
  });
}
