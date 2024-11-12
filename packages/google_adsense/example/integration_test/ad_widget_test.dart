// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// TO run the test:
// 1. Run chrome driver with --port=4444
// 2. Run the test from example folder with: flutter drive -d web-server --web-port 7357 --browser-name chrome --driver test_driver/integration_test.dart --target integration_test/ad_widget_test.dart

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_adsense/google_adsense.dart';
import 'package:integration_test/integration_test.dart';
import 'package:web/web.dart' as web;

const String testClient = 'test_client';
const String testSlot = 'test_slot';
late AdSense adsense;

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    adsense = AdSense();
  });

  group('initialization', () {
    testWidgets('Repeated initialization throws error', (WidgetTester _) async {
      adsense.initialize(testClient);
      expect(() => adsense.initialize(testClient), throwsA(isA<StateError>()));
    });

    testWidgets('Initialization adds AdSense snippet to index.html',
        (WidgetTester _) async {
      // Given
      const String expectedScriptUrl =
          'https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-$testClient';

      // When
      adsense.initialize(testClient);

      // Then
      final web.HTMLScriptElement injected =
          web.document.head!.lastChild! as web.HTMLScriptElement;
      expect(injected.src, expectedScriptUrl);
      expect(injected.crossOrigin, 'anonymous');
      expect(injected.async, true);
    });
  });

  group('adWidget', () {
    testWidgets('AdUnitWidget is created and rendered',
        (WidgetTester tester) async {
      // When
      // TODO(sokoloff06): Mock server response

      adsense.initialize(testClient);
      final Widget adUnitWidget =
          adSense.adUnit(AdUnitConfiguration.displayAdUnit(adSlot: testSlot));
      await tester.pumpWidget(adUnitWidget);
      await tester.pumpWidget(
          adUnitWidget); // TODO(sokoloff06): Why only works when pumping twice?
      // Then
      // Widget level
      expect(find.byWidget(adUnitWidget), findsOneWidget);
      expect(adUnitWidget, isA<AdUnitWidget>());

      // DOM level
      final web.HTMLElement? platformView =
          web.document.querySelector('flt-platform-view') as web.HTMLElement?;
      expect(platformView, isNotNull);
      final web.HTMLElement ins =
          platformView!.querySelector('ins')! as web.HTMLElement;
      expect(ins.style.display, 'block');

      // TODO(sokoloff06): Validate response is rendered
    });
  });
}
