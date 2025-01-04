// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// TO run the test:
// 1. Run chrome driver with --port=4444
// 2. Run the test from example folder with: flutter drive -d web-server --web-port 7357 --browser-name chrome --driver test_driver/integration_test.dart --target integration_test/ad_widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_adsense/experimental/ad_unit_widget.dart';
// Ensure we don't use the `adSense` singleton for tests.
import 'package:google_adsense/google_adsense.dart' hide adSense;
import 'package:google_adsense/src/adsense/ad_unit_params.dart';
import 'package:integration_test/integration_test.dart';

import 'js_interop_mocks/adsense_test_js_interop.dart';

const String testClient = 'test_client';
const String testSlot = 'test_slot';

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late AdSense adSense;

  setUp(() async {
    adSense = AdSense();
  });

  tearDown(() {
    clearAdsByGoogleMock();
  });

  group('adSense.adUnit', () {
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

      await adSense.initialize(testClient);

      final Widget adUnitWidget = AdUnitWidget(
        configuration: AdUnitConfiguration.displayAdUnit(
          adSlot: testSlot,
          adFormat: AdFormat.AUTO, // Important!
        ),
        adClient: adSense.adClient,
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

      await adSense.initialize(testClient);

      final Widget adUnitWidget = AdUnitWidget(
        configuration: AdUnitConfiguration.displayAdUnit(
          adSlot: testSlot,
        ),
        adClient: adSense.adClient,
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

      await adSense.initialize(testClient);
      final Widget adUnitWidget = AdUnitWidget(
        configuration: AdUnitConfiguration.displayAdUnit(
          adSlot: testSlot,
        ),
        adClient: adSense.adClient,
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

      await adSense.initialize(testClient);

      final Widget bunchOfAds = Column(
        children: <Widget>[
          AdUnitWidget(
            configuration: AdUnitConfiguration.displayAdUnit(
              adSlot: testSlot,
              adFormat: AdFormat.AUTO,
            ),
            adClient: adSense.adClient,
          ),
          AdUnitWidget(
            configuration: AdUnitConfiguration.displayAdUnit(
              adSlot: testSlot,
              adFormat: AdFormat.AUTO,
            ),
            adClient: adSense.adClient,
          ),
          Container(
            constraints: const BoxConstraints(maxHeight: 100),
            child: AdUnitWidget(
              configuration: AdUnitConfiguration.displayAdUnit(
                adSlot: testSlot,
              ),
              adClient: adSense.adClient,
            ),
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
  // One more for skwasm.
  await tester.pump();
  // This extra pump is needed to simulate the async behavior of the adsense JS mock.
  await tester.pumpAndSettle();
}
