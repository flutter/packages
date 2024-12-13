// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:js_interop';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_adsense/google_adsense.dart';
import 'package:google_adsense/h5.dart';
import 'package:integration_test/integration_test.dart';
import 'js_interop_mocks/h5_test_js_interop.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late AdSense adSense;

  setUp(() async {
    adSense = AdSense();
  });

  tearDown(() {
    clearAdsByGoogleMock();
  });

  group('h5GamesAds.adBreak', () {
    testWidgets('can do ad breaks', (WidgetTester tester) async {
      mockAdsByGoogle(
        mockAdBreak(),
      );
      await adSense.initialize('_');

      final AdBreakPlacement adBreakPlacement = AdBreakPlacement(
        type: BreakType.reward,
      );

      h5GamesAds.adBreak(adBreakPlacement);

      // Pump frames so we can see what happened with adBreak
      await tester.pump();
      await tester.pump();

      expect(lastAdBreakPlacement, isNotNull);
      expect(lastAdBreakPlacement!.type?.toDart, 'reward');
    });

    testWidgets('can call the adBreakDone callback',
        (WidgetTester tester) async {
      AdBreakDonePlacementInfo? lastPlacementInfo;

      void adBreakDoneCallback(AdBreakDonePlacementInfo placementInfo) {
        lastPlacementInfo = placementInfo;
      }

      mockAdsByGoogle(
        mockAdBreak(
          adBreakDonePlacementInfo: AdBreakDonePlacementInfo(
            breakName: 'ok-for-tests'.toJS,
          ),
        ),
      );
      await adSense.initialize('_');

      final AdBreakPlacement adBreakPlacement = AdBreakPlacement(
        type: BreakType.reward,
        adBreakDone: adBreakDoneCallback,
      );

      h5GamesAds.adBreak(adBreakPlacement);

      // Pump frames so we can see what happened with adBreak
      await tester.pump();
      await tester.pump();

      expect(lastPlacementInfo, isNotNull);
      expect(lastPlacementInfo!.breakName, 'ok-for-tests');
    });

    testWidgets('prefixes adBreak name', (WidgetTester tester) async {
      mockAdsByGoogle(
        mockAdBreak(),
      );
      await adSense.initialize('_');

      final AdBreakPlacement adBreakPlacement = AdBreakPlacement(
        type: BreakType.reward,
        name: 'my-test-break',
      );

      h5GamesAds.adBreak(adBreakPlacement);

      // Pump frames so we can see what happened with adBreak
      await tester.pump();
      await tester.pump();

      expect(lastAdBreakPlacement!.name!.toDart, 'APFlutter-my-test-break');
    });
  });

  group('h5GamesAds.adConfig', () {
    testWidgets('can set up configuration', (WidgetTester tester) async {
      bool called = false;
      void onReadyCallback() {
        called = true;
      }

      mockAdsByGoogle(
        mockAdConfig(),
      );
      await adSense.initialize('_');

      h5GamesAds.adConfig(
        AdConfigParameters(
          preloadAdBreaks: PreloadAdBreaks.on,
          sound: SoundEnabled.off,
          onReady: onReadyCallback,
        ),
      );

      // Pump frames so we can see what happened with adConfig
      await tester.pump();
      await tester.pump();

      expect(lastAdConfigParameters, isNotNull);
      expect(lastAdConfigParameters!.sound!.toDart, 'off');
      expect(lastAdConfigParameters!.preloadAdBreaks!.toDart, 'on');
      expect(called, isTrue);
    });
  });
}
