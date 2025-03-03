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

import 'js_interop_mocks/adsense_test_js_interop.dart';

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

      await adSense.initialize(testClient, jsLoaderTarget: target);

      final web.HTMLScriptElement? injected =
          target.lastElementChild as web.HTMLScriptElement?;

      expect(injected, isNotNull);
      expect(injected!.src, testScriptUrl);
      expect(injected.crossOrigin, 'anonymous');
      expect(injected.async, true);
    });

    testWidgets('sets AdSenseCodeParameters in script tag.',
        (WidgetTester _) async {
      final web.HTMLElement target = web.HTMLDivElement();

      await adSense.initialize(testClient,
          jsLoaderTarget: target,
          adSenseCodeParameters: AdSenseCodeParameters(
            adHost: 'test-adHost',
            admobInterstitialSlot: 'test-admobInterstitialSlot',
            admobRewardedSlot: 'test-admobRewardedSlot',
            adChannel: 'test-adChannel',
            adbreakTest: 'test-adbreakTest',
            tagForChildDirectedTreatment: 'test-tagForChildDirectedTreatment',
            tagForUnderAgeOfConsent: 'test-tagForUnderAgeOfConsent',
            adFrequencyHint: 'test-adFrequencyHint',
          ));

      final web.HTMLScriptElement injected =
          target.lastElementChild! as web.HTMLScriptElement;

      expect(injected.dataset['adHost'], 'test-adHost');
      expect(injected.dataset['admobInterstitialSlot'],
          'test-admobInterstitialSlot');
      expect(injected.dataset['admobRewardedSlot'], 'test-admobRewardedSlot');
      expect(injected.dataset['adChannel'], 'test-adChannel');
      expect(injected.dataset['adbreakTest'], 'test-adbreakTest');
      expect(injected.dataset['tagForChildDirectedTreatment'],
          'test-tagForChildDirectedTreatment');
      expect(injected.dataset['tagForUnderAgeOfConsent'],
          'test-tagForUnderAgeOfConsent');
      expect(injected.dataset['adFrequencyHint'], 'test-adFrequencyHint');
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
      mockAdsByGoogle((_) {});

      await adSense.initialize(testClient, jsLoaderTarget: target);

      expect(target.firstElementChild, isNull);
    });
  });
}
