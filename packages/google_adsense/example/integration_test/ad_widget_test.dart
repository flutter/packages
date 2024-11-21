// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// TO run the test:
// 1. Run chrome driver with --port=4444
// 2. Run the test from example folder with: flutter drive -d web-server --web-port 7357 --browser-name chrome --driver test_driver/integration_test.dart --target integration_test/ad_widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// Ensure we don't use the singleton `adSense`, but the local copies to this plugin.
import 'package:google_adsense/google_adsense.dart' hide adSense;
import 'package:integration_test/integration_test.dart';
import 'package:web/web.dart' as web;

import 'test_js_interop.dart';

const String testClient = 'test_client';
const String testSlot = 'test_slot';
const String testScriptUrl =
    'https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-$testClient';

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late AdSense adsense;

  setUp(() async {
    adsense = AdSense();
  });

  tearDown(() {
    clearAdsByGoogleMock();
  });

  group('initialization', () {
    testWidgets('Initialization adds AdSense snippet.', (WidgetTester _) async {
      final web.HTMLElement target = web.HTMLDivElement();
      // Given

      adsense.initialize(testClient, jsLoaderTarget: target);

      final web.HTMLScriptElement? injected =
          target.lastElementChild as web.HTMLScriptElement?;

      expect(injected, isNotNull);
      expect(injected!.src, testScriptUrl);
      expect(injected.crossOrigin, 'anonymous');
      expect(injected.async, true);
    });

    testWidgets('Skips initialization if script already present.',
        (WidgetTester _) async {
      final web.HTMLScriptElement script = web.HTMLScriptElement()
        ..id = 'previously-injected'
        ..src = testScriptUrl;
      final web.HTMLElement target = web.HTMLDivElement()..appendChild(script);

      adsense.initialize(testClient, jsLoaderTarget: target);

      expect(target.childElementCount, 1);
      expect(target.firstElementChild?.id, 'previously-injected');
    });

    testWidgets('Skips initialization if adsense object already present.',
        (WidgetTester _) async {
      final web.HTMLElement target = web.HTMLDivElement();

      // Write an empty noop object
      mockAdsByGoogle(() {});

      adsense.initialize(testClient, jsLoaderTarget: target);

      expect(target.firstElementChild, isNull);
    });
  });

  group('adWidget', () {
    testWidgets('Filled ad units resize widget height',
        (WidgetTester tester) async {
      // When
      mockAdsByGoogle(() {
        // Locate the target element, and push a red div to it...
        final web.Element? adTarget =
            web.document.querySelector('div[id^=adUnit] ins');

        final web.HTMLElement fakeAd = web.HTMLDivElement()
          ..style.width = '320px'
          ..style.height = '137px'
          ..style.background = 'red';

        adTarget!
          ..appendChild(fakeAd)
          ..setAttribute('data-ad-status', AdStatus.FILLED);
      });

      adsense.initialize(testClient);

      final Widget adUnitWidget =
          adsense.adUnit(AdUnitConfiguration.displayAdUnit(adSlot: testSlot));

      await pumpAdWidget(adUnitWidget, tester);

      // Then
      // Widget level
      expect(find.byWidget(adUnitWidget), findsOneWidget);

      final Size size = tester.getSize(find.byWidget(adUnitWidget));

      expect(size.height, 137);
    });

    testWidgets('Unfilled ad units collapse widget height',
        (WidgetTester tester) async {
      // When
      mockAdsByGoogle(() {
        // Locate the target element, and push a red div to it...
        final web.Element? adTarget =
            web.document.querySelector('div[id^=adUnit] ins');

        // The internal styling of the Ad doesn't matter, if AdSense tells us it is UNFILLED.
        final web.HTMLElement fakeAd = web.HTMLDivElement()
          ..style.width = '320px'
          ..style.height = '137px'
          ..style.background = 'red';

        adTarget!
          ..appendChild(fakeAd)
          ..setAttribute('data-ad-status', AdStatus.UNFILLED);
      });

      adsense.initialize(testClient);
      final Widget adUnitWidget =
          adsense.adUnit(AdUnitConfiguration.displayAdUnit(adSlot: testSlot));

      await pumpAdWidget(adUnitWidget, tester);

      // Then
      // Widget level
      expect(find.byWidget(adUnitWidget), findsOneWidget);

      final Size size = tester.getSize(find.byWidget(adUnitWidget));

      expect(size.height, 0);
    });
  });
}

// Pumps an AdUnit Widget into a given tester, with some parameters
Future<void> pumpAdWidget(Widget adUnit, WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: adUnit,
        ),
      ),
    ),
  );

  // This extra pump is needed for the platform view to actually render in the DOM.
  await tester.pump();

  // This extra pump is needed to simulate the async behavior of the adsense JS mock.
  await tester.pumpAndSettle();
}
