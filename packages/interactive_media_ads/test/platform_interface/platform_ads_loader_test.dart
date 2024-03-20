// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interactive_media_ads/src/platform_interface/platform_interface.dart';

import '../test_stubs.dart';

void main() {
  PlatformAdsLoaderCreationParams createEmptyParams() {
    return PlatformAdsLoaderCreationParams(
      container: TestPlatformAdDisplayContainer(
        PlatformAdDisplayContainerCreationParams(onContainerAdded: (_) {}),
        onBuild: (_) => Container(),
      ),
      onAdsLoaded: (_) {},
      onAdsLoadError: (_) {},
    );
  }

  test(
      'Default implementation of contentComplete should throw unimplemented error',
      () {
    final PlatformAdsLoader loader =
        ExtendsPlatformAdsLoader(createEmptyParams());

    expect(
      () => loader.contentComplete(),
      throwsUnimplementedError,
    );
  });

  test('Default implementation of requestAds should throw unimplemented error',
      () {
    final PlatformAdsLoader loader =
        ExtendsPlatformAdsLoader(createEmptyParams());

    expect(
      () => loader.requestAds(AdsRequest(adTagUrl: '')),
      throwsUnimplementedError,
    );
  });
}

final class ExtendsPlatformAdsLoader extends PlatformAdsLoader {
  ExtendsPlatformAdsLoader(super.params) : super.implementation();
}
