// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:video_player/video_player.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('dispose completes after initialize fails', (WidgetTester tester) async {
    final controller = VideoPlayerController.asset('assets/does_not_exist.mp4');

    await expectLater(controller.initialize(), throwsA(isA<PlatformException>()));

    // Without a timeout a regression would hang the test instead of failing it.
    await controller.dispose().timeout(const Duration(seconds: 10));
  });
}
