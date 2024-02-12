// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:interactive_media_ads/src/platform_interface/platform_interface.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'platform_ads_manager_delegate_test.mocks.dart';

@GenerateMocks(<Type>[
  InteractiveMediaAdsPlatform,
  PlatformAdsManagerDelegate,
])
void main() {
  setUp(() {
    InteractiveMediaAdsPlatform.instance =
        MockInteractiveMediaAdsPlatformWithMixin();
  });

  test('Cannot be implemented with `implements`', () {
    when((InteractiveMediaAdsPlatform.instance!
                as MockInteractiveMediaAdsPlatform)
            .createPlatformAdsManagerDelegate(any))
        .thenReturn(ImplementsPlatformAdsManagerDelegate());

    expect(
      () => PlatformAdsManagerDelegate(
        const PlatformAdsManagerDelegateCreationParams(),
      ),
      throwsAssertionError,
    );
  });

  test('Can be extended', () {
    when((InteractiveMediaAdsPlatform.instance!
                as MockInteractiveMediaAdsPlatform)
            .createPlatformAdsManagerDelegate(any))
        .thenReturn(ExtendsPlatformAdsManagerDelegate(
      const PlatformAdsManagerDelegateCreationParams(),
    ));

    expect(
      PlatformAdsManagerDelegate(
        const PlatformAdsManagerDelegateCreationParams(),
      ),
      isNotNull,
    );
  });
}

class MockInteractiveMediaAdsPlatformWithMixin
    extends MockInteractiveMediaAdsPlatform with MockPlatformInterfaceMixin {}

class ImplementsPlatformAdsManagerDelegate
    implements PlatformAdsManagerDelegate {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class ExtendsPlatformAdsManagerDelegate extends PlatformAdsManagerDelegate {
  ExtendsPlatformAdsManagerDelegate(super.params) : super.implementation();
}
