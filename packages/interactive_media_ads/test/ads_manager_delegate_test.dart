// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:interactive_media_ads/interactive_media_ads.dart';
import 'package:interactive_media_ads/src/platform_interface/platform_interface.dart';

import 'test_stubs.dart';

void main() {
  test('passes params to platform instance', () async {
    InteractiveMediaAdsPlatform.instance = TestInteractiveMediaAdsPlatform(
      onCreatePlatformAdsManagerDelegate:
          (PlatformAdsManagerDelegateCreationParams params) {
        return TestPlatformAdsManagerDelegate(params);
      },
      onCreatePlatformAdsLoader: (PlatformAdsLoaderCreationParams params) {
        throw UnimplementedError();
      },
      onCreatePlatformAdDisplayContainer:
          (PlatformAdDisplayContainerCreationParams params) {
        throw UnimplementedError();
      },
      onCreatePlatformContentProgressProvider: (_) =>
          throw UnimplementedError(),
    );

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
