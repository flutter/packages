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

  testWidgets('buildWidget', (WidgetTester tester) async {
    final TestCompanionAdSlot slot = TestCompanionAdSlot(
      PlatformCompanionAdSlotCreationParams(size: CompanionAdSlotSize.fluid()),
      onBuildWidget: (_) => Container(),
    );

    await tester.pumpWidget(
      Builder(
        builder: (BuildContext context) {
          return CompanionAdSlot.fromPlatform(slot).buildWidget(context);
        },
      ),
    );

    expect(find.byType(Container), findsOneWidget);
  });
}
