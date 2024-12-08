// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// TO run the test:
// 1. Run chrome driver with --port=4444
// 2. Run the test from example folder with: flutter drive -d web-server --web-port 7357 --browser-name chrome --driver test_driver/integration_test.dart --target integration_test/ad_widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// Ensure we don't use the singleton `adSense`, but the local copies to this plugin.
import 'package:google_adsense/experimental/google_adsense.dart' hide adSense;
import 'package:google_adsense/src/ad_unit_widget.dart';
import 'package:integration_test/integration_test.dart';
import 'package:web/web.dart' as web;

import 'test_js_interop.dart';

const String testClient = 'test_client';
const String testSlot = 'test_slot';
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

  group('initialization', () {
    testWidgets('Initialization adds AdSense snippet.', (WidgetTester _) async {
      final web.HTMLElement target = web.HTMLDivElement();
      // Given

      adSense.initialize(testClient, jsLoaderTarget: target);

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

      adSense.initialize(testClient, jsLoaderTarget: target);

      expect(target.childElementCount, 1);
      expect(target.firstElementChild?.id, 'previously-injected');
    });

    testWidgets('Skips initialization if adsense object is already present.',
        (WidgetTester _) async {
      final web.HTMLElement target = web.HTMLDivElement();

      // Write an empty noop object
      mockAdsByGoogle(() {});

      adSense.initialize(testClient, jsLoaderTarget: target);

      expect(target.firstElementChild, isNull);
    });
  });

  group('adWidget', () {
    testWidgets('Responsive (with adFormat) ad units reflow flutter',
        (WidgetTester tester) async {
      // The size of the ad that we're going to "inject"
      const double expectedHeight = 137;

      // When
      mockAdsByGoogle(
        mockAd(
          size: const Size(320, expectedHeight),
        ),
      );

      adSense.initialize(testClient);

      final Widget adUnitWidget = adSense.adUnit(
        AdUnitConfiguration.displayAdUnit(
          adSlot: testSlot,
          adFormat: AdFormat.AUTO, // Important!
        ),
      );

      await pumpAdWidget(adUnitWidget, tester);

      // Then
      // Widget level
      final Finder adUnit = find.byWidget(adUnitWidget);
      expect(adUnit, findsOneWidget);

      final Size size = tester.getSize(adUnit);
      expect(size.height, expectedHeight);
    });

    testWidgets(
        'Fixed size (without adFormat) ad units respect flutter constraints',
        (WidgetTester tester) async {
      const double maxHeight = 100;
      const BoxConstraints constraints = BoxConstraints(maxHeight: maxHeight);

      // When
      mockAdsByGoogle(
        mockAd(
          size: const Size(320, 157),
        ),
      );

      adSense.initialize(testClient);

      final Widget adUnitWidget = adSense.adUnit(
        AdUnitConfiguration.displayAdUnit(
          adSlot: testSlot,
        ),
      );

      final Widget constrainedAd = Container(
        constraints: constraints,
        child: adUnitWidget,
      );

      await pumpAdWidget(constrainedAd, tester);

      // Then
      // Widget level
      final Finder adUnit = find.byWidget(adUnitWidget);
      expect(adUnit, findsOneWidget);

      final Size size = tester.getSize(adUnit);
      expect(size.height, maxHeight);
    });

    testWidgets('Unfilled ad units collapse widget height',
        (WidgetTester tester) async {
      // When
      mockAdsByGoogle(mockAd(adStatus: AdStatus.UNFILLED));

      adSense.initialize(testClient);
      final Widget adUnitWidget = adSense.adUnit(
        AdUnitConfiguration.displayAdUnit(
          adSlot: testSlot,
        ),
      );

      await pumpAdWidget(adUnitWidget, tester);

      // Then
      expect(find.byType(HtmlElementView), findsNothing,
          reason: 'Unfilled ads should remove their platform view');

      final Finder adUnit = find.byWidget(adUnitWidget);
      expect(adUnit, findsOneWidget);

      final Size size = tester.getSize(adUnit);
      expect(size.height, 0);
    });

    testWidgets('Can handle multiple ads', (WidgetTester tester) async {
      // When
      mockAdsByGoogle(
        mockAds(<MockAdConfig>[
          (size: const Size(320, 200), adStatus: AdStatus.FILLED),
          (size: Size.zero, adStatus: AdStatus.UNFILLED),
          (size: const Size(640, 90), adStatus: AdStatus.FILLED),
        ]),
      );

      adSense.initialize(testClient);

      final Widget bunchOfAds = Column(
        children: <Widget>[
          adSense.adUnit(AdUnitConfiguration.displayAdUnit(
            adSlot: testSlot,
            adFormat: AdFormat.AUTO,
          )),
          adSense.adUnit(AdUnitConfiguration.displayAdUnit(
            adSlot: testSlot,
            adFormat: AdFormat.AUTO,
          )),
          Container(
            constraints: const BoxConstraints(maxHeight: 100),
            child: adSense.adUnit(AdUnitConfiguration.displayAdUnit(
              adSlot: testSlot,
            )),
          ),
        ],
      );

      await pumpAdWidget(bunchOfAds, tester);

      // Then
      // Widget level
      final Finder platformViews = find.byType(HtmlElementView);
      expect(platformViews, findsExactly(2),
          reason: 'The platform view of unfilled ads should be removed.');

      final Finder adUnits = find.byType(AdUnitWidget);
      expect(adUnits, findsExactly(3));

      expect(tester.getSize(adUnits.at(0)).height, 200,
          reason: 'Responsive ad widget should resize to match its `ins`');
      expect(tester.getSize(adUnits.at(1)).height, 0,
          reason: 'Unfulfilled ad should be 0x0');
      expect(tester.getSize(adUnits.at(2)).height, 100,
          reason: 'The constrained ad should use the height of container');
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
