// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// TO run the test:
// 1. Run chrome driver with --port=4444
// 2. Run the test from example folder with: flutter drive -d web-server --web-port 7357 --browser-name chrome --driver test_driver/integration_test.dart --target integration_test/ad_widget_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:google_adsense/google_adsense.dart';
import 'package:integration_test/integration_test.dart';
import 'package:web/web.dart' as web;

import 'adsense_test_js_interop.dart';

const String testClient = 'test_client';
const String testScriptUrl =
    'https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-$testClient';

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late AdSense adSense;

  setUp(() async {
    adSense = AdSense();
  });

  tearDown(() {
    clearAdsByGoogleMock();
  });

  group('adSense.initialize', () {
    testWidgets('adds AdSense script tag.', (WidgetTester _) async {
      final web.HTMLElement target = web.HTMLDivElement();
      // Given

      await adSense.initialize(testClient, jsLoaderTarget: target);

      final web.HTMLScriptElement? injected =
          target.lastElementChild as web.HTMLScriptElement?;

      expect(injected, isNotNull);
      expect(injected!.src, testScriptUrl);
      expect(injected.crossOrigin, 'anonymous');
      expect(injected.async, true);
    });

    testWidgets('Skips initialization if script is already present.',
        (WidgetTester _) async {
      final web.HTMLScriptElement script = web.HTMLScriptElement()
        ..id = 'previously-injected'
        ..src = testScriptUrl;
      final web.HTMLElement target = web.HTMLDivElement()..appendChild(script);

      await adSense.initialize(testClient, jsLoaderTarget: target);

      expect(target.childElementCount, 1);
      expect(target.firstElementChild?.id, 'previously-injected');
    });

    testWidgets('Skips initialization if adsense object is already present.',
        (WidgetTester _) async {
      final web.HTMLElement target = web.HTMLDivElement();

      // Write an empty noop object
      mockAdsByGoogle(() {});

      await adSense.initialize(testClient, jsLoaderTarget: target);

      expect(target.firstElementChild, isNull);
    });
  });
}
