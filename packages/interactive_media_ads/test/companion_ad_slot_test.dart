// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interactive_media_ads/interactive_media_ads.dart';
import 'package:interactive_media_ads/src/platform_interface/platform_interface.dart';

import 'test_stubs.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('build', (WidgetTester tester) async {
    final TestCompanionAdSlot slot = TestCompanionAdSlot(
      const PlatformCompanionAdSlotCreationParams.fluid(),
      onBuild: (_) => Container(),
    );

    await tester.pumpWidget(CompanionAdSlot.fromPlatform(
      platform: slot,
    ));

    expect(find.byType(Container), findsOneWidget);
  });

  testWidgets('constructor parameters are correctly passed to creation params',
      (WidgetTester tester) async {
    InteractiveMediaAdsPlatform.instance = TestInteractiveMediaAdsPlatform(
      onCreatePlatformCompanionAdSlot: (
        PlatformCompanionAdSlotCreationParams params,
      ) {
        return TestCompanionAdSlot(params, onBuild: (_) => Container());
      },
      onCreatePlatformAdDisplayContainer: (
        PlatformAdDisplayContainerCreationParams params,
      ) {
        return TestPlatformAdDisplayContainer(
          params,
          onBuild: (_) => Container(),
        );
      },
      onCreatePlatformAdsLoader: (PlatformAdsLoaderCreationParams params) {
        throw UnimplementedError();
      },
      onCreatePlatformAdsManagerDelegate: (
        PlatformAdsManagerDelegateCreationParams params,
      ) {
        throw UnimplementedError();
      },
      onCreatePlatformContentProgressProvider: (_) {
        throw UnimplementedError();
      },
    );

    final CompanionAdSlot slot = CompanionAdSlot.fluid(key: GlobalKey());

    // The key passed to the default constructor is used by the super class
    // and not passed to the platform implementation.
    expect(slot.platform.params.key, isNull);
  });
}
