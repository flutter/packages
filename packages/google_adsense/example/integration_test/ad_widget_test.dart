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
    test('Repeated initialization throws error', () {
      adsense.initialize(testClient);
      expect(() => adsense.initialize(testClient), throwsA(isA<StateError>()));
    });

    test('Initialization adds AdSense snippet to index.html', () {
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
      // TODO(sokoloff06): Mock server response as ./test_ad.html

      adsense.initialize(testClient);
      final Widget adUnitWidget = adsense.adUnit(adSlot: testSlot);
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
  test('Widget-level client id overrides initialization client id', () {
    // Given
    const String initClient = 'client1';
    const String widgetClient = 'client2';

    // When
    adsense.initialize(initClient);
    final AdUnitWidget adUnitWidget1 =
        adsense.adUnit(adSlot: testSlot, adClient: widgetClient);
    final AdUnitWidget adUnitWidget2 = adsense.adUnit(adSlot: testSlot);

    // Then
    expect(adUnitWidget1.adClient, widgetClient);
    expect(adUnitWidget2.adClient, initClient);
  });
}
