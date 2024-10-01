// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@TestOn('chrome')
library;

import 'dart:js_interop';

import 'package:google_adsense_ad_placement_api_web/google_adsense_ad_placement_api_web.dart';
import 'package:google_adsense_ad_placement_api_web/src/ad_placement_api_js_interop.dart';
import 'package:test/test.dart';

@JSExport()
class FakeAdPlacementApiJSObject {
  bool adBreakCalled = false;
  JSString? nameUsed;
  JSString? lastBreakTypeUsed;
  JSString? preloadAdBreaks;
  JSString? sound;

  @JSExport()
  // ignore: unreachable_from_main
  void adBreak(AdBreakParamJSObject o) {
    adBreakCalled = true;
    lastBreakTypeUsed = o.type;
    nameUsed = o.name;
    if (o.adBreakDone != null) {
      final AdBreakDoneCallbackParamJSObject adBreakDoneParam =
          AdBreakDoneCallbackParamJSObject(JSObject());
      adBreakDoneParam.breakFormat = 'interstitial'.toJS;
      adBreakDoneParam.breakName = 'myBreak'.toJS;
      adBreakDoneParam.breakType = 'reward'.toJS;
      adBreakDoneParam.breakStatus = 'dismissed'.toJS;
      o.adBreakDone!.callAsFunction(null, adBreakDoneParam);
    }
  }

  @JSExport()
  // ignore: unreachable_from_main
  void adConfig(AdConfigParamJSObject param) {
    preloadAdBreaks = param.preloadAdBreaks;
    sound = param.sound;
    param.onReady?.callAsFunction();
  }
}

void main() {
  group('AdPlacementApi', () {
    AdPlacementApi? adPlacementApi;
    FakeAdPlacementApiJSObject? fakeAdPlacementApi;

    setUp(() {
      fakeAdPlacementApi = FakeAdPlacementApiJSObject();
      final AdPlacementApiJSObject adPlacementApiJSObject =
          createJSInteropWrapper<FakeAdPlacementApiJSObject>(
              fakeAdPlacementApi!) as AdPlacementApiJSObject;
      adPlacementApi = AdPlacementApi(adPlacementApiJSObject);
    });

    test('can do ad breaks', () {
      adPlacementApi?.adBreak(
        type: BreakType.reward,
      );

      expect(fakeAdPlacementApi?.adBreakCalled, isTrue);
      expect(fakeAdPlacementApi?.lastBreakTypeUsed?.toDart,
          equals(BreakType.reward.name));
    });

    test('can call the adBreakDone callback', () {
      bool called = false;
      void adBreakDoneCallback(
        BreakType? breakType,
        String? breakName,
        BreakFormat? breakFormat,
        BreakStatus? breakStatus,
      ) {
        called = true;
      }

      adPlacementApi?.adBreak(
        type: BreakType.reward,
        adBreakDone: adBreakDoneCallback,
      );

      expect(called, isTrue);
    });

    test('can set up configuration', () {
      bool called = false;
      void onReadyCallback() {
        called = true;
      }

      adPlacementApi?.adConfig(
          PreloadAdBreaks.on, SoundEnabled.off, onReadyCallback);

      expect(fakeAdPlacementApi?.sound?.toDart, equals(SoundEnabled.off.name));
      expect(fakeAdPlacementApi?.preloadAdBreaks?.toDart,
          equals(PreloadAdBreaks.on.name));
      expect(called, isTrue);
    });

    test('perfixes adBreak name', () {
      adPlacementApi?.adBreak(
        type: BreakType.preroll,
        name: 'My Break',
      );

      expect(fakeAdPlacementApi?.adBreakCalled, isTrue);
      expect(
          fakeAdPlacementApi?.nameUsed?.toDart, equals('APFlutter-My Break'));
    });
  });
}
