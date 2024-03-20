// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:interactive_media_ads/src/platform_interface/platform_interface.dart';

import '../test_stubs.dart';

void main() {
  test('Cannot be implemented with `implements`', () {
    InteractiveMediaAdsPlatform.instance = TestInteractiveMediaAdsPlatform(
      onCreatePlatformAdsManagerDelegate: (
        PlatformAdsManagerDelegateCreationParams params,
      ) {
        return ImplementsPlatformAdsManagerDelegate();
      },
    );

    expect(
      () => PlatformAdsManagerDelegate(
        const PlatformAdsManagerDelegateCreationParams(),
      ),
      throwsAssertionError,
    );
  });

  test('Can be extended', () {
    InteractiveMediaAdsPlatform.instance = TestInteractiveMediaAdsPlatform(
      onCreatePlatformAdsManagerDelegate: (
        PlatformAdsManagerDelegateCreationParams params,
      ) {
        return ExtendsPlatformAdsManagerDelegate(
          const PlatformAdsManagerDelegateCreationParams(),
        );
      },
    );

    expect(
      PlatformAdsManagerDelegate(
        const PlatformAdsManagerDelegateCreationParams(),
      ),
      isNotNull,
    );
  });
}

class ImplementsPlatformAdsManagerDelegate
    implements PlatformAdsManagerDelegate {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class ExtendsPlatformAdsManagerDelegate extends PlatformAdsManagerDelegate {
  ExtendsPlatformAdsManagerDelegate(super.params) : super.implementation();
}
