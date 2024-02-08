// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:interactive_media_ads/interactive_media_ads.dart';
import 'package:interactive_media_ads/src/platform_interface/platform_interface.dart';

void main() {
  test('passes params to platform instance', () async {
    InteractiveMediaAdsPlatform.instance = TestInteractiveMediaAdsPlatform();

    void onAdEvent(AdEvent event) {}
    void onAdErrorEvent(AdErrorEvent event) {}

    final AdsManagerDelegate delegate = AdsManagerDelegate(
      onAdEvent: onAdEvent,
      onAdErrorEvent: onAdErrorEvent,
    );

    expect(delegate.platform.params.onAdEvent, onAdEvent);
    expect(delegate.platform.params.onAdErrorEvent, onAdErrorEvent);
  });
}

class TestInteractiveMediaAdsPlatform extends InteractiveMediaAdsPlatform {
  @override
  PlatformAdsManagerDelegate createPlatformAdsManagerDelegate(
    PlatformAdsManagerDelegateCreationParams params,
  ) {
    return TestPlatformPlatformAdsManagerDelegate(params);
  }
}

class TestPlatformPlatformAdsManagerDelegate
    extends PlatformAdsManagerDelegate {
  TestPlatformPlatformAdsManagerDelegate(super.params) : super.implementation();
}
