// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interactive_media_ads/interactive_media_ads.dart';
import 'package:interactive_media_ads/src/ad_display_container.dart';
import 'package:interactive_media_ads/src/platform_interface/platform_interface.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'ad_display_container_test.mocks.dart';

@GenerateMocks(<Type>[PlatformAdDisplayContainer])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('build', (WidgetTester tester) async {
    final MockPlatformAdDisplayContainer mockPlatformAdDisplayContainer =
        MockPlatformAdDisplayContainer();
    when(mockPlatformAdDisplayContainer.build(any)).thenReturn(Container());

    await tester.pumpWidget(AdDisplayContainer.fromPlatform(
      platform: mockPlatformAdDisplayContainer,
    ));

    expect(find.byType(Container), findsOneWidget);
  });

  testWidgets('constructor parameters are correctly passed to creation params',
      (WidgetTester tester) async {
    InteractiveMediaAdsPlatform.instance = TestInteractiveMediaAdsPlatform();

    final AdDisplayContainer adDisplayContainer = AdDisplayContainer(
      key: GlobalKey(),
      onContainerAdded: (_) {},
    );

    // The key passed to the default constructor is used by the super class
    // and not passed to the platform implementation.
    expect(adDisplayContainer.platform.params.key, isNull);
  });
}

class TestInteractiveMediaAdsPlatform extends InteractiveMediaAdsPlatform {
  @override
  PlatformAdDisplayContainer createPlatformAdDisplayContainer(
    PlatformAdDisplayContainerCreationParams params,
  ) {
    return TestPlatformAdDisplayContainer(params);
  }
}

class TestPlatformAdDisplayContainer extends PlatformAdDisplayContainer {
  TestPlatformAdDisplayContainer(super.params) : super.implementation();

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}
